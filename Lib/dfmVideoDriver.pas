{ Copyright 2004-2017 (c) RealThinClient.com (http://www.realthinclient.com)

  @exclude }

unit dfmVideoDriver;

(* ** This unit acts like and "interface" between
  RTC Host and the DemoForge Mirage Video Driver ** *)

{$INCLUDE rtcDefs.inc}
{$INCLUDE rtcPortalDefs.inc}

// Define to use the new fix for the MS RDP problem.
{.$DEFINE RTC_LBFIX}

interface

uses
  Windows, Classes, Registry, SysUtils, Forms,

  rtcCompress, rtcSystem,
  rtcInfo, rtcLog;

const
  MAX_SCREEN_WIDTH = 16384;
  MAX_SCREEN_HEIGHT = 8192;

  // Mirage driver for TightVNC feature this description String:
  VideoDriverString = 'Mirage Driver';
  VideoDriverName = 'dfmirage';
  VideoDriverRegKeyRoot =
    'SYSTEM\CurrentControlSet\Hardware Profiles\Current\System\CurrentControlSet\Services\';

  ESC_QVI_PROD_MIRAGE = 'MIRAGE';
  ESC_QVI_PROD_QUASAR = 'QUASAR';

  // Driver escapes
  MAP1 = 1030;
  UNMAP1 = 1031;
  TEST_DRIVER = 1050;
  TEST_MAPPED = 1051;
  QRY_VERINFO = 1026;

  // Misc
  MAXCHANGES_BUF = 20000;
  CLIP_LIMIT = 50;
  esc_qvi_prod_name_max = 16;
  DMF_PROTO_VER_CURRENT = $01020000;
  DMF_PROTO_VER_MINCOMPAT = $00090001;

  dmf_dfo_SCREEN_SCREEN = 11;
  dmf_dfo_BLIT = 12;
  dmf_dfo_SOLIDFILL = 13;
  dmf_dfo_BLEND = 14;
  dmf_dfo_TRANS = 15;
  dmf_dfo_PLG = 17;
  dmf_dfo_TEXTOUT = 18;

  dmf_dfo_Ptr_Engage = 48; // point is used with this record
  dmf_dfo_Ptr_Avert = 49;

  // Bitmap formats
  BMF_1BPP = 1;
  BMF_4BPP = 2;
  BMF_8BPP = 3;
  BMF_16BPP = 4;
  BMF_24BPP = 5;
  BMF_32BPP = 6;
  BMF_4RLE = 7;
  BMF_8RLE = 8;
  BMF_JPEG = 9;
  BMF_PNG = 10;

  // ChangeDisplaySettingsEx flags
  CDS_UPDATEREGISTRY = $00000001;
  CDS_TEST = $00000002;
  CDS_FULLSCREEN = $00000004;
  CDS_GLOBAL = $00000008;
  CDS_SET_PRIMARY = $00000010;
  CDS_RESET = $40000000;
  CDS_SETRECT = $20000000;
  CDS_NORESET = $10000000;

  // From WinUser.h
  ENUM_CURRENT_SETTINGS = cardinal(-1);
  ENUM_REGISTRY_SETTINGS = cardinal(-2);

type

  // *********************************************************************
  // DONT TOUCH STRUCTURES/ SHOULD BE EXACTLY THE SAME IN kernel/app/video
  // *********************************************************************

  CHANGES_RECORD = packed record
    OpType: cardinal; // screen_to_screen, blit, newcache, oldcache
    rect, origrect: TRect;
    point: TPoint;
    color: cardinal; // number used in cache array
    refcolor: cardinal; // slot used to pass bitmap data
  end;

  PCHANGES_RECORD = ^CHANGES_RECORD;

  Esc_dmf_Qvi_IN = packed record
    cbSize: cardinal;
    app_actual_version: cardinal;
    display_minreq_version: cardinal;
    connect_options: cardinal; // reserved. must be 0.
  end;

  Esc_dmf_Qvi_OUT = packed record
    cbSize: cardinal;
    display_actual_version: cardinal;
    miniport_actual_version: cardinal;
    app_minreq_version: cardinal;
    display_buildno: cardinal;
    miniport_buildno: cardinal;
    // MIRAGE
    // QUASAR
    prod_name: array [0 .. esc_qvi_prod_name_max - 1] of AnsiChar;
  end;

  CHANGES_BUF = packed record
    counter: cardinal;
    pointrect: array [0 .. MAXCHANGES_BUF - 1] of CHANGES_RECORD;
  end;

  PCHANGES_BUF = ^CHANGES_BUF;

  GETCHANGESBUF = packed record
    buffer: PCHANGES_BUF;
    userbuffer: pointer;
  end;

  PGETCHANGESBUF = ^GETCHANGESBUF;

  TDriverCallParams = record // Internal structure, do not use
    DeviceModeFlags: longint;
    DeviceName, DeviceString: ansistring;
    CDS2: boolean;
    AttachFirst: longint;
    AttachLast: longint;
    Ex: boolean;
    CheckExist: boolean;
    CheckActive: boolean;
    GetDriverDC: boolean;
    DC: HDC;
  end;

  // abstract base class for accumulator region
  TUpdateRegionBase = class(TObject)
  public
    constructor Create;
    destructor Destroy; override;
    procedure AddRect(const Rn: TRect); virtual;
    procedure StartAdd; virtual;
  end;

  TVideoDriver = class(TObject)
  private
    bufdata: GETCHANGESBUF;
    tempbuffer, tempbuffer2, tempbufferA, tempbufferB, tempbufferC, tempbufferD,
      tempbufferE, tempBufferF: RtcByteArray;
{$IFNDEF RTC_LBFIX}
    DW: HWND;
{$ENDIF}
    gdc: HDC;
    fDriverConnected: boolean;
    m_bitsPerPixel: byte;
    m_bytesPerPixel: byte;
    m_bytesPerRow: longint;
    m_ReadPtr: cardinal;

    Scr_Left, Scr_Top, Scr_Width, Scr_Height: longint;

    FLowReduce16bit, FLowReduce32bit, FReduce16bit, FReduce32bit: longword;
    FMultiMon: boolean;
    FLowReduceColors: boolean;
    FLowReduceColorPercent: integer;
    FLowReduceType: byte;

  public
    constructor Create;
    destructor Destroy; override;

    procedure Log(const s: String);

    function ActivateMirrorDriver: boolean;
    function DeactivateMirrorDriver: boolean;
    procedure MapSharedBuffers;
    procedure UnMapSharedBuffers;
    function ExistMirrorDriver: boolean;
    function IsMirrorDriverActive: boolean;
    function testdriver: boolean;
    function testmapped: boolean;

    procedure SetRegion(rect: TRect);

    function CaptureRect(const rcSrc: TRect; DstStride: longint;
      var destbuff: PAnsiChar): boolean;

    function CaptureLine(x1, x2, y: longint; DstStride: longint;
      var destbuff: PAnsiChar): boolean;

    function DeltaCompressLine(y, x1, x2: longint; DstStride: longint;
      var destbuff: PAnsiChar; var at: longint; var FirstPass: boolean)
      : RtcByteArray;
    function NormalCompressLine(y: longint; DstStride: longint;
      var destbuff: PAnsiChar; var at: longint; var FirstPass: boolean)
      : RtcByteArray;
    function OldCompressLine(y: longint; DstStride: longint;
      var destbuff: PAnsiChar; var at: longint): RtcByteArray;

    function UpdateIncremental(const DstStride: longint;
      updRgn: TUpdateRegionBase; destbuff: PAnsiChar): boolean;

    procedure FetchSeries(const first: PCHANGES_RECORD; last: PCHANGES_RECORD;
      DstStride: longint; updRgn: TUpdateRegionBase; destbuff: PAnsiChar);

    // qryverinfo is supported since version 1.1 (build 68) on
    function QryVerInfo: boolean;
    function GetMirrorDC: HDC;

    property BytesPerPixel: byte read m_bytesPerPixel;
    property BitsPerPixel: byte read m_bitsPerPixel;

  private
    function DriverCall(var dcp: TDriverCallParams): boolean;

  public
{$IFDEF RTC_LBFIX}
    gDriverName: ansistring;
{$ENDIF}
    property IsDriverActive: boolean read fDriverConnected;

    property Reduce16bit: longword read FReduce16bit write FReduce16bit;
    property Reduce32bit: longword read FReduce32bit write FReduce32bit;
    property LowReduce16bit: longword read FLowReduce16bit
      write FLowReduce16bit;
    property LowReduce32bit: longword read FLowReduce32bit
      write FLowReduce32bit;
    property LowReduceType: byte read FLowReduceType write FLowReduceType;

    property LowReduceColors: boolean read FLowReduceColors
      write FLowReduceColors;
    property LowReduceColorPercent: integer read FLowReduceColorPercent
      write FLowReduceColorPercent;

    property MultiMonitor: boolean read FMultiMon write FMultiMon;
  end;

  // From Windows.h
  DEVMODE_ = packed record
    dmDeviceName: array [0 .. CCHDEVICENAME - 1] of AnsiChar;
    dmSpecVersion: Word;
    dmDriverVersion: Word;
    dmSize: Word;
    dmDriverExtra: Word;
    dmFields: DWORD;

    { dmOrientation: SHORT;
      dmPaperSize: SHORT;
      dmPaperLength: SHORT;
      dmPaperWidth: SHORT;
      dmScale: SHORT;
      dmCopies: SHORT;
      dmDefaultSource: SHORT;
      dmPrintQuality: SHORT; }

    dmPosition: _POINTL;
    dmDisplayOrientation: DWORD;
    dmDisplayFixedOutput: DWORD;

    dmColor: SHORT;
    dmDuplex: SHORT;
    dmYResolution: SHORT;
    dmTTOption: SHORT;
    dmCollate: SHORT;
    dmFormName: array [0 .. CCHFORMNAME - 1] of AnsiChar;
    dmLogPixels: Word;
    dmBitsPerPel: DWORD;
    dmPelsWidth: DWORD;
    dmPelsHeight: DWORD;
    dmDisplayFlags: DWORD;
    dmDisplayFrequency: DWORD;
    dmICMMethod: DWORD;
    dmICMIntent: DWORD;
    dmMediaType: DWORD;
    dmDitherType: DWORD;
    dmICCManufacturer: DWORD;
    dmICCModel: DWORD;
    dmPanningWidth: DWORD;
    dmPanningHeight: DWORD;
  end;

  TLinesXX = packed record
    x1, x2: Word;
    chg: shortint;
  end;

  TGridUpdRegion = class(TUpdateRegionBase)
  private
    ScrRect: TRect;
    HaveLines, HaveLines2: boolean;
    LinesTimeStart: DWORD;
    LinesM: array [0 .. MAX_SCREEN_HEIGHT - 1] of shortint;
    LinesX: array [0 .. MAX_SCREEN_HEIGHT - 1] of TLinesXX;
    LinesX2: array [0 .. MAX_SCREEN_HEIGHT - 1] of TLinesXX;
    LinesTime: array [0 .. MAX_SCREEN_HEIGHT - 1] of DWORD;
    FTop, FBottom, FTop2, FBottom2: integer;
    FMaxSize: cardinal;
    FScanStep, FScanStep2: integer;
    ScanPass, ScanPass2: Word;
    FScan2Delay: cardinal;

    FStarted: boolean;
    FX1, FX2, FY1, FY2: integer;

  public
    constructor Create;
    destructor Destroy; override;

    procedure SetScrRect(const Value: TRect);
    procedure StartAdd; override;
    procedure AddRect(const Rn: TRect); override;
    procedure Flush;

    function CaptureRgnDelta(vd: TVideoDriver; DstStride: longint;
      ImgLine0: PAnsiChar): TRtcRecord;

    function CaptureRgnNormal(vd: TVideoDriver; DstStride: longint;
      ImgLine0: PAnsiChar): TRtcRecord;

    function CaptureRgnOld(vd: TVideoDriver; DstStride: longint;
      ImgLine0: PAnsiChar): TRtcRecord;

    property ScreenRect: TRect read ScrRect write SetScrRect;
    property ScanStep: integer read FScanStep write FScanStep;
    property ScanStep2: integer read FScanStep2 write FScanStep2;
    property Scan2Delay: cardinal read FScan2Delay write FScan2Delay;
    property MaxSize: cardinal read FMaxSize write FMaxSize;
  end;

implementation

{ TVideoDriver }

constructor TVideoDriver.Create;
begin
  inherited Create;
  SetLength(tempbuffer, MAX_SCREEN_WIDTH * 4 * 2);
  SetLength(tempbuffer2, MAX_SCREEN_WIDTH * 4 * 2);
  SetLength(tempbufferA, MAX_SCREEN_WIDTH * 4 * 2);
  SetLength(tempbufferB, MAX_SCREEN_WIDTH * 4 * 2);
  SetLength(tempbufferC, MAX_SCREEN_WIDTH * 4 * 2);
  SetLength(tempbufferD, MAX_SCREEN_WIDTH * 4 * 2);
  SetLength(tempbufferE, MAX_SCREEN_WIDTH * 4 * 2);
  SetLength(tempBufferF, MAX_SCREEN_WIDTH * 4 * 2);
  LowReduceColors := False;
  LowReduceColorPercent := 0;
  { bufdata.buffer:=nil;
    bufdata.Userbuffer:=nil;
    fDriverConnected=false;
    blocked=false; }
end;

destructor TVideoDriver.Destroy;
begin
  SetLength(tempbuffer, 0);
  SetLength(tempbuffer2, 0);
  SetLength(tempbufferA, 0);
  SetLength(tempbufferB, 0);
  SetLength(tempbufferC, 0);
  SetLength(tempbufferD, 0);
  SetLength(tempbufferE, 0);
  SetLength(tempBufferF, 0);
  UnMapSharedBuffers();
  DeactivateMirrorDriver();
  fDriverConnected := False;
  inherited Destroy;
end;

function TVideoDriver.ActivateMirrorDriver: boolean;
var
  dcp: TDriverCallParams;
begin
{$IFDEF RTC_LBFIX}
  gDriverName := 'DISPLAY';
{$ENDIF}
  FillChar(dcp, sizeof(dcp), 0);
  dcp.DeviceModeFlags := DM_BITSPERPEL + DM_ORIENTATION + DM_POSITION +
    DM_PELSWIDTH + DM_PELSHEIGHT;
  dcp.DeviceName := VideoDriverName;
  dcp.DeviceString := VideoDriverString;
  dcp.AttachFirst := 1;
  dcp.AttachLast := 1;
  dcp.Ex := true;
  Result := DriverCall(dcp);

  // ASSERT(m_bytesPerPixel);
  // ASSERT(m_bytesPerRow);

  QryVerInfo;
end;

function TVideoDriver.DeactivateMirrorDriver: boolean;
var
  dcp: TDriverCallParams;
begin
{$IFDEF RTC_LBFIX}
  gDriverName := '';
{$ENDIF}
  FillChar(dcp, sizeof(dcp), 0);
  dcp.DeviceModeFlags := DM_BITSPERPEL + DM_PELSWIDTH + DM_PELSHEIGHT +
    DM_POSITION;
  dcp.DeviceName := VideoDriverName;
  dcp.DeviceString := VideoDriverString;
  dcp.CDS2 := true;
  dcp.AttachFirst := 0;
  dcp.AttachLast := 0;
  dcp.Ex := true;
  Result := DriverCall(dcp);

  m_bytesPerPixel := 0;
  m_bytesPerRow := 0;
end;

procedure TVideoDriver.MapSharedBuffers;
begin
{$IFNDEF RTC_LBFIX}
  DW := GetDesktopWindow;
  try
    gdc := GetDC(DW);
  except
    gdc := 0;
  end;
  if (DW <> 0) and (gdc = 0) then
  begin
    DW := 0;
    try
      gdc := GetDC(DW);
    except
      gdc := 0;
    end;
    if gdc = 0 then
      raise Exception.Create('Can not lock on to Desktop Canvas');
  end;
{$ELSE}
  gdc := CreateDCA(@gDriverName[1], nil { VideoDriverName } , nil, nil);
{$ENDIF}
  if gdc <> 0 then
    fDriverConnected := ExtEscape(gdc, MAP1, 0, nil, sizeof(GETCHANGESBUF),
      @bufdata) > 0;
  // NOTE: not necessarily 0.
  // more correct way is as follows: get current bufdata.buffer->counter
  // and perform the initial full screen update
  m_ReadPtr := 0;
end;

procedure TVideoDriver.UnMapSharedBuffers;
begin
  ExtEscape(gdc, UNMAP1, sizeof(GETCHANGESBUF), @bufdata, 0, nil);
{$IFNDEF RTC_LBFIX}
  ReleaseDC(DW, gdc);
{$ELSE}
  DeleteDC(gdc);
{$ENDIF}
  fDriverConnected := False;
end;

function TVideoDriver.ExistMirrorDriver: boolean;
var
  dcp: TDriverCallParams;
begin
  Log('ExistMirrorDriver?');
  FillChar(dcp, sizeof(dcp), 0);
  dcp.DeviceModeFlags := DM_BITSPERPEL + DM_PELSWIDTH + DM_PELSHEIGHT;
  dcp.DeviceName := VideoDriverName;
  dcp.DeviceString := VideoDriverString;
  dcp.CheckExist := true;
  Result := DriverCall(dcp);
  Log('ExistMirrorDriver = ' + BoolToStr(Result, true));
end;

function TVideoDriver.IsMirrorDriverActive: boolean;
var
  dcp: TDriverCallParams;
begin
  FillChar(dcp, sizeof(dcp), 0);
  dcp.DeviceModeFlags := DM_BITSPERPEL + DM_ORIENTATION + DM_POSITION +
    DM_PELSWIDTH + DM_PELSHEIGHT;
  dcp.DeviceName := VideoDriverName;
  dcp.DeviceString := VideoDriverString;
  dcp.CheckActive := true;
  Result := DriverCall(dcp);
end;

function BYTE0(x: cardinal): byte;
begin
  Result := ((x) and $FF);
end;

function BYTE1(x: cardinal): byte;
begin
  Result := (((x) shr 8) and $FF);
end;

function BYTE2(x: cardinal): byte;
begin
  Result := (((x) shr 16) and $FF);
end;

function BYTE3(x: cardinal): byte;
begin
  Result := (((x) shr 24) and $FF);
end;

function TVideoDriver.QryVerInfo: boolean;
var
  ldw: HWND;
  ldc: HDC;
  qin: Esc_dmf_Qvi_IN;
  qout: Esc_dmf_Qvi_OUT;
begin
  Log(Format
    ('Supported driver version is: min = %u.%u.%u.%u, cur = %u.%u.%u.%u',
    [BYTE3(DMF_PROTO_VER_MINCOMPAT), BYTE2(DMF_PROTO_VER_MINCOMPAT),
    BYTE1(DMF_PROTO_VER_MINCOMPAT), BYTE0(DMF_PROTO_VER_MINCOMPAT),
    BYTE3(DMF_PROTO_VER_CURRENT), BYTE2(DMF_PROTO_VER_CURRENT),
    BYTE1(DMF_PROTO_VER_CURRENT), BYTE0(DMF_PROTO_VER_CURRENT)]));

  qin.cbSize := sizeof(qin);
  qin.app_actual_version := DMF_PROTO_VER_CURRENT;
  qin.display_minreq_version := DMF_PROTO_VER_MINCOMPAT;
  qin.connect_options := 0;
  qout.cbSize := sizeof(qout);

  ldw := GetDesktopWindow;
  try
    ldc := GetDC(ldw);
  except
    ldc := 0;
  end;
  if (ldw <> 0) and (ldc = 0) then
  begin
    ldw := 0;
    try
      ldc := GetDC(ldw);
    except
      ldc := 0;
    end;
    if ldc = 0 then
      raise Exception.Create('Can not lock on to Desktop Canvas');
  end;
  try
    Result := ExtEscape(ldc, QRY_VERINFO, sizeof(qin), @qin, sizeof(qout),
      @qout) > 0;
  finally
    ReleaseDC(ldw, ldc);
  end;

  if Result then
  begin
    Log(Format('Driver version is: display = %u.%u.%u.%u (build %u),' +
      ' miniport = %u.%u.%u.%u (build %u),' +
      ' appMinReq = %u.%u.%u.%u'#13#10'', [BYTE3(qout.display_actual_version),
      BYTE2(qout.display_actual_version), BYTE1(qout.display_actual_version),
      BYTE0(qout.display_actual_version), qout.display_buildno,
      BYTE3(qout.miniport_actual_version), BYTE2(qout.miniport_actual_version),
      BYTE1(qout.miniport_actual_version), BYTE0(qout.miniport_actual_version),
      qout.miniport_buildno, BYTE3(qout.app_minreq_version),
      BYTE2(qout.app_minreq_version), BYTE1(qout.app_minreq_version),
      BYTE0(qout.app_minreq_version)]));
  end
  else
  begin
    Log('QryVerInfo: not supported '#13#10'');
  end;
end;

function TVideoDriver.testdriver: boolean;
begin
{$IFNDEF RTC_LBFIX}
  DW := GetDesktopWindow;
  try
    gdc := GetDC(DW);
  except
    gdc := 0;
  end;
  if (DW <> 0) and (gdc = 0) then
  begin
    DW := 0;
    try
      gdc := GetDC(DW);
    except
      gdc := 0;
    end;
    if gdc = 0 then
      raise Exception.Create('Can not lock on to Desktop Canvas');
  end;
{$ELSE}
  gdc := CreateDCA(@gDriverName[1], nil { VideoDriverName } , nil, nil);
{$ENDIF}
  fDriverConnected := ExtEscape(gdc, TEST_DRIVER, 0, nil, sizeof(GETCHANGESBUF),
    @bufdata) > 0;
  Result := fDriverConnected;
  // TODO: (if not filled in)
  // m_bytesPerPixel;
  // m_bytesPerRow;
end;

function TVideoDriver.testmapped: boolean;
begin
  Result := False;
  if IsBadReadPtr(@bufdata, 1) then
    Exit;
  if bufdata.userbuffer = nil then
    Exit;
  if IsBadReadPtr(bufdata.userbuffer, 10) then
    Exit;
  Result := true;
end;

{ we probably should free the DC obtained from this function }

function TVideoDriver.GetMirrorDC: HDC;
var
  dcp: TDriverCallParams;
begin
  FillChar(dcp, sizeof(dcp), 0);
  dcp.DeviceModeFlags := DM_BITSPERPEL + DM_ORIENTATION + DM_POSITION +
    DM_PELSWIDTH + DM_PELSHEIGHT;
  dcp.DeviceName := VideoDriverName;
  dcp.DeviceString := VideoDriverString;
  dcp.GetDriverDC := true;
  if DriverCall(dcp) then
    Result := dcp.DC
  else
    Result := 0;
end;

function TVideoDriver.DriverCall(var dcp: TDriverCallParams): boolean;
var
  hdeskInput, hdeskCurrent: HDESK;
  dm: DEVMODEA;
  code: longint;
  pdm: PDEVMODE;

  dd: TDisplayDeviceA;
  devNum: longint;
  res: boolean;
  deviceNum: ansistring;
  KeyName: ansistring;
  hk: HKEY;
{$IFDEF RTC_LBFIX}
  dwVal: DWORD;
{$ENDIF RTC_LBFIX}
begin
  Result := False;

  FillChar(dm, sizeof(dm), 0);
  dm.dmSize := sizeof(dm);
  dm.dmDriverExtra := 0;

  EnumDisplaySettingsA(nil, ENUM_CURRENT_SETTINGS, dm);
  DEVMODE_(dm).dmFields := dcp.DeviceModeFlags;
{$IFDEF MULTIMON}
  if MultiMonitor then
  begin
    DEVMODE_(dm).dmPosition.x := Screen.DesktopRect.Left;
    DEVMODE_(dm).dmPosition.y := Screen.DesktopRect.Top;
    DEVMODE_(dm).dmPelsWidth := Screen.DesktopWidth;
    DEVMODE_(dm).dmPelsHeight := Screen.DesktopHeight;
  end
  else
{$ENDIF}
  begin
    DEVMODE_(dm).dmPosition.x := 0;
    DEVMODE_(dm).dmPosition.y := 0;
    DEVMODE_(dm).dmPelsWidth := Screen.Width;
    DEVMODE_(dm).dmPelsHeight := Screen.Height;
  end;

  if (dcp.AttachFirst = 0) and (dcp.AttachLast = 0) then
  begin
    DEVMODE_(dm).dmPelsWidth := 0;
    DEVMODE_(dm).dmPelsHeight := 0;
  end;

  dm.dmDeviceName[0] := #0;

  FillChar(dd, sizeof(dd), 0);
  dd.cb := sizeof(dd);
  devNum := 0;
  Log('EnumDisplayDevicesA');
  res := EnumDisplayDevicesA(nil, devNum, dd, 0);
  while res do
  begin
    Log('DisplayDeviceFound: '+String(StrPas(dd.DeviceString)));
    if strcomp(dd.DeviceString, PAnsiChar(dcp.DeviceString)) = 0 then
      break;
    inc(devNum);
    res := EnumDisplayDevicesA(nil, devNum, dd, 0);
  end;

  if dcp.CheckExist then
  begin
    Result := res;
    Exit;
  end;

  if dcp.CheckActive then
  begin
    Result := (dd.StateFlags and DISPLAY_DEVICE_ATTACHED_TO_DESKTOP) <> 0;
    Exit;
  end;

  if dcp.GetDriverDC then
  begin
    if res then
{$IFNDEF RTC_LBFIX}
      dcp.DC := CreateDCA('DISPLAY', dd.DeviceName, nil, nil);
{$ELSE}
      dcp.DC := CreateDCA(@gDriverName[1], nil { VideoDriverName } , nil, nil);
{$ENDIF}
    Result := res;
    Exit;
  end;

  if not res then
  begin
    Log(Format('No such driver found: %s', [String(dcp.DeviceString)]));
    Exit;
  end
  else
  begin

    m_bitsPerPixel := dm.dmBitsPerPel;
    m_bytesPerPixel := dm.dmBitsPerPel div 8;
    m_bytesPerRow := dm.dmPelsWidth * m_bytesPerPixel;

    Log(Format
      ('Driver call:'#13#10'  DevNum: %d'#13#10'  Name: %s'#13#10'  String: %s',
      [devNum, dd.DeviceName, dd.DeviceString]));
    Log(Format('  Screen Settings: %d %d %d', [dm.dmPelsWidth, dm.dmPelsHeight,
      dm.dmBitsPerPel]));
    Log(Format('  Screen Stride: %d', [m_bytesPerRow]));
  end;

  deviceNum := 'DEVICE0';
  { Should we modify it to point to correct devNum ?? Probably no }

  KeyName := VideoDriverRegKeyRoot + dcp.DeviceName + '\' + deviceNum;
  Log(Format('Creating key HKLM\%s', [String(KeyName)]));
  (*
    if (RegCreateKey(HKEY_LOCAL_MACHINE,
    ("SYSTEM\\CurrentControlSet\\Hardware Profiles\\Current\\System\\CurrentControlSet\\Services\\dfmirage"),
    &hKeyProfileMirror) != ERROR_SUCCESS)

  *)
  if RegCreateKeyA(HKEY_LOCAL_MACHINE, PAnsiChar(KeyName), hk) <> ERROR_SUCCESS
  then
  begin
    Log(Format('Error creating key HKLM\%s', [String(KeyName)]));
    Exit;
  end;

  try
{$IFDEF RTC_LBFIX}
    if dcp.AttachFirst = 1 then
    begin
      dwVal := 3; // Direct Access
      if (RegSetValueEx(hk, 'Cap.DfbBackingMode', 0, REG_DWORD, @dwVal, 4) <>
        ERROR_SUCCESS) then
      begin
        Log('Error setting value');
        Exit;
      end;

      dwVal := 1;
      if (RegSetValueEx(hk, 'Order.BltCopyBits.Enabled', 0, REG_DWORD, @dwVal,
        4) <> ERROR_SUCCESS) then
      begin
        Log('Error setting value');
        Exit;
      end;
    end
    else
    begin
      RegDeleteValue(hk, 'Cap.DfbBackingMode');
      RegDeleteValue(hk, 'Order.BltCopyBits.Enabled');
    end;
{$ENDIF}
    if RegSetValueEx(hk, 'Attach.ToDesktop', 0, REG_DWORD, @dcp.AttachFirst,
      sizeof(longint)) <> ERROR_SUCCESS then
    begin
      Log('Error setting value');
      Exit;
    end;

    StrPCopy(dm.dmDeviceName, dcp.DeviceName);

    hdeskCurrent := GetThreadDesktop(GetCurrentThreadId());
    if hdeskCurrent = 0 then
      Exit;

{$IFDEF RTC_LBFIX}
    hdeskInput := OpenInputDesktop(DF_ALLOWOTHERACCOUNTHOOK, False,
      DESKTOP_CREATEMENU or DESKTOP_CREATEWINDOW or DESKTOP_ENUMERATE or
      DESKTOP_HOOKCONTROL or DESKTOP_WRITEOBJECTS or DESKTOP_READOBJECTS or
      DESKTOP_SWITCHDESKTOP or GENERIC_WRITE);
{$ELSE RTC_LBFIX}
    hdeskInput := OpenInputDesktop(0, False, MAXIMUM_ALLOWED);
{$ENDIF RTC_LBFIX}
    if hdeskInput = 0 then
      Exit;
{$IFDEF ExtendLog}XLog(Format('SetThreadDesktop = %d', [hdeskInput]));
{$ENDIF}
    SetThreadDesktop(hdeskInput);

{$IFDEF RTC_LBFIX}
    // if (dm.dmBitsPerPel=24) then dm.dmBitsPerPel := 32;
{$ENDIF}
    // add 'Default.*' settings to the registry under above hKeyProfile\mirror\device
    if dcp.Ex then
      code := ChangeDisplaySettingsExA(dd.DeviceName, dm, 0,
        CDS_UPDATEREGISTRY, nil)
    else
    begin
      pdm := nil;
      code := ChangeDisplaySettings(pdm^, 0);
    end;
    Log(Format('Update register on device mode: %d', [code]));
    if dcp.CDS2 then
      ChangeDisplaySettingsExA(dd.DeviceName, dm, 0, 0, nil);

{$IFDEF RTC_LBFIX}
    gDriverName := dd.DeviceName;
{$ENDIF}
    // reset desktop
    SetThreadDesktop(hdeskCurrent);
    CloseDesktop(hdeskInput);

    if RegSetValueEx(hk, 'Attach.ToDesktop', 0, REG_DWORD, @dcp.AttachLast,
      sizeof(longint)) <> ERROR_SUCCESS then
    begin
      Log('Error setting value');
      Exit;
    end;
  finally
    RegCloseKey(hk);
  end;

  Result := true;
end;

function TVideoDriver.CaptureRect(const rcSrc: TRect; DstStride: longint;
  var destbuff: PAnsiChar): boolean;
var
  crect_re_vd_left: longint;
  crect_re_vd_top: longint;
  srcbmoffset: longint;
  dstbmoffset: longint;
  srcbuffpos: PAnsiChar;
  destbuffpos: PAnsiChar;
  widthBytes: cardinal;
  y: longint;
begin
  Result := False;

  if (fDriverConnected) then
  begin
    try
      crect_re_vd_left := rcSrc.Left;
      crect_re_vd_top := rcSrc.Top;

      srcbmoffset := (m_bytesPerRow * crect_re_vd_top) +
        (m_bytesPerPixel * crect_re_vd_left);
      dstbmoffset := (DstStride * crect_re_vd_top) +
        (m_bytesPerPixel * crect_re_vd_left);

      destbuffpos := destbuff + dstbmoffset;
      srcbuffpos := PAnsiChar(bufdata.userbuffer) + srcbmoffset;

      widthBytes := (rcSrc.right - rcSrc.Left) * m_bytesPerPixel;

      for y := rcSrc.Top to rcSrc.bottom - 1 do
      begin
        Move(srcbuffpos^, destbuffpos^, widthBytes);
        srcbuffpos := srcbuffpos + m_bytesPerRow;
        destbuffpos := destbuffpos + DstStride;
      end;

      Result := true;
    except
      on E: Exception do
      begin
        Log(Format('TVideoDriver.CaptureDirect -> "%s: %s"',
          [E.ClassName, E.Message]));
      end;
    end;
  end;
end;

function TVideoDriver.CaptureLine(x1, x2, y: longint; DstStride: longint;
  var destbuff: PAnsiChar): boolean;
var
  srcbmoffset: longint;
  dstbmoffset: longint;
  srcbuffpos: PAnsiChar;
  destbuffpos: PAnsiChar;
  widthBytes: cardinal;
begin
  Result := False;

  if (fDriverConnected) then
  begin
    try
      srcbmoffset := (m_bytesPerRow * y) + (m_bytesPerPixel * x1);
      dstbmoffset := (DstStride * y) + (m_bytesPerPixel * x1);

      destbuffpos := destbuff + dstbmoffset;
      srcbuffpos := PAnsiChar(bufdata.userbuffer) + srcbmoffset;

      widthBytes := (x2 - x1) * m_bytesPerPixel;

      Move(srcbuffpos^, destbuffpos^, widthBytes);

      Result := true;
    except
      on E: Exception do
      begin
        Log(Format('TVideoDriver.CaptureDirect: "%s: %s"',
          [E.ClassName, E.Message]));
      end;
    end;
  end;
end;

function TVideoDriver.DeltaCompressLine(y, x1, x2: longint; DstStride: longint;
  var destbuff: PAnsiChar; var at: longint; var FirstPass: boolean)
  : RtcByteArray;
var
  srcbmoffset: longint;
  dstbmoffset: longint;
  srcbuffpos: PAnsiChar;
  destbuffpos: PAnsiChar;
  widthBytes: Word;
  len: Word;
  Reduce_Colors, Reduce_Colors2: longword;

begin
  SetLength(Result, 0);

  if (fDriverConnected) then
  begin
    try
      srcbmoffset := (m_bytesPerRow * (y + Scr_Top)) +
        (m_bytesPerPixel * (Scr_Left + x1));
      dstbmoffset := (DstStride * y) + (m_bytesPerPixel * x1);

      destbuffpos := destbuff + dstbmoffset;
      srcbuffpos := PAnsiChar(bufdata.userbuffer) + srcbmoffset;

      widthBytes := (x2 - x1) * m_bytesPerPixel;

      at := dstbmoffset;

      Reduce_Colors := 0;
      Reduce_Colors2 := 0;
      if LowReduceColors and FirstPass then
      begin
        if FLowReduceType = 0 then
        begin
          case m_bytesPerPixel of
            4:
              if FLowReduce32bit <> 0 then
                Reduce_Colors := FLowReduce32bit;
            2:
              if FLowReduce16bit <> 0 then
                Reduce_Colors := FLowReduce16bit;
          end;
        end
        else
        begin
          case m_bytesPerPixel of
            4:
              if FLowReduce32bit <> 0 then
                Reduce_Colors2 := FLowReduce32bit;
            2:
              if FLowReduce16bit <> 0 then
                Reduce_Colors2 := FLowReduce16bit;
          end;
        end;
      end
      else
        FirstPass := False;

      Move(srcbuffpos^, tempbuffer[0], widthBytes);
      case m_bytesPerPixel of
        4:
          if FReduce32bit <> 0 then
            DWord_ReduceColors(Addr(tempbuffer[0]), widthBytes, FReduce32bit);
        2:
          if FReduce16bit <> 0 then
            DWord_ReduceColors(Addr(tempbuffer[0]), widthBytes, FReduce16bit);
      end;

      len := WordCompress_Delta_New(destbuffpos, Addr(tempbuffer[0]),
        Addr(tempbuffer2[0]), Addr(tempbufferA[0]), Addr(tempbufferB[0]),
        Addr(tempbufferC[0]), Addr(tempbufferD[0]), Addr(tempbufferE[0]),
        Addr(tempBufferF[0]), Reduce_Colors, Reduce_Colors2, FirstPass,
        LowReduceColorPercent, widthBytes, true);
      if len > 0 then
      begin
        SetLength(Result, len);
        Move(tempbuffer2[0], Result[0], len);
      end;
    except
      on E: Exception do
        Log(Format('TVideoDriver.CaptureDirect: "%s: %s"',
          [E.ClassName, E.Message]));
    end;
  end;
end;

function TVideoDriver.NormalCompressLine(y: longint; DstStride: longint;
  var destbuff: PAnsiChar; var at: longint; var FirstPass: boolean)
  : RtcByteArray;
var
  srcbmoffset: longint;
  dstbmoffset: longint;
  srcbuffpos: PAnsiChar;
  destbuffpos: PAnsiChar;
  widthBytes: Word;
  len: Word;
  Reduce_Colors, Reduce_Colors2: longword;

begin
  SetLength(Result, 0);

  if (fDriverConnected) then
  begin
    try
      srcbmoffset := (m_bytesPerRow * (y + Scr_Top)) +
        (m_bytesPerPixel * Scr_Left);
      dstbmoffset := DstStride * y;

      destbuffpos := destbuff + dstbmoffset;
      srcbuffpos := PAnsiChar(bufdata.userbuffer) + srcbmoffset;

      widthBytes := Scr_Width * m_bytesPerPixel;

      at := dstbmoffset;

      Reduce_Colors := 0;
      Reduce_Colors2 := 0;
      if LowReduceColors and FirstPass then
      begin
        if FLowReduceType = 0 then
        begin
          case m_bytesPerPixel of
            4:
              if FLowReduce32bit <> 0 then
                Reduce_Colors := FLowReduce32bit;
            2:
              if FLowReduce16bit <> 0 then
                Reduce_Colors := FLowReduce16bit;
          end;
        end
        else
        begin
          case m_bytesPerPixel of
            4:
              if FLowReduce32bit <> 0 then
                Reduce_Colors2 := FLowReduce32bit;
            2:
              if FLowReduce16bit <> 0 then
                Reduce_Colors2 := FLowReduce16bit;
          end;
        end;
      end
      else
        FirstPass := False;

      Move(srcbuffpos^, tempbuffer[0], widthBytes);
      case m_bytesPerPixel of
        4:
          if FReduce32bit <> 0 then
            DWord_ReduceColors(Addr(tempbuffer[0]), widthBytes, FReduce32bit);
        2:
          if FReduce16bit <> 0 then
            DWord_ReduceColors(Addr(tempbuffer[0]), widthBytes, FReduce16bit);
      end;

      len := WordCompress_Normal_New(destbuffpos, Addr(tempbuffer[0]),
        Addr(tempbuffer2[0]), Addr(tempbufferA[0]), Addr(tempbufferB[0]),
        Addr(tempbufferC[0]), Addr(tempbufferD[0]), Addr(tempbufferE[0]),
        Reduce_Colors, Reduce_Colors2, FirstPass, LowReduceColorPercent,
        widthBytes, true);
      if len > 0 then
      begin
        SetLength(Result, len);
        Move(tempbuffer2[0], Result[0], len);
      end;
    except
      on E: Exception do
      begin
        Log(Format('TVideoDriver.CaptureDirect: "%s: %s"',
          [E.ClassName, E.Message]));
      end;
    end;
  end;
end;

function TVideoDriver.OldCompressLine(y: longint; DstStride: longint;
  var destbuff: PAnsiChar; var at: longint): RtcByteArray;
var
  dstbmoffset: longint;
  destbuffpos: PAnsiChar;
  widthBytes: Word;
  len: Word;
  FirstPass: boolean;
begin
  SetLength(Result, 0);

  if (fDriverConnected) then
  begin
    try
      dstbmoffset := DstStride * y;
      destbuffpos := destbuff + dstbmoffset;

      widthBytes := Scr_Width * m_bytesPerPixel;

      at := dstbmoffset;

      FirstPass := False;
      len := WordCompress_Normal_New(destbuffpos, destbuffpos,
        Addr(tempbuffer2[0]), Addr(tempbufferA[0]), Addr(tempbufferB[0]),
        Addr(tempbufferC[0]), Addr(tempbufferD[0]), Addr(tempbufferE[0]), 0, 0,
        FirstPass, 0, widthBytes, False);

      SetLength(Result, len);
      Move(tempbuffer2[0], Result[0], len);
    except
      on E: Exception do
      begin
        Log(Format('TVideoDriver.CaptureDirect: "%s: %s"',
          [E.ClassName, E.Message]));
      end;
    end;
  end;
end;

function TVideoDriver.UpdateIncremental(const DstStride: longint;
  updRgn: TUpdateRegionBase; destbuff: PAnsiChar): boolean;
var
  snapshot_counter: cardinal;
begin
  Result := False;

  if (fDriverConnected) then
  begin
    try
      snapshot_counter := bufdata.buffer^.counter;

      if (m_ReadPtr <> snapshot_counter) then
      begin

        if (m_ReadPtr < snapshot_counter) then
        begin
          FetchSeries(@(bufdata.buffer^.pointrect[m_ReadPtr]),
            @(bufdata.buffer^.pointrect[snapshot_counter]), DstStride, updRgn,
            destbuff);
        end
        else
        begin
          FetchSeries(@(bufdata.buffer^.pointrect[m_ReadPtr]),
            @(bufdata.buffer^.pointrect[MAXCHANGES_BUF-1]), DstStride, updRgn, destbuff);

          FetchSeries(@(bufdata.buffer^.pointrect[0]),
            @(bufdata.buffer^.pointrect[snapshot_counter]), DstStride, updRgn,
            destbuff);
        end;

        m_ReadPtr := snapshot_counter;
      end;

      Result := true;
    except
      on E: Exception do
      begin
        Log(Format('TVideoDriver.UpdateIncrementalSimple: "%s: %s"',
          [E.ClassName, E.Message]));
      end;
    end;
  end;
end;

procedure TVideoDriver.FetchSeries(const first: PCHANGES_RECORD;
  last: PCHANGES_RECORD; DstStride: longint; updRgn: TUpdateRegionBase;
  destbuff: PAnsiChar);
var
  i: PCHANGES_RECORD;
begin
  i := first;
  while PAnsiChar(i) < PAnsiChar(last) do
  begin
    if (i^.OpType in [dmf_dfo_SCREEN_SCREEN .. dmf_dfo_TEXTOUT]) then
      updRgn.AddRect(i^.rect);
    // i := i + 1;

    i := PCHANGES_RECORD(PAnsiChar(pointer(i)) + sizeof(CHANGES_RECORD));
  end;
end;

constructor TUpdateRegionBase.Create;
begin
  inherited Create;
end;

destructor TUpdateRegionBase.Destroy;
begin
  inherited Destroy;
end;

procedure TUpdateRegionBase.AddRect(const Rn: TRect);
begin
end;

procedure TUpdateRegionBase.StartAdd;
begin
end;

procedure TVideoDriver.Log(const s: String);
begin
{$IFDEF LogMirrorDriver}
  rtcLog.Log(s, 'Screen');
{$ENDIF}
end;

constructor TGridUpdRegion.Create;
begin
  inherited Create;
  Flush;
end;

destructor TGridUpdRegion.Destroy;
begin
  inherited Destroy;
end;

procedure TGridUpdRegion.AddRect(const Rn: TRect);
var
  x1, x2, y1, y2: integer;
  ptrNow: ^byte;
begin
  with ScrRect do
  begin
    if (Rn.right < Left) or (Rn.Left > right) or (Rn.bottom < Top) or
      (Rn.Top > bottom) then
      Exit;

    if Rn.Top <= Top then
      y1 := 0
    else
      y1 := Rn.Top - Top;
    if Rn.bottom > bottom then
      y2 := bottom - Top
    else
      y2 := Rn.bottom - Top;

    if y1 < y2 then
    begin
      if Rn.Left <= Left then
        x1 := 0
      else
        x1 := ((Rn.Left - Left) shr 2) shl 2;
      if Rn.right > right then
        x2 := ((right - Left + 3) shr 2) shl 2
      else
        x2 := ((Rn.right - Left + 3) shr 2) shl 2;

      if x1 < x2 then
      begin
        if not HaveLines then
        begin
          ScanPass := 0;
          HaveLines := true;
          FTop := y1;
          FBottom := y2;
        end
        else
        begin
          if FTop > y1 then
            FTop := y1;
          if FBottom < y2 then
            FBottom := y2;
        end;

        if not FStarted then
        begin
          FX1 := x1;
          FX2 := x2;
          FY1 := y1;
          FY2 := y2;
          FStarted := true;
        end
        else if (x1 < FX1) or (x2 > FX2) or (y1 < FY1) or (y2 > FY2) then
        begin
          FX1 := x1;
          FX2 := x2;
          FY1 := y1;
          FY2 := y2;
        end
        else
          Exit;

        ptrNow := @LinesX[y1];
{$IFDEF CPUX64}
{$ELSE}
        asm
          push EAX
          push EDX
          push EDI
          push ECX

          cld

          mov  EAX, x1
          mov  EDX, x2
          mov  ECX, y2
          sub  ECX, y1
          mov  EDI, ptrNow

        @fill:
          cmp word[EDI+2], 0
          je @set // "X2" = 0? initialize X1 and X2

          cmp word[EDI], AX
          jbe @x1ok         // "X1" <= x1 ? no need to update
          mov word[EDI], AX // set "X1"

        @x1ok:
          cmp word[EDI+2], DX
          jae @x2ok // "X2" >= x2? no need to update
          mov word[EDI+2], DX

        @x2ok:
          mov byte[EDI+4], 1 // mark "changed"
          add EDI,5
          loop @fill     // loop
          jmp @finishing // done

        @set: // set x1 and x2
          mov word[EDI], AX
          mov word[EDI+2], DX
          mov byte[EDI+4], 1 // mark "changed"
          add EDI,5
          loop @fill

        @finishing:
          pop ECX
          pop EDI
          pop EDX
          pop EAX
        end;
{$ENDIF}
        // FillChar(LinesY[y1], y2-y1, 1);
      end;
    end;
  end;
end;

procedure TGridUpdRegion.Flush;
begin
  HaveLines := False;
  HaveLines2 := False;
  FStarted := False;
  FillChar(LinesM, sizeof(LinesM), 0);
  FillChar(LinesX, sizeof(LinesX), 0);
  FillChar(LinesX2, sizeof(LinesX2), 0);
  ScanStep := 1;
  ScanStep2 := 1;
  Scan2Delay := 0;
  ScanPass := 0;
  ScanPass2 := 0;
  MaxSize := 0;
end;

procedure TGridUpdRegion.SetScrRect(const Value: TRect);
begin
  ScrRect := Value;
end;

function TGridUpdRegion.CaptureRgnDelta(vd: TVideoDriver; DstStride: longint;
  ImgLine0: PAnsiChar): TRtcRecord;
var
  FirstLines, SecondLines, SecondSkip, ThirdLines, i: longint;
  img: RtcByteArray;
  at, loc: longint;

  Imgs: TRtcArray;
  Locs: TRtcArray;
  TotalSize: cardinal;
  FScanPass: integer;
  MaySkip, frst: boolean;
  NowTime: DWORD;

  procedure SkipScanPass(Step: integer);
  begin
    case Step of
      2:
        case FScanPass of
          0:
            FScanPass := 1;
          1:
            FScanPass := 0;
        end;
      3:
        case FScanPass of
          0:
            FScanPass := 1;
          1:
            FScanPass := 2;
          2:
            FScanPass := 0;
        end;
      4:
        case FScanPass of
          0:
            FScanPass := 2;
          1:
            FScanPass := 3;
          2:
            FScanPass := 1;
          3:
            FScanPass := 0;
        end;
      5:
        case FScanPass of
          0:
            FScanPass := 2;
          1:
            FScanPass := 3;
          2:
            FScanPass := 4;
          3:
            FScanPass := 0;
          4:
            FScanPass := 1;
        end;
      6:
        case FScanPass of
          0:
            FScanPass := 3;
          1:
            FScanPass := 4;
          2:
            FScanPass := 0;
          3:
            FScanPass := 5;
          4:
            FScanPass := 2;
          5:
            FScanPass := 1;
        end;
      7:
        case FScanPass of
          0:
            FScanPass := 3;
          1:
            FScanPass := 6;
          2:
            FScanPass := 4;
          3:
            FScanPass := 5;
          4:
            FScanPass := 0;
          5:
            FScanPass := 1;
          6:
            FScanPass := 2;
        end;
      8:
        case FScanPass of
          0:
            FScanPass := 4;
          1:
            FScanPass := 5;
          2:
            FScanPass := 7;
          3:
            FScanPass := 1;
          4:
            FScanPass := 6;
          5:
            FScanPass := 0;
          6:
            FScanPass := 2;
          7:
            FScanPass := 3;
        end;
      9:
        case FScanPass of
          0:
            FScanPass := 4;
          1:
            FScanPass := 5;
          2:
            FScanPass := 8;
          3:
            FScanPass := 7;
          4:
            FScanPass := 6;
          5:
            FScanPass := 3;
          6:
            FScanPass := 2;
          7:
            FScanPass := 0;
          8:
            FScanPass := 1;
        end;
      10:
        case FScanPass of
          0:
            FScanPass := 5;
          1:
            FScanPass := 6;
          2:
            FScanPass := 7;
          3:
            FScanPass := 8;
          4:
            FScanPass := 1;
          5:
            FScanPass := 2;
          6:
            FScanPass := 3;
          7:
            FScanPass := 9;
          8:
            FScanPass := 0;
          9:
            FScanPass := 4;
        end;
      11:
        case FScanPass of
          0:
            FScanPass := 5;
          1:
            FScanPass := 6;
          2:
            FScanPass := 10;
          3:
            FScanPass := 9;
          4:
            FScanPass := 7;
          5:
            FScanPass := 8;
          6:
            FScanPass := 3;
          7:
            FScanPass := 1;
          8:
            FScanPass := 2;
          9:
            FScanPass := 0;
          10:
            FScanPass := 4;
        end;
      12:
        case FScanPass of
          0:
            FScanPass := 6;
          1:
            FScanPass := 10;
          2:
            FScanPass := 7;
          3:
            FScanPass := 11;
          4:
            FScanPass := 0;
          5:
            FScanPass := 8;
          6:
            FScanPass := 9;
          7:
            FScanPass := 1;
          8:
            FScanPass := 2;
          9:
            FScanPass := 3;
          10:
            FScanPass := 4;
          11:
            FScanPass := 5;
        end;
    end;
  end;

begin
  img := nil;
  Result := nil;
  Imgs := nil;
  Locs := nil;
  loc := 0;

  TotalSize := 0;

  FirstLines := 0;
  SecondLines := 0;
  ThirdLines := 0;

  if HaveLines2 then
  begin
    for i := FTop2 to FBottom2 - 1 do
      if LinesX2[i].x2 > 0 then
        if LinesX[i].chg > 0 then
        begin // primary changed, compare
          LinesX[i].chg := 0;
          if (LinesX2[i].x1 >= LinesX[i].x2) or (LinesX2[i].x2 <= LinesX[i].x1)
          then // not touching primary scan region
          begin
            LinesX2[i].chg := 1; // outside of primary image, normal draw
            inc(SecondLines);
          end
          else if (LinesX2[i].x1 < LinesX[i].x1) or
            (LinesX2[i].x2 > LinesX[i].x2) then
          // at left and/or right side of primary
          begin
            LinesX2[i].chg := 2; // draw left or right side
            inc(SecondLines);
          end
          else // same as primary or inside primary, wait for primary refine
          begin
            LinesX2[i].x1 := 0;
            LinesX2[i].x2 := 0;
            LinesX2[i].chg := 0;
          end;
        end
        else if LinesX2[i].chg > 0 then // ready
          inc(SecondLines);
  end;

  if HaveLines then
  begin
    for i := FTop to FBottom - 1 do
      if LinesX[i].x2 > 0 then
        inc(FirstLines);

    FScanPass := ScanPass;
    // Process only new lines in the 1st pass ...
    while (FirstLines > 0) and (TotalSize <= MaxSize) do
    begin
      i := FTop + FScanPass;
      while i < FBottom do
      begin
        if LinesX[i].x2 > 0 then
        begin
          frst := true;
          img := vd.DeltaCompressLine(i, LinesX[i].x1, LinesX[i].x2, DstStride,
            ImgLine0, at, frst);
          if length(img) > 0 then
          begin
            if not assigned(Result) then
            begin
              Result := TRtcRecord.Create;
              Imgs := Result.newArray('di');
              Locs := Result.newArray('at');
            end;
            inc(TotalSize, length(img));
            Imgs.asString[loc] := RtcBytesToString(img);
            Locs.asInteger[loc] := at;
            inc(loc);
          end;
          if frst then
          begin
            LinesM[i] := 1; // need refine
            inc(ThirdLines);
          end
          else
          begin
            LinesX[i].x1 := 0;
            LinesX[i].x2 := 0;
            LinesX[i].chg := 0;
          end;
          Dec(FirstLines);
          if FirstLines = 0 then
            break;
        end;
        inc(i, ScanStep);
      end;
      SkipScanPass(ScanStep);
    end;
    ScanPass := FScanPass;
  end;

  if HaveLines2 then
  begin
    MaySkip := true;

    if (ThirdLines > 0) or HaveLines then
      NowTime := GetTickCount - FScan2Delay * 2 // more refining waiting
    else
      NowTime := GetTickCount - FScan2Delay; // no more data

    if (LinesTimeStart >= NowTime) or ((MaxSize > 0) and (TotalSize > MaxSize))
    then
      SecondSkip := 1
    else
    begin
      if MaxSize = 0 then
        TotalSize := 0;

      SecondSkip := 0;
      FScanPass := ScanPass2;
      while (SecondLines > 0) and (TotalSize <= MaxSize) do
      begin
        i := FTop2 + FScanPass;
        while i < FBottom2 do
        begin
          if LinesX2[i].chg > 0 then
            if LinesTime[i] < NowTime then
            begin
              case LinesX2[i].chg of
                1: // normal draw
                  begin
                    frst := False;
                    img := vd.DeltaCompressLine(i, LinesX2[i].x1, LinesX2[i].x2,
                      DstStride, ImgLine0, at, frst);
                    if length(img) > 0 then
                    begin
                      if not assigned(Result) then
                      begin
                        Result := TRtcRecord.Create;
                        Imgs := Result.newArray('di');
                        Locs := Result.newArray('at');
                      end;
                      Imgs.asString[loc] := RtcBytesToString(img);
                      Locs.asInteger[loc] := at;
                      inc(loc);
                      inc(TotalSize, length(img));
                    end;
                    LinesX2[i].x1 := 0;
                    LinesX2[i].x2 := 0;
                    LinesX2[i].chg := 0;

                    Dec(SecondLines);
                    if SecondLines = 0 then
                    begin
                      MaySkip := False;
                      break;
                    end
                    else if (MaxSize > 0) and (TotalSize > MaxSize) then
                    begin
                      MaySkip := False;
                      break;
                    end;
                  end;
                2: // attached to the left and/or right side of primary
                  begin
                    frst := False;
                    if LinesX2[i].x1 < LinesX[i].x1 then
                    begin
                      img := vd.DeltaCompressLine(i, LinesX2[i].x1,
                        LinesX[i].x1, DstStride, ImgLine0, at, frst);
                      if length(img) > 0 then
                      begin
                        if not assigned(Result) then
                        begin
                          Result := TRtcRecord.Create;
                          Imgs := Result.newArray('di');
                          Locs := Result.newArray('at');
                        end;
                        Imgs.asString[loc] := RtcBytesToString(img);
                        Locs.asInteger[loc] := at;
                        inc(loc);
                        inc(TotalSize, length(img));
                      end;
                    end;
                    if LinesX2[i].x2 > LinesX[i].x2 then
                    begin
                      img := vd.DeltaCompressLine(i, LinesX[i].x2,
                        LinesX2[i].x2, DstStride, ImgLine0, at, frst);
                      if length(img) > 0 then
                      begin
                        if not assigned(Result) then
                        begin
                          Result := TRtcRecord.Create;
                          Imgs := Result.newArray('di');
                          Locs := Result.newArray('at');
                        end;
                        Imgs.asString[loc] := RtcBytesToString(img);
                        Locs.asInteger[loc] := at;
                        inc(loc);
                        inc(TotalSize, length(img));
                      end;
                    end;
                    LinesX2[i].x1 := 0;
                    LinesX2[i].x2 := 0;
                    LinesX2[i].chg := 0;
                    // if there is more, it will be handled in 2nd pass

                    Dec(SecondLines);
                    if SecondLines = 0 then
                    begin
                      MaySkip := False;
                      break;
                    end
                    else if (MaxSize > 0) and (TotalSize > MaxSize) then
                    begin
                      MaySkip := False;
                      break;
                    end;
                  end;
              end;
            end
            else
            begin
              // need to wait for the time to pass
              Dec(SecondLines);
              inc(SecondSkip);
              if SecondLines = 0 then
              begin
                MaySkip := False;
                break;
              end;
            end;
          inc(i, ScanStep2);
        end;
        if MaySkip then
          SkipScanPass(ScanStep2);
      end;
      ScanPass2 := FScanPass;
    end;
    inc(SecondLines, SecondSkip);
  end;

  HaveLines := FirstLines > 0;
  HaveLines2 := SecondLines > 0;

  if ThirdLines > 0 then
  begin
    NowTime := GetTickCount;

    if not HaveLines2 then
    begin
      HaveLines2 := true;
      LinesTimeStart := NowTime;
      ScanPass2 := 0;
      FTop2 := FTop;
      FBottom2 := FBottom;
    end
    else
    begin
      if FTop < FTop2 then
        FTop2 := FTop;
      if FBottom > FBottom2 then
        FBottom2 := FBottom;
    end;

    for i := FTop to FBottom - 1 do
      if LinesM[i] > 0 then
      begin
        if LinesX2[i].x2 = 0 then
        begin
          LinesTime[i] := NowTime; // last one
          LinesX2[i].x1 := LinesX[i].x1;
          LinesX2[i].x2 := LinesX[i].x2;
        end
        else
        begin
          if LinesX2[i].chg = 0 then // refining again (animated space)
            LinesTime[i] := NowTime;
          if LinesX2[i].x1 > LinesX[i].x1 then
            LinesX2[i].x1 := LinesX[i].x1;
          if LinesX2[i].x2 < LinesX[i].x2 then
            LinesX2[i].x2 := LinesX[i].x2;
        end;
        LinesX2[i].chg := 1;
        LinesX[i].x1 := 0;
        LinesX[i].x2 := 0;
        LinesX[i].chg := 0;
        LinesM[i] := 0;
      end;

  end;
end;

function TGridUpdRegion.CaptureRgnNormal(vd: TVideoDriver; DstStride: longint;
  ImgLine0: PAnsiChar): TRtcRecord;
var
  i: longint;
  img: RtcByteArray;
  at, loc: longint;
  Imgs: TRtcArray;
  Locs: TRtcArray;
  Skipped, frst: boolean;
  NowTime: DWORD;
begin
  img := nil;
  Result := nil;
  Imgs := nil;
  Locs := nil;
  if HaveLines then
  begin
    NowTime := GetTickCount;
    Skipped := False;
    loc := 0;
    for i := FTop to FBottom - 1 do
      if LinesX[i].x2 > 0 then
      begin
        frst := true;
        img := vd.NormalCompressLine(i, DstStride, ImgLine0, at, frst);
        if length(img) > 0 then
        begin
          if not assigned(Result) then
          begin
            Result := TRtcRecord.Create;
            Imgs := Result.newArray('pu');
            Locs := Result.newArray('at');
          end;
          Imgs.asString[loc] := RtcBytesToString(img);
          Locs.asInteger[loc] := at;
          inc(loc);
          if frst then
          begin
            Skipped := true;
            if LinesX2[i].x2 = 0 then
            begin
              LinesTime[i] := NowTime;
              LinesX2[i].x1 := LinesX[i].x1;
              LinesX2[i].x2 := LinesX[i].x2;
            end
            else
            begin
              if LinesX2[i].chg = 0 then
                LinesTime[i] := NowTime;
              if LinesX2[i].x1 > LinesX[i].x1 then
                LinesX2[i].x1 := LinesX[i].x1;
              if LinesX2[i].x2 < LinesX[i].x2 then
                LinesX2[i].x2 := LinesX[i].x2;
            end;
            LinesX2[i].chg := 1;
          end;
        end;
        LinesX[i].x1 := 0;
        LinesX[i].x2 := 0;
        LinesX[i].chg := 0;
      end;

    HaveLines := False;
    if Skipped then
    begin
      if not HaveLines2 then
      begin
        LinesTimeStart := NowTime;
        ScanPass2 := 0;
        HaveLines2 := true;
        FTop2 := FTop;
        FBottom2 := FBottom;
      end
      else
      begin
        if FTop < FTop2 then
          FTop2 := FTop;
        if FBottom > FBottom2 then
          FBottom2 := FBottom;
      end;
    end
    else
      HaveLines2 := False;
  end;
end;

function TGridUpdRegion.CaptureRgnOld(vd: TVideoDriver; DstStride: longint;
  ImgLine0: PAnsiChar): TRtcRecord;
var
  i: longint;
  img: RtcByteArray;
  at, loc: longint;

  Imgs: TRtcArray;
  Locs: TRtcArray;
begin
  img := nil;
  Result := nil;
  Imgs := nil;
  Locs := nil;
  if HaveLines then
  begin
    loc := 0;
    for i := FTop to FBottom - 1 do
      if LinesX[i].x2 > 0 then
      begin
        img := vd.OldCompressLine(i, DstStride, ImgLine0, at);
        if length(img) > 0 then
        begin
          if not assigned(Result) then
          begin
            Result := TRtcRecord.Create;
            Imgs := Result.newArray('pu');
            Locs := Result.newArray('at');
          end;
          Imgs.asString[loc] := RtcBytesToString(img);
          Locs.asInteger[loc] := at;
          inc(loc);
        end;
      end;
  end;
end;

procedure TGridUpdRegion.StartAdd;
begin
  FStarted := False;
end;

procedure TVideoDriver.SetRegion(rect: TRect);
begin
  Scr_Left := rect.Left;
  Scr_Top := rect.Top;
  Scr_Width := rect.right - rect.Left;
  Scr_Height := rect.bottom - rect.Top;
end;

end.
