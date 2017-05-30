{ Copyright 2004-2017 (c) RealThinClient.com (http://www.realthinclient.com) }

unit rtcTSCli;

interface

{$INCLUDE rtcPortalDefs.inc}
{$INCLUDE rtcDefs.inc}

USES
  Windows,
  SysUtils,
  rtcLog;

TYPE
  { winsta.dll }
  TWinStationConnect = FUNCTION(hServer: THANDLE; SessionID: ULONG;
    TargetSessionID: ULONG; pPassword: PWideChar; bWait: Boolean)
    : Boolean; stdcall;

  { kernel32.dll }
  TWTSGetActiveConsoleSessionId = FUNCTION: DWORD; stdcall;
  TProcessIdToSessionId = FUNCTION(dwProcessID: DWORD; VAR pSessionId: DWORD)
    : BOOL; stdcall;

  { user32.dll }
  TLockWorkStation = FUNCTION: BOOL; stdcall;

VAR
  WinStationConnect: TWinStationConnect = NIL;
  WTSGetActiveConsoleSessionId: TWTSGetActiveConsoleSessionId = NIL;
  ProcessIdToSessionId: TProcessIdToSessionId = NIL;
  LockWorkStation: TLockWorkStation = NIL;
  LibsLoaded: Integer = 0;
  gWinSta: HMODULE;
  gKernel32: HMODULE;
  gUser32: HMODULE;

FUNCTION inConsoleSession: Boolean;
PROCEDURE SetConsoleSession(pSessionId: DWORD = $FFFFFFFF);

IMPLEMENTATION

FUNCTION GetProcedureAddress(VAR P: Pointer; CONST ModuleName, ProcName: String;
  VAR pModule: HMODULE): Boolean;
VAR
  ModuleHandle: HMODULE;
BEGIN
  IF NOT Assigned(P) THEN
  BEGIN
    ModuleHandle := GetModuleHandle(PChar(ModuleName));
    IF ModuleHandle = 0 THEN
      ModuleHandle := LoadLibrary(PChar(ModuleName));
    IF ModuleHandle <> 0 THEN
      P := Pointer(GetProcAddress(ModuleHandle, PChar(ProcName)));
    Result := Assigned(P);
  END
  ELSE
    Result := True;
END;

FUNCTION InitProcLibs: Boolean;
BEGIN
  IF LibsLoaded > 0 THEN
    Result := True
  ELSE IF LibsLoaded < 0 THEN
    Result := False
  ELSE
  BEGIN
    LibsLoaded := -1;
    IF GetProcedureAddress(@WinStationConnect, 'winsta.dll',
      'WinStationConnectW', gWinSta) AND
      GetProcedureAddress(@WTSGetActiveConsoleSessionId, 'kernel32.dll',
      'WTSGetActiveConsoleSessionId', gKernel32) AND
      GetProcedureAddress(@ProcessIdToSessionId, 'kernel32.dll',
      'ProcessIdToSessionId', gKernel32) AND
      GetProcedureAddress(@LockWorkStation, 'user32.dll', 'LockWorkStation',
      gUser32) THEN
      LibsLoaded := 1;
    Result := LibsLoaded = 1;
  END;
// {$IFDEF ExtendLog}XLog(Format('rtcTSCli.InitProclibs = %s', [BoolToStr(Result, True)]), LogAddon); {$ENDIF}
END;

PROCEDURE DeInitProcLibs;
BEGIN
  IF LibsLoaded = 1 THEN
  BEGIN
    FreeLibrary(gWinSta);
    FreeLibrary(gKernel32);
    FreeLibrary(gUser32);
  END;
END;

FUNCTION ProcessSessionId: DWORD;
BEGIN
  Result := 0;
  IF (LibsLoaded = 1) THEN
  BEGIN
    IF NOT ProcessIdToSessionId(GetCurrentProcessId(), Result) THEN
      Result := $FFFFFFFF
  END;
  // {$ifdef ExtendLog}XLog(Format('ProcessSessionId = %d', [result]), LogAddon);{$endif}
END;

FUNCTION ConsoleSessionId: DWORD;
BEGIN
  IF (LibsLoaded = 1) THEN
    Result := WTSGetActiveConsoleSessionId
  ELSE
    Result := 0;
  // {$ifdef ExtendLog}XLog(Format('ConsoleSessionId = %d', [result]), LogAddon);{$endif}
END;

FUNCTION inConsoleSession: Boolean;
BEGIN
  Result := ConsoleSessionId = ProcessSessionId;
  // {$ifdef ExtendLog}XLog(Format('inConsoleSession = %s', [booltostr(result, true)]), LogAddon);{$endif}
END;

PROCEDURE SetConsoleSession(pSessionId: DWORD = $FFFFFFFF);
BEGIN
// {$IFDEF ExtendLog}XLog(Format('SetConsoleSession(%d)', [pSessionId]), LogAddon); {$ENDIF}
  IF (LibsLoaded = 1) THEN
  BEGIN
    IF (pSessionId = $FFFFFFFF) THEN
      pSessionId := ProcessSessionId;
// {$IFDEF ExtendLog}XLog(Format('WinStationConnect(%d, %d)', [pSessionId, ConsoleSessionId]), LogAddon); {$ENDIF}
    IF WinStationConnect(0, pSessionId, ConsoleSessionId, '', False) THEN
{$IFDEF FORCELOGOUT}
      LockWorkStation;
{$ELSE FORCELOGOUT}
      ;
{$ENDIF FORCELOGOUT}
  END;
END;

INITIALIZATION

InitProcLibs;

FINALIZATION

DeInitProcLibs;

END.
