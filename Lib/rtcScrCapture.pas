{ Copyright 2004-2017 (c) RealThinClient.com (http://www.realthinclient.com) }

unit rtcScrCapture;

interface

{$INCLUDE rtcDefs.inc}
{$INCLUDE rtcPortalDefs.inc}

uses
  Windows, Messages, Classes,
  SysUtils, Graphics, Controls, Forms,

{$IFDEF DFMirage}
  dfmVideoDriver,
{$ENDIF}
  rtcInfo, rtcLog, rtcZLib, SyncObjs, rtcScrUtils,

{$IFDEF KMDriver}
  MouseAInf,
{$ENDIF}

  rtcCompress, rtcWinLogon, rtcSystem;

var
  RTC_CAPTUREBLT: DWORD = $40000000;

type
  { captureEverything = captures the Desktop and all Windows.
    captureDesktopOnly =  only captures the Desktop background.
    captureWindowOnly = only captures the Window specified in "RtcCaptureWindowHdl" }
  TRtcCaptureMode=(captureEverything, captureDesktopOnly, captureWindowOnly);
  TRtcMouseControlMode=(eventMouseControl, messageMouseControl);

var
  RtcCaptureMode:TRtcCaptureMode=captureEverything;
  RtcCaptureWindowHdl:HWND=0;
  
  RtcMouseControlMode:TRtcMouseControlMode=eventMouseControl;
  RtcMouseWindowHdl:HWND=0;

type
  TRtcScreenEncoder = class
  private
    CS: TCriticalSection;
    FTmpImage, FTmpLastImage: TBitmap;

    FTmpStorage: RtcByteArray;

    FOldImage, FNewImage: TBitmap;

    FImgIndex, FNewBlockSize: integer;

    FAllBlockSize, FBlockSize, FLastBlockSize: integer;

    FBlockWidth, FBlockHeight, FLastBlockHeight: integer;

    FBytesPerPixel: byte;

    FBlockCount: integer;

    FCaptureWidth, FCaptureHeight, FCaptureLeft, FCaptureTop, FScreenWidth,
      FScreenHeight, FScreenLeft, FScreenTop, FScreenBPP: integer;

    FBPPWidth, FBPPLimit, FMaxTotalSize, FMaxBlockCount: integer;

    FImages: array of TBitmap;
    FMarked: array of boolean;

    FScreenData, FInitialScreenData: TRtcValue;

    FNewScreenPalette: boolean;
    FScreenPalette: RtcString;

    FMyScreenInfoChanged: boolean;
    FScreenInfoChanged: boolean;
    FScreenGrabBroken: boolean;
    FScreenGrabFrom: integer;
    FUseCaptureMarks: boolean;
    FFullScreen: boolean;
    FFixedRegion: TRect;
    FReduce16bit: longword;
    FReduce32bit: longword;
    FCaptureMask: DWORD;
    FMultiMon: boolean;

    function CreateBitmap(index: integer): TBitmap;

  protected
    procedure PrepareStorage;
    procedure ReleaseStorage;

    procedure SetBlockIndex(index: integer);
    function CaptureBlock: boolean;

    function CompressBlock_Initial: RtcByteArray;
    function CompressBlock_Normal: RtcByteArray;
    function CompressBlock_Delta: RtcByteArray;

    procedure StoreBlock;

    function ScreenChanged: boolean;
    procedure CaptureScreenInfo;

    property BlockCount: integer read FBlockCount;

  public
    constructor Create;
    destructor Destroy; override;

    procedure Setup(BPPLimit, MaxBlockCount, MaxTotalSize: integer);

    procedure MarkForCapture(x1, y1, x2, y2: integer); overload;
    procedure MarkForCapture; overload;

    function Capture(SleepTime: integer = 0; Initial: boolean = False): boolean;

    function GetInitialScreenData: TRtcValue;
    function GetScreenData: TRtcValue;

    property CaptureMask: DWORD read FCaptureMask write FCaptureMask;
    property UseCaptureMarks: boolean read FUseCaptureMarks
      write FUseCaptureMarks;
    property FullScreen: boolean read FFullScreen write FFullScreen
      default True;
    property FixedRegion: TRect read FFixedRegion write FFixedRegion;

    property Reduce16bit: longword read FReduce16bit write FReduce16bit;
    property Reduce32bit: longword read FReduce32bit write FReduce32bit;

    property MultiMonitor: boolean read FMultiMon write FMultiMon;
  end;

  TRtcScreenCapture = class
  private
{$IFDEF DFMirage}
    vd: TVideoDriver;
    m_BackBm: TBitmap;
    m_Init: boolean;
    FMirage: boolean;
    dfm_ImgLine0: PAnsiChar;
    dfm_DstStride: integer;
    dfm_urgn: TGridUpdRegion;
    dfm_fixed: TRect;
    ScrDeltaRec: TRtcRecord;
{$ENDIF}
    ScrIn: TRtcScreenEncoder;

    FCaptureMask: DWORD;
    FBPPLimit, FMaxTotalSize, FScreen2Delay, FScreenBlockCount,
      FScreen2BlockCount: integer;

    FFullScreen: boolean;
    FFixedRegion: TRect;

    FShiftDown, FCtrlDown, FAltDown: boolean;

    FMouseX, FMouseY, FMouseHotX, FMouseHotY: integer;
    FMouseVisible: boolean;
    FMouseHandle: HICON;
    FMouseIcon: TBitmap;
    FMouseIconMask: TBitmap;
    FMouseShape: integer;

    FMouseChangedShape: boolean;
    FMouseMoved: boolean;
    FMouseLastVisible: boolean;
    FMouseInit: boolean;
    FMouseUser: String;

    FLastMouseUser: String;
    FLastMouseX, FLastMouseY: integer;

    FReduce32bit, FReduce16bit, FLowReduce32bit, FLowReduce16bit: DWORD;

    FLowReduceColors: boolean;
    FLowReduceType: integer;
    FLowReduceColorPercent: integer;

    FCaptureWidth, FCaptureHeight, FCaptureLeft, FCaptureTop, FScreenWidth,
      FScreenHeight, FScreenLeft, FScreenTop: longint;
    FMouseDriver: boolean;

    FMultiMon: boolean;

    procedure Init;
    procedure InitSize;

{$IFDEF DFMirage}
    function ScreenChanged: boolean;
    function GrabImageFullscreen: TRtcRecord;
    function GrabImageIncremental: TRtcRecord;
    function GrabImageOldScreen: TRtcRecord;
{$ENDIF}
    function GetMirageDriver: boolean;
    procedure SetMirageDriver(const Value: boolean);

    function GetLayeredWindows: boolean;
    procedure SetLayeredWindows(const Value: boolean);

    function GetBPPLimit: integer;
    procedure SetBPPLimit(const Value: integer);

    function GetMaxTotalSize: integer;
    procedure SetMaxTotalSize(const Value: integer);

    function GetFixedRegion: TRect;
    function GetFullScreen: boolean;

    procedure SetFixedRegion(const Value: TRect);
    procedure SetFullScreen(const Value: boolean);

    function GetReduce16bit: longword;
    function GetReduce32bit: longword;
    procedure SetReduce16bit(const Value: longword);
    procedure SetReduce32bit(const Value: longword);

    procedure Post_MouseDown(Button: TMouseButton);
    procedure Post_MouseUp(Button: TMouseButton);
    procedure Post_MouseMove(X, Y: integer);
    procedure Post_MouseWheel(Wheel: integer);

    procedure keybdevent(key: word; Down:boolean=True; Extended: boolean=False);

    procedure SetKeys(capslock, lWithShift, lWithCtrl, lWithAlt: boolean);
    procedure ResetKeys(capslock, lWithShift, lWithCtrl, lWithAlt: boolean);

    procedure SetMouseDriver(const Value: boolean);
    procedure SetMultiMon(const Value: boolean);
    function GetLowReduce16bit: longword;
    function GetLowReduce32bit: longword;
    procedure SetLowReduce16bit(const Value: longword);
    procedure SetLowReduce32bit(const Value: longword);

    function GetLowReduceColors: boolean;
    procedure SetLowReduceColors(const Value: boolean);

    function GetLowReduceColorPercent: integer;
    procedure SetLowReduceColorPercent(const Value: integer);
    function GetScreenBlockCount: integer;
    procedure SetScreenBlockCount(const Value: integer);
    function GetScreen2BlockCount: integer;
    procedure SetScreen2BlockCount(const Value: integer);
    function GetScreen2Delay: integer;
    procedure SetScreen2Delay(const Value: integer);
    function GetLowReduceType: integer;
    procedure SetLowReduceType(const Value: integer);

  public
    constructor Create; virtual;
    destructor Destroy; override;

    procedure Clear;
    function GrabScreen: boolean;
    procedure GrabMouse;

    function GetScreen: RtcString;
    function GetScreenDelta: RtcString;

    function GetMouse: RtcString;
    function GetMouseDelta: RtcString;

    function MirageDriverInstalled(Init: boolean = False): boolean;

    // control events
    procedure MouseDown(const user: String; X, Y: integer;
      Button: TMouseButton);
    procedure MouseUp(const user: String; X, Y: integer; Button: TMouseButton);
    procedure MouseMove(const user: String; X, Y: integer);
    procedure MouseWheel(Wheel: integer);

    procedure KeyPressW(const AText: WideString; AKey: word);
    procedure KeyPress(const AText: RtcString; AKey: word);
    procedure KeyDown(key: word; Shift: TShiftState);
    procedure KeyUp(key: word; Shift: TShiftState);

    procedure SpecialKey(const AKey: RtcString);

    procedure LWinKey(key: word);
    procedure RWinKey(key: word);

    procedure ReleaseAllKeys;

    property MirageDriver: boolean read GetMirageDriver write SetMirageDriver
      default False;
    property LayeredWindows: boolean read GetLayeredWindows
      write SetLayeredWindows default False;
    property BPPLimit: integer read GetBPPLimit write SetBPPLimit default 4;
    property MaxTotalSize: integer read GetMaxTotalSize write SetMaxTotalSize
      default 0;
    property ScreenBlockCount: integer read GetScreenBlockCount
      write SetScreenBlockCount default 1;
    property Screen2BlockCount: integer read GetScreen2BlockCount
      write SetScreen2BlockCount default 1;
    property Screen2Delay: integer read GetScreen2Delay write SetScreen2Delay
      default 0;
    property FullScreen: boolean read GetFullScreen write SetFullScreen
      default True;
    property FixedRegion: TRect read GetFixedRegion write SetFixedRegion;

    property Reduce16bit: longword read GetReduce16bit write SetReduce16bit;
    property Reduce32bit: longword read GetReduce32bit write SetReduce32bit;
    property LowReduce16bit: longword read GetLowReduce16bit
      write SetLowReduce16bit;
    property LowReduce32bit: longword read GetLowReduce32bit
      write SetLowReduce32bit;
    property LowReducedColors: boolean read GetLowReduceColors
      write SetLowReduceColors;
    property LowReduceType: integer read GetLowReduceType
      write SetLowReduceType;
    property LowReduceColorPercent: integer read GetLowReduceColorPercent
      write SetLowReduceColorPercent;

    property ScreenWidth: longint read FScreenWidth;
    property ScreenHeight: longint read FScreenHeight;
    property ScreenLeft: longint read FScreenLeft;
    property ScreenTop: longint read FScreenTop;

    property MouseDriver: boolean read FMouseDriver write SetMouseDriver
      default False;
    property MultiMonitor: boolean read FMultiMon write SetMultiMon
      default False;
  end;

function CaptureFullScreen(MultiMon: boolean;
  PixelFormat: TPixelFormat = pf8bit): TBitmap;

implementation

uses Types;
{$IFDEF KMDriver}

var
  FMouseAInit: integer = 0;
{$ENDIF}
  (*
    type
    TMyWinList=class
    cnt:integer;
    list:array[1..1000] of HWnd;
    end;

    function _EnumWindowsProc(Wnd: HWnd; const obj:TMyWinList): Bool; export; stdcall;
    begin
    if (obj.cnt<1000) and IsWindowVisible(Wnd) then
    begin
    if (GetWindowLong(Wnd, GWL_EXSTYLE) and WS_EX_LAYERED) = WS_EX_LAYERED then
    begin
    Inc(obj.cnt);
    obj.list[obj.cnt]:=Wnd;
    end;
    EnumChildWindows(Wnd, @_EnumWindowsProc, longint(obj));
    end;
    Result:=True;
    end;

    function GetLayeredWindowsList:TMyWinList;
    begin
    Result:=TMyWinList.Create;
    Result.cnt:=0;
    EnumDesktopWindows(GetThreadDesktop(Windows.GetCurrentThreadId),@_EnumWindowsProc, Longint(Result));
    end;
  *)

function GetCaptureWindow:HWND;
  var
    h1,h2:HWND;
  begin
  if RtcCaptureMode=captureWindowOnly then
    Result:=RtcCaptureWindowHdl
  else
    begin
    h1 := GetDesktopWindow;
    if (h1<>0) and (RtcCaptureMode=captureDesktopOnly) then
      begin
      h2 := FindWindowEx (h1, 0, 'Progman', 'Program Manager');
      if h2<>0 then h1:=h2;
      end;
    Result:=h1;
    end;
  end;

function CaptureFullScreen(MultiMon: boolean;
  PixelFormat: TPixelFormat = pf8bit): TBitmap;
var
  DW: HWND;
  SDC: HDC;
  X, Y: integer;
begin
  SwitchToActiveDesktop;

  Result := TBitmap.Create;
  Result.PixelFormat := PixelFormat;

{$IFDEF MULTIMON}
  if MultiMon then
  begin
    Result.Width := Screen.DesktopWidth;
    Result.Height := Screen.DesktopHeight;
    X := Screen.DesktopLeft;
    Y := Screen.DesktopTop;
  end
  else
{$ENDIF}
  begin
    Result.Width := Screen.Width;
    Result.Height := Screen.Height;
    X := 0;
    Y := 0;
  end;

  Result.Canvas.Lock;
  try
    DW := GetCaptureWindow;
    try
      SDC := GetDC(DW);
    except
      SDC := 0;
    end;
    if (DW <> 0) and (SDC = 0) then
    begin
      DW := 0;
      try
        SDC := GetDC(DW);
      except
        SDC := 0;
      end;
      if SDC = 0 then
        raise Exception.Create('Can not lock on to Desktop Canvas');
    end;
    try
      if not BitBlt(Result.Canvas.Handle, 0, 0, Result.Width, Result.Height,
        SDC, X, Y, SRCCOPY or RTC_CAPTUREBLT) then
      begin
        Result.Free;
        raise Exception.Create('Error capturing screen contents');
      end;
    finally
      ReleaseDC(DW, SDC);
    end;
  finally
    Result.Canvas.Unlock;
  end;
end;

procedure SetDefaultPalette(var Pal: TMaxLogPalette);
var
  i, r, g, b: integer;
  { havepal:boolean;
    Hdl:HWND;
    DC:HDC; }
  procedure SetPal(i, b, g, r: integer);
  begin
    with Pal.palPalEntry[i] do
    begin
      peRed := r;
      peGreen := g;
      peBlue := b;
    end;
  end;

begin
  if Pal.palNumEntries = 16 then
  begin
    { Ignore the disk image of the palette for 16 color bitmaps.
      Replace with the first and last 8 colors of the system palette }
    GetPaletteEntries(SystemPalette16, 0, 8, Pal.palPalEntry[0]);
    GetPaletteEntries(SystemPalette16, 8, 8,
      Pal.palPalEntry[Pal.palNumEntries - 8]);
  end
  else if Pal.palNumEntries = 256 then
  begin
    { Hdl := GetDesktopWindow;
      DC := GetDC(Hdl);
      try
      if (GetDeviceCaps (DC, RASTERCAPS) and RC_PALETTE = RC_PALETTE ) then
      havepal:=GetSystemPaletteEntries ( DC, 0, 256, Pal.palPalEntry )=256
      else
      havepal:=False;
      finally
      ReleaseDC(Hdl,DC);
      end; }

    // if not havepal then
    begin
      SetPal(0, $80, 0, 0);
      SetPal(1, 0, $80, 0);
      SetPal(2, 0, 0, $80);
      SetPal(3, $80, $80, 0);
      SetPal(4, 0, $80, $80);
      SetPal(5, $80, 0, $80);
      i := 6;
      for b := 0 to 4 do
        for r := 0 to 5 do
          for g := 0 to 6 do
          begin
            with Pal.palPalEntry[i] do
            begin
              peBlue := round(b * 255 / 4);
              peRed := round(r * 255 / 5);
              peGreen := round(g * 255 / 6);
            end;
            Inc(i);
          end;
      for r := 1 to 40 do
      begin
        with Pal.palPalEntry[i] do
        begin
          peRed := round(r * 255 / 41);
          peGreen := round(r * 255 / 41);
          peBlue := round(r * 255 / 41);
        end;
        Inc(i);
      end;
    end;
  end;
end;

(*
procedure ByteSwapColors(var Colors; Count: integer);
var // convert RGB to BGR and vice-versa.  TRGBQuad <-> TPaletteEntry
  SysInfo: TSystemInfo;
begin
  GetSystemInfo(SysInfo);
  asm
    MOV   EDX, Colors
    MOV   ECX, Count
    DEC   ECX
    JS    @@END
    LEA   EAX, SysInfo
    CMP   [EAX].TSystemInfo.wProcessorLevel, 3
    JE    @@386
  @@1:  MOV   EAX, [EDX+ECX*4]
    BSWAP EAX
    SHR   EAX,8
    MOV   [EDX+ECX*4],EAX
    DEC   ECX
    JNS   @@1
    JMP   @@END
  @@386:
    PUSH  EBX
  @@2:  XOR   EBX,EBX
    MOV   EAX, [EDX+ECX*4]
    MOV   BH, AL
    MOV   BL, AH
    SHR   EAX,16
    SHL   EBX,8
    MOV   BL, AL
    MOV   [EDX+ECX*4],EBX
    DEC   ECX
    JNS   @@2
    POP   EBX
  @@END:
  end;
end;
*)

function BitmapIsReverse(const Image: TBitmap): boolean;
begin
  With Image do
    if Height < 2 then
      Result := False
    else
      Result := Cardinal(ScanLine[0]) > Cardinal(ScanLine[1]);
end;

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

function IsWinNT: boolean;
var
  OS: TOSVersionInfo;
begin
  ZeroMemory(@OS, SizeOf(OS));
  OS.dwOSVersionInfoSize := SizeOf(OS);
  GetVersionEx(OS);
  Result := OS.dwPlatformId = VER_PLATFORM_WIN32_NT;
end;

{ - TRtcScreenEncoder - }

constructor TRtcScreenEncoder.Create;
begin
  inherited;
  CS := TCriticalSection.Create;

  FMyScreenInfoChanged := False;
  FCaptureMask := SRCCOPY;

  FScreenData := TRtcValue.Create;
  FInitialScreenData := TRtcValue.Create;

  FTmpImage := nil;
  FTmpLastImage := nil;
  SetLength(FTmpStorage, 0);

  FFullScreen := True;
  FCaptureLeft := 0;
  FCaptureTop := 0;
  FCaptureWidth := 0;
  FCaptureHeight := 0;

  FReduce16bit := 0;
  FReduce32bit := 0;

  FScreenWidth := 0;
  FScreenHeight := 0;
  FScreenLeft := 0;
  FScreenTop := 0;
  FScreenBPP := 0;

  FBPPLimit := 4;
  FMaxTotalSize := 0;
  FMaxBlockCount := 1;
  FBPPWidth := 0;

  FOldImage := nil;
  FNewImage := nil;

  FUseCaptureMarks := False;

  SetLength(FImages, 0);
  SetLength(FMarked, 0);
end;

destructor TRtcScreenEncoder.Destroy;
begin
  ReleaseStorage;

  FScreenData.Free;
  FInitialScreenData.Free;

  CS.Free;
  inherited;
end;

procedure TRtcScreenEncoder.Setup(BPPLimit, MaxBlockCount,
  MaxTotalSize: integer);
begin
  FBPPLimit := BPPLimit;
  FMaxTotalSize := MaxTotalSize;
  FMaxBlockCount := MaxBlockCount;

  FCaptureWidth := 0;
  FCaptureHeight := 0;
  FCaptureTop := 0;
  FCaptureLeft := 0;

  FScreenWidth := 0;
  FScreenHeight := 0;
  FScreenLeft := 0;
  FScreenTop := 0;
  FScreenBPP := 0;
end;

function TRtcScreenEncoder.Capture(SleepTime: integer = 0;
  Initial: boolean = False): boolean;
var
  Res: TRtcRecord;
  Data: TRtcArray;
  s: RtcByteArray;
  i, j, k: integer;
  rev: boolean;
  TotalSize: integer;
begin
  Result := False;

  FScreenData.isNull := True;
  FInitialScreenData.isNull := True;

  if Initial then
    CaptureScreenInfo
  else if not ScreenChanged then
    FScreenInfoChanged := False
  else
    CaptureScreenInfo;

  j := 0;
  Data := nil;
  try
    SetBlockIndex(0);
    rev := BitmapIsReverse(FNewImage);

    TotalSize := 0;

    if FScreenGrabBroken then
    begin
      FScreenGrabBroken := False;
      i := FScreenGrabFrom;
    end
    else
      i := -1;

    k := BlockCount;

    while k > 0 do
    begin
      Inc(i);
      if i >= BlockCount then
        i := 0;
      DEC(k);

      if FScreenInfoChanged or not FUseCaptureMarks or FMarked[i] then
      begin
        SetBlockIndex(i);
        if not CaptureBlock then
          Break;

        if FScreenInfoChanged then
          s := CompressBlock_Normal
        else
          s := CompressBlock_Delta;

        if length(s) > 0 then
        begin
          if not assigned(Data) then
            Data := TRtcArray.Create;
          with Data.newRecord(j) do
          begin
            if rev then
            begin
              if i = BlockCount - 1 then
                asInteger['at'] := 0
              else
                asInteger['at'] := FAllBlockSize - (i + 1) * FBlockHeight *
                  FBPPWidth;
            end
            else
              asInteger['at'] := i * FBlockHeight * FBPPWidth;

            asString['img'] := RtcBytesToString(s);
          end;
          Inc(j);
          TotalSize := TotalSize + length(s);
          SetLength(s, 0);
          StoreBlock;
          if FMaxTotalSize > 0 then
          begin
            if not FScreenInfoChanged and (k > 0) then
              if TotalSize > FMaxTotalSize then
              begin
                FScreenGrabBroken := True;
                FScreenGrabFrom := i;
                Break;
              end;
          end
          else
          begin
            FScreenGrabBroken := True;
            FScreenGrabFrom := i;
            Break;
          end;
        end;
        Sleep(SleepTime);
      end;
    end;
  finally
    if assigned(Data) then
    begin
      FScreenData.newRecord;
      Res := FScreenData.asRecord;
      if FScreenInfoChanged then
      begin
        Result := True;
        if FScreenPalette <> '' then
          Res.asString['pal'] := FScreenPalette;
        FNewScreenPalette := False;
        with Res.newRecord('res') do
        begin
          asInteger['Width'] := FCaptureWidth;
          asInteger['Height'] := FCaptureHeight;
          asInteger['Bits'] := FScreenBPP;
          asInteger['Bytes'] := FBytesPerPixel;
        end;
      end
      else if FNewScreenPalette then
      begin
        if FScreenPalette <> '' then
          Res.asString['pal'] := FScreenPalette;
        FNewScreenPalette := False;
      end;
      Res.asObject['scr'] := Data;
    end;
  end;
end;

function TRtcScreenEncoder.GetScreenData: TRtcValue;
begin
  Result := FScreenData;
end;

function TRtcScreenEncoder.GetInitialScreenData: TRtcValue;
var
  Res: TRtcRecord;
  Data: TRtcArray;
  s: RtcByteArray;
  i, j: integer;
  rev: boolean;
begin
  if FInitialScreenData.isNull then
  begin
    j := 0;
    Data := nil;
    try
      SetBlockIndex(0);
      rev := BitmapIsReverse(FOldImage);
      for i := 0 to BlockCount - 1 do
      begin
        SetBlockIndex(i);

        s := CompressBlock_Initial;

        if length(s) > 0 then
        begin
          if not assigned(Data) then
            Data := TRtcArray.Create;
          with Data.newRecord(j) do
          begin
            if rev then
            begin
              if i = BlockCount - 1 then
                asInteger['at'] := 0
              else
                asInteger['at'] := FAllBlockSize - (i + 1) * FBlockHeight *
                  FBPPWidth;
            end
            else
              asInteger['at'] := i * FBlockHeight * FBPPWidth;

            asString['img'] := RtcBytesToString(s);
          end;
          Inc(j);
          SetLength(s, 0);
        end;
      end;
    finally
      if assigned(Data) then
      begin
        FInitialScreenData.newRecord;

        Res := FInitialScreenData.asRecord;
        with Res.newRecord('res') do
        begin
          asInteger['Width'] := FCaptureWidth;
          asInteger['Height'] := FCaptureHeight;
          asInteger['Bits'] := FScreenBPP;
          asInteger['Bytes'] := FBytesPerPixel;
        end;
        if FScreenPalette <> '' then
          Res.asString['pal'] := FScreenPalette;
        Res.asObject['scr'] := Data;
      end;
    end;
  end;
  Result := FInitialScreenData;
end;

procedure TRtcScreenEncoder.PrepareStorage;
var
  i: integer;
begin
  ReleaseStorage;

  CS.Acquire;
  try
    FScreenInfoChanged := True;
    FScreenGrabBroken := False;

    SetLength(FImages, FBlockCount);
    for i := 0 to FBlockCount - 1 do
      FImages[i] := CreateBitmap(i);

    SetLength(FMarked, FBlockCount);
    for i := 0 to FBlockCount - 1 do
      FMarked[i] := True;

    if FBlockCount > 1 then
      FTmpImage := CreateBitmap(0);

    FTmpLastImage := CreateBitmap(FBlockCount - 1);

    SetLength(FTmpStorage, FBlockSize * 2);
  finally
    CS.Release;
  end;
end;

procedure TRtcScreenEncoder.ReleaseStorage;
var
  i: integer;
begin
  CS.Acquire;
  try
    SetLength(FTmpStorage, 0);

    if assigned(FTmpImage) then
    begin
      FTmpImage.Free;
      FTmpImage := nil;
    end;
    if assigned(FTmpLastImage) then
    begin
      FTmpLastImage.Free;
      FTmpLastImage := nil;
    end;
    if assigned(FImages) then
    begin
      for i := 0 to length(FImages) - 1 do
      begin
        FImages[i].Free;
        FImages[i] := nil;
      end;
      SetLength(FImages, 0);
    end;
    if assigned(FMarked) then
      SetLength(FMarked, 0);
  finally
    CS.Release;
  end;
end;

function TRtcScreenEncoder.ScreenChanged: boolean;
Var
  _BitsPerPixel, _ScreenWidth, _ScreenHeight, _ScreenLeft, _ScreenTop: integer;

  r: TRect;
  DW: HWND;
  SDC: HDC;
begin
  SwitchToActiveDesktop;

  DW := GetCaptureWindow;
  try
    SDC := GetDC(DW);
  except
    SDC := 0;
  end;
  if (DW <> 0) and (SDC = 0) then
  begin
    DW := 0;
    try
      SDC := GetDC(DW);
    except
      SDC := 0;
    end;
    if SDC = 0 then
    begin
      Result := False;
      Exit;
    end;
  end;

{$IFDEF MULTIMON}
  if MultiMonitor then
    r := Screen.DesktopRect
  else
{$ENDIF}
    GetWindowRect(DW, r);

  try
    _BitsPerPixel := GetDeviceCaps(SDC, BITSPIXEL);
  finally
    ReleaseDC(DW, SDC);
  end;
  _ScreenLeft := r.Left;
  _ScreenTop := r.Top;
  _ScreenWidth := r.Right - r.Left;
  _ScreenHeight := r.Bottom - r.Top;

  Result := (FScreenBPP <> _BitsPerPixel) or (FScreenWidth <> _ScreenWidth) or
    (FScreenHeight <> _ScreenHeight) or (FScreenLeft <> _ScreenLeft) or
    (FScreenTop <> _ScreenTop);
end;

procedure TRtcScreenEncoder.CaptureScreenInfo;
Var
  BitsPerPixel: integer;
  MaxHeight: integer;
  r: TRect;
  DW: HWND;
  SDC: HDC;

begin
  SwitchToActiveDesktop;

  CS.Acquire;
  try
    DW := GetCaptureWindow;
    try
      SDC := GetDC(DW);
    except
      SDC := 0;
    end;
    if (DW <> 0) and (SDC = 0) then
    begin
      DW := 0;
      try
        SDC := GetDC(DW);
      except
        SDC := 0;
      end;
      if SDC = 0 then
        Exit;
    end;

{$IFDEF MULTIMON}
    if MultiMonitor then
      r := Screen.DesktopRect
    else
{$ENDIF}
      GetWindowRect(DW, r);

    try
      BitsPerPixel := GetDeviceCaps(SDC, BITSPIXEL);
      case BitsPerPixel of
        1 .. 4:
          FBytesPerPixel := 0;
        5 .. 8:
          FBytesPerPixel := 1;
        9 .. 16:
          FBytesPerPixel := 2;
        17 .. 24:
          FBytesPerPixel := 3;
        32:
          FBytesPerPixel := 4;
      Else
        FBytesPerPixel := 3;
      End;
      FScreenBPP := BitsPerPixel;
    finally
      ReleaseDC(DW, SDC);
    end;
    FScreenWidth := r.Right - r.Left;
    FScreenHeight := r.Bottom - r.Top;
    FScreenLeft := r.Left;
    FScreenTop := r.Top;

    if FBytesPerPixel > FBPPLimit then
      FBytesPerPixel := FBPPLimit;

    if FBytesPerPixel = 3 then // 3 BPP images not supported
      FBytesPerPixel := 2;

    if FFullScreen then
    begin
      FCaptureLeft := FScreenLeft;
      FCaptureTop := FScreenTop;
      FCaptureWidth := FScreenWidth;
      FCaptureHeight := FScreenHeight;
    end
    else
    begin
      FCaptureLeft := FFixedRegion.Left;
      FCaptureTop := FFixedRegion.Top;
      if FCaptureLeft < FScreenLeft then
        FCaptureLeft := FScreenLeft;
      if FCaptureTop < FScreenTop then
        FCaptureTop := FScreenTop;

      FCaptureWidth := FFixedRegion.Right - FCaptureLeft;
      FCaptureHeight := FFixedRegion.Bottom - FCaptureTop;
      if FCaptureWidth > FScreenWidth - FCaptureLeft then
        FCaptureWidth := FScreenWidth - FCaptureLeft;
      if FCaptureHeight > FScreenHeight - FCaptureTop then
        FCaptureHeight := FScreenHeight - FCaptureTop;
    end;

    FBlockWidth := FCaptureWidth;
    FBlockHeight := FCaptureHeight;

    if FBytesPerPixel = 0 then
      FBPPWidth := FBlockWidth div 2
    else
      FBPPWidth := FBlockWidth * FBytesPerPixel;

    if FMaxBlockCount > 1 then
    begin
      MaxHeight := FBlockHeight div FMaxBlockCount;
      if MaxHeight < 2 then
        MaxHeight := 2;

      if FBlockHeight > MaxHeight then
        FBlockHeight := MaxHeight;
    end
    else if FMaxTotalSize > 0 then
    begin
      MaxHeight := FMaxTotalSize div FBPPWidth;
      if MaxHeight < 2 then
        MaxHeight := 2;

      if FBlockHeight > MaxHeight then
        FBlockHeight := MaxHeight;
    end;

    FBlockSize := FBlockHeight * FBPPWidth;
    FBlockCount := FCaptureHeight div FBlockHeight;
    FLastBlockHeight := FCaptureHeight - FBlockHeight * FBlockCount;

    if FLastBlockHeight = 0 then
      FLastBlockHeight := FBlockHeight
    else
      Inc(FBlockCount);

    FLastBlockSize := FLastBlockHeight * FBPPWidth;

    FAllBlockSize := FLastBlockSize + (FBlockCount - 1) * FBlockSize;

    FScreenPalette := '';
    FNewScreenPalette := False;
  finally
    CS.Release;
  end;

  PrepareStorage;
end;

function TRtcScreenEncoder.CreateBitmap(index: integer): TBitmap;
var
  Pal: TMaxLogPalette;
  tmp: RtcByteArray;
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
    Width := FBlockWidth;

    if index < FBlockCount - 1 then
      Height := FBlockHeight
    else
      Height := FLastBlockHeight;

    if FBytesPerPixel <= 1 then
    begin
      FillChar(Pal, SizeOf(Pal), #0);
      Pal.palVersion := $300;

      if FBytesPerPixel = 0 then
        Pal.palNumEntries := 16
      else
        Pal.palNumEntries := 256;

      SetDefaultPalette(Pal);

      if FScreenPalette = '' then
      begin
        FNewScreenPalette := True;
        SetLength(tmp, SizeOf(Pal));
        Move(Pal, tmp[0], length(tmp));
        FScreenPalette := RtcBytesToString(tmp);
      end;

      Palette := CreatePalette(TLogPalette(Addr(Pal)^));
    end;
  End;
end;

procedure TRtcScreenEncoder.SetBlockIndex(index: integer);
begin
  FImgIndex := index;

  FOldImage := FImages[index];
  if index < FBlockCount - 1 then
  begin
    FNewImage := FTmpImage;
    FNewBlockSize := FBlockSize;
  end
  else
  begin
    FNewImage := FTmpLastImage;
    FNewBlockSize := FLastBlockSize;
  end;
end;

procedure TRtcScreenEncoder.StoreBlock;
begin
  if FImgIndex < FBlockCount - 1 then
    FTmpImage := FOldImage
  else
    FTmpLastImage := FOldImage;
  FImages[FImgIndex] := FNewImage;
end;

function TRtcScreenEncoder.CaptureBlock: boolean;
var
  BlockTop: integer;
  DW: HWND;
  SDC: HDC;

  function CaptureNow: boolean;
  begin
    FNewImage.Canvas.Lock;
    try
      DW := GetCaptureWindow;
      try
        SDC := GetDC(DW);
      except
        SDC := 0;
      end;
      if (DW <> 0) and (SDC = 0) then
      begin
        DW := 0;
        try
          SDC := GetDC(DW);
        except
          SDC := 0;
        end;
        if SDC = 0 then
        begin
          Result := False;
          Exit;
        end;
      end;
      try
        Result := BitBlt(FNewImage.Canvas.Handle, 0, 0, FNewImage.Width,
          FNewImage.Height, SDC, FCaptureLeft, FCaptureTop + BlockTop,
          FCaptureMask);
      finally
        ReleaseDC(DW, SDC);
      end;
    finally
      FNewImage.Canvas.Unlock;
    end;
  end;

begin
  CS.Acquire;
  try
    FMarked[FImgIndex] := False;
  finally
    CS.Release;
  end;
  BlockTop := FBlockHeight * FImgIndex;

  Result := CaptureNow;

  if Result then
    case FBytesPerPixel of
      4:
        if FReduce32bit <> 0 then
          DWord_ReduceColors(BitmapDataPtr(FNewImage), FNewBlockSize,
            FReduce32bit);
      2:
        if FReduce16bit <> 0 then
          DWord_ReduceColors(BitmapDataPtr(FNewImage), FNewBlockSize,
            FReduce16bit);
    end;
end;

function TRtcScreenEncoder.CompressBlock_Delta: RtcByteArray;
var
  len: integer;
begin
  len := DWordCompress_Delta(BitmapDataPtr(FOldImage), BitmapDataPtr(FNewImage),
    Addr(FTmpStorage[0]), FNewBlockSize);
  if len = 0 then
    SetLength(Result, 0)
  else
  begin
    SetLength(Result, len);
    Move(FTmpStorage[0], Result[0], len);
  end;
end;

function TRtcScreenEncoder.CompressBlock_Normal: RtcByteArray;
var
  len: integer;
begin
  len := DWordCompress_Normal(BitmapDataPtr(FNewImage), Addr(FTmpStorage[0]),
    FNewBlockSize);
  if len = 0 then
    SetLength(Result, 0)
  else
  begin
    SetLength(Result, len);
    Move(FTmpStorage[0], Result[0], len);
  end;
end;

function TRtcScreenEncoder.CompressBlock_Initial: RtcByteArray;
var
  len: integer;
begin
  len := DWordCompress_Normal(BitmapDataPtr(FOldImage), Addr(FTmpStorage[0]),
    FNewBlockSize);
  if len = 0 then
    SetLength(Result, 0)
  else
  begin
    SetLength(Result, len);
    Move(FTmpStorage[0], Result[0], len);
  end;
end;

procedure TRtcScreenEncoder.MarkForCapture(x1, y1, x2, y2: integer);
var
  TopCord, BotCord, i: integer;
begin
  CS.Acquire;
  try
    TopCord := FCaptureTop;
    BotCord := TopCord + FBlockHeight - 1;
    if (FCaptureLeft <= x2) and (FCaptureWidth + FCaptureLeft - 1 >= x1) then
      for i := 0 to FBlockCount - 1 do
      begin
        if (BotCord >= y1) and (TopCord <= y2) then
          FMarked[i] := True;
        Inc(BotCord, FBlockHeight);
        Inc(TopCord, FBlockHeight);
      end;
  finally
    CS.Release;
  end;
end;

procedure TRtcScreenEncoder.MarkForCapture;
var
  i: integer;
begin
  CS.Acquire;
  try
    for i := 0 to FBlockCount - 1 do
      FMarked[i] := True;
  finally
    CS.Release;
  end;
end;

{ - RtcScreenCapture - }

constructor TRtcScreenCapture.Create;
begin
  inherited;
  FShiftDown := False;
  FCtrlDown := False;
  FAltDown := False;

  FReduce16bit := 0;
  FReduce32bit := 0;
  FLowReduce16bit := 0;
  FLowReduce32bit := 0;
  FLowReduceColors := False;
  FLowReduceType := 0;
  FLowReduceColorPercent := 0;

  FBPPLimit := 4;
  FMaxTotalSize := 0;
  FScreenBlockCount := 1;
  FScreen2BlockCount := 1;
  FScreen2Delay := 0;
  FFullScreen := True;
  FCaptureMask := SRCCOPY;

  FScreenWidth := 0;
  FScreenHeight := 0;
  FScreenLeft := 0;
  FScreenTop := 0;

  FCaptureLeft := 0;
  FCaptureTop := 0;
  FCaptureWidth := 0;
  FCaptureHeight := 0;

{$IFDEF DFMirage}
  ScrDeltaRec := nil;
  FMirage := False;
  vd := nil;
  m_BackBm := nil;
  dfm_urgn := nil;
{$ENDIF}
  ScrIn := nil;
  FMouseInit := True;
  FLastMouseUser := '';
  FLastMouseX := -1;
  FLastMouseY := -1;
  FMouseX := -1;
  FMouseY := -1;

  SwitchToActiveDesktop;
end;

destructor TRtcScreenCapture.Destroy;
begin
  ReleaseAllKeys;

{$IFDEF DFMirage}
  if assigned(vd) then
  begin
    vd.Free;
    vd := nil;
    m_BackBm.Free;
    m_BackBm := nil;
  end;
{$ENDIF}
  if assigned(ScrIn) then
  begin
    ScrIn.Free;
    ScrIn := nil;
  end;

{$IFDEF DFMirage}
  if assigned(ScrDeltaRec) then
  begin
    ScrDeltaRec.Free;
    ScrDeltaRec := nil;
  end;
  if assigned(dfm_urgn) then
  begin
    dfm_urgn.Free;
    dfm_urgn := nil;
  end;
{$ENDIF}
  if FMouseDriver then
    SetMouseDriver(False);

  inherited;
end;

procedure TRtcScreenCapture.InitSize;
begin
{$IFDEF MULTIMON}
  if MultiMonitor then
  begin
    FScreenWidth := Screen.DesktopWidth;
    FScreenHeight := Screen.DesktopHeight;
    FScreenLeft := Screen.DesktopLeft;
    FScreenTop := Screen.DesktopTop;
  end
  else
{$ENDIF}
  begin
    FScreenWidth := Screen.Width;
    FScreenHeight := Screen.Height;
    FScreenLeft := 0;
    FScreenTop := 0;
  end;

  if FullScreen then
  begin
    FCaptureLeft := FScreenLeft;
    FCaptureTop := FScreenTop;
    FCaptureWidth := FScreenWidth;
    FCaptureHeight := FScreenHeight;
  end
  else
  begin
    FCaptureLeft := FFixedRegion.Left;
    FCaptureTop := FFixedRegion.Top;
    FCaptureWidth := FFixedRegion.Right - FCaptureLeft;
    FCaptureHeight := FFixedRegion.Bottom - FCaptureTop;
  end;
end;

procedure TRtcScreenCapture.Init;
begin
{$IFDEF DFMirage}
  if FMirage then
  begin
    if not assigned(vd) then
    begin
      InitSize;
      vd := TVideoDriver.Create;
    end;
  end
  else
{$ENDIF}
    if not assigned(ScrIn) then
    begin
      InitSize;
      ScrIn := TRtcScreenEncoder.Create;
      ScrIn.Setup(FBPPLimit, FScreenBlockCount, FMaxTotalSize);
      ScrIn.Reduce16bit := FReduce16bit;
      ScrIn.Reduce32bit := FReduce32bit;
      ScrIn.FullScreen := FFullScreen;
      ScrIn.FixedRegion := FFixedRegion;
      ScrIn.CaptureMask := FCaptureMask;
      ScrIn.MultiMonitor := FMultiMon;
    end;
end;

function TRtcScreenCapture.GrabScreen: boolean;
begin
  Init;
{$IFDEF DFMirage}
  if FMirage then
  begin
    if assigned(ScrDeltaRec) then
    begin
      ScrDeltaRec.Free;
      ScrDeltaRec := nil;
    end;

    if ScreenChanged then
      m_Init := True;

    if m_Init then
    begin
      if FMirage then
      begin
        Result := True;
        m_Init := False;
        ScrDeltaRec := GrabImageFullscreen;
      end
      else
        Result := ScrIn.Capture;
    end
    else
    begin
      Result := False;
      ScrDeltaRec := GrabImageIncremental;
    end;
  end
  else
{$ENDIF}
    Result := ScrIn.Capture;
end;

function TRtcScreenCapture.GetScreenDelta: RtcString;
var
  rec: TRtcRecord;
begin
{$IFDEF DFMirage}
  if FMirage then
  begin
    if assigned(ScrDeltaRec) then
      Result := ScrDeltaRec.toCode
    else
      Result := '';
  end
  else
{$ENDIF}
    if ScrIn.GetScreenData.isType = rtc_Record then
    begin
      rec := ScrIn.GetScreenData.asRecord;
      if assigned(rec) then
        Result := rec.toCode
      else
        Result := '';
    end
    else
      Result := '';
end;

function TRtcScreenCapture.GetScreen: RtcString;
var
  rec: TRtcRecord;
begin
{$IFDEF DFMirage}
  if FMirage then
  begin
    rec := GrabImageOldScreen;
    if assigned(rec) then
      Result := rec.toCode
    else
      Result := '';
    rec.Free;
  end
  else
{$ENDIF}
    if ScrIn.GetInitialScreenData.isType = rtc_Record then
    begin
      rec := ScrIn.GetInitialScreenData.asRecord;
      if assigned(rec) then
        Result := rec.toCode
      else
        Result := '';
    end
    else
      Result := '';
end;

procedure TRtcScreenCapture.SetMaxTotalSize(const Value: integer);
begin
  if FMaxTotalSize <> Value then
  begin
    if assigned(ScrIn) then
    begin
      ScrIn.Free;
      ScrIn := nil;
    end;
{$IFDEF DFMirage}
    if assigned(vd) then
    begin
      vd.Free;
      vd := nil;
    end;
{$ENDIF}
    FMaxTotalSize := Value;
  end;
end;

procedure TRtcScreenCapture.SetBPPLimit(const Value: integer);
begin
  if FBPPLimit <> Value then
  begin
    if assigned(ScrIn) then
    begin
      ScrIn.Free;
      ScrIn := nil;
    end;
{$IFDEF DFMirage}
    if assigned(vd) then
    begin
      vd.Free;
      vd := nil;
    end;
{$ENDIF}
    FBPPLimit := Value;
  end;
end;

procedure TRtcScreenCapture.SetScreenBlockCount(const Value: integer);
begin
  if FScreenBlockCount <> Value then
  begin
    if assigned(ScrIn) then
    begin
      ScrIn.Free;
      ScrIn := nil;
    end;
{$IFDEF DFMirage}
    if assigned(vd) then
    begin
      vd.Free;
      vd := nil;
    end;
{$ENDIF}
    FScreenBlockCount := Value;
  end;
end;

procedure TRtcScreenCapture.SetScreen2BlockCount(const Value: integer);
begin
  if FScreen2BlockCount <> Value then
  begin
    if assigned(ScrIn) then
    begin
      ScrIn.Free;
      ScrIn := nil;
    end;
{$IFDEF DFMirage}
    if assigned(vd) then
    begin
      vd.Free;
      vd := nil;
    end;
{$ENDIF}
    FScreen2BlockCount := Value;
  end;
end;

procedure TRtcScreenCapture.SetScreen2Delay(const Value: integer);
begin
  if FScreen2Delay <> Value then
  begin
    if assigned(ScrIn) then
    begin
      ScrIn.Free;
      ScrIn := nil;
    end;
{$IFDEF DFMirage}
    if assigned(vd) then
    begin
      vd.Free;
      vd := nil;
    end;
{$ENDIF}
    FScreen2Delay := Value;
  end;
end;

procedure TRtcScreenCapture.SetFixedRegion(const Value: TRect);
var
  dif: integer;
begin
  if assigned(ScrIn) then
  begin
    ScrIn.Free;
    ScrIn := nil;
  end;
{$IFDEF DFMirage}
  if assigned(vd) then
  begin
    vd.Free;
    vd := nil;
  end;
{$ENDIF}
  FFullScreen := False;
  FFixedRegion := Value;
  if (FFixedRegion.Right - FFixedRegion.Left) mod 4 <> 0 then
  begin
    dif := 4 - ((FFixedRegion.Right - FFixedRegion.Left) mod 4);
    if FFixedRegion.Left - dif >= 0 then
      FFixedRegion.Left := FFixedRegion.Left - dif
    else
      FFixedRegion.Right := FFixedRegion.Right + dif;
  end;
end;

procedure TRtcScreenCapture.SetFullScreen(const Value: boolean);
begin
  if Value <> FFullScreen then
  begin
    FFullScreen := Value;
    if assigned(ScrIn) then
    begin
      ScrIn.Free;
      ScrIn := nil;
    end;
{$IFDEF DFMirage}
    if assigned(vd) then
    begin
      vd.Free;
      vd := nil;
    end;
{$ENDIF}
  end;
end;

procedure TRtcScreenCapture.SetMouseDriver(const Value: boolean);
begin
{$IFDEF KMDriver}
  if FMouseDriver <> Value then
  begin
    FMouseDriver := Value;
    if FMouseDriver then
    begin
      if FMouseAInit = 0 then
      begin
        if IsWinNT then
          if MouseAInf.MouseAInit then
            Inc(FMouseAInit);
      end
      else
        Inc(FMouseAInit);
    end
    else if (FMouseAInit > 0) then
    begin
      DEC(FMouseAInit);
      if FMouseAInit = 0 then
        MouseAInf.MouseAUnInit;
    end;
  end;
{$ENDIF}
end;

procedure TRtcScreenCapture.SetReduce16bit(const Value: longword);
begin
  if Value <> FReduce16bit then
  begin
    FReduce16bit := Value;
    if assigned(ScrIn) then
    begin
      ScrIn.Free;
      ScrIn := nil;
    end;
{$IFDEF DFMirage}
    if assigned(vd) then
    begin
      vd.Free;
      vd := nil;
    end;
{$ENDIF}
  end;
end;

procedure TRtcScreenCapture.SetReduce32bit(const Value: longword);
begin
  if Value <> FReduce32bit then
  begin
    FReduce32bit := Value;
    if assigned(ScrIn) then
    begin
      ScrIn.Free;
      ScrIn := nil;
    end;
{$IFDEF DFMirage}
    if assigned(vd) then
    begin
      vd.Free;
      vd := nil;
    end;
{$ENDIF}
  end;
end;

procedure TRtcScreenCapture.SetLowReduce16bit(const Value: longword);
begin
  if Value <> FLowReduce16bit then
  begin
    FLowReduce16bit := Value;
    if assigned(ScrIn) then
    begin
      ScrIn.Free;
      ScrIn := nil;
    end;
{$IFDEF DFMirage}
    if assigned(vd) then
    begin
      vd.Free;
      vd := nil;
    end;
{$ENDIF}
  end;
end;

procedure TRtcScreenCapture.SetLowReduce32bit(const Value: longword);
begin
  if Value <> FLowReduce32bit then
  begin
    FLowReduce32bit := Value;
    if assigned(ScrIn) then
    begin
      ScrIn.Free;
      ScrIn := nil;
    end;
{$IFDEF DFMirage}
    if assigned(vd) then
    begin
      vd.Free;
      vd := nil;
    end;
{$ENDIF}
  end;
end;

procedure TRtcScreenCapture.SetLowReduceColors(const Value: boolean);
begin
  if Value <> FLowReduceColors then
  begin
    FLowReduceColors := Value;
    if assigned(ScrIn) then
    begin
      ScrIn.Free;
      ScrIn := nil;
    end;
{$IFDEF DFMirage}
    if assigned(vd) then
    begin
      vd.Free;
      vd := nil;
    end;
{$ENDIF}
  end;
end;

procedure TRtcScreenCapture.SetLowReduceType(const Value: integer);
begin
  if Value <> FLowReduceType then
  begin
    FLowReduceType := Value;
    if assigned(ScrIn) then
    begin
      ScrIn.Free;
      ScrIn := nil;
    end;
{$IFDEF DFMirage}
    if assigned(vd) then
    begin
      vd.Free;
      vd := nil;
    end;
{$ENDIF}
  end;
end;

procedure TRtcScreenCapture.SetLowReduceColorPercent(const Value: integer);
begin
  if Value <> FLowReduceColorPercent then
  begin
    FLowReduceColorPercent := Value;
    if assigned(ScrIn) then
    begin
      ScrIn.Free;
      ScrIn := nil;
    end;
{$IFDEF DFMirage}
    if assigned(vd) then
    begin
      vd.Free;
      vd := nil;
    end;
{$ENDIF}
  end;
end;

function TRtcScreenCapture.GetFixedRegion: TRect;
begin
  Result := FixedRegion;
end;

function TRtcScreenCapture.GetFullScreen: boolean;
begin
  Result := FFullScreen;
end;

function TRtcScreenCapture.GetMaxTotalSize: integer;
begin
  Result := FMaxTotalSize;
end;

function TRtcScreenCapture.GetBPPLimit: integer;
begin
  Result := FBPPLimit;
end;

function TRtcScreenCapture.GetScreenBlockCount: integer;
begin
  Result := FScreenBlockCount;
end;

function TRtcScreenCapture.GetScreen2BlockCount: integer;
begin
  Result := FScreen2BlockCount;
end;

function TRtcScreenCapture.GetScreen2Delay: integer;
begin
  Result := FScreen2Delay;
end;

function TRtcScreenCapture.GetReduce16bit: longword;
begin
  Result := FReduce16bit;
end;

function TRtcScreenCapture.GetReduce32bit: longword;
begin
  Result := FReduce32bit;
end;

function TRtcScreenCapture.GetLowReduce16bit: longword;
begin
  Result := FLowReduce16bit;
end;

function TRtcScreenCapture.GetLowReduce32bit: longword;
begin
  Result := FLowReduce32bit;
end;

function TRtcScreenCapture.GetLowReduceColors: boolean;
begin
  Result := FLowReduceColors;
end;

function TRtcScreenCapture.GetLowReduceType: integer;
begin
  Result := FLowReduceType;
end;

function TRtcScreenCapture.GetLowReduceColorPercent: integer;
begin
  Result := FLowReduceColorPercent;
end;

procedure TRtcScreenCapture.Clear;
begin
{$IFDEF DFMirage}
  if FMirage then
    m_Init := True
  else
{$ENDIF}
    if assigned(ScrIn) then
    begin
      ScrIn.Free;
      ScrIn := nil;
    end;
  FMouseInit := True;
  ReleaseAllKeys;
end;

function TRtcScreenCapture.GetLayeredWindows: boolean;
begin
  Result := (FCaptureMask and RTC_CAPTUREBLT) = RTC_CAPTUREBLT;
end;

procedure TRtcScreenCapture.SetLayeredWindows(const Value: boolean);
begin
  if Value then
    FCaptureMask := FCaptureMask or RTC_CAPTUREBLT
  else
    FCaptureMask := FCaptureMask and not RTC_CAPTUREBLT;
end;

{$IFDEF DFMirage}
{ Mirage Video Capture }

function ScaleByPixformat(const v: integer; pf: TPixelFormat): integer;
begin
  case pf of
    pf1bit:
      Result := v div 8;
    pf4bit:
      Result := v div 2;
    pf8bit:
      Result := v;
    pf15bit, pf16bit:
      Result := v * 2;
    pf24bit:
      Result := v * 3;
  else
    Result := v * 4;
  end;
end;

function BPPToPixelFormat(a: byte): TPixelFormat;
begin
  case a of
    1:
      Result := pf1bit;
    4:
      Result := pf4bit;
    8:
      Result := pf8bit;
    15:
      Result := pf15bit;
    16:
      Result := pf16bit;
    24:
      Result := pf24bit;
    32:
      Result := pf32bit;
  else
    Result := pf32bit;
  end;
end;

function TRtcScreenCapture.GetMirageDriver: boolean;
begin
  Result := FMirage;
end;

procedure TRtcScreenCapture.SetMirageDriver(const Value: boolean);
var
  fixed: TRect;
begin
  if FMirage <> Value then
  begin
    FMirage := Value;
    if FMirage then
    begin
      if not assigned(m_BackBm) then
      begin
        Init;
        try
          vd.MultiMonitor := MultiMonitor;
          if not vd.ExistMirrorDriver then
            FMirage := False
          else if vd.IsMirrorDriverActive then
          begin
            vd.DeactivateMirrorDriver;
            Sleep(2000);
            if not vd.ActivateMirrorDriver then
              FMirage := False
            else
            begin
              Sleep(1000);
              vd.MapSharedBuffers;
              FMirage := vd.IsDriverActive;
              if not FMirage then
              begin
                vd.UnMapSharedBuffers;
                vd.DeactivateMirrorDriver;
              end;
            end;
          end
          else if not vd.ActivateMirrorDriver then
            FMirage := False
          else
          begin
            Sleep(1000);
            vd.MapSharedBuffers;
            FMirage := vd.IsDriverActive;
          end;
        except
          FMirage := False;
        end;

        if FMirage then
        begin
          m_Init := True;
          FMouseInit := True;
          m_BackBm := TBitmap.Create;
          m_BackBm.PixelFormat := BPPToPixelFormat(vd.BitsPerPixel);

          if FFullScreen then
          begin
{$IFDEF MULTIMON}
            if MultiMonitor then
            begin
              FFixedRegion.Left := Screen.DesktopRect.Left;
              FFixedRegion.Top := Screen.DesktopRect.Top;
              FFixedRegion.Right := Screen.DesktopRect.Right;
              FFixedRegion.Bottom := Screen.DesktopRect.Bottom;
            end
            else
{$ENDIF}
            begin
              FFixedRegion.Left := 0;
              FFixedRegion.Top := 0;
              FFixedRegion.Right := Screen.Width;
              FFixedRegion.Bottom := Screen.Height;
            end;
          end;

          vd.Reduce16bit := Reduce16bit;
          vd.Reduce32bit := Reduce32bit;
          vd.LowReduce16bit := LowReduce16bit;
          vd.LowReduce32bit := LowReduce32bit;
          vd.LowReduceColors := LowReducedColors;
          vd.LowReduceType := LowReduceType;
          vd.LowReduceColorPercent := LowReduceColorPercent;

          m_BackBm.Width := FFixedRegion.Right - FFixedRegion.Left;
          m_BackBm.Height := FFixedRegion.Bottom - FFixedRegion.Top;

{$IFDEF MULTIMON}
          if MultiMonitor then
          begin
            fixed.Left := FFixedRegion.Left - Screen.DesktopLeft;
            fixed.Top := FFixedRegion.Top - Screen.DesktopTop;
            fixed.Right := FFixedRegion.Right - Screen.DesktopLeft;
            fixed.Bottom := FFixedRegion.Bottom - Screen.DesktopTop;
          end
          else
{$ENDIF}
            fixed := FFixedRegion;

          vd.SetRegion(fixed);
        end
        else
        begin
          vd.Free;
          vd := nil;
        end;
      end;
    end
    else
    begin
      if assigned(m_BackBm) then
      begin
        vd.Free;
        vd := nil;
        m_BackBm.Free;
        m_BackBm := nil;
      end;
    end;
  end;
end;

function TRtcScreenCapture.ScreenChanged: boolean;
Var
  _ScreenWidth, _ScreenHeight, _ScreenLeft, _ScreenTop: integer;

  r: TRect;
  DW: HWND;
  SDC: HDC;

begin
  SwitchToActiveDesktop;

{$IFDEF MULTIMON}
  if MultiMonitor then
    r := Screen.DesktopRect
  else
{$ENDIF}
  begin
    DW := GetCaptureWindow;
    try
      SDC := GetDC(DW);
    except
      SDC := 0;
    end;
    if (DW <> 0) and (SDC = 0) then
    begin
      DW := 0;
      try
        SDC := GetDC(DW);
      except
        SDC := 0;
      end;
      if SDC = 0 then
      begin
        Result := False;
        Exit;
      end;
    end;
    GetWindowRect(DW, r);
    ReleaseDC(DW, SDC);
  end;

  _ScreenLeft := r.Left;
  _ScreenTop := r.Top;
  _ScreenWidth := r.Right - r.Left;
  _ScreenHeight := r.Bottom - r.Top;

  Result := (FScreenWidth <> _ScreenWidth) or (FScreenHeight <> _ScreenHeight)
    or (FScreenLeft <> _ScreenLeft) or (FScreenTop <> _ScreenTop);

  if Result then
  begin
    MirageDriver := False;
    Sleep(1000);
    MirageDriver := True;
    Init;
  end;
end;

function TRtcScreenCapture.GrabImageIncremental: TRtcRecord;
begin
  dfm_urgn.StartAdd;
  vd.UpdateIncremental(dfm_DstStride, dfm_urgn, dfm_ImgLine0);
  Result := dfm_urgn.CaptureRgnDelta(vd, dfm_DstStride, dfm_ImgLine0);
end;

function TRtcScreenCapture.GrabImageFullscreen: TRtcRecord;
begin
  dfm_ImgLine0 := PAnsiChar(m_BackBm.ScanLine[0]);
  dfm_DstStride := -ScaleByPixformat(m_BackBm.Width, m_BackBm.PixelFormat);

  dfm_fixed.Left := FFixedRegion.Left - FScreenLeft;
  dfm_fixed.Top := FFixedRegion.Top - FScreenTop;
  dfm_fixed.Right := FFixedRegion.Right - FScreenLeft;
  dfm_fixed.Bottom := FFixedRegion.Bottom - FScreenTop;

  if not assigned(dfm_urgn) then
  begin
    dfm_urgn := TGridUpdRegion.Create;
    dfm_urgn.SetScrRect(dfm_fixed);

    dfm_urgn.ScanStep := FScreenBlockCount;
    if dfm_urgn.ScanStep < 1 then
      dfm_urgn.ScanStep := 1
    else if dfm_urgn.ScanStep > 12 then
      dfm_urgn.ScanStep := 12;

    dfm_urgn.ScanStep2 := FScreen2BlockCount;
    if dfm_urgn.ScanStep2 < 1 then
      dfm_urgn.ScanStep2 := 1
    else if dfm_urgn.ScanStep2 > 12 then
      dfm_urgn.ScanStep2 := 12;

    dfm_urgn.Scan2Delay := FScreen2Delay;

    if FMaxTotalSize > 0 then
      dfm_urgn.MaxSize := FMaxTotalSize
    else
      dfm_urgn.MaxSize := 0;
  end;

  dfm_urgn.StartAdd;
  dfm_urgn.AddRect(dfm_fixed);
  vd.UpdateIncremental(dfm_DstStride, dfm_urgn, dfm_ImgLine0);

  Result := dfm_urgn.CaptureRgnNormal(vd, dfm_DstStride, dfm_ImgLine0);
  with Result.newRecord('res') do
  begin
    asInteger['Width'] := m_BackBm.Width;
    asInteger['Height'] := m_BackBm.Height;
    asInteger['Bits'] := vd.BitsPerPixel;
    asInteger['Bytes'] := vd.BytesPerPixel;
  end;
end;

function TRtcScreenCapture.GrabImageOldScreen: TRtcRecord;
var
  urgn: TGridUpdRegion;
begin
  urgn := TGridUpdRegion.Create;
  urgn.SetScrRect(dfm_fixed);
  urgn.StartAdd;
  urgn.AddRect(dfm_fixed);

  Result := urgn.CaptureRgnOld(vd, dfm_DstStride, dfm_ImgLine0);
  with Result.newRecord('res') do
  begin
    asInteger['Width'] := m_BackBm.Width;
    asInteger['Height'] := m_BackBm.Height;
    asInteger['Bits'] := vd.BitsPerPixel;
    asInteger['Bytes'] := vd.BytesPerPixel;
  end;

  urgn.Free;
end;

{$ELSE}

function TRtcScreenCapture.GetMirageDriver: boolean;
begin
  Result := False;
end;

procedure TRtcScreenCapture.SetMirageDriver(const Value: boolean);
begin
  // Mirage Driver not supported
end;

{$ENDIF}

procedure TRtcScreenCapture.GrabMouse;
var
  ci: TCursorInfo;
  icinfo: TIconInfo;
  pt: TPoint;
  i: integer;
begin
  ci.cbSize := SizeOf(ci);
  if Get_CursorInfo(ci) then
  begin
    if ci.flags = CURSOR_SHOWING then
    begin
      FMouseVisible := True;
      if FMouseInit or (ci.ptScreenPos.X <> FMouseX) or
        (ci.ptScreenPos.Y <> FMouseY) then
      begin
        FMouseMoved := True;
        FMouseX := ci.ptScreenPos.X;
        FMouseY := ci.ptScreenPos.Y;

        if (FLastMouseUser <> '') and (FMouseX = FLastMouseX) and
          (FMouseY = FLastMouseY) then
          FMouseUser := FLastMouseUser
        else
          FMouseUser := '';
      end;
      if FMouseInit or (ci.hCursor <> FMouseHandle) then
      begin
        FMouseChangedShape := True;
        FMouseHandle := ci.hCursor;
        if assigned(FMouseIcon) then
        begin
          FMouseIcon.Free;
          FMouseIcon := nil;
        end;
        if assigned(FMouseIconMask) then
        begin
          FMouseIconMask.Free;
          FMouseIconMask := nil;
        end;
        FMouseShape := 1;
        for i := crSizeAll to crDefault do
          if ci.hCursor = Screen.Cursors[i] then
          begin
            FMouseShape := i;
            Break;
          end;
        if FMouseShape = 1 then
        begin
          // send cursor image only for non-standard shapes
          if GetIconInfo(ci.hCursor, icinfo) then
          begin
            FMouseHotX := icinfo.xHotspot;
            FMouseHotY := icinfo.yHotspot;

            if icinfo.hbmMask <> INVALID_HANDLE_VALUE then
            begin
              FMouseIconMask := TBitmap.Create;
              FMouseIconMask.Handle := icinfo.hbmMask;
              FMouseIconMask.PixelFormat := pf4bit;
            end;

            if icinfo.hbmColor <> INVALID_HANDLE_VALUE then
            begin
              FMouseIcon := TBitmap.Create;
              FMouseIcon.Handle := icinfo.hbmColor;
              case FBPPLimit of
                0:
                  if FMouseIcon.PixelFormat > pf4bit then
                    FMouseIcon.PixelFormat := pf4bit;
                1:
                  if FMouseIcon.PixelFormat > pf8bit then
                    FMouseIcon.PixelFormat := pf8bit;
                2:
                  if FMouseIcon.PixelFormat > pf16bit then
                    FMouseIcon.PixelFormat := pf16bit;
              end;
            end;
          end;
        end;
      end;
      FMouseInit := False;
    end
    else
      FMouseVisible := False;
  end
  else if GetCursorPos(pt) then
  begin
    FMouseVisible := True;
    if FMouseInit or (pt.X <> FMouseX) or (pt.Y <> FMouseY) then
    begin
      FMouseMoved := True;
      FMouseX := pt.X;
      FMouseY := pt.Y;
      if (FLastMouseUser <> '') and (FMouseX = FLastMouseX) and
        (FMouseY = FLastMouseY) then
        FMouseUser := FLastMouseUser
      else
        FMouseUser := '';
    end;
    FMouseInit := False;
  end
  else
    FMouseVisible := False;
end;

function TRtcScreenCapture.GetMouseDelta: RtcString;
var
  rec: TRtcRecord;
begin
  if FMouseMoved or FMouseChangedShape or (FMouseLastVisible <> FMouseVisible)
  then
  begin
    rec := TRtcRecord.Create;
    try
      if FMouseLastVisible <> FMouseVisible then
        rec.asBoolean['V'] := FMouseVisible;
      if FMouseMoved then
      begin
        rec.asInteger['X'] := FMouseX - FCaptureLeft;
        rec.asInteger['Y'] := FMouseY - FCaptureTop;
        if FMouseUser <> '' then
          rec.asText['U'] := FMouseUser;
      end;
      if FMouseChangedShape then
      begin
        if FMouseShape <= 0 then
          rec.asInteger['C'] := -FMouseShape // 0 .. -22  ->>  0 .. 22
        else
        begin
          rec.asInteger['HX'] := FMouseHotX;
          rec.asInteger['HY'] := FMouseHotY;
          if FMouseIcon <> nil then
            FMouseIcon.SaveToStream(rec.newByteStream('I'));
          if FMouseIconMask <> nil then
            FMouseIconMask.SaveToStream(rec.newByteStream('M'));
        end;
      end;
      Result := rec.toCode;
    finally
      rec.Free;
    end;
    FMouseMoved := False;
    FMouseChangedShape := False;
    FMouseLastVisible := FMouseVisible;
  end;
end;

function TRtcScreenCapture.GetMouse: RtcString;
begin
  FMouseChangedShape := True;
  FMouseMoved := True;
  FMouseLastVisible := not FMouseVisible;
  Result := GetMouseDelta;
end;

function IsMyHandle(a: HWND): TForm;
var
  i, cnt: integer;
begin
  Result := nil;
  cnt := Screen.FormCount;
  for i := 0 to cnt - 1 do
    if Screen.Forms[i].Handle = a then
    begin
      Result := Screen.Forms[i];
      Break;
    end;
end;

function okToClick(X, Y: integer): boolean;
var
  P: TPoint;
  W: HWND;
  hit: integer;
begin
  P.X := X;
  P.Y := Y;
  W := WindowFromPoint(P);
  if IsMyHandle(W) <> nil then
  begin
    hit := SendMessage(W, WM_NCHITTEST, 0, P.X + (P.Y shl 16));
    Result := not(hit in [HTCLOSE, HTMAXBUTTON, HTMINBUTTON]);
  end
  else
    Result := True;
end;

function okToUnClick(X, Y: integer): boolean;
var
  P: TPoint;
  W: HWND;
  hit: integer;
  frm: TForm;
begin
  P.X := X;
  P.Y := Y;
  W := WindowFromPoint(P);
  frm := IsMyHandle(W);
  if assigned(frm) then
  begin
    hit := SendMessage(W, WM_NCHITTEST, 0, P.X + (P.Y shl 16));
    Result := not(hit in [HTCLOSE, HTMAXBUTTON, HTMINBUTTON]);
    if not Result then
    begin
      case hit of
        HTCLOSE:
          PostMessage(W, WM_SYSCOMMAND, SC_CLOSE, 0);
        HTMINBUTTON:
          PostMessage(W, WM_SYSCOMMAND, SC_MINIMIZE, 0);
        HTMAXBUTTON:
          if frm.WindowState = wsMaximized then
            PostMessage(W, WM_SYSCOMMAND, SC_RESTORE, 0)
          else
            PostMessage(W, WM_SYSCOMMAND, SC_MAXIMIZE, 0);
      end;
    end;
  end
  else
    Result := True;
end;

procedure TRtcScreenCapture.Post_MouseDown(Button: TMouseButton);
begin
{$IFDEF KMDriver}
  if FMouseDriver and (FMouseAInit > 0) then
  begin
    case Button of
      mbLeft:
        MouseAInf.MouseAImitationLButtonDown;
      mbRight:
        MouseAInf.MouseAImitationRButtonDown;
      mbMiddle:
        mouse_event(MOUSEEVENTF_MIDDLEDOWN, 0, 0, 0, 0);
    end;
  end
  else
{$ENDIF}
    case Button of
      mbLeft:
        mouse_event(MOUSEEVENTF_LEFTDOWN, 0, 0, 0, 0);
      mbRight:
        mouse_event(MOUSEEVENTF_RIGHTDOWN, 0, 0, 0, 0);
      mbMiddle:
        mouse_event(MOUSEEVENTF_MIDDLEDOWN, 0, 0, 0, 0);
    end;
end;

procedure TRtcScreenCapture.Post_MouseUp(Button: TMouseButton);
begin
{$IFDEF KMDriver}
  if FMouseDriver and (FMouseAInit > 0) then
  begin
    case Button of
      mbLeft:
        MouseAInf.MouseAImitationLButtonUp;
      mbRight:
        MouseAInf.MouseAImitationRButtonUp;
      mbMiddle:
        mouse_event(MOUSEEVENTF_MIDDLEDOWN, 0, 0, 0, 0);
    end;
  end
  else
{$ENDIF}
    case Button of
      mbLeft:
        mouse_event(MOUSEEVENTF_LEFTUP, 0, 0, 0, 0);
      mbRight:
        mouse_event(MOUSEEVENTF_RIGHTUP, 0, 0, 0, 0);
      mbMiddle:
        mouse_event(MOUSEEVENTF_MIDDLEUP, 0, 0, 0, 0);
    end;
end;

procedure TRtcScreenCapture.Post_MouseWheel(Wheel: integer);
begin
  mouse_event(MOUSEEVENTF_WHEEL, 0, 0, Wheel, 0);
end;

procedure TRtcScreenCapture.Post_MouseMove(X, Y: integer);
begin
{$IFDEF KMDriver}
  if FMouseDriver and (FMouseAInit > 0) then
  begin
    if (X > Screen.DesktopRect.Right) or (X < Screen.DesktopRect.Left) or
      (Y > Screen.DesktopRect.Bottom) or (Y < Screen.DesktopRect.Top) then
      Exit;

    if ScreenWidth > 0 then
    begin
      MouseAInf.MouseAImitationMove(mfMOUSE_MOVE_ABSOLUTE,
        MouseAInf.MouseXYToScreen(Point(X, Y)));
    end
    else
      SetCursorPos(X, Y);
  end
  else
{$ENDIF}
    if ScreenWidth > 0 then
    begin
      X := round(X / (Screen.Width - 1) * 65535);
      Y := round(Y / (Screen.Height - 1) * 65535);
      mouse_event(MOUSEEVENTF_MOVE or MOUSEEVENTF_ABSOLUTE, X, Y, 0, 0);
    end
    else
      SetCursorPos(X, Y);
end;

procedure PostMouseMessage(Msg:Cardinal; MouseX, MouseY: integer);
  var
    hdl,chdl:HWND;
    wpt,pt:TPoint;
    r:TRect;
  begin
  pt.X:=MouseX;
  pt.Y:=MouseY;
  wpt:=pt;
  if RtcMouseWindowHdl=0 then
    hdl:=WindowFromPoint(pt)
  else
    begin
    hdl:=RtcMouseWindowHdl;
    if IsWindow(hdl) then
      begin
      GetWindowRect(hdl,r);
      repeat
        pt.X:=wpt.X-r.Left;
        pt.Y:=wpt.Y-r.Top;
        chdl:=ChildWindowFromPointEx(hdl,pt,1+4);
        if not IsWindow(chdl) then
          Break
        else if chdl=hdl then
          Break
        else
          begin
          GetWindowRect(chdl,r);
          if (wpt.x>=r.left) and (wpt.x<=r.right) and
             (wpt.y>=r.top) and (wpt.y<=r.bottom) then
            hdl:=chdl
          else
            Break;
          end;
        until False;
      end;
    end;
  if IsWindow(hdl) then
    begin
    GetWindowRect(hdl,r);
    pt.x:=wpt.X-r.left;
    pt.y:=wpt.Y-r.Top;
    PostMessageA(hdl,msg,0,MakeLong(pt.X,pt.Y));
    end;
  end;

procedure TRtcScreenCapture.MouseDown(const user: string; X, Y: integer;
  Button: TMouseButton);
  var
    pt:TPoint;
begin
  FLastMouseUser := user;
  FLastMouseX := X + FCaptureLeft;
  FLastMouseY := Y + FCaptureTop;

  if Button in [mbLeft, mbRight] then
    if GetSystemMetrics(SM_SWAPBUTTON) <> 0 then
      case Button of
        mbLeft:
          Button := mbRight;
        mbRight:
          Button := mbLeft;
      end;

  if RtcMouseControlMode=eventMouseControl then
    begin
    Post_MouseMove(FLastMouseX, FLastMouseY);
    if Button <> mbLeft then
      Post_MouseDown(Button)
    else if okToClick(FLastMouseX, FLastMouseY) then
      Post_MouseDown(Button);
    end
  else
    begin
    case Button of
      mbLeft: PostMouseMessage(WM_LBUTTONDOWN,pt.X,pt.Y);
      mbRight: PostMouseMessage(WM_RBUTTONDOWN,pt.X,pt.Y);
      mbMiddle: PostMouseMessage(WM_MBUTTONDOWN,pt.X,pt.Y);
      end;
    end;
end;

procedure TRtcScreenCapture.MouseUp(const user: string; X, Y: integer;
  Button: TMouseButton);
  var
    pt:TPoint;
begin
  FLastMouseUser := user;
  FLastMouseX := X + FCaptureLeft;
  FLastMouseY := Y + FCaptureTop;

  if Button in [mbLeft, mbRight] then
    if GetSystemMetrics(SM_SWAPBUTTON) <> 0 then
      case Button of
        mbLeft:
          Button := mbRight;
        mbRight:
          Button := mbLeft;
      end;

  if RtcMouseControlMode=eventMouseControl then
    begin
    Post_MouseMove(FLastMouseX, FLastMouseY);
    if Button <> mbLeft then
      Post_MouseUp(Button)
    else if okToUnClick(FLastMouseX, FLastMouseY) then
      Post_MouseUp(Button);
    end
  else
    begin
    case Button of
      mbLeft: PostMouseMessage(WM_LBUTTONUP,pt.X,pt.Y);
      mbRight: PostMouseMessage(WM_RBUTTONUP,pt.X,pt.Y);
      mbMiddle: PostMouseMessage(WM_MBUTTONUP,pt.X,pt.Y);
      end;
    end;
end;

procedure TRtcScreenCapture.MouseMove(const user: String; X, Y: integer);
begin
  if RtcMouseControlMode=eventMouseControl then
    begin
    FLastMouseUser := user;
    FLastMouseX := X + FCaptureLeft;
    FLastMouseY := Y + FCaptureTop;

    Post_MouseMove(FLastMouseX, FLastMouseY);
    end;
end;

procedure TRtcScreenCapture.MouseWheel(Wheel: integer);
begin
  if RtcMouseControlMode=eventMouseControl then
    Post_MouseWheel(Wheel);
end;

procedure TRtcScreenCapture.keybdevent(key: word; Down:boolean=True; Extended: boolean=False);
var
  vk: integer;
  flags: cardinal;
begin
  vk := MapVirtualKey(key, 0);
  flags:=0;
  if not Down then flags:=flags or KEYEVENTF_KEYUP;
  if Extended then flags:=flags or KEYEVENTF_EXTENDEDKEY;
  keybd_event(key, vk, flags, 0);
end;

procedure TRtcScreenCapture.KeyDown(key: word; Shift: TShiftState);
begin
  case key of
    VK_SHIFT:
      if FShiftDown then
        Exit
      else
        FShiftDown := True;
    VK_CONTROL:
      if FCtrlDown then
        Exit
      else
        FCtrlDown := True;
    VK_MENU:
      if FAltDown then
        Exit
      else
        FAltDown := True;
  end;

  keybdevent(key, True, (Key >= $21) and (Key <= $2E));
end;

procedure TRtcScreenCapture.KeyUp(key: word; Shift: TShiftState);
begin
  case key of
    VK_SHIFT:
      if not FShiftDown then
        Exit
      else
        FShiftDown := False;
    VK_CONTROL:
      if not FCtrlDown then
        Exit
      else
        FCtrlDown := False;
    VK_MENU:
      if not FAltDown then
        Exit
      else
        FAltDown := False;
  end;

  keybdevent(key, False, (key >= $21) and (key <= $2E));
end;

procedure TRtcScreenCapture.SetKeys(capslock, lWithShift, lWithCtrl,
  lWithAlt: boolean);
begin
  if capslock then
  begin
    // turn CAPS LOCK off
    keybdevent(VK_CAPITAL);
    keybdevent(VK_CAPITAL, False);
  end;

  if lWithShift <> FShiftDown then
    keybdevent(VK_SHIFT, lWithShift);

  if lWithCtrl <> FCtrlDown then
    keybdevent(VK_CONTROL, lWithCtrl);

  if lWithAlt <> FAltDown then
    keybdevent(VK_MENU, lWithAlt);
end;

procedure TRtcScreenCapture.ResetKeys(capslock, lWithShift, lWithCtrl,
  lWithAlt: boolean);
begin
  if lWithAlt <> FAltDown then
    keybdevent(VK_MENU, FAltDown);

  if lWithCtrl <> FCtrlDown then
    keybdevent(VK_CONTROL, FCtrlDown);

  if lWithShift <> FShiftDown then
    keybdevent(VK_SHIFT, FShiftDown);

  if capslock then
  begin
    // turn CAPS LOCK on
    keybdevent(VK_CAPITAL);
    keybdevent(VK_CAPITAL, False);
  end;
end;

procedure TRtcScreenCapture.KeyPress(const AText: RtcString; AKey: word);
var
  a: integer;
  lScanCode: Smallint;
  lWithAlt, lWithCtrl, lWithShift: boolean;
  capslock: boolean;
begin
  for a := 1 to length(AText) do
  begin
{$IFDEF RTC_BYTESTRING}
    lScanCode := VkKeyScanA(AText[a]);
{$ELSE}
    lScanCode := VkKeyScanW(AText[a]);
{$ENDIF}
    if lScanCode = -1 then
    begin
      if not(AKey in [VK_MENU, VK_SHIFT, VK_CONTROL, VK_CAPITAL, VK_NUMLOCK])
      then
      begin
        keybdevent(AKey);
        keybdevent(AKey, False);
      end;
    end
    else
    begin
      lWithShift := lScanCode and $100 <> 0;
      lWithCtrl := lScanCode and $200 <> 0;
      lWithAlt := lScanCode and $400 <> 0;

      lScanCode := lScanCode and $F8FF;
      // remove Shift, Ctrl and Alt from the scan code

      capslock := GetKeyState(VK_CAPITAL) > 0;

      SetKeys(capslock, lWithShift, lWithCtrl, lWithAlt);

      keybdevent(lScanCode);
      keybdevent(lScanCode, False);

      ResetKeys(capslock, lWithShift, lWithCtrl, lWithAlt);
    end;
  end;
end;

procedure TRtcScreenCapture.KeyPressW(const AText: WideString; AKey: word);
var
  a: integer;
  lScanCode: Smallint;
  lWithAlt, lWithCtrl, lWithShift: boolean;
  capslock: boolean;
begin
  for a := 1 to length(AText) do
  begin
    lScanCode := VkKeyScanW(AText[a]);

    if lScanCode = -1 then
    begin
      if not(AKey in [VK_MENU, VK_SHIFT, VK_CONTROL, VK_CAPITAL, VK_NUMLOCK])
      then
      begin
        keybdevent(AKey);
        keybdevent(AKey, False);
      end;
    end
    else
    begin
      lWithShift := lScanCode and $100 <> 0;
      lWithCtrl := lScanCode and $200 <> 0;
      lWithAlt := lScanCode and $400 <> 0;

      lScanCode := lScanCode and $F8FF;
      // remove Shift, Ctrl and Alt from the scan code

      capslock := GetKeyState(VK_CAPITAL) > 0;

      SetKeys(capslock, lWithShift, lWithCtrl, lWithAlt);

      keybdevent(lScanCode);
      keybdevent(lScanCode, False);

      ResetKeys(capslock, lWithShift, lWithCtrl, lWithAlt);
    end;
  end;
end;

procedure TRtcScreenCapture.LWinKey(key: word);
begin
  SetKeys(False, False, False, False);
  keybdevent(VK_LWIN);
  keybdevent(key);
  keybdevent(key, False);
  keybdevent(VK_LWIN, False);
  ResetKeys(False, False, False, False);
end;

procedure TRtcScreenCapture.RWinKey(key: word);
begin
  SetKeys(False, False, False, False);
  keybdevent(VK_RWIN);
  keybdevent(key);
  keybdevent(key, False);
  keybdevent(VK_RWIN, False);
  ResetKeys(False, False, False, False);
end;

procedure TRtcScreenCapture.SpecialKey(const AKey: RtcString);
var
  capslock: boolean;
begin
  capslock := GetKeyState(VK_CAPITAL) > 0;

  if AKey = 'CAD' then
  begin
    // Ctrl+Alt+Del
    if UpperCase(Get_UserName) = 'SYSTEM' then
    begin
      XLog('Executing CtrlAltDel as SYSTEM user ...');
      SetKeys(capslock, False, False, False);
      if not Post_CtrlAltDel then
        begin
        XLog('CtrlAltDel execution failed as SYSTEM user');
        if rtcGetProcessID(AppFileName) > 0 then
          begin
          XLog('Sending CtrlAltDel request to Host Service ...');
          Write_File(ChangeFileExt(AppFileName, '.cad'), '');
          end;
        end
      else
        XLog('CtrlAltDel execution successful');
      ResetKeys(capslock, False, False, False);
    end
    else
    begin
      if rtcGetProcessID(AppFileName) > 0 then
        begin
        XLog('Sending CtrlAltDel request to Host Service ...');
        Write_File(ChangeFileExt(AppFileName, '.cad'), '');
        end
      else
        begin
        XLog('Emulating CtrlAltDel as "'+Get_UserName+'" user ...');
        SetKeys(capslock, False, True, True);
        keybdevent(VK_ESCAPE);
        keybdevent(VK_ESCAPE, False);
        ResetKeys(capslock, False, True, True);
        end;
    end;
  end
  else if AKey = 'COPY' then
  begin
    // Ctrl+C
    SetKeys(capslock, False, True, False);
    keybdevent(Ord('C'));
    keybdevent(Ord('C'), False);
    ResetKeys(capslock, False, True, False);
  end
  else if AKey = 'AT' then
  begin
    // Alt+Tab
    SetKeys(capslock, False, False, True);
    keybdevent(VK_TAB);
    keybdevent(VK_TAB, False);
    ResetKeys(capslock, False, False, True);
  end
  else if AKey = 'SAT' then
  begin
    // Shift+Alt+Tab
    SetKeys(capslock, True, False, True);
    keybdevent(VK_TAB);
    keybdevent(VK_TAB, False);
    ResetKeys(capslock, True, False, True);
  end
  else if AKey = 'CAT' then
  begin
    // Ctrl+Alt+Tab
    SetKeys(capslock, False, True, True);
    keybdevent(VK_TAB);
    keybdevent(VK_TAB, False);
    ResetKeys(capslock, False, True, True);
  end
  else if AKey = 'SCAT' then
  begin
    // Shift+Ctrl+Alt+Tab
    SetKeys(capslock, True, True, True);
    keybdevent(VK_TAB);
    keybdevent(VK_TAB, False);
    ResetKeys(capslock, True, True, True);
  end
  else if AKey = 'WIN' then
  begin
    // Windows
    SetKeys(capslock, False, False, False);
    keybdevent(VK_LWIN);
    keybdevent(VK_LWIN, False);
    ResetKeys(capslock, False, False, False);
  end
  else if AKey = 'RWIN' then
  begin
    // Windows
    SetKeys(capslock, False, False, False);
    keybdevent(VK_RWIN);
    keybdevent(VK_RWIN, False);
    ResetKeys(capslock, False, False, False);
  end
  else if AKey = 'HDESK' then
  begin
    // Hide Wallpaper
    Hide_Wallpaper;
  end
  else if AKey = 'SDESK' then
  begin
    // Show Wallpaper
    Show_Wallpaper;
  end;
end;

procedure TRtcScreenCapture.ReleaseAllKeys;
begin
  if FShiftDown then
    KeyUp(VK_SHIFT, []);
  if FAltDown then
    KeyUp(VK_MENU, []);
  if FCtrlDown then
    KeyUp(VK_CONTROL, []);
end;

procedure TRtcScreenCapture.SetMultiMon(const Value: boolean);
begin
{$IFDEF MULTIMON}
  if FMultiMon <> Value then
  begin
    if assigned(ScrIn) then
    begin
      ScrIn.Free;
      ScrIn := nil;
    end;
{$IFDEF DFMirage}
    if assigned(vd) then
    begin
      vd.Free;
      vd := nil;
    end;
{$ENDIF}
    FMultiMon := Value;
  end;
{$ENDIF}
end;

function TRtcScreenCapture.MirageDriverInstalled(Init: boolean = False)
  : boolean;
{$IFDEF DFMirage}
var
  v: TVideoDriver;
begin
  if assigned(vd) then
    Result := vd.ExistMirrorDriver
  else
  begin
    v := TVideoDriver.Create;
    try
      Result := v.ExistMirrorDriver;
      if Result and Init then
      begin
        v.ActivateMirrorDriver;
        v.DeactivateMirrorDriver;
      end;
    finally
      v.Free;
    end;
  end;
{$ELSE}

begin
  Result := False;
{$ENDIF}
end;

initialization

if not IsWinNT then
  RTC_CAPTUREBLT := 0;

end.
