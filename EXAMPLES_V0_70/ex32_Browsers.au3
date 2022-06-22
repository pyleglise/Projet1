;~ *** Standard code ***
#include "UIAWrappers.au3"
AutoItSetOption("MustDeclareVars", 1)

#region All logical definitions to have an abstraction layer (could be put in ini/properties UID file)
;~ To be moved to UID (User interface definition) files
;~ Set the system under test UID objects to recognize
local $UID_IE[2][2] = [ _
["mainwindow","Title:=.*Internet Explorer;classname:=IEFrame;instance:=1"], _
["addressbar","class:=Address Band Root;indexrelative:=1"] _
]
_UIA_setVarsFromArray($UID_IE,"browser1.")

;~ 2nd and 3rd browser definition (as an example)
_UIA_setVar("browser2.mainwindow","classname:=IEFrame;controltype:=Window;instance:=2")
_UIA_setVar("browser3.mainwindow","classname:=IEFrame;controltype:=Window;instance:=3")

;~ Chrome definitions
local $UID_CHROME[3][2] = [ _
["mainwindow","classname:=Chrome_WidgetWin_1;controltype:=Window;instance:=1"], _
["addressbar","title:=((Adres- en zoekbalk)|(Adress.*));ControlType:=Edit;instance:=1"], _
["newtab","name:=((Nieuw tabblad)|(new tab))"] _
]
_UIA_setVarsFromArray($UID_CHROME,"browser4.")

;~ Firefox definitions
local $UID_FF[2][2] = [ _
["mainwindow","Title:=Mozilla Firefox.*;controltype:=Window;class:=MozillaWindowClass;instance:=1"], _
["addressbar","title:=((Voer zoek.*)|(Search or enter address));controltype:=Edit"] _
]
_UIA_setVarsFromArray($UID_FF,"browser5.")

#EndRegion

#region examples

;~ run("notepad.exe","", @SW_SHOWMAXIMIZED)
;~ run("iexplore.exe")
;~ run("chrome.exe --force-renderer-accessibility")
run("firefox")

;~ shellexecute("iexplore.exe")
shellexecute("""C:\Program Files (x86)\Google\Chrome\Application\chrome.exe""", "--force-renderer-accessibility")
;~ shellexecute("firefox")

sleep(3000)

;~ exampleIE()
exampleChrome()
;~ exampleFF()
#EndRegion

func exampleIE()
	;~ So first on internet explorer
	_UIA_action("browser1.mainwindow","setfocus")
	;~ _UIA_action("browser1.addressbar","setfocus")
	_UIA_action("browser1.addressbar","click")                 ;Weird that we first have to click the addresbar to activate before we can set value in it
	;~ _UIA_action("browser1.mainwindow","setfocus")
	_UIA_action("browser1.addressbar","setvalue", "www.autoitscript.com")
	_UIA_action("browser1.addressbar","sendkeys", "{ENTER}")
	;~ _UIA_action("browser1.mainwindow","setfocus")
	;~ Just to show something happened before we go home again
	sleep(2500)
	_UIA_action("browser1.addressbar","sendkeys", "{BROWSER_HOME}")
EndFunc

func exampleChrome()
	;~ and now on Chrome
	_UIA_action("browser4.mainwindow","setfocus")
	_UIA_action("browser4.addressbar","setfocus")
	_UIA_action("browser4.addressbar","click")
	_UIA_action("browser4.addressbar","setvalue", "www.autoitscript.com")
	_UIA_action("browser4.addressbar","sendkeys", "{ENTER}")
	;~ Just to show something happened before we go home again
	sleep(5000)

	_UIA_action("browser4.newtab","click")
	_UIA_action("browser4.addressbar","sendkeys", "{BROWSER_HOME}")
EndFunc

func exampleFF()
	;~ and now on Firefox
	_UIA_action("browser5.mainwindow","setfocus")
	_UIA_action("browser5.addressbar","setfocus")
;~ 	_UIA_action("browser5.addressbar","click")
	_UIA_action("browser5.addressbar","sendkeys", "www.autoitscript.com")
	_UIA_action("browser5.addressbar","sendkeys", "{ENTER}")
	;~ Just to show something happened before we go home again
	sleep(5000)
	_UIA_action("browser5.addressbar","sendkeys", "{BROWSER_HOME}")
EndFunc

Exit