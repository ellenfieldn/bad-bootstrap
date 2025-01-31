; Finds monitor handle given a point
getMonitorHandle(monitor)
{
  ; Initialize Monitor handle
  hMon := DllCall("MonitorFromPoint"
    , "int64", monitor["Point"] ; point on monitor
    , "uint", 1) ; flag to return primary monitor on failure
    
  ; Get Physical Monitor from handle
  VarSetCapacity(Physical_Monitor, 8 + 256, 0)

  ret := DllCall("dxva2\GetPhysicalMonitorsFromHMONITOR"
    , "int", hMon   ; monitor handle
    , "uint", 1   ; monitor array size
    , "int", &Physical_Monitor)   ; point to array with monitor
  handleRetCode("getMonitorHandle", ret)
  hPhysMon := NumGet(Physical_Monitor)
  MsgBox, %hMon% : %hPhysMon%
  return hPhysMon
}

destroyMonitorHandle(handle)
{
  DllCall("dxva2\DestroyPhysicalMonitor", "int", handle)
}

; Used to change the monitor source
; DVI = 3
; HDMI = 4
; YPbPr = 12
setMonitorInputSource(monitor, source)
{
  handle := getMonitorHandle(monitor)
  ret := DllCall("dxva2\SetVCPFeature"
    , "int", handle
    , "char", 0x60 ;VCP code for Input Source Select
    , "uint", monitor[source])
  handleRetCode("setMonitorInputSource", ret)
  destroyMonitorHandle(handle)
}

; Gets Monitor source
getMonitorInputSource(monitor)
{
  handle := getMonitorHandle(monitor)
  ret := DllCall("dxva2\GetVCPFeatureAndVCPFeatureReply"
    , "int", handle
    , "char", 0x60 ;VCP code for Input Source Select
    , "Ptr", 0
    , "uint*", currentValue
    , "uint*", maximumValue)
  handleRetCode("getMonitorInputSource", ret)
  destroyMonitorHandle(handle)
  ;MsgBox, Current value: %currentValue%. Max value: %maximumValue%.
  return currentValue
}

handleRetCode(name, ret)
{
  if(ret) 
  {
	;msgbox, %name% success: %ret%
  }
  else
  {
    lasterror := DllCall("Kernel32\GetLastError")
	msgbox, %name% error: %ret% - %lasterror%
  }
}

; Msgbox with current monitor input source
;!r::
;msgbox % getMonitorInputSource()
;return

changeInput(monitor, sourcename)
{
  currentSource := getMonitorInputSource(monitor)
  if(currentSource != 3)
  {
    ;msgbox, Did not equal 3: %currentSource%
    setMonitorInputSource(monitor, "Dvi")
    ;msgbox % getMonitorInputSource(monitor)
  }
  else
  {
    ;msgbox, Did equal 3: %currentSource%
    setMonitorInputSource(monitor, sourcename)
    ;msgbox % getMonitorInputSource(monitor)
  }
}

RightMonitor := {"Point": 300, "Dvi": 3, "Hdmi": 17}
LeftMonitor := {"Point": -100, "Dvi": 3, "Vga": 1}

#IfWinActive
!r::
changeInput(RightMonitor, "Hdmi")
changeInput(LeftMonitor, "Vga")
return