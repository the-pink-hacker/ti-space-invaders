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
  xor a
_game_loop:
  xor a ; Sets to black ($00)
  call fill_screen

  call update_player_projectile
  call update_enemies

  ld a, playerHeight
  ld b, playerStartingY
  ld de, (PlayerPosition)
  ld ix, SpritePlayer
  call put_sprite

  call swap_vbuffer

; Check for input
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
  xor a
  cp (hl) ; Check if projectile is spawned
  ret nz  ; Return if already spawned
  ld (hl), 1 ; Set spawned
  ld hl, (PlayerPosition)
  ld (PlayerProjectileX), hl
  ld hl, PlayerProjectileY
  ld (hl), playerStartingY ; Set y
  ret

update_enemies:
  ld ix, EnemyTable
  ld b, 44 ; #enemies
_update_enemies_loop:
  push bc
  ld de, (ix) ; X
  push ix
  ld bc, 0
  ld c, (ix + 4) ; Type
  ld hl, EnemySpriteTable
  add hl, bc
  ld b, (ix + 3) ; Y
  ld ix, (hl) ; *Sprite
  ld a, 8 ; Height
  call put_sprite
  pop ix
  ld de, 5 ; Size
  add ix, de
  pop bc
  djnz _update_enemies_loop
  ret

update_player_projectile:
  ld hl, PlayerProjectileSpawned
  xor a
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
  ld de, (PlayerProjectileX)
  ld ix, SpriteProjectile
  call put_sprite

  ret

point_box_collision:
; Inputs:
;   b  = Y
;   de = X
;   a  = Y-point
;   hl = X-point
  ret

PlayerPosition:
  .dl (lcdWidth - spriteWidth) / 2

PlayerProjectileSpawned:
  .db $00
PlayerProjectileX:
  .dl $000000
PlayerProjectileY:
  .db $00

EnemySpriteTable:
  .dl SpriteEnemyDeath ; Offset: 0
  .dl SpriteEnemyDeath ; Offset: 3
  .dl SpriteEnemy1a    ; Offset: 6
  .dl SpriteEnemy2a    ; Offset: 9
  .dl SpriteEnemy3a    ; Offset: 12

; 11x4     Size: 220
; Enemy    Size: 5
;   X      Size: 3, Offset: 0
;   Y      Size: 1, Offset: 3
;   Type   Size: 1, Offset: 4
EnemyTable:
  .db  72, 0, 0,  8,  6
  .db  88, 0, 0,  8,  6
  .db 104, 0, 0,  8,  6
  .db 120, 0, 0,  8,  6
  .db 136, 0, 0,  8,  6
  .db 152, 0, 0,  8,  6
  .db 168, 0, 0,  8,  6
  .db 184, 0, 0,  8,  6
  .db 200, 0, 0,  8,  6
  .db 216, 0, 0,  8,  6
  .db 232, 0, 0,  8,  6
  .db  72, 0, 0, 24,  9
  .db  88, 0, 0, 24,  9
  .db 104, 0, 0, 24,  9
  .db 120, 0, 0, 24,  9
  .db 136, 0, 0, 24,  9
  .db 152, 0, 0, 24,  9
  .db 168, 0, 0, 24,  9
  .db 184, 0, 0, 24,  9
  .db 200, 0, 0, 24,  9
  .db 216, 0, 0, 24,  9
  .db 232, 0, 0, 24,  9
  .db  72, 0, 0, 40, 12
  .db  88, 0, 0, 40, 12
  .db 104, 0, 0, 40, 12
  .db 120, 0, 0, 40, 12
  .db 136, 0, 0, 40, 12
  .db 152, 0, 0, 40, 12
  .db 168, 0, 0, 40, 12
  .db 184, 0, 0, 40, 12
  .db 200, 0, 0, 40, 12
  .db 216, 0, 0, 40, 12
  .db 232, 0, 0, 40, 12
  .db  72, 0, 0, 56, 12
  .db  88, 0, 0, 56, 12
  .db 104, 0, 0, 56, 12
  .db 120, 0, 0, 56, 12
  .db 136, 0, 0, 56, 12
  .db 152, 0, 0, 56, 12
  .db 168, 0, 0, 56, 12
  .db 184, 0, 0, 56, 12
  .db 200, 0, 0, 56, 12
  .db 216, 0, 0, 56, 12
  .db 232, 0, 0, 56, 12
