# Clear the screen
Clear-Host

# Define paths and settings
$dllPath = "C:\test\LibreHardwareMonitorLib.dll"

try {
    # Unblock the DLL file if it's blocked
    if (Test-Path -LiteralPath $dllPath) {
        Unblock-File -LiteralPath $dllPath -ErrorAction SilentlyContinue
    } else {
        throw "DLL file not found at $dllPath"
    }

    # Load the LibreHardwareMonitor library
    Add-Type -LiteralPath $dllPath -ErrorAction Stop

    # Create and configure the hardware monitor
    $monitor = [LibreHardwareMonitor.Hardware.Computer]::new()
    $monitor.IsCPUEnabled = $true

    # Open the monitor connection
    $monitor.Open()

    # Find and process CPU temperature sensor
    $cpuTempSensor = $monitor.Hardware.Sensors | Where-Object {
        $_.SensorType -eq 'Temperature' -and $_.Name -eq 'CPU Package'
    }

    if ($cpuTempSensor) {
        # Convert Celsius to Fahrenheit
        $tempFahrenheit = ($cpuTempSensor.Value * 1.8) + 32
        
        # Create a formatted output
        $output = @"
CPU Temperature:
- Sensor: $($cpuTempSensor.Name)
- Celsius: $($cpuTempSensor.Value.ToString("N1"))°C
- Fahrenheit: $($tempFahrenheit.ToString("N1"))°F
"@
        
        Write-Host $output
    } else {
        Write-Warning "CPU Package temperature sensor not found"
    }
}
catch {
    Write-Error "An error occurred: $_"
}
finally {
    # Ensure the monitor is properly closed even if an error occurs
    if ($monitor) {
        $monitor.Close()
    }
}