#include "UIAWrappers.au3"

AutoItSetOption("MustDeclareVars", 1)

;~ Start the application
run("notepad.exe")

#REGION UIA_LOGICAL_NAMES
;~ Give logical names
;~ _UIA_setVar("notepad.mainwindow","title:=((Naamloos.*Kladblok)|(.*Notepad));classname:=Notepad")
_UIA_setVar("notepad.mainwindow","title:=((Naamloos.*Kladblok)|(.*Npad));classname:=Notepad")
_UIA_setVar("notepad.mainwindow.edit","title:=;classname:=Edit")

;~ When closing when text is changed
_UIA_setVar("Notepad.closewindow","title:=((Kladblok)|(Notepad));classname:=#32770")
;~ The three buttons
_UIA_setVar("Notepad.closewindow.Save","title:=Save;classname:=CCPushButton")
_UIA_setVar("Notepad.closewindow.Don'tSave","title:=((Don't Save)|(Niet opslaan));classname:=CCPushButton")
_UIA_setVar("Notepad.closewindow.Cancel","title:=((Cancel)|(Annuleren));classname:=CCPushButton")
#ENDREGION

#REGION ACTIONS
;~ Do some actions on the logical named objects
_UIA_action("notepad.mainwindow","setfocus")
_UIA_action("notepad.mainwindow","move",300,300)
_UIA_action("notepad.mainwindow","resize",300,300)
_UIA_action("notepad.mainwindow","minimize",300,300)
_UIA_action("notepad.mainwindow","maximize",300,300)
_UIA_action("notepad.mainwindow","resize",400,400)

_UIA_action("notepad.mainwindow.edit","setfocus")
_UIA_action("notepad.mainwindow.edit","setvalue","set value: hello world")
_UIA_action("notepad.mainwindow.edit","type","type command: hello world")

_UIA_action("notepad.mainwindow","close",400,400)
if _UIA_action("Notepad.closewindow","exists") Then
	_UIA_action("Notepad.closewindow.Don'tSave","click")
Else
EndIf
#ENDREGION