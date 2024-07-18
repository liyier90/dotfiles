#Requires AutoHotkey v2.0
#SingleInstance Force

Komorebic(Cmd) {
    RunWait Format("komorebic {}", Cmd), , "Hide"
}

!Enter::Run "wt"
!+r::Reload

!q::Komorebic("close")
!m::Komorebic("minimize")
!+c::Komorebic("reload-configuration")

; Focus window
!h::Komorebic("focus left")
!j::Komorebic("focus down")
!k::Komorebic("focus up")
!l::Komorebic("focus right")

!+[::Komorebic("cycle-focus previous")
!+]::Komorebic("cycle-focus next")

; Focus monitor
!p::Komorebic("cycle-monitor next")
!u::Komorebic("cycle-monitor previous")

; Move windows
!+h::Komorebic("move left")
!+j::Komorebic("move down")
!+k::Komorebic("move up")
!+l::Komorebic("move right")

; Stack windows
!Left::Komorebic("stack left")
!Down::Komorebic("stack down")
!Up::Komorebic("stack up")
!Right::Komorebic("stack right")
!;::Komorebic("unstack")
![::Komorebic("cycle-stack previous")
!]::Komorebic("cycle-stack next")

; Resize
!=::Komorebic("resize-axis horizontal increase")
!-::Komorebic("resize-axis horizontal decrease")
!+=::Komorebic("resize-axis vertical increase")
!+_::Komorebic("resize-axis vertical decrease")

; Manipulate windows
!+Space::Komorebic("toggle-float")
!w::Komorebic("toggle-monocle")

; Window manager options
; !+r::Komorebic("retile")
!+p::Komorebic("toggle-pause")

; Layouts
!x::Komorebic("flip-layout horizontal")
!y::Komorebic("flip-layout vertical")

; Workspaces
!1::
{
    Komorebic("focus-monitor 0")
    Komorebic("focus-workspace 0")
}
!2::
{
    Komorebic("focus-monitor 1")
    Komorebic("focus-workspace 0")
}
!3::
{
    Komorebic("focus-monitor 0")
    Komorebic("focus-workspace 1")
}
!4::
{
    Komorebic("focus-monitor 1")
    Komorebic("focus-workspace 1")
}
!5::
{
    Komorebic("focus-monitor 0")
    Komorebic("focus-workspace 2")
}
!6::
{
    Komorebic("focus-monitor 1")
    Komorebic("focus-workspace 2")
}
!7::
{
    Komorebic("focus-monitor 0")
    Komorebic("focus-workspace 3")
}
!8::
{
    Komorebic("focus-monitor 1")
    Komorebic("focus-workspace 3")
}

; Move windows across workspaces
!+1::
{
    Komorebic("move-to-monitor 0")
    Komorebic("move-to-workspace 0")
}
!+2::
{
    Komorebic("move-to-monitor 1")
    Komorebic("move-to-workspace 0")
}
!+3::
{
    Komorebic("move-to-monitor 0")
    Komorebic("move-to-workspace 1")
}
!+4::
{
    Komorebic("move-to-monitor 1")
    Komorebic("move-to-workspace 1")
}
!+5::
{
    Komorebic("move-to-monitor 0")
    Komorebic("move-to-workspace 2")
}
!+6::
{
    Komorebic("move-to-monitor 1")
    Komorebic("move-to-workspace 2")
}
!+7::
{
    Komorebic("move-to-monitor 0")
    Komorebic("move-to-workspace 3")
}
!+8::
{
    Komorebic("move-to-monitor 1")
    Komorebic("move-to-workspace 3")
}
