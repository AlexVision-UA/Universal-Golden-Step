# Перевірка файлів і папок з підрахунком
$basePath = "C:\Users\melal\Universal Golden_Step"

function Show-Files {
    param(
        [string]$path
    )

    $items = Get-ChildItem -Path $path
    $folders = $items | Where-Object { $_.PSIsContainer }
    $files   = $items | Where-Object { -not $_.PSIsContainer }

    # Показати папку з кількістю файлів
    $fileCount = ($files | Measure-Object).Count
    Write-Output "Папка: $path ($fileCount файлів)"

    # Показати файли
    foreach ($file in $files) {
        Write-Output "   Файл: $($file.FullName)"
    }

    # Рекурсивно показати підпапки
    foreach ($folder in $folders) {
        Show-Files -path $folder.FullName
    }
}

Write-Output "=== Перевірка файлів і папок ==="
Show-Files -path $basePath

# Підсумок
$totalFiles = (Get-ChildItem -Path $basePath -Recurse -File | Measure-Object).Count
$totalFolders = (Get-ChildItem -Path $basePath -Recurse -Directory | Measure-Object).Count

Write-Output "=== Підсумок ==="
Write-Output "Загалом файлів: $totalFiles"
Write-Output "Загалом папок: $totalFolders"