#NoEnv
#SingleInstance Force

; 激活米哈游启动器窗口
WinActivate, 米哈游启动器
WinWaitActive, 米哈游启动器,, 5

if ErrorLevel
{
    MsgBox, 找不到米哈游启动器窗口
    ExitApp
}

; 等待窗口完全激活
Sleep, 1000

; 获取窗口位置和大小
WinGetPos, winX, winY, winW, winH, 米哈游启动器

; "开始游戏"按钮通常在窗口底部中间位置
; 大约在窗口宽度的50%，高度的85%位置
btnX := winX + (winW * 0.5)
btnY := winY + (winH * 0.85)

; 点击按钮
Click, %btnX%, %btnY%

Sleep, 500
ExitApp
