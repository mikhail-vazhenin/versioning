$semver_file_name = "$PSScriptRoot\..\..\.semver"
$default_version = "1.0.0"

function Invoke-Semver {
    param(
        [Parameter(Position=0,Mandatory=0,HelpMessage="Options are major, minor, patch")]
        [ValidateSet("major", "minor", "patch")]
        [string]
        $Increment,
        [Parameter(Position=1,Mandatory=0,HelpMessage="Set a special version suffix")]
        [string]
        $Special,
        [Parameter(Position=2,Mandatory=0,HelpMessage="Options are %M, %m, %p, %s")]
        [string]
        $Format)

    New-IfSemverNotExist

    $semver = Get-SemverContent

    if (-Not [string]::IsNullOrEmpty($Increment))
    {
        $semver = Set-NumericVersion $Increment $semver
    }

    Get-Format $semver $Special
}

function New-IfSemverNotExist {
    if (!(Test-Path $semver_file_name)) {
        New-SemverFile
    }
}

function New-SemverFile {
    $semver = [version]$default_version
    [void](Save-NewVersion $semver)
}

function Get-SemverContent {
    $content = (Get-Content $semver_file_name | Select-Object -First 1)
    if ([string]::IsNullOrEmpty($content))
    {
        $content = $default_version
    }
    $semver = [version]($content)
    $semver
}

function Set-NumericVersion($increment, $semver) {
    
    $incremented_version = Get-IncrementedVersion $increment $semver
    [void](Save-NewVersion $incremented_version)
    $incremented_version
}

function Get-IncrementedVersion($increment, $semver) {
    $incremented_version = $semver

    if ($increment -eq "major") {
        $incremented_version = [version]::new($semver.Major + 1, 0, 0)
    }
    elseif ($increment -eq "minor") {
        $incremented_version = [version]::new($semver.Major, $semver.Minor + 1, 0)
    }
    elseif ($increment -eq "patch") {
        $incremented_version = [version]::new($semver.Major, $semver.Minor, $semver.Build + 1)
    }
    $incremented_version
}

function Get-Format($semver, $special) {
    #$version = "{0}.{1}.{2}" -f $semver.Major, $semver.Minor, $semver.Build
    $version = $semver.ToString(3)
    if (-Not [string]::IsNullOrEmpty($special))
    {    
        $version = "{0}-{1}" -f $version, $special
    }
    $version
}

function Save-NewVersion($semver) {
    $formatted = Get-Format $semver
    $formatted | Out-File -filepath $semver_file_name
}
