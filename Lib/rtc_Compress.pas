{ Copyright 2004-2017 (c) RealThinClient.com (http://www.realthinclient.com) 
 @exclude }

// pure pascal implementation of rtcCompress
unit rtc_Compress;

interface

uses
  rtcTypes;

{$INCLUDE rtcDefs.inc}
function DWord_Compress_Delta(const LastBlock, NowBlock, DestBlock: pointer;
  const BlockSize: longword): longword;
function DWord_Compress_Normal(const NowBlock, DestBlock: pointer;
  const BlockSize: longword): longword;

function DWord_Decompress(const SrcBlock, DestBlock: pointer;
  const Offset, SrcLen, BlockSize: longword): boolean;

implementation

type
  PLongWord = ^longword;
  PWord = ^Word;
  PByte = ^Byte;

  // Memory reserved by "DestBlock" needs to be at least 2 x BlockSize bytes
  // Result = number of bytes writen to DestBlock
function DWord_Compress_Delta(const LastBlock, NowBlock, DestBlock: pointer;
  const BlockSize: longword): longword;
var
  ptrTmp, ptrNow, ptrLast, ptrDest: ^Byte;
  w: ^Word;
  dw: ^longword;
  cnt_byte, cnt_dword: longint;
  have_not_equal: boolean;
  EAX, EBX, ECX, EDX: longword;
  ESI, EDI: PLongWord;
  ByteEDI: PByte;
  WordEDI: PWord;
begin
  ptrLast := LastBlock; // Old image
  ptrNow := NowBlock; // New image
  ptrDest := DestBlock; // Destination image

  cnt_byte := BlockSize and 3; // rest-bytes
  cnt_dword := BlockSize shr 2;

  { Codes:
    count:byte (1..241) = skip (byte) count*4 bytes

    #242 + count:word = skip (word) count*4 bytes
    #243 + count:longword = skip (longword) count*4 bytes

    #244 + count:byte + value:byte = repeat byte value count*4 times
    #245 + count:byte + value:word = repeat word value count*2 times
    #246 + count:byte + value:longword = repeat longword value count times

    #247 + count:word + value:byte= repeat byte value count*4 times
    #248 + count:word + value:word = repeat word value count*2 times
    #249 + count:word + value:longword = repeat longword value count times

    #250 + count:longword + value:byte= repeat byte value count*4 times
    #251 + count:longword + value:word = repeat word value count*2 times
    #252 + count:longword + value:longword = repeat longword value count times

    #253 + count:byte + data = copy (byte) count*4 bytes of data
    #254 + count:word + data = copy (word) count*2 words of data
    #255 + count:longword + data = copy (longword) count dwords of data

    #0 + count:byte + data = copy (byte) count bytes of data }

  ECX := cnt_dword;
  ESI := PLongWord(ptrNow);
  EDI := PLongWord(ptrLast);

  repeat
    { We need:
      ECX = cnt_dword (number of dwords left to check
      ESI = ptrNow position to start scanning
      EDI = ptrLast position to start scanning }

    { Count where equal ... }

    EDX := ECX; // number of dwords to check

    // Count all Equal dwords
    repeat
      if EDI^ = ESI^ then
      begin
        Inc(EDI);
        Inc(ESI);
        Dec(ECX);
      end
      else
        Break;
    until ECX = 0;

    if ECX = 0 then // all that's left is equal
    begin
      ptrNow := pointer(ESI);
      ptrLast := pointer(EDI);
      Break;
    end;

    Dec(EDX, ECX); // number of dwords where "source=dest"

    if EDX > 0 then
    begin // moved?
      { * if we have equal bytes, do ... * }

      ptrNow := pointer(ESI); // update ptrNow
      ptrLast := pointer(EDI); // update ptrLast and store EDI

      { Write jump-header ... }
      EDI := PLongWord(ptrDest);

      if EDX <= $FFFF then
      begin
        if EDX <= 241 then
        begin
          ByteEDI := PByte(EDI);
          ByteEDI^ := EDX;
          Inc(ByteEDI);

          EDI := PLongWord(ByteEDI);
        end
        else
        begin
          ByteEDI := PByte(EDI);
          ByteEDI^ := 242;
          Inc(ByteEDI);

          WordEDI := PWord(ByteEDI);
          WordEDI^ := EDX;
          Inc(WordEDI);

          EDI := PLongWord(WordEDI);
        end;
      end
      else
      begin
        ByteEDI := PByte(EDI);
        ByteEDI^ := 243;
        Inc(ByteEDI);

        EDI := PLongWord(ByteEDI);
        EDI^ := EDX;
        Inc(EDI);
      end;
      ptrDest := pointer(EDI); // update ptrDest

      EDI := PLongWord(ptrLast); // restore EDI
    end; { * done equal dwords. * }

    { Count where not equal ... }
    EDX := ECX; // EDX = dwords left to check

    // Count all un-equal drowds
    repeat
      if EDI^ <> ESI^ then
      begin
        Inc(EDI);
        Inc(ESI);
        Dec(ECX);
      end
      else
        Break;
    until ECX = 0;

    if ECX > 0 then // found equal dwords?
      Dec(EDX, ECX); // EDX = Non-Equal count

    cnt_dword := ECX; // update cnt_dword to dwords left to check on next run
    ptrLast := pointer(EDI); // update ptrLast for next run

    { ------------------
      Copy changed data ...
      ------------------ }

    { until here, we've prepared:
      - cnt_dword & ptrLast for the next run (if there will be one)
      - ptrNow to first non-equal longword position
      - ptrDest to next writing position
      - EDX to number of non-equal dwords to check and compress }

    // prepare ESI & ECX for iterations using LODSD
    ECX := EDX; // ECX = non-equal longword count

    // @count_repeating:
    repeat
      { from here, we need:
        ECX = dwords left to check
        ptrNow & ptrDest point to current source & dest location }

      { Count how many times "EAX" is repeating ... }

      EDI := PLongWord(ptrNow); // EDI = first non-equal longword position
      EDX := ECX; // dwords left to check
      EAX := EDI^; // load first longword (will scan for this one)

      repeat
        if EDI^ = EAX then
          Inc(EDI)
        else
          Break;
        Dec(ECX);
      until ECX = 0;

      Dec(EDX, ECX); // repeating dwords count

      if EDX > 1 then
      begin
        ptrNow := pointer(EDI);
        // update ptrNow (behind last repeating longword)

        { from here, we need:
          ptrNow = position after last repeating longword
          EAX = repeating longword (data)
          EDX = number of times EAX is repeating
          ECX = number of dwords left to check (non-repeating)
          EDI = ptrNow location behind last equal longword }

        { Write info about compressed dwords ... }
        EDI := PLongWord(ptrDest); // get ptrDest
        { write repeating header }
        if EDX <= $FFFF then
        begin
          if EDX <= $FF then
          begin
            ByteEDI := PByte(EDI);
            ByteEDI^ := 246;
            Inc(ByteEDI);
            ByteEDI^ := EDX;
            Inc(ByteEDI);

            EDI := PLongWord(ByteEDI);
            EDI^ := EAX;
            Inc(EDI);
          end
          else
          begin
            ByteEDI := PByte(EDI);
            ByteEDI^ := 249;
            Inc(ByteEDI);

            WordEDI := PWord(ByteEDI);
            WordEDI^ := EDX;
            Inc(WordEDI);

            EDI := PLongWord(WordEDI);
            EDI^ := EAX;
            Inc(EDI);
          end;
        end
        else
        begin
          ByteEDI := PByte(EDI);
          ByteEDI^ := 252;
          Inc(ByteEDI);

          EDI := PLongWord(ByteEDI);
          EDI^ := EDX;
          Inc(EDI);
          EDI^ := EAX;
          Inc(EDI);
        end;

        ptrDest := pointer(EDI); // update ptrDest

        // EDX:=ECX;                     // dwords left to check
      end
      else
      begin
        { from here, we need:
          ptrDest = next writing position
          ptrNow = next ptrNow longword to check
          ECX = number of non-equal dwords left - 1
          EDX = number of dwords checked }

        ESI := EDI;
        if ECX > 0 then // one longword can't be compressed.
        begin
          Inc(EDX, ECX);
          { Check how many dwords we can't compress using RLE }
          repeat
            EAX := ESI^; // store last longword
            Inc(ESI); // load next longword
            if ESI^ = EAX then // longwords match? done.
            begin
              Break;
              Inc(ECX);
            end;
            Dec(ECX);
          until ECX = 0;
          Dec(EDX, ECX); // EDX = non-repeating longword count
        end;

        { from here, we need:
          ECX = number of dwords left to check (if >0, count repeating)
          EDX = number of non-repeating dwords to copy
          ptrNow & ptrDest point to current source & dest location }

        EBX := ECX; // EBX = save ECX (non-equal dwords left to check)

        ECX := EDX; // ECX = dwords to copy
        ESI := PLongWord(ptrNow); // read from ptrNow
        EDI := PLongWord(ptrDest); // write to ptrDest

        { Write "EDX" dwords down }
        // write normal header ...
        if EDX <= $FFFF then
        begin
          if EDX <= $FF then
          begin
            ByteEDI := PByte(EDI);
            ByteEDI^ := 253;
            Inc(ByteEDI);
            ByteEDI^ := EDX;
            Inc(ByteEDI);

            EDI := PLongWord(ByteEDI);
          end
          else
          begin
            ByteEDI := PByte(EDI);
            ByteEDI^ := 254;
            Inc(ByteEDI);

            WordEDI := PWord(ByteEDI);
            WordEDI^ := EDX;
            Inc(WordEDI);

            EDI := PLongWord(WordEDI);
          end;
        end
        else
        begin
          ByteEDI := PByte(EDI);
          ByteEDI^ := 255;
          Inc(ByteEDI);

          EDI := PLongWord(ByteEDI);
          EDI^ := EDX;
          Inc(EDI);
        end;

        Move(ESI^, EDI^, ECX * 4); // copy dwords

        Inc(ESI, ECX);
        Inc(EDI, ECX);
        ptrNow := pointer(ESI);
        ptrDest := pointer(EDI);

        ECX := EBX; // restore ECX (dwords left to check)
      end;
    until ECX = 0;
    // have repeating dwords ...

    ESI := PLongWord(ptrNow);
    EDI := PLongWord(ptrLast);
    ECX := cnt_dword;

  until ECX = 0;

  if cnt_byte > 0 then
  begin
    have_not_equal := True;
    if (ptrLast^ = ptrNow^) then
    begin
      ptrTmp := ptrNow;
      Inc(ptrLast);
      Inc(ptrTmp);
      if (cnt_byte < 2) or (ptrLast^ = ptrTmp^) then
      begin
        Inc(ptrLast);
        Inc(ptrTmp);
        if (cnt_byte < 3) or (ptrLast^ = ptrTmp^) then
          have_not_equal := False;
      end;
    end;

    if have_not_equal then
    begin
      if cnt_dword > $FFFF then
      begin
        // write equal count
        ptrDest^ := 243;
        Inc(ptrDest);

        dw := pointer(ptrDest);
        dw^ := cnt_dword;
        Inc(ptrDest, 4);
      end
      else if cnt_dword > 241 then
      begin
        // write equal count
        ptrDest^ := 242;
        Inc(ptrDest);

        w := pointer(ptrDest);
        w^ := cnt_dword;
        Inc(ptrDest, 2);
      end
      else if cnt_dword > 0 then
      begin
        // write equal count
        ptrDest^ := cnt_dword;
        Inc(ptrDest);
      end;

      if cnt_byte > 0 then
      begin
        // Copy last few bytes of new image
        ptrDest^ := 0; // finishing bytes
        Inc(ptrDest);
        ptrDest^ := cnt_byte;
        Inc(ptrDest);
        repeat
          ptrDest^ := ptrNow^;
          Inc(ptrDest);
          Inc(ptrNow);
          Dec(cnt_byte);
        until cnt_byte = 0;
      end;
    end;
  end;

  // Calculate packed size ...
  Result := RtcIntPtr(ptrDest) - RtcIntPtr(DestBlock);
end;

function DWord_Compress_Normal(const NowBlock, DestBlock: pointer;
  const BlockSize: longword): longword;
var
  ptrNow, ptrDest: PByte;
  cnt_byte, cnt_dword: longint;

  ECX, EDX, EBX, EAX: longword;
  ESI, EDI: PLongWord;
  ByteEDI: PByte;
  WordEDI: PWord;
begin
  ptrNow := NowBlock; // New image
  ptrDest := DestBlock; // Destination image

  cnt_byte := BlockSize and 3; // rest-bytes
  cnt_dword := BlockSize shr 2;

  { Codes:
    count:byte (1..241) = skip (byte) count*4 bytes

    #242 + count:word = skip (word) count*4 bytes
    #243 + count:longword = skip (longword) count*4 bytes

    #244 + count:byte + value:byte = repeat byte value count*4 times
    #245 + count:byte + value:word = repeat word value count*2 times
    #246 + count:byte + value:longword = repeat longword value count times

    #247 + count:word + value:byte= repeat byte value count*4 times
    #248 + count:word + value:word = repeat word value count*2 times
    #249 + count:word + value:longword = repeat longword value count times

    #250 + count:longword + value:byte= repeat byte value count*4 times
    #251 + count:longword + value:word = repeat word value count*2 times
    #252 + count:longword + value:longword = repeat longword value count times

    #253 + count:byte + data = copy (byte) count*4 bytes of data
    #254 + count:word + data = copy (word) count*2 words of data
    #255 + count:longword + data = copy (longword) count dwords of data

    #0 + count:byte + data = copy (byte) count bytes of data }

  ECX := cnt_dword;

  { until here, we've prepared:
    - cnt_dword & ptrLast for the next run (if there will be one)
    - ptrNow to first non-equal longword position
    - ptrDest to next writing position
    - EDX to number of non-equal dwords to check and compress }

  repeat
    { from here, we need:
      ECX = dwords left to check
      ptrNow & ptrDest point to current source & dest location }

    { Count how many times "EAX" is repeating ... }

    EDI := PLongWord(ptrNow); // EDI = first non-equal longword position
    EDX := ECX; // dwords left to check
    EAX := EDI^; // load first longword (will scan for this one)

    repeat
      if EDI^ = EAX then
        Inc(EDI)
      else
        Break;
      Dec(ECX);
    until ECX = 0;

    Dec(EDX, ECX); // repeating dwords count

    if EDX > 1 then
    begin
      ptrNow := PByte(EDI); // update ptrNow (behind last repeating longword)

      { from here, we need:
        ptrNow = position after last repeating longword
        EAX = repeating longword (data)
        EDX = number of times EAX is repeating
        ECX = number of dwords left to check (non-repeating)
        EDI = ptrNow location behind last equal longword }

      { Write info about compressed dwords ... }
      EDI := PLongWord(ptrDest); // get ptrDest
      { write repeating header }
      if EDX <= $FFFF then
      begin
        if EDX <= $FF then
        begin
          ByteEDI := PByte(EDI);
          ByteEDI^ := 246;
          Inc(ByteEDI);
          ByteEDI^ := EDX;
          Inc(ByteEDI);

          EDI := PLongWord(ByteEDI);
          EDI^ := EAX;
          Inc(EDI);
        end
        else
        begin
          ByteEDI := PByte(EDI);
          ByteEDI^ := 249;
          Inc(ByteEDI);

          WordEDI := PWord(ByteEDI);
          WordEDI^ := EDX;
          Inc(WordEDI);

          EDI := PLongWord(WordEDI);
          EDI^ := EAX;
          Inc(EDI);
        end;
      end
      else
      begin
        ByteEDI := PByte(EDI);
        ByteEDI^ := 252;
        Inc(ByteEDI);

        EDI := PLongWord(ByteEDI);
        EDI^ := EDX;
        Inc(EDI);
        EDI^ := EAX;
        Inc(EDI);
      end;

      ptrDest := PByte(EDI); // update ptrDest

      // EDX:=ECX;                     // dwords left to check
    end
    else
    begin
      { from here, we need:
        ptrDest = next writing position
        ptrNow = next ptrNow longword to check
        ECX = number of non-equal dwords left - 1
        EDX = number of dwords checked }

      ESI := EDI;
      if ECX > 0 then // one longword can't be compressed.
      begin
        Inc(EDX, ECX);
        { Check how many dwords we can't compress using RLE }
        repeat
          EAX := ESI^; // store last longword
          Inc(ESI); // load next longword
          if ESI^ = EAX then // longwords match? done.
          begin
            Break;
            Inc(ECX);
          end;
          Dec(ECX);
        until ECX = 0;
        Dec(EDX, ECX); // EDX = non-repeating longword count
      end;

      { from here, we need:
        ECX = number of dwords left to check (if >0, count repeating)
        EDX = number of non-repeating dwords to copy
        ptrNow & ptrDest point to current source & dest location }

      EBX := ECX; // EBX = save ECX (non-equal dwords left to check)

      ECX := EDX; // ECX = dwords to copy
      ESI := PLongWord(ptrNow); // read from ptrNow
      EDI := PLongWord(ptrDest); // write to ptrDest

      { Write "EDX" dwords down }
      // write normal header ...
      if EDX <= $FFFF then
      begin
        if EDX <= $FF then
        begin
          ByteEDI := PByte(EDI);
          ByteEDI^ := 253;
          Inc(ByteEDI);
          ByteEDI^ := EDX;
          Inc(ByteEDI);

          EDI := PLongWord(ByteEDI);
        end
        else
        begin
          ByteEDI := PByte(EDI);
          ByteEDI^ := 254;
          Inc(ByteEDI);

          WordEDI := PWord(ByteEDI);
          WordEDI^ := EDX;
          Inc(WordEDI);

          EDI := PLongWord(WordEDI);
        end;
      end
      else
      begin
        ByteEDI := PByte(EDI);
        ByteEDI^ := 255;
        Inc(ByteEDI);

        EDI := PLongWord(ByteEDI);
        EDI^ := EDX;
        Inc(EDI);
      end;

      Move(ESI^, EDI^, ECX * 4); // copy dwords

      Inc(ESI, ECX);
      Inc(EDI, ECX);
      ptrNow := PByte(ESI);
      ptrDest := PByte(EDI);

      ECX := EBX; // restore ECX (dwords left to check)
    end;
  until ECX = 0;

  if cnt_byte > 0 then
  begin
    // Copy last few bytes of new image
    ptrDest^ := 0; // finishing bytes
    Inc(ptrDest);
    ptrDest^ := cnt_byte;
    Inc(ptrDest);
    repeat
      ptrDest^ := ptrNow^;
      Inc(ptrDest);
      Inc(ptrNow);
      Dec(cnt_byte);
    until cnt_byte = 0;
  end;

  // Calculate packed size ...
  Result := RtcIntPtr(ptrDest) - RtcIntPtr(DestBlock);
end;

function DWord_Decompress(const SrcBlock, DestBlock: pointer;
  const Offset, SrcLen, BlockSize: longword): boolean;
var
  b, bv: ^Byte;
  w, wv: ^Word;
  dw, dv: ^longword;
  id: ^AnsiChar;

  len: longword;
  ptrDest, ptrOrig: ^Byte;

  procedure FillDWord(fill: longword; data: pointer; cnt: longword);
  var
    a: longword;
    longdata: PLongWord absolute data;
  begin
    for a := 1 to cnt do
    begin
      longdata^ := fill;
      Inc(longdata);
    end;
  end;
  procedure FillWord(fill: longword; data: pointer; cnt: longword);
  begin
    Inc(fill, fill shl 16);
    FillDWord(fill, data, cnt);
  end;
  procedure FillByte(fill: longword; data: pointer; cnt: longword);
  begin
    Inc(fill, fill shl 8);
    Inc(fill, fill shl 16);
    FillDWord(fill, data, cnt);
  end;

begin
  Result := True;

  len := SrcLen;
  id := SrcBlock;
  ptrOrig := DestBlock;

  { Codes:
    #242 + count:word = skip (word) count*4 bytes
    #243 + count:longword = skip (longword) count*4 bytes

    #244 + count:byte + value:byte = repeat byte value count*4 times
    #245 + count:byte + value:word = repeat word value count*2 times
    #246 + count:byte + value:longword = repeat longword value count times

    #247 + count:word + value:byte= repeat byte value count*4 times
    #248 + count:word + value:word = repeat word value count*2 times
    #249 + count:word + value:longword = repeat longword value count times

    #250 + count:longword + value:byte= repeat byte value count*4 times
    #251 + count:longword + value:word = repeat word value count*2 times
    #252 + count:longword + value:longword = repeat longword value count times

    #253 + count:byte + data = copy (byte) count*4 bytes of data
    #254 + count:word + data = copy (word) count*2 words of data
    #255 + count:longword + data = copy (longword) count dwords of data

    #0 + count:byte + data = copy (byte) count bytes of data
    count:byte (1..241) = skip (byte) count*4 bytes }

  Inc(ptrOrig, Offset);
  ptrDest := ptrOrig;
  while (len > 0) do
  begin
    case id^ of
      #242: // count:word = skip count*4 bytes
        begin
          Inc(id);
          Dec(len);

          w := pointer(id); // get count
          Inc(id, 2);
          Dec(len, 2);

          Assert(longword(ptrDest) - longword(ptrOrig) + w^ * 4 <= BlockSize);

          Inc(ptrDest, w^ * 4);
        end;
      #243: // count:longword = skip count*4 bytes
        begin
          Inc(id);
          Dec(len);

          dw := pointer(id); // get count
          Inc(id, 4);
          Dec(len, 4);

          Assert(longword(ptrDest) - longword(ptrOrig) + dw^ * 4 <= BlockSize);

          Inc(ptrDest, dw^ * 4);
        end;

      #244: // count:byte + value:byte = repeat value count*4 times
        begin
          Inc(id);
          Dec(len);

          b := pointer(id); // get byte count
          Inc(id);
          Dec(len);

          bv := pointer(id); // get byte value
          Inc(id);
          Dec(len);

          Assert(longword(ptrDest) - longword(ptrOrig) + b^ * 4 <= BlockSize);

          FillByte(bv^, ptrDest, b^);

          Inc(ptrDest, b^ * 4);
        end;
      #245: // count:byte + value:word = repeat value count*2 times
        begin
          Inc(id);
          Dec(len);

          b := pointer(id); // get byte count
          Inc(id);
          Dec(len);

          wv := pointer(id); // get word value
          Inc(id, 2);
          Dec(len, 2);

          Assert(longword(ptrDest) - longword(ptrOrig) + b^ * 4 <= BlockSize);

          FillWord(wv^, ptrDest, b^);

          Inc(ptrDest, b^ * 4);
        end;
      #246: // count:byte + value:longword = repeat value count times
        begin
          Inc(id);
          Dec(len);

          b := pointer(id); // get byte count
          Inc(id);
          Dec(len);

          dv := pointer(id); // get longword value
          Inc(id, 4);
          Dec(len, 4);

          Assert(longword(ptrDest) - longword(ptrOrig) + b^ * 4 <= BlockSize);

          FillDWord(dv^, ptrDest, b^);

          Inc(ptrDest, b^ * 4);
        end;

      #247: // count:word + value:byte = repeat value count*4 times
        begin
          Inc(id);
          Dec(len);

          w := pointer(id); // get word count
          Inc(id, 2);
          Dec(len, 2);

          bv := pointer(id); // get byte value
          Inc(id);
          Dec(len);

          Assert(longword(ptrDest) - longword(ptrOrig) + w^ * 4 <= BlockSize);

          FillByte(bv^, ptrDest, w^);

          Inc(ptrDest, w^ * 4);
        end;
      #248: // count:word + value:word = repeat value count*2 times
        begin
          Inc(id);
          Dec(len);

          w := pointer(id); // get word count
          Inc(id, 2);
          Dec(len, 2);

          wv := pointer(id); // get word value
          Inc(id, 2);
          Dec(len, 2);

          Assert(longword(ptrDest) - longword(ptrOrig) + w^ * 4 <= BlockSize);

          FillWord(wv^, ptrDest, w^);

          Inc(ptrDest, w^ * 4);
        end;
      #249: // count:word + value:longword = repeat value count times
        begin
          Inc(id);
          Dec(len);

          w := pointer(id); // get word count
          Inc(id, 2);
          Dec(len, 2);

          dv := pointer(id); // get longword value
          Inc(id, 4);
          Dec(len, 4);

          Assert(longword(ptrDest) - longword(ptrOrig) + w^ * 4 <= BlockSize);

          FillDWord(dv^, ptrDest, w^);

          Inc(ptrDest, w^ * 4);
        end;

      #250: // count:longword + value:byte = repeat value count*4 times
        begin
          Inc(id);
          Dec(len);

          dw := pointer(id); // get longword count
          Inc(id, 4);
          Dec(len, 4);

          bv := pointer(id); // get byte value
          Inc(id);
          Dec(len);

          Assert(longword(ptrDest) - longword(ptrOrig) + dw^ * 4 <= BlockSize);

          FillByte(bv^, ptrDest, dw^);

          Inc(ptrDest, dw^ * 4);
        end;
      #251: // count:longword + value:word = repeat value count*2 times
        begin
          Inc(id);
          Dec(len);

          dw := pointer(id); // get longword count
          Inc(id, 4);
          Dec(len, 4);

          wv := pointer(id); // get word value
          Inc(id, 2);
          Dec(len, 2);

          Assert(longword(ptrDest) - longword(ptrOrig) + dw^ * 4 <= BlockSize);

          FillWord(wv^, ptrDest, dw^);

          Inc(ptrDest, dw^ * 4);
        end;
      #252: // count:longword + value:longword = repeat value count times
        begin
          Inc(id);
          Dec(len);

          dw := pointer(id); // get word count
          Inc(id, 4);
          Dec(len, 4);

          dv := pointer(id); // get longword value
          Inc(id, 4);
          Dec(len, 4);

          Assert(longword(ptrDest) - longword(ptrOrig) + dw^ * 4 <= BlockSize);

          FillDWord(dv^, ptrDest, dw^);

          Inc(ptrDest, dw^ * 4);
        end;

      #253: // count:byte + data = copy count*4 bytes of data
        begin
          Inc(id);
          Dec(len);

          b := pointer(id); // get count
          Inc(id);
          Dec(len);

          Assert((len >= b^ * 4) and (longword(ptrDest) - longword(ptrOrig) + b^
            * 4 <= BlockSize));

          Move(id^, ptrDest^, b^ * 4); // CopyDWord(id,ptrDest,b^);
          Inc(id, b^ * 4);
          Dec(len, b^ * 4);

          Inc(ptrDest, b^ * 4);
        end;
      #254: // count:word + data = copy count*4 bytes of data
        begin
          Inc(id);
          Dec(len);

          w := pointer(id); // get count
          Inc(id, 2);
          Dec(len, 2);

          Assert((len >= w^ * 4) and (longword(ptrDest) - longword(ptrOrig) + w^
            * 4 <= BlockSize));

          Move(id^, ptrDest^, w^ * 4); // CopyDWord(id,ptrDest,w^);
          Inc(id, w^ * 4);
          Dec(len, w^ * 4);

          Inc(ptrDest, w^ * 4);
        end;
      #255: // count:longword + data = copy count*4 bytes of data
        begin
          Inc(id);
          Dec(len);

          dw := pointer(id); // get count
          Inc(id, 4);
          Dec(len, 4);

          Assert((len >= dw^ * 4) and (longword(ptrDest) - longword(ptrOrig) +
            dw^ * 4 <= BlockSize));

          Move(id^, ptrDest^, dw^ * 4); // CopyDWord(id,ptrDest,dw^);
          Inc(id, dw^ * 4);
          Dec(len, dw^ * 4);

          Inc(ptrDest, dw^ * 4);
        end;

      #0: // 0 + count:byte + data = copy count finishing bytes
        begin
          Inc(id);
          Dec(len);

          b := pointer(id); // get count
          Inc(id);
          Dec(len);

          Assert((len >= b^) and (longword(ptrDest) - longword(ptrOrig) + b^ <=
            BlockSize));

          Move(id^, ptrDest^, b^);
          Inc(id, b^);
          Dec(len, b^);

          Inc(ptrDest, b^);
        end
    else // count:byte (1..241) = skip count*4 bytes
      begin
        b := pointer(id);
        Inc(id);
        Dec(len);

        Assert((longword(ptrDest) - longword(ptrOrig) + b^ * 4) <= BlockSize);

        Inc(ptrDest, b^ * 4);
      end;
    end;
  end;
end;

end.
