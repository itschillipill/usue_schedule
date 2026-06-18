package com.flutter.m.usue_schedule

import android.content.ContentValues
import android.content.pm.PackageManager
import android.os.Build
import android.os.Bundle
import android.os.Environment
import android.provider.MediaStore
import androidx.annotation.NonNull
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.Result
import java.io.File
import java.io.IOException

class MainActivity: FlutterActivity() {
    private val CHANNEL = "app.channel.files"
    private val PERMISSION_REQUEST_CODE = 123
    
    // Храним данные для повторной попытки после получения разрешения
    private var pendingFileName: String? = null
    private var pendingBytes: ByteArray? = null
    private var pendingResult: Result? = null

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "saveFile" -> {
                        val fileName = call.argument<String>("fileName") ?: "file.txt"
                        val bytes = call.argument<ByteArray>("bytes")
                        
                        if (bytes == null) {
                            result.error("FILE_SAVE_ERROR", "Bytes data is null", null)
                            return@setMethodCallHandler
                        }
                        
                        handleSaveFile(fileName, bytes, result)
                    }
                    else -> result.notImplemented()
                }
            }
    }
    
    private fun handleSaveFile(fileName: String, bytes: ByteArray, result: Result) {
        try {
            // Для Android 10+ разрешение не требуется
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                val savedPath = saveFileUsingMediaStore(fileName, bytes)
                result.success(savedPath)
                return
            }
            
            // Для Android 9 и ниже проверяем разрешение
            if (checkStoragePermission()) {
                // Разрешение уже есть - сохраняем
                val savedPath = saveFileUsingFileSystem(fileName, bytes)
                result.success(savedPath)
            } else {
                // Разрешения нет - запоминаем данные и запрашиваем разрешение
                pendingFileName = fileName
                pendingBytes = bytes
                pendingResult = result
                
                requestStoragePermission()
                // НЕ возвращаем ошибку сразу!
            }
        } catch (e: Exception) {
            result.error("FILE_SAVE_ERROR", e.message, null)
        }
    }

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray
    ) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        
        when (requestCode) {
            PERMISSION_REQUEST_CODE -> {
                if (grantResults.isNotEmpty() && grantResults[0] == PackageManager.PERMISSION_GRANTED) {
                    // Разрешение получено - пробуем сохранить снова
                    val fileName = pendingFileName
                    val bytes = pendingBytes
                    val result = pendingResult
                    
                    if (fileName != null && bytes != null && result != null) {
                        try {
                            val savedPath = saveFileUsingFileSystem(fileName, bytes)
                            result.success(savedPath)
                        } catch (e: Exception) {
                            result.error("FILE_SAVE_ERROR", e.message, null)
                        } finally {
                            // Очищаем временные данные
                            pendingFileName = null
                            pendingBytes = null
                            pendingResult = null
                        }
                    }
                } else {
                    // Пользователь отказал в разрешении
                    pendingResult?.error("PERMISSION_DENIED", "Storage permission denied by user", null)
                    
                    // Очищаем временные данные
                    pendingFileName = null
                    pendingBytes = null
                    pendingResult = null
                }
            }
        }
    }

    private fun saveFileUsingMediaStore(fileName: String, bytes: ByteArray): String {
    val resolver = contentResolver
    val collection = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
        MediaStore.Downloads.getContentUri(MediaStore.VOLUME_EXTERNAL_PRIMARY)
    } else {
        MediaStore.Downloads.EXTERNAL_CONTENT_URI
    }

    // Ищем, есть ли уже файл с таким именем в папке Downloads
    val projection = arrayOf(MediaStore.Downloads._ID)
    val selection = "${MediaStore.Downloads.DISPLAY_NAME} == ?"
    val selectionArgs = arrayOf(fileName)

    resolver.query(collection, projection, selection, selectionArgs, null)?.use { cursor ->
        if (cursor.moveToFirst()) {
            val id = cursor.getLong(cursor.getColumnIndexOrThrow(MediaStore.Downloads._ID))
            val existingUri = android.content.ContentUris.withAppendedId(collection, id)
            
            // Удаляем старый файл, чтобы новый создался с тем же именем без суффикса (1)
            try {
                resolver.delete(existingUri, null, null)
            } catch (e: Exception) {}
        }
    }

    val contentValues = ContentValues().apply {
        put(MediaStore.Downloads.DISPLAY_NAME, fileName)
        put(MediaStore.Downloads.MIME_TYPE, getMimeType(fileName))
        put(MediaStore.Downloads.RELATIVE_PATH, Environment.DIRECTORY_DOWNLOADS)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            put(MediaStore.Downloads.IS_PENDING, 1)
        }
    }

    val uri = resolver.insert(collection, contentValues)
        ?: throw Exception("Не удалось создать запись в MediaStore")

    try {
        resolver.openOutputStream(uri)?.use { outputStream ->
            outputStream.write(bytes)
            outputStream.flush()
        } ?: throw Exception("Не удалось открыть поток для записи")

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            contentValues.clear()
            contentValues.put(MediaStore.Downloads.IS_PENDING, 0)
            resolver.update(uri, contentValues, null, null)
        }
    } catch (e: Exception) {
        resolver.delete(uri, null, null)
        throw e
    }

    return uri.toString()
}
    private fun saveFileUsingFileSystem(fileName: String, bytes: ByteArray): String {
        val downloadsDir = Environment.getExternalStoragePublicDirectory(
            Environment.DIRECTORY_DOWNLOADS
        )
        
        if (!downloadsDir.exists()) {
            downloadsDir.mkdirs()
        }
        
        val file = File(downloadsDir, fileName)
        
        try {
            file.outputStream().use { outputStream ->
                outputStream.write(bytes)
            }
            return file.absolutePath
        } catch (e: IOException) {
            throw IOException("Failed to write to Downloads directory: ${e.message}")
        }
    }

    private fun checkStoragePermission(): Boolean {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            ContextCompat.checkSelfPermission(this, android.Manifest.permission.WRITE_EXTERNAL_STORAGE) == PackageManager.PERMISSION_GRANTED
        } else {
            true
        }
    }

    private fun requestStoragePermission() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            ActivityCompat.requestPermissions(
                this,
                arrayOf(android.Manifest.permission.WRITE_EXTERNAL_STORAGE),
                PERMISSION_REQUEST_CODE
            )
        }
    }

    private fun getMimeType(fileName: String): String {
        return when {
            fileName.endsWith(".ics") -> "text/calendar"
            fileName.endsWith(".doc") -> "application/msword"
            fileName.endsWith(".docx") -> "application/vnd.openxmlformats-officedocument.wordprocessingml.document"
            fileName.endsWith(".txt") -> "text/plain"
            fileName.endsWith(".pdf") -> "application/pdf"
            else -> "application/octet-stream"
        }
    }
}