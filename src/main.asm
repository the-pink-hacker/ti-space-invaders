.nolist
#include "includes/ti84pce.inc"
.list

.org userMem - 2
.assume ADL = 1
.db tExtTok, tAsm84CeCmp
start:
  call _RunIndicOff
  call _ClrLCDAll
  call _HomeUp
  ld hl, StringTitle
  call _PutS
  call _NewLine
  call _PutS
  call _GetKeyRetOff
  call initialize_keyboard
  call game_loop
exit:
  call restore_keyboard
  call clean_up_lcd
  call _ClrScrnFull
  call _HomeUp
  jp _DrawStatusBar

initialize_keyboard:
  di
  ld hl, DI_MODE
  ld (hl), 3
  ei
  ret

restore_keyboard:
  ld hl, $0F50000
  xor a		; Mode 0
  ld (hl), a
  inc l		; 0F50001h
  ld (hl), 15	; Wait 15*256 APB cycles before scanning each row
  inc l		; 0F50002h
  xor a
  ld (hl), a
  inc l		; 0F50003h
  ld (hl), 15	; Wait 15 APB cycles before each scan
  inc l		; 0F50004h
  ld a, 8		; Number of rows to scan
  ld (hl), a
  inc l		; 0F50005h
  ld (hl), a	; Number of columns to scan
  ret


#include "src/game.asm"
#include "src/gfx.asm"
#include "src/assets.asm"

StringTitle:
  .db "Space Invaders", 0

StringPressStart:
  .db "Press any key to start...", 0

.end
