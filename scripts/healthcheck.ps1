$config = Get-Content "../config/config.json" | ConvertFrom-Json

# CPU
$cpu = (Get-Counter '\Processor(_Total)\% Processor Time').CounterSamples.CookedValue

# Memory
$memory = Get-Counter '\Memory\% Committed Bytes In Use'
$memUsage = $memory.CounterSamples.CookedValue

# Disk
$disk = Get-WmiObject Win32_LogicalDisk -Filter "DeviceID='C:'"
$diskUsage = ((($disk.Size - $disk.FreeSpace) / $disk.Size) * 100)

# Services
$servicesStatus = @()
foreach ($svc in $config.services) {
    $status = Get-Service -Name $svc -ErrorAction SilentlyContinue
    $servicesStatus += @{
        Name = $svc
        Status = if ($status) { $status.Status } else { "Not Found" }
    }
}

# Create report
$report = @{
    CPU = [math]::Round($cpu,2)
    Memory = [math]::Round($memUsage,2)
    Disk = [math]::Round($diskUsage,2)
    Services = $servicesStatus
}

$report | ConvertTo-Json | Out-File "../output/report.json"

Write-Host "Health check completed"

# Fail condition (for CI/CD)
if ($cpu -gt $config.cpuThreshold -or 
    $memUsage -gt $config.memoryThreshold -or 
    $diskUsage -gt $config.diskThreshold) {
    
    Write-Error "Threshold exceeded!"
    exit 1
}