param(
    [int]$Port = 8000
)

$ErrorActionPreference = 'Stop'
$Dir = Split-Path -Parent $MyInvocation.MyCommand.Path

Write-Host "=== Compiling GWT ==="
Push-Location $Dir
try {
    if (Test-Path "$Dir\gradlew.bat") {
        & "$Dir\gradlew.bat" compileGwt --console verbose
    } elseif (Get-Command gradle -ErrorAction SilentlyContinue) {
        & gradle compileGwt --console verbose
    } else {
        throw "Gradle not found. Install Gradle 8.7+ or use gradlew.bat."
    }

    $linkPath = Join-Path $Dir "war\circuitjs1"
    $targetPath = Join-Path $Dir "build\gwt\out\circuitjs1"

    Write-Host "=== Linking war/circuitjs1 -> build/gwt/out/circuitjs1 ==="
    if (Test-Path $linkPath) {
        Remove-Item $linkPath -Force -Recurse
    }
    New-Item -ItemType Junction -Path $linkPath -Target $targetPath | Out-Null

    $url = "http://localhost:$Port/circuitjs.html"
    Write-Host "=== Starting server on $url ==="
    Start-Process $url | Out-Null

    Push-Location (Join-Path $Dir "war")
    try {
        python -m http.server $Port
    } finally {
        Pop-Location
    }
} finally {
    Pop-Location
}
