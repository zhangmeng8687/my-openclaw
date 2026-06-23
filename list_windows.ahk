#NoEnv
#SingleInstance Force

file := "C:\Users\Administrator\.openclaw\workspace\windows_list.txt"
FileDelete, %file%

WinGet, id, List
Loop, %id%
{
    this_id := id%A%
    WinGetTitle, this_title, ahk_id %this_id%
    if (this_title != "")
        FileAppend, %this_title%`n, %file%
}
ExitApp
