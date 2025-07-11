cls
$dll = "C:\test\LibreHardwareMonitorLib.dll"

Unblock-File -LiteralPath $dll
Add-Type -LiteralPath $dll
$monitor = [LibreHardwareMonitor.Hardware.Computer]::new()
$monitor.IsCPUEnabled = $true

$monitor.Open()
foreach ($sensor in $monitor.Hardware.Sensors) {
    if($sensor.SensorType -eq 'Temperature' -and $sensor.Name -eq 'CPU Package'){
        write-host $sensor.Name
        $temp = ($sensor.Value * 1.8) + 32
        write-host $temp
    }

}
$monitor.Close()