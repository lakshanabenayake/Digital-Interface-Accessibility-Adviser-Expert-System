param(
    [ValidateRange(1, 65535)]
    [int]$Port = 8080
)

$projectRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location -LiteralPath $projectRoot

$bundled = Join-Path $projectRoot 'runtime\swipl\bin\swipl.exe'
if (Test-Path -LiteralPath $bundled) {
    $prolog = $bundled
} else {
    $command = Get-Command swipl -ErrorAction SilentlyContinue
    if (-not $command) {
        throw 'SWI-Prolog is missing. Install it from https://www.swi-prolog.org/Download.html'
    }
    $prolog = $command.Source
}

& $prolog -q -s web_server.pl -- $Port
exit $LASTEXITCODE
