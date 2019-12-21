﻿[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments','',Justification='False Positives')]
Param()

Import-Module $PSScriptRoot\..\..\ImportExcel.psd1 -Force

Describe "Tests" {
    BeforeAll {
        $data = $null
        $timer = Measure-Command {
            $data = Import-Excel $PSScriptRoot\Simple.xlsx
        }
    }
    It "Should have a valid manifest".PadRight(90){
        {try {Test-ModuleManifest -Path $PSScriptRoot\..\..\ImportExcel.psd1 -ErrorAction stop}
         catch {throw}  } | should not throw
    }
    It "Should have two items in the imported simple data".PadRight(90) {
        $data.count | Should be 2
    }

    It "Should have items a and b in the imported simple data".PadRight(90) {
        $data[0].p1 | Should be "a"
        $data[1].p1 | Should be "b"
    }

    It "Should read the simple xlsx in < 2100 milliseconds".PadRight(90) {
        $timer.TotalMilliseconds | should BeLessThan 2100
    }

    It "Should read larger xlsx, 4k rows 1 col < 3000 milliseconds".PadRight(90) {
        $timer = Measure-Command {
            $null = Import-Excel $PSScriptRoot\LargerFile.xlsx
        }

        $timer.TotalMilliseconds | should BeLessThan 3000
    }

    It "Should be able to open, read and close as seperate actions".PadRight(90) {
        $timer = Measure-Command {
            $excel = Open-ExcelPackage $PSScriptRoot\Simple.xlsx
            $data = Import-Excel -ExcelPackage $excel
            Close-ExcelPackage -ExcelPackage $excel -NoSave}
            $timer.TotalMilliseconds | should BeLessThan 2100
            $data.count | Should be 2
            $data[0].p1 | Should be "a"
            $data[1].p1 | Should be "b"
    }

    It "Should take Paths from parameter".PadRight(90) {
        $data = Import-Excel -Path (Get-ChildItem -Path $PSScriptRoot -Filter "TestData?.xlsx").FullName
        $data.count | Should be 4
        $data[0].cola | Should be 1
        $data[2].cola | Should be 5
    }

    It "Should take Paths from pipeline".PadRight(90) {
        $data = (Get-ChildItem -Path $PSScriptRoot -Filter "TestData?.xlsx").FullName | Import-Excel
        $data.count | Should be 4
        $data[0].cola | Should be 1
        $data[2].cola | Should be 5
    }

    It "Should support PipelineVariable".PadRight(90) {
        $data = Import-Excel $PSScriptRoot\Simple.xlsx -PipelineVariable 'Pv' | ForEach-Object { $Pv.p1 }
        $data.count | Should be 2
        $data[0] | Should be "a"
        $data[1] | Should be "b"
    }
}