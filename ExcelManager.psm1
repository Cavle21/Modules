using module .\excelDocument.psm1;
using namespace System.Collections

class ExcelManager {
    #@(A4, B5), A1
    copyExcelBetweenDocuments([excelDocument]$excelDocument1, [excelDocument]$excelDocument2, [ArrayList]$sourceRange, [string]$destination){

        $range = "{0}:{1}" -f $sourceRange[0], $sourceRange[1];
        $sourceContent = $excelDocument1.ActiveSheet.range($range).entireColumn
    
        $sourceContent.Copy() | Out-Null
    
        $destinationPaste = $excelDocument2.Activesheets.cells.item($destination)
    
        $excelDocument2.ActiveSheets.Paste($destinationPaste)
    }
}