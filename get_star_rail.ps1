$shell = New-Object -ComObject WScript.Shell
$shortcut = $shell.CreateShortcut("C:\Users\Administrator\Desktop\游戏\崩坏：星穹铁道.lnk")
Write-Output $shortcut.TargetPath
Write-Output "---"
Write-Output $shortcut.WorkingDirectory
