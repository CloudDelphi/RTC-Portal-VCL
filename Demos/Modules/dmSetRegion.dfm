object dmSelectRegion: TdmSelectRegion
  Left = 243
  Top = 263
  HorzScrollBar.Visible = False
  VertScrollBar.Visible = False
  BorderIcons = []
  BorderStyle = bsNone
  Caption = 'dmSelectRegion'
  ClientHeight = 245
  ClientWidth = 328
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  FormStyle = fsStayOnTop
  OldCreateOrder = False
  Scaled = False
  PixelsPerInch = 96
  TextHeight = 13
  object imgScreen: TImage
    Left = 0
    Top = 0
    Width = 328
    Height = 245
    Cursor = crCross
    Align = alClient
    OnMouseDown = imgScreenMouseDown
    OnMouseMove = imgScreenMouseMove
    OnMouseUp = imgScreenMouseUp
  end
end
