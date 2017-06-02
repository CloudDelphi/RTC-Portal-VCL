{ Copyright (c) RealThinClient components
  - http://www.realthinclient.com }  

unit RtcControlForm;

interface

{$INCLUDE rtcDefs.inc}

uses
  Windows, Messages, SysUtils,
  Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, ShellApi,
  ComCtrls, Buttons, jpeg, Registry,

{$IFDEF IDE_XE3up}
  UITypes,
{$ENDIF}

  rtcThrPool,
  rtcLog, rtcCrypt, rtcInfo, rtcConn,
  rtcDataCli, rtcHttpCli,

{$IFNDEF RtcViewer}
  (* If you get a COMPILE ERROR here when compiling the RTC Viewer Project,
     please add "RtcViewer" to "Conditional Defines" in Project Options.
     This is necessary because RTC Control and Viewer share the same sources.
     If "RtcViewer" is declared, this unit is compiled with no Control features. *)
  rdFileTrans, dmSetRegion,
{$ENDIF}

  rdSetClient,
  rdDesktopView, rdChat,

  rtcpDesktopConst,
  rtcpDesktopControl, rtcpDesktopControlUI,
  rtcpChat, rtcpFileTrans, rtcpFileExplore,

  rtcPortalMod, rtcPortalCli, rtcPortalHttpCli,
  rtcpDesktopHost;

const
  WM_TASKBAREVENT = WM_USER + 1;

type
  TMainForm = class(TForm)
    Notebook: TNotebook;
    pTitlebar: TPanel;
    cTitleBar: TLabel;
    btnMinimize: TSpeedButton;
    btnClose: TSpeedButton;
    lblStatusPanel: TPanel;
    lblStatus: TLabel;
    Pages: TPageControl;
    Page_Setup: TTabSheet;
    Page_Control: TTabSheet;
    Label12: TLabel;
    btnGateway: TSpeedButton;
    eUserName: TEdit;
    Label3: TLabel;
    Label4: TLabel;
    ePassword: TEdit;
    xSavePassword: TCheckBox;
    xAutoConnect: TCheckBox;
    btnLogin: TButton;
    Label5: TLabel;
    sStatus1: TShape;
    sStatus2: TShape;
    btnChat: TSpeedButton;
    btnLogout: TSpeedButton;
    cPriority: TComboBox;
    btnFileTransfer: TSpeedButton;
    PClient: TRtcHttpPortalClient;
    PFileTrans: TRtcPFileTransfer;
    PChat: TRtcPChat;
    PDesktopControl: TRtcPDesktopControl;
    Panel1: TPanel;
    xKeyMapping: TCheckBox;
    xSmoothView: TCheckBox;
    xForceCursor: TCheckBox;
    cbControlMode: TComboBox;
    PDesktopHost: TRtcPDesktopHost;
    Panel3: TPanel;
    myDesktopPanel: TPanel;
    Panel5: TPanel;
    eConnected: TListView;
    btnCloseMyDesktop: TSpeedButton;
    btnViewDesktop: TSpeedButton;
    xHideWallpaper: TCheckBox;
    xReduceColors: TCheckBox;
    Label1: TLabel;
    btnHelp: TLabel;
    Label9: TLabel;
    xWithExplorer: TCheckBox;
    Panel2: TPanel;
    Label7: TLabel;
    Label11: TLabel;
    Image1: TImage;
    lCopyright: TLabel;
    Label2: TLabel;
    btnShowMyDesktop: TSpeedButton;
    Label6: TLabel;
    eRealName: TEdit;
    eUsers: TListBox;
    procedure btnLoginClick(Sender: TObject);
    procedure btnLogoutClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure btnMinimizeClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure eUsersClick(Sender: TObject);
    procedure btnFileTransferClick(Sender: TObject);
    procedure btnChatClick(Sender: TObject);
    procedure btnViewDesktopClick(Sender: TObject);

    { Private-Deklarationen }
    procedure WMTaskbarEvent(var Message: TMessage); message WM_TASKBAREVENT;
    procedure eUsersDblClick(Sender: TObject);
    procedure btnHelpClick(Sender: TObject);
    procedure cbControlModeChange(Sender: TObject);
    procedure btnCloseClick(Sender: TObject);
    procedure pTitlebarMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure pTitlebarMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure pTitlebarMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure xKeyMappingClick(Sender: TObject);
    procedure cPriorityChange(Sender: TObject);
    procedure xSmoothViewClick(Sender: TObject);
    procedure xForceCursorClick(Sender: TObject);
    procedure btnGatewayClick(Sender: TObject);
    procedure RtcCopyrightClick(Sender: TObject);
    procedure PClientError(Sender: TAbsPortalClient; const Msg: String);
    procedure PClientFatalError(Sender: TAbsPortalClient; const Msg: String);
    procedure PClientLogIn(Sender: TAbsPortalClient);
    procedure PClientLogOut(Sender: TAbsPortalClient);
    procedure PClientStart(Sender: TAbsPortalClient; const Data: TRtcValue);
    procedure PClientUserLoggedIn(Sender: TAbsPortalClient; const User: String);
    procedure PClientUserLoggedOut(Sender: TAbsPortalClient; const User: String);
    procedure PClientStatusGet(Sender: TAbsPortalClient; Status: TRtcPHttpConnStatus);
    procedure PClientStatusPut(Sender: TAbsPortalClient; Status: TRtcPHttpConnStatus);
    procedure PFileTransNewUI(Sender: TRtcPFileTransfer; const user: String);
    procedure PChatNewUI(Sender: TRtcPChat; const user: String);
    procedure eUserNameChange(Sender: TObject);
    procedure ePasswordChange(Sender: TObject);
    procedure PDesktopControlNewUI(Sender: TRtcPDesktopControl;
      const user: String);
    procedure btnShowMyDesktopClick(Sender: TObject);
    procedure PDesktopHostUserJoined(Sender: TRtcPModule;
      const user: String);
    procedure PDesktopHostUserLeft(Sender: TRtcPModule;
      const user: String);
    procedure btnCloseMyDesktopClick(Sender: TObject);
    procedure eConnectedDblClick(Sender: TObject);
    procedure xWithExplorerClick(Sender: TObject);
    procedure eRealNameChange(Sender: TObject);
    procedure lblStatusMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure lblStatusMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure lblStatusMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);

  public
    { Public declarations }
    TaskBarIcon:boolean;
    ReqCnt1,ReqCnt2:integer;

    procedure LoadSetup;
    procedure SaveSetup;

    // Load and Save Window Positions
    function LoadWindowPosition(Form: TForm; FormName: String; LoadSize:boolean=False):boolean;
    procedure SaveWindowPosition(Form: TForm; FormName: String);

    procedure TaskBarAddIcon;
    procedure TaskBarRemoveIcon;
  end;

var
  MainForm: TMainForm;

implementation

{$R *.dfm}

(* RTC Control and Viewer practically use the same code,
   but {$IFDEF}-ed to remove the Control part from the Viewer.
   This makes it possible to create 1 project for both.

   RTC Control does NOT have the "RtcViewer" directive declared, so
   that all units compiled by the RTC Control project
   compile all code parts needed for remote control.

   RTC Viewer DOES have the "RtcViewer" directive declared, so
   it will NOT compile the code parts meant to work only for Control. *)

function ControlStr(const s:string):string;
  begin
  {$IFNDEF RtcViewer}
    Result:=StringReplace(s,'Viewer','Control',[rfReplaceAll]);
  {$ELSE}
    Result:=StringReplace(s,'Control','Viewer',[rfReplaceAll]);
  {$ENDIF}
  end;

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
  // Eliminate annoying Vista BEEP bug when using ListView
  EliminateListViewBeep;

  Pages.ActivePage:=Page_Setup;
  Page_Control.TabVisible:=False;

  StartLog;

  LOG_THREAD_EXCEPTIONS:=True;
  LOG_EXCEPTIONS:=True;

  { We can set all our background Threads to a higher priority,
    so we can get enough CPU time even when there are applications
    with higher priority running at 100% CPU. }
  //RTC_THREAD_PRIORITY:=tpHigher;
  //RTC_WND_THREAD_PRIORITY:=tpHigher;

  TaskBarIcon:=False;
  ReqCnt1:=0;
  ReqCnt2:=0;

  Caption:=ControlStr(Caption);
  lCopyright.Caption:=ControlStr(lCopyright.Caption);

  cTitleBar.Caption:=ControlStr(cTitleBar.Caption);

{$IFNDEF RtcViewer}
  PFileTrans.FileInboxPath:= ExtractFilePath(AppFileName)+'INBOX';
  PFileTrans.Client:=PClient;
{$ELSE}
  xKeyMapping.Enabled:=False;
  cbControlMode.ItemIndex:=0;
  cbControlMode.Enabled:=False;
  xHideWallpaper.Enabled:=False;
  xReduceColors.Enabled:=False;
{$ENDIF}

  Left:=(Screen.Width-Width) div 2;
  Top:=(Screen.Height-Height) div 2;

  LoadSetup;

  cPriorityChange(nil);

  eUserName.Text:=PClient.LoginUsername;
  ePassword.Text:=PClient.LoginPassword;
  // Custom User Info (can be anything you want/need)
  eRealName.Text:=PClient.LoginUserInfo.asText['RealName'];

  // Called to speed-up loading of icons for the File Explorer:
  InitFileIconLibrary;
  end;

procedure TMainForm.FormDestroy(Sender: TObject);
  begin
  xAutoConnect.Checked:=False;
  PClient.Active:=False;
  PClient.Stop;
  end;

(* Load and Save Configuration *)

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
        DeCrypt(s, 'RTC Control 2.0');
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

            PClient.Gate_ProxyAddr:=info.asText['ProxyAddr'];
            PClient.Gate_ProxyUserName:=info.asText['ProxyUsername'];
            PClient.Gate_ProxyPassword:=info.asText['ProxyPassword'];

            PClient.LoginUsername:=info.asText['UserName'];
            PClient.LoginPassword:=info.asText['Password'];
            { We can simply replace all data from "LoginUserInfo" with "CustomInfo",
              because this is where we have saved it. }
            PClient.LoginUserInfo:=info.asRecord['CustomInfo'];

            if (PClient.GateAddr='') or (PClient.GatePort='') then
              btnGateway.Caption:='< Click to set up connection >'
            else
              btnGateway.Caption:=String(PClient.GateAddr+':'+PClient.GatePort);

            xSavePassword.Checked:=info.asBoolean['SavePassword'];
            xAutoConnect.Checked:=info.asBoolean['AutoConnect'];

            xKeyMapping.Checked:=info.asBoolean['MapKeys'];
            xSmoothView.Checked:=info.asBoolean['SmoothView'];
            xForceCursor.Checked:=info.asBoolean['ExactCursor'];
            cbControlMode.ItemIndex:=info.asInteger['ControlMode'];
            xHideWallpaper.Checked:=info.asBoolean['HideWallpaper'];
            xReduceColors.Checked:=info.asBoolean['ReduceColors'];
            xWithExplorer.Checked:=info.asBoolean['WithExplorer'];
            xWithExplorerClick(xWithExplorer);

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
  LoadWindowPosition(Self,'MainForm',False);
  end;

procedure TMainForm.SaveSetup;
  var
    CfgFileName:String;
    infos:RtcString;
    s2:RtcByteArray;
    info:TRtcRecord;
    len2:longint;
  begin
  info:=TRtcRecord.Create;
  try
    info.asString['Address']:= PClient.GateAddr;
    info.asString['Port']:= PClient.GatePort;
    info.asBoolean['Proxy']:= PClient.Gate_Proxy;
    info.asBoolean['WinHTTP']:= PClient.Gate_WinHttp;
    info.asBoolean['SSL']:= PClient.Gate_SSL;
    info.asString['DLL']:= PClient.Gate_ISAPI;

    info.asText['ProxyAddr']:=PClient.Gate_ProxyAddr;
    info.asText['ProxyPassword']:=PClient.Gate_ProxyPassword;
    info.asText['ProxyUsername']:=PClient.Gate_ProxyUserName;

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

    info.asBoolean['MapKeys']:=xKeyMapping.Checked;
    info.asBoolean['SmoothView']:=xSmoothView.Checked;
    info.asBoolean['ExactCursor']:=xForceCursor.Checked;
    info.asInteger['ControlMode']:=cbControlMode.ItemIndex;
    info.asBoolean['HideWallpaper']:=xHideWallpaper.Checked;
    info.asBoolean['ReduceColors']:=xReduceColors.Checked;
    info.asBoolean['WithExplorer']:=xWithExplorer.Checked;

    info.asInteger['Priority']:=cPriority.ItemIndex;

    infos:=info.toCode;
    Crypt(infos,'RTC Control 2.0');
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
function TMainForm.LoadWindowPosition(Form: TForm; FormName: String; LoadSize:boolean=False):boolean;
  var
    CfgFileName:String;
    s:RtcString;
    info:TRtcRecord;
  Begin
  Result:=false;

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
            if LoadSize then
              begin
              Form.Width := asInteger['Width'];
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
procedure TMainForm.SaveWindowPosition(Form: TForm; FormName: String);
  Var
    CfgFileName:String;
    s,infos:RtcString;
    info:TRtcRecord;
  Begin
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
      asInteger['Width']:= Form.Width;
      asInteger['Height']:= Form.Height;
      end;

    infos:=info.toCode;
  finally
    info.Free;
    end;

  Write_File(CfgFileName,infos);
  End;

(* Utility code *)

procedure TMainForm.TaskBarAddIcon;
  var
    tnid: TNotifyIconData;
    xOwner: HWnd;
  begin
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
    {$IFNDEF RtcViewer}
    StrCopy(tnid.szTip, 'RTC Control');
    {$ELSE}
    StrCopy(tnid.szTip, 'RTC Viewer');
    {$ENDIF}
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

(* Minimize and Close actions *)

procedure TMainForm.btnMinimizeClick(Sender: TObject);
  begin
  TaskBarAddIcon;
  Application.Minimize;
  ShowWindow(Application.Handle, SW_HIDE);
  end;

procedure TMainForm.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
  begin
  xAutoConnect.Checked:=False; // disable auto re-login

  btnLogoutClick(Sender);
  TaskBarRemoveIcon;
  CanClose:=True;

  SaveWindowPosition(Self, 'MainForm');
  end;

(* Buttons on our Form *)

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

  PClient.Active:=True;
  end;

procedure TMainForm.btnLogoutClick(Sender: TObject);
  begin
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

procedure TMainForm.btnHelpClick(Sender: TObject);
  begin
  {$IFNDEF RtcViewer}
  ShowMessage('Keys in Desktop Control ...'#13#10+
              'Full Screen View (Scaled) On/Off = [Win+S]'#13#10+
              'Full Screen View (100%) On/Off = [Win+W]'#13#10+
              'Hide Wallpaper = [Ctrl+Win]'#13#10+
              'Show Wallpaper = [Shift+Ctrl+Win]'#13#10+
              'Send <Ctrl+Alt+Del> = [Ctrl+Alt+Ins]'#13#10+
              'Send <Win> = [Shift+Win]'#13#10+
              'Send <Alt+TAB> = [Alt+Win]'#13#10+
              'Send <Shift+Alt+TAB> = [Shift+Alt+Win]'#13#10+
              'Get selected File/Folder = [Ctrl+Alt+C]'#13#10#13#10+
              '* Control Panel will apear when you move'#13#10+
              '  your mouse to the top-left window corner.');
  {$ELSE}
  ShowMessage('Keys in Desktop View ...'#13#10+
              'Full Screen View (Scaled) On/Off = [Win+S]'#13#10+
              'Full Screen View (100%) On/Off = [Win+W]');
  {$ENDIF}
  end;

procedure TMainForm.cbControlModeChange(Sender: TObject);
  begin
  {$IFNDEF RtcViewer}
  SaveSetup;
  case cbControlMode.ItemIndex of
    0:PDesktopControl.NotifyUI(RTCPDESKTOP_ControlMode_Off);
    1:PDesktopControl.NotifyUI(RTCPDESKTOP_ControlMode_Auto);
    2:PDesktopControl.NotifyUI(RTCPDESKTOP_ControlMode_Manual);
    3:PDesktopControl.NotifyUI(RTCPDESKTOP_ControlMode_Full);
    end;
  {$ENDIF}
  end;

procedure TMainForm.xKeyMappingClick(Sender: TObject);
  begin
  {$IFNDEF RtcViewer}
  SaveSetup;
  if xKeyMapping.Checked then
    PDesktopControl.NotifyUI(RTCPDESKTOP_MapKeys_On)
  else
    PDesktopControl.NotifyUI(RTCPDESKTOP_MapKeys_Off);
  {$ENDIF}
  end;

procedure TMainForm.xSmoothViewClick(Sender: TObject);
  begin
  SaveSetup;
  if xSmoothView.Checked then
    PDesktopControl.NotifyUI(RTCPDESKTOP_SmoothScale_On)
  else
    PDesktopControl.NotifyUI(RTCPDESKTOP_SmoothScale_Off);
  end;

procedure TMainForm.xForceCursorClick(Sender: TObject);
  begin
  SaveSetup;
  if xForceCursor.Checked then
    PDesktopControl.NotifyUI(RTCPDESKTOP_ExactCursor_On)
  else
    PDesktopControl.NotifyUI(RTCPDESKTOP_ExactCursor_Off);
  end;

procedure TMainForm.btnCloseClick(Sender: TObject);
  begin
  Close;
  end;

procedure TMainForm.eUsersClick(Sender: TObject);
  begin
  if (eUsers.ItemIndex>=0) and (eUsers.Items[eUsers.ItemIndex]<>'') then
    begin
    btnChat.Enabled:=True;
    btnFileTransfer.Enabled:=True;
    btnViewDesktop.Enabled:=True;
    btnShowMyDesktop.Enabled:=True;
    end
  else
    begin
    btnChat.Enabled:=False;
    btnFileTransfer.Enabled:=False;
    btnViewDesktop.Enabled:=False;
    btnShowMyDesktop.Enabled:=False;
    end;
  end;

procedure TMainForm.btnFileTransferClick(Sender: TObject);
  {$IFNDEF RtcViewer}
  var
    user:string;
  begin
  if (eUsers.ItemIndex>=0) and
     (eUsers.Items[eUsers.ItemIndex]<>'') then
    begin
    user:=eUsers.Items[eUsers.ItemIndex];
    PFileTrans.Open(user);
    end
  else
    MessageBeep(0);
  end;
  {$ELSE}
  begin
  ShowMessage('File Transfer is not available in RTC Viewer.');
  end;
  {$ENDIF}

procedure TMainForm.btnChatClick(Sender: TObject);
  var
    user:string;
  begin
  if (eUsers.ItemIndex>=0) and
     (eUsers.Items[eUsers.ItemIndex]<>'') then
    begin
    user:=eUsers.Items[eUsers.ItemIndex];
    PChat.Open(user);
    end
  else
    MessageBeep(0);
  end;

procedure TMainForm.btnViewDesktopClick(Sender: TObject);
  var
    user:string;
  begin
  if (eUsers.ItemIndex>=0) and
     (eUsers.Items[eUsers.ItemIndex]<>'') then
    begin
    user:=eUsers.Items[eUsers.ItemIndex];

    // If the Host was using a colorful Wallpaper, without hiding the wallpaper,
    // receiving the initial Desktop Screen could take quite a while.
    // To hide the Dektop wallpaper on the Host, you can use the "Send_HideDesktop" method.
    if xHideWallpaper.Checked then
      PDesktopControl.Send_HideDesktop(user);

    // If you would like to change Hosts Desktop Viewer settings
    // before the initial screen is being prepared for sending by the Host,
    // this is where you could call "PDesktopControl.ChgDesktop_" methods ...
    // The example below would set the Host to use 9bit colors and 25FPS frame rate ...
    if xReduceColors.Checked then
      begin
      PDesktopControl.ChgDesktop_Begin;
      PDesktopControl.ChgDesktop_ColorLimit(rdColor8bit);
      // PDesktopControl.ChgDesktop_FrameRate(rdFrames25);
      PDesktopControl.ChgDesktop_End(user);
      end;

    PDesktopControl.Open(user);
    end
  else
    MessageBeep(0);
  end;

procedure TMainForm.eUsersDblClick(Sender: TObject);
  begin
  eUsersClick(Sender);
  btnViewDesktopClick(Sender);
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

(* Shell calling code *)

procedure TMainForm.RtcCopyrightClick(Sender: TObject);
  begin
  ShellExecute(handle, 'open', 'http://www.realthinclient.com',nil,nil,SW_SHOW);
  end;

(* Moving the Window by using the "pTitlebar" Panel *)

var
  LMouseX,LMouseY:integer;
  SMouseD:boolean=False;
  LMouseD:boolean=False;

procedure TMainForm.pTitlebarMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
  begin
  if Button=mbLeft then
    begin
    LMouseD:=True;
    LMouseX:=X;LMouseY:=Y;
    end;
  end;

procedure TMainForm.pTitlebarMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
  begin
  if LMouseD then
    SetBounds(Left+X-LMouseX,Top+Y-LMouseY,Width,Height);
  end;

procedure TMainForm.pTitlebarMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
  begin
  if Button=mbLeft then
    LMouseD:=False;
  end;

procedure TMainForm.lblStatusMouseDown(Sender: TObject;
    Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
  begin
  if Button=mbLeft then
    begin
    SMouseD:=True;
    LMouseX:=X;LMouseY:=Y;
    end;
  end;

procedure TMainForm.lblStatusMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
  begin
  if SMouseD then
    SetBounds(Left,Top,Width,Height+Y-LMouseY);
  end;

procedure TMainForm.lblStatusMouseUp(Sender: TObject; Button: TMouseButton;
    Shift: TShiftState; X, Y: Integer);
  begin
  if Button=mbLeft then
    SMouseD:=False;
  end;

(* Events triggered by RTC Control/Viewer code *)

procedure TMainForm.btnGatewayClick(Sender: TObject);
  var
    sett:TrdClientSettings;
  begin
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

procedure TMainForm.PClientError(Sender: TAbsPortalClient; const Msg: String);
  begin
  PClientFatalError(Sender,Msg);

  // The difference between "OnError" and "OnFatalError" is
  // that "OnError" will make a reconnect if "Re-Login" was checked,
  // while "OnFatalError" simply closes all connections and stops.
  if xAutoConnect.Checked then
    PClient.Active:=True;
  end;

procedure TMainForm.PClientFatalError(Sender: TAbsPortalClient; const Msg: String);
  begin
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

  MessageBeep(0);
  end;

procedure TMainForm.PClientLogIn(Sender: TAbsPortalClient);
  begin
  eUsers.Clear;
  eConnected.Clear;
  btnLogout.Enabled:=True;

  lblStatus.Caption:='Logged in as "'+PClient.LoginUsername+'".';
  lblStatus.Update;
  end;

procedure TMainForm.PClientLogOut(Sender: TAbsPortalClient);
  begin
  if Pages.ActivePage<>Page_Setup then
    begin
    Page_Setup.TabVisible:=True;
    Pages.ActivePage.TabVisible:=False;
    Pages.ActivePage:=Page_Setup;
    end;

  btnLogin.Enabled:=True;
  lblStatus.Caption:='Logged out. Click "'+btnLogin.Caption+'" to connect again.';
  lblStatus.Update;
  end;

procedure TMainForm.PClientStart(Sender: TAbsPortalClient; const Data: TRtcValue);
  begin
  if Pages.ActivePage<>Page_Control then
    begin
    Page_Control.TabVisible:=True;
    Pages.ActivePage.TabVisible:=False;
    Pages.ActivePage:=Page_Control;
    end;

  eUsers.Clear;
  eConnected.Clear;

  eUsers.Enabled:=False;
  eUsers.Color:=clBtnFace;
  btnChat.Enabled:=False;
  btnFileTransfer.Enabled:=False;
  btnViewDesktop.Enabled:=False;
  btnShowMyDesktop.Enabled:=False;

  myDesktopPanel.Visible:=False;
  eConnected.Enabled:=False;
  btnCloseMyDesktop.Enabled:=False;

  lblStatus.Caption:='Connected as '+ControlStr('Control')+' "'+PClient.LoginUsername+'".';
  lblStatus.Update;

  cTitleBar.Refresh;
  btnMinimize.Refresh;
  btnClose.Refresh;
  end;

procedure TMainForm.PClientUserLoggedIn(Sender: TAbsPortalClient; const User: String);
  var
    a:integer;
    have:boolean;
    // el:TListItem;
    // uinfo:TRtcRecord;
    UName:String;
  begin
  UName:=User;
{ You can retrieve custom user information about 
  all users currently connected to this Client 
  by using the RemoteUserInfo property like this:

   uinfo:=Sender.RemoteUserInfo[User];

  What you get is a TRtcRecord containing all the
  information stored by the Client using the 
  "LoginUserInfo" property before he logged in to the Gateway.
  Private user information (like the password or configuration data) 
  will NOT be sent to other users. You will get here ONLY 
  data that what was assigned to the "LoginUserInfo" property.
  
  try
    if uinfo.CheckType('RealName',rtc_Text) then
      UName:=UName+' ('+uinfo.asText['RealName']+')';
  finally
    uinfo.Free; // You need to FREE the object received from RemoteUserInfo!
    end;
}

  have:=False;
  for a := 0 to eUsers.Items.Count - 1 do
    if eUsers.Items[a]=UName then
      have:=True;
  if not have then
    begin
    //el:=
    eUsers.Items.Add(UName);
    //el.Caption:=UName;
    eUsers.Update;
    end;
  if eUsers.Items.Count=1 then
    begin
    eUsers.Enabled:=True;
    eUsers.Color:=clWindow;
    eUsers.ItemIndex:=0;
    btnFileTransfer.Enabled:=True;
    btnChat.Enabled:=True;
    btnViewDesktop.Enabled:=True;
    btnShowMyDesktop.Enabled:=True;
    end;
  end;

procedure TMainForm.PClientUserLoggedOut(Sender: TAbsPortalClient; const User: String);
  var
    a,i:integer;
    // uinfo:TRtcRecord;
    UName:String;
  begin
  UName:=User;
  {Read comments in the above (PClientUserLoggedIn) method
   for more information on using the "RemoteUserInfo" property.

  uinfo:=Sender.RemoteUserInfo[User];
  try
    if uinfo.CheckType('RealName',rtc_Text) then
      UName:=UName+' ('+uinfo.asText['RealName']+')';
  finally
    uinfo.Free;
    end;}

  i:=-1;
  for a := 0 to eUsers.Items.Count - 1 do
    if eUsers.Items[a]=UName then
      begin
      i:=a;
      Break;
      end;
  if i>=0 then
    begin
    if eUsers.ItemIndex=i then
      begin
      eUsers.ItemIndex:=-1;
      btnFileTransfer.Enabled:=False;
      btnChat.Enabled:=False;
      btnViewDesktop.Enabled:=False;
      btnShowMyDesktop.Enabled:=False;
      end;

    eUsers.Items.Delete(i);
    eUsers.Update;

    if eUsers.Items.Count=0 then
      begin
      eUsers.Color:=clBtnFace;
      eUsers.Enabled:=False;
      end;
    end;
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

procedure TMainForm.PFileTransNewUI(Sender: TRtcPFileTransfer; const user: String);
{$IFNDEF RtcViewer}
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

    FWin.WithExplorer:=True;
    FWin.AutoExplore:=xWithExplorer.Checked;

    FWin.Show;
    FWin.WindowState:=wsNormal;
    FWin.BringToFront;
    end
  else
    raise Exception.Create('Error creating Window');
  end;
{$ELSE}
  begin
  end;
{$ENDIF}

procedure TMainForm.PChatNewUI(Sender: TRtcPChat; const user: String);
  var
    CWin:TrdChatForm;
  begin
  CWin:=TrdChatForm.Create(nil);
  if assigned(CWin) then
    begin
    CWin.PDesktopControl:=PDesktopControl;

    {$IFNDEF RtcViewer}
    CWin.PFileTrans:=PFileTrans;
    {$ENDIF}

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

procedure TMainForm.PDesktopControlNewUI(Sender: TRtcPDesktopControl; const user: String);
  var
    CDesk:TrdDesktopViewer;
  begin
  CDesk:=TrdDesktopViewer.Create(nil);
  if assigned(CDesk) then
    begin
    {$IFNDEF RtcViewer}
    CDesk.PFileTrans:=PFileTrans;
    {$ENDIF}

    CDesk.UI.MapKeys:=xKeyMapping.Checked;
    CDesk.UI.SmoothScale:=xSmoothView.Checked;
    CDesk.UI.ExactCursor:=xForceCursor.Checked;

    {$IFNDEF RtcViewer}
    case cbControlMode.ItemIndex of
      0: CDesk.UI.ControlMode:=rtcpNoControl;
      1: CDesk.UI.ControlMode:=rtcpAutoControl;
      2: CDesk.UI.ControlMode:=rtcpManualControl;
      3: CDesk.UI.ControlMode:=rtcpFullControl;
      end;
    {$ENDIF}

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

procedure TMainForm.btnShowMyDesktopClick(Sender: TObject);
  {$IFNDEF RtcViewer}
  var
    user:string;
    R:TRect;
    selRegion:TdmSelectRegion;
  begin
  if (eUsers.ItemIndex>=0) and
     (eUsers.Items[eUsers.ItemIndex]<>'') then
    begin
    user:=eUsers.Items[eUsers.ItemIndex];

    if eConnected.Items.Count=0 then
      begin
      if MessageDlg('Limit Visible Desktop Region?'#13#10#13#10+
                    'Click "YES" and select a region with your mouse, or'#13#10+
                    'Click "NO" to show your Primary Screen to remote users.',
                    mtConfirmation,[mbYes,mbNo],0)=mrYes then
        begin
        WindowState:=wsMinimized;
        try
          Sleep(500);
          selRegion:=TdmSelectRegion.Create(nil);
          try
            R:=selRegion.GrabScreen(True);
          finally
            SelRegion.Free;
            end;
        finally
          WindowState:=wsNormal;
          end;
        end
      else
        R:=Rect(0,0,Screen.Width,Screen.Height);

      PDesktopHost.ScreenRect:=R;
      PDesktopHost.GFullScreen:=False;
      PDesktopHost.GAllowView:=True;
      PDesktopHost.GAllowView_Super:=True;
      PDesktopHost.GCaptureAllMonitors:=True;
      PDesktopHost.GUseMirrorDriver:=True;

      PDesktopHost.Restart;
      end;

    PDesktopHost.Open(user);
    end
  else
    MessageBeep(0);
  end;
  {$ELSE}
  begin
  ShowMessage('This option is not available in RTC Viewer.');
  end;
  {$ENDIF}

procedure TMainForm.PDesktopHostUserJoined(Sender: TRtcPModule; const user: String);
  var
    el:TListItem;
  begin
  el:=eConnected.Items.Add;
  el.Caption:=user;
  eConnected.Update;
  if eConnected.Items.Count=1 then
    begin
    myDesktopPanel.Visible:=True;
    eConnected.Color:=clWindow;
    eConnected.Enabled:=True;
    btnCloseMyDesktop.Enabled:=True;
    end;
  end;

procedure TMainForm.PDesktopHostUserLeft(Sender: TRtcPModule; const user: String);
  var
    a,i:integer;
  begin
  i:=-1;
  for a := 0 to eConnected.Items.Count - 1 do
    if eConnected.Items[a].Caption=user then
      begin
      i:=a;
      Break;
      end;
  if i>=0 then
    begin
    eConnected.Items.Delete(i);
    eConnected.Update;
    if eConnected.Items.Count=0 then
      begin
      eConnected.Enabled:=False;
      eConnected.Color:=clBtnFace;
      btnCloseMyDesktop.Enabled:=False;
      myDesktopPanel.Visible:=False;

      PDesktopHost.GAllowView:=False;
      PDesktopHost.GAllowView_Super:=False;
      PDesktopHost.GCaptureAllMonitors:=False;
      PDesktopHost.GUseMirrorDriver:=False;

      // Disable mirror driver and disallow new connections
      PDesktopHost.Restart;
      end;
    end;
  end;

procedure TMainForm.btnCloseMyDesktopClick(Sender: TObject);
  begin
  PDesktopHost.CloseAll;
  end;

procedure TMainForm.eConnectedDblClick(Sender: TObject);
  var
    user:string;
  begin
  if (eConnected.ItemIndex>=0) and
     (eConnected.Items[eConnected.ItemIndex].Caption<>'') then
    begin
    user:=eConnected.Items[eConnected.ItemIndex].Caption;
    PDesktopHost.Close(user);
    end
  else
    MessageBeep(0);
  end;

procedure TMainForm.xWithExplorerClick(Sender: TObject);
  begin
  SaveSetup;
  if xWithExplorer.Checked then
    btnFileTransfer.Caption:='File Explorer'
  else
    btnFileTransfer.Caption:='File Transfer';
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
