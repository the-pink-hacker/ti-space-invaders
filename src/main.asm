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
  ret

GameLoop:
  call _ClrLCDAll
  ld de, vRam
  ld a, lcdHeight
_GameLoop:
  ld hl, Data
  ld bc, 64
  ldir
  ld hl, Data
  ld bc, 64
  ldir
  ld hl, Data
  ld bc, 64
  ldir
  ld hl, Data
  ld bc, 64
  ldir
  ld hl, Data
  ld bc, 64
  ldir
  ld hl, Data
  ld bc, 64
  ldir
  ld hl, Data
  ld bc, 64
  ldir
  ld hl, Data
  ld bc, 64
  ldir
  ld hl, Data
  ld bc, 64
  ldir
  ld hl, Data
  ld bc, 64
  ldir
  ;call _GetCSC
  ;cp skClear
  ;jr nz, _GameLoop
  cp 0
  dec a
  jr nz, _GameLoop
  call _GetKey
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
