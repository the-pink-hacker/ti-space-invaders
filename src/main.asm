.nolist
#include "includes/ti84pce.inc"
#define GBUF PlotSScreen
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
  call _DrawStatusBar
  call _GrBufClr ; Clears the graph
  set graphDraw, (iy + graphFlags) ; Forces the graph to rerender
  ld hl, EndMessage
  call _PutS
  call _NewLine
  ret

GameLoop:
  call _ClrLCDAll
_GameLoop:
  call _GrBufClr
  ld de, GBUF
  ld hl, Data
  ld bc, 64
  ldir
  call _GrBufCpyV
  ld a, (Data)
  inc a
  ld (Data), a
  call _GetCSC
  cp skClear
  jr nz, _GameLoop
  ret

StartMessage:
  .db "Hi there, press anything to start...", 0

EndMessage:
  .db "EXITED", 0

Data:
  .db $01, $23, $45, $67, $89, $AB, $CD, $EF
  .db $01, $23, $45, $67, $89, $AB, $CD, $EF
  .db $01, $23, $45, $67, $89, $AB, $CD, $EF
  .db $01, $23, $45, $67, $89, $AB, $CD, $EF
  .db $01, $23, $45, $67, $89, $AB, $CD, $EF
  .db $01, $23, $45, $67, $89, $AB, $CD, $EF
  .db $01, $23, $45, $67, $89, $AB, $CD, $EF
  .db $01, $23, $45, $67, $89, $AB, $CD, $EF

.end
