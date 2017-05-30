object rdDesktopViewer: TrdDesktopViewer
  Left = 369
  Top = 141
  Width = 500
  Height = 336
  HorzScrollBar.Tracking = True
  HorzScrollBar.Visible = False
  VertScrollBar.Tracking = True
  VertScrollBar.Visible = False
  Caption = 'rdDesktopViewer'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Arial'
  Font.Style = []
  KeyPreview = True
  OldCreateOrder = False
  Position = poScreenCenter
  PrintScale = poNone
  Scaled = False
  ShowHint = True
  OnClose = FormClose
  OnCloseQuery = FormCloseQuery
  OnDeactivate = FormDeactivate
  OnHide = FormDeactivate
  OnKeyDown = FormKeyDown
  OnKeyUp = FormKeyUp
  OnMouseWheel = FormMouseWheel
  PixelsPerInch = 120
  TextHeight = 14
  object Scroll: TScrollBox
    Left = 0
    Top = 0
    Width = 482
    Height = 291
    HorzScrollBar.Tracking = True
    HorzScrollBar.Visible = False
    VertScrollBar.Tracking = True
    VertScrollBar.Visible = False
    Align = alClient
    BorderStyle = bsNone
    Color = clBlack
    ParentColor = False
    TabOrder = 0
    OnMouseMove = ScrollMouseMove
    object pImage: TRtcPDesktopViewer
      Left = 0
      Top = 0
      Width = 482
      Height = 291
      Align = alClient
      OnDblClick = pImageDblClick
      OnMouseDown = pImageMouseDown
      OnMouseMove = pImageMouseMove
      OnMouseUp = pImageMouseUp
    end
    object sStatus: TLabel
      Left = 16
      Top = 12
      Width = 306
      Height = 20
      Caption = 'Loading initial screen. Please wait ...'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWhite
      Font.Height = 24
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object panOptions: TPanel
      Left = 10
      Top = 38
      Width = 287
      Height = 30
      ParentBackground = False
      TabOrder = 0
      Visible = False
      object btnCycle: TSpeedButton
        Left = 4
        Top = 4
        Width = 23
        Height = 22
        Hint = 'To Full Screen mode'
        AllowAllUp = True
        GroupIndex = 1
        Flat = True
        Glyph.Data = {
          36030000424D3603000000000000360000002800000010000000100000000100
          18000000000000030000120B0000120B00000000000000000000FF00FF314B62
          AC7D7EFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00
          FFFF00FFFF00FFFF00FF5084B20F6FE1325F8CB87E7AFF00FFFF00FFFF00FFFF
          00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FF32A0FE37A1FF
          106FE2325F8BB67D79FF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00
          FFFF00FFFF00FFFF00FFFF00FF37A4FE379FFF0E6DDE355F89BB7F79FF00FFFF
          00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FF
          37A4FE359EFF0F6FDE35608BA67B7FFF00FFFF00FFFF00FFFF00FFFF00FFFF00
          FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FF38A5FE329DFF156DCE444F5BFF
          00FF9C6B65AF887BAF887EAA8075FF00FFFF00FFFF00FFFF00FFFF00FFFF00FF
          FF00FFFF00FF3BABFFA1CAE7AD8679A98373E0CFB1FFFFDAFFFFDDFCF8CFCCB2
          9FA1746BFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFC0917DFC
          E9ACFFFFCCFFFFCFFFFFD0FFFFDEFFFFFAE3D3D1996965FF00FFFF00FFFF00FF
          FF00FFFF00FFFF00FFFF00FFB08978FAD192FEF4C2FFFFD0FFFFDAFFFFF6FFFF
          FCFFFFFCB69384FF00FFFF00FFFF00FFFF00FFFF00FFFF00FFB08978FEDA97ED
          B478FBEEBBFFFFD3FFFFDCFFFFF4FFFFF4FFFFE2E9DDBCA67B73FF00FFFF00FF
          FF00FFFF00FFFF00FFB18A78FFDE99E9A167F4D199FEFCCCFFFFD5FFFFDAFFFF
          DCFFFFD7EFE6C5A97E75FF00FFFF00FFFF00FFFF00FFFF00FFAA7F73FAE0A4F0
          B778EEBA7BF6DDA6FEFBCCFFFFD3FFFFD1FFFFD7D9C5A7A3756CFF00FFFF00FF
          FF00FFFF00FFFF00FFFF00FFCEB293FFFEDDF4D1A5EEBA7BF2C78FF8E1ABFCF0
          BAFCFACAA3776FFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFA1746BE1
          D4D3FFFEEEF7CC8CF0B473F7C788FCE3A5C2A088A5776CFF00FFFF00FFFF00FF
          FF00FFFF00FFFF00FFFF00FFFF00FF986865BA9587EAD7A4EAD59EE0C097A577
          6CA5776CFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF
          00FFFF00FFA77E70A98073A4786EFF00FFFF00FFFF00FFFF00FF}
        OnClick = btnCycleClick
      end
      object btnSettings: TSpeedButton
        Left = 104
        Top = 3
        Width = 97
        Height = 24
        Hint = 'Settings'
        Caption = 'Host Settings'
        Glyph.Data = {
          76010000424D7601000000000000760000002800000020000000100000000100
          04000000000000010000120B0000120B00001000000000000000000000000000
          800000800000008080008000000080008000808000007F7F7F00BFBFBF000000
          FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00555550FF0559
          1950555FF75F7557F7F757000FF055591903557775F75557F77570FFFF055559
          1933575FF57F5557F7FF0F00FF05555919337F775F7F5557F7F700550F055559
          193577557F7F55F7577F07550F0555999995755575755F7FFF7F5570F0755011
          11155557F755F777777555000755033305555577755F75F77F55555555503335
          0555555FF5F75F757F5555005503335505555577FF75F7557F55505050333555
          05555757F75F75557F5505000333555505557F777FF755557F55000000355557
          07557777777F55557F5555000005555707555577777FF5557F55553000075557
          0755557F7777FFF5755555335000005555555577577777555555}
        NumGlyphs = 2
        OnClick = btnSettingsClick
      end
      object btnWallpaper: TSpeedButton
        Left = 204
        Top = 3
        Width = 25
        Height = 24
        Hint = 'Hide Wallpaper'
        AllowAllUp = True
        GroupIndex = 5
        Flat = True
        Glyph.Data = {
          76010000424D7601000000000000760000002800000020000000100000000100
          04000000000000010000120B0000120B00001000000000000000000000000000
          800000800000008080008000000080008000808000007F7F7F00BFBFBF000000
          FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00333300000000
          0EEE333377777777777733330FF00FBFB0EE33337F37733F377733330F0BFB0B
          FB0E33337F73FF73337733330FF000BFBFB033337F377733333733330FFF0BFB
          FBF033337FFF733F333733300000BF0FBFB03FF77777F3733F37000FBFB0F0FB
          0BF077733FF7F7FF7337E0FB00000000BF0077F377777777F377E0BFBFBFBFB0
          F0F077F3333FFFF7F737E0FBFB0000000FF077F3337777777337E0BFBFBFBFB0
          FFF077F3333FFFF73FF7E0FBFB00000F000077FF337777737777E00FBFBFB0FF
          0FF07773FFFFF7337F37003000000FFF0F037737777773337F7333330FFFFFFF
          003333337FFFFFFF773333330000000003333333777777777333}
        NumGlyphs = 2
        OnClick = btnWallpaperClick
      end
      object btnCtrlAltDel: TSpeedButton
        Left = 232
        Top = 3
        Width = 25
        Height = 24
        Hint = 'Send <Ctrl+Alt+Del>'
        Flat = True
        Glyph.Data = {
          76010000424D7601000000000000760000002800000020000000100000000100
          04000000000000010000120B0000120B00001000000000000000000000000000
          800000800000008080008000000080008000808000007F7F7F00BFBFBF000000
          FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00555555555555
          5000555555555555577755555555555550B0555555555555F7F7555555555550
          00B05555555555577757555555555550B3B05555555555F7F557555555555000
          3B0555555555577755755555555500B3B0555555555577555755555555550B3B
          055555FFFF5F7F5575555700050003B05555577775777557555570BBB00B3B05
          555577555775557555550BBBBBB3B05555557F555555575555550BBBBBBB0555
          55557F55FF557F5555550BB003BB075555557F577F5575F5555577B003BBB055
          555575F7755557F5555550BB33BBB0555555575F555557F555555507BBBB0755
          55555575FFFF7755555555570000755555555557777775555555}
        NumGlyphs = 2
        OnClick = btnCtrlAltDelClick
      end
      object btnSmoothScale: TSpeedButton
        Left = 28
        Top = 4
        Width = 23
        Height = 22
        Hint = 'Smooth View'
        AllowAllUp = True
        GroupIndex = 2
        Flat = True
        Glyph.Data = {
          36050000424D3605000000000000360400002800000010000000100000000100
          0800000000000001000000000000000000000001000000010000000000000101
          0100020202000303030004040400050505000606060007070700080808000909
          09000A0A0A000B0B0B000C0C0C000D0D0D000E0E0E000F0F0F00101010001111
          1100121212001313130014141400151515001616160017171700181818001919
          19001A1A1A001B1B1B001C1C1C001D1D1D001E1E1E001F1F1F00202020002121
          2100222222002323230024242400252525002626260027272700282828002929
          29002A2A2A002B2B2B002C2C2C002D2D2D002E2E2E002F2F2F00303030003131
          3100323232003333330034343400353535003636360037373700383838003939
          39003A3A3A003B3B3B003C3C3C003D3D3D003E3E3E003F3F3F00404040004141
          4100424242004343430044444400454545004646460047474700484848004949
          49004A4A4A004B4B4B004C4C4C004B4C4E004B4D4F004B4E51004D4F51004F50
          5200525252005353530054545400555555005455560054565700545658005456
          590054575A0054575B0054585B0055585C0055595D0059595D00565A5E00575B
          5F00585C5F005A5D60005B5E61005D6062006062640062646500656667006969
          69006A6A6A006B6B6B006C6C6C006D6D6D006E6E6E006F6F6F00707070007171
          710072727200737373007474740079757400727477006E7479006B737B006873
          7D00657182006571860067708A005F6E8D00586C9200556A9400526995005068
          96004F6897004D6798004C6698004B6698004A6698004A659800496598004965
          98004865970046659600496598004B689A004C699B00506C9F00556EA2005971
          A6005E76AA00667BAE006C83B800758BBB008297C5008CA0CB0094A7D0009DAF
          D500A6B6D800AEBDDA00B7C4DB00BFCBDC00CAD3DC00DCE0DA00E9E9D800F0EE
          D700F5F1D800F8F5D800F9F5D100F9F5CB00F9F4C800F9F3C500F9F1C200F9EF
          BF00F8EEBC00F7EAB800F7E5B000F7E1A800F4DCA400F3D8A000F1D6A000ECD1
          A000E7CBA000E1C49E00DBBD9D00D8B99B00D4B49900D2B09800D0AD9600CBA7
          9400C8A29100C59D8E00C4998A00C1968900C0938800BF8F8700BF8B8500BD87
          8300BB848200BE828600C27D8B00C5789100C8729900CE69A400D55CB100DC4E
          BD00E43BCE00F021E300FE00FE00FE00FE00FE00FE00FE00FE00FE00FE00FE00
          FE00FE00FE00FE00FE00FE00FE00FE00FE00FE00FE00FE00FE00FE00FE00FE00
          FE00FE00FE00FE00FE00FE00FE00FE00FE00FE00FE00FE00FE00FE00FE00FE00
          FE00FE00FE00FE00FE00FE00FE00FE00FE00FE00FE00FE00FE00FE00FE00FE00
          FE00FE00FE00FE00FE00FD01FE00F00AFE00D91AFE00BC2CFD009842FC007854
          FB005B69F9004172F600357CF7002D77F5002675F400206CF2001E65F4001B5A
          F600184FF9001342FB00103BFB000C33FB000A2FFB00082AFB00DB4FC2DBDBDB
          DBDBDBDBDBDBDBDBDBDB94F78BC2DBDBDBDBDBDBDBDBDBDBDBDBF4F4F78BC2DB
          DBDBDBDBDBDBDBDBDBDBDBF4F4F78BC2DBDBDBDBDBDBDBDBDBDBDBDBF4F4F78B
          C2DBDBDBDBDBDBDBDBDBDBDBDBF4F4F74FDB63C0BABFDBDBDBDBDBDBDBDBF49B
          75C2AEA5A5A5B2BCDBDBDBDBDBDBDBBAB9ACA59AF39FA3A175DBDBDBDBDBDBC2
          AFAFAA94FF9DA3A3B4DBDBDBDBDBDBB9AD9494FAFFF2F29EA8C2DBDBDBDBDBB5
          AD8BFFFFFFFFFF99A5BDDBDBDBDBDBB8ADBEBCF3FF969CA1A7C0DBDBDBDBDBC1
          ACACAF92FF9CA7A4B2DBDBDBDBDBDBDBB6A3A3BAC5B6AEAAC2DBDBDBDBDBDBDB
          DBB8A1ACADADB0BDDBDBDBDBDBDBDBDBDBDBBDBDB8B9DBDBDBDB}
        OnClick = btnSmoothScaleClick
      end
      object btnMapKeys: TSpeedButton
        Left = 52
        Top = 4
        Width = 23
        Height = 22
        Hint = 'Map Keyboard'
        AllowAllUp = True
        GroupIndex = 3
        Flat = True
        Glyph.Data = {
          76010000424D7601000000000000760000002800000020000000100000000100
          04000000000000010000120B0000120B00001000000000000000000000000000
          800000800000008080008000000080008000808000007F7F7F00BFBFBF000000
          FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00333333033333
          333333333373F3333333333330F033333333333337373F33333333330FFF0333
          33333333733F73F333333330F80FF033333333373373373F3333330F80F7FF03
          33333373373F3F73F33330F70F0F0FF03333373F737373F73F33330F77F7F0FF
          03333373F33F373F73F33330F70F0F0FF03333373F737373373F33330F77F7F7
          FF03333373F33F3F3F73333330F70F0F07F03333373F737373373333330F77FF
          7F0333333373F33F337333333330F707F033333333373F733733333333330F7F
          03333333333373F373F33333333330F0303333F3F3F3F73737F3303030303303
          3033373737373F7FF73303030303000003337373737377777333}
        NumGlyphs = 2
        OnClick = btnMapKeysClick
      end
      object btnExactCursor: TSpeedButton
        Left = 76
        Top = 4
        Width = 23
        Height = 22
        Hint = 'Exact Mouse Cursor'
        AllowAllUp = True
        GroupIndex = 4
        Flat = True
        Glyph.Data = {
          76010000424D7601000000000000760000002800000020000000100000000100
          04000000000000010000120B0000120B00001000000000000000000000000000
          800000800000008080008000000080008000808000007F7F7F00BFBFBF000000
          FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00333333000333
          3333333337773F333333333330FFF03333333333733373F3333333330FFFFF03
          33333337F33337F3333333330FFFFF0333333337F33337F3333333330FFFFF03
          33333337FFFFF7F3333333330777770333333337777777F3333333330FF7FF03
          33333337F37F37F3333333330FF7FF03333333373F7FF7333333333330000033
          33333333777773FFF33333333330330007333333337F37777F33333333303033
          307333333373733377F33333333303333303333333F7F33337F3333333330733
          330333333F777F3337F333333370307330733333F77377FF7733333337033300
          0733333F77333777733333337033333333333337733333333333}
        NumGlyphs = 2
        OnClick = btnExactCursorClick
      end
      object btnGetSelected: TSpeedButton
        Left = 260
        Top = 3
        Width = 25
        Height = 24
        Hint = 'Download Selected File or Folder'
        Flat = True
        Glyph.Data = {
          36030000424D3603000000000000360000002800000010000000100000000100
          18000000000000030000120B0000120B00000000000000000000FF00FF0274AC
          0274AC0274AC0274AC0274AC0274AC0274AC0274AC0274AC0274AC0274AC0274
          AC0274ACFF00FFFF00FFA56F6FA56F6FA56F6FA56F6FA56F6FA56F6FA56F6F4A
          BFF74ABFF64ABFF74ABFF64BC0F72398CC0274ACFF00FFFF00FFA56F6FFEFCFA
          FEFCFAFEFCFAFEFCFAFEFCFA346D2B046B0B046B0B046B0B37ABA353C7F7279D
          CE6ACBE50274ACFF00FFA56F6FFEF7F0FEF7F0FEF7F0FEF7F0FEF7F0A56F6F4C
          C0CA046B0B088013046B0B32A4822AA0C799EDF70274ACFF00FFA56F6FFEF3E7
          FEF3E7FEF3E7FEF3E7FEF3E7A56F6F69DCFB6ADCFB046B0B14A428046B0B2092
          8A9FF0F70274ACFF00FFA56F6FFFEEE0FFEEE0FFEEE0F8E1D4F8E1D4A56F6F74
          E5FC74E5FC42AF91046B0B21B43E046B0B97EBE552BBD70274ACA56F6FFFEAD7
          FFEAD7FFEAD7C28887C28987B57A7A97DCCF88D0BB689667046B0B35D05D046B
          0B80A7818CAD970274ACA56F6FFFE5CEFFE5CEEFCBBAC99692C4B8B1BF818102
          6D66046B0B046B0B2EC2533FDA6E2AB64C046B0B046B0B0274ACA56F6FFFE1C5
          FFE1C5EFC7B4CE9997BF818182F3FE83F2FE48B58E046B0B42E17548E98033C2
          5A046B0BEBEDE0A56F6FA56F6FA56F6FA56F6FA56F6FBF81818AF8FE8AFAFE89
          F8FE8AFAFE58643D046B0B2DBC53046B0BEAE7D5FEF3E7A56F6FFF00FF0274AC
          FEFEFE8FFEFF8FFEFF8FFEFF0274AC0274AC0274ACA56F6F6AA060046B0BE7E1
          CBF8E1D4F8E1D4A56F6FFF00FFFF00FF0274AC0274AC0274AC0274ACFF00FFFF
          00FFFF00FFA56F6FFFEAD7FFEAD7FFEAD7C28887C28987B57A7AFF00FFFF00FF
          FF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFA56F6FFFE5CEFFE5CEEFCB
          BAC99692C4B8B1BF8181FF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF
          00FFFF00FFA56F6FFFE1C5FFE1C5EFC7B4CE9997BF8181FF00FFFF00FFFF00FF
          FF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFA56F6FA56F6FA56F6FA56F
          6FBF8181FF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF
          00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FF}
        OnClick = btnGetSelectedClick
      end
    end
    object panSettings: TPanel
      Left = 10
      Top = 83
      Width = 463
      Height = 198
      ParentBackground = False
      TabOrder = 1
      Visible = False
      object Label1: TLabel
        Left = 4
        Top = 4
        Width = 407
        Height = 14
        Caption = 
          'Select Desktop Options which you want to change and click the OK' +
          ' button.'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Arial'
        Font.Style = [fsBold]
        ParentFont = False
      end
      object Label2: TLabel
        Left = 8
        Top = 100
        Width = 74
        Height = 14
        Caption = 'Send Screen in'
      end
      object Label3: TLabel
        Left = 8
        Top = 28
        Width = 79
        Height = 14
        Caption = 'High Color depth'
      end
      object Label5: TLabel
        Left = 8
        Top = 52
        Width = 80
        Height = 14
        Caption = 'Low Color depth'
      end
      object Label6: TLabel
        Left = 256
        Top = 28
        Width = 55
        Height = 14
        Caption = 'Frame Rate'
      end
      object Label7: TLabel
        Left = 256
        Top = 52
        Width = 136
        Height = 14
        Caption = 'Capture Layered Windows?'
      end
      object Label8: TLabel
        Left = 256
        Top = 76
        Width = 119
        Height = 14
        Caption = 'Use Video Mirror Driver?'
      end
      object Label9: TLabel
        Left = 256
        Top = 100
        Width = 127
        Height = 14
        Caption = 'Desktop from all Monitors?'
      end
      object Label10: TLabel
        Left = 256
        Top = 124
        Width = 139
        Height = 14
        Caption = 'Enable Virtual Mouse Driver?'
      end
      object Label4: TLabel
        Left = 4
        Top = 76
        Width = 189
        Height = 14
        Caption = 'Use Low Colors if it will reduce size by'
      end
      object Label11: TLabel
        Left = 236
        Top = 76
        Width = 10
        Height = 14
        Caption = '%'
      end
      object Label12: TLabel
        Left = 8
        Top = 172
        Width = 77
        Height = 14
        Caption = 'Max Frame Size'
      end
      object Label13: TLabel
        Left = 8
        Top = 124
        Width = 69
        Height = 14
        Caption = 'Refine Screen'
      end
      object Label14: TLabel
        Left = 8
        Top = 148
        Width = 79
        Height = 14
        Caption = 'Scr.Refine delay'
      end
      object grpMirror: TComboBox
        Left = 404
        Top = 72
        Width = 53
        Height = 22
        Style = csDropDownList
        ItemHeight = 14
        TabOrder = 9
        Items.Strings = (
          'YES'
          'NO')
      end
      object grpMouse: TComboBox
        Left = 404
        Top = 120
        Width = 53
        Height = 22
        Style = csDropDownList
        ItemHeight = 14
        TabOrder = 11
        Items.Strings = (
          'YES'
          'NO')
      end
      object grpLayered: TComboBox
        Left = 404
        Top = 48
        Width = 53
        Height = 22
        Style = csDropDownList
        ItemHeight = 14
        TabOrder = 8
        Items.Strings = (
          'YES'
          'NO')
      end
      object grpScreenBlocks: TComboBox
        Left = 92
        Top = 96
        Width = 149
        Height = 22
        Style = csDropDownList
        DropDownCount = 25
        ItemHeight = 14
        TabOrder = 3
        Items.Strings = (
          '1 complete Frame'
          '2 partial Frames/Blocks'
          '3 partial Frames/Blocks'
          '4 partial Frames/Blocks'
          '5 partial Frames/Blocks'
          '6 partial Frames/Blocks'
          '7 partial Frames/Blocks'
          '8 partial Frames/Blocks'
          '9 partial Frames/Blocks'
          '10 partial Frames/Blocks'
          '11 partial Frames/Blocks'
          '12 partial Frames/Blocks')
      end
      object grpMonitors: TComboBox
        Left = 404
        Top = 96
        Width = 53
        Height = 22
        Style = csDropDownList
        ItemHeight = 14
        TabOrder = 10
        Items.Strings = (
          'YES'
          'NO')
      end
      object grpColor: TComboBox
        Left = 92
        Top = 24
        Width = 149
        Height = 22
        Style = csDropDownList
        DropDownCount = 25
        ItemHeight = 14
        TabOrder = 0
        Items.Strings = (
          '8 bit = 256 colors'
          '16 bit = 65.536 colors'
          '4 bit = 16 colors'
          '6 bit = 64 colors'
          '9 bit = 512 colors'
          '12 bit = 4.096 colors'
          '15 bit = 32.768 colors'
          '18 bit = 262.144 colors'
          '21 bit = 2 Million colors'
          '32 bit = True Color')
      end
      object grpFrame: TComboBox
        Left = 316
        Top = 24
        Width = 141
        Height = 22
        Style = csDropDownList
        DropDownCount = 25
        ItemHeight = 14
        TabOrder = 7
        Items.Strings = (
          'Maximum'
          '50 Frames per second'
          '40 Frames per second'
          '25 Frames per second'
          '20 Frames per second'
          '10 Frames per second'
          '8 Frames per second'
          '5 Frames per second'
          '4 Frames per second'
          '2 Frames per second'
          '1 Frames per second'
          '10 ms delay per Frame'
          '20 ms delay per Frame'
          '40 ms delay per Frame'
          '50 ms delay per Frame'
          '80 ms delay per Frame'
          '100 ms delay per Frame'
          '200 ms delay per Frame'
          '250 ms delay per Frame'
          '400 ms delay per Frame'
          '500 ms delay per Frame')
      end
      object btnCancel: TBitBtn
        Left = 284
        Top = 152
        Width = 73
        Height = 33
        Caption = 'Cancel'
        ModalResult = 2
        TabOrder = 12
        TabStop = False
        OnClick = btnCancelClick
        Glyph.Data = {
          DE010000424DDE01000000000000760000002800000024000000120000000100
          0400000000006801000000000000000000001000000000000000000000000000
          80000080000000808000800000008000800080800000C0C0C000808080000000
          FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00333333333333
          333333333333333333333333000033338833333333333333333F333333333333
          0000333911833333983333333388F333333F3333000033391118333911833333
          38F38F333F88F33300003339111183911118333338F338F3F8338F3300003333
          911118111118333338F3338F833338F3000033333911111111833333338F3338
          3333F8330000333333911111183333333338F333333F83330000333333311111
          8333333333338F3333383333000033333339111183333333333338F333833333
          00003333339111118333333333333833338F3333000033333911181118333333
          33338333338F333300003333911183911183333333383338F338F33300003333
          9118333911183333338F33838F338F33000033333913333391113333338FF833
          38F338F300003333333333333919333333388333338FFF830000333333333333
          3333333333333333333888330000333333333333333333333333333333333333
          0000}
        NumGlyphs = 2
      end
      object btnAccept: TBitBtn
        Left = 380
        Top = 152
        Width = 65
        Height = 33
        Caption = 'OK'
        ModalResult = 1
        TabOrder = 13
        TabStop = False
        OnClick = btnAcceptClick
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
      object grpColorLow: TComboBox
        Left = 92
        Top = 48
        Width = 149
        Height = 22
        Style = csDropDownList
        DropDownCount = 25
        ItemHeight = 14
        TabOrder = 1
        OnChange = grpColorLowChange
        Items.Strings = (
          '= High Color depth'
          '6 bit = 64 colors'
          '9 bit = 512 colors'
          '12 bit = 4.096 colors'
          '15 bit = 32.768 colors'
          '18 bit = 262.144 colors'
          '21 bit = 2 Million colors'
          '= High Color @ 6 bit'
          '= High Color @ 9 bit'
          '= High Color @ 12 bit'
          '= High Color @ 15 bit'
          '= High Color @ 18 bit'
          '= High Color @ 21 bit')
      end
      object cbReduceColors: TSpinEdit
        Left = 196
        Top = 72
        Width = 41
        Height = 23
        MaxValue = 99
        MinValue = 0
        TabOrder = 2
        Value = 0
      end
      object grpScreenLimit: TComboBox
        Left = 92
        Top = 168
        Width = 149
        Height = 22
        Style = csDropDownList
        DropDownCount = 25
        ItemHeight = 14
        TabOrder = 6
        Items.Strings = (
          'Automatic (1 Frame)'
          '8 Kbit = 1 KB'
          '16 Kbit = 2 KB'
          '32 Kbit = 4 KB'
          '64 Kbit = 8 KB'
          '96 Kbit = 12KB'
          '128 Kbit = 16 KB'
          '192 Kbit = 24 KB'
          '256 Kbit = 32 KB'
          '384 Kbit = 48 KB'
          '512 Kbit = 64 KB'
          '768 Kbit = 96 KB'
          '1024 Kbit = 128 KB'
          '1536 Kbit = 192 KB'
          '2048 Kbit = 256 KB'
          '3072 Kbit = 384 KB'
          '4096 Kbit = 512 KB')
      end
      object grpScreenBlocks2: TComboBox
        Left = 92
        Top = 120
        Width = 149
        Height = 22
        Style = csDropDownList
        DropDownCount = 25
        ItemHeight = 14
        TabOrder = 4
        Items.Strings = (
          'Auto (2 x Send Frames)'
          'in 2 Frames/Steps'
          'in 3 Frames/Steps'
          'in 4 Frames/Steps'
          'in 5 Frames/Steps'
          'in 6 Frames/Steps'
          'in 7 Frames/Steps'
          'in 8 Frames/Steps'
          'in 9 Frames/Steps'
          'in 10 Frames/Steps'
          'in 11 Frames/Steps'
          'in 12 Frames/Steps')
      end
      object grpScreen2Refine: TComboBox
        Left = 92
        Top = 144
        Width = 149
        Height = 22
        Style = csDropDownList
        DropDownCount = 25
        ItemHeight = 14
        TabOrder = 5
        Items.Strings = (
          '0.5 Seconds'
          '1 Second'
          '2 Seconds'
          '3 Seconds'
          '4 Seconds'
          '5 Seconds'
          '6 Seconds'
          '7 Seconds'
          '8 Seconds'
          '9 Seconds'
          '10 Seconds'
          '11 Seconds'
          '12 Seconds'
          '13 Seconds'
          '14 Seconds'
          '15 Seconds'
          '16 Seconds'
          '17 Seconds'
          '18 Seconds'
          '19 Seconds'
          '20 Seconds')
      end
    end
  end
  object myUI: TRtcPDesktopControlUI
    AutoScroll = True
    Viewer = pImage
    OnOpen = myUIOpen
    OnClose = myUIClose
    OnError = myUIError
    OnLogOut = myUILogOut
    OnData = myUIData
    Left = 372
    Top = 8
  end
  object DesktopTimer: TTimer
    Enabled = False
    OnTimer = DesktopTimerTimer
    Left = 412
    Top = 8
  end
end
