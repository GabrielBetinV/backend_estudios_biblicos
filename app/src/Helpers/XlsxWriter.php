<?php

namespace App\Helpers;

use ZipArchive;

class XlsxWriter
{
    private array $sections = [];
    private int $rowIndex = 0;
    private array $sharedStrings = [];
    private array $sharedIndex = [];
    private int $styleCount = 0;
    private string $defaultFont = 'Calibri';
    private int $defaultFontSize = 11;

    public function addSection(string $title, array $headers, array $data): void
    {
        $this->sections[] = [
            'title' => $title,
            'headers' => $headers,
            'data' => $data
        ];
    }

    private function addSharedString(string $value): int
    {
        if (!isset($this->sharedIndex[$value])) {
            $this->sharedIndex[$value] = count($this->sharedStrings);
            $this->sharedStrings[] = $value;
        }
        return $this->sharedIndex[$value];
    }

    private function cellRef(int $col, int $row): string
    {
        $colLetter = '';
        while ($col >= 0) {
            $colLetter = chr(65 + ($col % 26)) . $colLetter;
            $col = (int)($col / 26) - 1;
        }
        return $colLetter . $row;
    }

    public function generate(string $filename): void
    {
        // Build sheet XML first (this populates sharedStrings)
        $sheetXml = '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<worksheet xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships">
<cols><col min="1" max="50" width="30" customWidth="1"/></cols>
<sheetData>';

        $rowNum = 1;
        foreach ($this->sections as $section) {
            $sheetXml .= '<row r="' . $rowNum . '" ht="28" customHeight="1">';
            $si = $this->addSharedString($section['title']);
            $sheetXml .= '<c r="A' . $rowNum . '" t="s" s="2"><v>' . $si . '</v></c>';
            $sheetXml .= '</row>';
            $rowNum++;

            $sheetXml .= '<row r="' . $rowNum . '" ht="22" customHeight="1">';
            foreach ($section['headers'] as $colIdx => $header) {
                $si = $this->addSharedString($header);
                $sheetXml .= '<c r="' . $this->cellRef($colIdx, $rowNum) . '" t="s" s="1"><v>' . $si . '</v></c>';
            }
            $sheetXml .= '</row>';
            $rowNum++;

            foreach ($section['data'] as $row) {
                $sheetXml .= '<row r="' . $rowNum . '">';
                foreach ($row as $colIdx => $value) {
                    $ref = $this->cellRef($colIdx, $rowNum);
                    if (is_numeric($value)) {
                        $sheetXml .= '<c r="' . $ref . '" s="3"><v>' . $value . '</v></c>';
                    } else {
                        $si = $this->addSharedString((string)$value);
                        $sheetXml .= '<c r="' . $ref . '" t="s" s="3"><v>' . $si . '</v></c>';
                    }
                }
                $sheetXml .= '</row>';
                $rowNum++;
            }
            $rowNum++;
        }
        $sheetXml .= '</sheetData></worksheet>';

        // Now build shared strings XML (with all strings collected from sheet building)
        $ssXml = '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<sst xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main" count="' . count($this->sharedStrings) . '" uniqueCount="' . count($this->sharedStrings) . '">';
        foreach ($this->sharedStrings as $s) {
            $ssXml .= '<si><t>' . htmlspecialchars($s, ENT_XML1) . '</t></si>';
        }
        $ssXml .= '</sst>';

        // Build the ZIP
        $zip = new ZipArchive();
        $zip->open($filename, ZipArchive::CREATE | ZipArchive::OVERWRITE);

        $zip->addFromString('xl/worksheets/sheet1.xml', $sheetXml);
        $zip->addFromString('xl/sharedStrings.xml', $ssXml);
        $zip->addFromString('xl/styles.xml',
            '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<styleSheet xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main">
<fonts count="3">
  <font><sz val="11"/><name val="Calibri"/></font>
  <font><b/><sz val="12"/><color rgb="FFFFFFFF"/><name val="Calibri"/></font>
  <font><b/><sz val="11"/><name val="Calibri"/></font>
</fonts>
<fills count="3">
  <fill><patternFill patternType="none"/></fill>
  <fill><patternFill patternType="gray125"/></fill>
  <fill><patternFill patternType="solid"><fgColor rgb="FF4F46E5"/></patternFill></fill>
</fills>
<borders count="2">
  <border><left/><right/><top/><bottom/><diagonal/></border>
  <border>
    <left style="thin"><color auto="1"/></left>
    <right style="thin"><color auto="1"/></right>
    <top style="thin"><color auto="1"/></top>
    <bottom style="thin"><color auto="1"/></bottom>
    <diagonal/>
  </border>
</borders>
<cellXfs count="4">
  <xf numFmtId="0" fontId="0" fillId="0" borderId="0" xfId="0"/>
  <xf numFmtId="0" fontId="1" fillId="2" borderId="1" xfId="0" applyFont="1" applyFill="1" applyBorder="1" applyAlignment="1"><alignment horizontal="center" vertical="center"/></xf>
  <xf numFmtId="0" fontId="2" fillId="0" borderId="0" xfId="0" applyFont="1" applyAlignment="1"><alignment wrapText="1"/></xf>
  <xf numFmtId="0" fontId="0" fillId="0" borderId="1" xfId="0" applyBorder="1"/>
</cellXfs>
</styleSheet>');

        $zip->addFromString('xl/workbook.xml',
            '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<workbook xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships">
<sheets><sheet name="Reporte" sheetId="1" r:id="rId1"/></sheets>
</workbook>');

        $zip->addFromString('_rels/.rels',
            '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">
<Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument" Target="xl/workbook.xml"/>
</Relationships>');

        $zip->addFromString('xl/_rels/workbook.xml.rels',
            '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">
<Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/worksheet" Target="worksheets/sheet1.xml"/>
<Relationship Id="rId2" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/styles" Target="styles.xml"/>
<Relationship Id="rId3" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/sharedStrings" Target="sharedStrings.xml"/>
</Relationships>');

        $zip->addFromString('[Content_Types].xml',
            '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types">
<Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/>
<Default Extension="xml" ContentType="application/xml"/>
<Override PartName="/xl/workbook.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.sheet.main+xml"/>
<Override PartName="/xl/worksheets/sheet1.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.worksheet+xml"/>
<Override PartName="/xl/styles.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.styles+xml"/>
<Override PartName="/xl/sharedStrings.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.sharedStrings+xml"/>
</Types>');

        $zip->close();
    }
}
