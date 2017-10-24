{ Copyright (c) Danijel Tkalcec,
  RealThinClient components - http://www.realthinclient.com }

unit RtcHostSvc;

interface
                     
{$INCLUDE rtcDefs.inc}

uses
  Windows, Messages, SysUtils, Classes,
  Graphics, Controls, SvcMgr, Dialogs, ExtCtrls,

  rtcLog, rtcInfo, rtcCrypt,
  rtcThrPool, rtcSystem,

  rtcpDesktopHost, rtcpChat, rtcpFileTrans,
  rtcPortalHttpCli, rtcPortalMod, rtcPortalCli,

  rdDesktopSave,

  rtcScrUtils, rtcWinLogon,
  rtcpDesktopControl;

const
  RTC_HOSTSERVICE_NAME='Rtc_HostService';

type
  TRtc_HostService = class(TService)
    PClient: TRtcHttpPortalClient;
    PFileTrans: TRtcPFileTransfer;
    PChat: TRtcPChat;
    PDesktop: TRtcPDesktopHost;
    timCheckProcess: TTimer;
    PDesktopControl: TRtcPDesktopControl;
    timCheckSvc: TTimer;

    procedure ServiceShutdown(Sender: TService);
    procedure ServiceStart(Sender: TService; var Started: Boolean);
    procedure ServiceStop(Sender: TService; var Stopped: Boolean);
    procedure ServiceDestroy(Sender: TObject);

    procedure PClientError(Sender: TAbsPortalClient; const Msg:string);
    procedure PClientFatalError(Sender: TAbsPortalClient; const Msg:string);
    procedure PClientLogIn(Sender: TAbsPortalClient);
    procedure PClientLogOut(Sender: TAbsPortalClient);
    procedure PClientStart(Sender: TAbsPortalClient; Data: TRtcValue);
    procedure PClientParams(Sender: TAbsPortalClient; Data: TRtcValue);

    procedure PFileTransUserJoined(Sender: TRtcPModule; const user:string);
    procedure PFileTransUserLeft(Sender: TRtcPModule; const user:string);
    procedure PChatUserJoined(Sender: TRtcPModule; const user:string);
    procedure PChatUserLeft(Sender: TRtcPModule; const user:string);
    procedure PDesktopUserJoined(Sender: TRtcPModule; const user:string);
    procedure PDesktopUserLeft(Sender: TRtcPModule; const user:string);
    procedure PFileTrans_FileRecvStart(Sender: TRtcPFileTransfer; const user, filename, path: String; const size: Int64);
    procedure PFileTrans_FileSendStart(Sender: TRtcPFileTransfer; const user, filename, path: String; const size: Int64);
    procedure timCheckProcessTimer(Sender: TObject);
    procedure PDesktopControlNewUI(Sender: TRtcPDesktopControl; const user: String);
    procedure ServiceCreate(Sender: TObject);
    procedure timCheckSvcTimer(Sender: TObject);

  private
    { Private declarations }
  public
    { Public declarations }
    Running:boolean;
    Stopping:boolean;
    WaitLoopCount:integer;
    WasRunning:boolean;
    MyPriority:integer;

    procedure UpdateMyPriority;

    function GetServiceController:
      {$IFDEF VER120} PServiceController;
      {$ELSE} TServiceController; {$ENDIF} override;

    procedure StartMyService;
    procedure StopMyService;

    procedure LoadSetup;
  end;

var
  Rtc_HostService: TRtc_HostService;

implementation

{$R *.DFM}

procedure ServiceController(CtrlCode: DWord); stdcall;
  begin
  Rtc_HostService.Controller(CtrlCode);
  end;

procedure TRtc_HostService.ServiceCreate(Sender: TObject);
  begin
  if (Win32MajorVersion >= 6 { vista\server 2k8 } ) then
    Interactive:=False;
  end;

function TRtc_HostService.GetServiceController: {$IFDEF VER120} PServiceController; {$ELSE} TServiceController; {$ENDIF}
  begin
  Result := {$IFDEF VER120}@{$ENDIF}ServiceController;
  end;

procedure TRtc_HostService.UpdateMyPriority;
  var
    hProcess:Cardinal;
  begin
  if MyPriority>=0 then 
	begin
    hProcess:=GetCurrentProcess;
    case MyPriority of
      0:SetPriorityClass(hProcess, HIGH_PRIORITY_CLASS);
      1:SetPriorityClass(hProcess, NORMAL_PRIORITY_CLASS);
      2:SetPriorityClass(hProcess, IDLE_PRIORITY_CLASS);
      end;
    end;
  end;

procedure TRtc_HostService.ServiceStart(Sender: TService; var Started: Boolean);
  var
    s:RtcString;
  begin
  Stopping:=False;
  if (Win32MajorVersion >= 6 { vista\server 2k8 } ) then
    begin
    WasRunning:=False;
    WaitLoopCount:=0;
    if File_Exists(ChangeFileExt(AppFileName,'.run')) then
      begin
      s:=Read_File(ChangeFileExt(AppFileName,'.run'));
      rtcStartProcess(AppFileName+String(s));
      Delete_File(ChangeFileExt(AppFileName,'.run'));
      Started:=False;
      end
    else
      begin
      xLog('');
      xLog('--------------------------');
      xLog('Host Launcher started.');
      timCheckProcess.Interval:=100;
      timCheckProcess.Enabled:=True;
      Started:=True;
      end;
    end
  else
    begin
    StartMyService;
    Started:=Running;
    end;
  end;

procedure TRtc_HostService.ServiceStop(Sender: TService; var Stopped: Boolean);
  var
    cnt:integer;
  begin
  Stopping:=True;
  if (Win32MajorVersion >= 6 { vista\server 2k8 } ) then
    begin
    timCheckProcess.Enabled:=False;
    if WasRunning or (rtcGetProcessID(AppFileName,True)>0) then
      begin
      xLog('Logging on to the Gateway to force the Host process to close.');
      LoadSetup;
      PClient.GParamsLoaded:=True; // this will force all other Hosts to close
      cnt:=100;
      repeat
        Dec(cnt);
        Sleep(100);
        until PClient.GParamsLoaded or (cnt<=0);
      PClient.Active:=False;
      PClient.Stop;
      end;
    xLog('Host Launcher stopped.');
    Stopped:=True;
    end
  else
    begin
    StopMyService;
    Stopped:=not Running;
    end;
  end;

procedure TRtc_HostService.ServiceShutdown(Sender: TService);
  var
    cnt:integer;
  begin
  Stopping:=True;
  if (Win32MajorVersion >= 6 { vista\server 2k8 } ) then
    begin
    timCheckProcess.Enabled:=False;
    if WasRunning or (rtcGetProcessID(AppFileName,True)>0) then
      begin
      xLog('Logging on to the Gateway to force the Host process to close.');
      LoadSetup;
      PClient.GParamsLoaded:=True; // this will force all other Hosts to close
      cnt:=100;
      repeat
        Dec(cnt);
        Sleep(100);
        until PClient.GParamsLoaded or (cnt<=0);
      PClient.Active:=False;
      PClient.Stop;
      end;
    xLog('Host Launcher shut down.');
    end
  else
    StopMyService;
  end;

procedure TRtc_HostService.ServiceDestroy(Sender: TObject);
  begin
  Stopping:=True;
  if (Win32MajorVersion >= 6 { vista\server 2k8 } ) then
    begin
    timCheckProcess.Enabled:=False;
    if WasRunning then
      xLog('Host Launcher destroyed.');
    end
  else
    StopMyService;
  end;

{ RTC Host Launcher implementation for Windows Vista ... }

procedure TRtc_HostService.timCheckProcessTimer(Sender: TObject);
  var
    iProcessID: DWORD;
  begin
  { check if RTC Host process exists, start it if it does not exist. }
  timCheckProcess.Enabled:=False;
  try
    iProcessID := rtcGetProcessID(AppFileName,True);
    if iProcessID = 0 then
      begin
      if WasRunning then
        begin
        xLog('Host was closed, wait for Windows Explorer to close.');
        WasRunning:=False;
        WaitLoopCount:=25;
        if rtcGetProcessID('explorer.exe')<=0 then
          begin
          WaitLoopCount:=0;
          timCheckProcess.Interval:=10000;
          end
        else
          timCheckProcess.Interval:=1000;
        timCheckProcess.Enabled:=True;
        end
      else if WaitLoopCount>0 then
        begin
        Dec(WaitLoopCount);
        if rtcGetProcessID('explorer.exe')<=0 then
          begin
          WaitLoopCount:=0;
          timCheckProcess.Interval:=10000;
          end
        else
          timCheckProcess.Interval:=1000;
        timCheckProcess.Enabled:=True;
        end
      else if rtcGetProcessID('winlogon.exe')<=0 then
        begin
        xLog('Waiting for WinLogon ...');
        timCheckProcess.Interval:=1000;
        timCheckProcess.Enabled:=True;
        end
      else
        begin
        xLog('STARTING a new HOST instance ...');
        rtcStartProcess(AppFileName+' -autorun -silent');
        timCheckProcess.Interval:=5000;
        timCheckProcess.Enabled:=True;
        end;
      end
    else
      begin
      if not WasRunning then
        begin
        xLog('HOST instance is running.');
        WasRunning:=True;
        end;
      if File_Exists(ChangeFileExt(AppFileName,'.cad')) then
        begin
        xLog('Processing <Ctrl-Alt-Del>');
        Delete_File(ChangeFileExt(AppFileName,'.cad'));
        Post_CtrlAltDel(True);
        end;
      timCheckProcess.Interval:=2000;
      timCheckProcess.Enabled:=True;
      end;
  except
    on E:Exception do
      begin
      xLog('ERROR: '+E.ClassName+' - '+E.Message);
      timCheckProcess.Interval:=2000;
      timCheckProcess.Enabled:=True;
      end;
    end;
  end;

{ Normal RTC Host Service implementation ... }

procedure TRtc_HostService.StartMyService;
  begin
  if not running then
    begin
    StartLog;
    try
      LOG_THREAD_EXCEPTIONS:=True;
      LOG_EXCEPTIONS:=True;

      { We will set all our background Threads to a higher priority,
        so we can get enough CPU time even when there are applications
        with higher priority running at 100% CPU time. }
      RTC_THREAD_PRIORITY:=tpHigher;

      xLog('CREATING HOST MODULES ...');

      LoadSetup;
      UpdateMyPriority;

      xLog('MAKING FIRST LOGIN ATTEMPT ...');

      PClient.Active:=True;

      running := True;
    except
      on E:Exception do
        Log('Error '+E.ClassName+': '+E.Message);
      end;
    end;
  end;

procedure TRtc_HostService.StopMyService;
  begin
  if running then
    begin
    try
      PClient.Active:=False;
    except
      end;
    try
      PClient.Stop;
    except
      end;
    running := False;
    end;
  end;

procedure TRtc_HostService.LoadSetup;
  var
    CfgFileName:String;
    s:RtcString;
    s2:RtcByteArray;
    info:TRtcRecord;
    len:int64;
    len2:longint;
  begin
  s2:=nil;
  
  PFileTrans.FileInboxPath:= ExtractFilePath(AppFileName)+'INBOX';
  xLog('Set INBOX Path = '+PFileTrans.FileInboxPath);

  CfgFileName:= ChangeFileExt(AppFileName,'.inf');
  xLog('Loading Settings from file "'+CfgFileName+'" ...');

  len:=File_Size(CfgFileName);
  if len>5 then
    begin
    s:=Read_File(CfgFileName,len-5,5);
    if s='@RTC@' then
      begin
      s2:=Read_FileEx(CfgFileName,len-4-5,4);
      Move(s2[0],len2,4);
      if (len2=len-4-5) then
        begin
        s := Read_File(CfgFileName,len-4-5-len2,len2,rtc_ShareDenyNone);
        DeCrypt(s, 'RTC Host 2.0');
        try
          info:=TRtcRecord.FromCode(s);
        except
          info:=nil;
          end;
        if assigned(info) then
          begin
          try
            xLog('Gateway Address = '+info.asString['Address']);
            PClient.GateAddr:=info.asString['Address'];

            xLog('Gateway Port = '+info.asString['Port']);
            PClient.GatePort:=info.asString['Port'];

            PClient.Gate_Proxy:=info.asBoolean['Proxy'];
            PClient.Gate_WinHttp:=info.asBoolean['WinHTTP'];
            PClient.Gate_ProxyAddr:=info.asString['ProxyAddr'];
            PClient.Gate_ProxyUserName:=info.asString['ProxyUsername'];
            PClient.Gate_ProxyPassword:=info.asString['ProxyPassword'];

            if info.asBoolean['Proxy'] or info.asBoolean['WinHTTP'] then
              begin
              if PClient.Gate_WinHttp or (PClient.Gate_ProxyAddr<>'') then
                xLog('Using WinHTTP to work with Proxy')
              else
                xLog('Using WinInet to work with Proxy');
              xLog('Proxy URL = '+PClient.Gate_ProxyAddr);
              xLog('Proxy Username = '+PClient.Gate_ProxyUserName);
              if PClient.Gate_ProxyPassword<>'' then
                xLog('Proxy Password = *****')
              else
                xLog('Proxy Password =');
              end;

            if info.asBoolean['SSL'] then
              xLog('Using SSL');
            PClient.Gate_SSL:=info.asBoolean['SSL'];

            if info.asString['DLL']<>'' then
              xLog('DLL Path = '+info.asString['DLL']);
            PClient.Gate_ISAPI:=info.asString['DLL'];

            if not info.isNull['Compress'] then
              PClient.DataCompress:=TRtcpCompressLevel(info.asInteger['Compress']);

            if info.asString['SecureKey']<>'' then
              xLog('Using Secure Key');
            PClient.DataSecureKey:=info.asString['SecureKey'];

            xLog('Username = '+info.asString['Username']);
            PClient.LoginUsername:=info.asText['UserName'];

            if info.asText['Password']<>'' then
              xLog('Using Password')
            else
              xLog('No Password');
            PClient.LoginPassword:=info.asText['Password'];

            { We can assign the complete "CustomInfo" record to "LoginUserInfo",
              so we don't have to copy user entry fields one-by-one ... }
            PClient.LoginUserInfo:=info.asRecord['CustomInfo'];

            { If you have dynamic data (like Time of the Day, or IP address)
              which you also want to send as custom user info to the Gateway,
              you can do it here, for example like this:

            PClient.LoginUserInfo.asDateTime['LocalTime']:=Now; }

            if not info.isNull['Priority'] then
              MyPriority:=info.asInteger['Priority']
            else
              MyPriority:=-1;

            xLog('... end of Host Settings.');
          finally
            info.Free;
            end;
          end;
        end;
      end;
    end;

  end;

procedure TRtc_HostService.PClientError(Sender: TAbsPortalClient; const Msg:string);
  begin
  if not Stopping then
    begin
    xLog('ERROR: '+Msg);
    xLog('Disconnecting ...');
    try
      PClient.Active:=False;
    except
      end;
    try
      PClient.Disconnect;
    except
      end;
    xLog('STARTING A NEW LOGIN ATTEMPT in 5 seconds ...');

    timCheckSvc.Enabled:=True;
    end;
  end;

procedure TRtc_HostService.timCheckSvcTimer(Sender: TObject);
  begin
  timCheckSvc.Enabled:=False;

  xLog('PREPARING A NEW LOGIN ATTEMPT ...');

  try
    PClient.Active:=False;
  except
    end;
  try
    PClient.Stop;
  except
    end;

  LoadSetup;
  UpdateMyPriority;

  xLog('MAKING A NEW LOGIN ATTEMPT ...');
  PClient.Active:=True;
  end;

procedure TRtc_HostService.PClientFatalError(Sender: TAbsPortalClient; const Msg:string);
  begin
  xLog('FATAL ERROR: '+Msg);
  xLog('HOST IS NOT CONNECTED ANYMORE.');
  PClient.Disconnect;
  end;

procedure TRtc_HostService.PClientLogIn(Sender: TAbsPortalClient);
  begin
  xLog('LOGGED IN.');
  end;

procedure TRtc_HostService.PClientLogOut(Sender: TAbsPortalClient);
  begin
  xLog('LOGGED OUT.');
  xLog('HOST IS NOT ACCESSIBLE ANYMORE.');
  end;

procedure TRtc_HostService.PClientStart(Sender: TAbsPortalClient; Data: TRtcValue);
  begin
  xLog('HOST READY.');
  end;

procedure TRtc_HostService.PClientParams(Sender: TAbsPortalClient; Data: TRtcValue);
  begin
  xLog('STARTING HOST ...');
  if not PDesktop.GFullScreen then
    PDesktop.GFullScreen:=True;
  end;

procedure TRtc_HostService.PFileTransUserJoined(Sender: TRtcPModule; const user:string);
  begin
  xLog('FILE session Open: '+user);
  end;

procedure TRtc_HostService.PFileTransUserLeft(Sender: TRtcPModule; const user:string);
  begin
  xLog('FILE session Close: '+user);
  end;

procedure TRtc_HostService.PChatUserJoined(Sender: TRtcPModule; const user:string);
  begin
  xLog('CHAT session Open: '+user);
  end;

procedure TRtc_HostService.PChatUserLeft(Sender: TRtcPModule; const user:string);
  begin
  xLog('CHAT session Close: '+user);
  end;

procedure TRtc_HostService.PDesktopUserJoined(Sender: TRtcPModule; const user:string);
  begin
  xLog('DESKTOP session Open: '+user);
  end;

procedure TRtc_HostService.PDesktopUserLeft(Sender: TRtcPModule; const user:string);
  begin
  xLog('DESKTOP session Close: '+user);
  end;

procedure TRtc_HostService.PFileTrans_FileRecvStart(Sender: TRtcPFileTransfer; const user, filename, path: String; const size: Int64);
  begin
  xLog('Receiving FILE(s) from user '+user+': file ='+filename+'; path = '+path+'; size ='+IntToStr(size));
  end;

procedure TRtc_HostService.PFileTrans_FileSendStart(Sender: TRtcPFileTransfer; const user, filename, path: String; const size: Int64);
  begin
  xLog('Sending FILE(s) to user '+user+': file ='+filename+'; path ='+path+'; size ='+IntToStr(size));
  end;

procedure TRtc_HostService.PDesktopControlNewUI(Sender: TRtcPDesktopControl; const user: String);
  var
    CDesk:TrdDesktopSaver;
  begin
  xLog('Receiving DESKTOP from user '+user);
  CDesk:=TrdDesktopSaver.Create(nil);
  if assigned(CDesk) then
    begin
    CDesk.UI.UserName:=user;
    // Always set UI.Module *after* setting UI.UserName !!!
    CDesk.UI.Module:=Sender;
    end;
  end;

end.
