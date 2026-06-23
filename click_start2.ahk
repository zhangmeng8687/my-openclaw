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

Sleep, 1000

; 获取窗口位置和大小
WinGetPos, winX, winY, winW, winH, 米哈游启动器

; 尝试多个可能的按钮位置
; 位置1: 底部中间偏下 (85%)
btnX1 := winX + (winW * 0.5)
btnY1 := winY + (winH * 0.85)
Click, %btnX1%, %btnY1%
Sleep, 500

; 位置2: 底部中间 (80%)
btnX2 := winX + (winW * 0.5)
btnY2 := winY + (winH * 0.80)
Click, %btnX2%, %btnY2%
Sleep, 500

; 位置3: 底部中间偏上 (75%)
btnX3 := winX + (winW * 0.5)
btnY3 := winY + (winH * 0.75)
Click, %btnX3%, %btnY3%
Sleep, 500

ExitApp
