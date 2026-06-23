$shell = New-Object -ComObject WScript.Shell
$dir = "C:\Users\Administrator\Desktop\游戏"
$shortcuts = Get-ChildItem -Path $dir -Filter "*.lnk"
foreach ($s in $shortcuts) {
    if ($s.Name -match "星穹") {
        $shortcut = $shell.CreateShortcut($s.FullName)
        Write-Output $shortcut.TargetPath
        Write-Output "---"
        Write-Output $shortcut.WorkingDirectory
    }
}
