#include "CUIAutomation2.au3"
#include "SafeArray.au3"
#include "C:\Program Files (x86)\AutoIt3\Include\AutoItObject Package 1.2.8.3\autoitobject.au3"
#include <WinAPIDiag.au3>
Opt( "MustDeclareVars", 1 )

;~ Global Const $S_OK = 0x00000000
;~ Global Const $E_NOINTERFACE = 0x80004002
;~ Global Const $sIID_IUnknown = "{00000000-0000-0000-C000-000000000046}"
Global Const $tagVARIANT = "ushort vt;word r1;word r2;word r3;ptr data; ptr;"

Global $tIUIAutomationPropertyChangedEventHandler, $oIUIAutomationPropertyChangedEventHandler

Global $oUIAutomation

MainFunc()



Func MainFunc()

  $oIUIAutomationPropertyChangedEventHandler = ObjectFromTag( "oIUIAutomationPropertyChangedEventHandler_", $dtagIUIAutomationPropertyChangedEventHandler, $tIUIAutomationPropertyChangedEventHandler, True )
  If Not IsObj( $oIUIAutomationPropertyChangedEventHandler ) Then Return

  $oUIAutomation = ObjCreateInterface( $sCLSID_CUIAutomation, $sIID_IUIAutomation, $dtagIUIAutomation )
  If Not IsObj( $oUIAutomation ) Then Return

  Local $pUIElement
  $oUIAutomation.GetRootElement( $pUIElement ) ; Desktop
  If Not $pUIElement Then Return

#cs
  ; Use this code to call the AddPropertyChangedEventHandlerNativeArray method, which takes a normal array of property identifiers instead of a SAFEARRAY.
  ; Because of threading issues, calling this method instead of AddPropertyChangedEventHandler may lead to unexpected/incomplete results.
  Local $tPropertyArray = DllStructCreate( "int[2]" )
  DllStructSetData( $tPropertyArray, 1, $UIA_NamePropertyId, 1 )
  DllStructSetData( $tPropertyArray, 1, $UIA_ToggleToggleStatePropertyId, 2 )
  $oUIAutomation.AddPropertyChangedEventHandlerNativeArray( $pUIElement, $TreeScope_Descendants, 0, $oIUIAutomationPropertyChangedEventHandler, $tPropertyArray, 2 )
#ce

  ; Use this code to call the AddPropertyChangedEventHandlerNativeArray method, which takes a pointer to a SAFEARRAY of property identifiers.
  ; Because of threading issues, calling this method instead of AddPropertyChangedEventHandler appears to be preferable for automation of some applications.

  ; Create a SAFEARRAY vector having a number of rows equal to the number of property identifiers you will be monitoring for changes
  Local $ptrSafeArray = SafeArrayCreateVector( "int", 2 )

  ; Write SAFEARRAY structure
  Local Const $tagSAFEARRAY = "ushort cDims; ushort fFeatures; ulong cbElements; ulong cLocks; ptr pvData; ulong cElements; long lLbound"
  Local $tSAFEARRAY = DllStructCreate( $tagSAFEARRAY, $ptrSafeArray )

#cs
  ConsoleWrite( @CRLF & "SafeArray structure" & @CRLF )
  ConsoleWrite( "$tSAFEARRAY size       = " & DllStructGetSize( $tSAFEARRAY ) & @CRLF )
  ConsoleWrite( "$tSAFEARRAY cDims      = " & DllStructGetData( $tSAFEARRAY, "cDims" ) & @CRLF )
  ConsoleWrite( "$tSAFEARRAY fFeatures  = " & "0x" & Hex( DllStructGetData( $tSAFEARRAY, "fFeatures" ) ) & @CRLF )
  ConsoleWrite( "$tSAFEARRAY cbElements = " & DllStructGetData( $tSAFEARRAY, "cbElements" ) & @CRLF )
  ConsoleWrite( "$tSAFEARRAY cLocks     = " & DllStructGetData( $tSAFEARRAY, "cLocks" ) & @CRLF )
  ConsoleWrite( "$tSAFEARRAY pvData     = " & DllStructGetData( $tSAFEARRAY, "pvData" ) & @CRLF )
  ConsoleWrite( "$tSAFEARRAY cElements  = " & DllStructGetData( $tSAFEARRAY, "cElements" ) & @CRLF )
  ConsoleWrite( "$tSAFEARRAY lLbound    = " & DllStructGetData( $tSAFEARRAY, "lLbound" ) & @CRLF )
#ce


  ; Put the property identifiers corresponding to the properties you will be monitoring as elements into the SafeArray
  SafeArrayPutElement( $ptrSafeArray, 0, $UIA_NamePropertyId )
  SafeArrayPutElement( $ptrSafeArray, 1, $UIA_AutomationIdPropertyId )

  #cs
  Local $pValue
  ConsoleWrite( @CRLF & "Get the two conditions" & @CRLF )
  SafeArrayGetElement( $ptrSafeArray, 0, $pValue )
  ConsoleWrite( "int 1 = " &  $pValue & @CRLF )
  SafeArrayGetElement( $ptrSafeArray, 1, $pValue )
  ConsoleWrite( "int 2 = " &  $pValue & @CRLF )
  #ce

  ; Add the PropertyChangedEventHandler
  $oUIAutomation.AddPropertyChangedEventHandler( $pUIElement, $TreeScope_Descendants, 0, $oIUIAutomationPropertyChangedEventHandler, Ptr($ptrSafeArray))

  HotKeySet( "{ESC}", "Quit" )

  While Sleep(100)
  WEnd

  SafeArrayDestroy( $ptrSafeArray )

EndFunc

Func Quit()
  $oIUIAutomationPropertyChangedEventHandler = 0
  DeleteObjectFromTag( $tIUIAutomationPropertyChangedEventHandler )
  Exit
EndFunc



Func _UIA_getPropertyValue( $obj, $id )
  Local $vVal
  $obj.GetCurrentPropertyValue( $id, $vVal )
  Return $vVal
EndFunc

Func MemSet($pDest, $nChar, $nCount)
    DllCall("msvcrt.dll", "ptr:cdecl", "memset", "ptr", $pDest, "int", $nChar, "int", $nCount)
    If @error Then Return SetError(1,0,False)
    Return True
EndFunc

Func oIUIAutomationPropertyChangedEventHandler_HandlePropertyChangedEvent( $pSelf, $pSender, $iPropertyId, $newValue ) ; Ret: long  Par: ptr;int;variant
  ConsoleWrite( @CRLF & "oIUIAutomationPropertyChangedEventHandler_HandlePropertyChangedEvent: $iPropertyId = " & $iPropertyId & ", $newValue = " & $newValue & hex($newValue) &@CRLF )

;~ 	_WinAPI_DisplayStruct($newValue, $tagVARIANT)

    If $newValue <> 0x00000008 Then

    Local $tVARIANT = DllStructCreate($tagVARIANT)  ; ,$newValue)

    $tVARIANT = DllStructCreate($tagVARIANT,$newValue)

;~ 	_AutoItObject_VariantCopy($tVariant,$newValue)

;~ 	memset($tVariant, $newValue, 20)

    Local $vt = DllStructGetData( $tVARIANT, "vt" )
    ConsoleWrite( "$vt = " & $vt & ";" & hex($newValue) & ";" & binarylen($newValue) & ";" & DllStructGetSize($tagVariant) &@CRLF )
   Else
;~ 		Local $tVARIANT = DllStructCreate( $tagVARIANT, $newValue )
;~ 		Local $vt = DllStructGetData( $tVARIANT, "vt" )

;~ 		$vt=_AutoItObject_VariantRead($tVariant)
;~ 		ConsoleWrite( "$vt = " & $vt & @CRLF )

    EndIf

    Local $oSender = ObjCreateInterface( $pSender, $sIID_IUIAutomationElement, $dtagIUIAutomationElement )
    $oSender.AddRef()

    ConsoleWrite( "AutomationId    " & _UIA_getPropertyValue( $oSender, $UIA_AutomationIdPropertyId ) & @CRLF )
    ConsoleWrite( "Handle    " & _UIA_getPropertyValue( $oSender, $UIA_NativeWindowHandlePropertyId ) & @CRLF )
    ConsoleWrite( "Name      " & _UIA_getPropertyValue( $oSender, $UIA_NamePropertyId ) & @CRLF )
    ConsoleWrite( "Class     " & _UIA_getPropertyValue( $oSender, $UIA_ClassNamePropertyId ) & @CRLF )
    ConsoleWrite( "Ctrl type " & _UIA_getPropertyValue( $oSender, $UIA_ControlTypePropertyId ) & @CRLF )
    ConsoleWrite( "Ctrl name " & _UIA_getPropertyValue( $oSender, $UIA_LocalizedControlTypePropertyId ) & @CRLF )
    ConsoleWrite( "Value     " & _UIA_getPropertyValue( $oSender, $UIA_LegacyIAccessibleValuePropertyId ) & @CRLF )
	ConsoleWrite( "NewValue     " & _UIA_getPropertyValue( $oSender, $iPropertyId ) & @CRLF )
  Return $S_OK
EndFunc

Func oIUIAutomationPropertyChangedEventHandler_QueryInterface( $pSelf, $pRIID, $pObj ) ; Ret: long  Par: ptr;ptr*
  Local $sIID = StringFromGUID( $pRIID )
  If $sIID = $sIID_IUnknown Then
    ConsoleWrite( "oIUIAutomationPropertyChangedEventHandler_QueryInterface: IUnknown" & @CRLF )
    DllStructSetData( DllStructCreate( "ptr", $pObj ), 1, $pSelf )
    Return $S_OK
  ElseIf $sIID = $sIID_IUIAutomationPropertyChangedEventHandler Then
    ConsoleWrite( "oIUIAutomationPropertyChangedEventHandler_QueryInterface: IUIAutomationPropertyChangedEventHandler" & @CRLF )
    DllStructSetData( DllStructCreate( "ptr", $pObj ), 1, $pSelf )
    Return $S_OK
  Else
    ConsoleWrite( "oIUIAutomationPropertyChangedEventHandler_QueryInterface: " & $sIID & @CRLF )
    Return $E_NOINTERFACE
  EndIf
EndFunc

Func oIUIAutomationPropertyChangedEventHandler_AddRef( $pSelf ) ; Ret: ulong
  ConsoleWrite( "oIUIAutomationPropertyChangedEventHandler_AddRef" & @CRLF )
  Return 1
EndFunc

Func oIUIAutomationPropertyChangedEventHandler_Release( $pSelf ) ; Ret: ulong
  ConsoleWrite( "oIUIAutomationPropertyChangedEventHandler_Release" & @CRLF )
  Return 1
EndFunc



Func StringFromGUID( $pGUID )
  Local $aResult = DllCall( "ole32.dll", "int", "StringFromGUID2", "struct*", $pGUID, "wstr", "", "int", 40 )
  If @error Then Return SetError( @error, @extended, "" )
  Return SetExtended( $aResult[0], $aResult[2] )
EndFunc



Func ObjectFromTag($sFunctionPrefix, $tagInterface, ByRef $tInterface, $fPrint = False, $bIsUnknown = Default, $sIID = "{00000000-0000-0000-C000-000000000046}") ; last param is IID_IUnknown by default
    If $bIsUnknown = Default Then $bIsUnknown = True
    Local $sInterface = $tagInterface ; copy interface description
    Local $tagIUnknown = "QueryInterface hresult(ptr;ptr*);" & _
            "AddRef dword();" & _
            "Release dword();"
    ; Adding IUnknown methods
    If $bIsUnknown Then $tagInterface = $tagIUnknown & $tagInterface
    ; Below line is really simple even though it looks super complex. It's just written weird to fit in one line, not to steal your attention
    Local $aMethods = StringSplit(StringReplace(StringReplace(StringReplace(StringReplace(StringTrimRight(StringReplace(StringRegExpReplace(StringRegExpReplace($tagInterface, "\w+\*", "ptr"), "\h*(\w+)\h*(\w+\*?)\h*(\((.*?)\))\h*(;|;*\z)", "$1\|$2;$4" & @LF), ";" & @LF, @LF), 1), "object", "idispatch"), "hresult", "long"), "bstr", "ptr"), "variant", "ptr"), @LF, 3)
    Local $iUbound = UBound($aMethods)
    Local $sMethod, $aSplit, $sNamePart, $aTagPart, $sTagPart, $sRet, $sParams, $hCallback
    ; Allocation
    $tInterface = DllStructCreate("int RefCount;int Size;ptr Object;ptr Methods[" & $iUbound & "];int_ptr Callbacks[" & $iUbound & "];ulong_ptr Slots[16]") ; 16 pointer sized elements more to create space for possible private props
    If @error Then Return SetError(1, 0, 0)
    For $i = 0 To $iUbound - 1
        $aSplit = StringSplit($aMethods[$i], "|", 2)
        If UBound($aSplit) <> 2 Then ReDim $aSplit[2]
        $sNamePart = $aSplit[0]
        $sTagPart = $aSplit[1]
        $sMethod = $sFunctionPrefix & $sNamePart
        If $fPrint Then
            Local $iPar = StringInStr( $sTagPart, ";", 2 ), $t
            If $iPar Then
                $t = "Ret: " & StringLeft( $sTagPart, $iPar - 1 ) & "  " & _
                     "Par: " & StringRight( $sTagPart, StringLen( $sTagPart ) - $iPar )
            Else
                $t = "Ret: " & $sTagPart
            EndIf
            Local $s = "Func " & $sMethod & _
                "( $pSelf ) ; " & $t & @CRLF & _
                "EndFunc" & @CRLF
            ConsoleWrite( $s )
        EndIf
        $aTagPart = StringSplit($sTagPart, ";", 2)
        $sRet = $aTagPart[0]
        $sParams = StringReplace($sTagPart, $sRet, "", 1)
        $sParams = "ptr" & $sParams
        $hCallback = DllCallbackRegister($sMethod, $sRet, $sParams)
        ConsoleWrite(@error & @CRLF & @CRLF)
        DllStructSetData($tInterface, "Methods", DllCallbackGetPtr($hCallback), $i + 1) ; save callback pointer
        DllStructSetData($tInterface, "Callbacks", $hCallback, $i + 1) ; save callback handle
    Next
    DllStructSetData($tInterface, "RefCount", 1) ; initial ref count is 1
    DllStructSetData($tInterface, "Size", $iUbound) ; number of interface methods
    DllStructSetData($tInterface, "Object", DllStructGetPtr($tInterface, "Methods")) ; Interface method pointers
    Return ObjCreateInterface(DllStructGetPtr($tInterface, "Object"), $sIID, $sInterface, $bIsUnknown) ; pointer that's wrapped into object
EndFunc

Func DeleteObjectFromTag(ByRef $tInterface)
    For $i = 1 To DllStructGetData($tInterface, "Size")
        DllCallbackFree(DllStructGetData($tInterface, "Callbacks", $i))
    Next
    $tInterface = 0
EndFunc