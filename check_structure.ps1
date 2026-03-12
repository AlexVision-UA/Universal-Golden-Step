# Перевірка структури проекту з підрахунком файлів у кожній папці
$basePath = "C:\Users\melal\Universal Golden_Step"

function Show-Tree {
    param(
        [string]$path,
        [string]$indent = ""
    )

    $items = Get-ChildItem -Path $path
    $folders = $items | Where-Object { $_.PSIsContainer }
    $files   = $items | Where-Object { -not $_.PSIsContainer }

    # Показати папку з кількістю файлів
    $fileCount = ($files | Measure-Object).Count
    Write-Output "$indent├── $(Split-Path $path -Leaf) ($fileCount файлів)"

    # Показати файли
    foreach ($file in $files) {
        Write-Output "$indent│   └── $($file.Name)"
    }

    # Рекурсивно показати підпапки
    foreach ($folder in $folders) {
        Show-Tree -path $folder.FullName -indent "$indent│   "
    }
}

Write-Output "Структура проекту:"
Show-Tree -path $basePath
