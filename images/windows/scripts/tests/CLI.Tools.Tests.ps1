
Describe "Azure CLI" -Skip:(-not (Get-Command az -ErrorAction SilentlyContinue)) {
    It "Azure CLI" {
        "az --version" | Should -ReturnZeroExitCode
    }
}

Describe "Azure DevOps CLI" -Skip:(-not (Get-Command az -ErrorAction SilentlyContinue)) {
    It "az devops" {
        "az devops -h" | Should -ReturnZeroExitCode
    }
}

Describe "Aliyun CLI" -Skip:((Test-IsWin25) -or (-not (Get-Command aliyun -ErrorAction SilentlyContinue))) {
    It "Aliyun CLI" {
        "aliyun version" | Should -ReturnZeroExitCode
    }
}


Describe "AWS" -Skip:(-not (Get-Command aws -ErrorAction SilentlyContinue)) {
    It "AWS CLI" {
        "aws --version" | Should -ReturnZeroExitCode
    }

    It "Session Manager Plugin for the AWS CLI" {
        @(session-manager-plugin) -Match '\S' | Out-String | Should -Match "plugin was installed successfully"
    }

    It "AWS SAM CLI" {
        "sam --version" | Should -ReturnZeroExitCode
    }
}


Describe "GitHub CLI" {
    It "gh" {
        "gh --version" | Should -ReturnZeroExitCode
    }
}
