.nolist
#include "includes/ti84pce.inc"
.list

.org userMem - 2
.db tExtTok, tAsm84CeCmp
start:
  call _RunIndicOff
  call _ClrLCDAll
  call _HomeUp
  ld hl, StringTitle
  call _PutS
  call _NewLine
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
_game_loop:
; Render the screen
  ld a, C_BLUE
  call fill_screen
  ld a, 16
  ld b, lcdHeight - 16 - 8
  ld de, (PlayerPosition)
  ld ix, TestSprite
  call put_sprite
  call swap_vbuffer
; Check for input
  call _GetCSC
  cp skClear
  jr nz, _game_loop
  ret

#include "src/gfx.asm"
#include "src/sprites.asm"

PlayerPosition:
  .dl (lcdWidth - SPRITE_WIDTH) / 2

StringTitle:
  .db "Space Invaders", 0

StringPressStart:
  .db "Press anything to start...", 0

.end
