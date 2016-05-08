param(
    [string] $VSVers = "12.0"
)

$vsPotential = @(
    "${env:ProgramFiles(x86)}\Microsoft Visual Studio $VSVers", 
    "${env:ProgramFiles}\Microsoft Visual Studio $VSVers"
)
foreach ($p in $vsPotential) {
    if (test-path $p) { 
        $vsPath = $p 
        break
    }
}
if (!$vsPath) {
    throw "Could not find Visual Studio version $VSVers"
}

$vsdevcmd = "$vsPath\Common7\Tools\vsdevcmd.bat"

$vsdevcmdOutput = cmd /c "`"$vsdevcmd`" & powershell.exe -NoProfile -File .\extract-vsvars-helper.ps1"
$controlOutput = cmd /c 'powershell.exe -NoProfile -File .\extract-vsvars-helper.ps1'

$vsdevcmdVars = @{}
$controlVarNames = @()

$controlOutput |% {
    $idx = $_.indexof("=")
    $Name = $_.SubString(0,$idx)
    $controlVars += @($Name)
}

$vsdevcmdOutput |% {
    $idx = $_.indexof("=")
    $Name = $_.SubString(0,$idx)
    $Value = $_.Substring($idx+1)

    if ($controlVars -notcontains $Name) {
        # If the last char of $Value is a backslash (pretty common for paths), 
        # it will treat it as escaping the newline - NOT what we want for an
        # included makefile. 
        $vsdevcmdVars[$Name] = "$Value "
    }
}

$vsdevcmdVars.Keys |% {
    write-output "$_=$($vsdevcmdVars[$_])"
}

#return $vsdevcmdvars