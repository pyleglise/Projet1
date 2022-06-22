;~ *** Standard code maintainable ***
#include "UIAWrappers.au3"
AutoItSetOption("MustDeclareVars", 1)

_UIA_setVar("oP1","Title:=Start;controltype:=UIA_WindowControlTypeId;class:=Windows.UI.Core.CoreWindow")	;Start
_UIA_setVar("oP2","Title:=Apps in Start;controltype:=UIA_ListControlTypeId;class:=TileListView")	;Apps in Start
_UIA_setVar("oP3","Title:=Groepskoptest Het leven in één oogopslag;controltype:=UIA_ListControlTypeId;class:=TileListViewItem")	;Groepskoptest Het leven in één oogopslag

;~ $oUIElement=_UIA_getObjectByFindAll("MicrosoftEdge.mainwindow", "title:=Microsoft Edge;ControlType:=UIA_ListItemControlTypeId", $treescope_subtree)
_UIA_setVar("oUIElement","Title:=Microsoft Edge;controltype:=UIA_ListItemControlTypeId;class:=TileListViewItem") ;ControlType:=UIA_ListItemControlTypeId;classname:=TileListViewItem")

;~ Be aware that tree hierarchy changes as such simple spy will not give below
_UIA_setVar("oTaskbar","Title:=;controltype:=UIA_PaneControlTypeId;class:=Shell_TrayWnd")	;
_UIA_setVar("oStartbutton","title:=Starten;classname:=Start")


;~ Actions split away from logical/technical definition above can come from configfiles
_UIA_Action("oTaskbar","setfocus")
_UIA_Action("oStartButton","click")
sleep(500)
;~_UIA_Action("oP1","highlight")
_UIA_Action("oP1","setfocus")
;~_UIA_Action("oP2","highlight")
_UIA_Action("oP2","setfocus")
;~_UIA_Action("oP3","highlight")
_UIA_Action("oP3","setfocus")

;~_UIA_action($oUIElement","highlight")
;~_UIA_action($oUIElement,"click")
_UIA_action("oUIElement","setfocus")
sleep(500)
;~_UIA_action("oUIElement","click")
