{ Copyright (c) RealThinClient components
  - http://www.realthinclient.com }     

unit RtcHostForm;

interface

{$INCLUDE rtcDefs.inc}

uses
  Windows, Messages, SysUtils,
  Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, ShellApi,
  ComCtrls, Registry,

{$IFDEF IDE_XE3up}
  UITypes,
{$ENDIF}

  rtcInfo, rtcLog, rtcCrypt, rtcFastStrings,
  rtcThrPool, rtcWinLogon,

  RtcHostSvc,

  rdFileTrans, rdChat, rtcScrUtils,

  dmSetRegion, rdSetClient, rdSetHost,
  rdDesktopView, rtcpDesktopControlUI, rtcpDesktopControl,

  rtcpDesktopHost, rtcpChat, rtcpFileTrans,
  rtcPortalHttpCli, rtcPortalMod, rtcPortalCli, jpeg, Buttons;

const
  WM_TASKBAREVENT = WM_USER + 1;
  WM_AUTORUN =      WM_USER + 2;
  WM_AUTOMINIMIZE = WM_USER + 3;
  WM_AUTOCLOSE =    WM_USER + 4;

type
  TMainForm = class(TForm)
    pTitlebar: TPanel;
    cTitleBar: TLabel;
    btnMinimize: TSpeedButton;
    btnClose: TSpeedButton;
    PClient: TRtcHttpPortalClient;
    PFileTrans: TRtcPFileTransfer;
    PChat: TRtcPChat;
    PDesktopHost: TRtcPDesktopHost;
    lblStatusPanel: TPanel;
    lblStatus: TLabel;
    Pages: TPageControl;
    Page_Setup: TTabSheet;
    Page_Hosting: TTabSheet;
    Label3: TLabel;
    Label4: TLabel;
    Label12: TLabel;
    btnLogin: TButton;
    eUserName: TEdit;
    ePassword: TEdit;
    xAdvanced: TCheckBox;
    xSavePassword: TCheckBox;
    xAutoConnect: TCheckBox;
    btnGateway: TSpeedButton;
    Panel1: TPanel;
    Label25: TLabel;
    Label2: TLabel;
    btnInstall: TSpeedButton;
    btnRun: TSpeedButton;
    btnStop: TSpeedButton;
    btnUninstall: TSpeedButton;
    Label9: TLabel;
    sStatus1: TShape;
    sStatus2: TShape;
    Label21: TLabel;
    btnLogout: TSpeedButton;
    eConnected: TListView;
    btnSettings: TSpeedButton;
    cPriority: TComboBox;
    pSendFiles: TPanel;
    Label16: TLabel;
    Panel2: TPanel;
    Label7: TLabel;
    Label11: TLabel;
    Image1: TImage;
    PDesktopControl: TRtcPDesktopControl;
    Label8: TLabel;
    Label5: TLabel;
    Label1: TLabel;
    eRealName: TEdit;
    btnSaveSetup: TSpeedButton;
    btnRestartService: TSpeedButton;

    procedure btnLoginClick(Sender: TObject);
    procedure btnLogOutClick(Sender: TObject);
    procedure RtcCopyrightClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure btnMinimizeClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure xAdvancedClick(Sender: TObject);

    { Private-Deklarationen }
    procedure WMTaskbarEvent(var Message: TMessage); message WM_TASKBAREVENT;
    procedure btnSettingsClick(Sender: TObject);
    procedure btnCloseClick(Sender: TObject);
    procedure pTitlebarMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure pTitlebarMouseMove(Sender: TObject; Shift: TShiftState; X,Y: Integer);
    procedure pTitlebarMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure cPriorityChange(Sender: TObject);
    procedure btnInstallClick(Sender: TObject);
    procedure btnUninstallClick(Sender: TObject);
    procedure btnRunClick(Sender: TObject);
    procedure btnStopClick(Sender: TObject);

    procedure PClientLogIn(Sender: TAbsPortalClient);
    procedure PClientParams(Sender: TAbsPortalClient; const Data: TRtcValue);
    procedure PClientStart(Sender: TAbsPortalClient; const Data: TRtcValue);
    procedure PClientLogOut(Sender: TAbsPortalClient);
    procedure PClientError(Sender: TAbsPortalClient; const Msg:string);
    procedure PClientFatalError(Sender: TAbsPortalClient; const Msg:string);

    procedure PFileTransNewUI(Sender: TRtcPFileTransfer; const user:string);
    procedure PChatNewUI(Sender: TRtcPChat; const user:string);

    procedure PModuleUserJoined(Sender: TRtcPModule; const user:string);
    procedure PModuleUserLeft(Sender: TRtcPModule; const user:string);

    procedure PClientStatusPut(Sender: TAbsPortalClient; Status: TRtcPHttpConnStatus);
    procedure PClientStatusGet(Sender: TAbsPortalClient; Status: TRtcPHttpConnStatus);

    procedure btnGatewayClick(Sender: TObject);
    procedure eUserNameChange(Sender: TObject);
    procedure ePasswordChange(Sender: TObject);
    procedure PDesktopControlNewUI(Sender: TRtcPDesktopControl;
      const user: String);
    procedure FormShow(Sender: TObject);
    procedure eRealNameChange(Sender: TObject);
    procedure btnSaveSetupClick(Sender: TObject);
    procedure btnRestartServiceClick(Sender: TObject);

  protected

    FAutoRun:boolean;
    DesktopCnt:integer;

    // declare our DROPFILES message handler
    procedure AcceptFiles( var msg : TMessage ); message WM_DROPFILES;

    procedure WmAutoRun(var Msg:TMessage); message WM_AUTORUN;
    procedure WmAutoMinimize(var Msg:TMessage); message WM_AUTOMINIMIZE;
    procedure WmAutoClose(var Msg:TMessage); message WM_AUTOCLOSE;

    procedure WMQueryEndSession(var Msg : TWMQueryEndSession); message WM_QueryEndSession;

    function CheckService(bServiceFilename: Boolean = True {False = Service Name} ): String;

  public
    { Public declarations }
    Options:TrdHostSettings;
    SilentMode:boolean;

    ReqCnt1,ReqCnt2:integer;
    TaskBarIcon:boolean;

    // Load and Save Window Positions
    function LoadWindowPosition(Form: TForm; FormName: String; sizeable:boolean=False):boolean;
    procedure SaveWindowPosition(Form: TForm; FormName: String; sizeable:boolean=False);

    procedure LoadSetup;
    procedure SaveSetup;

    procedure TaskBarAddIcon;
    procedure TaskBarRemoveIcon;
    end;

var
  MainForm: TMainForm;

implementation

{$R *.dfm}

(* Constructor and Destructor *)

procedure EliminateListViewBeep;
  var
    reg:TRegistry;
  begin
  reg:=TRegistry.Create;
  try
    reg.RootKey:=HKEY_CURRENT_USER;
    if reg.OpenKey('\AppEvents\Schemes\Apps\.Default\CCSelect\.current',False) then
    try
      if reg.ValueExists('') then
        if Trim(reg.ReadString(''))='' then
          reg.DeleteValue('');
    finally
      reg.CloseKey;
      end;
    if reg.OpenKey('\AppEvents\Schemes\Apps\.Default\CCSelect\.Modified',False) then
    try
      if reg.ValueExists('') then
        if Trim(reg.ReadString(''))='' then
          reg.DeleteValue('');
    finally
      reg.CloseKey;
      end;
  finally
    reg.Free;
    end;
  end;

procedure TMainForm.FormCreate(Sender: TObject);
  begin
  Options:=nil;

  // Eliminate annoying Vista BEEP bug when using ListView
  EliminateListViewBeep;

  Pages.ActivePage:=Page_Setup;
  Page_Hosting.TabVisible:=False;

  LOG_THREAD_EXCEPTIONS:=True;
  LOG_EXCEPTIONS:=True;

  { We will set all our background Threads to a higher priority,
    so we can get enough CPU time even when there are applications
    with higher priority running at 100% CPU. }
  RTC_THREAD_PRIORITY:=tpHigher;

  TaskBarIcon:=False;
  ReqCnt1:=0;
  ReqCnt2:=0;

  StartLog;

  PFileTrans.FileInboxPath:= ExtractFilePath(AppFileName)+'INBOX';

  Left:=(Screen.Width-Width) div 2;
  Top:=(Screen.Height-Height) div 2;

  LoadSetup;

  cPriorityChange(nil);

  eUserName.Text:=PClient.LoginUsername;
  ePassword.Text:=PClient.LoginPassword;
  // Custom User Info (can be anything you want/need)
  eRealName.Text:=PClient.LoginUserInfo.asText['RealName'];

  SilentMode:=pos('-SILENT',uppercase(CmdLine)) > 0;

  if SilentMode then
    begin
    Left:=0;
    Top:=0;
    Width:=1;
    Height:=1;
    end;

  If pos('-AUTORUN',uppercase(CmdLine)) > 0 Then
    PostMessage(Handle,WM_AUTORUN,0,0);
  end;

procedure TMainForm.FormDestroy(Sender: TObject);
  begin
  xAutoConnect.Checked:=False;
  PClient.Active:=False;
  PClient.Stop;
  end;

(* Load/Save Configuration *)

procedure TMainForm.LoadSetup;
  var
    CfgFileName:String;
    s:RtcString;
    s2:RtcByteArray;
    info:TRtcRecord;
    len:int64;
    len2:longint;
  begin
  s2:=nil;

  CfgFileName:= ChangeFileExt(AppFileName,'.inf');
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
            PClient.GateAddr:=info.asString['Address'];
            PClient.GatePort:=info.asString['Port'];
            PClient.Gate_Proxy:=info.asBoolean['Proxy'];
            PClient.Gate_WinHttp:=info.asBoolean['WinHTTP'];
            PClient.Gate_SSL:=info.asBoolean['SSL'];
            PClient.Gate_ISAPI:=info.asString['DLL'];
            PClient.DataSecureKey:=info.asString['SecureKey'];
            PClient.DataCompress:=TRtcpCompressLevel(info.asInteger['Compress']);

            PClient.Gate_ProxyAddr:=info.asString['ProxyAddr'];
            PClient.Gate_ProxyUserName:=info.asString['ProxyUsername'];
            PClient.Gate_ProxyPassword:=info.asString['ProxyPassword'];

            PClient.LoginUsername:=info.asText['UserName'];
            PClient.LoginPassword:=info.asText['Password'];
            { We can simply replace all data from "LoginUserInfo" with "CustomInfo",
              because this is where we have saved it. }
            PClient.LoginUserInfo:=info.asRecord['CustomInfo'];

            xSavePassword.Checked:=info.asBoolean['SavePassword'];
            xAutoConnect.Checked:=info.asBoolean['AutoConnect'];

            if (PClient.GateAddr='') or (PClient.GatePort='') then
              btnGateway.Caption:='< Click to set up connection >'
            else
              btnGateway.Caption:=String(PClient.GateAddr+':'+PClient.GatePort);

            if not info.isNull['Priority'] then
              cPriority.ItemIndex:=info.asInteger['Priority'];

          finally
            info.Free;
            end;
          end;
        end;
      end;
    end;

  // Load Window Position
  LoadWindowPosition(Self, 'MainForm');
  end;

procedure TMainForm.SaveSetup;
  var
    CfgFileName:String;
    infos:RtcString;
    s2:RtcByteArray;
    info:TRtcRecord;
    len2:longint;
  begin
  if SilentMode then Exit;

  info:=TRtcRecord.Create;
  try
    info.asString['Address']:= PClient.GateAddr;
    info.asString['Port']:= PClient.GatePort;
    info.asBoolean['Proxy']:= PClient.Gate_Proxy;
    info.asBoolean['WinHTTP']:= PClient.Gate_WinHttp;
    info.asBoolean['SSL']:= PClient.Gate_SSL;
    info.asString['DLL']:= PClient.Gate_ISAPI;

    info.asString['ProxyAddr']:=PClient.Gate_ProxyAddr;
    info.asString['ProxyPassword']:=PClient.Gate_ProxyPassword;
    info.asString['ProxyUsername']:=PClient.Gate_ProxyUserName;

    info.asString['SecureKey']:=PClient.DataSecureKey;
    info.asInteger['Compress']:=Ord(PClient.DataCompress);

    info.asText['UserName']:=PClient.LoginUsername;
    if xSavePassword.Checked then
      begin
      info.asText['Password']:=PClient.LoginPassword;
      info.asBoolean['SavePassword']:=True;
      end;
    // Assigns a copy of the complete "LoginUserInfo" record to "info",
    // so we don't have to copy every field/value individually.
    info.asRecord['CustomInfo']:=PClient.LoginUserInfo;

    info.asBoolean['AutoConnect']:=xAutoConnect.Checked;
    info.asInteger['Priority']:=cPriority.ItemIndex;

    infos:=info.toCode;
    Crypt(infos,'RTC Host 2.0');
  finally
    info.Free;
    end;

  CfgFileName:= ChangeFileExt(AppFileName,'.inf');
  SetLength(s2,4);
  len2:=length(infos);
  Move(len2,s2[0],4);
  infos:=infos+RtcBytesToString(s2)+'@RTC@';
  Write_File(CfgFileName,infos);
  end;

// Load Window Position procedure
function TMainForm.LoadWindowPosition(Form: TForm; FormName: String; sizeable:boolean=False):boolean;
  var
    CfgFileName:String;
    s:RtcString;
    info:TRtcRecord;
  Begin
  Result:=false;

  if SilentMode then Exit;

  CfgFileName:= ChangeFileExt(AppFileName,'.ini');
  s := Read_File(CfgFileName,rtc_ShareDenyNone);
  if s<>'' then
    begin
    try
      info:=TRtcRecord.FromCode(s);
    except
      info:=nil;
      end;
    if assigned(info) then
      begin
      try
        If info.isType[FormName]=rtc_Record then
          Begin
          with info.asRecord[FormName] do
            begin
            Form.Top := asInteger['Top'];
            Form.Left := asInteger['Left'];
            if sizeable then
              begin
              if not isNull['Width'] then
                Form.Width := asInteger['Width'];
              if not isNull['Height'] then
                Form.Height := asInteger['Height'];
              end;

            Result:=True;
            End;
          End;
      finally
        info.Free;
        end;
      end;
    end;
  End;

// Save Window Position procedure
procedure TMainForm.SaveWindowPosition(Form: TForm; FormName: String; sizeable:boolean);
  Var
    CfgFileName:String;
    s,infos:RtcString;
    info:TRtcRecord;
  Begin
  if SilentMode then Exit;

  // Read old values
  CfgFileName:= ChangeFileExt(AppFileName,'.ini');
  s := Read_File(CfgFileName,rtc_ShareDenyNone);
  if s='' then
    info:=TRtcRecord.Create
  else
    begin
    try
      info:=TRtcRecord.FromCode(s);
    except
      info:=TRtcRecord.Create;
      end;
    end;

  try
    If info.isNull[FormName] then
      info.NewRecord(FormName);

    with info.asRecord[FormName] do
      begin
      asInteger['Top'] := Form.Top;
      asInteger['Left']:= Form.Left;
      if sizeable then asInteger['Width']:= Form.Width else isNull['Width']:=True;
      if sizeable then asInteger['Height']:= Form.Height else isNull['Height']:=True;
      end;

    infos:=info.toCode;
  finally
    info.Free;
    end;

  Write_File(CfgFileName,infos);
  End;

(* Minimize and Close buttons *)

procedure TMainForm.btnMinimizeClick(Sender: TObject);
  begin
  TaskBarAddIcon;
  Application.Minimize;
  ShowWindow (Application.Handle, SW_HIDE);
  end;

procedure TMainForm.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
  begin
  if (Pages.ActivePage<>Page_Setup) and (eConnected.Items.Count>0) then
    begin
    if SilentMode then
      begin
      xAutoConnect.Checked:=False; // disable auto re-login
      btnLogOutClick(Sender);
      CanClose:=True;
      end
    else if MessageDlg('Are you sure you want to close the Host?'#13#10+
                       'There are users connected to this Host.'#13#10+
                       'Closing the Host will disconnect them all.',
                       mtWarning,[mbNo,mbYes],0)=mrYes then
      begin
      xAutoConnect.Checked:=False; // disable auto re-login
      btnLogoutClick(Sender);
      TaskBarRemoveIcon;
      CanClose:=True;
      end
    else
      CanClose:=False;
    end
  else
    begin
    xAutoConnect.Checked:=False; // disable auto re-login
    btnLogoutClick(Sender);
    TaskBarRemoveIcon;
    CanClose:=True;
    end;

  if CanClose then
    begin
    SaveWindowPosition(Self, 'MainForm', False);
    Show_Wallpaper;
    end;
  end;

(* Utility code *)

procedure TMainForm.AcceptFiles( var msg : TMessage );
  const
    cnMaxFileNameLen = 1024;
  var
    i,
    nCount     : integer;
    acFileName : array [0..cnMaxFileNameLen] of char;
    myFileName : string;
    UserName: string;
  begin
  if not PClient.Active then
    begin
    MessageBeep(0);
    Exit;
    end;

  UserName:=PDesktopHost.LastMouseUser;
  if UserName='' then Exit;

  // find out how many files we're accepting
  nCount := DragQueryFile( msg.WParam,
                           $FFFFFFFF,
                           acFileName,
                           cnMaxFileNameLen );

  try
    // query Windows one at a time for the file name
    for i := 0 to nCount-1 do
      begin
      DragQueryFile( msg.WParam, i, acFileName, cnMaxFileNameLen );

      myFileName:=acFileName;
      PFileTrans.Send(UserName, myFileName);
      end;
  finally
    // let Windows know that you're done
    DragFinish( msg.WParam );
    end;
  end;

procedure TMainForm.TaskBarAddIcon;
  var
    tnid: TNotifyIconData;
    xOwner: HWnd;
  begin
  if SilentMode then Exit;

  if not TaskBarIcon then
    begin
    with tnid do
      begin
      cbSize := System.SizeOf(TNotifyIconData);
      Wnd := self.Handle;
      uID := 1;
      uFlags := NIF_MESSAGE or NIF_ICON or NIF_TIP;
      uCallbackMessage := WM_TASKBAREVENT;
      hIcon := Application.Icon.Handle;
      end;
    StrCopy(tnid.szTip, 'RTC Host');
    Shell_NotifyIcon(NIM_ADD, @tnid);

    xOwner:=GetWindow(self.Handle,GW_OWNER);
    If xOwner<>0 Then
      ShowWindow(xOwner,SW_HIDE);

    TaskBarIcon:=True;
    end;
  end;

procedure TMainForm.TaskBarRemoveIcon;
  var
    tnid: TNotifyIconData;
    xOwner: HWnd;
  begin
  if TaskBarIcon then
    begin
    tnid.cbSize := SizeOf(TNotifyIconData);
    tnid.Wnd := self.Handle;
    tnid.uID := 1;
    Shell_NotifyIcon(NIM_DELETE, @tnid);
    xOwner:=GetWindow(self.Handle,GW_OWNER);
    If xOwner<>0 Then
      Begin
      ShowWindow(xOwner,SW_Show);
      ShowWindow(xOwner,SW_Normal);
      End;
    TaskBarIcon:=false;
    end;
  end;

procedure TMainForm.WMTaskbarEvent(var Message: TMessage);
  begin
  case Message.LParamLo of
    WM_LBUTTONUP,
    WM_RBUTTONUP:
          begin
          Application.Restore;
          Application.BringToFront;
          BringToFront;
          BringWindowToTop(Handle);
          TaskBarRemoveIcon;
          end;
    end;
  end;

(* Code for all the Buttons on our Form *)

procedure TMainForm.eUserNameChange(Sender: TObject);
  begin
  PClient.LoginUsername:=Trim(eUserName.Text);
  // Changing "LoginUserName" will clear all LoginUserInfo parameters,
  // so we should reflect this on the user interface as well ...
  eRealName.Text:='';
  end;

procedure TMainForm.ePasswordChange(Sender: TObject);
  begin
  PClient.LoginPassword:=Trim(ePassword.Text);
  end;

procedure TMainForm.btnLoginClick(Sender: TObject);
  begin
  if Sender<>nil then
    begin
    SaveSetup;

    if PClient.GateAddr='' then
      begin
      ShowMessage('Please, enter your Gateway''s Address.');
      btnGateway.Click;
      Exit;
      end;
    if PClient.GatePort='' then
      begin
      ShowMessage('Please, enter your Gateway''s Port.');
      btnGateway.Click;
      Exit;
      end;
    if PClient.LoginUsername='' then
      begin
      ShowMessage('Please, enter your Username and Password.');
      eUserName.SetFocus;
      Exit;
      end;

    lblStatus.Caption:='Preparing the connection ...';
    lblStatus.Update;

    btnLogin.Enabled:=False;

    PClient.Active:=False;
    // PClient.Stop;
    end
  else
    begin
    PClient.Disconnect;
    btnLogin.Enabled:=False;
    end;

  if Sender=nil then
    lblStatus.Caption:=lblStatus.Caption+#13#10+'Making a new Login attempt ...'
  else
    lblStatus.Caption:='Logging on to the Gateway ...';
  lblStatus.Update;

  ReqCnt1:=0;
  ReqCnt2:=0;

  if xAutoConnect.Checked then
    PClient.RetryOtherCalls:=10
  else
    PClient.RetryOtherCalls:=3;

  if xAdvanced.Checked then
    PClient.GParamsLoaded:=True
  else
    PClient.Active:=True;
  end;

procedure TMainForm.btnLogOutClick(Sender: TObject);
  begin
  if assigned(Options) and Options.Visible then
    Options.Close;

  xAutoConnect.Checked:=False;
  btnLogout.Enabled:=False;

  if PClient.Active then
    PClient.Active:=False
  else
    begin
    btnLogin.Enabled:=True;
    if Pages.ActivePage<>Page_Setup then
      begin
      Page_Setup.TabVisible:=True;
      Pages.ActivePage.TabVisible:=False;
      Pages.ActivePage:=Page_Setup;
      end;
    end;

  PClient.Stop;
  end;

procedure TMainForm.xAdvancedClick(Sender: TObject);
  begin
  if xAdvanced.Checked then
    begin
    btnLogin.Caption:='Settings';
    lblStatus.Caption:='Click "Settings" to change Host settings.';
    lblStatus.Update;
    btnLogin.Click;
    end
  else
    begin
    btnLogin.Caption:='START';
    lblStatus.Caption:='Click "START" to log in and start Hosting.';
    lblStatus.Update;
    end;
  end;

procedure TMainForm.btnSaveSetupClick(Sender: TObject);
  begin
  SaveSetup;
  end;

procedure TMainForm.btnSettingsClick(Sender: TObject);
  begin
  if not assigned(Options) then
    Options:=TrdHostSettings.Create(self);
  if assigned(Options) then
    begin
    Options.PClient:=PClient;
    Options.PDesktop:=PDesktopHost;
    Options.PChat:=PChat;
    Options.PFileTrans:=PFileTrans;
    Options.Execute;
    end;
  end;

procedure TMainForm.btnCloseClick(Sender: TObject);
  begin
  Close;
  end;

procedure TMainForm.cPriorityChange(Sender: TObject);
  var
    hProcess:Cardinal;
  begin
  hProcess:=GetCurrentProcess;
  case cPriority.ItemIndex of
    0:SetPriorityClass(hProcess, HIGH_PRIORITY_CLASS);
    1:SetPriorityClass(hProcess, NORMAL_PRIORITY_CLASS);
    2:SetPriorityClass(hProcess, IDLE_PRIORITY_CLASS);
    end;
  if Sender<>nil then
    SaveSetup;
  end;

(* Various "Windows Shell" commands *)

procedure TMainForm.RtcCopyrightClick(Sender: TObject);
  begin
  ShellExecute(handle, 'open', 'http://www.realthinclient.com',nil,nil,SW_SHOW);
  end;

function TMainForm.CheckService(bServiceFilename: Boolean = True {False = Service Name} ): String;
  begin
  if bServiceFilename then
    Result := AppFileName
  else
    Result := RTC_HOSTSERVICE_NAME;
  end;

procedure TMainForm.btnInstallClick(Sender: TObject);
  begin
  SaveSetup;
  ShellExecute(0,'open',PChar(CheckService),'/INSTALL',nil,SW_SHOW);
  end;

procedure TMainForm.btnUninstallClick(Sender: TObject);
  begin
  ShellExecute(0,'open',PChar(CheckService),'/UNINSTALL',nil,SW_SHOW);
  end;

procedure TMainForm.btnRestartServiceClick(Sender: TObject);
  begin
  ShellExecute(0,'open','net',PChar('stop '+CheckService(False)),nil,SW_SHOW);
  Sleep(5000); // Wait 5 Seconds for the Host Service to Stop
  SaveSetup;
  ShellExecute(0,'open','net',PChar('start '+CheckService(False)),nil,SW_SHOW);
  Sleep(5000); // Wait 5 Seconds for the Host Service to Start
  Close;
  end;

procedure TMainForm.btnRunClick(Sender: TObject);
  begin
  SaveSetup;
  ShellExecute(0,'open','net',PChar('start '+CheckService(False)),nil,SW_SHOW);
  end;

procedure TMainForm.btnStopClick(Sender: TObject);
  begin
  ShellExecute(0,'open','net',PChar('stop '+CheckService(False)),nil,SW_SHOW);
  end;

(* Moving the Window by clicking and dragging on the Top Panel *)

var
  LMouseX,LMouseY:integer;
  LMouseD:boolean=False;

procedure TMainForm.pTitlebarMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
  begin
  LMouseD:=True;
  LMouseX:=X;LMouseY:=Y;
  end;

procedure TMainForm.pTitlebarMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
  begin
  if LMouseD then
    SetBounds(Left+X-LMouseX,Top+Y-LMouseY,Width,Height);
  end;

procedure TMainForm.pTitlebarMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
  begin
  LMouseD:=False;
  end;

(* Implementation of events triggered by RTC Portal components *)

procedure TMainForm.WmAutoRun(var Msg: TMessage);
begin
  FAutoRun := TRUE;
  btnLogin.Click;
end;

procedure TMainForm.WmAutoMinimize(var Msg: TMessage);
begin
  If FAutoRun then
    begin
    FAutoRun := FALSE;
    btnMinimize.Click;
    end;
end;

procedure TMainForm.WmAutoClose(var Msg: TMessage);
  begin
  Close;
  end;

procedure TMainForm.PFileTransNewUI(Sender: TRtcPFileTransfer; const user:string);
  var
    FWin:TrdFileTransfer;
  begin
  FWin:=TrdFileTransfer.Create(nil);
  if assigned(FWin) then
    begin
    FWin.UI.UserName:=user;
    // Always set UI.Module *after* setting UI.UserName !!!
    FWin.UI.Module:=Sender;

    (*
    // Restore Window Position
    if not LoadWindowPosition(FWin,'FileTransForm-'+user) then
      LoadWindowPosition(FWin,'FileTransForm');
    *)

    FWin.Show;
    FWin.WindowState:=wsMinimized;
    end
  else
    raise Exception.Create('Error creating Window');
  end;

procedure TMainForm.PChatNewUI(Sender: TRtcPChat; const user:string);
  var
    CWin:TrdChatForm;
  begin
  CWin:=TrdChatForm.Create(nil);
  if assigned(CWin) then
    begin
    CWin.UI.UserName:=user;
    // Always set UI.Module *after* setting UI.UserName !!!
    CWin.UI.Module:=Sender;

    (*
    LoadWindowPosition(CWin,'ChatForm');
    *)
    
    CWin.Show;
    end
  else
    raise Exception.Create('Error creating Window');

  if CWin.WindowState=wsNormal then
    begin
    CWin.BringToFront;
    BringWindowToTop(CWin.Handle);
    end;
  end;

// Called after a successful login (not after LoadGatewayParams)
procedure TMainForm.PClientLogIn(Sender: TAbsPortalClient);
  begin
  if assigned(Options) and Options.Visible then
    Options.Close;

  DesktopCnt:=0;
  eConnected.Clear;
  btnLogout.Enabled:=True;

  DragAcceptFiles(Handle, False);
  pSendFiles.Visible:=False;

  lblStatus.Caption:='Logged in as "'+PClient.LoginUsername+'".';
  lblStatus.Update;

  if FAutoRun then
    PostMessage(Handle,WM_AUTOMINIMIZE,0,0);
  end;

procedure TMainForm.PClientParams(Sender: TAbsPortalClient; const Data: TRtcValue);
  begin
  if xAdvanced.Checked then
    begin
    xAdvanced.Checked:=False;
    if not assigned(Options) then
      Options:=TrdHostSettings.Create(self);
    if assigned(Options) then
      begin
      Options.PClient:=PClient;
      Options.PDesktop:=PDesktopHost;
      Options.PChat:=PChat;
      Options.PFileTrans:=PFileTrans;
      Options.Execute;
      btnLogin.Enabled:=True;
      end;
    end
  else
    begin
    if not PDesktopHost.GFullScreen and
        (PDesktopHost.ScreenRect.Right=PDesktopHost.ScreenRect.Left) then
      PDesktopHost.GFullScreen:=True;
    end;
  end;

procedure TMainForm.PClientStart(Sender: TAbsPortalClient; const Data: TRtcValue);
  begin
  if Pages.ActivePage<>Page_Hosting then
    begin
    Page_Hosting.TabVisible:=True;
    Pages.ActivePage.TabVisible:=False;
    Pages.ActivePage:=Page_Hosting;
    end;
  lblStatus.Caption:='Connected as Host "'+PClient.LoginUsername+'".';
  lblStatus.Update;

  cTitleBar.Refresh;
  btnMinimize.Refresh;
  btnClose.Refresh;
  end;

procedure TMainForm.PClientLogOut(Sender: TAbsPortalClient);
  begin
  if assigned(Options) and Options.Visible then
    Options.Close;

  if Pages.ActivePage<>Page_Setup then
    begin
    Page_Setup.TabVisible:=True;
    Pages.ActivePage.TabVisible:=False;
    Pages.ActivePage:=Page_Setup;
    end;

  btnLogin.Enabled:=True;
  lblStatus.Caption:='Logged out. Click "'+btnLogin.Caption+'" to connect again.';
  lblStatus.Update;

  if SilentMode then
    PostMessage(Handle,WM_AUTOCLOSE,0,0);
  end;

procedure TMainForm.PClientFatalError(Sender: TAbsPortalClient; const Msg:string);
  begin
  if assigned(Options) and Options.Visible then
    Options.Close;

  PClient.Disconnect;

  if Pages.ActivePage<>Page_Setup then
    begin
    Page_Setup.TabVisible:=True;
    Pages.ActivePage.TabVisible:=False;
    Pages.ActivePage:=Page_Setup;
    end;

  btnLogin.Enabled:=True;
  lblStatus.Caption:=Msg;
  lblStatus.Update;

  if SilentMode then
    PostMessage(Handle,WM_AUTOCLOSE,0,0)
  else
    MessageBeep(0);
  end;

procedure TMainForm.PClientError(Sender: TAbsPortalClient; const Msg:string);
  begin
  if assigned(Options) and Options.Visible then
    Options.Close;

  PClientFatalError(Sender,Msg);

  // The difference between "OnError" and "OnFatalError" is
  // that "OnError" will make a reconnect if "Re-Login" was checked,
  // while "OnFatalError" simply closes all connections and stops.
  if SilentMode then
    PostMessage(Handle,WM_AUTOCLOSE,0,0)
  else if xAutoConnect.Checked then
    PClient.Active:=True;
  end;

procedure TMainForm.PModuleUserJoined(Sender: TRtcPModule; const user:string);
  var
    s:string;
    el:TListItem;
    uinfo:TRtcRecord;
  begin
  if Sender is TRtcPFileTransfer then
    s:='Files'
  else if Sender is TRtcPChat then
    s:='Chat'
  else if Sender is TRtcPDesktopHost then
    begin
    s:='Desktop';
    Inc(DesktopCnt);
    if DesktopCnt=1 then
      begin
      pSendFiles.Visible:=True;
      DragAcceptFiles(Handle, True);
      end;
    end
  else s:='???';

{ You can retrieve custom user information about 
  all users currently connected to this Client 
  by using the RemoteUserInfo property like this: }

  uinfo:=Sender.RemoteUserInfo[user];

{ What you get is a TRtcRecord containing all the
  information stored by the Client using the 
  "LoginUserInfo" property before he logged in to the Gateway.
  Private user information (like the password or configuration data) 
  will NOT be sent to other users. You will get here ONLY 
  data that what was assigned to the "LoginUserInfo" property. }

  try
    if uinfo.CheckType('RealName',rtc_Text) then
      s:=user+' ('+uinfo.asText['RealName']+') - '+s
    else
      s:=user+' - '+s;
  finally
    { When you are finished using the data, make sure
      to FREE the object received from "RemoteUserInfo" }
    uinfo.Free; // Do NOT forget this, or you will create a memory leak!
    end;

  el:=eConnected.Items.Add;
  el.Caption:=s;
  eConnected.Update;
  end;

procedure TMainForm.PModuleUserLeft(Sender: TRtcPModule; const user:string);
  var
    s:string;
    a,i:integer;
    uinfo:TRtcRecord;
  begin
  if Sender is TRtcPFileTransfer then
    s:='Files'
  else if Sender is TRtcPChat then
    s:='Chat'
  else if Sender is TRtcPDesktopHost then
    begin
    s:='Desktop';
    Dec(DesktopCnt);
    if DesktopCnt=0 then
      begin
      DragAcceptFiles(Handle,False);
      pSendFiles.Visible:=False;
      Show_Wallpaper;
      end;
    end
  else s:='???';

{ You can retrieve custom user information about 
  all users currently connected to this Client 
  by using the RemoteUserInfo property like this: }

  uinfo:=Sender.RemoteUserInfo[user];

{ What you get is a TRtcRecord containing all the
  information stored by the Client using the 
  "LoginUserInfo" property before he logged in to the Gateway.
  Private user information (like the password or configuration data) 
  will NOT be sent to other users. You will get here ONLY 
  data that what was assigned to the "LoginUserInfo" property. }

  try
    if uinfo.CheckType('RealName',rtc_Text) then
      s:=user+' ('+uinfo.asText['RealName']+') - '+s
    else
      s:=user+' - '+s;
  finally
    { When you are finished using the data, make sure
      to FREE the object received from "RemoteUserInfo" }
    uinfo.Free; // Do NOT forget this, or you will create a memory leak!
    end;

  i:=-1;
  for a := 0 to eConnected.Items.Count - 1 do
    if eConnected.Items[a].Caption=s then
      begin
      i:=a;
      Break;
      end;
  if i>=0 then
    begin
    eConnected.Items.Delete(i);
    eConnected.Update;
    end;
  end;

procedure TMainForm.btnGatewayClick(Sender: TObject);
  var
    sett:TrdClientSettings;
  begin
  if assigned(Options) and Options.Visible then
    Options.Close;

  PClient.Stop;

  sett:=TrdClientSettings.Create(nil);
  if assigned(sett) then
    begin
    sett.PClient:=PClient;
    try
      if sett.Execute then
        begin
        if (PClient.GateAddr='') or (PClient.GatePort='') then
          btnGateway.Caption:='< Click to set up connection >'
        else
          begin
          btnGateway.Caption:=String(PClient.GateAddr+':'+PClient.GatePort);
          SaveSetup;
          end;
        end;
    finally
      sett.Free;
      end;
    end;
  end;

procedure TMainForm.PClientStatusPut(Sender: TAbsPortalClient; Status: TRtcPHttpConnStatus);
  begin
  case status of
    rtccClosed:
      sStatus1.Brush.Color:=clGray;
    rtccOpen:
      sStatus1.Brush.Color:=clNavy;
    rtccSending:
      begin
      sStatus1.Brush.Color:=clGreen;
      case ReqCnt1 of
        0:sStatus1.Pen.Color:=clBlack;
        1:sStatus1.Pen.Color:=clGray;
        2:sStatus1.Pen.Color:=clSilver;
        3:sStatus1.Pen.Color:=clWhite;
        4:sStatus1.Pen.Color:=clSilver;
        5:sStatus1.Pen.Color:=clGray;
        end;
      Inc(ReqCnt1);
      if ReqCnt1>5 then ReqCnt1:=0;
      end;
    rtccReceiving:
      sStatus1.Brush.Color:=clLime;
    else
      begin
      sStatus1.Brush.Color:=clFuchsia;
      sStatus1.Pen.Color:=clRed;
      end;
    end;
  sStatus1.Update;
  end;

procedure TMainForm.PClientStatusGet(Sender: TAbsPortalClient; Status: TRtcPHttpConnStatus);
  begin
  case status of
    rtccClosed:
      begin
      sStatus2.Brush.Color:=clRed;
      sStatus2.Pen.Color:=clMaroon;
      end;
    rtccOpen:
      sStatus2.Brush.Color:=clNavy;
    rtccSending:
      begin
      sStatus2.Brush.Color:=clGreen;
      case ReqCnt2 of
        0:sStatus2.Pen.Color:=clBlack;
        1:sStatus2.Pen.Color:=clGray;
        2:sStatus2.Pen.Color:=clSilver;
        3:sStatus2.Pen.Color:=clWhite;
        4:sStatus2.Pen.Color:=clSilver;
        5:sStatus2.Pen.Color:=clGray;
        end;
      Inc(ReqCnt2);
      if ReqCnt2>5 then ReqCnt2:=0;
      end;
    rtccReceiving:
      sStatus2.Brush.Color:=clLime;
    else
      begin
      sStatus2.Brush.Color:=clFuchsia;
      sStatus2.Pen.Color:=clRed;
      end;
    end;
  sStatus2.Update;
  end;

procedure TMainForm.PDesktopControlNewUI(Sender: TRtcPDesktopControl; const user: String);
  var
    CDesk:TrdDesktopViewer;
  begin
  CDesk:=TrdDesktopViewer.Create(nil);
  if assigned(CDesk) then
    begin
    CDesk.PFileTrans:=PFileTrans;

    // MapKeys and ControlMode should stay as they are now,
    // because this is the Host side and Hosts do not have Control.
    CDesk.UI.ControlMode:=rtcpNoControl;
    CDesk.UI.MapKeys:=False;

    // You can set SmoothScale and ExactCursor to your prefered values,
    // or add options to the Form so the user can choose these values,
    // but the default values (False, False) will give you the best performance.
    CDesk.UI.SmoothScale:=False;
    CDesk.UI.ExactCursor:=False;

    CDesk.UI.UserName:=user;
    // Always set UI.Module *after* setting UI.UserName !!!
    CDesk.UI.Module:=Sender;

    CDesk.Show;
    end
  else
    raise Exception.Create('Error creating Window');

  if CDesk.WindowState=wsNormal then
    begin
    CDesk.BringToFront;
    BringWindowToTop(CDesk.Handle);
    end;
  end;

procedure TMainForm.FormShow(Sender: TObject);
  begin
  if not SilentMode then
    begin
    BringToFront;
    BringWindowToTop(Handle);
    end;
  end;

procedure TMainForm.WMQueryEndSession(var Msg: TWMQueryEndSession);
  begin
  xAutoConnect.Checked:=False;
  PClient.Active:=False;
  PClient.Stop;
  Application.Terminate;
  Msg.Result := 1 ;
  end;

procedure TMainForm.eRealNameChange(Sender: TObject);
  begin
{ You can assign any custom user information
  to the "PClient.LoginUserInfo" property before login ... }

  PClient.LoginUserInfo.asText['RealName']:=eRealName.Text;
 
{ All the information passed to the Gateway by using
  the "LoginUserInfo" property will be made available 
  to all other Clients through the "RemoteUserInfo" property. 
  Do NOT assign vital information here (like a 2nd password).
  Only use this property for information you want to share.

  Here are a few Examples:

  PClient.LoginUserInfo.asText['Organization']:='My Big Business';
  PClient.LoginUserInfo.asDateTime['LocalTime']:=Now;
  PClient.LoginUserInfo.asBoolean['AtWork']:=True;
 }
 end;

end.
