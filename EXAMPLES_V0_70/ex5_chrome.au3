#AutoIt3Wrapper_Au3Check_Parameters=-q -d -w 1 -w 2 -w 3 -w- 4 -w 5 -w 6 -w- 7
;~ #au3check -q -d -w 1 -w 2 -w 3 -w- 4 -w 5 -w 6 -w- 7
;~ Example 5 Automating chrome
;~ This example shows how to use UI Automation with chrome (later an example will come to put stuff in the html page)
;~ 1. Have chrome started with "--force-renderer-accessibility"
;~ 2. Check with chrome://accessibility in the adress bar if accessibility is on/off, turn it on
;~ a. or close all browsers and change in script the run command to the right path of the chrome.exe
;~
;~ Apparently google changed some stuff in chrome version 29 and seems not allways to return classname properly so sometimes
;~ harder to get the right element
;- Even worse on version 42 not returning UIA controltype or classnames for certain elements
;~ Version chrome 65

#include <EditConstants.au3>
#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>
#include <constants.au3>
#include <WinAPI.au3>
#AutoIt3Wrapper_Au3Check_Parameters=-q -d -w 1 -w 2 -w 3 -w- 4 -w 5 -w 6 -w- 7
;~ #au3check -q -d -w 1 -w 2 -w 3 -w- 4 -w 5 -w 6 -w- 7
#include <debug.au3>

#include "UIAWrappers.au3"

#AutoIt3Wrapper_UseX64=N  ;Should be used for stuff like tagpoint having right struct etc. when running on a 64 bits os

local $strChromeStartup="--force-renderer-accessibility"
local $strChromeExeFolder=@UserProfileDir & "\AppData\Local\Google\Chrome\Application\"
local $strChromeExe=$strChromeExeFolder & "chrome.exe "

if not fileexists($strChromeExe) Then
	$strChromeExeFolder=@ProgramFilesDir & "\Google\Chrome\Application\"
	$strChromeExe=$strChromeExeFolder & "chrome.exe "
EndIf

;~ Start chrome
if fileexists($strChromeExe) Then
    if not processexists("chrome.exe") Then
        run($strChromeExe & $strChromeStartup,"", @SW_MAXIMIZE )
        ProcessWait("chrome.exe")
        ;~ Just to give some time to start
        sleep(10000)
    endif
Else
	if not processexists("chrome.exe") Then
		consolewrite("No clue where to find chrome on your system, please start manually:" & @CRLF )
		consolewrite($strChromeExeFolder & @CRLF)
 		consolewrite(@ProgramFilesDir & @CRLF)
;~ 		C:\Program Files (x86)\Google\Chrome\Application

		consolewrite($strChromeExe & $strChromeStartup & @CRLF)
		Exit
	endif
EndIf

local $oChrome=_UIA_getFirstObjectOfElement($UIA_oDesktop,"class:=Chrome_WidgetWin_1", $treescope_children)
$oChrome.setfocus()

;~ _UIA_DumpThemAll($oDesktop,$treescope_children)

if isobj($oChrome) Then
;~ All stuff on the page to be dumped in an xml file in log folder
_UIA_DumpThemAll($oChrome,$treescope_subtree)

;~  get the addressbar
;~  $oChromeAddressBar=_UIA_getFirstObjectOfElement($oChrome,"class:=Chrome_OmniboxView", $treescope_children) ;worked in chrome 28
;~ local $oChromeAddressBar=_UIA_getFirstObjectOfElement($oChromeToolbar,"controltype:=" & $UIA_EditControlTypeId , $treescope_subtree) ;works in chrome 29
;~ $oChromeAddressBar=_UIA_getFirstObjectOfElement($oChromeToolbar,"helptext:=OmniboxViewViews", $treescope_subtree) ;works in chrome 42
;~  $oChromeAddressBar=_UIA_getFirstObjectOfElement($oChrome,"name:=Adres- en zoekbalk"  , $treescope_children) ;works in chrome 29

local $oChromeAddressBar=_UIA_getFirstObjectOfElement($oChrome,"title:=Adres- en zoekbalk"  , $treescope_subtree) ;works in chrome 65

;~  _UIA_DumpThemAll($oChromeToolbar,$treescope_children)
local $oValueP=_UIA_getpattern($oChromeAddressBar,$UIA_ValuePatternId)

;~  get the value of the addressbar
local $myText=""
$oValueP.CurrentValue($myText)
consolewrite("address: " & $myText & @CRLF)
sleep(500)

;~ Click all tabs, chrome hides them a little in the hierarchy but first find the tablist
local $oChromeTabs=_UIA_getFirstObjectOfElement($oChrome,"controltype:=" & $UIA_TabControlTypeId, $treescope_subtree)
 _UIA_DumpThemall($oChromeTabs,$treescope_children)

;~  Get result with findall function alternative could be the treewalker
    local  $pCondition, $pTrueCondition
	local  $pElements, $iLength

;~  and now just find all childs which are 4 tabs and 1 new button looking like a tab
    $UIA_oUIAutomation.CreateTrueCondition($pTRUECondition)
    local $oCondition=ObjCreateInterface($pTrueCondition, $sIID_IUIAutomationCondition,$dtagIUIAutomationCondition)

	$oChromeTabs.FindAll($treescope_children, $oCondition, $pElements)
    local $oAutomationElementArray = ObjCreateInterFace($pElements, $sIID_IUIAutomationElementArray, $dtagIUIAutomationElementArray)

	$oAutomationElementArray.Length($iLength)
	consolewrite("We have " & $ilength & " tabs" & @CRLF)

    For $i = 0 To $iLength - 1; it's zero based
	$oAutomationElementArray.GetElement($i, $UIA_pUIElement)
        local $oUIElement = ObjCreateInterface($UIA_pUIElement, $sIID_IUIAutomationElement, $dtagIUIAutomationElement)
        consolewrite( "Title is: <" &  _UIA_getPropertyValue($oUIElement,$UIA_NamePropertyId) &  ">" & @TAB _
   & "Class   := <" & _UIA_getPropertyValue($oUIElement,$uia_classnamepropertyid) &  ">" & @TAB _
& "controltype:= <" &  _UIA_getPropertyValue($oUIElement,$UIA_ControlTypePropertyId) &  ">" & @TAB & @CRLF)
;~  Invoke or select them all
;~ Tricky as chrome seems to say it supports certain patterns but then they seem not to be implemented


;~ only tabs with content
if _UIA_getPropertyValue($oUIElement, $UIA_IsSelectionItemPatternAvailablePropertyId) = "True" Then
_UIA_action($oUIElement,"leftclick")
;~  $oSelectP=_UIA_getpattern($oUIElement,$UIA_SelectionItemPatternId)
;~  $oSelectP.Select()
EndIf


Next

EndIf

;~ Lets open a new tab within chrome by finding the button in the tabstrip
local $oChromeNewTab=_UIA_getFirstObjectOfElement($oChromeTabs,"controltype:=" & $UIA_ButtonControlTypeId, $treescope_subtree)
_UIA_action($oChromeNewTab,"leftclick")

;~ Lets get the valuepattern of the addressbar
;~  $oLegacyP=_UIA_getpattern($oChromeAddressBar,$UIA_LegacyIAccessiblePatternId)
;~

_UIA_action($oChromeAddressBar,"leftclick")
_UIA_action($oChromeAddressBar,"setvalue using keys","www.autoitscript.com/forum{ENTER}")

;~ some time to load the browser page
sleep(2000)

exit

