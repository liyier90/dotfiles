#Requires AutoHotkey v2
#SingleInstance Force

; This scripts toggles between states raised and hidden of a Windows Terminal,
; or opens a new one if not opened, using  `Alt + Enter`


!Enter::ToggleTerminal()

ToggleTerminal()
{
    WinMatcher := "ahk_class CASCADIA_HOSTING_WINDOW_CLASS"
    DetectHiddenWindows true
    if WinExist(WinMatcher) {
        if !WinActive(WinMatcher) {
            ; Hide it first to alow raising it later on a different workspace
            HideTerminal()
            ShowTerminal()
        }
		else if WinExist(WinMatcher) {
            HideTerminal()
        }
    }
	else {
        OpenNewTerminal()
    }
}

OpenNewTerminal()
{	
	LocalAppData := EnvGet(LOCALAPPDATA)
    Run LocalAppData "\Microsoft\WindowsApps\wt.exe"
    Sleep 1000
    ShowTerminal()
}

ShowTerminal()
{
    WinShow "ahk_class CASCADIA_HOSTING_WINDOW_CLASS"
    WinActivate "ahk_class CASCADIA_HOSTING_WINDOW_CLASS"
}

HideTerminal()
{
    WinHide "ahk_class CASCADIA_HOSTING_WINDOW_CLASS"
}