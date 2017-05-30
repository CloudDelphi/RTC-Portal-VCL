object rdFileTransfer: TrdFileTransfer
  Left = 555
  Top = 113
  BorderStyle = bsNone
  Caption = 'File Transfer'
  ClientHeight = 234
  ClientWidth = 273
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  PrintScale = poNone
  Scaled = False
  OnClose = FormClose
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 120
  TextHeight = 16
  object pTitlebar: TPanel
    Left = 0
    Top = 0
    Width = 273
    Height = 28
    Align = alTop
    Color = 12704960
    ParentBackground = False
    TabOrder = 0
    OnMouseDown = pTitlebarMouseDown
    OnMouseMove = pTitlebarMouseMove
    OnMouseUp = pTitlebarMouseUp
    object cTitleBar: TLabel
      Left = 8
      Top = 8
      Width = 99
      Height = 16
      Caption = '(NOT READY)'
      Color = clBtnFace
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBlack
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentColor = False
      ParentFont = False
      Transparent = True
      OnMouseDown = pTitlebarMouseDown
      OnMouseMove = pTitlebarMouseMove
      OnMouseUp = pTitlebarMouseUp
    end
    object cUserName: TLabel
      Left = 208
      Top = 8
      Width = 16
      Height = 16
      Alignment = taRightJustify
      Caption = '---'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clNavy
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      OnMouseDown = pTitlebarMouseDown
      OnMouseMove = pTitlebarMouseMove
      OnMouseUp = pTitlebarMouseUp
    end
    object btnMinimize: TButton
      Left = 228
      Top = 4
      Width = 21
      Height = 21
      Caption = '_'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 1
      TabStop = False
      OnClick = btnMinimizeClick
    end
    object btnClose: TButton
      Left = 248
      Top = 4
      Width = 21
      Height = 21
      Caption = 'X'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 0
      TabStop = False
      OnClick = btnCloseClick
    end
  end
  object Panel1: TPanel
    Left = 0
    Top = 28
    Width = 273
    Height = 206
    Align = alClient
    TabOrder = 1
    object DownPanel: TPanel
      Left = 1
      Top = 149
      Width = 271
      Height = 56
      Align = alBottom
      BevelInner = bvLowered
      TabOrder = 0
      OnClick = DownPanelClick
      object DownLabel: TLabel
        Left = 60
        Top = 4
        Width = 209
        Height = 49
        Alignment = taCenter
        AutoSize = False
        Caption = 
          'Drag Files && Folders from Windows Explorer HERE to send them (u' +
          'pload).'
        Layout = tlCenter
        WordWrap = True
        OnClick = DownPanelClick
      end
      object btnExplore: TSpeedButton
        Left = 4
        Top = 4
        Width = 53
        Height = 49
        Caption = 'Explore'
        Enabled = False
        Flat = True
        Glyph.Data = {
          76060000424D7606000000000000360400002800000018000000180000000100
          0800000000004002000000000000000000000001000000010000FF00FF000453
          79004551590068535800765857007A5856007A6362007B6563007A696D007570
          6D006D6E7400706C7D00864A4300804A4400814C4700824E4900844F4B008753
          4D008E5C58008E665F0093665C0095675C0096685E0082696900976960009A68
          60009E6E67009F7369008A7376008F737600877078008972780093757B00A074
          6B00A5746900A0766C00A9776A00A77E6D00AA7A6D00AA797400B2817700B186
          7900B5907D00BD957E00EAA36500E9AB6B00EAAB6C00EDAF6D00EBAF7400EBB0
          7600045982001A5E8000175A97001F5D9700185A990005628F00016391000566
          9500036C9C00046D9E000A6E9A000B709D003B608200175EA5001A5DA7000271
          A5000274A9000578AC00037FB700486B8B00507683006E7981001F73CF000C67
          D3001073EA001074F0001680A7001C86AB001D8BB4001C95BB00248FB600289C
          BC003297B400438297007F8489004D9CBB0041A0BC006CACBD00099ACE001195
          C10016A9D70019ACD70026ABCF003AAFC7003FB4CB003FB1D30033B8DC00358A
          E7003A8EE5003590EE002D8CF2002B93FE002F9CFF00359EFF00389FFF0014B1
          E2001BB6E00012BDEF0025BBE30027BFE2002BB8E2003CA7FC0035AAFF004490
          C70044A9C50045ACCE0054B1CA0062AFC90066BBCE0044BDE10040ABFB0040AB
          FC0041AFFF004AB0FA0018C1EF000CC2F7000DC5FB000DC7FE0019C9F8001ACC
          FE0036C7ED0025D7FE003AD3FB003DD3FB0053C2DD006CC7DC0049CEE2005BD5
          E2005CD5E2005BD4F00050DAF00070CFE50063D5E20069D5E2007BD5E20045E6
          FE0056EEFE006AEFF7007DE9FE007AEEFE0066F2FB0069F6FE0076F3FA007FF7
          FE007BFCFE0080808400B18E8400CBA48A00CEA58C00D0A78C00CFAF9000D3B2
          9A00DCB89800F0BF8000E3BD9500C9ACA400D5BFBD00EFC08600F0C48B00F4C7
          8900F8CB8800E2C79C00F3CF9300F0C99700F4CE9800FBD59000F4D19900FFDE
          9A00FFDD9D00FFE19C00D9C1A700DAC7A700DDCCB400EACCA000EFD7A700F6DD
          A500E3D3B600FDE2A500FFEBA700F7E3AF00FFEDAB00FEEEB200F8EBB600FCEB
          B600FCEEB600FEF2B2008BABC7008ED5E300B2D5E30081FFFE0087FFFE008EFF
          FE0092F7FE009FF7FF0095FFFE0098FAFE009FFFFE00A0E9EF00AAEEF600A6FF
          FE00BAFFFE00F2E7C200F2EDCD00FCF3C100FEF7C500FFFEC500FDFAC900FFFF
          CB00FFFFCD00FBF4D000FFFFD100FFFFD400FFFFD900FEFCDD00C1FFFF00D5FF
          FF00DDFFFF00FEF4E500FFFFE600FFFFEB00EBF4F800F2FFFF00FFFFFA00F8FF
          FF00FFFFFE000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          00000000000000000000000000000B0209000000000000000000000000000000
          00000000001E3F4054000000003939393939393939390000000000001F344B70
          7100003939595958696E7773503D37370000001C364A68786200394C8891837F
          81848B87724E3B3232001C354A677861000042899791837F81828676564D3B39
          01203E4965786300000042899791837F7C60271A211B160D014548676F640000
          000042899791837D521729B4D3DBBA2A0508C47B64000000000042899791835B
          17A5E4DDDDDDDEDDAB281A640000000000004289979183469CEAE4D7D9D9D9C2
          BEA40D00000000000000428999959513B6E5DDD9D9DDDDBDA9BB260D00000000
          000042CFD08D5F16D4D9D9DDD9D9DDB930B29E100000000000004174515C6A16
          DEDDD9D9DDDDD5A72CB2A2100000000000003B5E96918316D4D9DDD9DDD5B02E
          2EBC9E10000000000000418997918306B4DDD9D9C2ACA3ACC2C2240D00000000
          000042899791835325D7BBA7302EAEE3EAA1100000000000000042899791836B
          0A2BC3B3AAAFD9EAA612100000000000000042899791837F6C47219FB7B8A021
          0310000000000000000042899791837F8184579B060410103300000000000000
          0000428ECDCBCACCC7C7C7C7988C5A443900000000000000000042C6EAE2E0D1
          CCC7C7C7C79A926C390000000000000000004255E6E7E1D2CDC7C7C7C7C7934F
          390000000000000000000042437575C5908F89895D5D3C390000000000000000
          0000000000424242424242424242000000000000000000000000}
        Layout = blGlyphTop
        OnClick = DownPanelClick
      end
    end
    object pMain: TPageControl
      Left = 1
      Top = 1
      Width = 271
      Height = 148
      ActivePage = pSending
      Align = alClient
      MultiLine = True
      TabOrder = 1
      object pSending: TTabSheet
        Caption = 'Sending'
        object Bevel1: TBevel
          Left = 3
          Top = 51
          Width = 259
          Height = 35
          Style = bsRaised
        end
        object gSendCurrent: TGauge
          Left = 4
          Top = 52
          Width = 257
          Height = 12
          BorderStyle = bsNone
          ForeColor = clNavy
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = []
          MaxValue = 10000
          ParentFont = False
          Progress = 0
          ShowText = False
        end
        object lSendFileName: TLabel
          Left = 4
          Top = 4
          Width = 31
          Height = 16
          Caption = '------'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clNavy
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentFont = False
        end
        object lSendCompleted: TLabel
          Left = 223
          Top = 88
          Width = 36
          Height = 16
          Alignment = taRightJustify
          Caption = '-- / --'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clGreen
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentFont = False
        end
        object gSendTotal: TGauge
          Left = 4
          Top = 64
          Width = 257
          Height = 4
          BorderStyle = bsNone
          ForeColor = clTeal
          MaxValue = 10000
          Progress = 0
          ShowText = False
        end
        object lSendTime: TLabel
          Left = 4
          Top = 104
          Width = 12
          Height = 16
          Caption = '---'
        end
        object lSendSpeed: TLabel
          Left = 4
          Top = 88
          Width = 79
          Height = 16
          Caption = 'NOT READY'
        end
        object gSendCompleted: TGauge
          Left = 4
          Top = 68
          Width = 257
          Height = 17
          BorderStyle = bsNone
          ForeColor = clGreen
          MaxValue = 10000
          Progress = 0
        end
        object Label2: TLabel
          Left = 4
          Top = 20
          Width = 26
          Height = 16
          Caption = 'from'
        end
        object lSendFromFolder: TLabel
          Left = 30
          Top = 20
          Width = 20
          Height = 16
          Cursor = crHandPoint
          Caption = '-----'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clNavy
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = []
          ParentFont = False
          OnClick = lSendFromFolderClick
        end
        object lSendCurrent: TLabel
          Left = 4
          Top = 36
          Width = 28
          Height = 16
          Caption = '-- / --'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clNavy
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = []
          ParentFont = False
        end
        object lSendTotal: TLabel
          Left = 231
          Top = 36
          Width = 28
          Height = 16
          Alignment = taRightJustify
          Caption = '-- / --'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clTeal
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = []
          ParentFont = False
        end
        object btnCancelSend: TSpeedButton
          Left = 240
          Top = 0
          Width = 23
          Height = 22
          Caption = 'X'
          OnClick = btnCancelSendClick
        end
      end
      object pReceiving: TTabSheet
        Caption = 'Receiving'
        ImageIndex = 1
        object Bevel2: TBevel
          Left = 3
          Top = 51
          Width = 259
          Height = 35
          Style = bsRaised
        end
        object gRecvCurrent: TGauge
          Left = 4
          Top = 52
          Width = 257
          Height = 12
          BorderStyle = bsNone
          ForeColor = clNavy
          MaxValue = 10000
          Progress = 0
          ShowText = False
        end
        object gRecvTotal: TGauge
          Left = 4
          Top = 64
          Width = 257
          Height = 21
          BorderStyle = bsNone
          ForeColor = clGreen
          MaxValue = 10000
          Progress = 0
        end
        object lRecvFileName: TLabel
          Left = 4
          Top = 4
          Width = 21
          Height = 16
          Caption = '----'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clNavy
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentFont = False
        end
        object lRecvTotal: TLabel
          Left = 223
          Top = 88
          Width = 36
          Height = 16
          Alignment = taRightJustify
          Caption = '-- / --'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clGreen
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentFont = False
        end
        object lRecvTime: TLabel
          Left = 4
          Top = 104
          Width = 12
          Height = 16
          Caption = '---'
        end
        object lRecvSpeed: TLabel
          Left = 4
          Top = 88
          Width = 79
          Height = 16
          Caption = 'NOT READY'
        end
        object lRecvToFolder: TLabel
          Left = 18
          Top = 20
          Width = 20
          Height = 16
          Cursor = crHandPoint
          Caption = '-----'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clNavy
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = []
          ParentFont = False
          OnClick = btnOpenInboxClick
        end
        object Label1: TLabel
          Left = 4
          Top = 20
          Width = 11
          Height = 16
          Caption = 'to'
        end
        object lRecvCurrent: TLabel
          Left = 4
          Top = 36
          Width = 28
          Height = 16
          Caption = '-- / --'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clNavy
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = []
          ParentFont = False
        end
        object btnCancelFetch: TSpeedButton
          Left = 240
          Top = 0
          Width = 23
          Height = 22
          Caption = 'X'
          OnClick = btnCancelFetchClick
        end
      end
    end
  end
  object myUI: TRtcPFileTransferUI
    OnInit = myUIInit
    OnOpen = myUIOpen
    OnClose = myUIClose
    OnError = myUIError
    OnLogOut = myUILogOut
    OnSendStart = myUISend
    OnSend = myUISend
    OnSendUpdate = myUISend
    OnSendStop = myUISend
    OnSendCancel = myUISendCancel
    OnRecvStart = myUIRecv
    OnRecv = myUIRecv
    OnRecvStop = myUIRecv
    OnRecvCancel = myUIRecvCancel
    Left = 140
    Top = 8
  end
end
