;~ Versuch, den Totalcommander zu steuern


#include <EditConstants.au3>
#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>
#include <constants.au3>
#include <WinAPI.au3>
;#include <debug.au3>

#include "UIAWrappers.au3"

#AutoIt3Wrapper_UseX64=Y  ;Should be used for stuff like tagpoint having right struct etc. when running on a 64 bits os

;~ Make this language specific
const $cTCClassName="TNASTYNAGSCREEN"
const $cButton1="1"


;~ Finde das TC Fenster:

;~ _UIA_setVar("RegistrationButton","title:=Registratie.*;classname:=Button")

Local $oP3=_UIA_getObjectByFindAll($UIA_oDesktop, "Title:=Total Commander;controltype:=UIA_WindowControlTypeId;class:=TNASTYNAGSCREEN", $treescope_children)
_UIA_Action($oP3,"setfocus")
_UIA_DumpThemAll($oP3,$treescope_subtree)

;~ Local $oBtn=_UIA_getObjectByFindAll($oP3, "RegistrationButton", $treescope_subtree)
;~ Local $oBtn=_UIA_getObjectByFindAll($oP3, "title:=1;classname:=Button", $treescope_subtree)
Local $oBtn=_UIA_getObjectByFindAll($oP3, "controltype:=UIA_PaneControlTypeId;index:=4", $treescope_subtree)

$tmpStr=_UIA_getBasePropertyInfo($oBtn)
ConsoleWrite($tmpStr)

;~ _UIA_Highlight($oBtn)

;~ _UIA_Action($oBtn,"highlight")
Exit

Local $okrampf=_UIA_getObjectByFindAll($oP3, "Title:=;controltype:=UIA_PaneControlTypeId;class:=TPanel", $treescope_children)
_UIA_Action($okrampf,"setfocus")


        ConsoleWrite("Title is: <" &  _UIA_getPropertyValue($okrampf,$UIA_NamePropertyId) &  ">" & @TAB _
                    & "Class   := <" & _UIA_getPropertyValue($okrampf,$uia_classnamepropertyid) &  ">" & @TAB _
                    & "controltype:= <" &  _UIA_getPropertyValue($okrampf,$UIA_ControlTypePropertyId) &  ">" & @TAB  _
                    & " (" &  hex(_UIA_getPropertyValue($okrampf,$UIA_ControlTypePropertyId)) &  ")" & @TAB & @CRLF)

Exit