^!p::
SysGet, PrimaryMon, MonitorPrimary
Sysget, MonCount, MonitorCount
SysGet, MonName, MonitorName, PrimaryMon
MsgBox, Enabling Presentation Mode on monitor %PrimaryMon% out of %MonCount%: %MonName%. (%A_ScreenWidth%x%A_ScreenHeight%)
MsgBox, Enabling Presentation Mode
ChangeResolution(MonName, 1920, 1080)
Run, presentationsettings.exe /start
return


^!+p::
SysGet, PrimaryMon, MonitorPrimary
Sysget, MonCount, MonitorCount
SysGet, MonName, MonitorName, PrimaryMon
MsgBox, Disabling Presentation Mode on monitor %PrimaryMon% out of %MonCount%: %MonName%. (%A_ScreenWidth%x%A_ScreenHeight%)
MsgBox, Disabling Presentation Mode
ChangeResolution(MonName, 2560, 1440)
Run, presentationsettings.exe /stop
return



ChangeResolution(MonitorName, Screen_Width, Screen_Height)
{
	VarSetCapacity(Device_Mode,200,0)
	ret := DllCall("user32\EnumDisplaySettings", "Str",MonitorName, "UInt",-2, "UInt",&Device_Mode) 
	nameLen := strlen(strget(&Device_Mode))
	NumPut(Screen_Width,Device_Mode,172)
	NumPut(Screen_Height,Device_Mode,176)
	ret := DllCall( "ChangeDisplaySettingsEx"
		, "str",MonitorName
		, "uint",&Device_Mode
		, "uint",null
		, "uint",0
		, "UInt", null )
	Return ret
}