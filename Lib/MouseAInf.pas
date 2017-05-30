{ Copyright 2004-2017 (c) RealThinClient.com (http://www.realthinclient.com)

  @exclude }

unit MouseAInf;

interface

{$INCLUDE rtcPortalDefs.inc}
{$INCLUDE rtcDefs.inc}

uses
  Windows;

type
  TMouseMoveFlags = (mfMOUSE_MOVE_RELATIVE, mfMOUSE_MOVE_ABSOLUTE);

  TMouseButtonFlags = (bfMOUSE_BUTTON_NONE, bfMOUSE_LEFT_BUTTON_DOWN,
    bfMOUSE_LEFT_BUTTON_UP, bfMOUSE_RIGHT_BUTTON_DOWN = $0004,
    bfMOUSE_RIGHT_BUTTON_UP = $0008, bfMOUSE_MIDDLE_BUTTON_DOWN = $0010,
    bfMOUSE_MIDDLE_BUTTON_UP = $0020, bfMOUSE_WHEEL = $0400);

  TMouseWheelMoveFlags = (wdMOUSE_WHEEL_MOVE_DOWN = $0078,
    wdMOUSE_WHEEL_MOVE_UP = $FF88);

  {
    Helper Function
  }

  TMouseAInitFunc = function: Boolean; cdecl;
  TMouseAImitation = function(MoveFlags: TMouseMoveFlags;
    ButtonFlags: TMouseButtonFlags; X, Y: LongInt): Boolean; cdecl;

function MouseAImitationWheelMove(WheelMoveFlag: TMouseWheelMoveFlags)
  : Boolean; forward;
function MouseAImitationWheelDown: Boolean; forward;
function MouseAImitationWheelUp: Boolean; forward;

function MouseAImitationMove(MoveFlags: TMouseMoveFlags; X, Y: LongInt)
  : Boolean; overload; forward;
function MouseAImitationMove(MoveFlags: TMouseMoveFlags; XY: TPoint): Boolean;
  overload; forward;
function MouseAImitationLButtonDown: Boolean; forward;
function MouseAImitationLButtonUp: Boolean; forward;
function MouseAImitationRButtonDown: Boolean; forward;
function MouseAImitationRButtonUp: Boolean; forward;

function MouseAInit: Boolean;
function MouseAUnInit: Boolean;

function MouseXYToScreen(const Point: TPoint): TPoint; forward;

var
  MouseInit: TMouseAInitFunc;
  MouseUnInit: TMouseAInitFunc;
  MouseAImitation: TMouseAImitation;

implementation

uses
  Forms;

var
  DLLHandle: THandle;

function MouseAInit: Boolean;
begin
  if DLLHandle = 0 then
  begin
    DLLHandle := LoadLibrary('MouseA.dll');
    If (DLLHandle <> 0) Then
    Begin
      MouseInit := GetProcAddress(DLLHandle, 'MouseAInit');
      MouseUnInit := GetProcAddress(DLLHandle, 'MouseAUnInit');
      MouseAImitation := GetProcAddress(DLLHandle, 'MouseAImitation');

      Result := MouseInit;
    End
    else
      Result := False;
  end
  else
    Result := True;
end;

function MouseAUnInit: Boolean;
begin
  if DLLHandle <> 0 then
  begin
    Result := MouseUnInit;
    FreeLibrary(DLLHandle);
    DLLHandle := 0;
  end
  else
    Result := True;
end;

function MouseAImitationWheelMove(WheelMoveFlag: TMouseWheelMoveFlags): Boolean;
begin
  Result := MouseAInf.MouseAImitation(mfMOUSE_MOVE_RELATIVE, bfMOUSE_WHEEL, 0,
    LongInt(WheelMoveFlag));
end;

function MouseAImitationWheelDown: Boolean;
begin
  Result := MouseAInf.MouseAImitation(mfMOUSE_MOVE_RELATIVE,
    bfMOUSE_MIDDLE_BUTTON_DOWN, 0, 0);
end;

function MouseAImitationWheelUp: Boolean;
begin
  Result := MouseAInf.MouseAImitation(mfMOUSE_MOVE_RELATIVE,
    bfMOUSE_MIDDLE_BUTTON_UP, 0, 0);
end;

function MouseAImitationMove(MoveFlags: TMouseMoveFlags; X, Y: LongInt)
  : Boolean;
begin
  Result := MouseAImitation(MoveFlags, bfMOUSE_BUTTON_NONE, X, Y);
end;

function MouseAImitationMove(MoveFlags: TMouseMoveFlags; XY: TPoint): Boolean;
begin
  Result := MouseAImitation(MoveFlags, bfMOUSE_BUTTON_NONE, XY.X, XY.Y);
end;

function MouseAImitationLButtonDown: Boolean;
begin
  Result := MouseAImitation(mfMOUSE_MOVE_RELATIVE,
    bfMOUSE_LEFT_BUTTON_DOWN, 0, 0);
end;

function MouseAImitationLButtonUp: Boolean;
begin
  Result := MouseAImitation(mfMOUSE_MOVE_RELATIVE,
    bfMOUSE_LEFT_BUTTON_UP, 0, 0);
end;

function MouseAImitationRButtonDown: Boolean;
begin
  Result := MouseAImitation(mfMOUSE_MOVE_RELATIVE,
    bfMOUSE_RIGHT_BUTTON_DOWN, 0, 0);
end;

function MouseAImitationRButtonUp: Boolean;
begin
  Result := MouseAImitation(mfMOUSE_MOVE_RELATIVE,
    bfMOUSE_RIGHT_BUTTON_UP, 0, 0);
end;

function MouseXYToScreen(const Point: TPoint): TPoint;
begin
  Result.X := round(Point.X / (Screen.Width - 1) * 65535);
  Result.Y := round(Point.Y / (Screen.Height - 1) * 65535);
end;

end.
