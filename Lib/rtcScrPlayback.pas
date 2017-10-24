{ Copyright 2004-2017 (c) RealThinClient.com (http://www.realthinclient.com) }

unit rtcScrPlayback;

interface

{$INCLUDE rtcPortalDefs.inc}
{$INCLUDE rtcDefs.inc}

uses
  Windows,
  Classes,
  SysUtils,
  Graphics,
  Forms,

  rtcSystem,

  rtcInfo,
  rtcZLib,

  rtcCompress;

type
  TRtcScreenDecoder = class
  private
    FBytesPerPixel: byte;
    TempBuff: RtcByteArray;

    FScreenWidth, FScreenHeight, FScreenBPP,

      FBPPWidth, FBlockSize: integer;

    FImage: TBitmap;

    function CreateBitmap: TBitmap;

  protected
    procedure PrepareStorage;
    procedure ReleaseStorage;

    procedure SetScreenInfo(const Info: TRtcRecord);
    procedure SetPalette(const s: RtcByteArray);

    procedure DecompressBlock(const Offset: longint; const s: RtcByteArray);
    procedure DecompressBlock2(const Offset: longint; const s: RtcByteArray);
    procedure DecompressBlock3(const Offset: longint; const s: RtcByteArray);

  public
    constructor Create;
    destructor Destroy; override;

    function SetScreenData(const Data: TRtcRecord): boolean;

    property Image: TBitmap read FImage;
  end;

  TRtcScreenPlayback = class
  private
    ScrOut: TRtcScreenDecoder;
    FCursorVisible: boolean;
    FCursorHotX: integer;
    FCursorHotY: integer;
    FCursorX: integer;
    FCursorY: integer;
    FCursorShape: integer;
    FCursorStd: boolean;
    FCursorImage: TBitmap;
    FCursorMask: TBitmap;
    FCursorOldY: integer;
    FCursorOldX: integer;
    FCursorUser: String;
    FLoginUserName: String;

    function GetScreen: TBitmap;

  public
    constructor Create; virtual;
    destructor Destroy; override;

    function PaintScreen(const s: RtcString): boolean;
    function PaintCursor(const s: RtcString): boolean;

    property Image: TBitmap read GetScreen;

    property LoginUserName: String read FLoginUserName write FLoginUserName;
    property CursorVisible: boolean read FCursorVisible;
    property CursorOldX: integer read FCursorOldX;
    property CursorOldY: integer read FCursorOldY;
    property CursorX: integer read FCursorX;
    property CursorY: integer read FCursorY;
    property CursorHotX: integer read FCursorHotX;
    property CursorHotY: integer read FCursorHotY;
    property CursorImage: TBitmap read FCursorImage;
    property CursorMask: TBitmap read FCursorMask;
    property CursorShape: integer read FCursorShape;
    property CursorStd: boolean read FCursorStd;
    property CursorUser: String read FCursorUser;
  end;

implementation

{ Helper Functions }

function BitmapDataPtr(const Image: TBitmap): pointer;
begin
  With Image do
  begin
    if Height < 2 then
      Result := ScanLine[0]
    else if Cardinal(ScanLine[0]) < Cardinal(ScanLine[1]) then
      Result := ScanLine[0]
    Else
      Result := ScanLine[Height - 1];
  End;
end;

function BitmapDataPtr2(const Image: TBitmap; Offset: longint): pointer;
begin
  With Image do
    Result := pointer(longint(ScanLine[0]) + Offset);
end;

{ - TRtcScreenDecoder - }

constructor TRtcScreenDecoder.Create;
begin
  inherited;
  FImage := nil;
  SetLength(TempBuff, 0);
end;

destructor TRtcScreenDecoder.Destroy;
begin
  ReleaseStorage;
  inherited;
end;

procedure TRtcScreenDecoder.SetScreenInfo(const Info: TRtcRecord);
begin
  FScreenWidth := Info.asInteger['Width'];
  FScreenHeight := Info.asInteger['Height'];
  FScreenBPP := Info.asInteger['Bits'];
  FBytesPerPixel := Info.asInteger['Bytes'];

  if FBytesPerPixel = 0 then
    FBPPWidth := FScreenWidth div 2
  else
    FBPPWidth := FBytesPerPixel * FScreenWidth;

  FBlockSize := FBPPWidth * FScreenHeight;

  PrepareStorage;
end;

procedure TRtcScreenDecoder.PrepareStorage;
begin
  ReleaseStorage;

  FImage := CreateBitmap;
  SetLength(TempBuff, 8192 * 4 * 2);
end;

procedure TRtcScreenDecoder.ReleaseStorage;
begin
  if assigned(FImage) then
  begin
    SetLength(TempBuff, 0);
    FImage.Free;
    FImage := nil;
  end;
end;

function TRtcScreenDecoder.CreateBitmap: TBitmap;
begin
  Result := TBitmap.Create;
  With Result do
  Begin
    case FBytesPerPixel of
      0:
        PixelFormat := pf4bit;
      1:
        PixelFormat := pf8bit;
      2:
        PixelFormat := pf16bit;
      3:
        PixelFormat := pf24bit;
      4:
        PixelFormat := pf32bit;
    End;
    Width := FScreenWidth;
    Height := FScreenHeight;
  End;
end;

procedure TRtcScreenDecoder.SetPalette(const s: RtcByteArray);
var
  lpPal: PLogPalette;
  myPal: HPALETTE;
begin
  if not assigned(FImage) then
    Exit;
  if length(s) = 0 then
    Exit;

  lpPal := @s[0];
  myPal := CreatePalette(lpPal^);

  with FImage do
  begin
    Canvas.Lock;
    try
      Palette := myPal;
    finally
      Canvas.Unlock;
    end;
  end;
end;

function TRtcScreenDecoder.SetScreenData(const Data: TRtcRecord): boolean;
var
  a: integer;
  Scr, Atr: TRtcArray;
begin
  Result := False;
  if assigned(Data) then
  begin
    if Data.isType['res'] = rtc_Record then
    begin
      SetScreenInfo(Data.asRecord['res']);
      Result := True;
    end;

    if Data.isType['pal'] = rtc_String then
    begin
      SetPalette(RtcStringToBytes(Data.asString['pal']));
      Result := True;
    end;

    if not assigned(FImage) then
      Exit;

    if Data.isType['di'] = rtc_Array then
    begin
      Scr := Data.asArray['di'];
      Atr := Data.asArray['at'];
      if Scr.Count > 0 then
      begin
        Result := True;
        for a := 0 to Scr.Count - 1 do
          DecompressBlock3(Atr.asInteger[a], RtcStringToBytes(Scr.asString[a]));
      end;
    end
    else if Data.isType['pu'] = rtc_Array then
    begin
      Scr := Data.asArray['pu'];
      Atr := Data.asArray['at'];
      if Scr.Count > 0 then
      begin
        Result := True;
        for a := 0 to Scr.Count - 1 do
          DecompressBlock3(Atr.asInteger[a], RtcStringToBytes(Scr.asString[a]));
      end;
    end
    else if Data.isType['diff'] = rtc_Array then
    begin
      Scr := Data.asArray['diff'];
      Atr := Data.asArray['at'];
      if Scr.Count > 0 then
      begin
        Result := True;
        for a := 0 to Scr.Count - 1 do
          DecompressBlock2(Atr.asInteger[a], RtcStringToBytes(Scr.asString[a]));
      end;
    end
    else if Data.isType['put'] = rtc_Array then
    begin
      Scr := Data.asArray['put'];
      Atr := Data.asArray['at'];
      if Scr.Count > 0 then
      begin
        Result := True;
        for a := 0 to Scr.Count - 1 do
          DecompressBlock2(Atr.asInteger[a], RtcStringToBytes(Scr.asString[a]));
      end;
    end
    else if Data.isType['scr'] = rtc_Array then
    begin
      Scr := Data.asArray['scr'];
      if Scr.Count > 0 then
      begin
        Result := True;
        for a := 0 to Scr.Count - 1 do
          if Scr.isType[a] = rtc_Record then
            with Scr.asRecord[a] do
              if isType['img'] = rtc_String then
                DecompressBlock(asInteger['at'],
                  RtcStringToBytes(asString['img']))
              else if isType['zip'] = rtc_String then
                DecompressBlock(asInteger['at'],
                  ZDecompress_Ex(RtcStringToBytes(asString['zip'])));
      end;
    end;
  end;
end;

procedure TRtcScreenDecoder.DecompressBlock(const Offset: longint;
  const s: RtcByteArray);
begin
  if length(s) > 0 then
    if not DWordDecompress(Addr(s[0]), BitmapDataPtr(FImage), Offset, length(s),
      FBlockSize - Offset) then
      raise Exception.Create('Error decompressing image');
end;

procedure TRtcScreenDecoder.DecompressBlock2(const Offset: longint;
  const s: RtcByteArray);
begin
  if length(s) > 0 then
    if not DWordDecompress(Addr(s[0]), BitmapDataPtr2(FImage, Offset), 0,
      length(s), FBlockSize - Offset) then
      raise Exception.Create('Error decompressing image');
end;

procedure TRtcScreenDecoder.DecompressBlock3(const Offset: longint;
  const s: RtcByteArray);
begin
  if length(s) > 0 then
    if not DWordDecompress_New(Addr(s[0]), BitmapDataPtr2(FImage, Offset),
      Addr(TempBuff[0]), 0, length(s), FBlockSize - Offset) then
      raise Exception.Create('Error decompressing image');
end;

{ - TRtcScreenPlayback - }

constructor TRtcScreenPlayback.Create;
begin
  inherited;
  ScrOut := TRtcScreenDecoder.Create;
  FCursorVisible := False;
  FLoginUserName := '';
end;

destructor TRtcScreenPlayback.Destroy;
begin
  if assigned(FCursorImage) then
  begin
    FCursorImage.Free;
    FCursorImage := nil;
  end;
  if assigned(FCursorMask) then
  begin
    FCursorMask.Free;
    FCursorMask := nil;
  end;
  ScrOut.Free;
  inherited;
end;

function TRtcScreenPlayback.PaintScreen(const s: RtcString): boolean;
var
  rec: TRtcRecord;
begin
  if s = '' then
  begin
    Result := False;
    Exit;
  end;
  rec := TRtcRecord.FromCode(s);
  try
    Result := ScrOut.SetScreenData(rec);
  finally
    rec.Free;
  end;
end;

function TRtcScreenPlayback.GetScreen: TBitmap;
begin
  Result := ScrOut.Image;
end;

function TRtcScreenPlayback.PaintCursor(const s: RtcString): boolean;
var
  rec: TRtcRecord;
  icinfo: TIconInfo;
  hc: HICON;
begin
  Result := False;
  if s = '' then
    Exit;

  rec := TRtcRecord.FromCode(s);
  try
    if (rec.isType['X'] <> rtc_Null) or (rec.isType['Y'] <> rtc_Null) then
    begin
      if FCursorVisible then
      begin
        FCursorOldX := FCursorX;
        FCursorOldY := FCursorY;
      end
      else
      begin
        FCursorOldX := rec.asInteger['X'];
        FCursorOldY := rec.asInteger['Y'];
      end;
      FCursorX := rec.asInteger['X'];
      FCursorY := rec.asInteger['Y'];
      if FCursorUser <> rec.asText['U'] then
        Result := True // changing user
      else
        Result := (FCursorX <> FCursorOldX) or (FCursorY <> FCursorOldY);
      FCursorUser := rec.asText['U'];
    end;
    if (rec.isType['V'] <> rtc_Null) and (rec.asBoolean['V'] <> FCursorVisible)
    then
    begin
      Result := True;
      FCursorVisible := rec.asBoolean['V'];
    end;
    if rec.isType['C'] <> rtc_Null then
    begin
      if not FCursorStd or (FCursorShape <> -rec.asInteger['C']) then
      begin
        Result := True;
        FCursorShape := -rec.asInteger['C'];
        FCursorStd := True;

        hc := Screen.Cursors[FCursorShape];
        if GetIconInfo(hc, icinfo) then
        begin
          FCursorHotX := icinfo.xHotspot;
          FCursorHotY := icinfo.yHotspot;

          if assigned(FCursorImage) then
          begin
            FCursorImage.Free;
            FCursorImage := nil;
          end;
          if assigned(FCursorMask) then
          begin
            FCursorMask.Free;
            FCursorMask := nil;
          end;

          if icinfo.hbmColor <> INVALID_HANDLE_VALUE then
          begin
            FCursorImage := TBitmap.Create;
            FCursorImage.Handle := icinfo.hbmColor;
          end;

          if icinfo.hbmMask <> INVALID_HANDLE_VALUE then
          begin
            FCursorMask := TBitmap.Create;
            FCursorMask.Handle := icinfo.hbmMask;
            FCursorMask.PixelFormat := pf4bit;
          end;
        end;
      end;
    end
    else if rec.isType['HX'] <> rtc_Null then
    begin
      Result := True;
      FCursorShape := 0;
      FCursorStd := False;

      FCursorHotX := rec.asInteger['HX'];
      FCursorHotY := rec.asInteger['HY'];

      if assigned(FCursorImage) then
      begin
        FCursorImage.Free;
        FCursorImage := nil;
      end;
      if assigned(FCursorMask) then
      begin
        FCursorMask.Free;
        FCursorMask := nil;
      end;

      if (rec.isType['I'] = rtc_ByteStream) then
      begin
        FCursorImage := TBitmap.Create;
        FCursorImage.LoadFromStream(rec.asByteStream['I']);
      end;

      if (rec.isType['M'] = rtc_ByteStream) then
      begin
        FCursorMask := TBitmap.Create;
        FCursorMask.LoadFromStream(rec.asByteStream['M']);
      end;
    end;
  finally
    rec.Free;
  end;
end;

end.
