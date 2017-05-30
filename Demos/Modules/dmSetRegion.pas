{ Copyright (c) Danijel Tkalcec,
  RealThinClient components - http://www.realthinclient.com }

unit dmSetRegion;

interface

{$INCLUDE rtcDefs.inc}
{$INCLUDE rtcPortalDefs.inc}

uses
  Windows, Messages, SysUtils, Classes,
  Graphics, Controls, Forms, Dialogs, ExtCtrls,

  rtcScrCapture;

type
  TdmSelectRegion = class(TForm)
    imgScreen: TImage;
    procedure imgScreenMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure imgScreenMouseMove(Sender: TObject; Shift: TShiftState; X,Y: Integer);
    procedure imgScreenMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);

  private
    { Private declarations }
    Region:TRect;
    mbDown,mbMove:boolean;

  public
    { Public declarations }

    function GrabScreen(MultiMon:boolean):TRect;
  end;

implementation

uses Types;

{$R *.dfm}

{ TdmSelectRegion }

function TdmSelectRegion.GrabScreen(MultiMon:boolean):TRect;
  var
    temp:integer;
  begin
  mbDown:=False; mbMove:=False;
  imgScreen.Picture.Bitmap:=CaptureFullScreen(MultiMon);
  {$IFDEF MULTIMON}
  if MultiMon then
    begin
    Left:=Screen.DesktopLeft;
    Top:=Screen.DesktopTop;
    end
  else
  {$ENDIF}
    begin
    Left:=0;
    Top:=0;
    end;
  ClientWidth:=imgScreen.Picture.Width;
  ClientHeight:=imgScreen.Picture.Height;
  ShowModal;
  if Region.Left>Region.Right then
    begin
    temp:=Region.Right;
    Region.Right:=Region.Left;
    Region.Left:=temp;
    end;
  if Region.Top>Region.Bottom then
    begin
    temp:=Region.Bottom;
    Region.Bottom:=Region.Top;
    Region.Top:=temp;
    end;
  {$IFDEF MULTIMON}
  Region.Left:=Region.Left+Screen.DesktopLeft;
  Region.Top:=Region.Top+Screen.DesktopTop;
  Region.Right:=Region.Right+Screen.DesktopLeft;
  Region.Bottom:=Region.Bottom+Screen.DesktopTop;
  {$ENDIF}
  Result:=Region;
  end;

procedure TdmSelectRegion.imgScreenMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
  begin
  if mbMove then
    begin
    mbMove:=False;
    imgScreen.Canvas.Pen.Mode:=pmXor;
    imgScreen.Canvas.Pen.Color:=clWhite;
    imgScreen.Canvas.MoveTo(Region.Left, 0);
    imgScreen.Canvas.LineTo(Region.Left, Height);
    imgScreen.Canvas.MoveTo(0, Region.Top);
    imgScreen.Canvas.LineTo(Width, Region.Top);
    end;
  if not mbDown then
    begin
    mbDown:=True;
    Region.Left:=X;
    Region.Top:=Y;
    Region.Right:=X+1;
    Region.Bottom:=Y+1;
    imgScreen.Canvas.Pen.Mode:=pmXor;
    imgScreen.Canvas.Pen.Color:=clWhite;
    imgScreen.Canvas.Rectangle(Region.Left, Region.Top, Region.Right, Region.Bottom);
    imgScreen.Canvas.Pen.Mode:=pmCopy;
    end;
  end;

procedure TdmSelectRegion.imgScreenMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
  begin
  if mbDown then
    begin
    imgScreen.Canvas.Pen.Mode:=pmXor;
    imgScreen.Canvas.Pen.Color:=clWhite;
    imgScreen.Canvas.Rectangle(Region.Left, Region.Top, Region.Right, Region.Bottom);
    Region.Right:=X+1;
    Region.Bottom:=Y+1;
    imgScreen.Canvas.Rectangle(Region.Left, Region.Top, Region.Right, Region.Bottom);
    imgScreen.Canvas.Pen.Mode:=pmCopy;
    end
  else
    begin
    imgScreen.Canvas.Pen.Mode:=pmXor;
    imgScreen.Canvas.Pen.Color:=clWhite;
    if mbMove then
      begin
      imgScreen.Canvas.MoveTo(Region.Left, 0);
      imgScreen.Canvas.LineTo(Region.Left, Height);
      imgScreen.Canvas.MoveTo(0, Region.Top);
      imgScreen.Canvas.LineTo(Width, Region.Top);
      end
    else
      mbMove:=True;
    Region.Left:=X;
    Region.Top:=Y;
    imgScreen.Canvas.MoveTo(Region.Left, 0);
    imgScreen.Canvas.LineTo(Region.Left, Height);
    imgScreen.Canvas.MoveTo(0, Region.Top);
    imgScreen.Canvas.LineTo(Width, Region.Top);
    imgScreen.Canvas.Pen.Mode:=pmCopy;
    end;
  end;

procedure TdmSelectRegion.imgScreenMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
  begin
  if mbDown then
    begin
    mbDown:=False;
    imgScreen.Canvas.Pen.Mode:=pmXor;
    imgScreen.Canvas.Pen.Color:=clBlack;
    imgScreen.Canvas.Rectangle(Region.Left, Region.Top, Region.Right, Region.Bottom);
    imgScreen.Canvas.Pen.Mode:=pmCopy;
    Region.Right:=X+1;
    Region.Bottom:=Y+1;
    end;

  ModalResult:=mrOk;
  end;

end.
