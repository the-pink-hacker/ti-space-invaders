spriteWidth .equ 16
playerHeight .equ 8
playerMoveDistance .equ 4
playerScreenMargin .equ 8
playerStartingY .equ lcdHeight - playerHeight - playerScreenMargin
playerXMin .equ playerScreenMargin
playerXMax .equ lcdWidth - spriteWidth - playerScreenMargin

inputLeftRow .equ kbdG7
inputLeftBit .equ kbitLeft
inputRightRow .equ kbdG7
inputRightBit .equ kbitRight
inputFireRow .equ kbdG1
inputFireBit .equ kbit2nd
inputExitRow .equ kbdG6
inputExitBit .equ kbitClear

game_loop:
  call _ClrLCDAll
  call init_lcd
  xor a, a
_game_loop:
; Render the screen
  xor a ; Sets to black ($00)
  call fill_screen

  call update_player_projectile

  ld a, playerHeight
  ld b, playerStartingY
  ld de, (PlayerPosition)
  ld ix, SpritePlayer
  call put_sprite

  call swap_vbuffer
; Check for input
  di
  ld hl, DI_MODE
  ld (hl), 2
  xor a, a
_game_loop_input_wait:
  cp (hl)
  jr nz, _game_loop_input_wait
  ld hl, inputLeftRow
  bit inputLeftBit, (hl)
  ld de, playerMoveDistance
  call nz, player_left

  ld hl, inputRightRow
  bit inputRightBit, (hl)
  call nz, player_right

  ld hl, inputFireRow
  bit inputFireBit, (hl)
  call nz, player_fire

  ld hl, inputExitRow
  bit inputExitBit, (hl)
  ei
  ret nz
  jr _game_loop

player_left:
  ld hl, (PlayerPosition)
  ld bc, playerXMin
  push hl
  sbc hl, bc
  pop hl
  ret c
  sbc hl, de
  ld (PlayerPosition), hl
  ret

player_right:
  ld hl, (PlayerPosition)
  ld bc, playerXMax
  push hl
  sbc hl, bc
  pop hl
  ret p
  add hl, de
  ld (PlayerPosition), hl
  ret

player_fire:
  ld hl, PlayerProjectileSpawned
  ld a, 0
  cp (hl) ; Check if projectile is spawned
  ret nz  ; Return if already spawned
  ld (hl), 1 ; Set spawned
  ld hl, (PlayerPosition)
  ld (PlayerProjectileX), hl
  ld hl, PlayerProjectileY
  ld (hl), playerStartingY ; Set y
  ret

update_player_projectile:
  ld hl, PlayerProjectileSpawned
  ld a, 0
  cp (hl)
  ret z ; Return if not spawned

  ld a, (PlayerProjectileY) ; 19
  sbc a, 4 ; Move projectile up
  jr nc, _update_player_projectile_sprite

  ld (hl), 0 ; Despawn
  ret

_update_player_projectile_sprite:
  ld hl, PlayerProjectileY
  ld (hl), a ; Update Y

  ld b, a         ; Y
  ld a, 8         ; Height
  ld de, (PlayerProjectileX) ; X
  ld ix, SpriteProjectile
  call put_sprite

  ret

PlayerPosition:
  .dl (lcdWidth - spriteWidth) / 2

PlayerProjectileSpawned:
  .db $00
PlayerProjectileX:
  .dL $000000
PlayerProjectileY:
  .db $00
