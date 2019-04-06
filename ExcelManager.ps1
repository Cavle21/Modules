using module .\excelDocument.psm1;
using namespace System.Collections

class ExcelManager {
    #@(A4, B5), @(1, 1)
    Static copyRangeBetweenDocuments([excelDocument]$excelDocument1, [excelDocument]$excelDocument2, [ArrayList]$sourceRange, [System.Collections.ArrayList[int]]$destination){

        $range = "{0}:{1}" -f $sourceRange[0], $sourceRange[1];
        $sourceContent = $excelDocument1.ActiveSheet.range($range).entireColumn
    
        $sourceContent.Copy() | Out-Null

        $Celldestination = "{0},{1}" -f $destination[0], $destination[1]
    
        $destinationPaste = $excelDocument2.Activesheet.cells.item($celldestination)
    
        $excelDocument2.ActiveSheet.Paste($destinationPaste)
    }

    static CopyRowBetweenExcelDocuments([excelDocument]$excelDocument1, [excelDocument]$excelDocument2,[int]$sourceRow, [int]$destinationRow){

        $rowToCopy = $excelDocument1.ActiveSheet.cells.item($sourceRow,1).entireRow

        $rowToCopy.Copy() | Out-Null

        $destinationToPaste = $excelDocument2.ActiveSheet.cells.item($destinationRow,1)

        $excelDocument2.ActiveSheet.Paste($destinationToPaste)

    }

    static CopyColumnBetweenExcelDocuments([excelDocument]$excelDocument1, [excelDocument]$excelDocument2,[int]$sourceRow, [int]$destinationRow){

        $rowToCopy = $excelDocument1.ActiveSheet.cells.item($sourceRow,1).entireRow

        $rowToCopy.Copy() | Out-Null

        $destinationToPaste = $excelDocument2.ActiveSheet.cells.item($destinationRow,1)

        $excelDocument2.ActiveSheet.Paste($destinationToPaste)

    }

    CopyFromXMLFile(){}
}