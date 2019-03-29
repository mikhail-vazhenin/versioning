param([String]$special='')

Import-Module $PSScriptRoot\semver.psm1

Invoke-Semver -Special $special