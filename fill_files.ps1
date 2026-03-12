# Наповнення файлів базовим контентом
$basePath = "C:\Users\melal\Universal Golden_Step"

$files = Get-ChildItem -Path $basePath -Recurse -File

foreach ($file in $files) {
    $content = Get-Content $file.FullName -ErrorAction SilentlyContinue
    if ([string]::IsNullOrWhiteSpace($content)) {
        Set-Content -Path $file.FullName -Value "Базовий контент для $($file.Name)"
        Write-Output "Filled file: $($file.FullName)"
    } else {
        Write-Output "Already has content: $($file.FullName)"
    }
}