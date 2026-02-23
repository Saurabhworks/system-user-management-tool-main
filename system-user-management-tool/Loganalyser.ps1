# File paths
$logFilePath = "E:\System-user-management\system-user-management-tool\users.csv"
$reportPath = "E:\System-user-management\system-user-management-tool\log-report.csv"

# Function to analyze logs
function AnalyzeLogs {
    param (
        [string]$logFilePath,
        [string]$dateFilter = "",
        [string]$timeFilter = ""
    )

    # Read and optionally filter log lines
    $logEntries = Get-Content -Path $logFilePath | Where-Object {
        ($dateFilter -eq "" -or $_ -match $dateFilter) -and
        ($timeFilter -eq "" -or $_ -match $timeFilter)
    }

    $logSummary = @()

    foreach ($log in $logEntries) {
        # Match format: YYYY-MM-DD HH:MM:SS - Message
        if ($log -match '^(?<date>\d{4}-\d{2}-\d{2}) (?<time>\d{2}:\d{2}:\d{2}) - (?<message>.*)$') {
            $logSummary += [PSCustomObject]@{
                Date    = $matches['date']
                Time    = $matches['time']
                Message = $matches['message']
            }
        }
    }

    return $logSummary
}

# Filters (can be customized)
$dateFilter = ""   # Example: "2025-10-16"
$timeFilter = ""   # Example: "14:3"

# Run analysis
$analysisResult = AnalyzeLogs -logFilePath $logFilePath -dateFilter $dateFilter -timeFilter $timeFilter

# Export results to CSV
if ($analysisResult.Count -gt 0) {
    $analysisResult | Export-Csv -Path $reportPath -NoTypeInformation -Force
    Write-Host "Log report generated at: $reportPath"
}
else {
    Write-Host "No matching log entries found for given filters."
}
