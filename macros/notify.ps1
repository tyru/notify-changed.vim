[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")

$objNotifyIcon = New-Object System.Windows.Forms.NotifyIcon

$objNotifyIcon.Icon = [System.Drawing.SystemIcons]::Information
$objNotifyIcon.BalloonTipIcon = "Info"
$objNotifyIcon.BalloonTipTitle = $args[0]
$objNotifyIcon.BalloonTipText = $args[1]
$objNotifyIcon.Visible = $True

$objNotifyIcon.ShowBalloonTip(10000)
