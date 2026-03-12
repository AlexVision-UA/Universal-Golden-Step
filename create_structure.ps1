# Створення базової структури проекту
$basePath = "C:\Users\melal\Universal Golden_Step"

$folders = @(
    "$basePath\Core",
    "$basePath\Docs",
    "$basePath\Legal\Agreements",
    "$basePath\Modules\Analytics",
    "$basePath\Modules\Business",
    "$basePath\Modules\Charity",
    "$basePath\Modules\Education",
    "$basePath\Modules\Social",
    "$basePath\Presentation",
    "$basePath\Website"
)

$files = @(
    "$basePath\Core\Architecture.docx",
    "$basePath\Core\Functions.md",
    "$basePath\Docs\Reports.docx",
    "$basePath\Docs\Transparency.md",
    "$basePath\Legal\Concept.docx",
    "$basePath\Legal\Statute.docx",
    "$basePath\Legal\Agreements\NDA.docx",
    "$basePath\Legal\Agreements\Partnership_Agreement.docx",
    "$basePath\Modules\Analytics\Overview.md",
    "$basePath\Modules\Business\Overview.md",
    "$basePath\Modules\Charity\Overview.md",
    "$basePath\Modules\Education\Overview.md",
    "$basePath\Modules\Social\Overview.md",
    "$basePath\Presentation\Full_Presentation.pptx",
    "$basePath\Presentation\Pitch.docx",
    "$basePath\Website\Content.txt"
)

foreach ($folder in $folders) {
    if (-not (Test-Path $folder)) {
        New-Item -ItemType Directory -Path $folder | Out-Null
        Write-Output "Створено папку: $folder"
    } else {
        Write-Output "Папка вже існує: $folder"
    }
}

foreach ($file in $files) {
    if (-not (Test-Path $file)) {
        New-Item -ItemType File -Path $file | Out-Null
        Write-Output "Створено файл: $(Split-Path $file -Leaf)"
    } else {
        Write-Output "Файл вже існує: $(Split-Path $file -Leaf)"
    }
}