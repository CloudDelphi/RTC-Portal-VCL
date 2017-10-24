{ Copyright 2004-2017 (c) RealThinClient.com (http://www.realthinclient.com) }

unit rtcpFileTransUI;

interface

{$INCLUDE rtcDefs.inc}

uses
  Windows, Classes, SysUtils,
{$IFNDEF IDE_1}
  Variants,
{$ELSE}
  FileCtrl,
{$ENDIF}

  rtcSystem,
  rtcLog,
  rtcInfo,

  rtcpFileTrans;

type
  TRtcPFileTransferUI = class;

  TRtcPFileTransUIEvent = procedure(Sender: TRtcPFileTransferUI) of object;

  TRtcPFileTransferUI = class(TRtcAbsPFileTransferUI)
  private
    FSendFolders: TRtcRecord;
    FSendFileName: String;
    FSendFromFolder: String;
    FSendStart: DWORD;
    FSendFirst: boolean;
    FSendCompleted, FSendPrepared, FSendSize, FSendNow, FSendMax: int64;
    FSendFilesCnt: integer;

    FRecvFolders: TRtcRecord;
    FRecvFileName: String;
    FRecvToFolder: String;
    FRecvStart: DWORD;
    FRecvFirst: boolean;
    FRecvCompleted, FRecvSize, FRecvNow, FRecvMax: int64;
    FRecvFilesCnt: integer;

    FUserCnt: integer;

    FData: TRtcFunctionInfo;

    FOnInit: TRtcPFileTransUIEvent;
    FOnOpen: TRtcPFileTransUIEvent;
    FOnClose: TRtcPFileTransUIEvent;

    FOnError: TRtcPFileTransUIEvent;
    FOnLogOut: TRtcPFileTransUIEvent;

    FOnReadStart: TRtcPFileTransUIEvent;
    FOnRead: TRtcPFileTransUIEvent;
    FOnReadUpdate: TRtcPFileTransUIEvent;
    FOnReadStop: TRtcPFileTransUIEvent;
    FOnReadCancel: TRtcPFileTransUIEvent;

    FOnWriteStart: TRtcPFileTransUIEvent;
    FOnWrite: TRtcPFileTransUIEvent;
    FOnWriteStop: TRtcPFileTransUIEvent;
    FOnWriteCancel: TRtcPFileTransUIEvent;

    FOnCallReceived: TRtcPFileTransUIEvent;
    FOnFileList: TRtcPFileTransUIEvent;

    FFolderName: String;
    FFolderData: TRtcDataSet;

    procedure InitSend;
    procedure InitRecv;

    function GetSendETA: String;
    function GetSendKBit: longint;
    function GetSendTotalTime: String;

    function GetRecvETA: String;
    function GetRecvKBit: longint;
    function GetRecvTotalTime: String;

    function GetActive: boolean;
    procedure SetActive(const Value: boolean);

  protected

    procedure xOnInit(Sender, Obj: TObject);
    procedure xOnOpen(Sender, Obj: TObject);
    procedure xOnClose(Sender, Obj: TObject);

    procedure xOnError(Sender, Obj: TObject);
    procedure xOnLogOut(Sender, Obj: TObject);

    procedure xOnReadStart(Sender, Obj: TObject);
    procedure xOnRead(Sender, Obj: TObject);
    procedure xOnReadUpdate(Sender, Obj: TObject);
    procedure xOnReadStop(Sender, Obj: TObject);
    procedure xOnReadCancel(Sender, Obj: TObject);

    procedure xOnWriteStart(Sender, Obj: TObject);
    procedure xOnWrite(Sender, Obj: TObject);
    procedure xOnWriteStop(Sender, Obj: TObject);
    procedure xOnWriteCancel(Sender, Obj: TObject);

    procedure xOnCallReceived(Sender, Obj: TObject);
    procedure xOnFileList(Sender, Obj: TObject);

  protected
    procedure Call_LogOut(Sender: TObject); override;
    procedure Call_Error(Sender: TObject); override;

    procedure Call_Init(Sender: TObject); override;
    procedure Call_Open(Sender: TObject); override;
    procedure Call_Close(Sender: TObject); override;

    procedure Call_ReadStart(Sender: TObject; const fname, fromfolder: String;
      size: int64); override;
    procedure Call_Read(Sender: TObject; const fname, fromfolder: String;
      size: int64); override;
    procedure Call_ReadUpdate(Sender: TObject); override;
    procedure Call_ReadStop(Sender: TObject; const fname, fromfolder: String;
      size: int64); override;
    procedure Call_ReadCancel(Sender: TObject; const fname, fromfolder: String;
      size: int64); override;

    procedure Call_WriteStart(Sender: TObject; const fname, tofolder: String;
      size: int64); override;
    procedure Call_Write(Sender: TObject; const fname, tofolder: String;
      size: int64); override;
    procedure Call_WriteStop(Sender: TObject; const fname, tofolder: String;
      size: int64); override;
    procedure Call_WriteCancel(Sender: TObject; const fname, tofolder: String;
      size: int64); override;

    procedure Call_CallReceived(Sender: TObject;
      const Data: TRtcFunctionInfo); override;
    procedure Call_FileList(Sender: TObject; const Folder: String;
      const Data: TRtcDataSet); override;

  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    { Data received with the "OnCallReceived" event.
      This property is set ONLY for the "OnCallReceived" event. }
    property Params: TRtcFunctionInfo read FData;

    { Name of the Folder for which data was received with the "OnFileList" event.
      This property is set ONLY for the "OnFileList" event. }
    property FolderName: String read FFolderName;

    { Folder Data received with the "OnFileList" event.
      This property is set ONLY for the "OnFileList" event.

      Field descriptions when receiving drive info (FolderName='') ...
      asText['drive'] = Drive letter + ':'
      asLargeInt['size'] = Capacity
      asLargeInt['free'] = Free Space
      asInteger['type'] = Media Type (TRtcPFileMediaType)
      asText['label'] = Volume Label

      Field descriptions when receiving file list (FolderName<>'') ...
      asText['file'] = File name (only file/folder name, no path included)
      asDateTime['age'] = File Date (last modified)
      asInteger['attr'] = File Attributes (faReadOnly .. faSymLink)
      asLargeInt['size'] = File Size }
    property FolderData: TRtcDataSet read FFolderData;

  published

    property Active: boolean read GetActive write SetActive default False;

    { Currently sending File/Folder name }
    property Send_FileName: String read FSendFileName;
    { Folder from where the file/folder will be read }
    property Send_FromFolder: String read FSendFromFolder;
    { Current file/folder bytes sent out }
    property Send_FileOut: int64 read FSendNow;
    { Current file/folder size in bytes }
    property Send_FileSize: int64 read FSendMax;

    { Number of files/folders left for sending, including current, in this round }
    property Send_FileCount: integer read FSendFilesCnt;
    { Is this the first file/folder we are sending in this round?
      If yes, our sending timer and all total byte counts have been reset. }
    property Send_FirstTime: boolean read FSendFirst;
    { Time (GetTickCount) when we have started sending files/folders - this round }
    property Send_StartTime: DWORD read FSendStart;
    { Number of Bytes really sent (confirmed by the Gateway) - this round }
    property Send_BytesComplete: int64 read FSendCompleted;
    { Number of Bytes prepared for sending, now on their way to the Gateway - this round }
    property Send_BytesPrepared: int64 read FSendPrepared;
    { Number of Bytes we need to send in this round }
    property Send_BytesTotal: int64 read FSendSize;
    { Average sending speed in KBit (this round) }
    property Send_KBit: longint read GetSendKBit;
    { Estimated Time or Arrival (ETA) for all files sending in this round }
    property Send_ETA: String read GetSendETA;
    { Total time elapsed between NOW and Send_StartTime. }
    property Send_TotalTime: String read GetSendTotalTime;

    { Currently receiving File/Folder name }
    property Recv_FileName: String read FRecvFileName;
    { Folder where the file/folder will be written (INBOX folder if empty) }
    property Recv_ToFolder: String read FRecvToFolder;
    { Current file/folder bytes received }
    property Recv_FileIn: int64 read FRecvNow;
    { Current file/folder size in bytes }
    property Recv_FileSize: int64 read FRecvMax;

    { Number of files/folders left for receiving, including the current, in this round }
    property Recv_FileCount: integer read FRecvFilesCnt;
    { is this the first file/folder we are receiving in this round?
      If yes, our receiving timer and all total byte counts have been reset. }
    property Recv_FirstTime: boolean read FRecvFirst;
    { Time (GetTickCount) when we have started receiving files/folders - this round }
    property Recv_StartTime: DWORD read FRecvStart;
    { Number of Bytes received in this round }
    property Recv_BytesComplete: int64 read FRecvCompleted;
    { Number of Bytes we need to receive in this round }
    property Recv_BytesTotal: int64 read FRecvSize;
    { Average receiving speed in KBit (this round) }
    property Recv_KBit: longint read GetRecvKBit;
    { Estimated Time or Arrival (ETA) for all files receiving in this round }
    property Recv_ETA: String read GetRecvETA;
    { Total time elapsed between NOW and Recv_StartTime. }
    property Recv_TotalTime: String read GetRecvTotalTime;

    { File Transfer window needed. If not open, open it now.
      OnOpen event will follow if window was not open. }
    property OnInit: TRtcPFileTransUIEvent read FOnInit write FOnInit;
    { File Transfer open for business }
    property OnOpen: TRtcPFileTransUIEvent read FOnOpen write FOnOpen;
    { File Transfer closed by user }
    property OnClose: TRtcPFileTransUIEvent read FOnClose write FOnClose;

    { Error received, File Transfer closed }
    property OnError: TRtcPFileTransUIEvent read FOnError write FOnError;
    { User logged out, File Transfer closed }
    property OnLogOut: TRtcPFileTransUIEvent read FOnLogOut write FOnLogOut;

    { We have started sending a new file.
      Obj = This TRtcPFileTransferUI component
      TRtcPFileTransferUI(Obj).Send_... = Sending files info }
    property OnSendStart: TRtcPFileTransUIEvent read FOnReadStart
      write FOnReadStart;
    { We are sending a file.
      Obj = This TRtcPFileTransferUI component
      TRtcPFileTransferUI(Obj).Send_... = Sending files info }
    property OnSend: TRtcPFileTransUIEvent read FOnRead write FOnRead;
    { We are sending a file, need to update send info.
      Obj = This TRtcPFileTransferUI component
      TRtcPFileTransferUI(Obj).Send_... = Sending files info }
    property OnSendUpdate: TRtcPFileTransUIEvent read FOnReadUpdate
      write FOnReadUpdate;
    { We have stopped sending a file (file sent).
      Obj = This TRtcPFileTransferUI component
      TRtcPFileTransferUI(Obj).Send_... = Sending files info }
    property OnSendStop: TRtcPFileTransUIEvent read FOnReadStop
      write FOnReadStop;
    { File sending was cancelled by user.
      Obj = This TRtcPFileTransferUI component
      TRtcPFileTransferUI(Obj).Send_... = Sending files info }
    property OnSendCancel: TRtcPFileTransUIEvent read FOnReadCancel
      write FOnReadCancel;

    { We have started receiving a new file.
      Obj = This TRtcPFileTransferUI component
      TRtcPFileTransferUI(Obj).Recv_... = Receiving files info }
    property OnRecvStart: TRtcPFileTransUIEvent read FOnWriteStart
      write FOnWriteStart;
    { We are receiving a file.
      Obj = This TRtcPFileTransferUI component
      TRtcPFileTransferUI(Obj).Recv_... = Receiving files info }
    property OnRecv: TRtcPFileTransUIEvent read FOnWrite write FOnWrite;
    { We have stopped receiving a file (file received).
      Obj = This TRtcPFileTransferUI component
      TRtcPFileTransferUI(Obj).Recv_... = Receiving files info }
    property OnRecvStop: TRtcPFileTransUIEvent read FOnWriteStop
      write FOnWriteStop;
    { File receiving was cancelled by user.
      Obj = This TRtcPFileTransferUI component
      TRtcPFileTransferUI(Obj).Recv_... = Receiving files info }
    property OnRecvCancel: TRtcPFileTransUIEvent read FOnWriteCancel
      write FOnWriteCancel;

    { Call received from "user".
      Obj = This TRtcPFileTransferUI component
      TRtcPFileTransferUI(Obj).Params = Data Received (RtcFunctionInfo object) }
    property OnCallReceived: TRtcPFileTransUIEvent read FOnCallReceived
      write FOnCallReceived;

    { File List received from "user".
      Obj = This TRtcPFileTransferUI component
      TRtcPFileTransferUI(Obj).Folder... = Folder Data Received }
    property OnFileList: TRtcPFileTransUIEvent read FOnFileList
      write FOnFileList;
  end;

implementation

{ TRtcPFileTransferUI }

constructor TRtcPFileTransferUI.Create(AOwner: TComponent);
begin
  inherited;
  FUserCnt := 0;
  FSendFolders := TRtcRecord.Create;
  FRecvFolders := TRtcRecord.Create;
  InitSend;
  InitRecv;
end;

destructor TRtcPFileTransferUI.Destroy;
begin
  FSendFolders.Free;
  FRecvFolders.Free;
  inherited;
end;

procedure TRtcPFileTransferUI.InitSend;
begin
  FSendFilesCnt := 0;
  FSendFolders.Clear;
  FSendFileName := '';
  FSendFromFolder := '';

  FSendStart := 0;
  FSendFirst := False;
  FSendCompleted := 0;
  FSendPrepared := 0;
  FSendSize := 0;
  FSendNow := 0;
  FSendMax := 0;
end;

procedure TRtcPFileTransferUI.InitRecv;
begin
  FRecvFilesCnt := 0;
  FRecvFolders.Clear;
  FRecvFileName := '';

  FRecvStart := 0;
  FRecvFirst := False;
  FRecvCompleted := 0;
  FRecvSize := 0;
  FRecvNow := 0;
  FRecvMax := 0;
end;

procedure TRtcPFileTransferUI.Call_Init(Sender: TObject);
begin
  InitSend;
  InitRecv;
  if assigned(FOnInit) then
    Module.CallEvent(Sender, xOnInit, self);
end;

procedure TRtcPFileTransferUI.Call_Open(Sender: TObject);
begin
  Inc(FUserCnt);
  if FUserCnt = 1 then
    if assigned(FOnOpen) then
      Module.CallEvent(Sender, xOnOpen, self);
end;

procedure TRtcPFileTransferUI.Call_Close(Sender: TObject);
begin
  if FUserCnt > 0 then
  begin
    Dec(FUserCnt);
    if FUserCnt = 0 then
    begin
      InitSend;
      InitRecv;
      if assigned(FOnClose) then
        Module.CallEvent(Sender, xOnClose, self);
    end;
  end;
end;

procedure TRtcPFileTransferUI.Call_Error(Sender: TObject);
begin
  FUserCnt := 0;
  InitSend;
  InitRecv;
  if assigned(FOnError) then
    Module.CallEvent(Sender, xOnError, self);
end;

procedure TRtcPFileTransferUI.Call_LogOut(Sender: TObject);
begin
  FUserCnt := 0;
  InitSend;
  InitRecv;
  if assigned(FOnLogOut) then
    Module.CallEvent(Sender, xOnLogOut, self);
end;

procedure TRtcPFileTransferUI.Call_ReadStart(Sender: TObject;
  const fname, fromfolder: String; size: int64);
begin
  if fname = '' then
    raise Exception.Create('Folder undefined');

  if FSendStart = 0 then
  begin
    FSendStart := GetTickCount;
    FSendFirst := True;
  end
  else
    FSendFirst := False;

  Inc(FSendFilesCnt);

  if FSendFolders.isNull[fname] then
    FSendFolders.NewRecord(fname);

  FSendFolders.asRecord[fname].asInteger['cnt'] := FSendFolders.asRecord[fname]
    .asInteger['cnt'] + 1;
  FSendFolders.asRecord[fname].asLargeInt['size'] := FSendFolders.asRecord
    [fname].asLargeInt['size'] + size;

  FSendSize := FSendSize + size;

  FSendNow := 0;
  FSendMax := size;

  FSendFileName := fname;
  FSendFromFolder := fromfolder;

  if assigned(FOnReadStart) then
    Module.CallEvent(Sender, xOnReadStart, self);

  FSendFirst := False;
end;

procedure TRtcPFileTransferUI.Call_Read(Sender: TObject;
  const fname, fromfolder: String; size: int64);
begin
  if fname = '' then
    raise Exception.Create('Folder undefined');

  FSendPrepared := FSendPrepared + size;
  FSendFileName := fname;
  FSendFromFolder := fromfolder;

  with FSendFolders.asRecord[fname] do
  begin
    asLargeInt['sent'] := asLargeInt['sent'] + size;
    FSendNow := asLargeInt['sent'];
    FSendMax := asLargeInt['size'];
  end;

  if assigned(FOnRead) then
    Module.CallEvent(Sender, xOnRead, self);
end;

procedure TRtcPFileTransferUI.Call_ReadStop(Sender: TObject;
  const fname, fromfolder: String; size: int64);
begin
  if fname = '' then
    raise Exception.Create('Folder undefined');

  Dec(FSendFilesCnt);

  FSendPrepared := FSendPrepared + size;

  FSendFileName := fname;
  FSendFromFolder := fromfolder;

  FSendFolders.asRecord[fname].asInteger['cnt'] := FSendFolders.asRecord[fname]
    .asInteger['cnt'] - 1;

  if FSendFolders.asRecord[fname].asInteger['cnt'] = 0 then
  begin
    with FSendFolders.asRecord[fname] do
    begin
      asLargeInt['sent'] := asLargeInt['sent'] + size;
      FSendNow := asLargeInt['sent'];
      FSendMax := asLargeInt['sent'];

      FSendSize := FSendSize + asLargeInt['sent'] - asLargeInt['size'];
    end;
    FSendFolders.isNull[fname] := True;
  end;

  if assigned(FOnReadStop) then
    Module.CallEvent(Sender, xOnReadStop, self);
end;

procedure TRtcPFileTransferUI.Call_ReadCancel(Sender: TObject;
  const fname, fromfolder: String; size: int64);
begin
  if fname = '' then
    raise Exception.Create('Folder undefined');

  Dec(FSendFilesCnt);

  FSendPrepared := FSendPrepared + size;

  FSendFileName := fname;
  FSendFromFolder := fromfolder;

  FSendFolders.asRecord[fname].asInteger['cnt'] := FSendFolders.asRecord[fname]
    .asInteger['cnt'] - 1;

  if FSendFolders.asRecord[fname].asInteger['cnt'] = 0 then
  begin
    with FSendFolders.asRecord[fname] do
    begin
      asLargeInt['sent'] := asLargeInt['sent'] + size;
      FSendNow := asLargeInt['sent'];
      FSendMax := asLargeInt['sent'];

      FSendSize := FSendSize + asLargeInt['sent'] - asLargeInt['size'];
    end;
    FSendFolders.isNull[fname] := True;
  end;

  if assigned(FOnReadCancel) then
    Module.CallEvent(Sender, xOnReadCancel, self);
end;

function SecondsToStr(LeftTime: Cardinal): String;
var
  i: Cardinal;
begin
  if LeftTime > 3600 then // Hours
  begin
    i := trunc(LeftTime / 3600);
    LeftTime := LeftTime - i * 3600;
    if i < 10 then
      Result := '0' + IntToStr(i) + ':'
    else
      Result := IntToStr(i) + ':';
  end
  else
    Result := '00:';

  if LeftTime > 60 then // Minutes
  begin
    i := trunc(LeftTime / 60);
    LeftTime := LeftTime - i * 60;
    if i < 10 then
      Result := Result + '0' + IntToStr(i) + ':'
    else
      Result := Result + IntToStr(i) + ':';
  end
  else
    Result := Result + '00:';

  i := LeftTime;
  if i < 10 then // Seconds
    Result := Result + '0' + IntToStr(i)
  else
    Result := Result + IntToStr(i);
end;

function TRtcPFileTransferUI.GetSendETA: String;
var
  NowTime: Cardinal;
  XSpeed: double;
  LeftTime: Cardinal;
begin
  Result := '';
  if FSendSize > 0 then
  begin
    NowTime := GetTickCount;
    if NowTime > FSendStart then
    begin
      XSpeed := FSendCompleted / (NowTime - FSendStart) * 1000;
      if XSpeed > 0 then
      begin
        LeftTime := round((FSendSize - FSendCompleted) / XSpeed);
        Result := SecondsToStr(LeftTime);
      end;
    end;
  end;
end;

function TRtcPFileTransferUI.GetSendTotalTime: String;
var
  NowTime: Cardinal;
  LeftTime: Cardinal;
begin
  if FSendSize > 0 then
  begin
    NowTime := GetTickCount;
    if NowTime > FSendStart then
      LeftTime := round((NowTime - FSendStart) / 1000)
    else
      LeftTime := 0;
    Result := SecondsToStr(LeftTime);
  end
  else
    Result := SecondsToStr(0);
end;

function TRtcPFileTransferUI.GetSendKBit: longint;
var
  NowTime: Cardinal;
begin
  Result := 0;
  if FSendSize > 0 then
  begin
    NowTime := GetTickCount;
    if NowTime > FSendStart then
      Result := round(FSendCompleted / (NowTime - FSendStart) * 8);
  end;
end;

procedure TRtcPFileTransferUI.Call_ReadUpdate(Sender: TObject);
begin
  FSendCompleted := FSendPrepared;

  if assigned(FOnReadUpdate) then
    Module.CallEvent(Sender, xOnReadUpdate, self);

  if FSendFilesCnt = 0 then
    InitSend;
end;

procedure TRtcPFileTransferUI.Call_WriteStart(Sender: TObject;
  const fname, tofolder: String; size: int64);
begin
  if fname = '' then
    raise Exception.Create('Folder undefined');

  if FRecvStart = 0 then
  begin
    FRecvFirst := True;
    FRecvStart := GetTickCount;
  end
  else
    FRecvFirst := False;

  Inc(FRecvFilesCnt);

  if FRecvFolders.isNull[fname] then
    FRecvFolders.NewRecord(fname);

  FRecvFolders.asRecord[fname].asInteger['cnt'] := FRecvFolders.asRecord[fname]
    .asInteger['cnt'] + 1;
  FRecvFolders.asRecord[fname].asLargeInt['size'] := FRecvFolders.asRecord
    [fname].asLargeInt['size'] + size;

  FRecvSize := FRecvSize + size;

  FRecvFileName := fname;
  FRecvToFolder := tofolder;

  FRecvNow := 0;
  FRecvMax := size;

  if assigned(FOnWriteStart) then
    Module.CallEvent(Sender, xOnWriteStart, self);

  FRecvFirst := False;
end;

function TRtcPFileTransferUI.GetRecvETA: String;
var
  NowTime: Cardinal;
  XSpeed: double;
  LeftTime: Cardinal;
begin
  Result := '';

  NowTime := GetTickCount;
  if FRecvSize > 0 then
  begin
    if NowTime > FRecvStart then
    begin
      XSpeed := FRecvCompleted / (NowTime - FRecvStart) * 1000;
      if XSpeed > 0 then
      begin
        LeftTime := round((FRecvSize - FRecvCompleted) / XSpeed);
        Result := SecondsToStr(LeftTime);
      end;
    end;
  end;
end;

function TRtcPFileTransferUI.GetRecvTotalTime: String;
var
  NowTime: Cardinal;
  LeftTime: Cardinal;
begin
  if FRecvSize > 0 then
  begin
    NowTime := GetTickCount;
    if NowTime > FRecvStart then
      LeftTime := round((NowTime - FRecvStart) / 1000)
    else
      LeftTime := 0;
    Result := SecondsToStr(LeftTime);
  end
  else
    Result := SecondsToStr(0);
end;

function TRtcPFileTransferUI.GetRecvKBit: longint;
var
  NowTime: DWORD;
begin
  Result := 0;
  if FRecvSize > 0 then
  begin
    NowTime := GetTickCount;
    if NowTime > FRecvStart then
      Result := round(FRecvCompleted / (NowTime - FRecvStart) * 8);
  end;
end;

procedure TRtcPFileTransferUI.Call_Write(Sender: TObject;
  const fname, tofolder: String; size: int64);
begin
  if fname = '' then
    raise Exception.Create('Folder undefined');

  if FRecvFolders.isType[fname] <> rtc_Record then
    raise Exception.Create('File "' + fname + '" not initialized for upload.');

  FRecvCompleted := FRecvCompleted + size;

  FRecvFileName := fname;
  FRecvToFolder := tofolder;

  with FRecvFolders.asRecord[fname] do
  begin
    asLargeInt['sent'] := asLargeInt['sent'] + size;
    FRecvNow := asLargeInt['sent'];
    FRecvMax := asLargeInt['size'];
  end;

  if assigned(FOnWrite) then
    Module.CallEvent(Sender, xOnWrite, self);
end;

procedure TRtcPFileTransferUI.Call_WriteStop(Sender: TObject;
  const fname, tofolder: String; size: int64);
begin
  if fname = '' then
    raise Exception.Create('Folder undefined');

  if FRecvFolders.isType[fname] <> rtc_Record then
    raise Exception.Create('File "' + fname + '" not initialized for upload.');

  Dec(FRecvFilesCnt);

  FRecvCompleted := FRecvCompleted + size;

  FRecvFileName := fname;
  FRecvToFolder := tofolder;

  FRecvFolders.asRecord[fname].asInteger['cnt'] := FRecvFolders.asRecord[fname]
    .asInteger['cnt'] - 1;

  if FRecvFolders.asRecord[fname].asInteger['cnt'] = 0 then
  begin
    with FRecvFolders.asRecord[fname] do
    begin
      asLargeInt['sent'] := asLargeInt['sent'] + size;
      FRecvNow := asLargeInt['sent'];
      FRecvMax := asLargeInt['sent'];
      FRecvSize := FRecvSize + asLargeInt['sent'] - asLargeInt['size'];
    end;
    FRecvFolders.isNull[fname] := True;
  end;

  if assigned(FOnWriteStop) then
    Module.CallEvent(Sender, xOnWriteStop, self);

  if FRecvFilesCnt = 0 then
    InitRecv;
end;

procedure TRtcPFileTransferUI.Call_WriteCancel(Sender: TObject;
  const fname, tofolder: String; size: int64);
begin
  if fname = '' then
    raise Exception.Create('Folder undefined');

  if FRecvFolders.isType[fname] <> rtc_Record then
    raise Exception.Create('File "' + fname + '" not initialized for upload.');

  Dec(FRecvFilesCnt);

  FRecvCompleted := FRecvCompleted + size;

  FRecvFileName := fname;
  FRecvToFolder := tofolder;

  FRecvFolders.asRecord[fname].asInteger['cnt'] := FRecvFolders.asRecord[fname]
    .asInteger['cnt'] - 1;

  if FRecvFolders.asRecord[fname].asInteger['cnt'] = 0 then
  begin
    with FRecvFolders.asRecord[fname] do
    begin
      asLargeInt['sent'] := asLargeInt['sent'] + size;
      FRecvNow := asLargeInt['sent'];
      FRecvMax := asLargeInt['sent'];
      FRecvSize := FRecvSize + asLargeInt['sent'] - asLargeInt['size'];
    end;
    FRecvFolders.isNull[fname] := True;
  end;

  if assigned(FOnWriteCancel) then
    Module.CallEvent(Sender, xOnWriteCancel, self);

  if FRecvFilesCnt = 0 then
    InitRecv;
end;

procedure TRtcPFileTransferUI.Call_CallReceived(Sender: TObject;
  const Data: TRtcFunctionInfo);
begin
  if assigned(FOnCallReceived) then
  begin
    FData := Data;
    try
      Module.CallEvent(Sender, xOnCallReceived, self);
    finally
      FData := nil;
    end;
  end;
end;

procedure TRtcPFileTransferUI.Call_FileList(Sender: TObject;
  const Folder: String; const Data: TRtcDataSet);
begin
  if assigned(FOnFileList) then
  begin
    FFolderName := Folder;
    FFolderData := Data;
    try
      Module.CallEvent(Sender, xOnFileList, self);
    finally
      FFolderName := '';
      FFolderData := nil;
    end;
  end;
end;

procedure TRtcPFileTransferUI.xOnClose(Sender, Obj: TObject);
begin
  FOnClose(self);
end;

procedure TRtcPFileTransferUI.xOnError(Sender, Obj: TObject);
begin
  FOnError(self);
end;

procedure TRtcPFileTransferUI.xOnInit(Sender, Obj: TObject);
begin
  FOnInit(self);
end;

procedure TRtcPFileTransferUI.xOnLogOut(Sender, Obj: TObject);
begin
  FOnLogOut(self);
end;

procedure TRtcPFileTransferUI.xOnOpen(Sender, Obj: TObject);
begin
  FOnOpen(self);
end;

procedure TRtcPFileTransferUI.xOnRead(Sender, Obj: TObject);
begin
  FOnRead(self);
end;

procedure TRtcPFileTransferUI.xOnReadStart(Sender, Obj: TObject);
begin
  FOnReadStart(self);
end;

procedure TRtcPFileTransferUI.xOnReadStop(Sender, Obj: TObject);
begin
  FOnReadStop(self);
end;

procedure TRtcPFileTransferUI.xOnReadCancel(Sender, Obj: TObject);
begin
  FOnReadCancel(self);
end;

procedure TRtcPFileTransferUI.xOnReadUpdate(Sender, Obj: TObject);
begin
  FOnReadUpdate(self);
end;

procedure TRtcPFileTransferUI.xOnWrite(Sender, Obj: TObject);
begin
  FOnWrite(self);
end;

procedure TRtcPFileTransferUI.xOnWriteStart(Sender, Obj: TObject);
begin
  FOnWriteStart(self);
end;

procedure TRtcPFileTransferUI.xOnWriteStop(Sender, Obj: TObject);
begin
  FOnWriteStop(self);
end;

procedure TRtcPFileTransferUI.xOnWriteCancel(Sender, Obj: TObject);
begin
  FOnWriteCancel(self);
end;

procedure TRtcPFileTransferUI.xOnCallReceived(Sender, Obj: TObject);
begin
  FOnCallReceived(self);
end;

procedure TRtcPFileTransferUI.xOnFileList(Sender, Obj: TObject);
begin
  FOnFileList(self);
end;

function TRtcPFileTransferUI.GetActive: boolean;
begin
  Result := FUserCnt > 0;
end;

procedure TRtcPFileTransferUI.SetActive(const Value: boolean);
begin
  if Value then
    Open
  else
    Close;
end;

end.
