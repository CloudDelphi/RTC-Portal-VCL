unit rdSetClient;  

interface

uses
  Windows, Messages, SysUtils,
  Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons,

  rtcTypes, rtcConn, rtcHttpCli, rtcPortalCli, rtcPortalHttpCli;

type
  TrdClientSettings = class(TForm)
    Label2: TLabel;
    Label7: TLabel;
    Label13: TLabel;
    Label22: TLabel;
    Label18: TLabel;
    eAddress: TEdit;
    ePort: TEdit;
    eSecureKey: TEdit;
    xProxy: TCheckBox;
    xSSL: TCheckBox;
    eISAPI: TEdit;
    xISAPI: TCheckBox;
    cbCompress: TComboBox;
    Label12: TLabel;
    btnCancel: TBitBtn;
    btnOK: TBitBtn;
    xWinHTTP: TCheckBox;
    gProxy: TGroupBox;
    Label1: TLabel;
    eProxyAddr: TEdit;
    Label4: TLabel;
    eProxyUsername: TEdit;
    eProxyPassword: TEdit;
    Label5: TLabel;

    procedure xSSLClick(Sender: TObject);
    procedure xISAPIClick(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure btnOKClick(Sender: TObject);
    procedure xProxyClick(Sender: TObject);

  private
    { Private declarations }

  public
    { Public declarations }
    PClient:TRtcHttpPortalClient;

    procedure Setup;

    function Execute:boolean;
  end;

implementation

{$R *.dfm}

procedure TrdClientSettings.xSSLClick(Sender: TObject);
  begin
  if xSSL.Checked and (ePort.Text='80') then
    ePort.Text:='443'
  else if not xSSL.Checked and (ePort.Text='443') then
    ePort.Text:='80';
  end;

procedure TrdClientSettings.xISAPIClick(Sender: TObject);
  begin
  eISAPI.Enabled:=xISAPI.Checked;
  if eISAPI.Enabled then
    eISAPI.Color:=clWindow
  else
    eISAPI.Color:=clGray;
  end;

procedure TrdClientSettings.Setup;
  begin
  xProxy.Checked:=PClient.Gate_Proxy;
  xWinHTTP.Checked:=PClient.Gate_WinHttp;
  xSSL.Checked:=PClient.Gate_SSL;

  eAddress.Text:=String(PClient.GateAddr);
  ePort.Text:=String(PClient.GatePort);

  if PClient.Gate_ISAPI<>'' then
    begin
    xISAPI.Checked:=True;
    eISAPI.Text:=String(PClient.Gate_ISAPI);
    end
  else
    begin
    xISAPI.Checked:=False;
    eISAPI.Text:='';
    end;

  if PClient.Gate_Proxy or PClient.Gate_WinHttp then
    begin
    eProxyAddr.Text:=PClient.Gate_ProxyAddr;
    eProxyUsername.Text:=PClient.Gate_ProxyUserName;
    eProxyPassword.Text:=PClient.Gate_ProxyPassword;
    end
  else
    begin
    eProxyAddr.Text:='';
    eProxyUsername.Text:='';
    eProxyPassword.Text:='';
    end;

  eSecureKey.Text:=String(PClient.DataSecureKey);
  cbCompress.ItemIndex:=Ord(PClient.DataCompress);
  end;

procedure TrdClientSettings.btnCancelClick(Sender: TObject);
  begin
  ModalResult:=mrCancel;
  end;

procedure TrdClientSettings.btnOKClick(Sender: TObject);
  begin
  PClient.GateAddr:=RtcString(Trim(eAddress.Text));
  PClient.GatePort:=RtcString(Trim(ePort.Text));
  PClient.Gate_Proxy:=xProxy.Checked;
  PClient.Gate_WinHttp:=xWinHTTP.Checked;
  PClient.Gate_SSL:=xSSL.Checked;

  if PClient.Gate_Proxy or PClient.Gate_WinHttp then
    begin
    PClient.Gate_ProxyAddr:=eProxyAddr.Text;
    PClient.Gate_ProxyUserName:=eProxyUsername.Text;
    PClient.Gate_ProxyPassword:=eProxyPassword.Text;
    end
  else
    begin
    PClient.Gate_ProxyAddr:='';
    PClient.Gate_ProxyUserName:='';
    PClient.Gate_ProxyPassword:='';
    end;

  if xISAPI.Checked then
    PClient.Gate_ISAPI:=RtcString(Trim(eISAPI.Text))
  else
    PClient.Gate_ISAPI:='';

  PClient.DataSecureKey:=RtcString(Trim(eSecureKey.Text));
  PClient.DataCompress:=TRtcpCompressLevel(cbCompress.ItemIndex);

  ModalResult:=mrOk;
  end;

function TrdClientSettings.Execute: boolean;
  begin
  Setup;
  Result:=ShowModal=mrOk;
  end;

procedure TrdClientSettings.xProxyClick(Sender: TObject);
  begin
  gProxy.Enabled:=xProxy.Checked or xWinHTTP.Checked;
  if gProxy.Enabled then
    begin
    eProxyAddr.Color:=clWindow;
    eProxyUsername.Color:=clWindow;
    eProxyPassword.Color:=clWindow;
    end
  else
    begin
    eProxyAddr.Color:=clGray;
    eProxyUsername.Color:=clGray;
    eProxyPassword.Color:=clGray;
    end;
  end;

end.
