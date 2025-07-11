Clear-Host
$dllPath = "C:\test\LibreHardwareMonitorLib.dll"

try {
    # Load assembly using reflection
    $assembly = [System.Reflection.Assembly]::LoadFile($dllPath)
    
    # Get the Computer type using reflection
    $computerType = $assembly.GetType("LibreHardwareMonitor.Hardware.Computer")
    
    # Create instance
    $monitor = [System.Activator]::CreateInstance($computerType)
    
    # Set properties
    $monitor.IsCPUEnabled = $true

    # Open the monitor connection
    $openMethod = $computerType.GetMethod("Open")
    $openMethod.Invoke($monitor, $null)

    # Get sensors
    $hardwareProperty = $computerType.GetProperty("Hardware")
    $hardware = $hardwareProperty.GetValue($monitor)

    foreach ($item in $hardware) {
        $sensorsProperty = $item.GetType().GetProperty("Sensors")
        $sensors = $sensorsProperty.GetValue($item)
        
        foreach ($sensor in $sensors) {
            $sensorType = $sensor.GetType()
            $sensorTypeProperty = $sensorType.GetProperty("SensorType")
            $nameProperty = $sensorType.GetProperty("Name")
            $valueProperty = $sensorType.GetProperty("Value")
            
            $currentSensorType = $sensorTypeProperty.GetValue($sensor)
            $currentName = $nameProperty.GetValue($sensor)
            $currentValue = $valueProperty.GetValue($sensor)
            
            if ($currentSensorType -eq 'Temperature' -and $currentName -eq 'CPU Package') {
                $tempF = ($currentValue * 1.8) + 32
                Write-Host "CPU Package Temperature:"
                Write-Host "  Celsius:    $currentValue°C"
                Write-Host "  Fahrenheit: $([Math]::Round($tempF, 1))°F"
            }
        }
    }
}
catch {
    Write-Error "An error occurred: $_"
}
finally {
    # Clean up if possible
    if ($monitor -and $computerType) {
        $closeMethod = $computerType.GetMethod("Close")
        $closeMethod.Invoke($monitor, $null)
    }
}