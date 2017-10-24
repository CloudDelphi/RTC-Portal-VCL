{ Copyright 2004-2017 (c) RealThinClient.com (http://www.realthinclient.com) }

unit rtcpChatUI;

interface

{$INCLUDE rtcDefs.inc}

uses
  Windows, Classes, SysUtils,
{$IFNDEF IDE_1}
  Variants,
{$ENDIF}
  rtcSystem, rtcLog,
  rtcInfo, rtcpChat;

type
  TRtcPChatUI = class;

  TRtcPChatUIEvent = procedure(Sender: TRtcPChatUI) of object;

  TRtcPChatUI = class(TRtcAbsPChatUI)
  private
    FUserCnt: integer;

    FRecvUser: String;
    FRecvMessage: String;

    FOnInit: TRtcPChatUIEvent;
    FOnOpen: TRtcPChatUIEvent;
    FOnClose: TRtcPChatUIEvent;

    FOnUserJoined: TRtcPChatUIEvent;
    FOnUserLeft: TRtcPChatUIEvent;
    FOnMessage: TRtcPChatUIEvent;

    FOnError: TRtcPChatUIEvent;
    FOnLogOut: TRtcPChatUIEvent;
    function GetActive: boolean;
    procedure SetActive(const Value: boolean);

  protected

    procedure xOnInit(Sender, Obj: TObject);
    procedure xOnOpen(Sender, Obj: TObject);
    procedure xOnClose(Sender, Obj: TObject);

    procedure xOnUserJoined(Sender, Obj: TObject);
    procedure xOnUserLeft(Sender, Obj: TObject);
    procedure xOnMessage(Sender, Obj: TObject);

    procedure xOnError(Sender, Obj: TObject);
    procedure xOnLogOut(Sender, Obj: TObject);

  protected
    procedure Call_LogOut(Sender: TObject); override;
    procedure Call_Error(Sender: TObject); override;

    procedure Call_Init(Sender: TObject); override;
    procedure Call_Open(Sender: TObject); override;
    procedure Call_Close(Sender: TObject); override;

    procedure Call_UserJoined(Sender: TObject; const user: String); override;
    procedure Call_UserLeft(Sender: TObject; const user: String); override;
    procedure Call_Message(Sender: TObject; const user, msg: String); override;

  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

  published
    property Active: boolean read GetActive write SetActive default False;

    { Name of the user from whom we have received a message }
    property Recv_User: String read FRecvUser;
    { Message received }
    property Recv_Message: String read FRecvMessage;

    { Chat room needed. If not already open, initialize it now.
      OnOpen event will follow if chat room was not open.
      Sender = this TRtcPChatUI object }
    property OnInit: TRtcPChatUIEvent read FOnInit write FOnInit;
    { Chat room opened.
      Sender = this TRtcPChatUI object }
    property OnOpen: TRtcPChatUIEvent read FOnOpen write FOnOpen;
    { Chat room closed by user.
      Sender = this TRtcPChatUI object }
    property OnClose: TRtcPChatUIEvent read FOnClose write FOnClose;

    { Error received, chat room closed.
      Sender = this TRtcPChatUI object }
    property OnError: TRtcPChatUIEvent read FOnError write FOnError;
    { User logged out, chat room closed.
      Sender = this TRtcPChatUI object }
    property OnLogOut: TRtcPChatUIEvent read FOnLogOut write FOnLogOut;

    { New user joined this chat room:
      Sender = this TRtcPChatUI object
      Sender.Recv_User = User name }
    property OnUserJoined: TRtcPChatUIEvent read FOnUserJoined
      write FOnUserJoined;
    { User left this chat room:
      Sender = this TRtcPChatUI object
      Sender.Recv_User = User name }
    property OnUserLeft: TRtcPChatUIEvent read FOnUserLeft write FOnUserLeft;
    { Message received from user:
      Sender = this TRtcPChatUI object
      Sender.Recv_User = User name
      Sender.Recv_Message = Message text }
    property OnMessage: TRtcPChatUIEvent read FOnMessage write FOnMessage;
  end;

implementation

{ TRtcPChatUI }

constructor TRtcPChatUI.Create(AOwner: TComponent);
begin
  inherited;
  FUserCnt := 0;
end;

destructor TRtcPChatUI.Destroy;
begin
  inherited;
end;

procedure TRtcPChatUI.Call_Init(Sender: TObject);
begin
  if assigned(FOnInit) then
    Module.CallEvent(Sender, xOnInit, self);
end;

procedure TRtcPChatUI.Call_Open(Sender: TObject);
begin
  Inc(FUserCnt);
  if FUserCnt = 1 then
    if assigned(FOnOpen) then
      Module.CallEvent(Sender, xOnOpen, self);
end;

procedure TRtcPChatUI.Call_Close(Sender: TObject);
begin
  if FUserCnt > 0 then
  begin
    Dec(FUserCnt);
    if FUserCnt = 0 then
    begin
      if assigned(FOnClose) then
        Module.CallEvent(Sender, xOnClose, self);
    end;
  end;
end;

procedure TRtcPChatUI.Call_Error(Sender: TObject);
begin
  FUserCnt := 0;

  if assigned(FOnError) then
    Module.CallEvent(Sender, xOnError, self);
end;

procedure TRtcPChatUI.Call_LogOut(Sender: TObject);
begin
  FUserCnt := 0;

  if assigned(FOnLogOut) then
    Module.CallEvent(Sender, xOnLogOut, self);
end;

procedure TRtcPChatUI.Call_UserJoined(Sender: TObject; const user: String);
begin
  FRecvUser := user;

  if assigned(FOnUserJoined) then
    Module.CallEvent(Sender, xOnUserJoined, self);
end;

procedure TRtcPChatUI.Call_UserLeft(Sender: TObject; const user: String);
begin
  FRecvUser := user;

  if assigned(FOnUserLeft) then
    Module.CallEvent(Sender, xOnUserLeft, self);
end;

procedure TRtcPChatUI.Call_Message(Sender: TObject; const user, msg: String);
begin
  FRecvUser := user;
  FRecvMessage := msg;

  if assigned(FOnMessage) then
    Module.CallEvent(Sender, xOnMessage, self);
end;

procedure TRtcPChatUI.xOnClose(Sender, Obj: TObject);
begin
  FOnClose(self);
end;

procedure TRtcPChatUI.xOnError(Sender, Obj: TObject);
begin
  FOnError(self);
end;

procedure TRtcPChatUI.xOnInit(Sender, Obj: TObject);
begin
  FOnInit(self);
end;

procedure TRtcPChatUI.xOnLogOut(Sender, Obj: TObject);
begin
  FOnLogOut(self);
end;

procedure TRtcPChatUI.xOnMessage(Sender, Obj: TObject);
begin
  FOnMessage(self);
end;

procedure TRtcPChatUI.xOnOpen(Sender, Obj: TObject);
begin
  FOnOpen(self);
end;

procedure TRtcPChatUI.xOnUserJoined(Sender, Obj: TObject);
begin
  FOnUserJoined(self);
end;

procedure TRtcPChatUI.xOnUserLeft(Sender, Obj: TObject);
begin
  FOnUserLeft(self);
end;

function TRtcPChatUI.GetActive: boolean;
begin
  Result := FUserCnt > 0;
end;

procedure TRtcPChatUI.SetActive(const Value: boolean);
begin
  if Value then
    Open
  else
  begin
    FUserCnt := 0;
    Close;
  end;
end;

end.
