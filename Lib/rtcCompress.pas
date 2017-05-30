{ Copyright 2004-2017 (c) RealThinClient.com (http://www.realthinclient.com) }

unit rtcCompress;

// When the RTC_FORCE_CLEAR_WHITE directive is declared, color reduction function
// will try to keep white color apear as white and not get darker with lower color depths.
// NOTE: This functionality can cause problems with bad screen updates on some PCs.
{ .$DEFINE RTC_FORCE_CLEAR_WHITE }

interface

{$INCLUDE rtcDefs.inc}
{$INCLUDE rtcPortalDefs.inc}
{ * IMAGE COMPRESSION AND DECOMPRESSION FUNCTIONS * }

procedure DWord_ReduceColors(const NowBlock: pointer; const BlockSize: longword;
  mask: longword);
// procedure DWord_ReduceColors2(const NowBlock:pointer; const BlockSize:longword; mask:longword);

function DWordCompress_Delta(const LastBlock, NowBlock, DestBlock: pointer;
  const BlockSize: longword): longword;
function DWordCompress_Normal(const NowBlock, DestBlock: pointer;
  const BlockSize: longword): longword;

function DWordDecompress(const SrcBlock, DestBlock: pointer;
  const Offset, SrcLen, BlockSize: longword): boolean;

function WordCompress_Delta_New(const LastBlock, NowBlock, DestBlock,
  TempBlock1, TempBlock2, TempBlock3, TempBlock4, TempBlock5,
  TempBlock6: pointer; const Reduce_Colors, Reduce_Colors2: longword;
  var FirstPass: boolean; ReducePercent: integer; const BlockSize: word;
  UpdateLastBlock: boolean): word;

function WordCompress_Normal_New(const LastBlock, NowBlock, DestBlock,
  TempBlock0, TempBlock1, TempBlock2, TempBlock3, TempBlock4: pointer;
  const Reduce_Colors, Reduce_Colors2: longword; var FirstPass: boolean;
  ReducePercent: integer; const BlockSize: word;
  UpdateLastBlock: boolean): word;

function DWordDecompress_New(const SrcBlock, DestBlock, TempBlock1: pointer;
  const Offset, SrcLen, BlockSize: longword): boolean;

implementation

uses
  rtc_Compress;

{$IFDEF RTC_FORCE_CLEAR_WHITE}

procedure DWord_ReduceColors(const NowBlock: pointer; const BlockSize: longword;
  mask: longword);
var
  ptrNow: ^byte;
  cnt_dword: longint;
begin
{$IFDEF CPUX64}
  // todo
{$ELSE}
  ptrNow := NowBlock; // image
  cnt_dword := BlockSize shr 2;
  if cnt_dword < 1 then
    Exit;
  asm
    push EDI
    push EAX
    push EBX
    push ECX
    push EDX

    cld

    mov  ECX, cnt_dword
    mov  EDI, ptrNow
    mov  EAX, mask
    mov  EBX, EAX
    not  EBX

  @fill:
    mov  EDX, [EDI]
    and  EDX, EAX
    cmp  EDX, EAX
    jne   @ok
    or   EDX, EBX
  @ok:
    mov  [EDI], EDX
    add  EDI, 4
    loop @fill

  @finishing:
    pop EDX
    pop ECX
    pop EBX
    pop EAX
    pop EDI
  end;
end;
{$ENDIF}
{$ELSE}

procedure DWord_ReduceColors(const NowBlock: pointer; const BlockSize: longword;
  mask: longword);
var
  ptrNow: ^byte;
  cnt_dword: longint;
begin
{$IFDEF CPUX64}
  // todo
{$ELSE}
  ptrNow := NowBlock; // image
  cnt_dword := BlockSize shr 2;
  if cnt_dword < 1 then
    Exit;
  asm
    push EDI
    push EAX
    push ECX
    push EDX

    cld

    mov  ECX, cnt_dword
    mov  EDX, 0
    mov  EDI, ptrNow
    mov  EAX, mask

  @fill:
    and  [EDI], EAX
    add  EDI, 4
    loop @fill

  @finishing:
    pop EDX
    pop ECX
    pop EAX
    pop EDI
  end;
{$ENDIF}
end;

{$ENDIF}

procedure DWord_ReduceColors2(const NowBlock: pointer;
  const BlockSize: longword; mask: longword);
var
  ptrNow: ^byte;
  cnt_dword: longint;
begin
{$IFDEF CPUX64}
  // todo
{$ELSE}
  ptrNow := NowBlock; // image
  cnt_dword := BlockSize shr 2;
  if cnt_dword < 2 then
    Exit;
  asm
    push EDI
    push EAX
    push EBX
    push ECX
    push EDX

    cld

    mov  EDI, ptrNow
    mov  EAX, mask
    mov  ECX, cnt_dword
    dec  ECX

    mov  EBX, [EDI]
    and  EBX, EAX
    add  EDI, 4

  @fill:
    mov  EDX, [EDI]
    and  EDX, EAX
    cmp  EDX, EBX
    jne  @neu

    mov  EDX, [EDI-4]
    mov  [EDI], EDX
    add  EDI, 4
    loop  @fill
    jmp @finishing

  @neu:
    mov  EBX, [EDI]
    and  EBX, EAX
    add  EDI, 4
    loop @fill

  @finishing:
    pop EDX
    pop ECX
    pop EBX
    pop EAX
    pop EDI
  end;
{$ENDIF}
end;

// Memory reserved by "DestBlock" needs to be at least 2 x BlockSize bytes
// Result = number of bytes writen to DestBlock
function DWordCompress_Delta(const LastBlock, NowBlock, DestBlock: pointer;
  const BlockSize: longword): longword;
var
  ptrTmp, ptrNow, ptrLast, ptrDest: ^byte;
  w: ^word;
  dw: ^longword;
  cnt_byte, cnt_dword: longint;
  have_not_equal: boolean;
begin
{$IFDEF CPUX64}
  Result := rtc_Compress.DWord_Compress_Delta(LastBlock, NowBlock, DestBlock,
    BlockSize);
{$ELSE}
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

  asm
    push ESI
    push EDI
    push EAX
    push EBX
    push ECX
    push EDX

    cld

    mov  ECX, cnt_dword
    mov  ESI, ptrNow
    mov  EDI, ptrLast

  @start:
    { We need:
    ECX = cnt_dword (number of dwords left to check
    ESI = ptrNow position to start scanning
    EDI = ptrLast position to start scanning }

    { Count where equal ... }

    mov  EDX, ECX                     // number of dwords to check

    repe CMPSD                        // Count all Equal dwords
    JE   @rest_equal                  // all what's left is equal ( EDX = cnt_dword )

    inc  ECX                          // number of dwords left to check
    sub  ESI, 4                       // new ptrNow
    sub  EDI, 4                       // new ptrLast
    sub  EDX, ECX                     // number of dwords where "source=dest"

    cmp  EDX, 0
    JE   @no_equal                    // not moved?

    { * if we have equal bytes, do ... * }

    mov  ptrNow, ESI                  // update ptrNow
    mov  ptrLast, EDI                 // update ptrLast and store EDI

    { Write jump-header ... }
    mov  EDI, ptrDest

    cmp  EDX, $FFFF
    ja   @more_eq2
    cmp  DX, 241
    ja   @more_eq

    mov  [EDI], DL
    inc  EDI
    jmp  @done_eq

  @more_eq:
    mov  AL, 242
    mov  [EDI], AL
    inc  EDI
    mov  [EDI], DX
    add  EDI, 2
    jmp @done_eq

  @more_eq2:
    mov  AL, 243
    mov  [EDI], AL
    inc  EDI
    mov  [EDI], EDX
    add  EDI, 4
    jmp @done_eq


  @done_eq:
    mov ptrDest, EDI                  // update ptrDest

    mov  EDI, ptrLast                 // restore EDI
    { * done equal dwords. * }

  @no_equal:

    { Count where not equal ... }
    mov  EDX, ECX                     // EDX = dwords left to check

    repne CMPSD                       // Count all un-equal drowds
    jne   @rest_not_equal             // all left is un-equal?

    inc  ECX                          // ECX = dwords left to check
    sub  EDI, 4                       // new ptrLast (won't need this until next run)
    sub  EDX, ECX                     // EDX = Non-Equal count

  @rest_not_equal:
    mov  cnt_dword, ECX               // update cnt_dwotd to dwords left to check on next run
    mov  ptrLast, EDI                 // update ptrLast for next run

    { ------------------
    Copy changed data ...
    ------------------ }

    { until here, we've prepared:
    - cnt_dword & ptrLast for the next run (if there will be one)
    - ptrNow to first non-equal longword position
    - ptrDest to next writing position
    - EDX to number of non-equal dwords to check and compress }

    // prepare ESI & ECX for iterations using LODSD
    mov  ECX, EDX                     // ECX = non-equal longword count

  @count_repeating:
    { from here, we need:
    ECX = dwords left to check
    ptrNow & ptrDest point to current source & dest location }

    { Count how many times "EAX" is repeating ... }

    mov  EDI, ptrNow                  // EDI = first non-equal longword position
    mov  EDX, ECX                     // dwords left to check
    mov  EAX, [EDI]                   // load first longword (will scan for this one)

    repe SCASD                        // Count repeating dwords (will be min. 1)
    je   @rest_repeating
    // not all dwords are equal
    inc  ECX                          // move behind last equal
    sub  EDI, 4                       // update EDI position (will need it later to store ptrNow)

  @rest_repeating:
    sub  EDX, ECX                     // repeating dwords count

    cmp  EDX, 1
    je   @non_equal_run

    mov  ptrNow, EDI                  // update ptrNow (behind last repeating longword)

    { from here, we need:
    ptrNow = position after last repeating longword
    EAX = repeating longword (data)
    EDX = number of times EAX is repeating
    ECX = number of dwords left to check (non-repeating)
    EDI = ptrNow location behind last equal longword }

    { Write info about compressed dwords ... }
    mov  EDI, ptrDest                 // get ptrDest
    { write repeating header }
    mov  EBX, EAX
    shr  EBX, 16                      // BX = high EAX

    cmp  EDX, $FFFF
    ja   @more_repeating2
    cmp  DX, $FF
    ja   @more_repeating

    cmp  AX, BX
    jne  @rep1_dword
    cmp  AL, AH
    jne  @rep1_word

  @rep1_byte:
    mov  BL, 244
    mov  [EDI], BL
    inc  EDI
    mov  [EDI], DL
    inc  EDI
    mov  [EDI], AL
    inc  EDI
    jmp  @done_rep

  @rep1_word:
    mov  BL, 245
    mov  [EDI], BL
    inc  EDI
    mov  [EDI], DL
    inc  EDI
    mov  [EDI], AX
    add  EDI, 2
    jmp  @done_rep

  @rep1_dword:
    mov  BL, 246
    mov  [EDI], BL
    inc  EDI
    mov  [EDI], DL
    inc  EDI
    mov  [EDI], EAX
    add  EDI, 4
    jmp  @done_rep

  @more_repeating:

    cmp  AX, BX
    jne  @rep2_dword
    cmp  AL, AH
    jne  @rep2_word

  @rep2_byte:
    mov  BL, 247
    mov  [EDI], BL
    inc  EDI
    mov  [EDI], DX
    add  EDI, 2
    mov  [EDI], AL
    inc  EDI
    jmp @done_rep

  @rep2_word:
    mov  BL, 248
    mov  [EDI], BL
    inc  EDI
    mov  [EDI], DX
    add  EDI, 2
    mov  [EDI], AX
    add  EDI, 2
    jmp @done_rep

  @rep2_dword:
    mov  BL, 249
    mov  [EDI], BL
    inc  EDI
    mov  [EDI], DX
    add  EDI, 2
    mov  [EDI], EAX
    add  EDI, 4
    jmp  @done_rep

  @more_repeating2:

    cmp  AX, BX
    jne  @rep2_dword2
    cmp  AL, AH
    jne  @rep2_word2

  @rep2_byte2:
    mov  BL, 250
    mov  [EDI], BL
    inc  EDI
    mov  [EDI], EDX
    add  EDI, 4
    mov  [EDI], AL
    inc  EDI
    jmp @done_rep

  @rep2_word2:
    mov  BL, 251
    mov  [EDI], BL
    inc  EDI
    mov  [EDI], EDX
    add  EDI, 4
    mov  [EDI], AX
    add  EDI, 2
    jmp @done_rep

  @rep2_dword2:
    mov  BL, 252
    mov  [EDI], BL
    inc  EDI
    mov  [EDI], EDX
    add  EDI, 4
    mov  [EDI], EAX
    add  EDI, 4

  @done_rep:
    mov  ptrDest, EDI                 // update ptrDest

    mov  EDX, ECX                     // dwords left to check
    cmp  ECX,0
    ja   @count_repeating

    jmp  @finishing

    (* ************** *)

  @non_equal_run:
    { from here, we need:
    ptrDest = next writing position
    ptrNow = next ptrNow longword to check
    ECX = number of non-equal dwords left - 1
    EDX = number of dwords checked }

    mov  ESI, EDI
    add  EDX, ECX
    cmp  ECX,0
    je   @write_non_repeating         // one longword can't be compressed.
    { Check how many dwords we can't compress using RLE }
  @scan_non_repeating:
    mov  EBX, EAX                     // store last longword
    LODSD                             // load next longword
    cmp  EBX, EAX                     // compare last and prior dwords
    je   @found_repeating             // until you find a match,
    loop @scan_non_repeating          // or work through all dwords

    jmp  @write_non_repeating         // no repeating dwords found

  @found_repeating:                   // found 2 repeating dwords.
    // ECX positioned on the second longword (not behind it)
    inc  ECX                          // Move counter one longword back,
    // to place it behind last non-repeating position.
    // ptrNow will be updated after we write non-repeating data down.
    // ECX = non-equal dwords left to check
  @write_non_repeating:
    sub  EDX, ECX                     // EDX = non-repeating longword count

    { from here, we need:
    ECX = number of dwords left to check (if >0, count repeating)
    EDX = number of non-repeating dwords to copy
    ptrNow & ptrDest point to current source & dest location }

    mov  EBX, ECX                     // EBX = save ECX (non-equal dwords left to check)

    mov  ECX, EDX                     // ECX = dwords to copy
    mov  ESI, ptrNow                  // read from ptrNow
    mov  EDI, ptrDest                 // write to ptrDest

    { Write "EDX" dwords down }
    // write normal header ...
    cmp  EDX, $FFFF
    ja   @more_not_eq2
    cmp  DX, $FF
    ja   @more_not_eq

    mov  AL, 253
    mov  [EDI], AL
    inc  EDI
    mov  [EDI], DL
    inc  EDI
    jmp  @copy_not_eq

  @more_not_eq:
    mov  AL, 254
    mov  [EDI], AL
    inc  EDI
    mov  [EDI], DX
    add  EDI, 2
    jmp  @copy_not_eq

  @more_not_eq2:
    mov  AL, 255
    mov  [EDI], AL
    inc  EDI
    mov  [EDI], EDX
    add  EDI, 4

  @copy_not_eq:
    rep  MOVSD                        // copy dwords

    mov  ptrNow, ESI                  // update ptrNow
    mov  ptrDest, EDI                 // update ptrDest

    mov  ECX, EBX                     // restore ECX (dwords left to check)

    cmp  ECX, 0
    ja   @count_repeating             // done with non-equal dwords?

    // have repeating dwords ...

  @finishing:
    mov  ESI, ptrNow
    mov  EDI, ptrLast
    mov  ECX, cnt_dword

    cmp  ECX,0
    ja   @start
    jmp  @done

  @rest_equal:
    mov ptrNow, ESI
    mov ptrLast, EDI

  @done:
    pop EDX
    pop ECX
    pop EBX
    pop EAX
    pop EDI
    pop ESI
  end;

  if cnt_byte > 0 then
  begin
    have_not_equal := True;
    if (ptrLast^ = ptrNow^) then
    begin
      ptrTmp := ptrNow;
      inc(ptrLast);
      inc(ptrTmp);
      if (cnt_byte < 2) or (ptrLast^ = ptrTmp^) then
      begin
        inc(ptrLast);
        inc(ptrTmp);
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
        inc(ptrDest);

        dw := pointer(ptrDest);
        dw^ := cnt_dword;
        inc(ptrDest, 4);
      end
      else if cnt_dword > 241 then
      begin
        // write equal count
        ptrDest^ := 242;
        inc(ptrDest);

        w := pointer(ptrDest);
        w^ := cnt_dword;
        inc(ptrDest, 2);
      end
      else if cnt_dword > 0 then
      begin
        // write equal count
        ptrDest^ := cnt_dword;
        inc(ptrDest);
      end;

      if cnt_byte > 0 then
      begin
        // Copy last few bytes of new image
        ptrDest^ := 0; // finishing bytes
        inc(ptrDest);
        ptrDest^ := cnt_byte;
        inc(ptrDest);
        repeat
          ptrDest^ := ptrNow^;
          inc(ptrDest);
          inc(ptrNow);
          dec(cnt_byte);
        until cnt_byte = 0;
      end;
    end;
  end;

  // Calculate packed size ...
  Result := longint(ptrDest) - longint(DestBlock);
{$ENDIF}
end;

function DWordCompress_Normal(const NowBlock, DestBlock: pointer;
  const BlockSize: longword): longword;
var
  ptrNow, ptrDest: ^byte;
  cnt_byte, cnt_dword: longint;
begin
{$IFDEF CPUX64}
  Result := rtc_Compress.DWord_Compress_Normal(NowBlock, DestBlock, BlockSize);
{$ELSE}
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

  asm
    push ESI
    push EDI
    push EAX
    push EBX
    push ECX
    push EDX

    cld

    mov  ECX, cnt_dword

    { until here, we've prepared:
    - cnt_dword & ptrLast for the next run (if there will be one)
    - ptrNow to first non-equal longword position
    - ptrDest to next writing position
    - EDX to number of non-equal dwords to check and compress }

  @count_repeating:
    { from here, we need:
    ECX = dwords left to check
    ptrNow & ptrDest point to current source & dest location }

    { Count how many times "EAX" is repeating ... }

    mov  EDI, ptrNow                  // EDI = first non-equal longword position
    mov  EDX, ECX                     // dwords left to check
    mov  EAX, [EDI]                   // load first longword (will scan for this one)

    repe SCASD                        // Count repeating dwords (will be min. 1)
    je   @rest_repeating
    // not all dwords are equal
    inc  ECX                          // move behind last equal
    sub  EDI, 4                       // update EDI position (will need it later to store ptrNow)

  @rest_repeating:
    sub  EDX, ECX                     // repeating dwords count

    cmp  EDX, 1
    je   @non_equal_run

    mov  ptrNow, EDI                  // update ptrNow (behind last repeating longword)

    { from here, we need:
    ptrNow = position after last repeating longword
    EAX = repeating longword (data)
    EDX = number of times EAX is repeating
    ECX = number of dwords left to check (non-repeating)
    EDI = ptrNow location behind last equal longword }

    { Write info about compressed dwords ... }
    mov  EDI, ptrDest                 // get ptrDest
    { write repeating header }
    mov  EBX, EAX
    shr  EBX, 16                      // BX = high EAX

    cmp  EDX, $FFFF
    ja   @more_repeating2
    cmp  DX, $FF
    ja   @more_repeating

    cmp  AX, BX
    jne  @rep1_dword
    cmp  AL, AH
    jne  @rep1_word

  @rep1_byte:
    mov  BL, 244
    mov  [EDI], BL
    inc  EDI
    mov  [EDI], DL
    inc  EDI
    mov  [EDI], AL
    inc  EDI
    jmp  @done_rep

  @rep1_word:
    mov  BL, 245
    mov  [EDI], BL
    inc  EDI
    mov  [EDI], DL
    inc  EDI
    mov  [EDI], AX
    add  EDI, 2
    jmp  @done_rep

  @rep1_dword:
    mov  BL, 246
    mov  [EDI], BL
    inc  EDI
    mov  [EDI], DL
    inc  EDI
    mov  [EDI], EAX
    add  EDI, 4
    jmp  @done_rep

  @more_repeating:

    cmp  AX, BX
    jne  @rep2_dword
    cmp  AL, AH
    jne  @rep2_word

  @rep2_byte:
    mov  BL, 247
    mov  [EDI], BL
    inc  EDI
    mov  [EDI], DX
    add  EDI, 2
    mov  [EDI], AL
    inc  EDI
    jmp @done_rep

  @rep2_word:
    mov  BL, 248
    mov  [EDI], BL
    inc  EDI
    mov  [EDI], DX
    add  EDI, 2
    mov  [EDI], AX
    add  EDI, 2
    jmp @done_rep

  @rep2_dword:
    mov  BL, 249
    mov  [EDI], BL
    inc  EDI
    mov  [EDI], DX
    add  EDI, 2
    mov  [EDI], EAX
    add  EDI, 4
    jmp @done_rep

  @more_repeating2:

    cmp  AX, BX
    jne  @rep2_dword2
    cmp  AL, AH
    jne  @rep2_word2

  @rep2_byte2:
    mov  BL, 250
    mov  [EDI], BL
    inc  EDI
    mov  [EDI], EDX
    add  EDI, 4
    mov  [EDI], AL
    inc  EDI
    jmp @done_rep

  @rep2_word2:
    mov  BL, 251
    mov  [EDI], BL
    inc  EDI
    mov  [EDI], EDX
    add  EDI, 4
    mov  [EDI], AX
    add  EDI, 2
    jmp @done_rep

  @rep2_dword2:
    mov  BL, 252
    mov  [EDI], BL
    inc  EDI
    mov  [EDI], EDX
    add  EDI, 4
    mov  [EDI], EAX
    add  EDI, 4

  @done_rep:
    mov  ptrDest, EDI                 // update ptrDest

    mov  EDX, ECX                     // dwords left to check
    cmp  ECX,0
    ja   @count_repeating

    jmp  @finishing

    { **************** }

  @non_equal_run:
    { from here, we need:
    ptrDest = next writing position
    ptrNow = next ptrNow longword to check
    ECX = number of non-equal dwords left - 1
    EDX = number of dwords checked }

    mov  ESI, EDI
    add  EDX, ECX
    cmp  ECX,0
    je   @write_non_repeating         // one longword can't be compressed.
    { Check how many dwords we can't compress using RLE }
  @scan_non_repeating:
    mov  EBX, EAX                     // store last longword
    LODSD                             // load next longword
    cmp  EBX, EAX                     // compare last and prior dwords
    je   @found_repeating             // until you find a match,
    loop @scan_non_repeating          // or work through all dwords

    jmp  @write_non_repeating         // no repeating dwords found

  @found_repeating:                   // found 2 repeating dwords.
    // ECX positioned on the second longword (not behind it)
    inc  ECX                          // Move counter one longword back,
    // to place it behind last non-repeating position.
    // ptrNow will be updated after we write non-repeating data down.
    // ECX = non-equal dwords left to check
  @write_non_repeating:
    sub  EDX, ECX                     // EDX = non-repeating longword count

    { from here, we need:
    ECX = number of dwords left to check (if >0, count repeating)
    EDX = number of non-repeating dwords to copy
    ptrNow & ptrDest point to current source & dest location }

    mov  EBX, ECX                     // EBX = save ECX (non-equal dwords left to check)

    mov  ECX, EDX                     // ECX = dwords to copy
    mov  ESI, ptrNow                  // read from ptrNow
    mov  EDI, ptrDest                 // write to ptrDest

    { Write "EDX" dwords down }
    // write normal header ...
    cmp  EDX, $FFFF
    ja   @more_not_eq2
    cmp  DX, $FF
    ja   @more_not_eq

    mov  AL, 253
    mov  [EDI], AL
    inc  EDI
    mov  [EDI], DL
    inc  EDI
    jmp  @copy_not_eq

  @more_not_eq:
    mov  AL, 254
    mov  [EDI], AL
    inc  EDI
    mov  [EDI], DX
    add  EDI, 2
    jmp  @copy_not_eq

  @more_not_eq2:
    mov  AL, 255
    mov  [EDI], AL
    inc  EDI
    mov  [EDI], EDX
    add  EDI, 4

  @copy_not_eq:
    rep  MOVSD                        // copy dwords

    mov  ptrNow, ESI                  // update ptrNow
    mov  ptrDest, EDI                 // update ptrDest

    mov  ECX, EBX                     // restore ECX (dwords left to check)

    cmp  ECX, 0
    ja   @count_repeating             // done with non-equal dwords?

  @finishing:
    pop EDX
    pop ECX
    pop EBX
    pop EAX
    pop EDI
    pop ESI
  end;

  if cnt_byte > 0 then
  begin
    // Copy last few bytes of new image
    ptrDest^ := 0; // finishing bytes
    inc(ptrDest);
    ptrDest^ := cnt_byte;
    inc(ptrDest);
    repeat
      ptrDest^ := ptrNow^;
      inc(ptrDest);
      inc(ptrNow);
      dec(cnt_byte);
    until cnt_byte = 0;
  end;

  // Calculate packed size ...
  Result := longint(ptrDest) - longint(DestBlock);
{$ENDIF}
end;

function DWordDecompress(const SrcBlock, DestBlock: pointer;
  const Offset, SrcLen, BlockSize: longword): boolean;
var
  b, bv: ^byte;
  w, wv: ^word;
  dw, dv: ^longword;
  id: ^AnsiChar;

  len: longword;
  ptrDest, ptrOrig: ^byte;

{$IFNDEF CPUX64}
  procedure CopyDWord(src: pointer; data: pointer; cnt: longword);
  begin
    asm
      push ESI
      push EDI
      push ECX

      mov  ESI, src  // source
      mov  EDI, data // destination
      mov  ECX, cnt  // count

      cld
      REP  MOVSD // copy count dwords

      pop  ECX
      pop  EDI
      pop  ESI
    end;
  end;

  procedure FillDWord(fill: longword; data: pointer; cnt: longword);
  asm
    push EDI
    push ECX
    push EAX

    mov  EDI, data // destination
    mov  EAX, fill // value to fill
    mov  ECX, cnt  // count

    cld
    REP  STOSD // Fill count dwords

    pop  EAX
    pop  ECX
    POP  EDI
  end;

  procedure FillWord(fill: longword; data: pointer; cnt: longword);
  begin
    inc(fill, fill shl 16);
    FillDWord(fill, data, cnt);
  end;
  procedure FillByte(fill: longword; data: pointer; cnt: longword);
  begin
    inc(fill, fill shl 8);
    inc(fill, fill shl 16);
    FillDWord(fill, data, cnt);
  end;
{$ENDIF}

begin
{$IFDEF CPUX64}
  Result := rtc_Compress.DWord_Decompress(SrcBlock, DestBlock, Offset, SrcLen,
    BlockSize);
{$ELSE}
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

  inc(ptrOrig, Offset);
  ptrDest := ptrOrig;
  while (len > 0) do
  begin
    case id^ of
      #242: // count:word = skip count*4 bytes
        begin
          inc(id);
          dec(len);

          w := pointer(id); // get count
          inc(id, 2);
          dec(len, 2);

          Assert(longword(ptrDest) - longword(ptrOrig) + w^ * 4 <= BlockSize);

          inc(ptrDest, w^ * 4);
        end;
      #243: // count:longword = skip count*4 bytes
        begin
          inc(id);
          dec(len);

          dw := pointer(id); // get count
          inc(id, 4);
          dec(len, 4);

          Assert(longword(ptrDest) - longword(ptrOrig) + dw^ * 4 <= BlockSize);

          inc(ptrDest, dw^ * 4);
        end;

      #244: // count:byte + value:byte = repeat value count*4 times
        begin
          inc(id);
          dec(len);

          b := pointer(id); // get byte count
          inc(id);
          dec(len);

          bv := pointer(id); // get byte value
          inc(id);
          dec(len);

          Assert(longword(ptrDest) - longword(ptrOrig) + b^ * 4 <= BlockSize);

          FillByte(bv^, ptrDest, b^);

          inc(ptrDest, b^ * 4);
        end;
      #245: // count:byte + value:word = repeat value count*2 times
        begin
          inc(id);
          dec(len);

          b := pointer(id); // get byte count
          inc(id);
          dec(len);

          wv := pointer(id); // get word value
          inc(id, 2);
          dec(len, 2);

          Assert(longword(ptrDest) - longword(ptrOrig) + b^ * 4 <= BlockSize);

          FillWord(wv^, ptrDest, b^);

          inc(ptrDest, b^ * 4);
        end;
      #246: // count:byte + value:longword = repeat value count times
        begin
          inc(id);
          dec(len);

          b := pointer(id); // get byte count
          inc(id);
          dec(len);

          dv := pointer(id); // get longword value
          inc(id, 4);
          dec(len, 4);

          Assert(longword(ptrDest) - longword(ptrOrig) + b^ * 4 <= BlockSize);

          FillDWord(dv^, ptrDest, b^);

          inc(ptrDest, b^ * 4);
        end;

      #247: // count:word + value:byte = repeat value count*4 times
        begin
          inc(id);
          dec(len);

          w := pointer(id); // get word count
          inc(id, 2);
          dec(len, 2);

          bv := pointer(id); // get byte value
          inc(id);
          dec(len);

          Assert(longword(ptrDest) - longword(ptrOrig) + w^ * 4 <= BlockSize);

          FillByte(bv^, ptrDest, w^);

          inc(ptrDest, w^ * 4);
        end;
      #248: // count:word + value:word = repeat value count*2 times
        begin
          inc(id);
          dec(len);

          w := pointer(id); // get word count
          inc(id, 2);
          dec(len, 2);

          wv := pointer(id); // get word value
          inc(id, 2);
          dec(len, 2);

          Assert(longword(ptrDest) - longword(ptrOrig) + w^ * 4 <= BlockSize);

          FillWord(wv^, ptrDest, w^);

          inc(ptrDest, w^ * 4);
        end;
      #249: // count:word + value:longword = repeat value count times
        begin
          inc(id);
          dec(len);

          w := pointer(id); // get word count
          inc(id, 2);
          dec(len, 2);

          dv := pointer(id); // get longword value
          inc(id, 4);
          dec(len, 4);

          Assert(longword(ptrDest) - longword(ptrOrig) + w^ * 4 <= BlockSize);

          FillDWord(dv^, ptrDest, w^);

          inc(ptrDest, w^ * 4);
        end;

      #250: // count:longword + value:byte = repeat value count*4 times
        begin
          inc(id);
          dec(len);

          dw := pointer(id); // get longword count
          inc(id, 4);
          dec(len, 4);

          bv := pointer(id); // get byte value
          inc(id);
          dec(len);

          Assert(longword(ptrDest) - longword(ptrOrig) + dw^ * 4 <= BlockSize);

          FillByte(bv^, ptrDest, dw^);

          inc(ptrDest, dw^ * 4);
        end;
      #251: // count:longword + value:word = repeat value count*2 times
        begin
          inc(id);
          dec(len);

          dw := pointer(id); // get longword count
          inc(id, 4);
          dec(len, 4);

          wv := pointer(id); // get word value
          inc(id, 2);
          dec(len, 2);

          Assert(longword(ptrDest) - longword(ptrOrig) + dw^ * 4 <= BlockSize);

          FillWord(wv^, ptrDest, dw^);

          inc(ptrDest, dw^ * 4);
        end;
      #252: // count:longword + value:longword = repeat value count times
        begin
          inc(id);
          dec(len);

          dw := pointer(id); // get word count
          inc(id, 4);
          dec(len, 4);

          dv := pointer(id); // get longword value
          inc(id, 4);
          dec(len, 4);

          Assert(longword(ptrDest) - longword(ptrOrig) + dw^ * 4 <= BlockSize);

          FillDWord(dv^, ptrDest, dw^);

          inc(ptrDest, dw^ * 4);
        end;

      #253: // count:byte + data = copy count*4 bytes of data
        begin
          inc(id);
          dec(len);

          b := pointer(id); // get count
          inc(id);
          dec(len);

          Assert((len >= b^ * 4) and (longword(ptrDest) - longword(ptrOrig) + b^
            * 4 <= BlockSize));

          CopyDWord(id, ptrDest, b^);
          inc(id, b^ * 4);
          dec(len, b^ * 4);

          inc(ptrDest, b^ * 4);
        end;
      #254: // count:word + data = copy count*4 bytes of data
        begin
          inc(id);
          dec(len);

          w := pointer(id); // get count
          inc(id, 2);
          dec(len, 2);

          Assert((len >= w^ * 4) and (longword(ptrDest) - longword(ptrOrig) + w^
            * 4 <= BlockSize));

          CopyDWord(id, ptrDest, w^);
          inc(id, w^ * 4);
          dec(len, w^ * 4);

          inc(ptrDest, w^ * 4);
        end;
      #255: // count:longword + data = copy count*4 bytes of data
        begin
          inc(id);
          dec(len);

          dw := pointer(id); // get count
          inc(id, 4);
          dec(len, 4);

          Assert((len >= dw^ * 4) and (longword(ptrDest) - longword(ptrOrig) +
            dw^ * 4 <= BlockSize));

          CopyDWord(id, ptrDest, dw^);
          inc(id, dw^ * 4);
          dec(len, dw^ * 4);

          inc(ptrDest, dw^ * 4);
        end;

      #0: // 0 + count:byte + data = copy count finishing bytes
        begin
          inc(id);
          dec(len);

          b := pointer(id); // get count
          inc(id);
          dec(len);

          Assert((len >= b^) and (longword(ptrDest) - longword(ptrOrig) + b^ <=
            BlockSize));

          Move(id^, ptrDest^, b^);
          inc(id, b^);
          dec(len, b^);

          inc(ptrDest, b^);
        end
    else // count:byte (1..241) = skip count*4 bytes
      begin
        b := pointer(id);
        inc(id);
        dec(len);

        Assert((longword(ptrDest) - longword(ptrOrig) + b^ * 4) <= BlockSize);

        inc(ptrDest, b^ * 4);
      end;
    end;
  end;
{$ENDIF}
end;

// Memory reserved by "DestBlock1" and "DestBlock2" needs to be at least BlockSize bytes
// DestBlock1 = memory for color information
// DestBlock2 = memory for length information
// Result = number of bytes writen to DestBlock1
// Size2 = number of bytes written to DestBlock2

function WordCompress_Delta2(const LastBlock, NowBlock, DestBlock1,
  DestBlock2: pointer; const BlockSize: word; var Size2: word): word;
var
  ptrTmp, ptrNow, ptrLast, ptrDest1, ptrDest2: ^byte;
  w: ^word;
  cnt_byte, cnt_word: word;
  have_not_equal: boolean;
begin
{$IFDEF CPUX64}
  Assert(False, 'Not supported x64: WordCompress_Delta2');
{$ELSE}
  Size2 := 0;
  ptrLast := LastBlock; // Old image
  ptrNow := NowBlock; // New image
  ptrDest1 := DestBlock1; // Destination image colors
  ptrDest2 := DestBlock2; // Destination image lengths

  cnt_byte := BlockSize and 3; // rest-bytes
  cnt_word := BlockSize shr 2;

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

  asm
    push ESI
    push EDI
    push EAX
    push EBX
    push ECX
    push EDX

    cld

    xor  ECX,ECX
    mov  CX, cnt_word

    mov  ESI, ptrNow
    mov  EDI, ptrLast

  @start:
    { We need:
    ECX = cnt_dword (number of dwords left to check
    ESI = ptrNow position to start scanning
    EDI = ptrLast position to start scanning }

    { Count where equal ... }

    mov  DX, CX                     // number of dwords to check

    repe CMPSD                        // Count all Equal dwords
    JE   @rest_equal                  // all what's left is equal ( EDX = cnt_dword )

    inc  CX                           // number of dwords left to check
    sub  ESI, 4                       // new ptrNow
    sub  EDI, 4                       // new ptrLast
    sub  DX, CX                       // number of dwords where "source=dest"

    cmp  DX, 0
    JE   @no_equal                    // not moved?

    { * if we have equal bytes, do ... * }

    mov  ptrNow, ESI                  // update ptrNow
    mov  ptrLast, EDI                 // update ptrLast and store EDI

    { Write jump-header ... }
    mov  EDI, ptrDest2

    cmp  DX, 241
    ja   @more_eq

    mov  [EDI], DL
    inc  EDI
    jmp  @done_eq

  @more_eq:
    mov  AL, 242
    mov  [EDI], AL
    inc  EDI
    mov  [EDI], DX
    add  EDI, 2

  @done_eq:
    mov ptrDest2, EDI                  // update ptrDest

    mov  EDI, ptrLast                 // restore EDI
    { * done equal dwords. * }

  @no_equal:

    { Count where not equal ... }
    mov  DX, CX                     // EDX = dwords left to check

    repne CMPSD                       // Count all un-equal drowds
    jne   @rest_not_equal             // all left is un-equal?

    inc  CX                          // ECX = dwords left to check
    sub  EDI, 4                       // new ptrLast (won't need this until next run)
    sub  DX, CX                     // EDX = Non-Equal count

  @rest_not_equal:
    mov  cnt_word, CX               // update cnt_dword to dwords left to check on next run
    mov  ptrLast, EDI                 // update ptrLast for next run

    { ------------------
    Copy changed data ...
    ------------------ }

    { until here, we've prepared:
    - cnt_dword & ptrLast for the next run (if there will be one)
    - ptrNow to first non-equal longword position
    - ptrDest to next writing position
    - EDX to number of non-equal dwords to check and compress }

    // prepare ESI & ECX for iterations using LODSD
    mov  CX, DX                     // ECX = non-equal longword count

  @count_repeating:
    { from here, we need:
    ECX = dwords left to check
    ptrNow & ptrDest point to current source & dest location }

    { Count how many times "EAX" is repeating ... }

    mov  EDI, ptrNow                  // EDI = first non-equal longword position
    mov  DX, CX                     // dwords left to check
    mov  EAX, [EDI]                   // load first longword (will scan for this one)

    repe SCASD                        // Count repeating dwords (will be min. 1)
    je   @rest_repeating
    // not all dwords are equal
    inc  CX                          // move behind last equal
    sub  EDI, 4                       // update EDI position (will need it later to store ptrNow)

  @rest_repeating:
    sub  DX, CX                     // repeating dwords count

    cmp  DX, 1
    je   @non_equal_run

    mov  ptrNow, EDI                  // update ptrNow (behind last repeating longword)

    { from here, we need:
    ptrNow = position after last repeating longword
    EAX = repeating longword (data)
    EDX = number of times EAX is repeating
    ECX = number of dwords left to check (non-repeating)
    EDI = ptrNow location behind last equal longword }

    { Write info about compressed dwords ... }
    mov  EDI, ptrDest2                 // get ptrDest
    { write repeating header }
    mov  EBX, EAX
    shr  EBX, 16                      // BX = high EAX

    cmp  DX, $FF
    ja   @more_repeating

    cmp  AX, BX
    jne  @rep1_dword
    cmp  AL, AH
    jne  @rep1_word

  @rep1_byte:
    mov  BL, 244
    mov  [EDI], BL
    inc  EDI
    mov  [EDI], DL
    inc  EDI
    mov  ptrDest2, EDI                 // update ptrDest2
    mov  EDI, ptrDest1
    mov  [EDI], AL
    inc  EDI
    jmp  @done_rep

  @rep1_word:
    mov  BL, 245
    mov  [EDI], BL
    inc  EDI
    mov  [EDI], DL
    inc  EDI
    mov  ptrDest2, EDI                 // update ptrDest2
    mov  EDI, ptrDest1
    mov  [EDI], AX
    add  EDI, 2
    jmp  @done_rep

  @rep1_dword:
    mov  BL, 246
    mov  [EDI], BL
    inc  EDI
    mov  [EDI], DL
    inc  EDI
    mov  ptrDest2, EDI                 // update ptrDest2
    mov  EDI, ptrDest1
    mov  [EDI], EAX
    add  EDI, 4
    jmp  @done_rep

  @more_repeating:

    cmp  AX, BX
    jne  @rep2_dword
    cmp  AL, AH
    jne  @rep2_word

  @rep2_byte:
    mov  BL, 247
    mov  [EDI], BL
    inc  EDI
    mov  [EDI], DX
    add  EDI, 2
    mov  ptrDest2, EDI                 // update ptrDest2
    mov  EDI, ptrDest1
    mov  [EDI], AL
    inc  EDI
    jmp @done_rep

  @rep2_word:
    mov  BL, 248
    mov  [EDI], BL
    inc  EDI
    mov  [EDI], DX
    add  EDI, 2
    mov  ptrDest2, EDI                 // update ptrDest2
    mov  EDI, ptrDest1
    mov  [EDI], AX
    add  EDI, 2
    jmp @done_rep

  @rep2_dword:
    mov  BL, 249
    mov  [EDI], BL
    inc  EDI
    mov  [EDI], DX
    add  EDI, 2
    mov  ptrDest2, EDI                 // update ptrDest2
    mov  EDI, ptrDest1
    mov  [EDI], EAX
    add  EDI, 4

  @done_rep:
    mov  ptrDest1, EDI                 // update ptrDest1

    mov  DX, CX                     // dwords left to check
    cmp  CX,0
    ja   @count_repeating

    jmp  @finishing

    (* ************** *)

  @non_equal_run:
    { from here, we need:
    ptrDest = next writing position
    EDI, ptrNow = next ptrNow longword to check
    ECX = number of non-equal dwords left - 1
    EDX = number of dwords checked }

    mov  ESI, EDI
    add  DX, CX
    cmp  CX,0
    je   @write_non_repeating         // one longword can't be compressed.
    { Check how many dwords we can't compress using RLE }
  @scan_non_repeating:
    mov  EBX, EAX                     // store last longword
    LODSD                             // load next longword
    cmp  EBX, EAX                     // compare last and prior dwords
    je   @found_repeating             // until you find a match,
    loop @scan_non_repeating          // or work through all dwords

    jmp  @write_non_repeating         // no repeating dwords found

  @found_repeating:                   // found 2 repeating dwords.
    // ECX positioned on the second longword (not behind it)
    inc  CX                          // Move counter one longword back,
    // to place it behind last non-repeating position.
    // ptrNow will be updated after we write non-repeating data down.
    // ECX = non-equal dwords left to check
  @write_non_repeating:
    sub  DX, CX                     // EDX = non-repeating longword count

    { from here, we need:
    ECX = number of dwords left to check (if >0, count repeating)
    EDX = number of non-repeating dwords to copy
    ptrNow & ptrDest point to current source & dest location }

    mov  BX, CX                     // EBX = save ECX (non-equal dwords left to check)

    mov  CX, DX                       // ECX = dwords to copy
    mov  ESI, ptrNow                  // read from ptrNow
    mov  EDI, ptrDest2                // write to ptrDest

    { Write "EDX" dwords down }
    // write normal header ...
    cmp  DX, $FF
    ja   @more_not_eq

    mov  AL, 253
    mov  [EDI], AL
    inc  EDI
    mov  [EDI], DL
    inc  EDI
    jmp  @copy_not_eq

  @more_not_eq:
    mov  AL, 254
    mov  [EDI], AL
    inc  EDI
    mov  [EDI], DX
    add  EDI, 2

  @copy_not_eq:
    mov  ptrDest2, EDI
    mov  EDI, ptrDest1
    rep  MOVSD                        // copy dwords

    mov  ptrNow, ESI                   // update ptrNow
    mov  ptrDest1, EDI                 // update ptrDest1

    mov  CX, BX                     // restore ECX (dwords left to check)

    cmp  CX, 0
    ja   @count_repeating             // done with non-equal dwords?

    // have repeating dwords ...

  @finishing:
    mov  ESI, ptrNow
    mov  EDI, ptrLast
    mov  CX, cnt_word

    cmp  CX,0
    ja   @start
    jmp  @done

  @rest_equal:
    mov ptrNow, ESI
    mov ptrLast, EDI

  @done:
    pop EDX
    pop ECX
    pop EBX
    pop EAX
    pop EDI
    pop ESI
  end;

  if cnt_byte > 0 then
  begin
    have_not_equal := True;
    if (ptrLast^ = ptrNow^) then
    begin
      ptrTmp := ptrNow;
      inc(ptrLast);
      inc(ptrTmp);
      if (cnt_byte < 2) or (ptrLast^ = ptrTmp^) then
      begin
        inc(ptrLast);
        inc(ptrTmp);
        if (cnt_byte < 3) or (ptrLast^ = ptrTmp^) then
          have_not_equal := False;
      end;
    end;

    if have_not_equal then
    begin
      if cnt_word > 241 then
      begin
        // write equal count
        ptrDest2^ := 242;
        inc(ptrDest2);

        w := pointer(ptrDest2);
        w^ := cnt_word;
        inc(ptrDest2, 2);
      end
      else if cnt_word > 0 then
      begin
        // write equal count
        ptrDest2^ := cnt_word;
        inc(ptrDest2);
      end;

      if cnt_byte > 0 then
      begin
        // Copy last few bytes of new image
        ptrDest2^ := 0; // finishing bytes
        inc(ptrDest2);
        ptrDest2^ := cnt_byte;
        inc(ptrDest2);
        repeat
          ptrDest1^ := ptrNow^;
          inc(ptrDest1);
          inc(ptrNow);
          dec(cnt_byte);
        until cnt_byte = 0;
      end;
    end;
  end;

  // Calculate packed size ...
  Size2 := longint(ptrDest2) - longint(DestBlock2);
  Result := longint(ptrDest1) - longint(DestBlock1);
{$ENDIF}
end;

function DWordDecompress2(const SrcBlock1, SrcBlock2, DestBlock: pointer;
  const Offset, SrcLen2, BlockSize: longword): boolean;
var
  b, bv: ^byte;
  w, wv: ^word;
  dw, dv: ^longword;
  id, colors: ^AnsiChar;

  len: longword;
  ptrDest, ptrOrig: ^byte;

{$IFNDEF CPUX64}
  procedure CopyDWord(src: pointer; data: pointer; cnt: longword);
  begin
    asm
      push ESI
      push EDI
      push ECX

      mov  ESI, src  // source
      mov  EDI, data // destination
      mov  ECX, cnt  // count

      cld
      REP  MOVSD // copy count dwords

      pop  ECX
      pop  EDI
      pop  ESI
    end;
  end;

  procedure FillDWord(fill: longword; data: pointer; cnt: longword);
  begin
    asm
      push EDI
      push ECX
      push EAX

      mov  EDI, data // destination
      mov  EAX, fill // value to fill
      mov  ECX, cnt  // count

      cld
      REP  STOSD // Fill count dwords

      pop  EAX
      pop  ECX
      POP  EDI
    end;
  end;

  procedure FillWord(fill: longword; data: pointer; cnt: longword);
  begin
    inc(fill, fill shl 16);
    FillDWord(fill, data, cnt);
  end;
  procedure FillByte(fill: longword; data: pointer; cnt: longword);
  begin
    inc(fill, fill shl 8);
    inc(fill, fill shl 16);
    FillDWord(fill, data, cnt);
  end;
{$ENDIF}

begin
{$IFDEF CPUX64}
  Assert(False, 'Not supported x64: WordDeCompress2');
{$ELSE}
  Result := True;

  len := SrcLen2;
  id := SrcBlock2;
  colors := SrcBlock1;
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

  inc(ptrOrig, Offset);
  ptrDest := ptrOrig;
  while (len > 0) do
  begin
    case id^ of
      #242: // count:word = skip count*4 bytes
        begin
          inc(id);
          dec(len);

          w := pointer(id); // get count
          inc(id, 2);
          dec(len, 2);

          Assert(longword(ptrDest) - longword(ptrOrig) + w^ * 4 <= BlockSize);

          inc(ptrDest, w^ * 4);
        end;
      #243: // count:longword = skip count*4 bytes
        begin
          inc(id);
          dec(len);

          dw := pointer(id); // get count
          inc(id, 4);
          dec(len, 4);

          Assert(longword(ptrDest) - longword(ptrOrig) + dw^ * 4 <= BlockSize);

          inc(ptrDest, dw^ * 4);
        end;

      #244: // count:byte + value:byte = repeat value count*4 times
        begin
          inc(id);
          dec(len);

          b := pointer(id); // get byte count
          inc(id);
          dec(len);

          bv := pointer(colors); // get byte value
          inc(colors);

          Assert(longword(ptrDest) - longword(ptrOrig) + b^ * 4 <= BlockSize);

          FillByte(bv^, ptrDest, b^);

          inc(ptrDest, b^ * 4);
        end;
      #245: // count:byte + value:word = repeat value count*2 times
        begin
          inc(id);
          dec(len);

          b := pointer(id); // get byte count
          inc(id);
          dec(len);

          wv := pointer(colors); // get word value
          inc(colors, 2);

          Assert(longword(ptrDest) - longword(ptrOrig) + b^ * 4 <= BlockSize);

          FillWord(wv^, ptrDest, b^);

          inc(ptrDest, b^ * 4);
        end;
      #246: // count:byte + value:longword = repeat value count times
        begin
          inc(id);
          dec(len);

          b := pointer(id); // get byte count
          inc(id);
          dec(len);

          dv := pointer(colors); // get longword value
          inc(colors, 4);

          Assert(longword(ptrDest) - longword(ptrOrig) + b^ * 4 <= BlockSize);

          FillDWord(dv^, ptrDest, b^);

          inc(ptrDest, b^ * 4);
        end;

      #247: // count:word + value:byte = repeat value count*4 times
        begin
          inc(id);
          dec(len);

          w := pointer(id); // get word count
          inc(id, 2);
          dec(len, 2);

          bv := pointer(colors); // get byte value
          inc(colors);

          Assert(longword(ptrDest) - longword(ptrOrig) + w^ * 4 <= BlockSize);

          FillByte(bv^, ptrDest, w^);

          inc(ptrDest, w^ * 4);
        end;
      #248: // count:word + value:word = repeat value count*2 times
        begin
          inc(id);
          dec(len);

          w := pointer(id); // get word count
          inc(id, 2);
          dec(len, 2);

          wv := pointer(colors); // get word value
          inc(colors, 2);

          Assert(longword(ptrDest) - longword(ptrOrig) + w^ * 4 <= BlockSize);

          FillWord(wv^, ptrDest, w^);

          inc(ptrDest, w^ * 4);
        end;
      #249: // count:word + value:longword = repeat value count times
        begin
          inc(id);
          dec(len);

          w := pointer(id); // get word count
          inc(id, 2);
          dec(len, 2);

          dv := pointer(colors); // get longword value
          inc(colors, 4);

          Assert(longword(ptrDest) - longword(ptrOrig) + w^ * 4 <= BlockSize);

          FillDWord(dv^, ptrDest, w^);

          inc(ptrDest, w^ * 4);
        end;

      #250: // count:longword + value:byte = repeat value count*4 times
        begin
          inc(id);
          dec(len);

          dw := pointer(id); // get longword count
          inc(id, 4);
          dec(len, 4);

          bv := pointer(colors); // get byte value
          inc(colors);

          Assert(longword(ptrDest) - longword(ptrOrig) + dw^ * 4 <= BlockSize);

          FillByte(bv^, ptrDest, dw^);

          inc(ptrDest, dw^ * 4);
        end;
      #251: // count:longword + value:word = repeat value count*2 times
        begin
          inc(id);
          dec(len);

          dw := pointer(id); // get longword count
          inc(id, 4);
          dec(len, 4);

          wv := pointer(colors); // get word value
          inc(colors, 2);

          Assert(longword(ptrDest) - longword(ptrOrig) + dw^ * 4 <= BlockSize);

          FillWord(wv^, ptrDest, dw^);

          inc(ptrDest, dw^ * 4);
        end;
      #252: // count:longword + value:longword = repeat value count times
        begin
          inc(id);
          dec(len);

          dw := pointer(id); // get word count
          inc(id, 4);
          dec(len, 4);

          dv := pointer(colors); // get longword value
          inc(colors, 4);

          Assert(longword(ptrDest) - longword(ptrOrig) + dw^ * 4 <= BlockSize);

          FillDWord(dv^, ptrDest, dw^);

          inc(ptrDest, dw^ * 4);
        end;

      #253: // count:byte + data = copy count*4 bytes of data
        begin
          inc(id);
          dec(len);

          b := pointer(id); // get count
          inc(id);
          dec(len);

          Assert(longword(ptrDest) - longword(ptrOrig) + b^ * 4 <= BlockSize);

          CopyDWord(colors, ptrDest, b^);
          inc(colors, b^ * 4);

          inc(ptrDest, b^ * 4);
        end;
      #254: // count:word + data = copy count*4 bytes of data
        begin
          inc(id);
          dec(len);

          w := pointer(id); // get count
          inc(id, 2);
          dec(len, 2);

          Assert(longword(ptrDest) - longword(ptrOrig) + w^ * 4 <= BlockSize);

          CopyDWord(colors, ptrDest, w^);
          inc(colors, w^ * 4);

          inc(ptrDest, w^ * 4);
        end;
      #255: // count:longword + data = copy count*4 bytes of data
        begin
          inc(id);
          dec(len);

          dw := pointer(id); // get count
          inc(id, 4);
          dec(len, 4);

          Assert(longword(ptrDest) - longword(ptrOrig) + dw^ * 4 <= BlockSize);

          CopyDWord(colors, ptrDest, dw^);
          inc(colors, dw^ * 4);

          inc(ptrDest, dw^ * 4);
        end;

      #0: // 0 + count:byte + data = copy count finishing bytes
        begin
          inc(id);
          dec(len);

          b := pointer(id); // get count
          inc(id);
          dec(len);

          Assert(longword(ptrDest) - longword(ptrOrig) + b^ <= BlockSize);

          Move(colors^, ptrDest^, b^);
          inc(colors, b^);

          inc(ptrDest, b^);
        end
    else // count:byte (1..241) = skip count*4 bytes
      begin
        b := pointer(id);
        inc(id);
        dec(len);

        Assert(longword(ptrDest) - longword(ptrOrig) + b^ * 4 <= BlockSize);

        inc(ptrDest, b^ * 4);
      end;
    end;
  end;
{$ENDIF}
end;

function DWordDecompress3(const SrcBlock1, SrcBlock2, DestBlock: pointer;
  const Offset, SrcLen2, BlockSize: longword): boolean;
var
  b: ^byte;
  w: ^word;
  dw: ^longword;
  id, colors: ^AnsiChar;
  skip: boolean;

  len: longword;
  ptrDest, ptrOrig: ^byte;

{$IFNDEF CPUX64}
  procedure CopyDWord(src: pointer; data: pointer; cnt: longword);
  begin
    asm
      push ESI
      push EDI
      push ECX

      mov  ESI, src  // source
      mov  EDI, data // destination
      mov  ECX, cnt  // count

      cld
      REP  MOVSD // copy count dwords

      pop  ECX
      pop  EDI
      pop  ESI
    end;
  end;
{$ENDIF}

begin
{$IFDEF CPUX64}
  Assert(False, 'Not supported x64: DWordDeCompress3');
{$ELSE}
  Result := True;

  len := SrcLen2;
  id := SrcBlock2;
  colors := SrcBlock1;
  ptrOrig := DestBlock;

  { Codes:
    * Starting with skip
    #0 = swap skip/copy
    count:byte (1..252) = skip/copy (byte) count*4 bytes
    #253 + count:word = skip/copy (word) count *4 bytes
    #254 + count:dword = skip/copy (dword) count *4 bytes
    #255 + count:byte + data = copy (byte) count bytes of data }

  inc(ptrOrig, Offset);
  ptrDest := ptrOrig;

  skip := True; // start with skip
  while (len > 0) do
  begin
    case id^ of
      #0:
        begin
          inc(id);
          dec(len);
          skip := not skip;
        end;
      #253: // skip/copy (byte) count*4 bytes of data
        begin
          inc(id);
          dec(len);

          w := pointer(id); // get count (word)
          inc(id, 2);
          dec(len, 2);

          Assert(longword(ptrDest) - longword(ptrOrig) + w^ * 4 <= BlockSize);

          if not skip then
          begin
            CopyDWord(colors, ptrDest, w^);
            inc(colors, w^ * 4);
          end;

          inc(ptrDest, w^ * 4);
          skip := not skip;
        end;
      #254: // skip/copy (word) count*4 bytes of data
        begin
          inc(id);
          dec(len);

          dw := pointer(id); // get count (dword)
          inc(id, 4);
          dec(len, 4);

          Assert(longword(ptrDest) - longword(ptrOrig) + dw^ * 4 <= BlockSize);

          if not skip then
          begin
            CopyDWord(colors, ptrDest, dw^);
            inc(colors, dw^ * 4);
          end;

          inc(ptrDest, dw^ * 4);
        end;
      #255: // 255 + count:byte + data = copy count finishing bytes
        begin
          inc(id);
          dec(len);

          b := pointer(id); // get count
          inc(id);
          dec(len);

          Assert(longword(ptrDest) - longword(ptrOrig) + b^ <= BlockSize);

          Move(colors^, ptrDest^, b^);
          inc(colors, b^);

          inc(ptrDest, b^);
        end
    else // count:byte (1..241) = skip/copy count*4 bytes
      begin
        b := pointer(id);
        inc(id);
        dec(len);

        Assert(longword(ptrDest) - longword(ptrOrig) + b^ * 4 <= BlockSize);

        if not skip then
        begin
          CopyDWord(colors, ptrDest, b^);
          inc(colors, b^ * 4);
        end;

        inc(ptrDest, b^ * 4);
        skip := not skip;
      end;
    end;
  end;
{$ENDIF}
end;

// Memory reserved by "DestBlock1" and "DestBlock2" needs to be at least BlockSize bytes
// DestBlock1 = memory for color information
// DestBlock2 = memory for length information
// Result = number of bytes writen to DestBlock1
// Size2 = number of bytes written to DestBlock2
function WordCompress_Normal4(const NowBlock, DestBlock1, DestBlock2: pointer;
  const BlockSize: word; var Size2: word): word;
var
  ptrNow, ptrDest1, ptrDest2: ^byte;
  cnt_byte, cnt_word: word;
begin
{$IFDEF CPUX64}
  Assert(False, 'Not supported x64: WordCompress_Normal4');
{$ELSE}
  Size2 := 0;
  ptrNow := NowBlock; // New image
  ptrDest1 := DestBlock1; // Destination image colors
  ptrDest2 := DestBlock2; // Destination image lengths

  cnt_byte := BlockSize and 3; // rest-bytes
  cnt_word := BlockSize shr 2;

  { Codes:
    count:byte (1..244) + value:longword = repeat (byte) longword value count times
    #245 + count:word + value:longword = repeat (word) longword value count times
    #246 + count:longword + value:longword = repeat (longword) longword value count times

    #247 + count:byte + value:word = repeat (byte) word value count*2 times
    #248 + count:word + value:word = repeat (word) word value count*2 times
    #249 + count:longword + value:word = repeat (longword) word value count*2 times

    #250 + count:byte + value:byte = repeat (word) byte value count*4 times
    #251 + count:word + value:byte = repeat (word) byte value count*4 times
    #252 + count:longword + value:byte = repeat (longword) byte value count*4 times

    #253 + count:byte + data = copy (byte) count*4 bytes of data
    #254 + count:word + data = copy (word) count*4 bytes of data
    #255 + count:longword + data = copy (longword) count*4 bytes of data

    #0 + count:byte + data = copy (byte) count bytes of data }

  asm
    push ESI
    push EDI
    push EAX
    push EBX
    push ECX
    push EDX

    cld

    xor  ECX, ECX
    mov  CX, cnt_word

    { until here, we've prepared:
    - cnt_dword & ptrLast for the next run (if there will be one)
    - ptrNow to first non-equal longword position
    - ptrDest to next writing position
    - EDX to number of non-equal dwords to check and compress }

  @count_repeating:
    { from here, we need:
    ECX = dwords left to check
    ptrNow & ptrDest point to current source & dest location }

    { Count how many times "EAX" is repeating ... }

    mov  EDI, ptrNow                  // EDI = first non-equal longword position
    mov  DX, CX                     // dwords left to check
    mov  EAX, [EDI]                   // load first longword (will scan for this one)

    repe SCASD                        // Count repeating dwords (will be min. 1)
    je   @rest_repeating
    // not all dwords are equal
    inc  CX                          // move behind last equal
    sub  EDI, 4                       // update EDI position (will need it later to store ptrNow)

  @rest_repeating:
    sub  DX, CX                     // repeating dwords count

    cmp  DX, 1
    je   @non_equal_run

    mov  ptrNow, EDI                  // update ptrNow (behind last repeating longword)

    { from here, we need:
    ptrNow = position after last repeating longword
    EAX = repeating longword (data)
    EDX = number of times EAX is repeating
    ECX = number of dwords left to check (non-repeating)
    EDI = ptrNow location behind last equal longword }

    { Write info about compressed dwords ... }
    mov  EDI, ptrDest2                 // get ptrDest
    { write repeating header }
    mov  EBX, EAX
    shr  EBX, 16                      // BX = high EAX

    cmp  AX, BX
    jne  @rep1_dword
    cmp  AL, AH
    jne  @rep1_word

  @rep1_byte:

    cmp  DX, 255
    ja   @rep2_byte

    mov  BL, 250
    mov  [EDI], BL
    inc  EDI
    mov  [EDI], DL
    inc  EDI
    mov  ptrDest2, EDI
    mov  EDI, ptrDest1
    mov  [EDI], AL
    inc  EDI
    jmp  @done_rep

  @rep2_byte:
    mov  BL, 251
    mov  [EDI], BL
    inc  EDI
    mov  [EDI], DX
    add  EDI, 2
    mov  ptrDest2, EDI
    mov  EDI, ptrDest1
    mov  [EDI], AL
    inc  EDI
    jmp @done_rep

  @rep1_word:

    cmp  DX, 255
    ja   @rep2_word

    mov  BL, 247
    mov  [EDI], BL
    inc  EDI
    mov  [EDI], DL
    inc  EDI
    mov  ptrDest2, EDI
    mov  EDI, ptrDest1
    mov  [EDI], AX
    add  EDI, 2
    jmp  @done_rep

  @rep2_word:
    mov  BL, 248
    mov  [EDI], BL
    inc  EDI
    mov  [EDI], DX
    add  EDI, 2
    mov  ptrDest2, EDI
    mov  EDI, ptrDest1
    mov  [EDI], AX
    add  EDI, 2
    jmp @done_rep

  @rep1_dword:

    cmp  DX, 244
    ja   @rep2_dword

    mov  [EDI], DL // repeat 1 - 244 dwords
    inc  EDI
    mov  ptrDest2, EDI
    mov  EDI, ptrDest1
    mov  [EDI], EAX
    add  EDI, 4
    jmp  @done_rep

  @rep2_dword:
    mov  BL, 245
    mov  [EDI], BL
    inc  EDI
    mov  [EDI], DX
    add  EDI, 2
    mov  ptrDest2, EDI
    mov  EDI, ptrDest1
    mov  [EDI], EAX
    add  EDI, 4

  @done_rep:
    mov  ptrDest1, EDI              // update ptrDest

    mov  DX, CX                     // dwords left to check
    cmp  CX,0
    ja   @count_repeating

    jmp  @finishing

    { **************** }

  @non_equal_run:
    { from here, we need:
    ptrDest = next writing position
    EDI, ptrNow = next ptrNow longword to check
    ECX = number of non-equal dwords left - 1
    EDX = number of dwords checked }

    mov  ESI, EDI
    add  DX, CX
    cmp  CX,0
    je   @write_non_repeating         // one longword can't be compressed.
    { Check how many dwords we can't compress using RLE }
  @scan_non_repeating:
    mov  EBX, EAX                     // store last longword
    LODSD                             // load next longword
    cmp  EBX, EAX                     // compare last and prior dwords
    je   @found_repeating             // until you find a match,
    loop @scan_non_repeating          // or work through all dwords

    jmp  @write_non_repeating         // no repeating dwords found

  @found_repeating:                   // found 2 repeating dwords.
    // ECX positioned on the second longword (not behind it)
    inc  CX                          // Move counter one longword back,
    // to place it behind last non-repeating position.
    // ptrNow will be updated after we write non-repeating data down.
    // ECX = non-equal dwords left to check
  @write_non_repeating:
    sub  DX, CX                     // EDX = non-repeating longword count

    { from here, we need:
    ECX = number of dwords left to check (if >0, count repeating)
    EDX = number of non-repeating dwords to copy
    ptrNow & ptrDest point to current source & dest location }

    mov  BX, CX                     // EBX = save ECX (non-equal dwords left to check)

    mov  CX, DX                        // ECX = dwords to copy
    mov  ESI, ptrNow                   // read from ptrNow
    mov  EDI, ptrDest2                 // write to ptrDest

    { Write "EDX" dwords down }
    // write normal header ...
    cmp  DX, 255
    ja   @more_not_eq

    mov  AL, 253
    mov  [EDI], AL
    inc  EDI
    mov  [EDI], DL
    inc  EDI
    jmp  @copy_not_eq

  @more_not_eq:
    mov  AL, 254
    mov  [EDI], AL
    inc  EDI
    mov  [EDI], DX
    add  EDI, 2

  @copy_not_eq:
    mov  ptrDest2, EDI
    mov  EDI, ptrDest1
    rep  MOVSD                        // copy dwords

    mov  ptrNow, ESI                   // update ptrNow
    mov  ptrDest1, EDI                 // update ptrDest

    mov  CX, BX                     // restore ECX (dwords left to check)

    cmp  CX, 0
    ja   @count_repeating             // done with non-equal dwords?

  @finishing:
    pop EDX
    pop ECX
    pop EBX
    pop EAX
    pop EDI
    pop ESI
  end;

  if cnt_byte > 0 then
  begin
    // Copy last few bytes of new image
    ptrDest2^ := 0; // finishing bytes
    inc(ptrDest2);
    ptrDest2^ := cnt_byte;
    inc(ptrDest2);
    repeat
      ptrDest1^ := ptrNow^;
      inc(ptrDest1);
      inc(ptrNow);
      dec(cnt_byte);
    until cnt_byte = 0;
  end;

  // Calculate packed size ...
  Size2 := longint(ptrDest2) - longint(DestBlock2);
  Result := longint(ptrDest1) - longint(DestBlock1);
{$ENDIF}
end;

function DWordDecompress4(const SrcBlock1, SrcBlock2, DestBlock: pointer;
  const Offset, SrcLen2, BlockSize: longword): boolean;
var
  b, bv: ^byte;
  w, wv: ^word;
  dw, dv: ^longword;
  id, colors: ^AnsiChar;

  len: longword;
  ptrDest, ptrOrig: ^byte;

{$IFNDEF CPUX64}
  procedure CopyDWord(src: pointer; data: pointer; cnt: longword);
  begin
    asm
      push ESI
      push EDI
      push ECX

      mov  ESI, src  // source
      mov  EDI, data // destination
      mov  ECX, cnt  // count

      cld
      REP  MOVSD // copy count dwords

      pop  ECX
      pop  EDI
      pop  ESI
    end;
  end;

  procedure FillDWord(fill: longword; data: pointer; cnt: longword);
  begin
    asm
      push EDI
      push ECX
      push EAX

      mov  EDI, data // destination
      mov  EAX, fill // value to fill
      mov  ECX, cnt  // count

      cld
      REP  STOSD // Fill count dwords

      pop  EAX
      pop  ECX
      POP  EDI
    end;
  end;

  procedure FillWord(fill: longword; data: pointer; cnt: longword);
  begin
    inc(fill, fill shl 16);
    FillDWord(fill, data, cnt);
  end;
  procedure FillByte(fill: longword; data: pointer; cnt: longword);
  begin
    inc(fill, fill shl 8);
    inc(fill, fill shl 16);
    FillDWord(fill, data, cnt);
  end;
{$ENDIF}

begin
{$IFDEF CPUX64}
  Assert(False, 'Not supported x64: DWordDeCompress4');
{$ELSE}
  Result := True;

  len := SrcLen2;
  id := SrcBlock2;
  colors := SrcBlock1;
  ptrOrig := DestBlock;

  { Codes:
    count:byte (1..244) + value:longword = repeat (byte) longword value count times
    #245 + count:word + value:longword = repeat (word) longword value count times
    #246 + count:longword + value:longword = repeat (longword) longword value count times

    #247 + count:byte + value:word = repeat (byte) word value count*2 times
    #248 + count:word + value:word = repeat (word) word value count*2 times
    #249 + count:longword + value:word = repeat (longword) word value count*2 times

    #250 + count:byte + value:byte = repeat (word) byte value count*4 times
    #251 + count:word + value:byte = repeat (word) byte value count*4 times
    #252 + count:longword + value:byte = repeat (longword) byte value count*4 times

    #253 + count:byte + data = copy (byte) count*4 bytes of data
    #254 + count:word + data = copy (word) count*4 bytes of data
    #255 + count:longword + data = copy (longword) count*4 bytes of data

    #0 + count:byte + data = copy (byte) count bytes of data }

  inc(ptrOrig, Offset);
  ptrDest := ptrOrig;
  while (len > 0) do
  begin
    case id^ of
      #0: // 0 + count:byte + data = copy count finishing bytes
        begin
          inc(id);
          dec(len);

          b := pointer(id); // get count
          inc(id);
          dec(len);

          Assert(longword(ptrDest) - longword(ptrOrig) + b^ <= BlockSize);

          Move(colors^, ptrDest^, b^);
          inc(colors, b^);

          inc(ptrDest, b^);
        end;

      #255: // count:longword + data = copy count*4 bytes of data
        begin
          inc(id);
          dec(len);

          dw := pointer(id); // get count
          inc(id, 4);
          dec(len, 4);

          Assert(longword(ptrDest) - longword(ptrOrig) + dw^ * 4 <= BlockSize);

          CopyDWord(colors, ptrDest, dw^);
          inc(colors, dw^ * 4);

          inc(ptrDest, dw^ * 4);
        end;

      #254: // count:word + data = copy count*4 bytes of data
        begin
          inc(id);
          dec(len);

          w := pointer(id); // get count
          inc(id, 2);
          dec(len, 2);

          Assert(longword(ptrDest) - longword(ptrOrig) + w^ * 4 <= BlockSize);

          CopyDWord(colors, ptrDest, w^);
          inc(colors, w^ * 4);

          inc(ptrDest, w^ * 4);
        end;

      #253: // count:byte + data = copy count*4 bytes of data
        begin
          inc(id);
          dec(len);

          b := pointer(id); // get count
          inc(id);
          dec(len);

          Assert(longword(ptrDest) - longword(ptrOrig) + b^ * 4 <= BlockSize);

          CopyDWord(colors, ptrDest, b^);
          inc(colors, b^ * 4);

          inc(ptrDest, b^ * 4);
        end;

      #252: // count:longword + value:byte = repeat value count*4 times
        begin
          inc(id);
          dec(len);

          dw := pointer(id); // get longword count
          inc(id, 4);
          dec(len, 4);

          bv := pointer(colors); // get byte value
          inc(colors);

          Assert(longword(ptrDest) - longword(ptrOrig) + dw^ * 4 <= BlockSize);

          FillByte(bv^, ptrDest, dw^);

          inc(ptrDest, dw^ * 4);
        end;

      #251: // count:word + value:byte = repeat value count*4 times
        begin
          inc(id);
          dec(len);

          w := pointer(id); // get word count
          inc(id, 2);
          dec(len, 2);

          bv := pointer(colors); // get byte value
          inc(colors);

          Assert(longword(ptrDest) - longword(ptrOrig) + w^ * 4 <= BlockSize);

          FillByte(bv^, ptrDest, w^);

          inc(ptrDest, w^ * 4);
        end;

      #250: // count:byte + value:byte = repeat value count*4 times
        begin
          inc(id);
          dec(len);

          b := pointer(id); // get byte count
          inc(id);
          dec(len);

          bv := pointer(colors); // get byte value
          inc(colors);

          Assert(longword(ptrDest) - longword(ptrOrig) + b^ * 4 <= BlockSize);

          FillByte(bv^, ptrDest, b^);

          inc(ptrDest, b^ * 4);
        end;

      #249: // count:longword + value:word = repeat value count*2 times
        begin
          inc(id);
          dec(len);

          dw := pointer(id); // get longword count
          inc(id, 4);
          dec(len, 4);

          wv := pointer(colors); // get word value
          inc(colors, 2);

          Assert(longword(ptrDest) - longword(ptrOrig) + dw^ * 4 <= BlockSize);

          FillWord(wv^, ptrDest, dw^);

          inc(ptrDest, dw^ * 4);
        end;

      #248: // count:word + value:word = repeat value count*2 times
        begin
          inc(id);
          dec(len);

          w := pointer(id); // get word count
          inc(id, 2);
          dec(len, 2);

          wv := pointer(colors); // get word value
          inc(colors, 2);

          Assert(longword(ptrDest) - longword(ptrOrig) + w^ * 4 <= BlockSize);

          FillWord(wv^, ptrDest, w^);

          inc(ptrDest, w^ * 4);
        end;

      #247: // count:byte + value:word = repeat value count*2 times
        begin
          inc(id);
          dec(len);

          b := pointer(id); // get byte count
          inc(id);
          dec(len);

          wv := pointer(colors); // get word value
          inc(colors, 2);

          Assert(longword(ptrDest) - longword(ptrOrig) + b^ * 4 <= BlockSize);

          FillWord(wv^, ptrDest, b^);

          inc(ptrDest, b^ * 4);
        end;

      #246: // count:longword + value:longword = repeat value count times
        begin
          inc(id);
          dec(len);

          dw := pointer(id); // get word count
          inc(id, 4);
          dec(len, 4);

          dv := pointer(colors); // get longword value
          inc(colors, 4);

          Assert(longword(ptrDest) - longword(ptrOrig) + dw^ * 4 <= BlockSize);

          FillDWord(dv^, ptrDest, dw^);

          inc(ptrDest, dw^ * 4);
        end;

      #245: // count:word + value:longword = repeat value count times
        begin
          inc(id);
          dec(len);

          w := pointer(id); // get word count
          inc(id, 2);
          dec(len, 2);

          dv := pointer(colors); // get longword value
          inc(colors, 4);

          Assert(longword(ptrDest) - longword(ptrOrig) + w^ * 4 <= BlockSize);

          FillDWord(dv^, ptrDest, w^);

          inc(ptrDest, w^ * 4);
        end;

    else // count:byte + value:longword = repeat value count times
      begin
        b := pointer(id); // get byte count
        inc(id);
        dec(len);

        dv := pointer(colors); // get longword value
        inc(colors, 4);

        Assert(longword(ptrDest) - longword(ptrOrig) + b^ * 4 <= BlockSize);

        FillDWord(dv^, ptrDest, b^);

        inc(ptrDest, b^ * 4);
      end;
    end;
  end;
{$ENDIF}
end;

function WordCompress_Delta_New(const LastBlock, NowBlock, DestBlock,
  TempBlock1, TempBlock2, TempBlock3, TempBlock4, TempBlock5,
  TempBlock6: pointer; const Reduce_Colors, Reduce_Colors2: longword;
  var FirstPass: boolean; ReducePercent: integer; const BlockSize: word;
  UpdateLastBlock: boolean): word;
var
  len1, len2, len5, len6: word;
  ToBlock: ^byte;
  a: byte;
begin
{$IFDEF CPUX64}
  Assert(False, 'Not supported x64: WordCompress_Delta_New');
{$ELSE}
  ToBlock := DestBlock;
  if FirstPass and ((Reduce_Colors <> 0) or (Reduce_Colors2 <> 0)) then
  begin
    if ReducePercent > 0 then
    begin
      len1 := WordCompress_Delta2(LastBlock, NowBlock, TempBlock1, TempBlock2,
        BlockSize, len2);
      if len1 = 0 then
      begin
        FirstPass := False;
        Result := 0;
      end
      else
      begin
        Move(LastBlock^, TempBlock3^, BlockSize);
        Move(NowBlock^, TempBlock4^, BlockSize);
        if Reduce_Colors <> 0 then
        begin
          DWord_ReduceColors(TempBlock3, BlockSize, Reduce_Colors);
          DWord_ReduceColors(TempBlock4, BlockSize, Reduce_Colors);
        end;
        if Reduce_Colors2 <> 0 then
        begin
          DWord_ReduceColors2(TempBlock3, BlockSize, Reduce_Colors2);
          DWord_ReduceColors2(TempBlock4, BlockSize, Reduce_Colors2);
        end;
        len5 := WordCompress_Delta2(TempBlock3, TempBlock4, TempBlock5,
          TempBlock6, BlockSize, len6);

        if len5 = 0 then
          Result := 0
        else if (len5 + len6) < (len1 + len2) * (100 - ReducePercent) / 100 then
        begin
          len1 := WordCompress_Normal4(TempBlock4, TempBlock1, TempBlock2,
            BlockSize, len2);

          if len1 + len2 <= len5 + len6 then
          begin
            a := 0; // RLE compressed
            Move(a, ToBlock^, 1);
            inc(ToBlock);
            Move(len2, ToBlock^, 2);
            inc(ToBlock, 2); // size of lengths
            Move(len1, ToBlock^, 2);
            inc(ToBlock, 2); // size of colors
            Move(TempBlock2^, ToBlock^, len2);
            inc(ToBlock, len2); // lengths
            Move(TempBlock1^, ToBlock^, len1); // colors
            Result := 5 + len2 + len1;
            if UpdateLastBlock then
              Move(TempBlock4^, LastBlock^, BlockSize);
          end
          else
          begin
            a := 3; // Delta2 compressed
            Move(a, ToBlock^, 1);
            inc(ToBlock);
            Move(len6, ToBlock^, 2);
            inc(ToBlock, 2); // size of lengths
            Move(len5, ToBlock^, 2);
            inc(ToBlock, 2); // size of colors
            Move(TempBlock6^, ToBlock^, len6);
            inc(ToBlock, len6); // lengths
            Move(TempBlock5^, ToBlock^, len5); // colors
            Result := 5 + len6 + len5;
            if UpdateLastBlock then
              DWordDecompress2(TempBlock5, TempBlock6, LastBlock, 0, len6,
                BlockSize);
          end;
        end
        else
        begin
          FirstPass := False;

          len5 := WordCompress_Normal4(NowBlock, TempBlock5, TempBlock6,
            BlockSize, len6);

          if len5 + len6 <= len1 + len2 then
          begin
            a := 0; // RLE compressed
            Move(a, ToBlock^, 1);
            inc(ToBlock);
            Move(len6, ToBlock^, 2);
            inc(ToBlock, 2); // size of lengths
            Move(len5, ToBlock^, 2);
            inc(ToBlock, 2); // size of colors
            Move(TempBlock6^, ToBlock^, len6);
            inc(ToBlock, len6); // lengths
            Move(TempBlock5^, ToBlock^, len5); // colors
            Result := 5 + len6 + len5;
            if UpdateLastBlock then
              Move(NowBlock^, LastBlock^, BlockSize);
          end
          else
          begin
            a := 3; // Delta2 compressed
            Move(a, ToBlock^, 1);
            inc(ToBlock);
            Move(len2, ToBlock^, 2);
            inc(ToBlock, 2); // size of lengths
            Move(len1, ToBlock^, 2);
            inc(ToBlock, 2); // size of colors
            Move(TempBlock2^, ToBlock^, len2);
            inc(ToBlock, len2); // lengths
            Move(TempBlock1^, ToBlock^, len1); // colors
            Result := 5 + len2 + len1;
            if UpdateLastBlock then
              Move(NowBlock^, LastBlock^, BlockSize);
          end;
        end;
      end;
    end
    else
    begin
      Move(LastBlock^, TempBlock3^, BlockSize);
      Move(NowBlock^, TempBlock4^, BlockSize);
      if Reduce_Colors <> 0 then
      begin
        DWord_ReduceColors(TempBlock3, BlockSize, Reduce_Colors);
        DWord_ReduceColors(TempBlock4, BlockSize, Reduce_Colors);
      end;
      if Reduce_Colors2 <> 0 then
      begin
        DWord_ReduceColors2(TempBlock3, BlockSize, Reduce_Colors2);
        DWord_ReduceColors2(TempBlock4, BlockSize, Reduce_Colors2);
      end;
      len5 := WordCompress_Delta2(TempBlock3, TempBlock4, TempBlock5,
        TempBlock6, BlockSize, len6);

      if len5 = 0 then
        Result := 0
      else
      begin
        len1 := WordCompress_Normal4(TempBlock4, TempBlock1, TempBlock2,
          BlockSize, len2);

        if len1 + len2 <= len5 + len6 then
        begin
          a := 0; // RLE compressed
          Move(a, ToBlock^, 1);
          inc(ToBlock);
          Move(len2, ToBlock^, 2);
          inc(ToBlock, 2); // size of lengths
          Move(len1, ToBlock^, 2);
          inc(ToBlock, 2); // size of colors
          Move(TempBlock2^, ToBlock^, len2);
          inc(ToBlock, len2); // lengths
          Move(TempBlock1^, ToBlock^, len1); // colors
          Result := 5 + len2 + len1;
          if UpdateLastBlock then
            Move(TempBlock4^, LastBlock^, BlockSize);
        end
        else
        begin
          a := 3; // Delta2 compressed
          Move(a, ToBlock^, 1);
          inc(ToBlock);
          Move(len6, ToBlock^, 2);
          inc(ToBlock, 2); // size of lengths
          Move(len5, ToBlock^, 2);
          inc(ToBlock, 2); // size of colors
          Move(TempBlock6^, ToBlock^, len6);
          inc(ToBlock, len6); // lengths
          Move(TempBlock5^, ToBlock^, len5); // colors
          Result := 5 + len6 + len5;
          if UpdateLastBlock then
            DWordDecompress2(TempBlock5, TempBlock6, LastBlock, 0, len6,
              BlockSize);
        end;
      end;
    end;
  end
  else
  begin
    FirstPass := False;
    len1 := WordCompress_Delta2(LastBlock, NowBlock, TempBlock1, TempBlock2,
      BlockSize, len2);
    if len1 = 0 then
      Result := 0
    else
    begin
      len5 := WordCompress_Normal4(NowBlock, TempBlock5, TempBlock6,
        BlockSize, len6);

      if len5 + len6 <= len1 + len2 then
      begin
        a := 0; // RLE compressed
        Move(a, ToBlock^, 1);
        inc(ToBlock);
        Move(len6, ToBlock^, 2);
        inc(ToBlock, 2); // size of lengths
        Move(len5, ToBlock^, 2);
        inc(ToBlock, 2); // size of colors
        Move(TempBlock6^, ToBlock^, len6);
        inc(ToBlock, len6); // lengths
        Move(TempBlock5^, ToBlock^, len5); // colors
        Result := 5 + len6 + len5;
        if UpdateLastBlock then
          Move(NowBlock^, LastBlock^, BlockSize);
      end
      else
      begin
        a := 3; // Delta2 compressed
        Move(a, ToBlock^, 1);
        inc(ToBlock);
        Move(len2, ToBlock^, 2);
        inc(ToBlock, 2); // size of lengths
        Move(len1, ToBlock^, 2);
        inc(ToBlock, 2); // size of colors
        Move(TempBlock2^, ToBlock^, len2);
        inc(ToBlock, len2); // lengths
        Move(TempBlock1^, ToBlock^, len1); // colors
        Result := 5 + len2 + len1;
        if UpdateLastBlock then
          Move(NowBlock^, LastBlock^, BlockSize);
      end;
    end;
  end;
{$ENDIF}
end;

function WordCompress_Normal_New(const LastBlock, NowBlock, DestBlock,
  TempBlock0, TempBlock1, TempBlock2, TempBlock3, TempBlock4: pointer;
  const Reduce_Colors, Reduce_Colors2: longword; var FirstPass: boolean;
  ReducePercent: integer; const BlockSize: word;
  UpdateLastBlock: boolean): word;
var
  len1, len2, len3, len4: word;
  ToBlock: ^byte;
  tb: pointer;
  a: byte;
begin
{$IFDEF CPUX64}
  Assert(False, 'Not supported x64: WordCompress_Delta_New');
{$ELSE}
  ToBlock := DestBlock;
  if FirstPass and (ReducePercent > 0) and
    ((Reduce_Colors <> 0) or (Reduce_Colors2 <> 0)) then
  begin
    len1 := WordCompress_Normal4(NowBlock, TempBlock1, TempBlock2,
      BlockSize, len2);

    Move(NowBlock^, TempBlock0^, BlockSize);
    if Reduce_Colors <> 0 then
      DWord_ReduceColors(TempBlock0, BlockSize, Reduce_Colors);
    if Reduce_Colors2 <> 0 then
      DWord_ReduceColors2(TempBlock0, BlockSize, Reduce_Colors2);

    len3 := WordCompress_Normal4(TempBlock0, TempBlock3, TempBlock4,
      BlockSize, len4);

    if len3 + len4 < (len1 + len2) * (100 - ReducePercent) / 100 then
    begin
      a := 0; // RLE compressed
      Move(a, ToBlock^, 1);
      inc(ToBlock);
      Move(len4, ToBlock^, 2);
      inc(ToBlock, 2); // size of lengths
      Move(len3, ToBlock^, 2);
      inc(ToBlock, 2); // size of colors
      Move(TempBlock4^, ToBlock^, len4);
      inc(ToBlock, len4); // lengths
      Move(TempBlock3^, ToBlock^, len3); // colors
      Result := 5 + len4 + len3;
      if UpdateLastBlock then
        Move(TempBlock0^, LastBlock^, BlockSize);
    end
    else
    begin
      FirstPass := False;
      a := 0; // RLE compressed
      Move(a, ToBlock^, 1);
      inc(ToBlock);
      Move(len2, ToBlock^, 2);
      inc(ToBlock, 2); // size of lengths
      Move(len1, ToBlock^, 2);
      inc(ToBlock, 2); // size of colors
      Move(TempBlock2^, ToBlock^, len2);
      inc(ToBlock, len2); // lengths
      Move(TempBlock1^, ToBlock^, len1); // colors
      Result := 5 + len2 + len1;
      if UpdateLastBlock then
        Move(NowBlock^, LastBlock^, BlockSize);
    end;
  end
  else
  begin
    if FirstPass and ((Reduce_Colors <> 0) or (Reduce_Colors2 <> 0)) then
    begin
      Move(NowBlock^, TempBlock0^, BlockSize);
      if Reduce_Colors <> 0 then
        DWord_ReduceColors(TempBlock0, BlockSize, Reduce_Colors);
      if Reduce_Colors2 <> 0 then
        DWord_ReduceColors2(TempBlock0, BlockSize, Reduce_Colors2);
      tb := TempBlock0;
    end
    else
    begin
      FirstPass := False;
      tb := NowBlock;
    end;

    len1 := WordCompress_Normal4(tb, TempBlock1, TempBlock2, BlockSize, len2);

    a := 0; // RLE compressed
    Move(a, ToBlock^, 1);
    inc(ToBlock);
    Move(len2, ToBlock^, 2);
    inc(ToBlock, 2); // size of lengths
    Move(len1, ToBlock^, 2);
    inc(ToBlock, 2); // size of colors
    Move(TempBlock2^, ToBlock^, len2);
    inc(ToBlock, len2); // lengths
    Move(TempBlock1^, ToBlock^, len1); // colors
    Result := 5 + len2 + len1;
    if UpdateLastBlock then
      Move(tb^, LastBlock^, BlockSize);
  end;
{$ENDIF}
end;

function DWordDecompress_New(const SrcBlock, DestBlock, TempBlock1: pointer;
  const Offset, SrcLen, BlockSize: longword): boolean;
var
  len1, len2, len3, len4: word;
  FromBlock, SrcBlock1, SrcBlock2, SrcBlock3, SrcBlock4: ^byte;
  a: byte;
begin
{$IFDEF CPUX64}
  Assert(False, 'Not supported x64: WordCompress_Delta_New');
{$ELSE}
  Assert(SrcLen >= 7);

  FromBlock := SrcBlock;
  Move(FromBlock^, a, 1);
  inc(FromBlock);
  case a of
    0: // Normal4 compressed
      begin
        Move(FromBlock^, len2, 2);
        inc(FromBlock, 2);
        Move(FromBlock^, len1, 2);
        inc(FromBlock, 2);

        Assert(SrcLen = 5 + len1 + len2);

        SrcBlock2 := FromBlock;
        SrcBlock1 := SrcBlock2;
        inc(SrcBlock1, len2);
        Result := DWordDecompress4(SrcBlock1, SrcBlock2, DestBlock, Offset,
          len2, BlockSize);
      end;
    1: // Delta3 compressed
      begin
        Move(FromBlock^, len2, 2);
        inc(FromBlock, 2);
        Move(FromBlock^, len1, 2);
        inc(FromBlock, 2);

        Assert(SrcLen = 5 + len1 + len2);

        SrcBlock2 := FromBlock;
        SrcBlock1 := SrcBlock2;
        inc(SrcBlock1, len2);
        Result := DWordDecompress3(SrcBlock1, SrcBlock2, DestBlock, Offset,
          len2, BlockSize);
      end;
    2: // Delta3 + Normal4 compressed
      begin
        Move(FromBlock^, len2, 2);
        inc(FromBlock, 2);
        Move(FromBlock^, len4, 2);
        inc(FromBlock, 2);
        Move(FromBlock^, len3, 2);
        inc(FromBlock, 2);

        Assert(SrcLen = 7 + len2 + len3 + len4);

        SrcBlock2 := FromBlock;
        SrcBlock4 := SrcBlock2;
        inc(SrcBlock4, len2);
        SrcBlock3 := SrcBlock4;
        inc(SrcBlock3, len4);
        if DWordDecompress4(SrcBlock3, SrcBlock4, TempBlock1, 0, len4, BlockSize)
        then
          Result := DWordDecompress3(TempBlock1, SrcBlock2, DestBlock, Offset,
            len2, BlockSize)
        else
          Result := False;
      end;
    3: // Delta2 or Normal2 compressed
      begin
        Move(FromBlock^, len2, 2);
        inc(FromBlock, 2);
        Move(FromBlock^, len1, 2);
        inc(FromBlock, 2);

        Assert(SrcLen = 5 + len1 + len2);

        SrcBlock2 := FromBlock;
        SrcBlock1 := SrcBlock2;
        inc(SrcBlock1, len2);
        Result := DWordDecompress2(SrcBlock1, SrcBlock2, DestBlock, Offset,
          len2, BlockSize);
      end;
  else
    Result := False;
  end;
{$ENDIF}
end;

end.
