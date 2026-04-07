Describe "RunnerCache" {
    Context "Runner cache directory not empty" {
        It "C:\ProgramData\runner not empty" {
            (Get-ChildItem -Path "C:\ProgramData\runner\*.zip" -Recurse).Count | Should -BeGreaterThan 0
        }
    }

    Context "Runner zipball not empty" {
        $testCases = Get-ChildItem -Path "C:\ProgramData\runner\*.zip" -Recurse | ForEach-Object { @{ RunnerZipball = $_.FullName } }
        It "<RunnerZipball>" -TestCases $testCases {
            param ([string] $RunnerZipball)
            (Get-Item "$RunnerZipball").Length | Should -BeGreaterThan 0
        }
    }
}
