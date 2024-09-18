Add-Type -AssemblyName System.Windows.Forms

$form = New-Object System.Windows.Forms.Form
$form.Text = "Process Timer"
$form.Size = New-Object System.Drawing.Size(300,350)
$form.StartPosition = "CenterScreen"

$processLabel = New-Object System.Windows.Forms.Label
$processLabel.Text = "Select Process:"
$processLabel.Location = New-Object System.Drawing.Point(10,10)
$form.Controls.Add($processLabel)

$processComboBox = New-Object System.Windows.Forms.ComboBox
$processComboBox.Location = New-Object System.Drawing.Point(10,30)
$processComboBox.Size = New-Object System.Drawing.Size(260,20)
$processComboBox.DropDownStyle = [System.Windows.Forms.ComboBoxStyle]::DropDownList
$form.Controls.Add($processComboBox)

$timeLabel = New-Object System.Windows.Forms.Label
$timeLabel.Text = "Enter Time (HH:mm):"
$timeLabel.Location = New-Object System.Drawing.Point(10,60)
$form.Controls.Add($timeLabel)

$timeTextBox = New-Object System.Windows.Forms.TextBox
$timeTextBox.Location = New-Object System.Drawing.Point(10,80)
$timeTextBox.Size = New-Object System.Drawing.Size(260,20)
$form.Controls.Add($timeTextBox)

$ignoreChildCheckBox = New-Object System.Windows.Forms.CheckBox
$ignoreChildCheckBox.Text = "Show only parent processes"
$ignoreChildCheckBox.Location = New-Object System.Drawing.Point(10,110)
$form.Controls.Add($ignoreChildCheckBox)

$startButton = New-Object System.Windows.Forms.Button
$startButton.Text = "Start"
$startButton.Location = New-Object System.Drawing.Point(10,150)
$form.Controls.Add($startButton)

$stopButton = New-Object System.Windows.Forms.Button
$stopButton.Text = "Stop"
$stopButton.Location = New-Object System.Drawing.Point(100,150)
$stopButton.Enabled = $false
$form.Controls.Add($stopButton)

$timerRunning = $false
$selectedProcess = $null
$scheduledTime = $null

function Refresh-ProcessList {
    $processComboBox.Items.Clear()
    if ($ignoreChildCheckBox.Checked) {
        $processes = Get-Process | Where-Object { $_.MainWindowHandle -ne 0 } | Select-Object -ExpandProperty ProcessName | Sort-Object
    } else {
        $processes = Get-Process | Select-Object -ExpandProperty ProcessName | Sort-Object
    }
    $processComboBox.Items.AddRange($processes)
}

Refresh-ProcessList

$ignoreChildCheckBox.Add_CheckedChanged({
    Refresh-ProcessList
})

$startButton.Add_Click({
    $selectedProcess = $processComboBox.SelectedItem
    $scheduledTime = $timeTextBox.Text
    
    if (-not $selectedProcess) {
        [System.Windows.Forms.MessageBox]::Show("Please select a process.")
        return
    }
    
    if (-not $scheduledTime -or -not $scheduledTime -match "^\d{2}:\d{2}$") {
        [System.Windows.Forms.MessageBox]::Show("Please enter a valid time in HH:mm format.")
        return
    }
    
    $stopButton.Enabled = $true
    $startButton.Enabled = $false
    $timerRunning = $true

    while ($timerRunning) {
        $currentTime = (Get-Date).ToString("HH:mm")
        
        if ($currentTime -eq $scheduledTime) {
            $proc = Get-Process -Name $selectedProcess -ErrorAction SilentlyContinue
            if ($proc) {
                $proc | Stop-Process
                [System.Windows.Forms.MessageBox]::Show("Process $selectedProcess closed.")
            } else {
                [System.Windows.Forms.MessageBox]::Show("Process $selectedProcess not found.")
            }
            $timerRunning = $false
        }
        Start-Sleep -Seconds 30
    }
    
    $startButton.Enabled = $true
    $stopButton.Enabled = $false
})

$stopButton.Add_Click({
    $timerRunning = $false
    [System.Windows.Forms.MessageBox]::Show("Timer stopped.")
    $startButton.Enabled = $true
    $stopButton.Enabled = $false
})

$form.Topmost = $true
$form.Add_Shown({$form.Activate()})
[void]$form.ShowDialog()
