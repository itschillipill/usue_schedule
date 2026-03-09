import '../../../core/utils/date_utils.dart';
import '../../schedule/models/schedule_response.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'package:archive/archive_io.dart';

class DocxGenerator {
  static Uint8List create(ScheduleResponse schedule, String title) {
    final archive = Archive();

    _addFile(archive, '[Content_Types].xml', _contentTypesXml);
    _addFile(archive, '_rels/.rels', _relsXml);
    _addFile(archive, 'word/_rels/document.xml.rels', _documentRelsXml);
    _addFile(archive, 'word/styles.xml', _stylesXml);

    final documentXml = _buildDocumentXml(schedule, title);
    _addFile(archive, 'word/document.xml', documentXml);

    final encoder = ZipEncoder();
    final encoded = encoder.encode(archive);
    return Uint8List.fromList(encoded);
  }

  static void _addFile(Archive archive, String path, String content) {
    final bytes = utf8.encode(content);
    archive.addFile(ArchiveFile(path, bytes.length, bytes));
  }

  static String _buildDocumentXml(ScheduleResponse schedule, String title) {
    final buffer = StringBuffer();

    buffer.writeln('<?xml version="1.0" encoding="UTF-8" standalone="yes"?>');
    buffer.writeln(
        '<w:document xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main" '
        'xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships" '
        'xmlns:mc="http://schemas.openxmlformats.org/markup-compatibility/2006" '
        'xmlns:w14="http://schemas.microsoft.com/office/word/2010/wordml" '
        'xmlns:wp14="http://schemas.microsoft.com/office/word/2010/wordprocessingDrawing" '
        'mc:Ignorable="w14 wp14">');

    buffer.writeln('<w:body>');

    _addParagraph(buffer, title, fontSize: 36, bold: true, center: true);
    _addParagraph(buffer, '');

    for (final day in schedule.schedules.where((d) => d.hasPairs)) {
      final dayDate = DateTimeUtils.parseDate(day.date)!;
      final dayTitle =
          "${DateTimeUtils.getWeekdayName(dayDate.weekday)}, ${day.date}";
      _addParagraph(buffer, dayTitle, fontSize: 28, bold: true, keepNext: true);
      buffer.writeln('<w:tbl>');

      buffer.writeln('<w:tblPr>');
      buffer.writeln('<w:tblW w:w="5000" w:type="pct"/>');
      buffer.writeln('<w:tblLayout w:type="fixed"/>');

      buffer.writeln('<w:tblBorders>');
      for (var border in [
        'top',
        'left',
        'bottom',
        'right',
        'insideH',
        'insideV'
      ]) {
        buffer.writeln(
            '<w:$border w:val="single" w:sz="2" w:space="0" w:color="000000"/>');
      }
      buffer.writeln('</w:tblBorders>');
      buffer.writeln('</w:tblPr>');

      buffer.writeln('<w:tblGrid>');
      buffer.writeln('<w:gridCol w:w="1500"/>');
      buffer.writeln('<w:gridCol w:w="3000"/>');
      buffer.writeln('<w:gridCol w:w="1500"/>');
      buffer.writeln('<w:gridCol w:w="1500"/>');
      buffer.writeln('<w:gridCol w:w="1500"/>');
      buffer.writeln('</w:tblGrid>');

      //  buffer.writeln('<w:tr>');
      //   buffer.writeln('<w:trPr><w:cantSplit/></w:trPr>');

      //   _addTableCell(buffer, dayTitle,
      //       bold: true, bgColor: 'F0F0F0', percentage: '15', keepNext: true);
      //   _addTableCell(buffer, '',
      //       bold: true, bgColor: 'F0F0F0', percentage: '30', keepNext: true);
      //   _addTableCell(buffer, '',
      //       bold: true, bgColor: 'F0F0F0', percentage: '15', keepNext: true);
      //   _addTableCell(buffer, '',
      //       bold: true, bgColor: 'F0F0F0', percentage: '15', keepNext: true);
      //   _addTableCell(buffer, '',
      //       bold: true, bgColor: 'F0F0F0', percentage: '15', keepNext: true);

      //   buffer.writeln('</w:tr>');

      /// HEADER
      buffer.writeln('<w:tr>');
      buffer.writeln('<w:trPr><w:cantSplit/></w:trPr>');

      _addTableCell(buffer, 'Время',
          bold: true, bgColor: 'F0F0F0', percentage: '15', keepNext: true);
      _addTableCell(buffer, 'Предмет',
          bold: true, bgColor: 'F0F0F0', percentage: '30', keepNext: true);
      _addTableCell(buffer, 'Группа',
          bold: true, bgColor: 'F0F0F0', percentage: '15', keepNext: true);
      _addTableCell(buffer, 'Преподаватель',
          bold: true, bgColor: 'F0F0F0', percentage: '15', keepNext: true);
      _addTableCell(buffer, 'Ауд.',
          bold: true, bgColor: 'F0F0F0', percentage: '15', keepNext: true);

      buffer.writeln('</w:tr>');

//           buffer.writeln('<w:tr>');
// buffer.writeln('<w:trPr><w:cantSplit/></w:trPr>');

// _addDayHeaderCell(
//   buffer,
//   dayTitle,
//   gridSpan: 5,
//   bgColor: 'F0F0F0',
//   keepNext: true,
// );

// buffer.writeln('</w:tr>');

      /// FLATTEN ROWS
      final rows = <MapEntry<dynamic, dynamic>>[];

      for (final pair in day.nonEmptyPairs) {
        for (final sp in pair.schedulePairs) {
          rows.add(MapEntry(pair, sp));
        }
      }

      /// DATA ROWS
      for (int i = 0; i < rows.length; i++) {
        final pair = rows[i].key;
        final sp = rows[i].value;

        final keepNext = i != rows.length - 1;

        final audience = sp.comment.isNotEmpty
            ? "${sp.audience} (${sp.comment})"
            : sp.audience;

        buffer.writeln('<w:tr>');
        buffer.writeln('<w:trPr><w:cantSplit/></w:trPr>');

        _addTableCell(buffer, pair.pairTime,
            bold: true, percentage: '15', keepNext: keepNext);

        _addTableCell(buffer, sp.subject, percentage: '30', keepNext: keepNext);

        _addTableCell(buffer, sp.group, percentage: '15', keepNext: keepNext);

        _addTableCell(buffer, sp.teacher, percentage: '15', keepNext: keepNext);

        _addTableCell(buffer, audience, percentage: '15', keepNext: keepNext);

        buffer.writeln('</w:tr>');
      }

      buffer.writeln('</w:tbl>');
      _addParagraph(buffer, '');
    }

    buffer.writeln('<w:sectPr>');
    buffer.writeln('<w:pgSz w:w="11906" w:h="16838"/>');
    buffer.writeln(
        '<w:pgMar w:top="720" w:right="720" w:bottom="720" w:left="720"/>');
    buffer.writeln('</w:sectPr>');

    buffer.writeln('</w:body>');
    buffer.writeln('</w:document>');

    return buffer.toString();
  }

  static void _addParagraph(StringBuffer buffer, String text,
      {int fontSize = 24,
      bool bold = false,
      bool italic = false,
      bool center = false,
      bool right = false,
      bool keepNext = false}) {
    buffer.writeln('<w:p>');
    if (center || right || keepNext) {
      buffer.writeln('<w:pPr>');
      if (center) buffer.writeln('<w:jc w:val="center"/>');
      if (right) buffer.writeln('<w:jc w:val="right"/>');
      if (keepNext) buffer.writeln('<w:keepNext/>');
      buffer.writeln('</w:pPr>');
    }

    if (text.isNotEmpty) {
      buffer.writeln('<w:r>');
      buffer.writeln('<w:rPr>');
      if (bold) buffer.writeln('<w:b/>');
      if (italic) buffer.writeln('<w:i/>');
      buffer.writeln('<w:sz w:val="$fontSize"/>');
      buffer.writeln('</w:rPr>');
      buffer.writeln('<w:t xml:space="preserve">${_escapeXml(text)}</w:t>');
      buffer.writeln('</w:r>');
    }

    buffer.writeln('</w:p>');
  }

  static void _addTableCell(
    StringBuffer buffer,
    String text, {
    bool bold = false,
    String? bgColor,
    required String percentage,
    bool keepNext = false,
  }) {
    buffer.writeln('<w:tc>');
    buffer.writeln('<w:tcPr>');
    buffer.writeln(' <w:tcW w:w="$percentage" w:type="pct"/>');

    if (bgColor != null) {
      buffer.writeln('<w:shd w:val="clear" w:color="auto" w:fill="$bgColor"/>');
    }

    buffer.writeln('</w:tcPr>');
    buffer.writeln('<w:p>');

    buffer.writeln('<w:pPr>');
    if (keepNext) {
      buffer.writeln('<w:keepNext/>');
    }
    buffer.writeln('<w:spacing w:line="300" w:lineRule="auto"/>');
    buffer.writeln('</w:pPr>');

    buffer.writeln('<w:r>');
    buffer.writeln('<w:rPr>');
    if (bold) buffer.writeln('<w:b/>');
    buffer.writeln('<w:sz w:val="20"/>');
    buffer.writeln('</w:rPr>');
    buffer.writeln('<w:t xml:space="preserve">${_escapeXml(text)}</w:t>');
    buffer.writeln('</w:r>');

    buffer.writeln('</w:p>');
    buffer.writeln('</w:tc>');
  }

  static String _escapeXml(String text) {
    return text
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&apos;');
  }

  // ==================== СИСТЕМНЫЕ ФАЙЛЫ ====================

  static const String _contentTypesXml =
      '''<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types">
  <Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/>
  <Default Extension="xml" ContentType="application/xml"/>
  <Override PartName="/word/document.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.document.main+xml"/>
  <Override PartName="/word/styles.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.styles+xml"/>
</Types>''';

  static const String _relsXml =
      '''<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">
  <Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument" Target="word/document.xml"/>
</Relationships>''';

  static const String _documentRelsXml =
      '''<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">
  <Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/styles" Target="styles.xml"/>
</Relationships>''';

  static const String _stylesXml =
      '''<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<w:styles xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">
  <w:docDefaults>
    <w:rPrDefault>
      <w:rPr>
        <w:rFonts w:ascii="Times New Roman" w:hAnsi="Times New Roman" w:cs="Times New Roman"/>
        <w:sz w:val="24"/>
        <w:szCs w:val="24"/>
      </w:rPr>
    </w:rPrDefault>
  </w:docDefaults>
  
  <w:style w:type="paragraph" w:styleId="Normal">
    <w:name w:val="Normal"/>
    <w:qFormat/>
  </w:style>
  
  <w:style w:type="paragraph" w:styleId="Title">
    <w:name w:val="Title"/>
    <w:basedOn w:val="Normal"/>
    <w:rPr>
      <w:b/>
      <w:sz w:val="36"/>
    </w:rPr>
  </w:style>
  
  <w:style w:type="paragraph" w:styleId="DayHeading">
    <w:name w:val="DayHeading"/>
    <w:basedOn w:val="Normal"/>
    <w:rPr>
      <w:b/>
      <w:sz w:val="28"/>
      <w:color w:val="2E74B5"/>
    </w:rPr>
  </w:style>
  
  <w:style w:type="character" w:styleId="DefaultParagraphFont">
    <w:name w:val="Default Paragraph Font"/>
    <w:uiPriority w:val="1"/>
  </w:style>
  
  <w:style w:type="table" w:styleId="TableGrid">
    <w:name w:val="Table Grid"/>
    <w:basedOn w:val="Normal"/>
    <w:tblPr>
      <w:tblBorders>
        <w:top w:val="single" w:sz="2" w:space="0" w:color="000000"/>
        <w:left w:val="single" w:sz="2" w:space="0" w:color="000000"/>
        <w:bottom w:val="single" w:sz="2" w:space="0" w:color="000000"/>
        <w:right w:val="single" w:sz="2" w:space="0" w:color="000000"/>
        <w:insideH w:val="single" w:sz="2" w:space="0" w:color="000000"/>
        <w:insideV w:val="single" w:sz="2" w:space="0" w:color="000000"/>
      </w:tblBorders>
    </w:tblPr>
  </w:style>
</w:styles>''';
}
