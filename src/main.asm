.nolist
#include "includes/ti84pce.inc"
.list

.org userMem - 2
.db tExtTok, tAsm84CeCmp
start:
  call _RunIndicOff
  call _ClrLCDAll
  call _HomeUp
  ld hl, StartMessage
  call _PutS
  call _GetKey
  call game_loop
exit:
  call clean_up_lcd
  call _ClrScrnFull
  call _HomeUp
  call _DrawStatusBar
  ret

game_loop:
  call _ClrLCDAll
  call init_lcd
  ld ix, 0
_game_loop:
  ;call get_palette_color
  ld a, (ix)
  inc ix
; Render the screen
  call fill_screen
  call swap_vbuffer
; Check for input
  call _GetCSC
  cp skClear
  jr nz, _game_loop
  ret

#include "src/gfx.asm"
#include "src/sprites.asm"

StartMessage:
  .db "Hi there, press anything to start...", 0

.end
