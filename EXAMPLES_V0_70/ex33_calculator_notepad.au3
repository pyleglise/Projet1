;~ *** Standard code ***
#include "UIAWrappers.au3"
AutoItSetOption("MustDeclareVars", 1)

#CS
; Write below to uia.cfg file
; This is an inifile for UIA wrappers having the configuration defaults
; Debug=true        Turn debugging on of off with true/false value
; Highlight=true    Turn Highlighting rectangle to true / false
; TODO: AutoStartSUT=true AutoStartSUT is starting all SUT's automatically

[Global]
Debug=true
Highlight=true
AutoStartSUT=true

[Multiuser]
CFGPerUser=false

[Folders]
subfolders=false

;System under test settings
; Folder      = Location where exe can be found
; Workingdir  = Location of the working directory
; exe         = Name of the exe to start
; Fullname    = Path & name of exe
; Windowstate = minimized, maximized, normal


[SUT1]
Folder=%Windowsdir%\system32
Workingdir=%Windowsdir%\system32
exe=calc.exe
Fullname=%Windowsdir%\system32\calc.exe
Parameters=
Processname=calc.exe
Windowstate=normal

[SUT2]
Folder=%Windowsdir%\system32
Workingdir=%Windowsdir%\system32
exe=notepad.exe
Fullname=%Windowsdir%\system32\notepad.exe
Parameters=
Processname=notepad.exe
Windowstate=normal
#CE


;~ Start the system under test applications
;~ _UIA_StartSUT("SUT1") ;~Calculator
;~ _UIA_StartSUT("SUT2") ;~Notepad

shellexecute("calc.exe")
shellexecute("notepad.exe")

;~ Low level setting of references
_UIA_SETVAR("calc.mainwindow","Title:=((Rekenmachine.*)|(calc.*));controltype:=UIA_WindowControlTypeId;class:=CalcFrame")
_UIA_SETVAR("btn1","title:=1;classname:=Button")
_UIA_SETVAR("btn2","title:=2;classname:=Button")
_UIA_SETVAR("btn3","title:=3;classname:=Button")
_UIA_SETVAR("btn4","title:=4;classname:=Button")
_UIA_SETVAR("btn5","title:=5;classname:=Button")
_UIA_SETVAR("btn6","title:=6;classname:=Button")
_UIA_SETVAR("btn7","title:=7;classname:=Button")
_UIA_SETVAR("btn8","title:=8;classname:=Button")
_UIA_SETVAR("btn9","title:=9;classname:=Button")

_UIA_SETVAR("btn+","automationid:=93;classname:=Button")
_UIA_SETVAR("btn=","automationid:=121;classname:=Button")

_UIA_SETVAR("mnuEdit","title:=((Edit)|(Bewerken));ControlType:=MenuItem")
_UIA_SETVAR("mnuCopy","title:=((Copy.*)|(Kopi.*)); controltype:=MenuItem")

;~ Alternative way of setting the predefined references
;- They are all prefixed with the reference Notepad. when loaded
local $UID_NOTEPAD[4][2] = [ _
["mainwindow","classname:=Notepad"], _
["title","controltype:=50037"], _
["mnuEdit","name:=((Edit)|(Bewerken))"], _
["mnuPaste","name:=((Paste.*)|(Plak.*))"] _
]
_UIA_setVarsFromArray($UID_NOTEPAD,"Notepad.")

;- Above could also be stored in configuration files

;- Actual simple script
;- The bookkeeper has a calculator to make a calculation of 1 + 1 and he expects to see the answer 2 in notepad

_UIA_Action("calc.mainwindow","setfocus")
_UIA_Action("btn1","click")
_UIA_Action("btn+","click")
_UIA_Action("btn1","click")
_UIA_Action("btn=","click")

_UIA_Action("mnuEdit","click")
_UIA_Action("mnuCopy","click")

_UIA_Action("Notepad.mainwindow","setfocus")
_UIA_Action("Notepad.mnuEdit","click")

_uia_getvars2array()

_UIA_Action("Notepad.mnuPaste","click")

