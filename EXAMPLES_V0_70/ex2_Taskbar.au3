#AutoIt3Wrapper_Au3Check_Parameters=-q -d -w 1 -w 2 -w 3 -w- 4 -w 5 -w 6 -w- 7
;~ #au3check -q -d -w 1 -w 2 -w 3 -w- 4 -w 5 -w 6 -w- 7
;~ Example 2 Finding the taskbar and clicking on the start menu button
#include <EditConstants.au3>
#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>
#include <WinAPI.au3>
#include "CUIAutomation2.au3"
#include "UIAWrappers.au3"

#AutoIt3Wrapper_UseX64=Y  ;Should be used for stuff like tagpoint having right struct etc. when running on a 64 bits os

;~ To prevent some FAQ questions
consolewrite("*** Some important settings you can find in " & @scriptdir & "\UIA.CFG ***" & @CRLF)
consolewrite("*** " & _UIA_getVersionInfoString() )
consolewrite("*** If logging is turned on you can find it here :" & _UIA_getVar("logFileName") & @CRLF)

Consolewrite("**** All childs of the taskbar will be written to logfile see xml or txt file created in folder of example .au3 file ****" & @CRLF)
Consolewrite("** Logfile default location: " & _uia_getVar("logfilename") & @CRLF)

;~ Maintainable way for doing stuff with taskbar and startbutton by giving logical name to technical description
_UIA_setVar("oTaskbar","Title:=;controltype:=UIA_PaneControlTypeId;class:=Shell_TrayWnd")	;
_UIA_setVar("oStartbutton","title:=Starten;classname:=Start")

local $oTaskBar=_UIA_gettaskbar()
_UIA_DumpThemAll($otaskbar,$treescope_subtree)

local $pInvoke, $oStart
local $CaptionStartButton

Consolewrite("**** try to click on the start button of the taskbar ****" & @CRLF)
Consolewrite("Your languagecode influences name of start button and your languagecode is: " & @oslang & @CRLF)
switch @OSLang
	case 0409
		$CaptionStartButton="start"
	case 0413
		$CaptionStartButton="Starten"
	case 1033
		$CaptionStartButton="Start"
	case Else
		MsgBox($MB_SYSTEMMODAL, "Title", "Language unknown please extend script with right caption of start button and post it in thread", 3)
EndSwitch

;~ Get the first item that has as the name: Starten change to Start for english or other text to match start button in local language
$oStart=_UIA_getFirstObjectOfElement($oTaskbar,$CaptionStartButton, $treescope_subtree)
if isobj($oStart) Then
    consolewrite("Start button found" & @CRLF)

Else
    consolewrite("I bet you did not read the messagebox. Script will stop")
	exit
EndIf

;~ Get the invoke pattern to click on the item
$oStart.getCurrentPattern($UIA_InvokePatternId, $pInvoke)
local $oInvokeP=objCreateInterface($pInvoke, $sIID_IUIAutomationInvokePattern, $dtagIUIAutomationInvokePattern)
$oInvokeP.invoke()
sleep(500)

;~ And doing it in a maintainable way the logical / technical definition independent of each other

_UIA_Action($UIA_oDesktop,"click",1,1)
;~ _UIA_Action($UIA_oDesktop,"mousemove",1,1)
sleep(500)
_UIA_Action("oTaskbar","setfocus")
sleep(1500)
_UIA_Action("oStartButton","setfocus")    ;For start button you first have to give it the focus before you click as when you setfocus to menuitems you can have different behavior
_UIA_Action("oStartButton","click")
sleep(3000)
