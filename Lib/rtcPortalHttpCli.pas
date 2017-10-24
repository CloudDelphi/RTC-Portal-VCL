{ Copyright 2004-2017 (c) RealThinClient.com (http://www.realthinclient.com) }

unit rtcPortalHttpCli;

interface

{$INCLUDE rtcDefs.inc}

uses
  Classes, Windows, rtcConn, SysUtils,

  rtcTypes, rtcSystem, rtcPlugins,
  rtcPortalMod, rtcPortalCli, rtcHttpCli;

type
  TRtcPHttpConnStatus = (rtccClosed, rtccOpen, rtccSending, rtccReceiving,
    rtccError);

  TRtcHttpPortalClientEvent = procedure(Sender: TAbsPortalClient;
    Status: TRtcPHttpConnStatus) of object;

  TRtcHttpPortalClient = class(TRtcPortalCli)
  private
    FCliGet, FCliPut: TRtcHttpClient;

    FUseWinHttp: boolean;
    FUseSSL: boolean;
    FUseProxy: boolean;
    FMultiThreaded: boolean;
    FTimeout: integer;
    FGatewayPort: RtcString;
    FGatewayAddr: RtcString;
    FGatewayPath: RtcString;
    FGatewayIPV: RtcIPV;

    FOnStatusGet: TRtcHttpPortalClientEvent;
    FOnStatusPut: TRtcHttpPortalClientEvent;

    FProxyUserName: RtcString;
    FProxyBypass: RtcString;
    FProxyPassword: RtcString;
    FProxyAddr: RtcString;

    FCryptPlugin: TRtcCryptPlugin;

    procedure SetGatewayAddr(const Value: RtcString);
    procedure SetGatewayPort(const Value: RtcString);
    procedure SetGatewayIPV(const Value: RtcIPV);
    procedure SetMultiThreaded(const Value: boolean);
    procedure SetProxy(const Value: boolean);
    procedure SetSSSL(const Value: boolean);
    procedure SetTimeout(const Value: integer);
    procedure SetWinHttp(const Value: boolean);
    procedure SetGatewayPath(const Value: RtcString);

    procedure HttpClientConnect(Sender: TRtcConnection);
    procedure HttpClient2Connect(Sender: TRtcConnection);
    procedure HttpClientBeginRequest(Sender: TRtcConnection);
    procedure HttpClient2BeginRequest(Sender: TRtcConnection);
    procedure HttpClientResponseData(Sender: TRtcConnection);
    procedure HttpClient2ResponseData(Sender: TRtcConnection);
    procedure HttpClientResponseAbort(Sender: TRtcConnection);
    procedure HttpClient2ResponseAbort(Sender: TRtcConnection);
    procedure HttpClientResponseDone(Sender: TRtcConnection);
    procedure HttpClient2ResponseDone(Sender: TRtcConnection);
    procedure HttpClientDisconnect(Sender: TRtcConnection);
    procedure HttpClient2Disconnect(Sender: TRtcConnection);
    procedure HttpClientConnectError(Sender: TRtcConnection; E: Exception);
    procedure HttpClient2ConnectError(Sender: TRtcConnection; E: Exception);

    procedure SetConnected(const Value: boolean);
    function GetConnected: boolean;

    procedure SetProxyAddr(const Value: RtcString);
    procedure SetProxyBypass(const Value: RtcString);
    procedure SetProxyPassword(const Value: RtcString);
    procedure SetProxyUserName(const Value: RtcString);
    procedure SetCryptPlugin(const Value: TRtcCryptPlugin);

  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure Disconnect;
    procedure Stop;

  published
    property Connected: boolean read GetConnected write SetConnected
      default False;
    property MultiThreaded: boolean read FMultiThreaded write SetMultiThreaded
      default False;
    property GateAddr: RtcString read FGatewayAddr write SetGatewayAddr;
    property GatePort: RtcString read FGatewayPort write SetGatewayPort;
    property GateIPV: RtcIPV read FGatewayIPV write SetGatewayIPV default rtc_IPVDefault;

    property Gate_ISAPI: RtcString read FGatewayPath write SetGatewayPath;
    property Gate_Timeout: integer read FTimeout write SetTimeout default 30;

    { To use SSL/SSH encryption using third-party components, simply assign the encryption
      plug-in here before you start using the Client connection (before first connect). }
    property Gate_CryptPlugin: TRtcCryptPlugin read FCryptPlugin
      write SetCryptPlugin;

    property Gate_Proxy: boolean read FUseProxy write SetProxy default False;
    property Gate_SSL: boolean read FUseSSL write SetSSSL default False;
    property Gate_WinHttp: boolean read FUseWinHttp write SetWinHttp
      default False;

    { Proxy Address, including http:// or https:// depending on proxy type.
      This property should ONLY be set if you want to use a specific proxy
      and do not want to use default Internet Explorer or WinHTTP settings. }
    property Gate_ProxyAddr: RtcString read FProxyAddr write SetProxyAddr;
    { List of domains which should NOT go through the proxy specified in ProxyAddr.
      This option is ONLY used if ProxyAddr is set.
      When ProxyAddr is not set, default proxy settings will be used. }
    property Gate_ProxyBypass: RtcString read FProxyBypass write SetProxyBypass;
    // Proxy Username: needed for proxy servers where the user has to authenticate
    property Gate_ProxyUserName: RtcString read FProxyUserName
      write SetProxyUserName;
    // Proxy Password: needed for proxy servers where the user has to authenticate
    property Gate_ProxyPassword: RtcString read FProxyPassword
      write SetProxyPassword;

    property OnStatusGet: TRtcHttpPortalClientEvent read FOnStatusGet
      write FOnStatusGet;
    property OnStatusPut: TRtcHttpPortalClientEvent read FOnStatusPut
      write FOnStatusPut;
  end;

implementation

{ TRtcHttpPortalClient }

constructor TRtcHttpPortalClient.Create(AOwner: TComponent);
begin
  inherited;
  FTimeout := 30;

  FProxyUserName := '';
  FProxyBypass := '';
  FProxyPassword := '';
  FProxyAddr := '';
  FCryptPlugin := nil;
  FGatewayIPV := rtc_IPVDefault;

  FCliGet := TRtcHttpClient.Create(nil);
  FCliPut := TRtcHttpClient.Create(nil);

  FCliGet.AutoConnect := True;
  FCliGet.ServerIPV := FGatewayIPV;
  FCliGet.ReconnectOn.ConnectError := True;
  FCliGet.ReconnectOn.ConnectFail := True;
  FCliGet.ReconnectOn.ConnectLost := True;
  FCliGet.ReconnectOn.Wait := 2;
  FCliGet.Timeout.AfterConnecting := FTimeout;

  FCliPut.AutoConnect := True;
  FCliPut.ServerIPV := FGatewayIPV;
  FCliPut.ReconnectOn.ConnectError := True;
  FCliPut.ReconnectOn.ConnectFail := True;
  FCliPut.ReconnectOn.ConnectLost := True;
  FCliPut.ReconnectOn.Wait := 2;
  FCliPut.Timeout.AfterConnecting := FTimeout;

  FCliGet.OnConnect := HttpClientConnect;
  FCliPut.OnConnect := HttpClient2Connect;
  FCliGet.OnBeginRequest := HttpClientBeginRequest;
  FCliPut.OnBeginRequest := HttpClient2BeginRequest;
  FCliGet.OnResponseData := HttpClientResponseData;
  FCliPut.OnResponseData := HttpClient2ResponseData;
  FCliGet.OnResponseAbort := HttpClientResponseAbort;
  FCliPut.OnResponseAbort := HttpClient2ResponseAbort;
  FCliGet.OnResponseDone := HttpClientResponseDone;
  FCliPut.OnResponseDone := HttpClient2ResponseDone;
  FCliGet.OnDisconnect := HttpClientDisconnect;
  FCliPut.OnDisconnect := HttpClient2Disconnect;
  FCliGet.OnConnectError := HttpClientConnectError;
  FCliPut.OnConnectError := HttpClient2ConnectError;

  Client_Get := FCliGet;
  Client_Put := FCliPut;

  ModuleFileName := '/$rdgate';
end;

destructor TRtcHttpPortalClient.Destroy;
begin
  Client_Get := nil;
  Client_Put := nil;

  FCliGet.Free;
  FCliPut.Free;
  inherited;
end;

procedure TRtcHttpPortalClient.SetGatewayAddr(const Value: RtcString);
begin
  if FGatewayAddr <> Value then
  begin
    Disconnect;
    FGatewayAddr := Value;
    FCliGet.ServerAddr := FGatewayAddr;
    FCliPut.ServerAddr := FGatewayAddr;
    ModuleHost := FGatewayAddr;
  end;
end;

procedure TRtcHttpPortalClient.SetGatewayPath(const Value: RtcString);
begin
  if FGatewayPath <> Value then
  begin
    Disconnect;
    FGatewayPath := trim(Value);
    if FGatewayPath = '' then
      ModuleFileName := '/$rdgate'
    else
      ModuleFileName := FGatewayPath + '/gate';
  end;
end;

procedure TRtcHttpPortalClient.SetGatewayPort(const Value: RtcString);
begin
  if FGatewayPort <> Value then
  begin
    Disconnect;
    FGatewayPort := Value;
    FCliGet.ServerPort := FGatewayPort;
    FCliPut.ServerPort := FGatewayPort;
  end;
end;

procedure TRtcHttpPortalClient.SetGatewayIPV(const Value: RtcIPV);
begin
  if FGatewayIPV <> Value then
  begin
    Disconnect;
    FGatewayIPV := Value;
    FCliGet.ServerIPV := FGatewayIPV;
    FCliPut.ServerIPV := FGatewayIPV;
  end;
end;

procedure TRtcHttpPortalClient.SetMultiThreaded(const Value: boolean);
begin
  if FMultiThreaded <> Value then
  begin
    Disconnect;
    FMultiThreaded := Value;
    FCliGet.MultiThreaded := FMultiThreaded;
    FCliPut.MultiThreaded := FMultiThreaded;
  end;
end;

procedure TRtcHttpPortalClient.SetProxy(const Value: boolean);
begin
  if FUseProxy <> Value then
  begin
    Disconnect;
    FUseProxy := Value;
    FCliGet.UseProxy := FUseProxy;
    FCliPut.UseProxy := FUseProxy;
  end;
end;

procedure TRtcHttpPortalClient.SetSSSL(const Value: boolean);
begin
  if FUseSSL <> Value then
  begin
    Disconnect;
    FUseSSL := Value;
    FCliGet.UseSSL := FUseSSL;
    FCliPut.UseSSL := FUseSSL;
  end;
end;

procedure TRtcHttpPortalClient.SetWinHttp(const Value: boolean);
begin
  if FUseWinHttp <> Value then
  begin
    Disconnect;
    FUseWinHttp := Value;
    FCliGet.UseWinHTTP := FUseWinHttp;
    FCliPut.UseWinHTTP := FUseWinHttp;
  end;
end;

procedure TRtcHttpPortalClient.SetProxyAddr(const Value: RtcString);
begin
  if FProxyAddr <> Value then
  begin
    Disconnect;
    FProxyAddr := Value;
    FCliGet.UserLogin.ProxyAddr := FProxyAddr;
    FCliPut.UserLogin.ProxyAddr := FProxyAddr;
  end;
end;

procedure TRtcHttpPortalClient.SetProxyBypass(const Value: RtcString);
begin
  if FProxyBypass <> Value then
  begin
    Disconnect;
    FProxyBypass := Value;
    FCliGet.UserLogin.ProxyBypass := FProxyBypass;
    FCliPut.UserLogin.ProxyBypass := FProxyBypass;
  end;
end;

procedure TRtcHttpPortalClient.SetCryptPlugin(const Value: TRtcCryptPlugin);
begin
  if FCryptPlugin <> Value then
  begin
    Disconnect;
    FCryptPlugin := Value;
    FCliGet.CryptPlugin := Value;
    FCliPut.CryptPlugin := Value;
  end;
end;

procedure TRtcHttpPortalClient.SetProxyPassword(const Value: RtcString);
begin
  if FProxyPassword <> Value then
  begin
    Disconnect;
    FProxyPassword := Value;
    FCliGet.UserLogin.ProxyPassword := FProxyPassword;
    FCliPut.UserLogin.ProxyPassword := FProxyPassword;
  end;
end;

procedure TRtcHttpPortalClient.SetProxyUserName(const Value: RtcString);
begin
  if FProxyUserName <> Value then
  begin
    Disconnect;
    FProxyUserName := Value;
    FCliGet.UserLogin.ProxyUserName := FProxyUserName;
    FCliPut.UserLogin.ProxyUserName := FProxyUserName;
  end;
end;

procedure TRtcHttpPortalClient.SetTimeout(const Value: integer);
begin
  if FTimeout <> Value then
  begin
    FTimeout := Value;
    FCliGet.Timeout.AfterConnecting := FTimeout;
    FCliPut.Timeout.AfterConnecting := FTimeout;
  end;
end;

procedure TRtcHttpPortalClient.Disconnect;
begin
  FCliGet.SkipRequests;
  FCliPut.SkipRequests;

  FCliGet.Disconnect;
  FCliPut.Disconnect;
end;

procedure TRtcHttpPortalClient.Stop;
begin
  if Connected then
  begin
    FCliGet.AutoConnect := False;
    FCliPut.AutoConnect := False;

    FCliGet.SkipRequests;
    FCliPut.SkipRequests;

    FCliGet.DisconnectNow(True);
    FCliPut.DisconnectNow(True);

    FCliGet.SkipRequests;
    FCliPut.SkipRequests;

    FCliGet.AutoConnect := True;
    FCliPut.AutoConnect := True;
  end;
end;

procedure TRtcHttpPortalClient.HttpClientConnect(Sender: TRtcConnection);
begin
  if assigned(FOnStatusGet) then
    if AutoSyncEvents and not Sender.inMainThread then
      Sender.Sync(HttpClientConnect)
    else
      FOnStatusGet(self, rtccOpen); // OK
end;

procedure TRtcHttpPortalClient.HttpClient2Connect(Sender: TRtcConnection);
begin
  if assigned(FOnStatusPut) then
    if AutoSyncEvents and not Sender.inMainThread then
      Sender.Sync(HttpClient2Connect)
    else
      FOnStatusPut(self, rtccOpen); // OK
end;

procedure TRtcHttpPortalClient.HttpClientBeginRequest(Sender: TRtcConnection);
begin
  if assigned(FOnStatusGet) then
    if AutoSyncEvents and not Sender.inMainThread then
      Sender.Sync(HttpClientBeginRequest)
    else
      FOnStatusGet(self, rtccSending); // Begin Request
end;

procedure TRtcHttpPortalClient.HttpClient2BeginRequest(Sender: TRtcConnection);
begin
  if assigned(FOnStatusPut) then
    if AutoSyncEvents and not Sender.inMainThread then
      Sender.Sync(HttpClient2BeginRequest)
    else
      FOnStatusPut(self, rtccSending); // Begin Request
end;

procedure TRtcHttpPortalClient.HttpClientResponseData(Sender: TRtcConnection);
begin
  if assigned(FOnStatusGet) then
    if AutoSyncEvents and not Sender.inMainThread then
      Sender.Sync(HttpClientResponseData)
    else
      FOnStatusGet(self, rtccReceiving); // Receiving
end;

procedure TRtcHttpPortalClient.HttpClient2ResponseData(Sender: TRtcConnection);
begin
  if assigned(FOnStatusPut) then
    if AutoSyncEvents and not Sender.inMainThread then
      Sender.Sync(HttpClient2ResponseData)
    else
      FOnStatusPut(self, rtccReceiving); // Receiving
end;

procedure TRtcHttpPortalClient.HttpClientResponseAbort(Sender: TRtcConnection);
begin
  if assigned(FOnStatusGet) then
    if AutoSyncEvents and not Sender.inMainThread then
      Sender.Sync(HttpClientResponseAbort)
    else
      FOnStatusGet(self, rtccError); // Error
end;

procedure TRtcHttpPortalClient.HttpClient2ResponseAbort(Sender: TRtcConnection);
begin
  if assigned(FOnStatusPut) then
    if AutoSyncEvents and not Sender.inMainThread then
      Sender.Sync(HttpClient2ResponseAbort)
    else
      FOnStatusPut(self, rtccError); // Error
end;

procedure TRtcHttpPortalClient.HttpClientResponseDone(Sender: TRtcConnection);
begin
  if assigned(FOnStatusGet) then
    if AutoSyncEvents and not Sender.inMainThread then
      Sender.Sync(HttpClientResponseDone)
    else
      FOnStatusGet(self, rtccOpen); // Response Done
end;

procedure TRtcHttpPortalClient.HttpClient2ResponseDone(Sender: TRtcConnection);
begin
  if assigned(FOnStatusPut) then
    if AutoSyncEvents and not Sender.inMainThread then
      Sender.Sync(HttpClient2ResponseDone)
    else
      FOnStatusPut(self, rtccOpen); // Response Done
end;

procedure TRtcHttpPortalClient.HttpClientDisconnect(Sender: TRtcConnection);
begin
  if assigned(FOnStatusGet) then
    if AutoSyncEvents and not Sender.inMainThread then
      Sender.Sync(HttpClientDisconnect)
    else
      FOnStatusGet(self, rtccClosed); // Disconnected
end;

procedure TRtcHttpPortalClient.HttpClient2Disconnect(Sender: TRtcConnection);
begin
  if assigned(FOnStatusPut) then
    if AutoSyncEvents and not Sender.inMainThread then
      Sender.Sync(HttpClient2Disconnect)
    else
      FOnStatusPut(self, rtccClosed); // Disconnected
end;

procedure TRtcHttpPortalClient.HttpClientConnectError(Sender: TRtcConnection;
  E: Exception);
begin
  if assigned(FOnStatusGet) then
    if AutoSyncEvents and not Sender.inMainThread then
      Sender.Sync(HttpClientConnectError, E)
    else
      FOnStatusGet(self, rtccError); // Error
end;

procedure TRtcHttpPortalClient.HttpClient2ConnectError(Sender: TRtcConnection;
  E: Exception);
begin
  if assigned(FOnStatusPut) then
    if AutoSyncEvents and not Sender.inMainThread then
      Sender.Sync(HttpClient2ConnectError, E)
    else
      FOnStatusPut(self, rtccError); // Error
end;

procedure TRtcHttpPortalClient.SetConnected(const Value: boolean);
begin
  if Value then
  begin
    FCliGet.Connect;
    FCliPut.Connect;
  end
  else
    Disconnect;
end;

function TRtcHttpPortalClient.GetConnected: boolean;
begin
  if assigned(FCliGet) and assigned(FCliPut) then
    Result := FCliGet.isConnected or FCliPut.isConnected
  else
    Result := False;
end;

end.
