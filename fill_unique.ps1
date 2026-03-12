# ”н≥кальне наповненн€ файл≥в
$basePath = "C:\Users\melal\Universal Golden_Step"

$uniqueDrafts = @{
    "Architecture.docx" = "Architecture draft"
    "Functions.md" = "Functions draft"
    "Reports.docx" = "Reports draft"
    "Transparency.md" = "Transparency draft"
    "Concept.docx" = "Concept draft"
    "Statute.docx" = "Statute draft"
    "NDA.docx" = "NDA draft"
    "Partnership_Agreement.docx" = "Partnership Agreement draft"
    "Overview.md" = "Overview draft"
    "Full_Presentation.pptx" = "Presentation draft"
    "Pitch.docx" = "Pitch draft"
    "Content.txt" = "Website content draft"
}

$files = Get-ChildItem -Path $basePath -Recurse -File

foreach ($file in $files) {
    if ($uniqueDrafts.ContainsKey($file.Name)) {
        Add-Content -Path $file.FullName -Value $uniqueDrafts[$file.Name]
        Write-Output "Filled file: $($file.FullName) with $($uniqueDrafts[$file.Name])"
    }
}