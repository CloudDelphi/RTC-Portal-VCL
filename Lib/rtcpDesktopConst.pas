{ Copyright 2004-2017 (c) RealThinClient.com (http://www.realthinclient.com) }

unit rtcpDesktopConst;

interface

{$INCLUDE rtcPortalDefs.inc}

type
  TrdColorLimit = (rdColor8bit, rdColor16bit, rdColor4bit, rdColor6bit,
    rdColor9bit, rdColor12bit, rdColor15bit, rdColor18bit, rdColor21bit,
    rdColor32bit);

  TrdLowColorLimit = (rd_ColorHigh, rd_Color6bit, rd_Color9bit, rd_Color12bit,
    rd_Color15bit, rd_Color18bit, rd_Color21bit, rd_ColorHigh6bit,
    rd_ColorHigh9bit, rd_ColorHigh12bit, rd_ColorHigh15bit, rd_ColorHigh18bit,
    rd_ColorHigh21bit);

  TrdScreenBlocks = (rdBlocks1, rdBlocks2, rdBlocks3, rdBlocks4, rdBlocks5,
    rdBlocks6, rdBlocks7, rdBlocks8, rdBlocks9, rdBlocks10, rdBlocks11,
    rdBlocks12);

  TrdScreenLimit = (rdBlockAnySize, rdBlock1KB, rdBlock2KB, rdBlock4KB,
    rdBlock8KB, rdBlock12KB, rdBlock16KB, rdBlock24KB, rdBlock32KB, rdBlock48KB,
    rdBlock64KB, rdBlock96KB, rdBlock128KB, rdBlock192KB, rdBlock256KB,
    rdBlock384KB, rdBlock512KB);

  TrdFrameRate = (rdFramesMax, rdFrames50, rdFrames40, rdFrames25, rdFrames20,
    rdFrames10, rdFrames8, rdFrames5, rdFrames4, rdFrames2, rdFrames1,
    rdFrameSleep10, rdFrameSleep20, rdFrameSleep40, rdFrameSleep50,
    rdFrameSleep80, rdFrameSleep100, rdFrameSleep200, rdFrameSleep250,
    rdFrameSleep400, rdFrameSleep500);

implementation

end.
