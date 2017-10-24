{ Copyright 2004-2017 (c) RealThinClient.com (http://www.realthinclient.com) }

unit rtcPortalGate;

interface

{$INCLUDE rtcDefs.inc}
{$INCLUDE rtcPortalDefs.inc}

// Declare the compiler directive RTC_TRIAL if you 
// are using the RealThinClient SDK Starter edition
// and want to get a meaningfull Error message on the
// Client side when the connection limit has been exceeded.

{.$DEFINE RTC_TRIAL}

uses
  SysUtils, Classes,

  rtcLog,

  rtcSystem, rtcFunction, rtcInfo,
  rtcConn, rtcDataSrv, rtcSrvModule;

const
  RD_ALLOWUSERS:String = 'AllowUsers';
  RD_RESTRICTACCESS:String = 'RestrictAccess';

  RD_FN_USERGET:String = 'User.Get';
  RD_FN_USERSET:String = 'User.Set';
  RD_FN_USERADD:String = 'User.Add';
  RD_FN_USERDEL:String = 'User.Del';
  RD_FN_LOGIN:String = 'LogIn';
  RD_FN_LOGOUT:String = 'LogOut';
  RD_FN_RELOGIN:String = 'ReLogin';
  RD_FN_HOST:String = 'Host';
  RD_FN_CONTROL:String = 'Control';
  RD_FN_GET:String = 'Get';
  RD_FN_PUT:String = 'Put';

  S_DEMO_EXCEEDED:String = 'DEMO user limit (5) exceeded.';

type
  TRtcPortalUserEvent = procedure(const UserName:String) of object;

  TRtcPortalGateUserEvent = procedure(Sender:TRtcConnection; const UserName, Password:String; UserInfo:TRtcRecord) of object;

  TRtcPUserAccessReason = (rtcpUA_HostConnect, rtcpUA_HostDisconnect,
                           rtcpUA_ControlConnect, rtcpUA_ControlDisconnect,
                           rtcpUA_SubscribeFrom, rtcpUA_SubscribeTo,
                           rtcpUA_UnSubscribeFrom, rtcpUA_UnSubscribeTo,
                           rtcpUA_EndSubscriptions, rtcpUA_UnSubscribe,
                           rtcpUA_GetParams, rtcpUA_SetParams,
                           rtcpUA_AddParams, rtcpUA_DelParams);

  TRtcPortalUserAccess = class(TRtc_Component)
  protected
    { Load all Users Info from file "FileName" }
    procedure LoadUserInfo(const FileName:String); virtual; abstract;

    { Save all Users Info to file "FileName" }
    procedure SaveUserInfo(const FileName:String); virtual; abstract;

    { Return TRUE if user "UserName" exists. If not, return FALSE. }
    function UserExists(const UserName:String):boolean; virtual; abstract;

    { A notification that we will be accessing data from user "UserName".
      If user does not exist, raise exception. }
    procedure UserAccess(const UserName:String; Reason:TRtcPUserAccessReason); virtual; abstract;

    { Register user "UserName" with password "Password" and user info "UserInfo".
      If there are problems registering, raise exception }
    procedure RegisterUser(Sender:TRtcConnection; const UserName, Password:String; UserInfo:TRtcRecord; WriteLog:boolean); virtual; abstract;

    { User "UserName" is logging in from "Sender" using password "Password" and user info "UserInfo".
      If the user is not allowed to log in, raise exception }
    procedure LoginUser(Sender:TRtcConnection; const UserName, Password:String; UserInfo:TRtcRecord; WriteLog:boolean); virtual; abstract;

    { User "UserName" is logging out from "Sender" with password "Password".
      If user does not exist, or password does not match, raise exception. }
    procedure LogoutUser(Sender:TRtcConnection; const UserName, Password:String; WriteLog:boolean); virtual; abstract;

    { Copy all the information you have about user "UserName" and return as a TRtcRecord.
      Return NIL if the user is unknown (no user information available).
      Caller needs to take care of freeing the result received. }
    function GetUserDataCopy(const UserName: String):TRtcRecord; virtual; abstract;

    { Replace all the information you have about user "UserName" with
      the information stored inside the "ReplaceWith" record.
      This method should take care of freeing the "ReplaceWith" object. }
    procedure SetUserData(const UserName: String; ReplaceWith:TRtcRecord); virtual; abstract;
    end;

  { This component uses a TRtcRecord to keep all user data in memory.
    "LoadUserInfo" and "SaveUserInfo" methods are working with the Filename
    provided by the "TRtcPortalGateway" components "UserInfoFileName" property.

    If you want to use a different storage media that a plain text file,
    you should implement a new class based on the "TRtcPortalUserAccess" or
    "TRtcPortalGateUserAccess" component and assign it to the "UserAccess"
    property on the TRtcPortalGateway component. }
  TRtcPortalGateUserAccess = class(TRtcPortalUserAccess)
  protected
    UserList:TRtcRecord;

  public
    constructor Create(AOwner:TComponent); override;
    destructor Destroy; override;

    { Load all Users Info from file "FileName" }
    procedure LoadUserInfo(const FileName:String); override;

    { Save all Users Info to file "FileName" }
    procedure SaveUserInfo(const FileName:String); override;

    { Return TRUE if user "UserName" exists. If not, return FALSE. }
    function UserExists(const UserName:String):boolean; override;

    { A notification that we will be accessing data from user "UserName".
      If user does not exist, raise exception. }
    procedure UserAccess(const UserName:String; Reason:TRtcPUserAccessReason); override;

    { Register user "UserName" with password "Password" and user info "UserInfo".
      If there are problems registering, raise exception }
    procedure RegisterUser(Sender:TRtcConnection; const UserName, Password:String; UserInfo:TRtcRecord; WriteLog:boolean); override;

    { User "UserName" is logging in from "Sender" using password "Password" and user info "UserInfo".
      If the user is not allowed to log in, raise exception }
    procedure LoginUser(Sender:TRtcConnection; const UserName, Password:String; UserInfo:TRtcRecord; WriteLog:boolean); override;

    { User "UserName" is logging out from "Sender" with password "Password".
      If user does not exist, or password does not match, raise exception. }
    procedure LogoutUser(Sender:TRtcConnection; const UserName, Password:String; WriteLog:boolean); override;

    { Copy all the information you have about user "UserName" and return as a TRtcRecord.
      Return NIL if the user is unknown (no user information available).
      Caller needs to take care of freeing the result received. }
    function GetUserDataCopy(const UserName: String):TRtcRecord; override;

    { Replace all the information you have about user "UserName" with
      the information stored inside the "ReplaceWith" record.
      This method will take care of freeing the "ReplaceWith" object. }
    procedure SetUserData(const UserName: String; ReplaceWith:TRtcRecord); override;

    end;

  TRtcPortalGateway = class(TRtcBaseServerModule)
  protected
    FDefaultUserAccess: TRtcPortalUserAccess;
    FUsers: TRtcPortalUserAccess;

    FnGroup: TRtcFunctionGroup;

    FnLogIn: TRtcFunction;
    FnLogOut: TRtcFunction;
    FnUserGet: TRtcFunction;
    FnUserSet: TRtcFunction;
    FnUserAdd: TRtcFunction;
    FnUserDel: TRtcFunction;
    FnHost: TRtcFunction;
    FnControl: TRtcFunction;
    FnReLogin: TRtcFunction;
    FnGet: TRtcFunction;
    FnPut: TRtcFunction;

    LogInCounter:integer;
    FAutoSave: boolean;
    FFileName:string;
    HostList,ControlList:TRtcRecord;
    HostSubList,ControlSubList:TRtcRecord;
    LoggedIn:TRtcRecord;
    FAutoRegisterUsers:boolean;

    MessPut, MessPutTick, MessPutDirect:TRtcRecord;
    MessGet, MessGetTick, MessGetOld:TRtcRecord;

    WakesGet,WakesPut:TRtcInfo;
    CS:TRtcCritSec;
    FOnUserLogin: TRtcPortalUserEvent;
    FOnUserLogout: TRtcPortalUserEvent;
    FSyncUserEvents: boolean;
    FResponseTimeout: longint;
    FDataSendTimeout: longint;

    FOnSessionClosing: TRtcNotifyEvent;
    FBeforeLogin: TRtcPortalGateUserEvent;
    FBeforeRegister: TRtcPortalGateUserEvent;

    FWriteLog: boolean;

    // @exclude
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;

    // Call before accessing any of the protected objects
    procedure Lock;
    // Call in "finally", after accessing these protected objects
    procedure UnLock;

    procedure FnLogInExecute(Sender: TRtcConnection; Param: TRtcFunctionInfo; Result: TRtcValue);
    procedure FnLogOutExecute(Sender: TRtcConnection; Param: TRtcFunctionInfo; Result: TRtcValue);
    procedure FnReLoginExecute(Sender: TRtcConnection; Param: TRtcFunctionInfo; Result: TRtcValue);

    procedure FnUserGetExecute(Sender: TRtcConnection; Param: TRtcFunctionInfo; Result: TRtcValue);
    procedure FnUserSetExecute(Sender: TRtcConnection; Param: TRtcFunctionInfo; Result: TRtcValue);
    procedure FnUserAddExecute(Sender: TRtcConnection; Param: TRtcFunctionInfo; Result: TRtcValue);
    procedure FnUserDelExecute(Sender: TRtcConnection; Param: TRtcFunctionInfo; Result: TRtcValue);

    procedure FnGetExecute(Sender: TRtcConnection; Param: TRtcFunctionInfo; Result: TRtcValue);
    procedure FnPutExecute(Sender: TRtcConnection; Param: TRtcFunctionInfo; Result: TRtcValue);

    procedure FnHostExecute(Sender: TRtcConnection; Param: TRtcFunctionInfo; Result: TRtcValue);
    procedure FnControlExecute(Sender: TRtcConnection; Param: TRtcFunctionInfo; Result: TRtcValue);

    procedure ServerModuleSessionClose(Sender: TRtcConnection);

    function GetHelperFunctionGroup: TRtcFunctionGroup;
    function GetAfterExecute: TRtcFunctionCallEvent;
    function GetBeforeExecute: TRtcFunctionCallEvent;
    function GetOnWrongCall: TRtcFunctionCallEvent;
    function GetUserAccess: TRtcPortalUserAccess;

    procedure SetAutoSaveInfo(const Value: boolean);
    procedure SetInfoFileName(const Value: string);
    procedure SetHelperFunctionGroup(const Value: TRtcFunctionGroup);
    procedure SetAfterExecute(const Value: TRtcFunctionCallEvent);
    procedure SetBeforeExecute(const Value: TRtcFunctionCallEvent);
    procedure SetOnWrongCall(const Value: TRtcFunctionCallEvent);
    procedure SetAutoRegisterUsers(const Value: boolean);
    procedure SetUserAccess(const Value: TRtcPortalUserAccess);

  public
    { Public declarations }

    // @exclude
    constructor Create(AOwner:TComponent); override;
    // @exclude
    destructor Destroy; override;

    function isValidUsername(const username:string):boolean;

    procedure UserReLogin(Sender:TRtcConnection; const username,password:String; const ID:RtcString; uinfo:TRtcRecord);
    function UserLogin(Sender:TRtcConnection; const username,password:String; const ID:RtcString; uinfo:TRtcRecord):boolean;
    function UserLogOut(Sender:TRtcConnection; const username,password:String; forced:boolean):boolean;

    procedure HostConnect(Sender:TRtcConnection; const username:string);
    procedure HostDisconnect(Sender:TRtcConnection; const username:string);
    procedure ControlConnect(Sender:TRtcConnection; const username:string);
    procedure ControlDisconnect(Sender:TRtcConnection; const username:string);

    function UserLoggedIn(Sender:TRtcConnection; const username:String; const ID:RtcString):boolean;

    procedure UserSet(Sender:TRtcConnection; const username:string; data:TRtcRecord);
    procedure UserAdd(Sender:TRtcConnection; const username:string; data:TRtcRecord);
    procedure UserDel(Sender:TRtcConnection; const username:string; data:TRtcRecord);

    function UserGet(Sender:TRtcConnection; const username:string):TRtcRecord;

    function SetWakePut(const user:string; Call:TRtcDelayedCall):boolean;
    function SetWakeGet(const user:string; Call:TRtcDelayedCall):boolean;
    procedure ClearWakePut(const user:string);
    procedure ClearWakeGet(const user:string);

    procedure WakePut(const user:string);
    procedure WakeGet(const user:string);

    function CheckMsgPut(const fromuser:string; Tick:longint):boolean;

    procedure SubscribeUser(Sender:TRtcConnection; const fromuser,func,touser:string; temp:boolean=False);
    procedure UnSubscribeUser(Sender:TRtcConnection; const fromuser,func,touser:string; temp:boolean=False);
    procedure EndSubscriptions(Sender:TRtcConnection; const username:string);
    procedure UnSubscribe(Sender:TRtcConnection; const username,func:string);

    procedure MsgPut(const fromuser:string; const uname:string; const data:TRtcValueObject; direct:boolean=False);
    procedure MsgPutFn(const fromuser:string; const forfn:string; const data:TRtcValueObject; direct:boolean=False);
    function MsgGet(const foruser:string; Tick:longint):TRtcRecord;
    procedure MsgClear(const foruser:string);

    // Signal Control that Host has logged in
    procedure Msg_HostLogin(const uhost, ucontrol:string);
    // Signal Control that Host has logged out
    procedure Msg_HostLogout(const uhost, ucontrol:string);

    // Signal Host and Control that Control is Subscribed to Host for Func
    procedure Msg_Subscribed(const uhost, ucontrol, func:string);
    // Signal Host and Control that Control has unsubscribed from Host for Func
    procedure Msg_Unsubscribed(const uhost, ucontrol, func:string);

    // Signal Control that Host, to which it was subscribed for function Func, is no longer there
    procedure Msg_UnsubHost(const uhost, ucontrol, func:string);
    // Signal to Host that Control, subscribed to Host's function Func, is no longer there
    procedure Msg_UnsubControl(const uhost, ucontrol, func:string);

    procedure DoTextEvent(Sender: TRtcConnection; Event: TRtcPortalUserEvent; const s: string);
    procedure SyncTextEvent(Sender: TRtcConnection; obj:TObject);

    procedure LoadInfo;
    procedure SaveInfo;

  published
    { Write important events (user login/logout) to a LOG file? }
    property WriteLog:boolean read FWriteLog write FWriteLog default False;

    { You can implement your own custom PortalUserAccess component and assign it
      to the Gateway's "UserAccess" property if you need more functionality than
      provided in the TRtcPortalGateUserAccess component. }
    property UserAccess:TRtcPortalUserAccess read GetUserAccess write SetUserAccess;

    { If user does not exist when logging in, register the user automatically? }
    property AutoRegisterUsers:boolean read FAutoRegisterUsers write SetAutoRegisterUsers default False;

    { This event can be used for additional controls during user registration.
      For example, to limit registrations only to users connecting from a specific
      IP addresses, to completely disable automatic user registrations, or to
      implement special requirements for usernames, passwords or custom user info.
      In case the user may NOT register, raise an exception. }
    property BeforeUserRegister:TRtcPortalGateUserEvent read FBeforeRegister write FBeforeRegister;

    { This event can be used for additional controls during user login.
      For example, to limit login only to users from a specific IP address range,
      to disable login for specific users or to implement additional login requirements
      based on usernames, passwords or custom user info (received from clients).
      In case the user may NOT log in, raise an exception. }
    property BeforeUserLogin:TRtcPortalGateUserEvent read FBeforeLogin write FBeforeLogin;

    { Name of the User Info file. Call "LoadInfo" to load, "SaveInfo" to save user info.
      If "AutoSaveInfo=TRUE", setting "InfoFileName" will load data from the file.
      If you do NOT want User Info in memory to be rewritten by data from the file,
      set "AutoSaveInfo:=FALSE" before setting "InfoFileName" to TRUE,
      then call "SaveInfo" and set "AutoSaveInfo:=True" afterwards. }
    property InfoFileName:string read FFileName write SetInfoFileName;

    { Auto-save every User Info change to the "User Info File"?
      If "InfoFileName" is set (not empty), setting "AutoSaveInfo=True"
      will load User Info data from that file. }
    property AutoSaveInfo:boolean read FAutoSave write SetAutoSaveInfo default False;

    // Called when a user logs in to the Gateway
    property OnUserLogin:TRtcPortalUserEvent read FOnUserLogin write FOnUserLogin;
    // Called when a user logs out of the Gateway
    property OnUserLogout:TRtcPortalUserEvent read FOnUserLogout write FOnUserLogout;

    // Call "OnUserLogin" and "OnUserLogout" events synchronized with the Main Thread?
    property AutoSyncUserEvents:boolean read FSyncUserEvents write FSyncUserEvents default False;

    // Timeout (in seconds) after which a response has to be sent back to the Client
    property TimeoutResponse:longint read FResponseTimeout write FResponseTimeout default 20;
    // How long (in seconds) may it take for a data package to be sent to the client and the client returned?
    // Should a data package need more time to get to the client and back, that clients session will be closed.
    property TimeoutDataSend:longint read FDataSendTimeout write FDataSendTimeout default 20;

    { Use this property to define what compression level you want to use when sending
      data from Server to client. Default Compression value is "cNone" (no compression).
      You can use different compression levels between client and server (for example,
      fast or no compression from client and max from server). If your server has to
      work with clients which don't support compression, you have to use "cNone". }
    property Compression;

    { Use this property to define what Data Formats you want to accept for this ServerModule.
      Since this is a set, you can choose one supported format or all supported formats. }
    property DataFormats;

    { - Set "ObjectLinks" to "ol_None" (default) to completely disable the "RTC Linked Objects"
        feature for this RTC Server Module. When "ObjectLinks=ol_None", calling the
        "TRtcDataServer(Sender).ActivateObjectManager;" method will also raise an exception
        because any RTC Linked Objects created this way would NOT be sent to the Client. @html(<br><br>)

        Because a single Server can potentially host any number of different Applications
        and handle requests from any number of different Clients, there is no reason why
        a single Server shouldn't have more than one "TRtcServerModule" component using the
        "RTC Linked Objects" feature. But, to keep the Client-side implementation simple,
        it is best to use only *one* "TRtcServerModule" per "Client Application" and
        customize each "TRtcServerModule" to specific needs of each Client Application. @html(<br><br>)

      - Set "ObjectLinks" to "ol_Manual" if you want to force the Client to call a remote
        function on the Server which will execute the "TRtcDataServer(Sender).ActivateObjectManager;"
        method before any "Linked Objects" can be created (from Client or Server side). If there is no
        active Session and you use "ActiveObjectManager(True)", a new Session will also be created,
        after which a new Object Manager will be created and assigned to the Session. @html(<br><br>)

      - Set "ObjectLinks" to "ol_AutoClient" (or "ol_AutoBoth") if you want an Object Manager to be created
        automatically by the Server if "Linked Objects" data is received from a Client, allowing Clients to
        start creating Linked Objects without having to call a remote function and use "ActivateObjectManager"
        first (see "ol_Manual"). Please note that a Session is also required before an Object Manager can
        be created, since the Object Manager is stored inside a Session. If you also want the Session to
        be created automatically for the Client, set the "AutoSessions" property to TRUE.

      - Set "ObjectLinks" to "ol_AutoServer" (or "ol_AutoBoth") if an Object Manager should be created
        and/or activated automatically before each remote function linked to this Server Module gets executed,
        so there will be no need to explicitly call "ActivateObjectManager" from these functions OnExecute events.
        If "ObjectLinks" is "ol_AutoServer" (or "ol_AutoBoth"), because an Object Manager requires an active Session,
        the AutoSessions property also has to be TRUE for a Session to be created automatically, or a Session
        has to be opened manually by using a remote function linked to another Server Module.

      - Setting "ObjectLinks" to "ol_AutoBoth" is the equivalent of combining "ol_AutoClient" and "ol_AutoServer". }
    property ObjectLinks;

    { Set this property to a value other than 0 if you want to enable automatic
      Encryption for clients which have their EncryptionKey option activated.
      EncryptionKey value defines the length on the encryption key, in bytes.
      One byte represents encryption strength of 8 bits. To have 256-bit encryption,
      set EncryptionKey=32. @html(<br><br>)

      The final encryption key is combined from a key received by the client
      and a key generated by this ServerModule. When EncryptionKey is >0 by the
      ClientModule doing the call AND by this ServerModule, Encryption handshake will
      be done automatically by those two components, so that the user only has to set
      the values and use the components as if there is no encryption.

      If ServerModule's EncryptionKey property is 0 (zero), server will not allow data to be
      encrypted and all communication with all clients will flow without encryption.
      Clients which have ForceEncryption set to True, will not work if the server
      doesn't want to support encryption. }
    property EncryptionKey;

    { If you need a 100% secure connection, define a Secure Key String
      (combination of letters, numbers and special characters) for each
      ServerModule/ClientModule pair, additionally to the EncryptionKey value.
      ClientModule will be able to communicate with the ServerModule ONLY if
      they both use the same SecureKey. Default value for the SecureKey is
      an empty String (means: no secure key). @html(<br><br>)

      SecureKey will be used in the encryption initialisation handshake,
      to decrypt the first key combination received by the ClientModule.
      Since all other data packages are already sent using some kind of encryption,
      by defining a SecureKey, you encrypt the only key part which would have
      been sent out without special encryption. }
    property SecureKey;

    { Setting this property to TRUE will tell the ServerModule to work with
      Clients ONLY if they requested to use encryption. If AutoEncryptKey is > 0 and
      Client doesn't request encryption, function calls will not be processed
      and any request coming from the client will be rejected, until
      client requests and initializes encryption. }
    property ForceEncryption;

    { Using this property, you define how long a session will live (in seconds)
      when there are no requests from this client and the session was
      created by a call from ClientModule that has its AutoSessions property enabled.
      The higher this value, the longer a session will stay valid when there
      are no requests coming from the client for which the session was created.
      This value will be used only after the Client has sent a valid request
      which produces a valid response from the server. Before that, a default
      Session Live time of @Link(RTC_SESSION_TIMEOUT=60) seconds will be used. @html(<br><br>)

      Session Live counter is reset each time a new request is received from the same client,
      so that this parameter only removes sessions which are inactive longer than
      AutoSessionsLive seconds. To keep your server from nasty clients creating tons of
      sessions and leaving them inactive, keep this property under 600 seconds,
      even if you want your session to stay alive for a long time. You do not have to
      overexagurate this value, since every session consumes memory and client sessions which are not
      needed will ONLY THEN be removed from memory when this AutoSessionsLive timeout expires. }
    property AutoSessionsLive;

    { Set this property to TRUE if you want ClientModule's to be able to
      reqest a new session automatically by using the NEWID parameter.
      Session handling is built into the ClientModule and uses Request.Params to
      send the Session.ID to the server and Response.Cookie['ID'] to receive a
      new session ID from the server and initialize the session object. @html(<br><br>)

      Since session ID's are communicated automaticaly by the ClientModule and
      ServerModule components, all TRtcFunction and TRtcResult components used by
      this ClientModule will have direct access to the session object.
      When AutoSessions is set to true, Client's can automaticaly request a new
      session is no session exists or when a session expires. @html(<br><br>)

      When AutoSessions is FALSE, you have to request a new session by calling
      a remote server function to generate a new session and return the session ID. }
    property AutoSessions;

    { When AutoSessions are used, you can define what client data you want to use to lock the
      Sessions to this client and deny access to session data from other clients. }
    property AutoSessionsLock;

    { If ModuleHost is specified, then Request.Host will be compared to the ModuleHost
      property to decide if this request should be processed by this ServerModule. @html(<br>)
      If your DataServer has to serve more different hosts, while your ServerModule
      is not supposed to react to requests from all those hosts, you can assign the
      host name to which this ServerModule belongs to. If ModuleHost is left blank,
      then this ServerModule will respond to any request asking for this servermodule's
      ModuleFileName, regardless of the HOST header. @html(<br><br>)

      To process all requests for a domain and all of its sub-domains, enter domain name ONLY
      (example: "realthinclient.com" for "realthinclient.com" and any sub-domain like
      "www.realthinclient.com", "mymod.myapp.realthinclient.com", etc). @html(<br>)
      To limit the requests to a sub-domain and its sub-sub-domains, enter the name
      of the highest sub-domain (example: "myapp.realthinclient.com" for
      "myapp.realthinclient.com" and any of its sub-domains like
      "mymod.myapp.realthinclient.com"). @html(<br>)
      To process ONLY requests pointed exactly to ONE HOST, add "." in front of your
      host name (example: ".realthinclient.com" will ONLY react to requests with
      "realthinclient.com" in their HOST header). }
    property ModuleHost;
    { This property will be compared to Request.FileName to decide if the
      request we just received was pointed to this ServerModule. Any request asking
      for this FileName will be processed by this ServerModule component.
      Since parameters are passed to the server module through request's Content
      body (rather than headers), we do not need to check the request for anything
      else than it's FileName to know if the request is directed to this module. }
    property ModuleFileName;

    { Set this property to tell the RtcPortalGateway to use this TRtcFunctionGroup
      component to execute helper (custom) functions received as a request from Portal clients. }
    property HelperFunctions:TRtcFunctionGroup read GetHelperFunctionGroup write SetHelperFunctionGroup;

    { This event is triggered when data is received from a remote "Object Manager".
      The main purpose of this event is to allow you to *monitor* all received "Linked Objects"
      packages without changing anything, but it could also be used to modify received data
      before it is forwarded to the local "Object Manager" for processing/execution.

      @param(Sender - NIL, or the connection component through which data was received)
      @param(Data - Data received from remote "Object Manager".
             Unless you know exactly what you are doing and understand the format which
             local and remote "Object Manager" instances are using for communication,
             it is highly recommended that you do NOT make ANY changes to this instance.
             This is the instance that will be passed over to our "Object Manager" later) }
    property OnObjectDataIn;

    { This event is triggered *before* we send data prepared by our "Object Manager".
      The main purpose of this event is to allow you to *monitor* all "Linked Objects"
      packages before they are sent out, but it could also be used to modify prepared data.

      @param(Sender - NIL if using the default connection; "Sender" parameter for the Call method)
      @param(Data - Data prepared by our local "Object Manager" for sending to remote "Object Manager".
             Unless you know exactly what you are doing and understand the format which
             local and remote "Object Manager" instances are using for communication,
             it is highly recommended that you do NOT make ANY changes to this instance.
             This is the instance that will be sent over to remote "Object Manager") }
    property OnObjectDataOut;

    { This event is triggered when the remote Object Manager has requested
      our Object Manager to create a new Object (remote instance was already created)
      and allows you to create Objects which don't have a global constructor
      registered (through the global "RegisterRtcObjectConstructor" procedure).

      Objects which you do NOT want to have created automatically by the remote
      side, but where you still want to allow controlled creation should NOT have
      a global constructor registered and should be created from THIS event instead. }
    property OnObjectCreate;

    { Event to be triggered after a new Session was opened. }
    property OnSessionOpen;
    { Event to be triggered before an existing Session was to be closed. }
    property OnSessionClosing:TRtcNotifyEvent read FOnSessionClosing write FOnSessionClosing;
    { Event to be triggered when the Server starts listening on the connection.
      You can use this event for component initialization. }
    property OnListenStart;
    { Event to be triggered when the Server stops listening on the connection.
      You can use this event for component deinitialization. }
    property OnListenStop;
    { Event to be triggered when a child DataProvider component accepts the Request.
      You can use this event for request initialization. For example,
      you could create a DataTunel and assign it to Tunel, to have reuqest data tunneled. }
    property OnRequestAccepted;
    { Event to be triggered after the response was sent out (Response.Done) }
    property OnResponseDone;
    { Event to be triggered when connection gets lost after a request was accepted.
      You can use this event for component deinitialization. }
    property OnDisconnect;

    { This event will be called every time BEFORE the function call is passed
      over to the TRtcFunction object and can be used for monitoring function calls
      before they happen. You can modify calling parameters in this event if needed,
      temper with the Result object or raise an exception if you do not want the
      function to be executed.

      The event will only be called for functions directly assigned to this function group.
      It will NOT be executed for functions assigned to the Helper or the Parent Function
      Group, nor in case a function is missing (not assigned to the group).

      The event will receive all parameters as the Function. }
    property BeforeExecute:TRtcFunctionCallEvent read GetBeforeExecute write SetBeforeExecute;

    { This event will be called every time AFTER a call to a Function assigned to this
      FunctionGroup has been executed without raising an exception. You can use this
      event to monitor function calls after they have been completed. Since the function
      has already completed execution, you will also have access to the Result parameters,
      which you can also modify - if you want. }
    property AfterExecute:TRtcFunctionCallEvent read GetAfterExecute write SetAfterExecute;

    { This event will be executed if a Function to be called is missing (unassigned).
      You can use this event to log calls to functions which are not yet implemented,
      or function calls to undeclared/non-existend functions.

      Changes to Parameters or the Result object inside this event will have no effect.
      If a function is not assigned, an exception will be raised by the component and
      the error message (Function not found) will be returned to the calling Client. }
    property OnWrongCall:TRtcFunctionCallEvent read GetOnWrongCall write SetOnWrongCall;
  end;

implementation

constructor TRtcPortalGateway.Create(AOwner: TComponent);
  begin
  inherited;
  FnGroup:=TRtcFunctionGroup.Create(nil);
  FunctionGroup:=FnGroup;

  FnLogIn:=TRtcFunction.Create(nil);
  FnLogOut:=TRtcFunction.Create(nil);
  FnReLogin:=TRtcFunction.Create(nil);
  FnUserGet:=TRtcFunction.Create(nil);
  FnUserSet:=TRtcFunction.Create(nil);
  FnUserAdd:=TRtcFunction.Create(nil);
  FnUserDel:=TRtcFunction.Create(nil);
  FnHost:=TRtcFunction.Create(nil);
  FnControl:=TRtcFunction.Create(nil);
  FnGet:=TRtcFunction.Create(nil);
  FnPut:=TRtcFunction.Create(nil);

  FnLogIn.Group:=FunctionGroup;
  FnLogOut.Group:=FunctionGroup;
  FnReLogin.Group:=FunctionGroup;
  FnUserGet.Group:=FunctionGroup;
  FnUserSet.Group:=FunctionGroup;
  FnUserAdd.Group:=FunctionGroup;
  FnUserDel.Group:=FunctionGroup;
  FnHost.Group:=FunctionGroup;
  FnControl.Group:=FunctionGroup;
  FnGet.Group:=FunctionGroup;
  FnPut.Group:=FunctionGroup;

  FnUserGet.FunctionName := RD_FN_USERGET; //'User.Get';
  FnUserSet.FunctionName := RD_FN_USERSET; //'User.Set';
  FnUserAdd.FunctionName := RD_FN_USERADD; //'User.Add';
  FnUserDel.FunctionName := RD_FN_USERDEL; //'User.Del';
  FnLogIn.FunctionName   := RD_FN_LOGIN;   //'LogIn';
  FnLogOut.FunctionName  := RD_FN_LOGOUT;  //'LogOut';
  FnReLogin.FunctionName := RD_FN_RELOGIN; //'ReLogin';
  FnHost.FunctionName    := RD_FN_HOST;    //'Host';
  FnControl.FunctionName := RD_FN_CONTROL; //'Control';
  FnGet.FunctionName     := RD_FN_GET;     //'Get';
  FnPut.FunctionName     := RD_FN_PUT;     //'Put';

  FnUserGet.OnExecute:=FnUserGetExecute;
  FnUserSet.OnExecute:=FnUserSetExecute;
  FnUserAdd.OnExecute:=FnUserAddExecute;
  FnUserDel.OnExecute:=FnUserDelExecute;
  FnLogIn.OnExecute:=FnLogInExecute;
  FnLogOut.OnExecute:=FnLogOutExecute;
  FnReLogin.OnExecute:=FnReLoginExecute;
  FnHost.OnExecute:=FnHostExecute;
  FnControl.OnExecute:=FnControlExecute;
  FnGet.OnExecute:=FnGetExecute;
  FnPut.OnExecute:=FnPutExecute;

  OnSessionClose:=ServerModuleSessionClose;

  LogInCounter:=0;
  LoggedIn:=TRtcRecord.Create;
  HostList:=TRtcRecord.Create;
  ControlList:=TRtcRecord.Create;
  CS:=TRtcCritSec.Create;

  FDefaultUserAccess:=TRtcPortalGateUserAccess.Create(nil);
  FUsers:=FDefaultUserAccess;

  FAutoRegisterUsers:=False;
  FWriteLog:=False;

  MessPut:=TRtcRecord.Create;
  MessPutTick:=TRtcRecord.Create;
  MessPutDirect:=TRtcRecord.Create;

  MessGet:=TRtcRecord.Create;
  MessGetOld:=TRtcRecord.Create;
  MessGetTick:=TRtcRecord.Create;

  HostSubList:=TRtcRecord.Create;
  ControlSubList:=TRtcRecord.Create;

  MessPut.AutoCreate:=True;
  MessGet.AutoCreate:=True;
  MessGetOld.AutoCreate:=True;
  MessGetTick.AutoCreate:=True;

  HostSubList.AutoCreate:=True;
  ControlSubList.AutoCreate:=True;

  WakesPut:=TRtcInfo.Create;
  WakesGet:=TRtcInfo.Create;

  FResponseTimeout:=20;
  FDataSendTimeout:=20;
  end;

destructor TRtcPortalGateway.Destroy;
  begin
  FunctionGroup:=nil;

  FreeAndNil(FnUserGet);
  FreeAndNil(FnUserSet);
  FreeAndNil(FnUserAdd);
  FreeAndNil(FnUserDel);

  FreeAndNil(FnLogIn);
  FreeAndNil(FnLogOut);
  FreeAndNil(FnReLogin);

  FreeAndNil(FnHost);
  FreeAndNil(FnControl);

  FreeAndNil(FnGet);
  FreeAndNil(FnPut);

  FreeAndNil(FnGroup);

  FUsers:=nil;
  FreeAndNil(FDefaultUserAccess);

  WakesPut.Free;
  WakesGet.Free;

  LogInCounter:=0;
  LoggedIn.Free;
  HostList.Free;
  ControlList.Free;

  HostSubList.Free;
  ControlSubList.Free;

  MessPut.Free;
  MessPutDirect.Free;
  MessPutTick.Free;

  MessGet.Free;
  MessGetOld.Free;
  MessGetTick.Free;

  CS.Free;
  inherited;
  end;

procedure TRtcPortalGateway.LoadInfo;
  begin
  CS.Acquire;
  try
    FUsers.LoadUserInfo(FFileName);
  finally
    CS.Release;
    end;
  end;

procedure TRtcPortalGateway.SaveInfo;
  begin
  CS.Acquire;
  try
    FUsers.SaveUserInfo(FFileName);
  finally
    CS.Release;
    end;
  end;

function TRtcPortalGateway.UserLogin(Sender:TRtcConnection; const username, password:String; const ID: RtcString; uinfo:TRtcRecord):boolean;
  begin
  if username='' then
    raise Exception.Create('Username undefined.')
  else if not isValidUsername(username) then
    raise Exception.Create('Not a valid username. Use only A-Z and 0-9.');
  CS.Acquire;
  try
    if FAutoRegisterUsers and not FUsers.UserExists(UserName) then
      begin
      if assigned(FBeforeRegister) then
        FBeforeRegister(Sender,UserName,Password,uinfo);

      FUsers.RegisterUser(Sender, UserName, Password, uinfo, WriteLog);
      if AutoSaveInfo then
        FUsers.SaveUserInfo(FFileName);

      if assigned(FBeforeLogin) then
        FBeforeLogin(Sender,UserName,Password,uinfo);
      end
    else
      begin
      if assigned(FBeforeLogin) then
        FBeforeLogin(Sender,UserName,Password,uinfo);
      FUsers.LoginUser(Sender, UserName, Password, uinfo, WriteLog);
      end;

    if LoggedIn.isType[username]=rtc_Null then
      begin
      {$IFDEF RTC_TRIAL}
      Result:=false;
      if LogInCounter>=5 then
        raise Exception.Create(S_DEMO_EXCEEDED);
      {$ENDIF}
      LoggedIn.newRecord(username);
      Inc(LogInCounter);
      end
    else if LoggedIn.asRecord[username].asString['ID']<>ID then
      begin
      UserLogout(Sender,username,password,True);
      Inc(LogInCounter);
      LoggedIn.newRecord(username);
      end;

    with LoggedIn.asRecord[username] do
      begin
      Result:=asInteger['count']=0;

      asInteger['count']:=asInteger['count']+1;
      asString['ID']:=ID;
      if assigned(uinfo) then
        begin
        isNull['info']:=True;
        asRecord['info']:=uinfo;
        end;
      end;
  finally
    CS.Release;
    end;
  end;

procedure TRtcPortalGateway.UserReLogin(Sender:TRtcConnection; const username, password:String; const ID: RtcString; uinfo:TRtcRecord);
  begin
  CS.Acquire;
  try
    if UserLoggedIn(Sender,username,ID) then
      UserLogin(Sender,username,password,ID,uinfo)
    else
      raise Exception.Create('Logged out');
  finally
    CS.Release;
    end;
  end;

function TRtcPortalGateway.UserLogOut(Sender:TRtcConnection; const username,password:string; forced:boolean):boolean;
  begin
  Result:=False;

  CS.Acquire;
  try
    if LoggedIn.isType[username]=rtc_Record then
      begin
      if Forced or (LoggedIn.asRecord[username].asInteger['count']=1) then
        begin
        FUsers.LogoutUser(Sender,UserName,Password,WriteLog);

        if WriteLog then xLog(username+': Logging out');

        // End all active subscriptions
        EndSubscriptions(Sender,username);
        // Remove from Host and Control lists
        HostDisconnect(Sender,username);
        ControlDisconnect(Sender,username);
        // Log the user out completely
        LoggedIn.isNull[username]:=True;
        Dec(LogInCounter);
        // Clear users "received messages" queue
        MsgClear(username);
        // Wake up if sleeping
        WakeGet(username);
        WakePut(username);

        Result:=True;
        end
      else
        begin
        with Loggedin.asRecord[username] do
          begin
          asInteger['count']:=asInteger['count']-1;
          if WriteLog then xLog(username+': '+asText['count']+' Sessions left');
          end;
        end;
      end;
  finally
    CS.Release;
    end;
  end;

function TRtcPortalGateway.UserLoggedIn(Sender:TRtcConnection; const username:String; const ID:RtcString): boolean;
  begin
  CS.Acquire;
  try
    if LoggedIn.isType[username]<>rtc_Record then
      Result:=False
    else if LoggedIn.asRecord[username].asString['ID']<>ID then
      Result:=False
    else
      Result:=True;
  finally
    CS.Release;
    end;
  end;

procedure TRtcPortalGateway.HostConnect(Sender:TRtcConnection; const username: string);
  var
    user:TRtcRecord;
    list:TRtcRecord;
    uname:string;
    a:integer;
  begin
  CS.Acquire;
  try
    FUsers.UserAccess(UserName, rtcpUA_HostConnect);

    if HostList.isNull[username] then
      begin
      HostList.asObject[username]:=FUsers.GetUserDataCopy(username);

      user:=HostList.asRecord[username];

      if not user.asBoolean[RD_RESTRICTACCESS] then
        begin
        // notify all connected controls
        for a:=0 to ControlList.Count-1 do
          begin
          uname:=ControlList.FieldName[a];

          if ControlList.isType[uname]<>rtc_Null then
            Msg_HostLogin(username, uname);
          end;
        end
      else if user.isType[RD_ALLOWUSERS]=rtc_Record then
        begin
        list:=user.asRecord[RD_ALLOWUSERS];
        // notify all connected Controls from the "AllowUsers" list
        for a:=0 to list.Count-1 do
          begin
          uname:=list.FieldName[a];
          if list.isType[uname]<>rtc_Null then
            if ControlList.isType[uname]<>rtc_Null then
              Msg_HostLogin(username, uname);
          end;
        end;
      end;
  finally
    CS.Release;
    end;
  end;

procedure TRtcPortalGateway.HostDisconnect(Sender:TRtcConnection; const username: string);
  var
    user:TRtcRecord;
    list:TRtcRecord;
    uname:string;
    a:integer;
  begin
  CS.Acquire;
  try
    FUsers.UserAccess(UserName, rtcpUA_HostDisconnect);

    if HostList.isType[username]=rtc_Record then
      begin
      user:=HostList.asRecord[username];

      if not user.asBoolean[RD_RESTRICTACCESS] then
        begin
        // notify all connected controls
        for a:=0 to ControlList.Count-1 do
          begin
          uname:=ControlList.FieldName[a];
          if ControlList.isType[uname]<>rtc_Null then
            Msg_HostLogout(username,uname);
          end;
        end
      else if user.isType[RD_ALLOWUSERS]=rtc_Record then
        begin
        list:=user.asRecord[RD_ALLOWUSERS];
        // notify all connected Controls from the "AllowUsers" list
        for a:=0 to list.Count-1 do
          begin
          uname:=list.FieldName[a];
          if list.isType[uname]<>rtc_Null then
            if ControlList.isType[uname]<>rtc_Null then
              Msg_HostLogout(username,uname);
          end;
        end;

      HostList.isNull[username]:=True;
      end;
  finally
    CS.Release;
    end;
  end;

procedure TRtcPortalGateway.ControlConnect(Sender:TRtcConnection; const username: string);
  var
    user:TRtcRecord;
    uname:string;
    a:integer;
  begin
  CS.Acquire;
  try
    FUsers.UserAccess(UserName, rtcpUA_ControlConnect);

    if ControlList.isType[username]=rtc_Null then
      begin
      ControlList.asObject[username]:=FUsers.GetUserDataCopy(username);

      for a:=0 to HostList.Count-1 do
        begin
        uname:=HostList.FieldName[a];
        user:=HostList.asRecord[uname];

        if assigned(user) then
          begin
          if not user.asBoolean[RD_RESTRICTACCESS] then
            Msg_HostLogin(uname,username)
          else if user.isType[RD_ALLOWUSERS]=rtc_Record then
            begin
            if user.asRecord[RD_ALLOWUSERS].isType[username]<>rtc_Null then
              Msg_HostLogin(uname,username);
            end;
          end;
        end;
      end;
  finally
    CS.Release;
    end;
  end;

procedure TRtcPortalGateway.ControlDisconnect(Sender:TRtcConnection; const username: string);
  begin
  CS.Acquire;
  try
    FUsers.UserAccess(UserName, rtcpUA_ControlDisconnect);

    if ControlList.isType[username]=rtc_Record then
      ControlList.isNull[username]:=True;
  finally
    CS.Release;
    end;
  end;

procedure TRtcPortalGateway.SubscribeUser(Sender:TRtcConnection; const fromuser, func, touser: string; temp:boolean=False);
  var
    user:TRtcRecord;
  begin
  CS.Acquire;
  try
    FUsers.UserAccess(fromuser, rtcpUA_SubscribeFrom);
    FUsers.UserAccess(touser, rtcpUA_SubscribeTo);

    user:=HostSubList.asRecord[fromuser].asRecord[func];
    if not user.asBoolean[touser] then
      begin
      user.asBoolean[touser]:=True;
      ControlSubList.asRecord[touser].asRecord[func].asBoolean[fromuser]:=True;

      if WriteLog then xLog(fromuser+' ['+Sender.PeerAddr+']: Opened "'+func+'" for Control <'+touser+'>');

      if not temp then
        Msg_Subscribed(fromuser,touser, func);
      end;
  finally
    CS.Release;
    end;
  end;

procedure TRtcPortalGateway.UnSubscribeUser(Sender:TRtcConnection; const fromuser, func, touser: string; temp:boolean=False);
  var
    user:TRtcRecord;
  begin
  CS.Acquire;
  try
    FUsers.UserAccess(fromuser, rtcpUA_UnSubscribeFrom);
    FUsers.UserAccess(touser, rtcpUA_UnSubscribeTo);

    if HostSubList.isType[fromuser]=rtc_Null then Exit // "fromuser" needs to have active subscriptions
    else if ControlSubList.isType[touser]=rtc_Null then Exit // "touser" needs to have active subscriptions
    else
      begin
      user:=HostSubList.asRecord[fromuser].asRecord[func];
      if user.isType[touser]<>rtc_Null then
        begin
        user.isNull[touser]:=True;
        ControlSubList.asRecord[touser].asRecord[func].isNull[fromuser]:=True;

        if WriteLog then xLog(fromuser+' ['+Sender.PeerAddr+']: Closed "'+func+'" for Control <'+touser+'>');

        if not temp then Msg_Unsubscribed(fromuser, touser, func);
        end;
      end;
  finally
    CS.Release;
    end;
  end;

procedure TRtcPortalGateway.EndSubscriptions(Sender:TRtcConnection; const username: string);
  var
    user,list:TRtcRecord;
    uname,func:string;
    a,i:integer;
  begin
  CS.Acquire;
  try
    FUsers.UserAccess(UserName, rtcpUA_EndSubscriptions);

    // signal all Controls when Host logs out
    if HostSubList.isType[username]=rtc_Record then
      begin
      user:=HostSubList.asRecord[username];
      // check all functions subscribed by the user
      for a:=0 to user.Count-1 do
        begin
        func:=user.FieldName[a];
        if user.isType[func]=rtc_Record then
          begin
          list:=user.asRecord[func];
          // check all users subscribed to that function by that user
          for i:=0 to list.Count-1 do
            begin
            uname:=list.FieldName[i];
            if list.isType[uname]<>rtc_Null then
              begin
              list.isNull[uname]:=True;
              ControlSubList.asRecord[uname].asRecord[func].isNull[username]:=True;

              if WriteLog then xLog(username+' ['+Sender.PeerAddr+']: Stopped "'+func+'" with Control <'+uname+'>');

              Msg_UnsubHost(username, uname,func);
              end;
            end;
          end;
        end;
      HostSubList.isNull[username]:=True;
      end;

    // signal all Hosts when Control logs out
    if ControlSubList.isType[username]=rtc_Record then
      begin
      user:=ControlSubList.asRecord[username];
      // check all functions for which this user was subscribed to
      for a:=0 to user.Count-1 do
        begin
        func:=user.FieldName[a];
        if user.isType[func]=rtc_Record then
          begin
          list:=user.asRecord[func];
          // check all users by which this is subscribed for that function
          for i:=0 to list.Count-1 do
            begin
            uname:=list.FieldName[i];
            if list.isType[uname]<>rtc_Null then
              begin
              list.isNull[uname]:=True;
              HostSubList.asRecord[uname].asRecord[func].isNull[username]:=True;

              if WriteLog then xLog(username+' ['+Sender.PeerAddr+']: Terminated "'+func+'" from Host <'+uname+'>');

              Msg_UnsubControl(uname, username, func);
              end;
            end;
          end;
        end;
      ControlSubList.isNull[username]:=True;
      end;
  finally
    CS.Release;
    end;
  end;

procedure TRtcPortalGateway.UnSubscribe(Sender:TRtcConnection; const username,func: string);
  var
    user,list:TRtcRecord;
    uname:string;
    i:integer;
  begin
  CS.Acquire;
  try
    FUsers.UserAccess(UserName, rtcpUA_UnSubscribe);

    // signal all Controls when Host logs out
    if HostSubList.isType[username]=rtc_Record then
      begin
      user:=HostSubList.asRecord[username];
      // check all functions subscribed by the user
      if user.isType[func]=rtc_Record then
        begin
        list:=user.asRecord[func];
        // check all users subscribed to that function by that user
        for i:=0 to list.Count-1 do
          begin
          uname:=list.FieldName[i];
          if list.isType[uname]<>rtc_Null then
            begin
            list.isNull[uname]:=True;
            ControlSubList.asRecord[uname].asRecord[func].isNull[username]:=True;

            if WriteLog then xLog(username+' ['+Sender.PeerAddr+']: Stopped "'+func+'" with Control <'+uname+'>');

            Msg_Unsubscribed(username, uname, func);
            Msg_UnsubHost(username, uname, func);
            end;
          end;
        user.isNull[func]:=True;
        end;
      end;

    // signal all Hosts when Control logs out
    if ControlSubList.isType[username]=rtc_Record then
      begin
      user:=ControlSubList.asRecord[username];
      // check all functions for which this user was subscribed to
      if user.isType[func]=rtc_Record then
        begin
        list:=user.asRecord[func];
        // check all users by which this is subscribed for that function
        for i:=0 to list.Count-1 do
          begin
          uname:=list.FieldName[i];
          if list.isType[uname]<>rtc_Null then
            begin
            list.isNull[uname]:=True;
            HostSubList.asRecord[uname].asRecord[func].isNull[username]:=True;

            if WriteLog then xLog(username+' ['+Sender.PeerAddr+']: Terminated "'+func+'" from Host <'+uname+'>');

            Msg_Unsubscribed(uname, username, func);
            Msg_UnsubControl(uname, username, func);
            end;
          end;
        user.isNull[func]:=True;
        end;
      end;
  finally
    CS.Release;
    end;
  end;

function TRtcPortalGateway.UserGet(Sender:TRtcConnection; const username: string): TRtcRecord;
  begin
  if username='' then
    raise Exception.Create('Username undefined.');
  CS.Acquire;
  try
    FUsers.UserAccess(UserName, rtcpUA_GetParams);

    Result:=FUsers.GetUserDataCopy(UserName);
  finally
    CS.Release;
    end;
  end;

procedure TRtcPortalGateway.UserSet(Sender:TRtcConnection; const username: string; data: TRtcRecord);
  var
    i:integer;
    fname:string;
    udata:TRtcRecord;
  begin
  if username='' then
    raise Exception.Create('Username undefined.');
  CS.Acquire;
  try
    FUsers.UserAccess(UserName, rtcpUA_SetParams);
    udata:=FUsers.GetUserDataCopy(UserName);

    try
      with udata do
        begin
        for i:=0 to data.FieldCount-1 do
          begin
          fname:=data.FieldName[i];
          if fname<>'' then
            begin
            isNull[fname]:=True;
            asObject[fname]:=data.asObject[fname];
            data.asObject[fname]:=nil;
            end;
          end;
        end;
    except
      FreeAndNil(udata);
      raise;
      end;

    FUsers.SetUserData(UserName, udata);
    if AutoSaveInfo then
      FUsers.SaveUserInfo(FFileName);
  finally
    CS.Release;
    end;
  end;

procedure TRtcPortalGateway.UserAdd(Sender:TRtcConnection; const username: string; data: TRtcRecord);
  var
    i,j:integer;
    fname, rname:string;
    rec:TRtcRecord;
    srec,drec:TRtcRecord;
    sarr,darr:TRtcArray;
    sdat,ddat:TRtcDataSet;
  begin
  if username='' then
    raise Exception.Create('Username undefined.');
  CS.Acquire;
  try
    FUsers.UserAccess(UserName, rtcpUA_AddParams);
    rec:=FUsers.GetUserDataCopy(UserName);

    try
      for i:=data.FieldCount-1 downto 0 do
        begin
        fname:=data.FieldName[i];
        if fname<>'' then
          begin
          if rec.isType[fname]=rtc_Null then
            begin
            rec.asObject[fname]:=data.asObject[fname];
            data.asObject[fname]:=nil;
            end
          else if data.asObject[fname] is TRtcSimpleValue then
            begin
            rec.isNull[fname]:=True;
            rec.asObject[fname]:=data.asObject[fname];
            data.asObject[fname]:=nil;
            end
          else if data.isType[fname]<>rec.isType[fname] then
            raise Exception.Create('Incompatible Data Type (Field: '+fname+')')
          else if data.isType[fname]=rtc_Record then
            begin
            drec:=rec.asRecord[fname];
            srec:=data.asRecord[fname];
            for j:=0 to srec.FieldCount-1 do
              begin
              rname:=srec.FieldName[j];
              drec.isNull[rname]:=True;
              drec.asObject[rname]:=srec.asObject[rname];
              end;
            for j:=srec.FieldCount-1 downto 0 do
              srec.asObject[rname]:=nil;
            end
          else if data.isType[fname]=rtc_Array then
            begin
            sarr:=data.asArray[fname];
            darr:=rec.asArray[fname];
            for j:=0 to sarr.FieldCount-1 do
              darr.asObject[darr.Count]:=sarr.asObject[j];
            for j:=sarr.FieldCount-1 downto 0 do
              sarr.asObject[j]:=nil;
            end
          else if data.isType[fname]=rtc_DataSet then
            begin
            sdat:=data.asDataSet[fname];
            ddat:=rec.asDataSet[fname];
            sdat.First;
            while not sdat.EOF do
              begin
              ddat.Append;
              for j:=0 to sdat.FieldCount-1 do
                begin
                rname:=sdat.FieldName[j];
                ddat.isNull[rname]:=True;
                ddat.asObject[rname]:=sdat.asObject[rname];
                end;
              for j:=sdat.FieldCount-1 downto 0 do
                sdat.asObject[rname]:=nil;
              sdat.Next;
              end;
            end
          else
            raise Exception.Create('Unsupported data type (Field: '+fname+')');
          end;
        end;
    except
      FreeAndNil(rec);
      raise;
      end;

    FUsers.SetUserData(UserName,rec);
    if AutoSaveInfo then
      FUsers.SaveUserInfo(FFileName);
  finally
    CS.Release;
    end;
  end;

procedure TRtcPortalGateway.UserDel(Sender:TRtcConnection; const username: string; data: TRtcRecord);
  var
    i,j,k:integer;
    fname, rname:string;
    rec:TRtcRecord;
    srec,drec:TRtcRecord;
    sarr,darr:TRtcArray;
    sdat,ddat:TRtcDataSet;
    found:boolean;
  begin
  if username='' then
    raise Exception.Create('Username undefined.');
  CS.Acquire;
  try
    FUsers.UserAccess(UserName, rtcpUA_DelParams);
    rec:=FUsers.GetUserDataCopy(UserName);

    try
      for i:=0 to data.FieldCount-1 do
        begin
        fname:=data.FieldName[i];
        if (fname<>'') and (rec.isType[fname]<>rtc_Null) then
          begin
          if data.asObject[fname] is TRtcSimpleValue then
            rec.isNull[fname]:=True
          else if data.isType[fname]<>rec.isType[fname] then
            raise Exception.Create('Incompatible Data Type (Field: '+fname+')')
          else if data.isType[fname]=rtc_Record then
            begin
            drec:=rec.asRecord[fname];
            srec:=data.asRecord[fname];
            for j:=0 to srec.FieldCount-1 do
              begin
              rname:=srec.FieldName[j];
              drec.isNull[rname]:=True;
              end;
            end
          else if data.isType[fname]=rtc_Array then
            begin
            sarr:=data.asArray[fname];
            darr:=rec.asArray[fname];
            for j:=0 to sarr.FieldCount-1 do
              for k:=0 to darr.FieldCount-1 do
                if darr.toCode[k]=sarr.toCode[j] then
                  darr.isNull[k]:=True;
            end
          else if data.isType[fname]=rtc_DataSet then
            begin
            sdat:=data.asDataSet[fname];
            ddat:=rec.asDataSet[fname];
            sdat.First;
            while not sdat.EOF and (ddat.RowCount>0) do
              begin
              ddat.Last;
              while not ddat.BOF do
                begin
                found:=True;
                for j:=0 to sdat.FieldCount-1 do
                  begin
                  rname:=sdat.FieldName[j];
                  if ddat.asCode[rname]<>sdat.asCode[rname] then
                    begin
                    found:=False;
                    Break;
                    end;
                  end;
                if found then
                  ddat.Delete
                else
                  ddat.Prior;
                end;
              sdat.Next;
              end;
            end
          else
            raise Exception.Create('Unsupported data type (Field: '+fname+')');
          end;
        end;
    except
      FreeAndNil(rec);
      raise;
      end;

    FUsers.SetUserData(UserName,rec);
    if AutoSaveInfo then
      SaveInfo;
  finally
    CS.Release;
    end;
  end;

procedure TRtcPortalGateway.FnReLoginExecute(Sender: TRtcConnection; Param: TRtcFunctionInfo; Result: TRtcValue);
  begin
  if WriteLog then xLog(Param.asString['user']+' ['+Sender.PeerAddr+']: Re-Login check');
  // we will log the user in (again) ONLY if he is already logged in under the same ID
  UserReLogin(Sender,Param.asText['user'], Param.asText['pwd'], Param.asString['id'], Param.asRecord['info']);
  with TRtcDataServer(Sender) do
    begin
    Session.asBoolean['login']:=True;
    Session.asString['ID']:=Param.asString['id'];
    Session.asText['user']:=Param.asText['user'];
    Session.asText['pwd']:=Param.asText['pwd'];
    end;
  end;

procedure TRtcPortalGateway.FnLogInExecute(Sender: TRtcConnection; Param: TRtcFunctionInfo; Result: TRtcValue);
  begin
  if WriteLog then xLog(Param.asString['user']+' ['+Sender.PeerAddr+']: Login check');

  if UserLogin(Sender,Param.asText['user'], Param.asText['pwd'], Param.asString['id'], Param.asRecord['info']) then
    begin
    if WriteLog then xLog(Param.asString['user']+' ['+Sender.PeerAddr+']: LOGGED IN');
    DoTextEvent(Sender,FOnUserLogin,Param.asText['user']);
    end;

  with TRtcDataServer(Sender) do
    begin
    Session.asBoolean['login']:=True;
    Session.asString['ID']:=Param.asString['id'];
    Session.asText['user']:=Param.asText['user'];
    Session.asText['pwd']:=Param.asText['pwd'];
    end;
  end;

procedure TRtcPortalGateway.FnLogOutExecute(Sender: TRtcConnection; Param: TRtcFunctionInfo; Result: TRtcValue);
  begin
  if WriteLog then xLog(Param.asString['user']+' ['+Sender.PeerAddr+']: Logout check');
  // Log the user completely out ...
  with TRtcDataServer(Sender) do
    begin
    if UserLogout(Sender,Param.asText['user'], Param.asText['pwd'], True) then
      begin
      if WriteLog then xLog(Param.asString['user']+' ['+Sender.PeerAddr+']: LOGGED OUT');
      DoTextEvent(Sender,FOnUserLogout,Param.asText['user']);
      end;

    if Session.asBoolean['login'] then
      begin
      Session.asBoolean['login']:=False;
      Session.Close;
      end;
    end;
  end;

procedure TRtcPortalGateway.ServerModuleSessionClose(Sender: TRtcConnection);
  begin
  if assigned(FOnSessionClosing) then
    FOnSessionClosing(Sender);
  // Log the user out if there are no other active user sessions ...
  with TRtcDataServer(Sender) do
    if Session.asBoolean['login'] then
      begin
      if WriteLog then xLog(Session.asString['user']+': Session expired');
      // we will log the user out ONLY if he is logged in under the same ID
      if UserLoggedIn(Sender,Session.asText['user'], Session.asString['ID']) then
        if UserLogout(Sender,Session.asText['user'],Session.asText['pwd'],False) then
          begin
          if WriteLog then xLog(Session.asString['user']+': LOGGED OUT');
          DoTextEvent(Sender,FOnUserLogout,Session.asText['user']);
          end;
      Session.asBoolean['login']:=False;
      end;
  end;

procedure TRtcPortalGateway.FnUserGetExecute(Sender: TRtcConnection; Param: TRtcFunctionInfo; Result: TRtcValue);
  begin
  with TRtcDataServer(Sender) do
    if not Session.asBoolean['login'] then
      raise Exception.Create('Not logged in')
    else
      Result.asObject:=UserGet(Sender,Session.asText['user']);
  end;

procedure TRtcPortalGateway.FnUserSetExecute(Sender: TRtcConnection; Param: TRtcFunctionInfo; Result: TRtcValue);
  begin
  with TRtcDataServer(Sender) do
    if not Session.asBoolean['login'] then
      raise Exception.Create('Not logged in')
    else
      UserSet(Sender,Session.asText['user'], Param);
  end;

procedure TRtcPortalGateway.FnUserAddExecute(Sender: TRtcConnection; Param: TRtcFunctionInfo; Result: TRtcValue);
  begin
  with TRtcDataServer(Sender) do
    if not Session.asBoolean['login'] then
      raise Exception.Create('Not logged in')
    else
      UserAdd(Sender,Session.asText['user'], Param);
  end;

procedure TRtcPortalGateway.FnUserDelExecute(Sender: TRtcConnection; Param: TRtcFunctionInfo; Result: TRtcValue);
  begin
  with TRtcDataServer(Sender) do
    if not Session.asBoolean['login'] then
      raise Exception.Create('Not logged in')
    else
      UserDel(Sender,Session.asText['user'], Param);
  end;

function TRtcPortalGateway.SetWakePut(const user: string; Call: TRtcDelayedCall):boolean;
  begin
  CS.Acquire;
  try
    WakesPut.asPtr[user]:=nil;
    if WakesPut.asBoolean[user] or // somebody is already waking us up
       not MessPutDirect.asBoolean[user] then // nothing there to wait for
      begin
      Result:=False;
      WakesPut.isNull[user]:=True;
      Call.Free;
      end
    else
      begin
      Result:=True;
      WakesPut.asPtr[user]:=Call;
      end;
  finally
    CS.Release;
    end;
  end;

function TRtcPortalGateway.SetWakeGet(const user: string; Call: TRtcDelayedCall):boolean;
  begin
  CS.Acquire;
  try
    WakesGet.asPtr[user]:=nil;
    if WakesGet.asBoolean[user] then
      begin
      Result:=False;
      WakesGet.isNull[user]:=True;
      Call.Free;
      end
    else
      begin
      Result:=True;
      WakesGet.asPtr[user]:=Call;
      end;
  finally
    CS.Release;
    end;
  end;

procedure TRtcPortalGateway.ClearWakePut(const user: string);
  begin
  CS.Acquire;
  try
    WakesPut.asPtr[user]:=nil;
    WakesPut.isNull[user]:=True;
  finally
    CS.Release;
    end;
  end;

procedure TRtcPortalGateway.ClearWakeGet(const user: string);
  begin
  CS.Acquire;
  try
    WakesGet.asPtr[user]:=nil;
    WakesGet.isNull[user]:=True;
  finally
    CS.Release;
    end;
  end;

procedure TRtcPortalGateway.WakePut(const user: string);
  var
    Call:TRtcDelayedCall;
  begin
  CS.Acquire;
  try
    Call:=TRtcDelayedCall(WakesPut.asPtr[user]);
    WakesPut.asBoolean[user]:=True;
    WakesPut.asBoolean[user]:=True;
    if assigned(Call) then
      WakesPut.asPtr[user]:=nil;
  finally
    CS.Release;
    end;
  if assigned(Call) then
    Call.WakeUp;
  end;

procedure TRtcPortalGateway.WakeGet(const user: string);
  var
    Call:TRtcDelayedCall;
  begin
  CS.Acquire;
  try
    Call:=TRtcDelayedCall(WakesGet.asPtr[user]);
    WakesGet.asBoolean[user]:=True;
    WakesGet.asBoolean[user]:=True;
    if assigned(Call) then
      WakesGet.asPtr[user]:=nil;
  finally
    CS.Release;
    end;
  if assigned(Call) then
    Call.WakeUp;
  end;

{ Return TRUE if this is not the same Tick as the one we remember,
  which would indicate that this is the first time this package has arrived. }
function TRtcPortalGateway.CheckMsgPut(const fromuser: string; Tick: Integer): boolean;
  begin
  CS.Acquire;
  try
    Result:=MessPutTick.asInteger[fromuser]<>Tick;
    if Result then
      MessPutTick.asInteger[fromuser]:=Tick;
  finally
    CS.Release;
    end;
  end;

{ Store "data" in the mesage queue for user "uname".
  NOTE: "data" object will be invalid after this call. }
procedure TRtcPortalGateway.MsgPut(const fromuser: string; const uname:string; const data: TRtcValueObject; direct:boolean=False);
  var
    MGet:TRtcArray;
  begin
  CS.Acquire;
  try
    if LoggedIn.isType[uname]<>rtc_Null then
      begin
      // increment the message counter
      MessPut.asInteger[fromuser]:=MessPut.asInteger[fromuser]+1;
      if direct then
        // do we need to notify the sender when all data has been picked up?
        MessPutDirect.asBoolean[fromuser]:=True;

      // Find "to user's" array for "from user"
      MGet:=MessGet.asRecord[uname].asArray[fromuser];

      // Add "data" to user's message queue
      // user gets the original "data"
      MGet.asObject[MGet.Count]:=data;

      // wake the receiver up, there is new data waiting
      WakeGet(uname);
      end;
  finally
    CS.Release;
    end;
  end;

procedure TRtcPortalGateway.MsgPutFn(const fromuser, forfn: string; const data: TRtcValueObject; direct:boolean=False);
  var
    a:integer;
    first:boolean;
    MGet:TRtcArray;
    uname:string;
    forusers:TRtcRecord;
  begin
  CS.Acquire;
  try
    first:=True;
    if HostSubList.isType[fromuser]=rtc_Record then
      begin
      // Get the list of users for this function
      forusers:=HostSubList.asRecord[fromuser].asRecord[forfn];
      for a:=0 to forusers.Count-1 do
        begin
        uname:=forusers.FieldName[a];
        if uname<>fromuser then
          begin
          if forusers.isType[uname]<>rtc_Null then
            begin
            if LoggedIn.isType[uname]<>rtc_Null then
              begin
              // increment the message counter
              MessPut.asInteger[fromuser]:=MessPut.asInteger[fromuser]+1;
              if direct then
                MessPutDirect.asBoolean[fromuser]:=True;

              // Find "to user's" array for "from user"
              MGet:=MessGet.asRecord[uname].asArray[fromuser];

              // Add "data" to user's message queue
              if first then
                begin
                MGet.asObject[MGet.Count]:=data; // first user gets the original "data"
                first:=False;
                end
              else
                MGet.asObject[MGet.Count]:=data.copyOf; // all other users get a copy of "data"

              // wake the receiver up, there is new data waiting
              WakeGet(uname);
              end;
            end;
          end;
        end;
      end;
    // message not sent to anyone? free the original
    if first then data.Free;
  finally
    CS.Release;
    end;
  end;

{ Get all messages stored for the user "foruser".
  If no messages were stored, return NIL.
  Result object needs to be freed (it is not just a pointer, but a copy). }
function TRtcPortalGateway.MsgGet(const foruser: string; Tick:longint):TRtcRecord;
  var
    a:integer;
    MGet:TRtcRecord;
    uname:string;
  begin
  CS.Acquire;
  try
    // re-send old message(s)
    if MessGetTick.asInteger[foruser]=Tick then
      begin
      if MessGetOld.isType[foruser]=rtc_Record then
        Result:=TRtcRecord(MessGetOld.asObject[foruser].copyOf)
      else
        Result:=nil;
      end
    else
    // send new message(s)
      begin
      MessGetOld.isNull[foruser]:=True;
      if MessGet.isType[foruser]<>rtc_Record then
        begin
        // last check had nothing to send
        MessGetTick.asInteger[foruser]:=-1;
        Result:=nil;
        end
      else
        begin
        MGet:=MessGet.asRecord[foruser];
        MessGetTick.asInteger[foruser]:=Tick;
        MessGet.asObject[foruser]:=nil;
        // Store messages, so we can re-send them if sending fails
        if Tick>0 then
          MessGetOld.asRecord[foruser]:=MGet;
        // Return original message
        Result:=MGet;
        for a:=0 to MGet.Count-1 do
          begin
          uname:=MGet.FieldName[a];
          // decrement the number of messages waiting for pickup
          if MGet.isType[uname]=rtc_Array then
            begin
            MessPut.asInteger[uname]:=MessPut.asInteger[uname]-MGet.asArray[uname].Count;
            if MessPut.asInteger[uname]<=0 then
              begin
              MessPut.asInteger[uname]:=0;
              if MessPutDirect.asBoolean[uname] then
                begin
                MessPutDirect.asBoolean[uname]:=False;
                WakePut(uname);
                end;
              end;
            end;
          end;
        end;
      end;
  finally
    CS.Release;
    end;
  end;

{ Clear all messages stored for the user "foruser" }
procedure TRtcPortalGateway.MsgClear(const foruser: string);
  var
    a:integer;
    MGet:TRtcRecord;
    uname:string;
  begin
  CS.Acquire;
  try
    MessGetOld.isNull[foruser]:=True;
    MessGetTick.isNull[foruser]:=True;
    MessPut.isNull[foruser]:=True;
    MessPutTick.isNull[foruser]:=True;
    MessPutDirect.isNull[foruser]:=True;
    if MessGet.isType[foruser]=rtc_Record then
      begin
      MGet:=MessGet.asRecord[foruser];
      try
        MessGet.asObject[foruser]:=nil;
        for a:=0 to MGet.Count-1 do
          begin
          uname:=MGet.FieldName[a];
          // decrement the number of messages waiting for pickup
          if MGet.isType[uname]=rtc_Array then
            begin
            MessPut.asInteger[uname]:=MessPut.asInteger[uname]-MGet.asArray[uname].Count;
            if (MessPut.asInteger[uname]=0) and MessPutDirect.asBoolean[uname] then
              begin
              MessPutDirect.asBoolean[uname]:=False;
              WakePut(uname);
              end;
            end;
          end;
      finally
        MGet.Free;
        end;
      end;
  finally
    CS.Release;
    end;
  end;

procedure TRtcPortalGateway.Msg_HostLogin(const uhost, ucontrol: string);
  var
    rec:TRtcBooleanValue;
    rec2:TRtcRecord;
    uinfo:TRtcRecord;
  begin
  uinfo:=LoggedIn.asRecord[uhost];
  if assigned(uinfo) then
    uinfo := uinfo.asRecord['info'];
  if assigned(uinfo) then
    begin
    rec2:=TRtcRecord.Create;
    rec2.asBoolean['in']:=True;
    rec2.asRecord['info']:=uinfo;
    MsgPut(uhost,ucontrol,rec2);
    end
  else
    begin
    rec:=TRtcBooleanValue.Create(True);
    MsgPut(uhost,ucontrol,rec);
    end;
  end;

procedure TRtcPortalGateway.Msg_HostLogout(const uhost, ucontrol: string);
  var
    rec:TRtcBooleanValue;
  begin
  rec:=TRtcBooleanValue.Create(False);
  MsgPut(uhost,ucontrol,rec);
  end;

procedure TRtcPortalGateway.Msg_Subscribed(const uhost, ucontrol, func: string);
  var
    rec:TRtcRecord;
    uinfo:TRtcRecord;
  begin
  // send message to Host for activation
  rec:=TRtcRecord.Create;
  rec.asBoolean['on']:=True;
  rec.asText['fn']:=func;
  rec.asText['user']:=ucontrol;
  uinfo:=LoggedIn.asRecord[ucontrol];
  if assigned(uinfo) then
    uinfo:=uinfo.asRecord['info'];
  if assigned(uinfo) then
    rec.asRecord['info']:=uinfo;
  MsgPut(uhost,uhost,rec); // need to send from self to self, to know it is a genuine message

  // send message to Control for confirmation
  rec:=TRtcRecord.Create;
  rec.asBoolean['on']:=True;
  rec.asText['fn']:=func;
  rec.asText['user']:=uhost;
  uinfo:=LoggedIn.asRecord[uhost];
  if assigned(uinfo) then
    uinfo:=uinfo.asRecord['info'];
  if assigned(uinfo) then
    rec.asRecord['info']:=uinfo;
  MsgPut(uhost,ucontrol,rec);
  end;

procedure TRtcPortalGateway.Msg_Unsubscribed(const uhost, ucontrol, func: string);
  var
    rec:TRtcRecord;
  begin
  // send message to Host for deactivation
  rec:=TRtcRecord.Create;
  rec.asBoolean['off']:=True;
  rec.asText['fn']:=func;
  rec.asText['user']:=ucontrol;
  MsgPut(uhost,uhost,rec); // need to send from self to self, to know it is a genuine message

  // send message to Control for deactivation
  rec:=TRtcRecord.Create;
  rec.asBoolean['off']:=True;
  rec.asText['fn']:=func;
  rec.asText['user']:=uhost;
  MsgPut(uhost,ucontrol,rec);
  end;

procedure TRtcPortalGateway.Msg_UnsubControl(const uhost, ucontrol, func: string);
  var
    rec:TRtcRecord;
  begin
  // send message to Host for deactivation
  rec:=TRtcRecord.Create;
  rec.asBoolean['off']:=True;
  rec.asText['fn']:=func;
  rec.asText['user']:=ucontrol;
  MsgPut(uhost,uhost,rec); // need to send from self to self, to know it is a genuine message
  end;

procedure TRtcPortalGateway.Msg_UnsubHost(const uhost, ucontrol, func: string);
  var
    rec:TRtcRecord;
  begin
  // send message to Control for deactivation
  rec:=TRtcRecord.Create;
  rec.asBoolean['off']:=True;
  rec.asText['fn']:=func;
  rec.asText['user']:=uhost;
  MsgPut(uhost,ucontrol,rec);
  end;

procedure TRtcPortalGateway.FnHostExecute(Sender: TRtcConnection; Param: TRtcFunctionInfo; Result: TRtcValue);
  begin
  with TRtcDataServer(Sender) do
    begin
    if not Session.asBoolean['login'] then
      raise Exception.Create('Not logged in')
    else if Param.asBoolean['on'] then
      begin
      if WriteLog then xLog(Session.asString['user']+' ['+Sender.PeerAddr+']: HOST START');
      HostConnect(Sender,Session.asText['user']);
      end
    else
      begin
      if WriteLog then xLog(Session.asString['user']+' ['+Sender.PeerAddr+']: HOST STOP');
      HostDisconnect(Sender,Session.asText['user']);
      end;
    end;
  end;

procedure TRtcPortalGateway.FnControlExecute(Sender: TRtcConnection; Param: TRtcFunctionInfo; Result: TRtcValue);
  begin
  with TRtcDataServer(Sender) do
    begin
    if not Session.asBoolean['login'] then
      raise Exception.Create('Not logged in')
    else if Param.asBoolean['on'] then
      begin
      if WriteLog then xLog(Session.asString['user']+' ['+Sender.PeerAddr+']: CONTROL START');
      ControlConnect(Sender,Session.asText['user']);
      end
    else
      begin
      if WriteLog then xLog(Session.asString['user']+' ['+Sender.PeerAddr+']: CONTROL STOP');
      ControlDisconnect(Sender,Session.asText['user']);
      end;
    end;
  end;

procedure TRtcPortalGateway.FnPutExecute(Sender: TRtcConnection; Param: TRtcFunctionInfo; Result: TRtcValue);
  var
    dat:TRtcDataSet;
    dc:TRtcDelayedCall;
  begin
  // Check for received messages
  with TRtcDataServer(Sender) do
    begin
    if not Session.asBoolean['login'] then
      begin
      if WriteLog then xLog(Session.asString['user']+' ['+Sender.PeerAddr+']: (PUT) NOT LOGGED IN');
      raise Exception.Create('Not logged in');
      end;

    // if user logged out, clear session
    if not UserLoggedIn(Sender,Session.asText['user'], Session.asString['ID']) then
      begin
      if WriteLog then xLog(Session.asString['user']+' ['+Sender.PeerAddr+']: (PUT) User logged out');
      Session.asBoolean['login']:=False;
      Session.Close;
      Result.asException:='Logged out';
      Exit; // EXIT HERE !!!!
      end;

    // put message(s)
    if Param.isType['p']=rtc_DataSet then
      begin
      if CheckMsgPut(Session.asText['user'], Param.asInteger['x']) then
        begin
        dat:=Param.asDataSet['p'];
        dat.First;
        while not dat.EOF do
          begin
          if dat.isType['d']<>rtc_Null then
            begin
            if dat.isType['to'] in [rtc_String,rtc_Text] then
              MsgPut(Session.asText['user'], dat.asText['to'], dat.asObject['d'], true)
            else if dat.isType['fn'] in [rtc_String,rtc_Text] then
              MsgPutFn(Session.asText['user'], dat.asText['fn'], dat.asObject['d'], true)
            else
              raise Exception.Create('Message destination undefined');
            dat.asObject['d']:=nil;
            end
          else if dat.isType['s'] in [rtc_String,rtc_Text] then
            SubscribeUser(Sender, Session.asText['user'], dat.asText['s'], dat.asText['user'])
          else if dat.isType['u'] in [rtc_String,rtc_Text] then
            UnSubscribeUser(Sender, Session.asText['user'], dat.asText['u'], dat.asText['user'])
          else if dat.isType['t'] in [rtc_String,rtc_Text] then
            UnSubscribeUser(Sender, dat.asText['user'], dat.asText['t'], Session.asText['user'])
          else if dat.isType['uf'] in [rtc_String,rtc_Text] then
            UnSubscribe(Sender,Session.asText['user'], dat.asText['uf'])
          else
            raise Exception.Create('Message not recognized');
          dat.Next;
          end;
        end;
      // clear the Messages structure
      Param.isNull['p']:=True;
      end
    else if Param.isType['put']<>rtc_Null then
      raise Exception.Create('Your client is not compatible with this Gateway.');

    // Check if we need to wait for message pickup ..
    if not Param.asBoolean['$run'] and (FResponseTimeout>0) then
      begin
      Param.asBoolean['$run']:=True;
      // We will wait up to 10 seconds for all messages to be picked up
      dc:=PrepareDelayedCall(FResponseTimeout*1000,Param,FnPutExecute);
      if SetWakePut(Session.asText['user'],dc) then
        PostDelayedCall(dc);
      end
    else
      ClearWakePut(Session.asText['user']);
    end;
  end;

// Put messages into the message queue
// if "get=True", wait until they have been picked up or we have received a message
procedure TRtcPortalGateway.FnGetExecute(Sender: TRtcConnection; Param: TRtcFunctionInfo; Result: TRtcValue);
  var
    dc:TRtcDelayedCall;
    rec:TRtcRecord;
  begin
  // Check for received messages
  with TRtcDataServer(Sender) do
    begin
    if not Session.asBoolean['login'] then
      begin
      if WriteLog then xLog(Session.asString['user']+' ['+Sender.PeerAddr+']: (GET) NOT LOGGED IN');
      raise Exception.Create('Not logged in');
      end;

    // if user logged out, clear session
    if not UserLoggedIn(Sender,Session.asText['user'], Session.asString['ID']) then
      begin
      if WriteLog then xLog(Session.asString['user']+' ['+Sender.PeerAddr+']: (GET) User logged out');
      Session.asBoolean['login']:=False;
      Session.Close;
      Result.asException:='Logged out';
      Exit; // EXIT HERE !!!
      end;

    Session.KeepAlive:=FDataSendTimeout;

    // wait for new messages ...
    rec:=MsgGet(Session.asText['user'], Param.asInteger['x']);
    if rec<>nil then
      begin
      Result.asObject:=rec;
      if Param.asBoolean['$run'] then
        ClearWakeGet(Session.asText['user']);
      end
    else if not Param.asBoolean['$run'] and (FResponseTimeout>0) then
      begin
      Param.asBoolean['$run']:=True;
      // Wait up to 20 seconds for a message ...
      dc:=PrepareDelayedCall(FResponseTimeout*1000,Param,FnGetExecute);
      if SetWakeGet(Session.asText['user'],dc) then
        PostDelayedCall(dc);
      end
    else
      ClearWakeGet(Session.asText['user']);
    end;
  end;

function TRtcPortalGateway.isValidUsername(const username: string): boolean;
  var
    a:integer;
  begin
  Result:=length(username)>0;
  for a:=1 to length(username) do
    case username[a] of
      ':','"','=',';':
        begin
        Result:=False;
        Break;
        end;
      end;
  end;

type
  TSyncTextEvent=class(TObject)
    SText:string;
    STextEvent:TRtcPortalUserEvent;
    end;

procedure TRtcPortalGateway.DoTextEvent(Sender: TRtcConnection; Event: TRtcPortalUserEvent; const s: string);
  var
    obj:TSyncTextEvent;
  begin
  if assigned(Event) then
    if FSyncUserEvents and assigned(Sender) and not Sender.inMainThread then
      begin
      obj:=TSyncTextEvent.Create;
      try
        obj.SText:=s;
        obj.STextEvent:=Event;
        Sender.Sync(SyncTextEvent,obj);
      finally
        obj.Free;
        end;
      end
    else
      Event(s);
  end;

procedure TRtcPortalGateway.SyncTextEvent(Sender: TRtcConnection; obj:TObject);
  var
    sobj:TSyncTextEvent absolute obj;
  begin
  sobj.STextEvent(sobj.SText);
  end;

function TRtcPortalGateway.GetHelperFunctionGroup: TRtcFunctionGroup;
  begin
  if assigned(FnGroup) then
    Result:=FnGroup.HelperGroup
  else
    Result:=nil;
  end;

procedure TRtcPortalGateway.SetHelperFunctionGroup(const Value: TRtcFunctionGroup);
  begin
  if assigned(FnGroup) then
    FnGroup.HelperGroup:=Value;
  end;

function TRtcPortalGateway.GetAfterExecute: TRtcFunctionCallEvent;
  begin
  if assigned(FnGroup) then
    Result:=FnGroup.AfterExecute
  else
    Result:=nil;
  end;

function TRtcPortalGateway.GetBeforeExecute: TRtcFunctionCallEvent;
  begin
  if assigned(FnGroup) then
    Result:=FnGroup.BeforeExecute
  else
    Result:=nil;
  end;

function TRtcPortalGateway.GetOnWrongCall: TRtcFunctionCallEvent;
  begin
  if assigned(FnGroup) then
    Result:=FnGroup.OnWrongCall
  else
    Result:=nil;
  end;

procedure TRtcPortalGateway.SetAfterExecute(const Value: TRtcFunctionCallEvent);
  begin
  if assigned(FnGroup) then FnGroup.AfterExecute:=Value;
  end;

procedure TRtcPortalGateway.SetBeforeExecute(const Value: TRtcFunctionCallEvent);
  begin
  if assigned(FnGroup) then FnGroup.BeforeExecute:=Value;
  end;

procedure TRtcPortalGateway.SetOnWrongCall(const Value: TRtcFunctionCallEvent);
  begin
  if assigned(FnGroup) then FnGroup.OnWrongCall:=Value;
  end;

procedure TRtcPortalGateway.Lock;
  begin
  if assigned(CS) then CS.Acquire;
  end;

procedure TRtcPortalGateway.UnLock;
  begin
  if assigned(CS) then CS.Release;
  end;

procedure TRtcPortalGateway.SetInfoFileName(const Value: string);
  begin
  FFileName := Value;
  if AutoSaveInfo and (FFileName<>'') then LoadInfo;
  end;

procedure TRtcPortalGateway.SetAutoSaveInfo(const Value: boolean);
  begin
  FAutoSave := Value;
  if AutoSaveInfo and (FFileName<>'') then LoadInfo;
  end;

procedure TRtcPortalGateway.SetAutoRegisterUsers(const Value: boolean);
  begin
  FAutoRegisterUsers := Value;
  end;

function TRtcPortalGateway.GetUserAccess: TRtcPortalUserAccess;
  begin
  if not assigned(FUsers) then
    Result:=nil
  else if FUsers=FDefaultUserAccess then
    Result:=nil
  else
    Result:=FUsers;
  end;

procedure TRtcPortalGateway.SetUserAccess(const Value: TRtcPortalUserAccess);
  begin
  if not assigned(Value) then
    FUsers:=FDefaultUserAccess
  else
    FUsers:=Value;
  end;

procedure TRtcPortalGateway.Notification(AComponent: TComponent; Operation: TOperation);
  begin
  inherited Notification(AComponent,Operation);
  if Operation=opRemove then
    if AComponent=FUsers then
      FUsers:=FDefaultUserAccess
    else if AComponent=FnGroup.HelperGroup then
      FnGroup.HelperGroup:=nil;
  end;

{ TRtcPortalUserAccess }

constructor TRtcPortalGateUserAccess.Create(AOwner: TComponent);
  begin
  inherited;
  UserList:=TRtcRecord.Create;
  end;

destructor TRtcPortalGateUserAccess.Destroy;
  begin
  UserList.Free;
  inherited;
  end;

procedure TRtcPortalGateUserAccess.LoadUserInfo(const FileName: String);
  var
    s:RtcString;
  begin
  s:=Read_File(FileName,0,-1);
  if s<>'' then
    begin
    if assigned(UserList) then UserList.Free;
    UserList:=TRtcRecord.FromCode(s);
    end
  else
    UserList.Clear;
  end;

procedure TRtcPortalGateUserAccess.SaveUserInfo(const FileName: String);
  begin
  Write_File(FileName,UserList.toCode);
  end;

function TRtcPortalGateUserAccess.UserExists(const UserName: String): boolean;
  begin
  Result:=UserList.isType[username]=rtc_Record;
  end;

procedure TRtcPortalGateUserAccess.RegisterUser(Sender: TRtcConnection; const UserName, Password: String; UserInfo: TRtcRecord; WriteLog:boolean);
  begin
  if UserList.isNull[username] then
    begin
    // User not in our records? Create a new user record
    UserList.newRecord(username).asText['pwd']:=password;
    if WriteLog then xLog(username+' ['+Sender.PeerAddr+']: NEW USER CREATED');
    end
  else if UserList.asRecord[username].asText['pwd']<>password then
    begin
    if WriteLog then xLog(username+' ['+Sender.PeerAddr+']: INVALID LOGIN (Wrong Password)');
    // User tried to log in with wrong password
    raise Exception.Create('Username already taken, password does NOT match.');
    end;
  end;

procedure TRtcPortalGateUserAccess.LoginUser(Sender: TRtcConnection; const UserName, Password: String; UserInfo: TRtcRecord; WriteLog:boolean);
  begin
  if UserList.isType[UserName]<>rtc_Record then
    begin
    // User not in our records
    if WriteLog then xLog(username+' ['+Sender.PeerAddr+']: INVALID LOGIN (User not Registered)');
    raise Exception.Create('User not registered. Access Denied.');
    end
  else if UserList.asRecord[username].asText['pwd']<>password then
    begin
    if WriteLog then xLog(username+' ['+Sender.PeerAddr+']: INVALID LOGIN (Wrong Password)');
    // User tried to log in with wrong password
    raise Exception.Create('Username already taken, password does NOT match.');
    end;
  end;

procedure TRtcPortalGateUserAccess.LogoutUser(Sender: TRtcConnection; const UserName, Password: String; WriteLog:boolean);
  begin
  if UserList.isType[UserName]<>rtc_Record then
    begin
    // User not in our records
    if WriteLog then xLog(username+' ['+Sender.PeerAddr+']: INVALID LOGOUT (User not Registered)');
    raise Exception.Create('User not registered. Access denied.');
    end
  else if UserList.asRecord[username].asText['pwd']<>password then
    begin
    if WriteLog then xLog(username+' ['+Sender.PeerAddr+']: INVALID LOGOUT (Wrong Password)');
    // User tried to log out with wrong password
    raise Exception.Create('Username already taken, password does NOT match.');
    end;
  end;

procedure TRtcPortalGateUserAccess.UserAccess(const UserName: String; Reason:TRtcPUserAccessReason);
  begin
  if UserList.isType[username]<>rtc_Record then
    raise Exception.Create('User "'+username+'" does not exist.');
  end;

function TRtcPortalGateUserAccess.GetUserDataCopy(const UserName: String):TRtcRecord;
  begin
  if UserList.isType[username]=rtc_Record then
    Result:=TRtcRecord(UserList.asRecord[username].copyOf)
  else
    Result:=nil;
  end;

procedure TRtcPortalGateUserAccess.SetUserData(const UserName: String; ReplaceWith: TRtcRecord);
  begin
  UserList.isNull[UserName]:=True;
  UserList.asObject[UserName]:=ReplaceWith;
  end;

end.
