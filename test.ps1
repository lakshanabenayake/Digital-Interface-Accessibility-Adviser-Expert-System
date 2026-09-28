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

& $prolog -q -s tests.pl -g run_tests -t halt
exit $LASTEXITCODE
