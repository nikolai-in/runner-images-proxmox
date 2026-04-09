$chocoPackageNames = (Get-ToolsetContent).choco.common_packages | ForEach-Object { $_.name.ToLower() }

Describe "7-Zip" {
    It "7z" {
        "7z" | Should -ReturnZeroExitCode
    }
}

Describe "Aria2" {
    It "Aria2" {
        "aria2c --version" | Should -ReturnZeroExitCode
    }
}

Describe "AzCopy" -Skip:('azcopy10' -notin $chocoPackageNames) {
    It "AzCopy" {
        "azcopy --version" | Should -ReturnZeroExitCode
    }
}

Describe "Bicep" -Skip:('bicep' -notin $chocoPackageNames) {
    It "Bicep" {
        "bicep --version" | Should -ReturnZeroExitCode
    }
}

Describe "InnoSetup" {
    It "InnoSetup" {
        (Get-Command -Name iscc).CommandType | Should -BeExactly "Application"
    }
}

Describe "Jq" {
    It "Jq" {
        "jq -n ." | Should -ReturnZeroExitCode
    }
}

Describe "Nuget" {
    It "Nuget" {
       "nuget" | Should -ReturnZeroExitCode
    }
}

Describe "Packer" {
    It "Packer" {
       "packer --version" | Should -ReturnZeroExitCode
    }
}

Describe "Perl" -Skip:('strawberryperl' -notin $chocoPackageNames) {
    It "Perl" {
       "perl --version" | Should -ReturnZeroExitCode
    }
}

Describe "Pulumi" -Skip:('pulumi' -notin $chocoPackageNames) {
    It "pulumi" {
       "pulumi version" | Should -ReturnZeroExitCode
    }
}

Describe "Svn" -Skip:((Test-IsWin25) -or (-not (Get-Command svn -ErrorAction SilentlyContinue))) {
    It "svn" {
        "svn --version --quiet" | Should -ReturnZeroExitCode
    }
}

Describe "Swig" {
    It "Swig" {
        "swig -version" | Should -ReturnZeroExitCode
    }
}

Describe "VSWhere" {
    It "vswhere" {
        "vswhere" | Should -ReturnZeroExitCode
    }
}

Describe "Julia" -Skip:('julia' -notin $chocoPackageNames) {
    It "Julia path exists" {
        "C:\Julia" | Should -Exist
    }

    It "Julia" {
        "julia --version" | Should -ReturnZeroExitCode
    }
}

Describe "CMake" {
    It "cmake" {
        "cmake --version" | Should -ReturnZeroExitCode
    }
}

Describe "ImageMagick" -Skip:('imagemagick' -notin $chocoPackageNames) {
    It "ImageMagick" {
        "magick -version" | Should -ReturnZeroExitCode
    }
}

Describe "Ninja" {
    BeforeAll {
        $ninjaProjectPath = $(Join-Path $env:TEMP_DIR "ninjaproject")
        New-item -Path $ninjaProjectPath -ItemType Directory -Force
@'
cmake_minimum_required(VERSION 3.10)
project(NinjaTest NONE)
'@ | Out-File -FilePath "$ninjaProjectPath/CMakeLists.txt" -Encoding utf8

        $ninjaProjectBuildPath = $(Join-Path $ninjaProjectPath "build")
        New-item -Path $ninjaProjectBuildPath -ItemType Directory -Force
        Set-Location $ninjaProjectBuildPath
    }

    It "Make a simple ninja project" {
    "cmake -GNinja $ninjaProjectPath" | Should -ReturnZeroExitCode
    }

    It "build.ninja file should exist" {
        $buildFilePath = $(Join-Path $ninjaProjectBuildPath "build.ninja")
        $buildFilePath | Should -Exist
    }

    It "Ninja" {
        "ninja --version" | Should -ReturnZeroExitCode
    }
}
