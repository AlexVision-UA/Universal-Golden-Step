$basePath = "C:\Users\melal\Universal Golden_Step"
$configFile = Join-Path $basePath "config.json"
$config = Get-Content $configFile | ConvertFrom-Json

$todayArchive = Join-Path $basePath (Get-Date -Format "yyyy-MM-dd")
$archivePath = Join-Path $todayArchive "Archive"
if (-not (Test-Path $archivePath)) { New-Item -ItemType Directory -Path $archivePath -Force | Out-Null }

$logFile = Join-Path $basePath ("run_log_{0:yyyy-MM-dd_HH-mm}.txt" -f (Get-Date))
$summaryFile = Join-Path $basePath "summary.txt"
$csvFile = Join-Path $basePath "summary.csv"
$errors = @()
$startTime = Get-Date
$timestamp = Get-Date -Format "yyyy-MM-dd_HH-mm"

function Run-Step {
    param([string]$StepName,[scriptblock]$Action)
    Write-Output "=== $StepName ==="
    Add-Content -Path $logFile -Value "[$(Get-Date)] $StepName"
    try {
        $result = & $Action 2>&1
        $count = ($result | Measure-Object).Count
        Write-Output "${StepName}: оброблено $count елементів"
        Add-Content -Path $logFile -Value "[$(Get-Date)] ${StepName} успішно ($count)"
        foreach ($line in $result) { Add-Content -Path $logFile -Value "    $line" }
        return @{Name=$StepName; Count=$count; Status="Успішно"}
    } catch {
        $errors += "${StepName}: $_"
        Write-Output "Помилка у ${StepName}: $_"
        Add-Content -Path $logFile -Value "[$(Get-Date)] ${StepName} помилка: $_"
        return @{Name=$StepName; Count=0; Status="Помилка"}
    }
}

Write-Output "=== Запуск Universal Golden_Step ==="
Add-Content -Path $logFile -Value "=== Новий запуск: $(Get-Date) ==="

$create   = Run-Step "1. Створення структури" { .\create_structure.ps1 }
$fill     = Run-Step "2. Наповнення файлів" { .\fill_files.ps1 }
$unique   = Run-Step "3. Унікальне наповнення" { .\fill_unique.ps1 }
$check    = Run-Step "4. Перевірка структури" { .\check_structure.ps1 }

Write-Output "=== Завершено! ==="

# Таблиця
$steps = @($create,$fill,$unique,$check)
$table = "Крок                     | Елементів | Статус`n-------------------------|-----------|-----------------"
foreach ($s in $steps) { $table += "`n{0,-25} | {1,-9} | {2}" -f $s.Name,$s.Count,$s.Status }
Write-Output $table
Add-Content -Path $summaryFile -Value $table
$steps | Export-Csv -Path $csvFile -NoTypeInformation -Encoding UTF8

# Дерево
Write-Output "=== Структура проекту з підрахунком ==="
$treeOutput = & .\check_structure.ps1
foreach ($line in $treeOutput) { Write-Output $line; Add-Content -Path $summaryFile -Value $line }

# Статистика
$totalFiles = (Get-ChildItem -Path $basePath -Recurse -File | Measure-Object).Count
$totalFolders = (Get-ChildItem -Path $basePath -Recurse -Directory | Measure-Object).Count
$stats = "=== Загальна статистика ===`nФайлів: $totalFiles`nПапок: $totalFolders"
Write-Output $stats
Add-Content -Path $summaryFile -Value $stats

# Тривалість
$endTime = Get-Date
$duration = $endTime - $startTime
$timeReport = "=== Тривалість виконання: $($duration.ToString()) ==="
Write-Output $timeReport
Add-Content -Path $summaryFile -Value $timeReport

# Архівування summary у щоденну папку
Copy-Item $summaryFile (Join-Path $archivePath ("summary_{0}.txt" -f $timestamp))
Copy-Item $csvFile (Join-Path $archivePath ("summary_{0}.csv" -f $timestamp))
Copy-Item $logFile (Join-Path $archivePath ("run_log_{0}.txt" -f $timestamp))

# Побудова графіка з CSV
Add-Type -AssemblyName System.Windows.Forms.DataVisualization
$chart = New-Object System.Windows.Forms.DataVisualization.Charting.Chart
$chart.Width = 600
$chart.Height = 400
$chart.BackColor = [System.Drawing.Color]::White
$chartArea = New-Object System.Windows.Forms.DataVisualization.Charting.ChartArea
$chart.ChartAreas.Add($chartArea)
$series = New-Object System.Windows.Forms.DataVisualization.Charting.Series
$series.ChartType = [System.Windows.Forms.DataVisualization.Charting.SeriesChartType]::Bar

Import-Csv $csvFile | Where-Object { $_.Name -and $_.Count } | ForEach-Object {
    $series.Points.AddXY($_.Name, [int]$_.Count)
}
$chart.Series.Add($series)
$chartFile = Join-Path $basePath ("chart_{0}.png" -f $timestamp)
$chart.SaveImage($chartFile, "Png")

# Формування PDF‑звіту через LibreOffice
$sofficePath = "C:\Program Files\LibreOffice\program\soffice.exe"
$pdfFile = Join-Path $basePath "summary.pdf"
if (Test-Path $sofficePath) {
    & $sofficePath --headless --convert-to pdf --outdir $basePath $summaryFile
}

# Відправлення email (дані з config.json, пароль із smtp_password.xml)
try {
    $securePass = Import-Clixml "$basePath\smtp_password.xml"
    $smtpPass = [System.Net.NetworkCredential]::new("",$securePass).Password

    $mail = New-Object System.Net.Mail.MailMessage
    $mail.From = $config.smtpUser
    $mail.To.Add($config.recipient)
    $mail.Subject = "Golden_Step Звіт"
    $mail.Body = "Автоматично сформований звіт та графік Golden_Step."

    if (Test-Path $pdfFile) { $mail.Attachments.Add($pdfFile) }
    if (Test-Path $chartFile) { $mail.Attachments.Add($chartFile) }

    $smtp = New-Object Net.Mail.SmtpClient($config.smtpServer,$config.smtpPort)
    $smtp.EnableSsl = $true
    $smtp.Credentials = New-Object System.Net.NetworkCredential($config.smtpUser,$smtpPass)
    $smtp.Send($mail)
    Write-Output "Email успішно відправлено."
} catch {
    Write-Output "Помилка при відправленні email: $_"
}

# Pop-up повідомлення
Add-Type -AssemblyName PresentationFramework
if ($errors.Count -eq 0) {
    [System.Windows.MessageBox]::Show("✅ Усі кроки виконано успішно. PDF‑звіт, графік і email сформовано.","Golden_Step")
} else {
    [System.Windows.MessageBox]::Show("⚠️ Є помилки, дивись блок помилок. PDF‑звіт, графік і email сформовано.","Golden_Step")
}
