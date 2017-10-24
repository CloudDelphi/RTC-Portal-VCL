{ Copyright 2004-2017 (c) RealThinClient.com (http://www.realthinclient.com) }

unit rtcWinLogon;

interface

{$INCLUDE rtcDefs.inc}
{$INCLUDE rtcPortalDefs.inc}

{.$DEFINE ExtendLog}

uses
  SyncObjs,
  Windows,
  rtcLog,
  TLHelp32,
  SysUtils,

{$IFDEF RTC_LBFIX}
  rtcTSCli,
{$ENDIF RTC_LBFIX}

  rtcSystem;

const
  DESKTOP_ALL = DESKTOP_CREATEMENU or DESKTOP_CREATEWINDOW or
    DESKTOP_ENUMERATE or DESKTOP_HOOKCONTROL or DESKTOP_WRITEOBJECTS or
    DESKTOP_READOBJECTS or DESKTOP_SWITCHDESKTOP or GENERIC_WRITE;

  WTS_CURRENT_SERVER_HANDLE = 0;

type
  _WTS_INFO_CLASS = (WTSInitialProgram, WTSApplicationName, WTSWorkingDirectory,
    WTSOEMId, WTSSessionId, WTSUserName, WTSWinStationName, WTSDomainName,
    WTSConnectState, WTSClientBuildNumber, WTSClientName, WTSClientDirectory,
    WTSClientProductId, WTSClientHardwareId, WTSClientAddress, WTSClientDisplay,
    WTSClientProtocolType, WTSIdleTime, WTSLogonTime, WTSIncomingBytes,
    WTSOutgoingBytes, WTSIncomingFrames, WTSOutgoingFrames, WTSClientInfo,
    WTSSessionInfo);
{$EXTERNALSYM _WTS_INFO_CLASS}
  WTS_INFO_CLASS = _WTS_INFO_CLASS;
  TWtsInfoClass = WTS_INFO_CLASS;

const
  wtsapi = 'wtsapi32.dll';
  advapi32 = 'advapi32.dll';
  userenvlib = 'userenv.dll';

const
  TOKEN_ADJUST_SESSIONID = $0100;
{$EXTERNALSYM TOKEN_ADJUST_SESSIONID}
  SE_DEBUG_NAME = 'SeDebugPrivilege';
{$EXTERNALSYM SE_DEBUG_NAME}

type
  _TOKEN_INFORMATION_CLASS = (TokenInfoClassPad0, TokenUser, TokenGroups,
    TokenPrivileges, TokenOwner, TokenPrimaryGroup, TokenDefaultDacl,
    TokenSource, TokenType, TokenImpersonationLevel, TokenStatistics,
    TokenRestrictedSids, TokenSessionId, TokenGroupsAndPrivileges,
    TokenSessionReference, TokenSandBoxInert, TokenAuditPolicy, TokenOrigin);

  { kernel32 }
  TWTSGetActiveConsoleSessionId = function: DWORD; stdcall;
  TProcessIdToSessionId = function(dwProcessId: DWORD; var pSessionId: DWORD)
    : BOOL; stdcall;
  { wtsapi }
  TWTSQueryUserToken = function(SessionId: ULONG; var phToken: THANDLE)
    : BOOL; stdcall;
  { advpai32 }
  TSetTokenInformation = function(TokenHandle: THANDLE;
    TokenInformationClass: _TOKEN_INFORMATION_CLASS; TokenInformation: Pointer;
    TokenInformationLength: DWORD): BOOL; stdcall;
  TAdjustTokenPrivileges = function(TokenHandle: THANDLE;
    DisableAllPrivileges: BOOL; NewState: Pointer; BufferLength: DWORD;
    PreviousState: Pointer; ReturnLength: LPDWORD): BOOL; stdcall;
  { userenvlib }
  TCreateEnvironmentBlock = function(lpEnvironment: Pointer; hToken: THANDLE;
    bInherit: BOOL): BOOL; stdcall;
  TWTSSendMessageA = function(hServer: THANDLE; SessionId: DWORD; pTitle: LPSTR;
    TitleLength: DWORD; pMessage: LPSTR; MessageLength: DWORD; Style: DWORD;
    Timeout: DWORD; var pResponse: DWORD; bWait: BOOL): BOOL; stdcall;

  TWTSQuerySessionInformationA = function(hServer: Windows.THANDLE;
    SessionId: DWORD; WTSInfoClass: DWORD; var ppBuffer: Pointer;
    var pBytesReturned: DWORD): BOOL; stdcall;

  TWTSOpenServerA = function(pServerName: LPSTR): THANDLE; stdcall;
  TWTSCloseServer = procedure(hServer: THANDLE); stdcall;

  TWTSFreeMemory = procedure(pMemory: Pointer); stdcall;

var
  LogAddon: String= '';
  // Call "SwitchToActiveDesktop" periodically? 
  // (required when running as a Service)
  AutoDesktopSwitch: Boolean=True;

var
  WTSGetActiveConsoleSessionId: TWTSGetActiveConsoleSessionId = nil;
  ProcessIdToSessionId: TProcessIdToSessionId = nil;
  WTSQueryUserToken: TWTSQueryUserToken = nil;
  SetTokenInformation: TSetTokenInformation = nil;
  AdjustTokenPrivileges: TAdjustTokenPrivileges = nil;
  CreateEnvironmentBlock: TCreateEnvironmentBlock = nil;
  WTSSendMessageA: TWTSSendMessageA = nil;
  WTSQuerySessionInformationB: TWTSQuerySessionInformationA = nil;
  WTSFreeMemory: TWTSFreeMemory = nil;
  WTSOpenServerA: TWTSOpenServerA = nil;
  WTSCloseServer: TWTSCloseServer = nil;

procedure SwitchToActiveDesktop;

function GetWTSString(SessionId: Cardinal; wtsInfo: _WTS_INFO_CLASS): String;
function GetCurrentUserName: String;

function rtcKillProcess(strProcess: String): Integer;
function rtcGetProcessID(strProcess: String;
  OnlyActiveSession: boolean = False): DWORD;

function rtcStartProcess(strProcess: String; out piOut: PProcessInformation): DWORD; overload;
function rtcStartProcess(strProcess: String): DWORD; overload;

function InitProcLibs: boolean;

implementation

uses
  rtcScrUtils;

var
  LibsLoaded: Integer = 0;

type
  EReportedException = class(Exception);

function APICheck(aBool: boolean; anOperation: String): boolean;
var
  anError: String;
begin
  if not aBool then
  begin
    anError := Format('Error in %s: %s',
      [anOperation, SysErrorMessage(GetLastError)]);
    SetLastError(0);
{$IFDEF ExtendLog}xLog(anError, LogAddon); {$ENDIF}
    raise EReportedException.create(anError);
  end
  else if GetLastError <> 0 then
{$IFDEF ExtendLog}xLog(Format('%s: %s', [anOperation, SysErrorMessage(GetLastError)]), LogAddon){$ENDIF};
  SetLastError(0);
  Result := true;
end;

function GetProcedureAddress(var P: Pointer;
  const ModuleName, ProcName: String): boolean;
var
  ModuleHandle: HMODULE;
begin
  if not Assigned(P) then
  begin
    ModuleHandle := GetModuleHandle(PChar(ModuleName));
    if ModuleHandle = 0 then
    begin
      SetLastError(0);
      ModuleHandle := LoadLibrary(PChar(ModuleName));
    end;
    if ModuleHandle <> 0 then
      P := Pointer(GetProcAddress(ModuleHandle, PChar(ProcName)));
    Result := Assigned(P);
  end
  else
    Result := true;
end;

function GetProc(var P: Pointer; ModuleName: String; ProcName: String): boolean;
begin
  Result := GetProcedureAddress(P, ModuleName, ProcName);
{$IFDEF ExtendLog}xLog(Format('GetProcAddress: %s.%s - %s', [ModuleName, ProcName, BoolToStr(Result, true)]), LogAddon); {$ENDIF}
end;

function InitProcLibs: boolean;
begin
{$IFDEF ExtendLog}xLog('InitProcLibs', LogAddon); {$ENDIF}
  if LibsLoaded > 0 then
    Result := true
  else if LibsLoaded < 0 then
    Result := False
  else
  begin
    LibsLoaded := -1;
    SetLastError(0);
    if GetProc(@ProcessIdToSessionId, kernel32, 'ProcessIdToSessionId') and
      GetProc(@SetTokenInformation, advapi32, 'SetTokenInformation') and
      GetProc(@AdjustTokenPrivileges, advapi32, 'AdjustTokenPrivileges') and
      GetProc(@CreateEnvironmentBlock, userenvlib, 'CreateEnvironmentBlock')
    then
      LibsLoaded := 1;

    // these procs need to be checked before using and can be nil!!
    GetProc(@WTSGetActiveConsoleSessionId, kernel32,
      'WTSGetActiveConsoleSessionId');
    GetProc(@WTSQueryUserToken, wtsapi, 'WTSQueryUserToken');
    GetProc(@WTSSendMessageA, wtsapi, 'WTSSendMessageA');
    GetProc(@WTSFreeMemory, wtsapi, 'WTSFreeMemory');
    GetProc(@WTSOpenServerA, wtsapi, 'WTSOpenServerA');
    GetProc(@WTSCloseServer, wtsapi, 'WTSCloseServer');
    GetProc(@WTSQuerySessionInformationB, wtsapi,
      'WTSQuerySessionInformationA');

{$IFDEF ExtendLog}APICheck(LibsLoaded = 1, 'LibsLoaded'); {$ENDIF}
    Result := LibsLoaded = 1;
  end;
end;

function GetCurrentUserName: String;
var
  aDWord: DWORD;
begin
  aDWord := DWORD(-1);
  if InitProcLibs and Assigned(WTSOpenServerA) then
    Result := GetWTSString(aDWord, WTSUserName)
  else
    Result := String(Get_UserName);
end;

function rtcKillProcess(strProcess: String): Integer;
const
  PROCESS_TERMINATE = $0001;
var
  ContinueLoop: BOOL;
  FSnapshotHandle: THANDLE;
  procEntry: TProcessEntry32;
  myPID: Cardinal;
begin
{$IFDEF ExtendLog}xLog('rtcKillProcess', LogAddon); {$ENDIF}
  Result := 0;
  if not InitProcLibs then
    Exit;

  strProcess := UpperCase(ExtractFileName(strProcess));
  myPID := GetCurrentProcessId;

  FSnapshotHandle := CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0);
  try
    procEntry.dwSize := Sizeof(procEntry);
    ContinueLoop := Process32First(FSnapshotHandle, procEntry);
    while Integer(ContinueLoop) <> 0 do
    begin
      if (procEntry.th32ProcessID <> myPID) and
        ((UpperCase(procEntry.szExeFile) = strProcess) or
        (UpperCase(ExtractFileName(procEntry.szExeFile)) = strProcess)) then
        Result := Integer(TerminateProcess(OpenProcess(PROCESS_TERMINATE,
          BOOL(0), procEntry.th32ProcessID), 0));
      ContinueLoop := Process32Next(FSnapshotHandle, procEntry);
    end;
  finally
    CloseHandle(FSnapshotHandle);
  end;
end;

function ActiveSessionID: Cardinal;
begin
  if Assigned(WTSGetActiveConsoleSessionId) then
    Result := WTSGetActiveConsoleSessionId
  else
    Result := 0;
end;

function rtcGetProcessID(strProcess: String;
  OnlyActiveSession: boolean = False): DWORD;
var
  dwSessionId, winlogonSessId: DWORD;
  hsnap: THANDLE;
  procEntry: TProcessEntry32;
  myPID: Cardinal;
  aResult: DWORD;
begin
{$IFDEF ExtendLog}xLog('rtcGetProcessID', LogAddon); {$ENDIF}
  Result := 0;
  aResult := 0;

  try
    if not InitProcLibs then
      Exit;

    dwSessionId := ActiveSessionID;

{$IFDEF ExtendLog}xLog(Format('dwSessionId = %d', [dwSessionId]), LogAddon);
{$ENDIF}
    hsnap := CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0);
    if (hsnap = INVALID_HANDLE_VALUE) then
      Exit;
    try
      strProcess := UpperCase(ExtractFileName(strProcess));
      myPID := GetCurrentProcessId;

{$IFDEF ExtendLog}xLog(Format('strProcess = %s', [strProcess]), LogAddon);
{$ENDIF}
      procEntry.dwSize := Sizeof(TProcessEntry32);
      if (not Process32First(hsnap, procEntry)) then
      begin
        Exit;
      end;

      repeat
        if (procEntry.th32ProcessID <> myPID) and
          ((UpperCase(procEntry.szExeFile) = strProcess) or
          (UpperCase(ExtractFileName(procEntry.szExeFile)) = strProcess)) then
        begin
          winlogonSessId := 0;
          aResult := procEntry.th32ProcessID;
{$IFDEF ExtendLog}xLog(Format('OnlyActiveSession = %s', [BoolToStr(OnlyActiveSession, true)]), LogAddon); {$ENDIF}
          if not OnlyActiveSession then
          begin
{$IFDEF ExtendLog}xLog(Format('Result = %d', [Result]), LogAddon);
{$ENDIF}
            Result := procEntry.th32ProcessID;
            break;
          end
          else
          begin
            if ProcessIdToSessionId(procEntry.th32ProcessID, winlogonSessId)
            then
            begin
{$IFDEF ExtendLog}xLog(Format('winlogonSessId = %d', [winlogonSessId]), LogAddon); {$ENDIF}
              if (winlogonSessId = dwSessionId) then
              begin
                Result := procEntry.th32ProcessID;
{$IFDEF ExtendLog}xLog(Format('Result = %d', [Result]), LogAddon); {$ENDIF}
                break;
              end;
            end;
          end;
        end;
      until (not Process32Next(hsnap, procEntry));
      // fallback to using the process from another session if available
      if Result = 0 then
        Result := aResult;
    finally
      CloseHandle(hsnap);
    end;
  finally
    SetLastError(0);
  end;
end;

function get_winlogon_handle: THANDLE;
var
  hProcess: THANDLE;
  hTokenThis: THANDLE;
  ID: DWORD;
  id_session: THANDLE;
begin
  ID := rtcGetProcessID('winlogon.exe', true);
  id_session := ActiveSessionID;
  hProcess := OpenProcess(PROCESS_ALL_ACCESS, False, ID);
  if (hProcess > 0) then
  begin
    OpenProcessToken(hProcess, TOKEN_ASSIGN_PRIMARY or TOKEN_ALL_ACCESS,
      hTokenThis);
    DuplicateTokenEx(hTokenThis, TOKEN_ASSIGN_PRIMARY or TOKEN_ALL_ACCESS, nil,
      SecurityImpersonation, TokenPrimary, Result);
    SetTokenInformation(Result, TokenSessionId, @id_session, Sizeof(DWORD));
    CloseHandle(hTokenThis);
    CloseHandle(hProcess);
  end;
end;

function GetWTSString(SessionId: Cardinal; wtsInfo: WTS_INFO_CLASS): String;
var
  Ptr: Pointer;
  R: Cardinal;
  hSvr: THANDLE;
begin
  R := 0;
  Ptr := nil;
  hSvr := WTSOpenServerA(nil);
  try
    if WTSQuerySessionInformationB(0, SessionId, DWORD(wtsInfo), Ptr, R) and
      (R > 1) then
      Result := String(PAnsiChar(Ptr))
    else
    begin
      Result := String(Get_UserName);
    end;
    WTSFreeMemory(Ptr);
  finally
    if hSvr <> 0 then
      WTSCloseServer(hSvr);
  end;
end;

{$IFNDEF IDE_2009up}

type
  PTokenUser = ^TTokenUser;

  _TOKEN_USER = record
    User: TSIDAndAttributes;
  end;
{$EXTERNALSYM _TOKEN_USER}

  TTokenUser = _TOKEN_USER;
  TOKEN_USER = _TOKEN_USER;
{$EXTERNALSYM TOKEN_USER}
{$ENDIF}

function rtcStartProcess(strProcess: String;
  out piOut: PProcessInformation): DWORD;
var
  pi: TProcessInformation;
  si: STARTUPINFO;
  winlogonPid, dwSessionId: DWORD;
  hUserToken, hUserTokenDup, hPToken, hProcess: THANDLE;
  dwCreationFlags: DWORD;
  tp: TOKEN_PRIVILEGES;
  // lpEnv: Pointer;

begin
{$IFDEF ExtendLog}xLog('rtcStartProcess', LogAddon); {$ENDIF}
  { start process as elevated by cloning existing process, as we're running as admin... }
  Result := 0;
  try
    APICheck(InitProcLibs, 'InitProcLibs');

    hProcess := 0;
    hUserToken := 0;
    hUserTokenDup := 0;
    hPToken := 0;
    try
      winlogonPid := rtcGetProcessID('winlogon.exe', true);
      APICheck(winlogonPid > 0, 'rtcGetProcessID');

      { get user token for winlogon and duplicate it... (this gives us admin rights) }
      dwSessionId := 0;
      if (Win32MajorVersion >= 6 { vista\server 2k8 } ) then
      begin
        dwSessionId := ActiveSessionID;
        APICheck(dwSessionId > 0, 'WTSGetActiveConsoleSessionId');
      end;

      if not Assigned(WTSQueryUserToken) or not WTSQueryUserToken(dwSessionId,
        hUserToken) then
      begin
{$IFDEF ExtendLog}xLog('Fallback ...', LogAddon); {$ENDIF}
        hUserToken := get_winlogon_handle;
{$IFDEF ExtendLog}xLog(Format('Fallback result: %d', [hUserToken]), LogAddon); {$ENDIF}
      end
      else
{$IFDEF ExtendLog}xLog(Format('WTSQueryUserToken result: %d', [hUserToken]), LogAddon); {$ENDIF}
      APICheck(hUserToken <> 0, 'usertoken error');

      dwCreationFlags := NORMAL_PRIORITY_CLASS or CREATE_NEW_CONSOLE;
      ZeroMemory(@si, Sizeof(STARTUPINFO));
      si.cb := Sizeof(STARTUPINFO);
      si.lpDesktop := PChar('winsta0\default');
      ZeroMemory(@pi, Sizeof(pi));

      hProcess := OpenProcess(MAXIMUM_ALLOWED, False, winlogonPid);
      APICheck(hProcess > 0, 'OpenProcess');

      APICheck(OpenProcessToken(hProcess, TOKEN_ASSIGN_PRIMARY or
        TOKEN_ALL_ACCESS, hPToken), 'OpenProcessToken');
      APICheck(LookupPrivilegeValue(nil, SE_DEBUG_NAME, tp.Privileges[0].Luid),
        'LookupPrivilegeValue');

      tp.PrivilegeCount := 1;
      tp.Privileges[0].Attributes := SE_PRIVILEGE_ENABLED;
      APICheck(DuplicateTokenEx(hPToken, MAXIMUM_ALLOWED, nil,
        SecurityIdentification, TokenPrimary, hUserTokenDup),
        'DuplicateTokenEx');

      APICheck(SetTokenInformation(hUserTokenDup, TokenSessionId,
        Pointer(@dwSessionId), Sizeof(DWORD)), 'SetTokenInformation');
      APICheck(AdjustTokenPrivileges(hUserTokenDup, False, @tp,
        Sizeof(TOKEN_PRIVILEGES), nil, nil), 'AdjustTokenPrivileges');

      { lpEnv := nil;
        try           // causes RtlCreateEnvironmentEx exceptions in win7 64
        Log('hUserTokenDup = '+inttostr(hUserTokenDup));
        if APICheck(CreateEnvironmentBlock(lpEnv, hUserTokenDup, TRUE), 'CreateEnvironmentBlock') then
        dwCreationFlags := dwCreationFlags or CREATE_UNICODE_ENVIRONMENT; //or STARTF_USESHOWWINDOW
        except
        end; }

      { launch the process in the client's logon session... }
      si.wShowWindow := SW_HIDE;
      SetLastError(0);
{$IFDEF ExtendLog}xLog(Format('CreateProcessAsUser: %s', [strProcess]), LogAddon); {$ENDIF}
      APICheck(CreateProcessAsUser(hUserTokenDup, // client's access token
        nil, // file to execute
        PChar(strProcess), // command line (exe and parameters)
        nil, // pointer to process SECURITY_ATTRIBUTES
        nil, // pointer to thread SECURITY_ATTRIBUTES
        False, // handles are not inheritable
        dwCreationFlags, // creation flags
        nil, // pointer to new environment block
        PChar(ExtractFilePath(strProcess)), // name of current directory
        si, // pointer to STARTUPINFO structure
        pi) // receives information about new process
        , 'CreateProcessAsUser');
      try
        Result := pi.dwThreadId;
        if piOut <> nil then
          piOut^ := pi;
      finally
        if piOut = nil then
        begin
          CloseHandle(pi.hProcess);
          CloseHandle(pi.hThread);
        end;
      end;
    finally
      { perform all the close handles tasks... }
      if hProcess > 0 then
        CloseHandle(hProcess);
      if hUserToken > 0 then
        CloseHandle(hUserToken);
      if hUserTokenDup > 0 then
        CloseHandle(hUserTokenDup);
      if hPToken > 0 then
        CloseHandle(hPToken);
    end;
  except
    on e: Exception do
    begin
      if not(e is EReportedException) then
        xLog(Format('Error: %s', [e.Message]), LogAddon);
      // eat all other exceptions as we're running in a service
    end;
  end;
end;

function rtcStartProcess(strProcess: String):DWORD;
var piOut: PProcessInformation;
begin
  piOut:=nil;
  Result:=rtcStartProcess(strProcess,piOut);
end;

var
  CS: TCriticalSection;

  // Find the visible window station and switch to it
  // This would allow the service to be started non-interactive
  // Needs more supporting code & a redesign of the server core to
  // work, with better partitioning between server & UI components.

var
  home_window_station: HWINSTA;

function WinStationEnumProc(name: LPSTR; param: LPARAM): BOOL; stdcall;
var
  station: HWINSTA;
  oldstation: HWINSTA;
  flags: USEROBJECTFLAGS;
  tmp: Cardinal;
begin
  try
    station := OpenWindowStationA(name, False, GENERIC_ALL);
    oldstation := GetProcessWindowStation;
    tmp := 0;
    if not GetUserObjectInformationA(station, UOI_FLAGS, @flags,
      Sizeof(flags), tmp) then
      Result := True
    else
    begin
      if (flags.dwFlags and WSF_VISIBLE) <> 0 then
      begin
        if (SetProcessWindowStation(station)) then
        begin
          if (oldstation <> home_window_station) then
            CloseWindowStation(oldstation);
          Result := False; // success !!!
        end
        else
        begin
          CloseWindowStation(station);
          Result := True;
        end;
      end
      else
        Result := True;
    end;
  except
    Result := True;
  end;
end;

procedure SelectInputWinStation;
var
  flags: USEROBJECTFLAGS;
  tmp: Cardinal;
begin
  home_window_station := 0;
  try
    tmp := 0;
    home_window_station := GetProcessWindowStation;
    if not GetUserObjectInformationA(home_window_station, UOI_FLAGS, @flags,
      Sizeof(flags), tmp) or ((flags.dwFlags and WSF_VISIBLE) = 0) then
    begin
      if EnumWindowStations(@WinStationEnumProc, 0) then
        home_window_station := 0;
    end;
  except
    home_window_station := 0;
  end;
end;

procedure SelectHomeWinStation;
var
  station: HWINSTA;
begin
  if home_window_station <> 0 then
  begin
    station := GetProcessWindowStation();
    SetProcessWindowStation(home_window_station);
    CloseWindowStation(station);
  end;
end;

procedure SwitchToActiveDesktop;
var
  LogonDesktop, CurDesktop: HDESK;
begin
  if not AutoDesktopSwitch then Exit;

  CS.Acquire;
  try
    SelectInputWinStation;

    LogonDesktop := OpenInputDesktop(DF_ALLOWOTHERACCOUNTHOOK, False,
      DESKTOP_ALL);
    CurDesktop := GetThreadDesktop(GetCurrentThreadID);

    if (LogonDesktop <> 0) and (LogonDesktop <> CurDesktop) then
    begin
      SetThreadDesktop(LogonDesktop);
      CloseDesktop(CurDesktop);
    end;
  finally
    CS.Release;
  end;
end;

initialization

LogAddon := 'Logon';
CS := TCriticalSection.Create;
SelectInputWinStation;

finalization

SelectHomeWinStation;
FreeAndNil(CS);
LogAddon := '';

end.
