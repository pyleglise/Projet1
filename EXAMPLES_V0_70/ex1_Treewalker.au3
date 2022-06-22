#AutoIt3Wrapper_Au3Check_Parameters=-q -d -w 1 -w 2 -w 3 -w- 4 -w 5 -w 6 -w- 7
;~ #au3check -q -d -w 1 -w 2 -w 3 -w- 4 -w 5 -w 6 -w- 7
;~ Example 1 Iterating thru the different ways of representing the objects in the tree
;~ a. Autoit WinList function
;~ b. UIAutomation RawViewWalker
;~ c. UIAutomation ControlViewWalker
;~ d. UIAutomation ContentViewWalker
;~ e. Finding elements based on conditions (based on property id, frequently search on name or classname)

#include <EditConstants.au3>
#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>
#include <MsgBoxConstants.au3>
#include <WinAPI.au3>
#include "CUIAutomation2.au3"
#include "UIAWrappers.au3"

#AutoIt3Wrapper_UseX64=Y  ;Should be used for stuff like tagpoint having right struct etc. when running on a 64 bits os
;~ _UIA_Action($UIA_oDesktop,"setfocus")

;~ To prevent some FAQ questions
consolewrite("*** Some important settings you can find in " & @scriptdir & "\UIA.CFG ***" & @CRLF)
consolewrite("*** " & _UIA_getVersionInfoString() )
consolewrite("*** If logging is turned on you can find it here :" & _UIA_getVar("logFileName") & @CRLF)

samplewinlist()

sampleTW(1)
sampleTW(2)
sampleTW(3)

ConsoleWrite("**** Desktop windows ****" & @CRLF)
findThemAll($UIA_oDesktop, $TreeScope_Children)

ConsoleWrite(@CRLF & "**** All childs of the taskbar ****")
local $oTaskBar = _UIA_gettaskbar()
findThemAll($oTaskBar, $treescope_subtree)

ConsoleWrite(@CRLF & "**** Deal with browser windows ****" & @CRLF)
Local $myBrowser
;- Just get the first browser we can find
$myBrowser=getBrowser()

local $tReturn=MsgBox($MB_SYSTEMMODAL + $MB_OKCANCEL , "Title", "Make sure you have 2 browsers (IE and Chrome) open otherwise press X button to abort.")
if $tReturn<>$IDOK  Then
	ConsoleWrite(@CRLF & "**** ABORTING chrome browser demo ****" & @CRLF)
	exit
EndIf

consolewrite(@CRLF & "**** Continue with finding 2 browser windows ****" & @CRLF)

;- Just get the first browser we can find of this type
local $browserType= "Google Chrome"
;~ $browserType= "Internet Explorer"
;~ $browserType= "Opera"

$myBrowser=getBrowser($browserType,1)
if isobj($myBrowser) Then
	consolewrite("Yes found first browser " & @CRLF)
endif

ConsoleWrite(@CRLF & "**** Deal with 2nd browser window****" & @CRLF)
;- Just get the 2nd browser we can find of this type
$myBrowser=getBrowser($browserType,2)
if isobj($myBrowser) Then
	consolewrite("Yes found second browser " & @CRLF)
Else
	consolewrite("No 2nd browser found so unable to focus and highlight " & @CRLF)
	exit
endif

_UIA_Action($myBrowser,"setfocus")
_UIA_Action($myBrowser,"highlight")

Func sampleWinList()
	ConsoleWrite("sample winlist (title not empty and visible windows only)" & @CRLF)
	Local $hTimer = TimerInit()
	Local $var = WinList()

	For $i = 1 To $var[0][0]
		; Only display visble windows
		If $var[$i][0] <> "" And IsVisible($var[$i][1]) Then
			ConsoleWrite($i & ": Title=" & $var[$i][0] & @TAB & "Handle=" & $var[$i][1] & " Class=" &  _WinAPI_GetClassName($var[$i][1]) & @CRLF)
		EndIf
	Next

	Local $fDiff = TimerDiff($hTimer)
	Consolewrite("SampleWinList took: " & $fDiff & " milliseconds" & @CRLF & @CRLF)
EndFunc   ;==>sampleWinList

Func IsVisible($handle)
	If BitAND(WinGetState($handle), 2) Then
		Return 1
	Else
		Return 0
	EndIf

EndFunc   ;==>IsVisible

Func getBrowser($browserName="",$browserIndex=1)
	local $iBrowserIdx=0
;- Create treewalker
	$UIA_oUIAutomation.RawViewWalker($UIA_pTW)

	local $oTW = ObjCreateInterface($UIA_pTW, $sIID_IUIAutomationTreeWalker, $dtagIUIAutomationTreeWalker)
	If IsObj($oTW) = 0 Then
		MsgBox(1, "UI automation treewalker failed", "UI Automation failed failed", 10)
	EndIf

;~ Get first element
	$oTW.GetFirstChildElement($UIA_oDesktop, $UIA_pUIElement)
	local $oUIElement = ObjCreateInterface($UIA_pUIElement, $sIID_IUIAutomationElement, $dtagIUIAutomationElement)

;~ Iterate all desktopwindows
	While IsObj($oUIElement) = True
		local $tName= _UIA_getPropertyValue($oUIElement, $UIA_NamePropertyId)
		Local $tHandle= Hex(_UIA_getPropertyValue($oUIElement, $UIA_NativeWindowHandlePropertyId))
		Local $tClassName= _UIA_getPropertyValue($oUIElement, $uia_classnamepropertyid)
;~ 		Browser normally put their browsername after the - (so this fails when multiple - are in title so thats why we search from right)
		local $tStrTitle=stringmid($tname,stringinstr($tName,"-",  $STR_NOCASESENSE, -1)+2)

;- See if its a browser (based on title it could be done on class but preferred logical name instead of a classname)
;~ Private modes diffferent title to deal with only IE misbehaves
;~ InPrivate - Internet Explorer - [InPrivate]
;~ InPrivate - [InPrivate] ?- Microsoft Edge
;~ Google Chrome (Incognito)
;~ Mozilla Firefox (Private Browsing)
;~ Privé-browsen - Opera<

;~ 		Fix misbehave
		if $tStrTitle="[InPrivate]" then $tStrTitle="Internet Explorer"
		if stringinstr($tStrTitle," (") then
			$tStrTitle=stringleft($tStrTitle,stringinstr($tStrTitle," (")-1)
		EndIf
		consolewrite("location: " & stringinstr($tName,"-",  $STR_NOCASESENSE, -1) & "<" & $tStrTitle & "><" & $tname & "><" &  $tclassname & "><" &   $tHandle & ">"& @CRLF)

		local $itsABrowserTitle=stringinstr("Google Chrome,Internet Explorer,Mozilla Firefox,Microsoft Edge,Opera",$tStrTitle,$STR_NOCASESENSE )
		local $itsABrowserClass=stringinstr("Chrome_WidgetWin_1,IEFrame",$tClassname,$STR_NOCASESENSE )
		if ($itsABrowserTitle > 0) or ($itsABrowserClass>0) then
;~ 			consolewrite("** Potential match ** " & $tStrTitle & ":" & $browserName& @tab & $tname & @tab & $tclassname & @CRLF)
			if ($browserName=stringleft($tStrTitle,stringlen($browsername))) or ($browserName="") or ($itsABrowserClass>0) Then
;~ 				consolewrite("** match ** " & $tStrTitle & ":" & $browserName& @tab & $tname & @tab & $tclassname & @CRLF)
				$iBrowserIdx=$iBrowserIdx+1
;~ 				consolewrite($browserIndex & $iBrowserIdx)
				if $iBrowserIDX=$browserIndex Then
					return $oUIElement
				endif
			EndIf
		EndIf

		$oTW.GetNextSiblingElement($oUIElement, $UIA_pUIElement)
		$oUIElement = ObjCreateInterface($UIA_pUIElement, $sIID_IUIAutomationElement, $dtagIUIAutomationElement)
	WEnd

EndFunc   ;==>sampleTW


Func sampleTW($t)
	ConsoleWrite("initializing tw " & $t & @CRLF)
	Local $hTimer = TimerInit()
	Local $i=0
;~ ' Lets show all the items of the desktop with a treewalker
	If $t = 1 Then $UIA_oUIAutomation.RawViewWalker($UIA_pTW)
	If $t = 2 Then $UIA_oUIAutomation.ControlViewWalker($UIA_pTW)
	If $t = 3 Then $UIA_oUIAutomation.ContentViewWalker($UIA_pTW)

	local $oTW = ObjCreateInterface($UIA_pTW, $sIID_IUIAutomationTreeWalker, $dtagIUIAutomationTreeWalker)
	If IsObj($oTW) = 0 Then
		MsgBox(1, "UI automation treewalker failed", "UI Automation failed failed", 10)
	EndIf

	$oTW.GetFirstChildElement($UIA_oDesktop, $UIA_pUIElement)
	local $oUIElement = ObjCreateInterface($UIA_pUIElement, $sIID_IUIAutomationElement, $dtagIUIAutomationElement)

	While IsObj($oUIElement) = True
		ConsoleWrite($i & "Title is: " & _UIA_getPropertyValue($oUIElement, $UIA_NamePropertyId) & @TAB & "Handle=" & Hex(_UIA_getPropertyValue($oUIElement, $UIA_NativeWindowHandlePropertyId)) & @TAB & "Class=" & _UIA_getPropertyValue($oUIElement, $uia_classnamepropertyid) & @CRLF)
		$oTW.GetNextSiblingElement($oUIElement, $UIA_pUIElement)
		$oUIElement = ObjCreateInterface($UIA_pUIElement, $sIID_IUIAutomationElement, $dtagIUIAutomationElement)
		$i=$i+1
	WEnd

	Local $fDiff = TimerDiff($hTimer)
	Consolewrite("Sample tw " & $t & " took: " & $fDiff & " milliseconds" & @CRLF & @CRLF)
EndFunc   ;==>sampleTW

Func findThemAll($oElementStart, $TreeScope)
	Local $hTimer = TimerInit()
;~  Get result with findall function alternative could be the treewalker
	local $oCondition, $pTrueCondition
	local $pElements, $iLength

	$UIA_oUIAutomation.CreateTrueCondition($pTrueCondition)
	$oCondition = ObjCreateInterface($pTrueCondition, $sIID_IUIAutomationCondition, $dtagIUIAutomationCondition)
;~  $oCondition1 = _AutoItObject_WrapperCreate($aCall[1], $dtagIUIAutomationCondition)
;~ Tricky to search all descendants on html objects or from desktop/root element
	$oElementStart.FindAll($TreeScope, $oCondition, $pElements)

	local $oAutomationElementArray = ObjCreateInterface($pElements, $sIID_IUIAutomationElementArray, $dtagIUIAutomationElementArray)

	$oAutomationElementArray.Length($iLength)
	For $i = 0 To $iLength - 1; it's zero based
		$oAutomationElementArray.GetElement($i, $UIA_pUIElement)
		local $oUIElement = ObjCreateInterface($UIA_pUIElement, $sIID_IUIAutomationElement, $dtagIUIAutomationElement)
		ConsoleWrite("Title is: " & _UIA_getPropertyValue($oUIElement, $UIA_NamePropertyId) & @TAB & "Class=" & _UIA_getPropertyValue($oUIElement, $uia_classnamepropertyid) & @CRLF)
	Next

	Local $fDiff = TimerDiff($hTimer)
	Consolewrite("Findthemall took: " & $fDiff & " milliseconds" & @CRLF & @CRLF)

EndFunc   ;==>findThemAll