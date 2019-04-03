class ExcelDocument {

    #excel is the manager
    #workbook is the actual page
    #sheet is a page inside workbook
    
    $excel
    $workBook
    $workSheet
    [string]$path
    [string]$currentSheet
    [boolean]$visibility
    [boolean]$displayAlerts
    [System.Collections.Hashtable]$hashHeaders

    #open existing document
    ExcelDocument ([string]$path, $visibility, $displayAlerts) {
        $this.excel = New-Object -ComObject Excel.Application
        try {
            $this.workBook = $this.excel.Workbooks.Open($path)
        }catch{
            Write-host "Unable to open excelsheet"
            Write-host $error[0].exception.Message
            exit
        }   

        $this.excel.application.Visible = $visibility
        $this.excel.displayalerts = $displayAlerts
        $this.visibility = $visibility
        $this.displayAlerts = $displayAlerts
        
        $this.path = $path
    }
    #create new document
    ExcelDocument ([string]$nameOfDocument, $visibility, $displayAlerts){
        $this.excel = New-Object -ComObject excel.application
        $this.excel.application.Visible = $visibility
        $this.excel.displayalerts = $displayAlerts
        $this.visibility = $visibility
        $this.displayAlerts = $displayAlerts

        $this.book = $this.excel.Workbooks.Add()

        $this.sheet = $this.book.Worksheets.Item(1)
        $this.Sheet.Name = $nameOfDocument

        $this.sheet.Activate() 
    }

    [void]SaveDocument (){}

    [void]CloseDocument (){
        $this.excel.quit()
        $this.workbook.close()
        [System.Runtime.Interopservices.Marshal]::ReleaseComObject($this.Excel)
        [System.Runtime.Interopservices.Marshal]::ReleaseComObject($this.workbook)
        [System.Runtime.Interopservices.Marshal]::ReleaseComObject($this.workSheet)
    }

    [System.Collections.Hashtable]GetColumnHeaders ([uint32]$startingCol, [uint32]$row){

        $col = $startingCol

        $Headers = new-object System.Collections.Hashtable

        Do  { 
            $columnHeader = $this.Worksheet.Cells.Item($row, $startingCol).Value() #.trim()  
            #if there are spaces in the name it will remove them.
            $Headers.add(($columnHeader -replace " ", ""),$col)
            $col++ 
        } While ($null -ne $this.Worksheet.Cells.Item($row,$col).Value())

        $this.ColunmHeaders = $Headers

        return $Headers
    }



    [System.Collections.Hashtable]GetValuesInRow([uint32]$startingCol, [uint32]$row){

        $col = $startingCol

        $hashRowValues = new-object System.Collections.Hashtable

        Do  { 
            $cellValue = $this.Worksheet.Cells.Item($row, $startingCol).Value() #.trim()  
            #if there are spaces in the name it will remove them.
            $hashRowValues.add(($cellValue),$col)
            $col++ 
        } While ($null -ne $this.Worksheet.Cells.Item($row,$col).Value())

        return $hashRowValues

    }

    #iterates through search criteria to find values of one row. Needs work, too hardcoded.
    [PSCustomObject]FindCriteria ([uint32]$startingCol, [uint32]$row, [System.Collections.ArrayList]$arrSearchCriteria){
        $result = [PSCustomObject]@{}
        $numberOfResults = 1
        $foundArr = new-object System.Collections.ArrayList

        #find all rows that match the first set of numbers
        $found = $this.worksheet.Cells.Find($arrSearchCriteria[0])
        $firstRow = $found.row
        $loop = $true
        #loop through all results $found and store them in an array
        while($loop -eq $true){
            $foundarr.Add($found)
            $found = $this.worksheet.Cells.FindNext($found)
            $currentRow = $found.row
            #Write-host "$currentrow and $firstRow"
            if ($currentRow -eq $firstRow){
                $loop = $false
            }else{
                $numberOfResults++
            }
        }

        Write-host "There are $numberOfResults rows with that value."

        #check rows found against second element in array ( hopefully this eliminates all others but one)

        forEach ($item in $foundarr){
            #Write-host $item.row
            if (($this.workSheet.cells.item($item.row,10).text) -eq $arrSearchCriteria[1]){
                $found = $item
            }
        }

        $col = 1

        $ArrHeaders = new-object System.Collections.ArrayList
        #get all column headers
        $col = 1
        #add data to result object using column headers as variable name
        forEach ($objHeader in $ArrHeaders){  
            If ($null -ne $this.Worksheet.Cells.Item($found.Row, $col).Value()){  
                $result | Add-Member -type NoteProperty -name $objHeader -value $this.worksheet.Cells.Item($found.Row, $Col).Value() #.trim()  
            }else{ 
                $result | Add-Member -type NoteProperty -name $objHeader -value $null  
            }

            $Col++ 
        }

        return $result
    }

    NewSheet(){}

    SelectSheet(){}

    SetValuesInCell ([uint32]$col, [uint32]$row, [string]$value){
        $this.sheet.cells.Item($row,$col) = $value
        $this.sheet.cells.Item($row,$col).entireRow.Delete()
    }

    [string]GetValuesInCell([uint32]$row, [uint32]$col){
        $retVal = $this.worksheet.Cells.Item($Row, $Col).Value()

        return $retVal
    }

    ChangeFormatofCell(){}

    DeleteCellValue(){}

    [system.Collections.ArrayList]SelectDataRange ($initialRow, $row, $letterToStart, $letterToStop) {
        [System.Collections.ArrayList]$dataRange = $this.sheet.Range(("$letterToStart{0}" -f $initialRow, ("$LetterToStop{0}" -f $row)))

        return $dataRange
    }

    [void]DeleteEntireRow([int]$row){
        
        $this.sheet.cells.item($row, 1).entireRow.Delete()

    }

    [void]DeleteEntireColumn([int]$column){

        $this.sheet.cells.item(1,$column).entireColumn.Delete()
    }

    [Void]sortWorkSheet(){
        $currenSheet = $this.excel.ActiveSheet

        
    }

    
}