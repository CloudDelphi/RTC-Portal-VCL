{ Copyright (c) Danijel Tkalcec,
  RealThinClient components - http://www.realthinclient.com }

unit RtcGatewayForm;

interface

{$INCLUDE rtcDefs.inc}

uses
  Windows, Messages, SysUtils,
  Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, ShellApi,

{$IFDEF IDE_XE3up}
  UITypes,
{$ENDIF}

  rtcLog, rtcCrypt,
  rtcThrPool, rtcHWndPool,
  rtcSrvModule, rtcPortalGate,
  rtcDataSrv, rtcHttpSrv,
  rtcInfo, rtcConn,

  rtcGatewaySvc,

  jpeg, ComCtrls, Buttons;

const
  WM_TASKBAREVENT = WM_USER + 1;

type
  TMainForm = class(TForm)
    pTitlebar: TPanel;
    cTitleBar: TLabel;
    btnMinimize: TSpeedButton;
    btnClose: TSpeedButton;
    Pages: TPageControl;
    Page_Setup: TTabSheet;
    Page_Active: TTabSheet;
    Label2: TLabel;
    Label7: TLabel;
    lblSelect: TLabel;
    ePort: TEdit;
    btnLogin: TButton;
    eSecureKey: TEdit;
    xSSL: TCheckBox;
    eAddress: TEdit;
    xISAPI: TCheckBox;
    eISAPI: TEdit;
    xBindIP: TCheckBox;
    Panel2: TPanel;
    Label25: TLabel;
    Label24: TLabel;
    btnInstall: TSpeedButton;
    btnRun: TSpeedButton;
    btnStop: TSpeedButton;
    btnUninstall: TSpeedButton;
    Label5: TLabel;
    btnLogout: TSpeedButton;
    eUsers: TListView;
    Panel3: TPanel;
    Label1: TLabel;
    Label3: TLabel;
    Image1: TImage;
    lblStatusPanel: TPanel;
    lblStatus: TLabel;
    Label8: TLabel;
    HttpServer: TRtcHttpServer;
    RtcGateTestProvider: TRtcDataProvider;
    Gateway: TRtcPortalGateway;
    xNoAutoRegUsers: TCheckBox;
    btnRestartService: TSpeedButton;
    btnSaveSetup: TSpeedButton;
    procedure btnLoginClick(Sender: TObject);
    procedure btnLogoutClick(Sender: TObject);
    procedure xSSLClick(Sender: TObject);
    procedure RtcCopyrightClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure btnMinimizeClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);

    { Private-Deklarationen }
    procedure WMTaskbarEvent(var Message: TMessage); message WM_TASKBAREVENT;
    procedure btnCloseClick(Sender: TObject);
    procedure pTitlebarMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure pTitlebarMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure pTitlebarMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure xBindIPClick(Sender: TObject);
    procedure xISAPIClick(Sender: TObject);
    procedure btnInstallClick(Sender: TObject);
    procedure btnUninstallClick(Sender: TObject);
    procedure btnRunClick(Sender: TObject);
    procedure btnStopClick(Sender: TObject);
    procedure RtcGateTestProviderCheckRequest(Sender: TRtcConnection);
    procedure RtcGateTestProviderDataReceived(Sender: TRtcConnection);
    procedure HttpServerListenError(Sender: TRtcConnection; E: Exception);
    procedure GatewayUserLogin(const UserName: String);
    procedure GatewayUserLogout(const UserName: String);
    procedure HttpServerListenLost(Sender: TRtcConnection);
    procedure btnSaveSetupClick(Sender: TObject);
    procedure btnRestartServiceClick(Sender: TObject);

  public
    { Public declarations }
    TaskBarIcon:boolean;

    procedure LoadSetup;
    procedure SaveSetup;

    procedure TaskBarAddIcon;
    procedure TaskBarRemoveIcon;

    procedure On_Error(const s:string);
  end;

var
  MainForm: TMainForm;

implementation

{$R *.dfm}

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
    StrCopy(tnid.szTip, 'RTC Gateway');
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
          TaskBarRemoveIcon;
          end;
    end;
  end;

procedure TMainForm.FormCreate(Sender: TObject);
  begin
  Pages.ActivePage:=Page_Setup;
  Page_Active.TabVisible:=False;

  LOG_THREAD_EXCEPTIONS:=True;
  LOG_EXCEPTIONS:=True;

  RTC_THREAD_PRIORITY:=tpHigher;

  TaskBarIcon:=False;

  StartLog;

  Gateway.InfoFileName:=ChangeFileExt(AppFileName,'.usr');

  LoadSetup;
  end;

procedure TMainForm.btnLoginClick(Sender: TObject);
  begin
  SaveSetup;

  if xBindIP.Checked and (eAddress.Text='') then
    begin
    ShowMessage('Please, uncheck the "Bind to IP" option,'#13#10+
                'or enter your Network Card''s IP Address.');
    eAddress.SetFocus;
    Exit;
    end;
  if ePort.Text='' then
    begin
    ShowMessage('Please, choose a Port for your Gateway.');
    ePort.SetFocus;
    Exit;
    end;
  if xISAPI.Checked and (eISAPI.Text='') then
    begin
    ShowMessage('Please, enter the PATH where you want to emulate the ISAPI DLL.');
    eISAPI.SetFocus;
    Exit;
    end;

  btnLogin.Enabled:=False;

  lblStatus.Caption:='Preparing the Gateway ...';
  lblStatus.Update;

  HttpServer.StopListenNow;

  if xBindIP.Checked then
    HttpServer.ServerAddr:=RtcString(Trim(eAddress.Text))
  else
    HttpServer.ServerAddr:='';
  HttpServer.ServerPort:=RtcString(Trim(ePort.Text));

  Gateway.AutoRegisterUsers:=not xNoAutoRegUsers.Checked;

  if xISAPI.Checked then
    Gateway.ModuleFileName:=RtcString(Trim(eISAPI.Text))+'/gate'
  else
    Gateway.ModuleFileName:='/$rdgate';

  Gateway.SecureKey:=RtcString(Trim(eSecureKey.Text));

  HttpServer.Listen;

  btnLogout.Enabled:=True;

  if Pages.ActivePage<>Page_Active then
    begin
    Page_Active.TabVisible:=True;
    Pages.ActivePage.TabVisible:=False;
    Pages.ActivePage:=Page_Active;
    end;

  {eUsers.Clear;
  eUsers.Enabled:=False;
  eUsers.Color:=clBtnFace;}

  // A work-around for disapearing Close and Minimize buttons ...
  cTitleBar.Refresh;
  btnMinimize.Refresh;
  btnClose.Refresh;

  lblStatus.Caption:='Gateway running on Port '+ePort.Text;
  lblStatus.Update;
  end;

procedure TMainForm.On_Error(const s: string);
  begin
  if Pages.ActivePage<>Page_Setup then
    begin
    Page_Setup.TabVisible:=True;
    Pages.ActivePage.TabVisible:=False;
    Pages.ActivePage:=Page_Setup;
    end;

  btnLogin.Enabled:=True;
  lblStatus.Caption:=s;
  lblStatus.Update;

  MessageBeep(0);
  end;

procedure TMainForm.btnLogoutClick(Sender: TObject);
  begin
  btnLogout.Enabled:=False;

  HttpServer.StopListenNow;

  if Pages.ActivePage<>Page_Setup then
    begin
    Page_Setup.TabVisible:=True;
    Pages.ActivePage.TabVisible:=False;
    Pages.ActivePage:=Page_Setup;
    end;

  btnLogin.Enabled:=True;
  lblStatus.Caption:='Click "START" to start the Gateway.';
  lblStatus.Update;
  end;

procedure TMainForm.xSSLClick(Sender: TObject);
  begin
  if xSSL.Checked and (ePort.Text='80') then
    ePort.Text:='443'
  else if not xSSL.Checked and (ePort.Text='443') then
    ePort.Text:='80';
  end;

procedure TMainForm.RtcCopyrightClick(Sender: TObject);
  begin
  ShellExecute(handle, 'open', 'http://www.realthinclient.com',nil,nil,SW_SHOW);
  end;

procedure TMainForm.btnMinimizeClick(Sender: TObject);
  begin
  TaskBarAddIcon;
  Application.Minimize;
  ShowWindow(Application.Handle, SW_HIDE);
  end;

procedure TMainForm.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
  begin
  if (Pages.ActivePage=Page_Active) and (eUsers.Items.Count>0) then
    begin
    if MessageDlg('Are you sure you want to close the Gateway?'#13#10+
                  'There are users connected to this Gateway.'#13#10+
                  'Closing the Gateway will disconnect them all.',
                  mtWarning,[mbNo,mbYes],0)=mrYes then
      begin
      BtnLogoutClick(Sender);
      TaskBarRemoveIcon;
      CanClose:=True;
      end
    else
      CanClose:=False;
    end
  else
    begin
    BtnLogoutClick(Sender);
    TaskBarRemoveIcon;
    CanClose:=True;
    end;
  end;

procedure TMainForm.btnCloseClick(Sender: TObject);
  begin
  Close;
  end;

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
        DeCrypt(s, 'RTC Gateway 2.0');
        try
          info:=TRtcRecord.FromCode(s);
        except
          info:=nil;
          end;
        if assigned(info) then
          begin
          try
            xBindIP.Checked:=info.asBoolean['Bind'];
            eAddress.Text:=info.asText['Address'];
            ePort.Text:=info.asText['Port'];
            xSSL.Checked:=info.asBoolean['SSL'];
            xISAPI.Checked:=info.asBoolean['ISAPI'];
            eISAPI.Text:=info.asText['DLL'];
            eSecureKey.Text:=info.asText['SecureKey'];
            xNoAutoRegUsers.Checked:=info.asBoolean['NoAutoReg'];
          finally
            info.Free;
            end;
          end;
        end;
      end;
    end;
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
    info.asBoolean['Bind']:=xBindIP.Checked;
    info.asString['Address']:=RtcString(Trim(eAddress.Text));
    info.asString['Port']:=RtcString(Trim(ePort.Text));
    info.asBoolean['SSL']:=xSSL.Checked;
    info.asBoolean['ISAPI']:=xISAPI.Checked;
    info.asString['DLL']:=RtcString(Trim(eISAPI.Text));
    info.asString['SecureKey']:=RtcString(Trim(eSecureKey.Text));
    info.asBoolean['NoAutoReg']:=xNoAutoRegUsers.Checked;
    infos:=info.toCode;
    Crypt(infos,'RTC Gateway 2.0');
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

procedure TMainForm.xBindIPClick(Sender: TObject);
  begin
  eAddress.Enabled:=xBindIP.Checked;
  if eAddress.Enabled then eAddress.Color:=clWindow
  else eAddress.Color:=clGray;
  end;

procedure TMainForm.xISAPIClick(Sender: TObject);
  begin
  eISAPI.Enabled:=xISAPI.Checked;
  if eISAPI.Enabled then eISAPI.Color:=clWindow
  else eISAPI.Color:=clGray;
  end;

procedure TMainForm.btnInstallClick(Sender: TObject);
  begin
  SaveSetup;
  ShellExecute(0,'open',PChar(AppFileName),'/INSTALL',nil,SW_SHOW);
  end;

procedure TMainForm.btnUninstallClick(Sender: TObject);
  begin
  ShellExecute(0,'open',PChar(AppFileName),'/UNINSTALL',nil,SW_SHOW);
  end;

procedure TMainForm.btnRunClick(Sender: TObject);
  begin
  SaveSetup;
  ShellExecute(0,'open','net',PChar('start '+RTC_GATEWAYSERVICE_NAME),nil,SW_SHOW);
  end;

procedure TMainForm.btnRestartServiceClick(Sender: TObject);
  begin
  ShellExecute(0,'open','net',PChar('stop '+RTC_GATEWAYSERVICE_NAME),nil,SW_SHOW);
  Sleep(5000); // Wait 5 seconds for the Service to stop
  SaveSetup;
  ShellExecute(0,'open','net',PChar('start '+RTC_GATEWAYSERVICE_NAME),nil,SW_SHOW);
  Sleep(5000); // Wait 5 seconds for the Service to start
  Close;
  end;

procedure TMainForm.btnSaveSetupClick(Sender: TObject);
  begin
  SaveSetup;
  end;

procedure TMainForm.btnStopClick(Sender: TObject);
  begin
  ShellExecute(0,'open','net',PChar('stop '+RTC_GATEWAYSERVICE_NAME),nil,SW_SHOW);
  end;

procedure TMainForm.RtcGateTestProviderCheckRequest(
  Sender: TRtcConnection);
begin
  with TRtcDataServer(Sender) do
    if Request.FileName='/' then
      Accept;
end;

procedure TMainForm.RtcGateTestProviderDataReceived(
  Sender: TRtcConnection);
begin
  with TRtcDataServer(Sender) do
    if Request.Complete then
      begin
      Write('<HTML><BODY>');
      Write('RTC Portal Gateway is now ready to be used.<BR><BR>');
      Write('RTC Portal Host and Control can be downloaded from <a href="http://www.realthinclient.com">www.RealThinClient.com</a>');
      Write('</BODY></HTML>');
      end;
end;

procedure TMainForm.HttpServerListenError(Sender: TRtcConnection; E: Exception);
begin
  if not Sender.inMainThread then
    Sender.Sync(HttpServerListenError,E)
  else
    On_Error('Error: '+E.Message);
end;

procedure TMainForm.HttpServerListenLost(Sender: TRtcConnection);
begin
  if not Sender.inMainThread then
    Sender.Sync(HttpServerListenLost)
  else
    On_Error('Gateway Listener Lost');
end;

procedure TMainForm.GatewayUserLogin(const UserName: String);
  var
    a:integer;
    have:boolean;
    el:TListItem;
  begin
  have:=False;
  for a:=0 to eUsers.Items.Count-1 do
    if eUsers.Items[a].Caption=UserName then
      have:=True;
  if not have then
    begin
    el:=eUsers.Items.Add;
    el.Caption:=UserName;
    eUsers.Update;
    end;
  if eUsers.Items.Count=1 then
    begin
    eUsers.Enabled:=True;
    eUsers.Color:=clWindow;
    eUsers.ItemIndex:=0;
    end;
  end;

procedure TMainForm.GatewayUserLogout(const UserName: String);
  var
    a,i:integer;
  begin
  i:=-1;
  for a:=0 to eUsers.Items.Count-1 do
    if eUsers.Items[a].Caption=UserName then
      begin
      i:=a;
      Break;
      end;
  if i>=0 then
    begin
    if eUsers.ItemIndex=i then
      begin
      eUsers.ItemIndex:=-1;
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

end.
