{ Copyright 2004-2017 (c) RealThinClient.com (http://www.realthinclient.com) }

unit rtcpChat;

interface

{$INCLUDE rtcDefs.inc}

uses
  Windows, Classes, SysUtils,
{$IFNDEF IDE_1}
  Variants,
{$ENDIF}
  rtcLog, SyncObjs,
  rtcInfo, rtcPortalMod;

type
  // forward
  TRtcPChat = class;

  TRtcAbsPChatUI = class(TRtcPortalComponent)
  private
    FModule: TRtcPChat;
    FUserName: String;
    FCleared: boolean;
    FLocked: integer;

    function GetModule: TRtcPChat;
    procedure SetModule(const Value: TRtcPChat);

    function GetUserName: String;
    procedure SetUserName(const Value: String);

  protected
    procedure Call_LogOut(Sender: TObject); virtual; abstract;
    procedure Call_Error(Sender: TObject); virtual; abstract;

    procedure Call_Init(Sender: TObject); virtual; abstract;
    procedure Call_Open(Sender: TObject); virtual; abstract;
    procedure Call_Close(Sender: TObject); virtual; abstract;

    procedure Call_UserJoined(Sender: TObject; const user: String);
      virtual; abstract;
    procedure Call_UserLeft(Sender: TObject; const user: String);
      virtual; abstract;
    procedure Call_Message(Sender: TObject; const user, msg: String);
      virtual; abstract;

    property Cleared: boolean read FCleared;
    property Locked: integer read FLocked write FLocked;

  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    // Prepare Chat
    procedure Open(Sender: TObject = nil); virtual;
    // Terminate Chat
    procedure Close(Sender: TObject = nil); virtual;

    // Close Chat and clear the "Module" property. The component is about to be freed.
    // Returns TRUE if the component may be destroyed now, FALSE if not.
    // If FALSE was returned, OnLogOut event will be triggered when the component may be destroyed.
    function CloseAndClear(Sender: TObject = nil): boolean; virtual;

    // Send message "Msg".
    procedure Send(const msg: String; Sender: TObject = nil); virtual;

  published
    { Chat Module used for sending and receiving messages. }
    property Module: TRtcPChat read GetModule write SetModule;
    { Name of the Chat room owner }
    property UserName: String read GetUserName write SetUserName;
  end;

  TRtcPChatRoomEvent = procedure(Sender: TRtcPChat; const user: String)
    of object;
  TRtcPChatRoomUserEvent = procedure(Sender: TRtcPChat;
    const chatroom, user: String) of object;
  TRtcPChatRoomUserMsgEvent = procedure(Sender: TRtcPChat;
    const chatroom, user, msg: String) of object;

  TRtcPChat = class(TRtcPModule)
  private
    CSUI: TCriticalSection;
    UIs: TRtcInfo;

    AmHost: TRtcRecord;
    AmHostCnt: integer;

    FAllow: boolean;
    FAllowSuper: boolean;

    FOnChatInit: TRtcPChatRoomEvent;
    FOnChatOpen: TRtcPChatRoomEvent;
    FOnChatClose: TRtcPChatRoomEvent;
    FOnChatUserJoined: TRtcPChatRoomUserEvent;
    FOnChatUserLeft: TRtcPChatRoomUserEvent;
    FOnChatMessage: TRtcPChatRoomUserMsgEvent;

    FOnNewUI: TRtcPChatRoomEvent;

    FAccessControl: boolean;
    FGatewayParams: boolean;
    FHostMode: boolean;

    function MayJoinChat(const user: String): boolean;

    procedure Event_Error(Sender: TObject);
    procedure Event_Logout(Sender: TObject);

    procedure Event_ChatInit(Sender: TObject; const room: String);
    procedure Event_ChatOpen(Sender: TObject; const room: String);
    procedure Event_ChatClose(Sender: TObject; const room: String);

    procedure Event_ChatUserJoined(Sender: TObject; const room, user: String);
    procedure Event_ChatUserLeft(Sender: TObject; const room, user: String);
    procedure Event_ChatMessage(Sender: TObject; const room, user, msg: String);

    procedure CallChatEvent(Sender: TObject; Event: TRtcCustomDataEvent;
      const room, user, msg: String); overload;
    procedure CallChatEvent(Sender: TObject; Event: TRtcCustomDataEvent;
      const room, user: String); overload;
    procedure CallChatEvent(Sender: TObject; Event: TRtcCustomDataEvent;
      const room: String); overload;

    function LockUI(const UserName: String): TRtcAbsPChatUI;
    procedure UnlockUI(UI: TRtcAbsPChatUI);

    function GetAllow: boolean;
    procedure SetAllow(const Value: boolean);

    function GetAllowSuper: boolean;
    procedure SetAllowSuper(const Value: boolean);

  protected

    procedure xOnChatInit(Sender, Obj: TObject; Data: TRtcValue);
    procedure xOnChatOpen(Sendeer, Obj: TObject; Data: TRtcValue);
    procedure xOnChatClose(Sendeer, Obj: TObject; Data: TRtcValue);
    procedure xOnChatUserJoined(Sendeer, Obj: TObject; Data: TRtcValue);
    procedure xOnChatUserLeft(Sendeer, Obj: TObject; Data: TRtcValue);
    procedure xOnChatMessage(Sendeer, Obj: TObject; Data: TRtcValue);

    procedure xOnNewUI(Sendeer, Obj: TObject; Data: TRtcValue);

  protected

    // function SenderLoop_Check(Sender:TObject):boolean; override;
    // procedure SenderLoop_Prepare(Sender:TObject); override;
    // procedure SenderLoop_Execute(Sender:TObject); override;

    // procedure Call_LogIn(Sender:TObject); override;
    procedure Call_LogOut(Sender: TObject); override;
    procedure Call_Error(Sender: TObject; Data: TRtcValue); override;
    procedure Call_FatalError(Sender: TObject; Data: TRtcValue); override;

    procedure Call_Start(Sender: TObject; Data: TRtcValue); override;
    procedure Call_Params(Sender: TObject; Data: TRtcValue); override;

    // procedure Call_BeforeData(Sender:TObject); override;

    // procedure Call_UserLoggedIn(Sender:TObject; const uname:String); override;
    // procedure Call_UserLoggedOut(Sender:TObject; const uname:String); override;

    procedure Call_UserJoinedMyGroup(Sender: TObject; const group: String;
      const uname: String; uinfo:TRtcRecord); override;
    procedure Call_UserLeftMyGroup(Sender: TObject; const group: String;
      const uname: String); override;

    procedure Call_JoinedUsersGroup(Sender: TObject; const group: String;
      const uname: String; uinfo:TRtcRecord); override;
    procedure Call_LeftUsersGroup(Sender: TObject; const group: String;
      const uname: String); override;

    procedure Call_DataFromUser(Sender: TObject; const uname: String;
      Data: TRtcFunctionInfo); override;

    // procedure Call_AfterData(Sender:TObject); override;

    procedure Init; override;

    procedure AddUI(UI: TRtcAbsPChatUI);
    procedure RemUI(UI: TRtcAbsPChatUI);

  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    { Open chatroom.
      When BeTheHost=True, "Username" is invited to our own chatroom.
      When BeTheHost=False, we ask to join chatroom maintained by user "Username". }
    procedure Open(const UserName: String; Sender: TObject = nil);
    { Close chatroom.
      Called with own username, disbands our own chatroom and kicks all users out.
      Called with a username of a user that was invited to join our chatroo, the user is kicked out.
      If we were invited to a group maintained by "Username", we leave that chat group. }
    procedure Close(const UserName: String; Sender: TObject = nil);
    { Send message "Msg".
      Called with own username, sends the message to all users in our own chatroom.
      Called with a specific username, sends the message only to that specific user,
      or to user's whole chatroom if we were invited to a chatroom by that user. }
    procedure Send(const UserName, msg: String; Sender: TObject = nil);

  published
    { Chat has 2 sides. For two clients to be able to chat,
      at least one side has to have BeTheHost property set to True.
      You can NOT initiate chat between two clients if they both have BeTheHost=False.
      On the other hand, if two clients have BeTheHost=True, the one to initiate
      chat will become the chat host for the duration of the chat session.
      The chat host can invite any number of clients to his chat, while any client
      with BeTheHost=False (and appriproate rights) can join the chat hosted by this client. }
    property BeTheHost: boolean read FHostMode write FHostMode default False;

    { Set to TRUE if you wish to store access right parameters on the Gateway
      and load parameters from the Gateway after Activating the component.
      When gwStoreParams is FALSE, parameter changes will NOT be sent to the Gateway,
      nor will current parameters stored on the Gateway be loaded on start. }
    property GwStoreParams: boolean read FGatewayParams write FGatewayParams
      default False;

    { Allow other users to Join our chat?
      If gwStoreParams=True, this parameter will be stored on the Gateway. }
    property GAllowJoin: boolean read GetAllow write SetAllow default True;
    { Allow other super users to Join our chat?
      If gwStoreParams=True, this parameter will be stored on the Gateway. }
    property GAllowJoin_Super: boolean read GetAllowSuper write SetAllowSuper
      default True;

    { Set to FALSE if you want to ignore Access right settings and allow all actions,
      regardless of user lists and AllowJoin parameters set by this user. }
    property AccessControl: boolean read FAccessControl write FAccessControl
      default True;

    { This event will be triggered when a RtcPChatUI component is required, but still not assigned for this user.
      You should create a new ChatUI component in this event and assign this component to it's Module property.
      The ChatUI component will then take care of processing all events received from that user. }
    property OnNewUI: TRtcPChatRoomEvent read FOnNewUI write FOnNewUI;

    { On the Host side: User with username = "user" is asking for access to our Chat.

      On the Viewer/Control side: User with username = "user" has invited us to his Chat (allowed access).
      This event can be used on the Control side when you want the Host to initiate the Chat and
      allow the Control to be notified before a Chat window pops up wide open.

      Note that ONLY users with granted access will trigger this event. If you have already limited
      access to this Host by using the AllowUsersList, users who are NOT on that list will be ignored
      and no events will be triggered for them. So ... you could leave this event empty (not implemented)
      if you want to allow access to all users with granted access rights, or you could implement this event
      to set the "Allow" parmeter (passed into the event as TRUE) saying if this user may access our Chat.

      If you implement this event, make sure it will not take longer than 20 seconds to complete, because
      this code is executed from the context of a connection component responsible for receiving data from
      the Gateway and if this component does not return to the Gateway before time runs out, the client will
      be disconnected from the Gateway. If you implement this event by using a dialog for the user, that dialog
      will have to auto-close whithin no more than 20 seconds automatically, selecting what ever you find apropriate. }
    property OnQueryAccess;
    { We have a new Chat user, username = "Data.asText";
      You can use this event to maintain a list of active Chat users. }
    property OnUserJoined;
    { User "Data.asText" no longer has Chat open with us.
      You can use this event to maintain a list of active Chat users. }
    property OnUserLeft;

    { *Optional* These events can be used for general monitoring. }
    property On_ChatInit: TRtcPChatRoomEvent read FOnChatInit write FOnChatInit;
    property On_ChatOpen: TRtcPChatRoomEvent read FOnChatOpen write FOnChatOpen;
    property On_ChatClose: TRtcPChatRoomEvent read FOnChatClose
      write FOnChatClose;
    property On_ChatUserJoined: TRtcPChatRoomUserEvent read FOnChatUserJoined
      write FOnChatUserJoined;
    property On_ChatUserLeft: TRtcPChatRoomUserEvent read FOnChatUserLeft
      write FOnChatUserLeft;
    property On_ChatMessage: TRtcPChatRoomUserMsgEvent read FOnChatMessage
      write FOnChatMessage;
  end;

implementation

{ TRtcPChat }

constructor TRtcPChat.Create(AOwner: TComponent);
begin
  inherited;
  CSUI := TCriticalSection.Create;
  UIs := TRtcInfo.Create;

  FHostMode := False;
  FAllow := True;
  FAllowSuper := True;
  FAccessControl := True;

  AmHost := TRtcRecord.Create;
  AmHostCnt := 0;
end;

destructor TRtcPChat.Destroy;
var
  i: integer;
  x: String;
begin
  CSUI.Acquire;
  try
    for i := 0 to UIs.Count - 1 do
    begin
      x := UIs.FieldName[i];
      if UIs.asBoolean[x] and assigned(UIs.asPtr[x]) then
        TRtcAbsPChatUI(UIs.asPtr[x]).Module := nil;
    end;
    UIs.Clear;
  finally
    CSUI.Release;
  end;

  AmHost.Free;
  UIs.Free;
  CSUI.Free;
  inherited;
end;

procedure TRtcPChat.Call_Start(Sender: TObject; Data: TRtcValue);
begin
end;

procedure TRtcPChat.Call_Params(Sender: TObject; Data: TRtcValue);
begin
  if FGatewayParams then
    if Data.isType = rtc_Record then
      with Data.asRecord do
      begin
        FAllow := not asBoolean['NoChat'];
        FAllowSuper := not asBoolean['NoSuperChat'];
      end;
end;

procedure TRtcPChat.Call_LogOut(Sender: TObject);
begin
  Event_Logout(Sender);
end;

procedure TRtcPChat.Call_Error(Sender: TObject; Data: TRtcValue);
begin
  Event_Error(Sender);
end;

procedure TRtcPChat.Call_FatalError(Sender: TObject; Data: TRtcValue);
begin
  Event_Error(Sender);
end;

function TRtcPChat.MayJoinChat(const user: String): boolean;
begin
  if FAccessControl then
    Result := (FAllow and Client.inUserList[user]) or
      (FAllowSuper and Client.isSuperUser[user])
  else
    Result := True;
end;

procedure TRtcPChat.Open(const UserName: String; Sender: TObject = nil);
var
  fn: TRtcFunctionInfo;
begin
  if BeTheHost then
    Client.AddUserToMyGroup(Sender, UserName, 'chat')
  else
  begin
    // data to send to the user ...
    fn := TRtcFunctionInfo.Create;
    fn.FunctionName := 'chat';
    Client.SendToUser(Sender, UserName, fn);
  end;
end;

procedure TRtcPChat.Close(const UserName: String; Sender: TObject = nil);
begin
  if CompareText(UserName, Client.LoginUsername) = 0 then
  begin
    Client.DisbandMyGroup(Sender, 'chat');
    AmHost.Clear;
    AmHostCnt := 0;
  end
  else if AmHost.asBoolean[UserName] then
    Client.RemoveUserFromMyGroup(Sender, UserName, 'chat')
  else
    Client.LeaveUserGroup(Sender, UserName, 'chat');
end;

procedure TRtcPChat.Send(const UserName, msg: String; Sender: TObject = nil);
var
  fn: TRtcFunctionInfo;
begin
  if CompareText(UserName, Client.LoginUsername) = 0 then
  begin
    fn := TRtcFunctionInfo.Create;
    fn.FunctionName := 'msg';
    fn.asText['s'] := msg;
    Client.SendToMyGroup(Sender, 'chat', fn);
  end
  else
  begin
    { if not isSubscriber(username) then
      Open(username,Sender); }

    fn := TRtcFunctionInfo.Create;
    fn.FunctionName := 'msg';
    fn.asText['s'] := msg;
    Client.SendToUser(Sender, UserName, fn);
  end;
end;

procedure TRtcPChat.Call_JoinedUsersGroup(Sender: TObject;
  const group, uname: String; uinfo:TRtcRecord);
begin
  inherited;

  // we were invited to join user's group
  if group = 'chat' then
    if not isSubscriber(uname) then
      if MayJoinChat(uname) and Event_QueryAccess(Sender, uname) then
      // we are being asked to join a chat session
      begin
        if setSubscriber(uname, True) then
        begin
          Event_NewUser(Sender, uname, uinfo);
          Event_ChatOpen(Sender, uname);
        end;
      end
      else // setting "Allow" to FALSE will close the chat session
        Close(uname, Sender);
end;

procedure TRtcPChat.Call_LeftUsersGroup(Sender: TObject;
  const group, uname: String);
begin
  if group = 'chat' then
    if setSubscriber(uname, False) then
    begin
      Event_ChatClose(Sender, uname);
      Event_OldUser(Sender, uname);
    end;

  inherited;
end;

procedure TRtcPChat.Call_UserJoinedMyGroup(Sender: TObject;
  const group, uname: String; uinfo:TRtcRecord);
var
  r: TRtcFunctionInfo;
begin
  inherited;

  // we have invited a user to join our group
  if group = 'chat' then
    if setSubscriber(uname, True) then
    begin
      AmHost.asBoolean[uname] := True;
      Inc(AmHostCnt);

      Event_NewUser(Sender, uname, uinfo);

      if AmHostCnt = 1 then
        Event_ChatOpen(Sender, Client.LoginUsername);

      Event_ChatUserJoined(Sender, Client.LoginUsername, uname);

      r := TRtcFunctionInfo.Create;
      r.FunctionName := 'chat';
      r.asText['add'] := uname;
      Client.SendToMyGroup(Sender, 'chat', r);
    end;
end;

procedure TRtcPChat.Call_UserLeftMyGroup(Sender: TObject;
  const group, uname: String);
var
  r: TRtcFunctionInfo;
begin
  if group = 'chat' then
    if setSubscriber(uname, False) then
    begin
      AmHost.asBoolean[uname] := False;
      Dec(AmHostCnt);

      // Group Mode
      Event_ChatUserLeft(Sender, Client.LoginUsername, uname);

      if AmHostCnt = 0 then // This was the last subscriber
        Event_ChatClose(Sender, Client.LoginUsername);

      r := TRtcFunctionInfo.Create;
      r.FunctionName := 'chat';
      r.asText['rem'] := uname;
      Client.SendToMyGroup(Sender, 'chat', r);

      Event_OldUser(Sender, uname);
    end;

  inherited;
end;

procedure TRtcPChat.Call_DataFromUser(Sender: TObject; const uname: String;
  Data: TRtcFunctionInfo);
var
  r: TRtcFunctionInfo;
begin
  if Data.FunctionName = 'msg' then
  begin
    if AmHost.asBoolean[uname] then
    begin
      Event_ChatMessage(Sender, Client.LoginUsername, uname, Data.asText['s']);

      r := TRtcFunctionInfo.Create;
      r.FunctionName := 'msg';
      r.asText['s'] := Data.asText['s'];
      r.asText['user'] := uname;
      Client.SendToMyGroup(Sender, 'chat', r);
    end
    else if isSubscriber(uname) or MayJoinChat(uname) then
    begin
      if Data.isType['user'] in [rtc_Text, rtc_String] then
        Event_ChatMessage(Sender, uname, Data.asText['user'], Data.asText['s'])
      else
        Event_ChatMessage(Sender, uname, uname, Data.asText['s']);
    end;
  end
  else if Data.FunctionName = 'chat' then
  begin
    if isSubscriber(uname) then
    begin
      if Data.isType['add'] in [rtc_Text, rtc_String] then
        Event_ChatUserJoined(Sender, uname, Data.asText['add'])
      else if Data.isType['rem'] in [rtc_Text, rtc_String] then
        Event_ChatUserLeft(Sender, uname, Data.asText['rem'])
      else
        Event_ChatUserJoined(Sender, uname, uname);
    end
    else if BeTheHost and MayJoinChat(uname) then
      if Event_QueryAccess(Sender, uname) then
      begin
        Event_ChatInit(Sender, Client.LoginUsername);
        Client.AddUserToMyGroup(Sender, uname, 'chat');
      end;
  end
end;

procedure TRtcPChat.CallChatEvent(Sender: TObject; Event: TRtcCustomDataEvent;
  const room, user, msg: String);
var
  r: TRtcValue;
begin
  r := TRtcValue.Create;
  try
    with r.NewRecord do
    begin
      asText['room'] := room;
      asText['user'] := user;
      asText['msg'] := msg;
    end;
    CallEvent(Sender, Event, r);
  finally
    r.Free;
  end;
end;

procedure TRtcPChat.CallChatEvent(Sender: TObject; Event: TRtcCustomDataEvent;
  const room, user: String);
var
  r: TRtcValue;
begin
  r := TRtcValue.Create;
  try
    with r.NewRecord do
    begin
      asText['room'] := room;
      asText['user'] := user;
    end;
    CallEvent(Sender, Event, r);
  finally
    r.Free;
  end;
end;

procedure TRtcPChat.CallChatEvent(Sender: TObject; Event: TRtcCustomDataEvent;
  const room: String);
var
  r: TRtcValue;
begin
  r := TRtcValue.Create;
  try
    r.asText := room;
    CallEvent(Sender, Event, r);
  finally
    r.Free;
  end;
end;

procedure TRtcPChat.AddUI(UI: TRtcAbsPChatUI);
begin
  CSUI.Acquire;
  try
    if UIs.asBoolean[UI.UserName] then
      if assigned(UIs.asPtr[UI.UserName]) and (UIs.asPtr[UI.UserName] <> UI) then
        TRtcAbsPChatUI(UIs.asPtr[UI.UserName]).Module := nil;

    UIs.asBoolean[UI.UserName] := True;
    UIs.asPtr[UI.UserName] := UI;
  finally
    CSUI.Release;
  end;
end;

procedure TRtcPChat.RemUI(UI: TRtcAbsPChatUI);
begin
  CSUI.Acquire;
  try
    UIs.asBoolean[UI.UserName] := False;
    UIs.asPtr[UI.UserName] := nil;
  finally
    CSUI.Release;
  end;
end;

function TRtcPChat.LockUI(const UserName: String): TRtcAbsPChatUI;
begin
  CSUI.Acquire;
  try
    Result := TRtcAbsPChatUI(UIs.asPtr[UserName]);
    if assigned(Result) then
      Result.Locked := Result.Locked + 1;
  finally
    CSUI.Release;
  end;
end;

procedure TRtcPChat.UnlockUI(UI: TRtcAbsPChatUI);
var
  toFree: boolean;
begin
  CSUI.Acquire;
  try
    UI.Locked := UI.Locked - 1;
    toFree := (UI.Locked = 0) and UI.Cleared;
  finally
    CSUI.Release;
  end;
  if toFree then
    UI.Call_LogOut(nil);
end;

procedure TRtcPChat.Event_ChatInit(Sender: TObject; const room: String);
var
  UI: TRtcAbsPChatUI;
  msg: TRtcValue;
begin
  if assigned(FOnChatInit) then
    CallChatEvent(Sender, xOnChatInit, room);

  UI := LockUI(room);
  if assigned(UI) then
  begin
    try
      UI.Call_Init(Sender)
    finally
      UnlockUI(UI);
    end;
  end
  else if assigned(FOnNewUI) then
  begin
    msg := TRtcValue.Create;
    try
      msg.asText := room;
      CallEvent(Sender, xOnNewUI, msg);
    finally
      msg.Free;
    end;
    UI := LockUI(room);
    if assigned(UI) then
      try
        UI.Call_Init(Sender);
      finally
        UnlockUI(UI);
      end;
  end;
end;

procedure TRtcPChat.Event_ChatOpen(Sender: TObject; const room: String);
var
  UI: TRtcAbsPChatUI;
  msg: TRtcValue;
begin
  if assigned(FOnChatOpen) then
    CallChatEvent(Sender, xOnChatOpen, room);

  UI := LockUI(room);
  if assigned(UI) then
  begin
    try
      UI.Call_Open(Sender);
    finally
      UnlockUI(UI);
    end;
  end
  else if assigned(FOnNewUI) then
  begin
    msg := TRtcValue.Create;
    try
      msg.asText := room;
      CallEvent(Sender, xOnNewUI, msg);
    finally
      msg.Free;
    end;
    UI := LockUI(room);
    if assigned(UI) then
      try
        UI.Call_Open(Sender);
      finally
        UnlockUI(UI);
      end;
  end;
end;

procedure TRtcPChat.Event_ChatClose(Sender: TObject; const room: String);
var
  UI: TRtcAbsPChatUI;
begin
  if assigned(FOnChatClose) then
    CallChatEvent(Sender, xOnChatClose, room);

  UI := LockUI(room);
  if assigned(UI) then
    try
      UI.Call_Close(Sender);
    finally
      UnlockUI(UI);
    end;
end;

procedure TRtcPChat.Event_ChatUserJoined(Sender: TObject;
  const room, user: String);
var
  UI: TRtcAbsPChatUI;
begin
  if assigned(FOnChatUserJoined) then
    CallChatEvent(Sender, xOnChatUserJoined, room, user);

  UI := LockUI(room);
  if assigned(UI) then
    try
      UI.Call_UserJoined(Sender, user);
    finally
      UnlockUI(UI);
    end;
end;

procedure TRtcPChat.Event_ChatUserLeft(Sender: TObject;
  const room, user: String);
var
  UI: TRtcAbsPChatUI;
begin
  if assigned(FOnChatUserLeft) then
    CallChatEvent(Sender, xOnChatUserLeft, room, user);

  UI := LockUI(room);
  if assigned(UI) then
    try
      UI.Call_UserLeft(Sender, user);
    finally
      UnlockUI(UI);
    end;
end;

procedure TRtcPChat.Event_ChatMessage(Sender: TObject;
  const room, user, msg: String);
var
  UI: TRtcAbsPChatUI;
begin
  if assigned(FOnChatMessage) then
    CallChatEvent(Sender, xOnChatMessage, room, user, msg);

  UI := LockUI(room);
  if assigned(UI) then
    try
      UI.Call_Message(Sender, user, msg);
    finally
      UnlockUI(UI);
    end;
end;

procedure TRtcPChat.Event_Error(Sender: TObject);
var
  UI: TRtcAbsPChatUI;
  i: integer;
  user: String;
begin
  for i := 0 to UIs.Count - 1 do
  begin
    user := UIs.FieldName[i];
    UI := LockUI(user);
    if assigned(UI) then
      try
        UI.Call_Error(Sender);
      finally
        UnlockUI(UI);
      end;
  end;
end;

procedure TRtcPChat.Event_Logout(Sender: TObject);
var
  UI: TRtcAbsPChatUI;
  i: integer;
  user: String;
begin
  for i := 0 to UIs.Count - 1 do
  begin
    user := UIs.FieldName[i];
    UI := LockUI(user);
    if assigned(UI) then
      try
        UI.Call_LogOut(Sender);
      finally
        UnlockUI(UI);
      end;
  end;
end;

function TRtcPChat.GetAllow: boolean;
begin
  Result := FAllow;
end;

function TRtcPChat.GetAllowSuper: boolean;
begin
  Result := FAllowSuper;
end;

procedure TRtcPChat.SetAllow(const Value: boolean);
begin
  if Value <> FAllow then
  begin
    if FGatewayParams and assigned(Client) then
      Client.ParamSet(nil, 'NoChat', TRtcBooleanValue.Create(not Value));
    FAllow := Value;
  end;
end;

procedure TRtcPChat.SetAllowSuper(const Value: boolean);
begin
  if Value <> FAllowSuper then
  begin
    if FGatewayParams and assigned(Client) then
      Client.ParamSet(nil, 'NoSuperChat', TRtcBooleanValue.Create(not Value));
    FAllowSuper := Value;
  end;
end;

procedure TRtcPChat.xOnChatClose(Sendeer, Obj: TObject; Data: TRtcValue);
begin
  FOnChatClose(self, Data.asText);
end;

procedure TRtcPChat.xOnChatInit(Sender, Obj: TObject; Data: TRtcValue);
begin
  FOnChatInit(self, Data.asText);
end;

procedure TRtcPChat.xOnChatMessage(Sendeer, Obj: TObject; Data: TRtcValue);
begin
  FOnChatMessage(self, Data.asRecord.asText['room'],
    Data.asRecord.asText['user'], Data.asRecord.asText['msg']);
end;

procedure TRtcPChat.xOnChatOpen(Sendeer, Obj: TObject; Data: TRtcValue);
begin
  FOnChatOpen(self, Data.asText);
end;

procedure TRtcPChat.xOnChatUserJoined(Sendeer, Obj: TObject; Data: TRtcValue);
begin
  FOnChatUserJoined(self, Data.asRecord.asText['room'],
    Data.asRecord.asText['user']);
end;

procedure TRtcPChat.xOnChatUserLeft(Sendeer, Obj: TObject; Data: TRtcValue);
begin
  FOnChatUserLeft(self, Data.asRecord.asText['room'],
    Data.asRecord.asText['user']);
end;

procedure TRtcPChat.xOnNewUI(Sendeer, Obj: TObject; Data: TRtcValue);
begin
  FOnNewUI(self, Data.asText);
end;

procedure TRtcPChat.Init;
begin
  inherited;
  AmHost.Clear;
end;

{ TRtcAbsPChatUI }

constructor TRtcAbsPChatUI.Create(AOwner: TComponent);
begin
  inherited;
end;

destructor TRtcAbsPChatUI.Destroy;
begin
  Module := nil;
  inherited;
end;

procedure TRtcAbsPChatUI.SetModule(const Value: TRtcPChat);
begin
  if assigned(Value) and (UserName = '') then
    raise Exception.Create('Set "UserName" before linking to RtcPChat');
  if Value <> FModule then
  begin
    if assigned(Module) and not FCleared then
      Module.RemUI(self);
    FCleared := False;
    FModule := Value;
    if assigned(Module) then
      Module.AddUI(self);
  end;
end;

function TRtcAbsPChatUI.GetModule: TRtcPChat;
begin
  Result := FModule;
end;

procedure TRtcAbsPChatUI.SetUserName(const Value: String);
begin
  if assigned(Module) and (Value = '') then
    raise Exception.Create('Can not clear "UserName" while linked to RtcPChat');
  if Value <> FUserName then
  begin
    if assigned(Module) then
      Module.RemUI(self);
    FUserName := Value;
    if assigned(Module) then
      Module.AddUI(self);
  end;
end;

function TRtcAbsPChatUI.GetUserName: String;
begin
  Result := FUserName;
end;

procedure TRtcAbsPChatUI.Open(Sender: TObject = nil);
begin
  if (UserName <> '') and assigned(FModule) then
    FModule.Open(UserName, Sender);
end;

procedure TRtcAbsPChatUI.Close(Sender: TObject = nil);
begin
  if (UserName <> '') and assigned(FModule) then
    FModule.Close(UserName, Sender);
end;

function TRtcAbsPChatUI.CloseAndClear(Sender: TObject = nil): boolean;
begin
  if (UserName <> '') and assigned(FModule) and not FCleared then
  begin
    Module.RemUI(self);
    Result := Locked = 0;
    FModule.Close(UserName, nil);
    if not Result then
      FCleared := True
    else
      FModule := nil;
  end
  else
    Result := True;
end;

procedure TRtcAbsPChatUI.Send(const msg: String; Sender: TObject = nil);
begin
  if (UserName <> '') and assigned(FModule) then
    FModule.Send(UserName, msg, Sender);
end;

end.
