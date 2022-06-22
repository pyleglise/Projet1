#AutoIt3Wrapper_Au3Check_Parameters=-q -d -w 1 -w 2 -w 3 -w- 4 -w 5 -w 6 -w- 7
;~ #au3check -q -d -w 1 -w 2 -w 3 -w- 4 -w 5 -w 6 -w- 7
;~ Example 3 Clicking a litlle more for finding in your start menu scite and in the end displaying all items from the clock (thats not directly possible with AU3Info)
;~ This shows a little more on the concept of
;~ 1. Find your element
;~ 2. Think what you want and find the right pattern
;~ 3. Retrieve the pattern and execute the action
;~
;~ Within the patterns you will find not likely direct support for clicking right mouse and default actions are not allways what you want so
;~ then you have to fallback to mousemove, mouseclick functions of autoit or
;~ the sendinput function from microsoft (not declared in the standard autoit library)

#include "UIAWrappers.au3"

#AutoIt3Wrapper_UseX64=Y  ;Should be used for stuff like tagpoint having right struct etc. when running on a 64 bits os

;~ To prevent some FAQ questions
consolewrite("*** Some important settings you can find in " & @scriptdir & "\UIA.CFG ***" & @CRLF)
consolewrite("*** " & _UIA_getVersionInfoString() )
consolewrite("*** If logging is turned on you can find it here :" & _UIA_getVar("logFileName") & @CRLF)

Consolewrite("**** Get the taskbar ****" & @CRLF)
local $oTaskBar=_UIA_gettaskbar()
;~ Equal To
;~ _UIA_getFirstObjectOfElement($oDesktop,"classname:=Shell_TrayWnd",$TreeScope_Children)

Consolewrite("**** All childs of the taskbar ****" & @CRLF)
;~  _UIA_dumpThemAll($otaskbar,$treescope_subtree)

local $pInvoke ;~ Pattern invoke
local $oStart  ;~ Object reference to IUIElement for button start
local $CaptionStartButton

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

Consolewrite("**** Different ways of assigning the startbutton to an object ****" & @CRLF)
;~ $oStart=_UIA_getFirstObjectOfElement($oTaskbar,"Starten", $treescope_subtree)
$oStart=_UIA_getFirstObjectOfElement($oTaskbar,"name:="& $CaptionStartButton, $treescope_subtree)

local $oClock  ;~ Object reference to IUIElement for button of clock, be aware this is a panel not a button
$oClock=_UIA_getFirstObjectOfElement($oTaskbar,"classname:=TrayClockWClass", $treescope_subtree)

Consolewrite("**** try to click on the start button of the taskbar ****" & @CRLF)
;~ Get the first item that has as the name: Starten change to Start for english or other text to match start button in local language
$oStart=_UIA_getFirstObjectOfElement($oTaskbar,"Starten", $treescope_subtree)

if isobj($oStart) Then
    consolewrite("Start button found" & @CRLF)
Else
    consolewrite("I bet the text has to change to Start instead of Starten")
EndIf

Consolewrite("Get the invoke pattern to click on the start button item. Invoke possible: " & _UIA_getPropertyValue($UIA_oUIElement, $UIA_IsInvokePatternAvailablePropertyId) & @CRLF)
;~ $oStart.getCurrentPattern($UIA_InvokePatternId, $pInvoke)
;~ $oInvokeP=objCreateInterface($pInvoke, $sIID_IUIAutomationInvokePattern, $dtagIUIAutomationInvokePattern)
local $oInvokeP=_UIA_getpattern($oStart,$UIA_InvokePatternID)
$oInvokeP.invoke()
sleep(100)

Consolewrite("Get the menu that is after the start button" & @crlf)

if @OSVERSION="WIN_10" Then
	local $oMenuStart=_UIA_getFirstObjectOfElement($UIA_oDesktop,"classname:=Windows.UI.Core.CoreWindow", $treescope_subtree)
Else
	$oMenuStart=_UIA_getFirstObjectOfElement($UIA_oDesktop,"Menu Start", $treescope_children)
	;~ $oMenuStart=_UIA_getFirstObjectOfElement($UIA_oDesktop,"Menu Start", $treescope_Descendants)
EndIf

if isobj($oMenuStart) Then
    consolewrite("Menu start found" & @crlf)
Else
    consolewrite("I bet the text has to change to Start instead of Starten" & @crlf)
EndIf

local $oStartMenuItem
local  $tDimension

$oStartMenuItem=_UIA_getFirstObjectOfElement($oMenuStart,"name:=SciTE", $treescope_subtree)
;~ $oStartMenuItem=_UIA_getFirstObjectOfElement($oMenuStart,"Microsoft Excel 2010", $treescope_subtree)
;~ $oStartMenuItem=_UIA_getFirstObjectOfElement($oMenuStart,"SpotGrit", $treescope_subtree)
if isobj($oStartMenuItem) Then
    consolewrite("Scite found" & @crlf)
;~ remember the dimensions

	$tDimension=stringsplit(_UIA_getPropertyValue($oStartMenuItem, $UIA_BoundingRectanglePropertyId),";")

Else
    consolewrite("scite not found" & @crlf)
EndIf

Consolewrite("Get the pattern to click on the menu after the start button. Invoke possible: " & _UIA_getPropertyValue($oStartMenuItem, $UIA_IsInvokePatternAvailablePropertyId) & @CRLF)
$oInvokeP=_UIA_getpattern($oStartMenuItem,$UIA_InvokePatternID)
;~ This would definitely fail as there is no invoke pattern
if isobj($oInvokeP) Then
    consolewrite("invoke found lets see what happens" & @crlf)
	$oInvokeP.invoke()
Else
    consolewrite("invoke not supported" & @crlf)
EndIf

sleep(3000)

consolewrite("So you saw it clicked or only selected but did not click" & @crlf)
;~ still you can click as you now know the dimensions previousl where to click
if ubound($tDimension)>0 Then
	consolewrite("Initial dimension: " & $tDimension[1] & ";" & $tDimension[2] & ";" & $tDimension[3] & ";" & $tDimension[4] & @crlf)
EndIf

;- Allways recheck that you not clicked it away or shifted focus

$tDimension=stringsplit(_UIA_getPropertyValue($oStartMenuItem, $UIA_BoundingRectanglePropertyId),";")
;~ _arraydisplay($tDimension)
;~ consolewrite("Nice!@#!@#!@ even if its gone you get a bounding rectangle" & ubound($tDimension))
;~ local $iVisible=_UIA_getPropertyValue($oStartMenuItem,$UIA_IsOffscreenPropertyId)
;~ consolewrite("Visible [" & $iVisible & "]" & @CRLF)

if ubound($tDimension)>2 Then
;~ _winapi_mouse_event($MOUSEEVENTF_ABSOLUTE + $MOUSEEVENTF_MOVE,$t[1],$t[2])
	mousemove($tDimension[1]+($tDimension[3]/2),$tDimension[2]+$tDimension[4]/2)
	sleep(2000)
	mouseclick("left")
	sleep(2000)
Else
;~ Remind you can easily mis an object having focus by giving it to another app, so refix frequenlty your steps
	consolewrite("Weird no dimensions found to click in" & @crlf)
	consolewrite("**** Fixing to click on scite in start menu **** " & @crlf)
	$oInvokeP=_UIA_getpattern($oStart,$UIA_InvokePatternID)
	$oInvokeP.invoke()
	sleep(500)

	$tDimension=stringsplit(_UIA_getPropertyValue($oStartMenuItem, $UIA_BoundingRectanglePropertyId),";")
	mousemove($tDimension[1]+($tDimension[3]/2),$tDimension[2]+$tDimension[4]/2)
	sleep(2000)
	mouseclick("left")
	sleep(2000)
endif

Consolewrite("**** try to click on the clock (TrayClockWClass) or (Windows.UI.Core.CoreWindow) button of the taskbar ****" & @CRLF)
if isobj($oClock) Then
    consolewrite("Clock found" & @crlf)
Else
    consolewrite("Clock not found" & @crlf)
EndIf

local $pLegacy
;~ $oClock.getCurrentPattern($UIA_InvokePatternId, $pInvoke)
local $oLegacyP=_UIA_getPattern($oClock,$UIA_LegacyIAccessiblePatternId)
$oLegacyP.dodefaultaction()

local $oClock2

if @OSVERSION="WIN_10" Then
	$oClock2=_UIA_getFirstObjectOfElement($UIA_odesktop,"classname:=Windows.UI.Core.CoreWindow",$TreeScope_Children)
Else
	$oClock2=_UIA_getFirstObjectOfElement($UIA_odesktop,"classname:=ClockFlyoutWindow",$TreeScope_Children)
EndIf

if isobj($oClock2) then
	_UIA_dumpthemall($oClock2,$treescope_subtree)
Else
	consolewrite("Second clock window not found with the clock elements" & @crlf)
	_UIA_dumpthemall($UIA_oDesktop,$treescope_children)
EndIf

consolewrite("Check created xml or txt for the output as we run in debug logging mode automatically" & @crlf)

Exit

