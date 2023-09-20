.equ vRamSize (vRamEnd - vRam)

.nolist
#include "includes/ti84pce.inc"
.list

.org userMem - 2
.db tExtTok, tAsm84CeCmp
Start:
  call _RunIndicOff
  call _ClrLCDAll
  call _HomeUp
  ld hl, StartMessage
  call _PutS
  call _GetKey
  jr GameLoop
Exit:
  call _ClrLCDAll
  call _HomeUp
  ld hl, EndMessage
  call _PutS
  ret

GameLoop:
  call _ClrLCDAll
  ld de, vRam
  ld a, lcdHeight
  ld ix, TestPixelData
_GameLoop:
  inc ix
  call FillScreen16
  call _GetCSC
  cp skClear
  jr nz, _GameLoop
  ret

FillScreen16:
; Fill the entire screen with one color.
;
; Inputs:
;   ix = *2-byte rgbb color
; Output:
;   hl = vRamEnd
;   de = vRamEnd
; Destorys:
;   Registers:
;     c
;     hl
;     de
;   Flags:
;     z
  ld hl, vRam
  ld de, vRamEnd
_FillScreenLoop:
  ld c, (ix)
  ld (hl), c
  inc hl
  ld c, (ix + 1)
  ld (hl), c
  inc hl
  call _CpHlDe
  jr nz, _FillScreenLoop
  ret

StartMessage:
  .db "Hi there, press anything to start...", 0

EndMessage:
  .db "EXITED", 0

TestPixelData:
; 64 Bytes
  .dw $F000, $F000, $F000, $F000 ; Red
  .dw $F000, $F000, $F000, $F000 ; Red
  .dw $0F00, $0F00, $0F00, $0F00 ; Green
  .dw $0F00, $0F00, $0F00, $0F00 ; Green
  .dw $00FF, $00FF, $00FF, $00FF ; Blue
  .dw $00FF, $00FF, $00FF, $00FF ; Blue
  .dw $0000, $0000, $0000, $0000 ; Black
  .dw $FFFF, $FFFF, $FFFF, $FFFF ; White

.end
