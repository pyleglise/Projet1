#AutoIt3Wrapper_Au3Check_Parameters=-q -d -w 1 -w 2 -w 3 -w- 4 -w 5 -w 6 -w- 7
;~ #au3check -q -d -w 1 -w 2 -w 3 -w- 4 -w 5 -w 6 -w- 7
;~ Example 7 Demonstrates all stuff within firefox to
;~ navigate html pages,
;~ find hyperlink,
;~ click hyperlink,
;~ find picture,
;~ click picture,
;~ enter data in inputbox
;~
;~ Made a lot more comments and failure to show when an object is not retrieved/found the hierarchy of the tree is written to the console
;~ Lots of optimizations could be done by using the cachefunctions (less interprocess communication) but on my machine it runs at
;~ a very acceptable speed
;~ In top of script put the text in your local language of the operating system

#include <EditConstants.au3>
#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>
#include <constants.au3>
#include <WinAPI.au3>
#include <debug.au3>
#include "CUIAutomation2.au3"
#include "UIAWrappers.au3"

#AutoIt3Wrapper_UseX64=Y  ;Should be used for stuff like tagpoint having right struct etc. when running on a 64 bits os

;~ Make this language specific
;~ const $cToolbarByName = "name:=((Navigation Toolbar)|(Navigatiewerkbalk))"
const $cToolbarByName = "name:=Mozilla Firefox"
const $cAddressBarByName = "name:=Rechercher avec Google ou saisir une adresse"
const $cFFNewTabByName="name:=((Open a new tab.*)|(Een nieuw tabblad openen.*))"
const $cstrDocument="Name:=" & "AutoIt.*" & "; controltype:=" & $UIA_DocumentControlTypeId & "; isoffscreen:=False"
local $strFFExeFolder
if (@AutoItX64==1) then
	$strFFExeFolder=@programfilesdir & "\Mozilla Firefox\"
Else
	$strFFExeFolder=@programfilesdir & " (x86)\Mozilla Firefox\"
EndIf

local $strFFStartup=""
local $strFFExe=$strFFExeFolder & "firefox.exe "

;~ Start chrome
if fileexists($strFFExe) Then
    if not processexists("firefox.exe") Then
        run($strFFExe & $strFFStartup,"", @SW_MAXIMIZE )
        ProcessWait("firefox.exe")
        ;~ Just to give some time to start
        sleep(10000)
    endif
Else
    consolewrite("No clue where to find firefox on your system, please start manually:" & @CRLF )
    consolewrite($strFFExe & $strFFStartup & @CRLF)
EndIf

;~ Find the FF window
local $oFF=_UIA_getFirstObjectOfElement($UIA_oDesktop,"class:=MozillaWindowClass", $treescope_children)
if not isobj($oFF) Then
    _UIA_DumpThemAll($UIA_oDesktop,$treescope_children)
EndIf

;~ Make sure ff is front window
$oFF.setfocus()

if isobj($oFF) Then
    consolewrite("Action 1" & @CRLF)

;~  get the FF toolbar
;~  $oFFToolbar=_UIA_getFirstObjectOfElement($oFF,"controltype:=" & $UIA_ToolBarControlTypeId, $treescope_subtree)
local     $oFFToolbar=_UIA_getFirstObjectOfElement($oFF,$cToolbarByName, $treescope_subtree)
    if not isobj($oFFToolbar) Then
        _UIA_DumpThemAll($oFF,$treescope_subtree)
    EndIf


consolewrite("Action 2" & @CRLF)
;~  get the addressbar
;~  $oFFAddressBar=_UIA_getFirstObjectOfElement($oFFToolbar,"class:=Chrome_OmniboxView", $treescope_children) ;worked in chrome 28
;~  $oFFAddressBar=_UIA_getFirstObjectOfElement($oFFToolbar,"controltype:=" & $UIA_EditControlTypeId , $treescope_subtree) ;works in chrome 29
;~  $oFFAddressBar=_UIA_getFirstObjectOfElement($oFFToolbar,"name:=Adres- en zoekbalk"  , $treescope_children) ;works in chrome 29
local $oFFAddressBar=_UIA_getObjectByFindAll($oFFToolbar, $cAddressBarByName  , $treescope_subtree) ;works in chrome 29
    if not isobj($oFFAddressbar) Then
        _UIA_DumpThemAll($oFFToolbar,$treescope_subtree)
    EndIf
	_uia_action($oFFAddressbar,"highlight")
;~  $oValueP=_UIA_getpattern($oFFAddressBar,$UIA_ValuePatternId)
;~  sleep(2000)

;~  get the value of the addressbar
;~  $myText=""
;~  $oValueP.CurrentValue($myText)
;~  consolewrite("address: " & $myText & @CRLF)

consolewrite("Action 3" & @CRLF)
;~ Get reference to the tabs
local     $oFFTabs=_UIA_getFirstObjectOfElement($oFF,"controltype:=" & $UIA_TabControlTypeId, $treescope_subtree)
    if not isobj($oFFTabs) Then
        _UIA_DumpThemAll($oFF,$treescope_subtree)
    EndIf

;~ Lets open a new tab within ff

consolewrite("Action 4" & @CRLF)
;~  $oFFNewTab= _UIA_getFirstObjectOfElement($oFFTabs,"controltype:=" & $UIA_ButtonControlTypeId, $treescope_subtree)
local     $oFFNewTab= _UIA_getObjectByFindAll($oFFTabs, $cFFNewTabByName,$treescope_subtree)
    if not isobj($oFFNewTab) Then
        _UIA_DumpThemAll($oFFTabs,$treescope_subtree)
    EndIf
 _UIA_action($oFFNewtab,"leftclick")
 sleep(100)

consolewrite("Action 5" & @CRLF)
    $oFFAddressBar=_UIA_getObjectByFindAll($oFFToolbar, $cAddressBarByName  , $treescope_subtree) ;works in chrome 29

    if not isobj($oFFAddressbar) Then
        _UIA_DumpThemAll($oFFToolbar,$treescope_subtree)
    EndIf

local     $t=stringsplit(_UIA_getPropertyValue($oFFAddressBar, $UIA_BoundingRectanglePropertyId),";")
    _UIA_DrawRect($t[1],$t[3]+$t[1],$t[2],$t[4]+$t[2])
    _UIA_action($oFFAddressBar,"leftclick")
    _UIA_action($oFFAddressBar,"setvalue using keys","www.autoitscript.com/{ENTER}")

consolewrite("Action 6" & @CRLF)

;~  give some time to open website
    sleep(1000)
;~     $oDocument=_UIA_getFirstObjectOfElement($oFF,"controltype:=" & $UIA_DocumentControlTypeId , $treescope_subtree)
;~ 	$oDocument=_UIA_getFirstObjectOfElement($oFF,"Name:=" & "AutoItScript - AutoItScript Website" , $treescope_subtree)
local 	$oDocument=_UIA_getObjectByFindAll($oFF,$cstrDocument, $treescope_subtree)
    if not isobj($oDocument) Then
		consolewrite("Action 6 failed" & @CRLF)
        _UIA_DumpThemAll($oFF,$treescope_subtree)
		exit
    Else
        $t=stringsplit(_UIA_getPropertyValue($oDocument, $UIA_BoundingRectanglePropertyId),";")
        _UIA_DrawRect($t[1],$t[3]+$t[1],$t[2],$t[4]+$t[2])
    EndIf

    sleep(100)

consolewrite("Action 7 retrieve document after clicking a hyperlink" & @CRLF)
local     $oForumLink=_UIA_getObjectByFindAll($oDocument,"name:=FORUM", $treescope_subtree)
;~ All document items
    if not isobj($oForumLink) Then
		consolewrite("Action 7 failed" & @CRLF)
        _UIA_DumpThemAll($oDocument,$treescope_subtree)
		exit
    EndIf
    _UIA_action($oForumLink,"leftclick")
    sleep(1000)

consolewrite("Action 8 first refresh the document control" & @CRLF)

;~     $oDocument=_UIA_getFirstObjectOfElement($oFF,"controltype:=" & $UIA_DocumentControlTypeId , $treescope_subtree)
	$oDocument=_UIA_getObjectByFindAll($oFF,$cstrDocument, $treescope_subtree)

    if not isobj($oDocument) Then
		consolewrite("Action 8 failed" & @CRLF)
        _UIA_DumpThemAll($oFF,$treescope_subtree)
    Else
        $t=stringsplit(_UIA_getPropertyValue($oDocument, $UIA_BoundingRectanglePropertyId),";")
        _UIA_DrawRect($t[1],$t[3]+$t[1],$t[2],$t[4]+$t[2])
    EndIf

;~ Now we get the searchfield
	local 	$oEdtSearchForum = _UIA_getObjectByFindAll($oDocument, "controltype:=Edit;name:=Search...", $treescope_subtree)
    if not isobj($oEdtSearchForum) Then
        _UIA_DumpThemAll($oDocument,$treescope_subtree)
    EndIf
    _UIA_action($oEdtSearchForum,"focus")
    _UIA_action($oEdtSearchForum,"setvalue using keys","Chrome is designed to resist automation in a web page") ; {ENTER}")
    sleep(100)

;~ Exit
;~ Now we press the button, see relative syntax used as the button seems not to have a name its just 1 objects further then search field
local     $oBtnSearch=_UIA_getObjectByFindAll($oDocument,"name:=Search...; indexrelative:=1", $treescope_subtree)
    if not isobj($oBtnSearch) Then
        _UIA_DumpThemAll($oDocument,$treescope_subtree)
    EndIf
    $t=stringsplit(_UIA_getPropertyValue($oDocument, $UIA_BoundingRectanglePropertyId),";")
    _UIA_DrawRect($t[1],$t[3]+$t[1],$t[2],$t[4]+$t[2])
    sleep(100)
    _UIA_action($oBtnSearch,"leftclick")
    sleep(1000)

;~ consolewrite("Action 9 first refresh the document control" & @CRLF)

;~     $oDocument=_UIA_getFirstObjectOfElement($oFF,"controltype:=" & $UIA_DocumentControlTypeId , $treescope_subtree)
	$oDocument=_UIA_getObjectByFindAll($oFF,$cstrDocument, $treescope_subtree)

	if not isobj($oDocument) Then
        _UIA_DumpThemAll($oDocument,$treescope_subtree)
    EndIf
;~ 	UIA_HyperlinkControlTypeId
;~ Tricky to know its the 2nd one you want to click on
local     $oHyperlink=_UIA_getObjectByFindAll($oDocument,"name:=controlsend doesn't work;index:=2", $treescope_subtree)
    if not isobj($oBtnSearch) Then
        _UIA_DumpThemAll($oDocument,$treescope_subtree)
    EndIf
    sleep(100)
    _UIA_action($oHyperlink,"leftclick",20,5)
    sleep(1000)

consolewrite("Action 10 just find some text to validate" & @CRLF)
	$oDocument = _UIA_getFirstObjectOfElement($oFF, "controltype:=" & $UIA_DocumentControlTypeId, $treescope_subtree)
	If Not IsObj($oDocument) Then
		_UIA_DumpThemAll($oDocument, $treescope_subtree)
	EndIf
	local 	$oTextToCheck = _UIA_getObjectByFindAll($oDocument, "name:=.*automated with ui automation.*", $treescope_subtree)
	If Not IsObj($oTextToCheck) Then
		_UIA_DumpThemAll($oDocument, $treescope_subtree)
	EndIf
	Sleep(100)
;~ 	_UIA_action($oTextToCheck, "invoke")
	_UIA_action($oTextToCheck, "highlight")
	consolewrite(_UIA_action($oTextToCheck, "property", "title"))
	local $tResult=_UIA_action($oTextToCheck, "getvalue")
	consolewrite($tresult)

	Sleep(1000)

EndIf

exit

