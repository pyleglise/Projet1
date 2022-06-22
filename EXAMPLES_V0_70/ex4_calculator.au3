#AutoIt3Wrapper_Au3Check_Parameters=-q -d -w 1 -w 2 -w 3 -w- 4 -w 5 -w 6 -w- 7
;~ #au3check -q -d -w 1 -w 2 -w 3 -w- 4 -w 5 -w 6 -w- 7
;~ Example 4 that demonstrates on the calculator and notepad
;~ How to click
;~ How to find buttons (be aware that you have to change the captions to language of your windows)
;~ How to click in the menu (copy result to the clipboard)
;~    then it uses notepad to demonstrate
;~ How to set a value on a textbox with the value pattern
;~
;~ Attention points
;~ Examples are build on exact match of text (so this includes tab and Ctrl+C values), later I will
;~ make some function that can find with regexp or non exact match (need treewalker for that)
;~ Timing / sleep is sometimes needed to give the system time to popup the menus / execute the action
;~ Focus of application is sometimes to be set (and sometimes not as you look on the clicking of the
;~ buttons it will even happen when there is a screen in front of the calculator)

#include "UIAWrappers.au3"

local $oButton
#forceref $oButton

#AutoIt3Wrapper_UseX64=Y  ;Should be used for stuff like tagpoint having right struct etc. when running on a 64 bits os

;~ To prevent some FAQ questions
consolewrite("*** Some important settings you can find in " & @scriptdir & "\UIA.CFG ***" & @CRLF)
consolewrite("*** " & _UIA_getVersionInfoString() )
consolewrite("*** If logging is turned on you can find it here :" & _UIA_getVar("logFileName") & @CRLF)

Consolewrite("**** Get the notepad and calculator ****" & @CRLF)

consolewrite("Example text is for dutch calculator so please change text to english or other language to identify controls" & @crlf)

;~ Translate below to correct language
local $cCalcIdentification="title:=Rekenmachine"
;~ $cCalcClassName="((CalcFrame)|(ApplicationFrameWindow))"
local $cNotepadIdentification="class:=Notepad"

local $cButton1
local $cButton3
local $cButtonAdd
local $cButtonEqual
local $cButtonEdit

if @OSVERSION="WIN_10" Then
	 $cButton1="Een"
	 $cButton3="Drie"
	 $cButtonAdd="Plus"
	 $cButtonEqual="Is gelijk aan"
	 $cButtonEdit="Bewerken"
Else
	 $cButton1="1"
	 $cButton3="3"
	 $cButtonAdd="Optellen"
	 $cButtonEqual="Is gelijk aan"
	 $cButtonEdit="Weergave is.*"
EndIf



;~ Start the calculator and notepad
run("calc.exe")
run("notepad.exe")

Local $oCalc=_UIA_getFirstObjectOfElement($UIA_oDesktop,$cCalcIdentification, $treescope_children)
Local $oNotepad=_UIA_getFirstObjectOfElement($UIA_oDesktop, $cNotepadIdentification, $treescope_children)

if isobj($oCalc) Then

;~ You can comment this out just there to get the names of whats available under the calc window
_UIA_DumpThemAll($oCalc,$treescope_subtree)

    $oButton=_UIA_getFirstObjectOfElement($oCalc,"name:=" & $cButton1, $treescope_subtree)
    local $oInvokeP=_UIA_getpattern($oButton,$UIA_InvokePatternID)
    $oInvokeP.Invoke

    $oButton=_UIA_getFirstObjectOfElement($oCalc,"name:=" & $cButtonAdd, $treescope_subtree)
    $oInvokeP=_UIA_getpattern($oButton,$UIA_InvokePatternID)
    $oInvokeP.Invoke

    $oButton=_UIA_getFirstObjectOfElement($oCalc,"name:=" & $cButton3, $treescope_subtree)
    $oInvokeP=_UIA_getpattern($oButton,$UIA_InvokePatternID)
    $oInvokeP.Invoke

    $oButton=_UIA_getFirstObjectOfElement($oCalc,"name:=" & $cButtonEqual, $treescope_subtree)
    $oInvokeP=_UIA_getpattern($oButton,$UIA_InvokePatternID)
    $oInvokeP.Invoke

if @OSVERSION="WIN_10" Then
  	$oButton=_UIA_getObjectByFindAll($oCalc," automationid:=CalculatorResults", $treescope_subtree)
	_UIA_highlight($oButton)
    _UIA_Action($oButton,"right")
else
    $oButton=_UIA_getFirstObjectOfElement($oCalc,"name:=" & $cButtonEdit, $treescope_subtree)
    $oInvokeP=_UIA_getpattern($oButton,$UIA_InvokePatternID)
    $oInvokeP.Invoke
EndIf

    sleep(1500)
;~  findThemAll($oCalc,$treescope_subtree)
;~  sleep(1000)

;~ Use a regular expression to identify the copy choice as there are special characters/tabs etc in the name
;~     $sText="Kopiëren.*"    ;Copy
;~     $sText="name:=((Copy.*)|(Kopi.*))"    ;Copy
    local $sText="((Copy.*)|(Kopi.*))"    ;Copy
    $oButton=_UIA_getObjectByFindAll($oCalc,"name:=" & $sText, $treescope_subtree)
    if isobj($oButton) Then
        consolewrite("Menuitem is there")
    Else
        consolewrite("Menuitem is NOT there")
    EndIf
    sleep(2000)

if @OSVERSION="WIN_10" Then
    _UIA_Action($oButton,"left")
else
	$oInvokeP=_UIA_getpattern($oButton,$UIA_InvokePatternID)
    $oInvokeP.Invoke
endif
    sleep(2500)

Else
	consolewrite("Calculator window not found ")
	_UIA_DumpThemAll($UIA_oDesktop,$treescope_children)
EndIf

if isobj($oNotepad) Then

local $myText=clipget()

;~ You can comment this out
_UIA_dumpThemAll($oNotepad,$treescope_subtree)
    sleep(1000)

;~ Activate notepad and put the value in the edit text control of notepad
    $oNotepad.setfocus()

    $sText="Edit"
    local $oEdit=_UIA_getFirstObjectOfElement($oNotepad,"classname:=" & $sText, $treescope_subtree)
    local $oValueP=_UIA_getpattern($oEdit,$UIA_ValuePatternId)
    $oValueP.SetValue($myText)

EndIf

Exit

