object rdChatForm: TrdChatForm
  Left = 433
  Top = 139
  BorderIcons = []
  BorderStyle = bsNone
  Caption = 'rdChatForm'
  ClientHeight = 510
  ClientWidth = 526
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -14
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  KeyPreview = True
  OldCreateOrder = False
  Position = poDefault
  OnClose = FormClose
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnKeyPress = FormKeyPress
  OnResize = FormResize
  OnShow = FormResize
  PixelsPerInch = 120
  TextHeight = 16
  object Panel3: TPanel
    Left = 4
    Top = 4
    Width = 518
    Height = 502
    Align = alClient
    ParentBackground = False
    TabOrder = 0
    OnMouseDown = Panel3MouseDown
    OnMouseMove = Panel3MouseMove
    OnMouseUp = Panel3MouseUp
    object pSplit: TSplitter
      Left = 1
      Top = 218
      Width = 516
      Height = 4
      Cursor = crVSplit
      Align = alTop
      Color = clGray
      ParentColor = False
    end
    object pMain: TPanel
      Left = 1
      Top = 37
      Width = 516
      Height = 181
      Align = alTop
      BorderWidth = 2
      ParentBackground = False
      TabOrder = 1
      object mChatLog: TRichEdit
        Left = 3
        Top = 3
        Width = 510
        Height = 175
        TabStop = False
        Align = alClient
        Font.Charset = ANSI_CHARSET
        Font.Color = clWindowText
        Font.Height = -17
        Font.Name = 'MS Sans Serif'
        Font.Style = []
        ParentFont = False
        PopupMenu = HistoryPopupMenu
        ReadOnly = True
        ScrollBars = ssVertical
        TabOrder = 0
      end
    end
    object pBox: TScrollBox
      Left = 1
      Top = 326
      Width = 516
      Height = 175
      VertScrollBar.Smooth = True
      VertScrollBar.Style = ssHotTrack
      VertScrollBar.Tracking = True
      Align = alClient
      BorderStyle = bsNone
      Color = 14737632
      ParentColor = False
      TabOrder = 0
      TabStop = True
    end
    object pTitle: TPanel
      Left = 1
      Top = 1
      Width = 516
      Height = 36
      Align = alTop
      BevelOuter = bvNone
      Color = 12704960
      ParentBackground = False
      TabOrder = 2
      OnMouseDown = pTitleMouseDown
      OnMouseMove = pTitleMouseMove
      OnMouseUp = pTitleMouseUp
      object cTitle: TLabel
        Left = 10
        Top = 10
        Width = 32
        Height = 16
        Caption = 'Chat'
        Color = clBtnFace
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clBlack
        Font.Height = -15
        Font.Name = 'MS Sans Serif'
        Font.Style = [fsBold]
        ParentColor = False
        ParentFont = False
        Transparent = True
        OnMouseDown = pTitleMouseDown
        OnMouseMove = pTitleMouseMove
        OnMouseUp = pTitleMouseUp
      end
      object Panel2: TPanel
        Left = 383
        Top = 0
        Width = 133
        Height = 36
        Align = alRight
        BevelOuter = bvNone
        Color = clMoneyGreen
        TabOrder = 0
        object btnClose: TSpeedButton
          Left = 103
          Top = 5
          Width = 26
          Height = 26
          Caption = 'X'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clBlack
          Font.Height = -15
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentFont = False
          OnClick = btnCloseClick
        end
        object btnMinimize: TSpeedButton
          Left = 79
          Top = 5
          Width = 24
          Height = 26
          Caption = '_'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clBlack
          Font.Height = -15
          Font.Name = 'MS Sans Serif'
          Font.Style = []
          ParentFont = False
          OnClick = btnMinimizeClick
        end
        object btnOnTop: TSpeedButton
          Left = 5
          Top = 4
          Width = 65
          Height = 28
          Caption = 'To Top'
          Flat = True
          Layout = blGlyphRight
          OnClick = btnOnTopClick
        end
      end
    end
    object myBox: TPanel
      Left = 1
      Top = 256
      Width = 516
      Height = 70
      Align = alTop
      AutoSize = True
      BevelOuter = bvNone
      Color = 14737632
      ParentBackground = False
      TabOrder = 3
    end
    object Panel12: TPanel
      Left = 1
      Top = 222
      Width = 516
      Height = 34
      Align = alTop
      ParentBackground = False
      TabOrder = 4
      object btnLockChatBoxes: TSpeedButton
        Left = 399
        Top = 4
        Width = 114
        Height = 28
        Caption = 'Lock Chat Boxes'
        Flat = True
        Layout = blGlyphRight
        OnClick = btnLockChatBoxesClick
      end
      object btnClearHistory: TSpeedButton
        Left = 84
        Top = 2
        Width = 94
        Height = 30
        Caption = 'Clear History'
        Flat = True
        OnClick = btnClearHistoryClick
      end
      object btnHideHistory: TSpeedButton
        Left = 182
        Top = 2
        Width = 95
        Height = 30
        Caption = 'Hide History'
        Flat = True
        OnClick = btnHideHistoryClick
      end
      object btnDesktop: TSpeedButton
        Left = 5
        Top = 2
        Width = 75
        Height = 30
        Caption = 'Desktop'
        Flat = True
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -15
        Font.Name = 'MS Sans Serif'
        Font.Style = [fsBold]
        ParentFont = False
        Visible = False
        OnClick = btnDesktopClick
      end
      object btnHideTyping: TSpeedButton
        Left = 281
        Top = 2
        Width = 114
        Height = 30
        Caption = 'Hide my Typing'
        Flat = True
        OnClick = btnHideTypingClick
      end
    end
  end
  object pRight: TPanel
    Left = 522
    Top = 4
    Width = 4
    Height = 502
    Cursor = crSizeWE
    Align = alRight
    BevelOuter = bvNone
    Color = clGray
    TabOrder = 1
    OnMouseDown = Panel3MouseDown
    OnMouseMove = Panel3MouseMove
    OnMouseUp = Panel3MouseUp
    object pSize1: TPanel
      Left = 0
      Top = 487
      Width = 4
      Height = 15
      Cursor = crSizeNWSE
      Align = alBottom
      BevelOuter = bvNone
      Color = clBlack
      TabOrder = 0
      OnMouseDown = Panel3MouseDown
      OnMouseMove = Panel3MouseMove
      OnMouseUp = Panel3MouseUp
    end
  end
  object pBottom: TPanel
    Left = 0
    Top = 506
    Width = 526
    Height = 4
    Cursor = crSizeNS
    Align = alBottom
    BevelOuter = bvNone
    Color = clGray
    TabOrder = 2
    OnMouseDown = Panel3MouseDown
    OnMouseMove = Panel3MouseMove
    OnMouseUp = Panel3MouseUp
    object pSize2: TPanel
      Left = 507
      Top = 0
      Width = 19
      Height = 4
      Cursor = crSizeNWSE
      Align = alRight
      BevelOuter = bvNone
      Color = clBlack
      TabOrder = 0
      OnMouseDown = Panel3MouseDown
      OnMouseMove = Panel3MouseMove
      OnMouseUp = Panel3MouseUp
    end
  end
  object pLeft: TPanel
    Left = 0
    Top = 4
    Width = 4
    Height = 502
    Cursor = crSizeWE
    Align = alLeft
    BevelOuter = bvNone
    Color = clGray
    TabOrder = 3
    OnMouseDown = Panel3MouseDown
    OnMouseMove = Panel3MouseMove
    OnMouseUp = Panel3MouseUp
    object pSize4: TPanel
      Left = 0
      Top = 0
      Width = 4
      Height = 15
      Cursor = crSizeNWSE
      Align = alTop
      BevelOuter = bvNone
      Color = clBlack
      TabOrder = 0
      OnMouseDown = Panel3MouseDown
      OnMouseMove = Panel3MouseMove
      OnMouseUp = Panel3MouseUp
    end
  end
  object pTop: TPanel
    Left = 0
    Top = 0
    Width = 526
    Height = 4
    Cursor = crSizeNS
    Align = alTop
    BevelOuter = bvNone
    Color = clGray
    TabOrder = 4
    OnMouseDown = Panel3MouseDown
    OnMouseMove = Panel3MouseMove
    OnMouseUp = Panel3MouseUp
    object pSize3: TPanel
      Left = 0
      Top = 0
      Width = 18
      Height = 4
      Cursor = crSizeNWSE
      Align = alLeft
      BevelOuter = bvNone
      Color = clBlack
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBlack
      Font.Height = -15
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentFont = False
      TabOrder = 0
      OnMouseDown = Panel3MouseDown
      OnMouseMove = Panel3MouseMove
      OnMouseUp = Panel3MouseUp
    end
  end
  object pTimer: TTimer
    Enabled = False
    Interval = 500
    OnTimer = pTimerTimer
    Left = 248
    Top = 45
  end
  object CopyPastePopupMenu: TPopupMenu
    Left = 280
    Top = 45
    object Copy1: TMenuItem
      Caption = 'Copy'
      OnClick = Copy1Click
    end
    object Paste1: TMenuItem
      Caption = 'Paste'
      OnClick = Paste1Click
    end
  end
  object HistoryPopupMenu: TPopupMenu
    Left = 60
    Top = 89
    object miSaveHistory: TMenuItem
      Caption = 'Save History'
      OnClick = miSaveHistoryClick
    end
    object miLoadHistory: TMenuItem
      Caption = 'Load History'
      OnClick = miLoadHistoryClick
    end
    object miCopyHistory: TMenuItem
      Caption = 'Copy to Clipboard'
      OnClick = miCopyHistoryClick
    end
  end
  object dlgSaveHistory: TSaveDialog
    DefaultExt = '.hst'
    Filter = 'History(*.hst)|*.hst'
    InitialDir = '.'
    Options = [ofOverwritePrompt, ofHideReadOnly, ofEnableSizing]
    Left = 92
    Top = 89
  end
  object dlgLoadHistory: TOpenDialog
    DefaultExt = '.hst'
    Filter = 'History(*.hst)|*.hst'
    InitialDir = '.'
    Options = [ofReadOnly, ofHideReadOnly, ofPathMustExist, ofFileMustExist, ofEnableSizing]
    Left = 28
    Top = 89
  end
  object myUI: TRtcPChatUI
    OnInit = myUIInit
    OnOpen = myUIOpen
    OnClose = myUIClose
    OnError = myUIError
    OnLogOut = myUILogOut
    OnUserJoined = myUIUserJoined
    OnUserLeft = myUIUserLeft
    OnMessage = myUIMessage
    Left = 140
    Top = 8
  end
end
