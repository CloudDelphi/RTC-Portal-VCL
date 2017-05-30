object rdClientSettings: TrdClientSettings
  Left = 554
  Top = 226
  BorderIcons = []
  BorderStyle = bsDialog
  Caption = 'Connection Settings'
  ClientHeight = 340
  ClientWidth = 273
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Arial'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  PrintScale = poNone
  Scaled = False
  PixelsPerInch = 120
  TextHeight = 14
  object Label2: TLabel
    Left = 56
    Top = 104
    Width = 19
    Height = 14
    Alignment = taRightJustify
    Caption = 'Port'
  end
  object Label7: TLabel
    Left = 14
    Top = 236
    Width = 57
    Height = 14
    Alignment = taRightJustify
    Caption = 'Secure Key'
  end
  object Label13: TLabel
    Left = 28
    Top = 32
    Width = 42
    Height = 14
    Alignment = taRightJustify
    Caption = 'Address'
  end
  object Label22: TLabel
    Left = 12
    Top = 284
    Width = 258
    Height = 14
    Caption = 'More Compression = less Traffic but more CPU usage'
  end
  object Label18: TLabel
    Left = 12
    Top = 260
    Width = 63
    Height = 14
    Caption = 'Compression'
  end
  object Label12: TLabel
    Left = 8
    Top = 8
    Width = 210
    Height = 14
    Caption = 'Gateway information (where to connect) ...'
  end
  object eAddress: TEdit
    Left = 80
    Top = 28
    Width = 185
    Height = 22
    Hint = 'Enter Gateway Address here'
    TabOrder = 0
  end
  object ePort: TEdit
    Left = 80
    Top = 100
    Width = 93
    Height = 22
    Hint = 'Enter Gateway Port here'
    TabOrder = 6
  end
  object eSecureKey: TEdit
    Left = 80
    Top = 232
    Width = 185
    Height = 22
    Hint = 'Enter the Secure Key set up on the Gateway'
    PasswordChar = '*'
    TabOrder = 8
  end
  object xProxy: TCheckBox
    Left = 128
    Top = 76
    Width = 57
    Height = 21
    Hint = 'if you are behind a HTTP Proxy, check this box'
    TabStop = False
    Caption = 'Proxy'
    TabOrder = 4
    OnClick = xProxyClick
  end
  object xSSL: TCheckBox
    Left = 80
    Top = 76
    Width = 49
    Height = 21
    TabStop = False
    Caption = 'SSL'
    TabOrder = 3
    OnClick = xSSLClick
  end
  object eISAPI: TEdit
    Left = 80
    Top = 52
    Width = 185
    Height = 22
    Hint = 'Enter the PATH to the Gateway ISAPI DLL'
    Color = clGray
    Enabled = False
    TabOrder = 2
  end
  object xISAPI: TCheckBox
    Left = 24
    Top = 52
    Width = 53
    Height = 21
    Hint = 'Is the Gateway running as an ISAPI DLL?'
    TabStop = False
    Caption = 'ISAPI'
    TabOrder = 1
    OnClick = xISAPIClick
  end
  object cbCompress: TComboBox
    Left = 80
    Top = 256
    Width = 185
    Height = 22
    Style = csDropDownList
    DropDownCount = 15
    ItemHeight = 14
    TabOrder = 9
    Items.Strings = (
      'Normal'
      'Maximum'
      'Minimum')
  end
  object btnCancel: TBitBtn
    Left = 12
    Top = 304
    Width = 75
    Height = 29
    TabOrder = 11
    OnClick = btnCancelClick
    Kind = bkCancel
  end
  object btnOK: TBitBtn
    Left = 188
    Top = 304
    Width = 75
    Height = 29
    Caption = 'OK'
    Default = True
    ModalResult = 1
    TabOrder = 10
    OnClick = btnOKClick
    Glyph.Data = {
      DE010000424DDE01000000000000760000002800000024000000120000000100
      0400000000006801000000000000000000001000000000000000000000000000
      80000080000000808000800000008000800080800000C0C0C000808080000000
      FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00333333333333
      3333333333333333333333330000333333333333333333333333F33333333333
      00003333344333333333333333388F3333333333000033334224333333333333
      338338F3333333330000333422224333333333333833338F3333333300003342
      222224333333333383333338F3333333000034222A22224333333338F338F333
      8F33333300003222A3A2224333333338F3838F338F33333300003A2A333A2224
      33333338F83338F338F33333000033A33333A222433333338333338F338F3333
      0000333333333A222433333333333338F338F33300003333333333A222433333
      333333338F338F33000033333333333A222433333333333338F338F300003333
      33333333A222433333333333338F338F00003333333333333A22433333333333
      3338F38F000033333333333333A223333333333333338F830000333333333333
      333A333333333333333338330000333333333333333333333333333333333333
      0000}
    NumGlyphs = 2
  end
  object xWinHTTP: TCheckBox
    Left = 188
    Top = 76
    Width = 77
    Height = 21
    Hint = 'if you want to use the WinHTTP API, check this box'
    TabStop = False
    Caption = 'WinHTTP'
    TabOrder = 5
    OnClick = xProxyClick
  end
  object gProxy: TGroupBox
    Left = 8
    Top = 128
    Width = 261
    Height = 97
    Caption = 'Proxy Settings (leave empty for default)'
    Enabled = False
    TabOrder = 7
    object Label1: TLabel
      Left = 8
      Top = 24
      Width = 51
      Height = 14
      Alignment = taRightJustify
      Caption = 'Proxy URL'
    end
    object Label4: TLabel
      Left = 10
      Top = 48
      Width = 49
      Height = 14
      Alignment = taRightJustify
      Caption = 'Username'
    end
    object Label5: TLabel
      Left = 9
      Top = 72
      Width = 50
      Height = 14
      Alignment = taRightJustify
      Caption = 'Password'
    end
    object eProxyAddr: TEdit
      Left = 68
      Top = 20
      Width = 185
      Height = 22
      Hint = 'Enter the Address of your Proxy including http:// or https://'
      Color = clGray
      TabOrder = 0
    end
    object eProxyUsername: TEdit
      Left = 68
      Top = 44
      Width = 185
      Height = 22
      Hint = 'Enter Username needed to log in to the Proxy'
      Color = clGray
      TabOrder = 1
    end
    object eProxyPassword: TEdit
      Left = 68
      Top = 68
      Width = 185
      Height = 22
      Hint = 'Enter Password needed to log in to the Proxy'
      Color = clGray
      PasswordChar = '*'
      TabOrder = 2
    end
  end
end
