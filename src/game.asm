spriteWidthSmall .equ 8
spriteWidthBig .equ 16
playerHeight .equ 8
enemyHeight .equ 8
enemyCollisionWidth .equ 11
enemyCollisionHeight .equ enemyHeight
enemyMoveDistance .equ 4
projectileHeight .equ 8
projectileMoveDistance .equ 2
playerScreenMargin .equ 8
playerStartingY .equ lcdHeight - playerHeight - playerScreenMargin
playerStartingX .equ (lcdWidth - spriteWidthBig) / 2
playerXMin .equ playerScreenMargin
playerXMax .equ lcdWidth - spriteWidthBig - playerScreenMargin
enemyXMin .equ playerScreenMargin
enemyXMax .equ lcdWidth - spriteWidthBig - playerScreenMargin
enemyColumns .equ 11
enemyRows    .equ 5
totalEnemies .equ enemyColumns * enemyRows
enemyMemorySize .equ 5
enemyOffsetX .equ 72
enemyOffsetY .equ 32

enemyScore1 .equ 30
enemyScore2 .equ 20
enemyScore3 .equ 10

; Hotkeys
inputLeftRow  .equ kbdG7
inputLeftBit  .equ kbitLeft
inputRightRow .equ kbdG7
inputRightBit .equ kbitRight
inputFireRow  .equ kbdG1
inputFireBit  .equ kbit2nd
inputExitRow  .equ kbdG6
inputExitBit  .equ kbitClear

game_loop:
  call setup_enemy_table
_game_loop:
  ld hl, GameCounter
  inc (hl)

  ; Set enemy move flag
  ld a, (hl) ; a=0 -> 1/256 frames
  sla a ; a=0 -> 1/128 frames
  sla a ; a=0 -> 1/64 frames
  ld hl, GameFlags
  jr z, _game_loop_set_enemy_move

  res gameFlagEnemyMove, (hl) ; Reset flag
  jr _game_loop_enemy_move_skip

_game_loop_set_enemy_move:
  set gameFlagEnemyMove, (hl) ; Set flag

_game_loop_enemy_move_skip:
  xor a ; Sets to black ($00)
  call fill_screen

  call update_player_projectile
  call update_enemies

  ld a, playerHeight
  ld b, playerStartingY
  ld de, (PlayerPosition)
  ld ix, SpritePlayer
  call put_sprite_16

  call update_text

  call swap_vbuffer

; Check for input
  di

  ld hl, inputLeftRow
  bit inputLeftBit, (hl)
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
  jr z, _game_loop
  ret

player_left:
  ld hl, (PlayerPosition)
  ld bc, playerXMin
  push hl
  sbc hl, bc
  pop hl
  ret c
  dec hl
  dec hl
  ld (PlayerPosition), hl
  ret

player_right:
  ld hl, (PlayerPosition)
  ld bc, playerXMax
  push hl
  sbc hl, bc
  pop hl
  ret p
  inc hl
  inc hl
  ld (PlayerPosition), hl
  ret

player_fire:
  ld hl, PlayerProjectileSpawned
  xor a
  cp (hl) ; Check if projectile is spawned
  ret nz  ; Return if already spawned
  ld (hl), 1 ; Set spawned
  ld hl, (PlayerPosition)
  ld bc, (spriteWidthBig - spriteWidthSmall) / 2 ; Center to player
  add hl, bc
  ld (PlayerProjectileX), hl
  ld hl, PlayerProjectileY
  ld (hl), playerStartingY ; Set y
  ret

update_enemies:
  ld ix, EnemyTable
  ld b, totalEnemies

  ld a, (GameFlags)

  bit gameFlagEnemyEdge, a ; Check edge flag.
  jr z, _update_enemies_move_check
  
  xor a, gameFlagEnemyDirectionBitmask | gameFlagEnemyDownBitmask | gameFlagEnemyEdgeBitmask ; Invert direction, set down, reset edge
  ld (GameFlags), a

_update_enemies_move_check:
  bit gameFlagEnemyMove, a
  jr z, _update_enemies_loop

  ld hl, EnemySpriteTable + enemyState1
  ld a, (hl)
  xor spriteEnemy1BitmaskLs
  ld (hl), a
  inc hl
  ld a, (hl)
  xor spriteEnemy1BitmaskMs
  ld (hl), a

  ld hl, EnemySpriteTable + enemyState2
  ld a, (hl)
  xor spriteEnemy2BitmaskLs
  ld (hl), a
  inc hl
  ld a, (hl)
  xor spriteEnemy2BitmaskMs
  ld (hl), a

  ld hl, EnemySpriteTable + enemyState3
  ld a, (hl)
  xor spriteEnemy3BitmaskLs
  ld (hl), a
  inc hl
  ld a, (hl)
  xor spriteEnemy3BitmaskMs
  ld (hl), a
_update_enemies_loop:
  push bc
  ld a, (ix + 4) ; Type
  or a
  jp z, _update_enemies_loop_skip ; Enemy is dead.

  ld hl, (ix) ; Enemy x

  ld a, (GameFlags)

  bit gameFlagEnemyDown, a
  jr z, _update_enemies_loop_move_check

  ld a, (ix + 3) ; Enemy y
  ld b, enemyHeight
  add a, b
  ld (ix + 3), a
  jr _update_enemies_loop_move_skip

_update_enemies_loop_move_check:
  bit gameFlagEnemyMove, a
  jr z, _update_enemies_loop_move_skip ; Jump if not move.
  
  ld bc, enemyMoveDistance

  bit gameFlagEnemyDirection, a
  jr nz, _update_enemies_loop_move_right  

  sbc hl, bc ; Move left
  ld (ix), hl ; Update x

  ld bc, enemyXMin
  sbc hl, bc
  jr nc, _update_enemies_loop_move_skip

  set gameFlagEnemyEdge, a
  ld (GameFlags), a

  jr _update_enemies_loop_move_skip

_update_enemies_loop_move_right:
  add hl, bc ; Move right
  ld (ix), hl ; Update x

  ld bc, enemyXMax
  sbc hl, bc
  jr c, _update_enemies_loop_move_skip

  set gameFlagEnemyEdge, a
  ld (GameFlags), a
_update_enemies_loop_move_skip:
  ld a, (PlayerProjectileSpawned)
  or a
  jr z, _update_enemies_loop_collision_skip ; Projectile not spawned.
  ld a, (PlayerProjectileY)
  ld hl, (PlayerProjectileX)
  ld de, (spriteWidthSmall / 2) + 1 ; Center of projectile.
  add hl, de
  call collision_enemy
  jr nc, _update_enemies_loop_collision_skip ; Didn't collide.

  ld hl, EnemyScoreTable
  ld de, 0
  ld e, (ix + 4)
  add hl, de
  ld hl, (hl) ; Score for killing enemy.

  ld de, (ScoreCounter)
  add hl, de
  ld (ScoreCounter), hl

  ld hl, GameFlags
  set gameFlagScoreUpdate, (hl)

  xor a
  ld (ix + 4), a ; Kill enemy
  ld (PlayerProjectileSpawned), a ; Despawn projectile.
  jr _update_enemies_loop_skip
_update_enemies_loop_collision_skip:
  ld de, (ix) ; X
  ld hl, EnemySpriteTable
  ld bc, 0
  ld c, (ix + 4) ; Type
  add hl, bc
  ld b, (ix + 3) ; Y
  push ix
  ld ix, (hl) ; *Sprite
  ld a, 8 ; Height
  call put_sprite_16
  pop ix
_update_enemies_loop_skip:
  pop bc
  ld de, enemyMemorySize
  add ix, de

  dec b ; djnz
  jp nz, _update_enemies_loop
  
  ld hl, GameFlags
  res gameFlagEnemyDown, (hl)

  ret

update_player_projectile:
  ld hl, PlayerProjectileSpawned
  xor a
  cp (hl)
  ret z ; Return if not spawned.

  ld a, (PlayerProjectileY)
  sbc a, projectileMoveDistance ; Move projectile up.
  jr c, _update_player_projectile_despawn

  ld hl, PlayerProjectileY
  ld (hl), a ; Update Y

  ld b, a ; Y
  ld a, projectileHeight
  ld de, (PlayerProjectileX)
  ld ix, SpriteProjectile
  jp put_sprite_8

_update_player_projectile_despawn:
  ld (hl), 0
  ret

update_text:
  ld hl, GameFlags
  bit gameFlagScoreUpdate, (hl)
  jr z, _update_text_display

  res gameFlagScoreUpdate, (hl)

  ld hl, ScoreCounter
  ld ix, TextScore + 6
  call number_to_string

_update_text_display:
  ld hl, TextScore
  ld de, 8
  ld b, 8
  call put_string

  ret

collision_enemy:
; Input:
;   ix = *enemy
;   hl = projectile_x
;   a = projectile_y
; Output:
;   carry = Collision
; Destorys:
;   a
;   hl
;   bc
  ld bc, (ix) ; enemy_left
  inc bc ; Left offset.
  inc bc
  inc bc
  sbc hl, bc
  jr c, _collision_failed ; Left bounds.

  ld bc, enemyCollisionWidth
  sbc hl, bc
  ret nc ; Right bounds.

  ld b, (ix + 3) ; enemy_top
  sbc a, b
  jr c, _collision_failed ; Top bounds.

  ld b, enemyCollisionHeight
  sbc a, b
  ret ; Bottom bounds.
_collision_failed:
  or a ; Reset carry.
  ret

setup_enemy_table:
  ld ix, EnemyTable
  ld de, spriteWidthBig

  ; Row 1
  ld a, enemyOffsetY
  ld b, enemyColumns
  ld c, enemyState1
  ld hl, enemyOffsetX
_setup_enemy_table_row_1:
  ld (ix), hl ; X position.
  ld (ix + 3), a ; Y position.
  ld (ix + 4), c ; Enemy state
  add hl, de
  push de
  ld de, enemyMemorySize
  add ix, de
  pop de
  djnz _setup_enemy_table_row_1

  ; Row 2
  add a, e
  ld b, enemyColumns
  ld c, enemyState2
  ld hl, enemyOffsetX
_setup_enemy_table_row_2:
  ld (ix), hl ; X position.
  ld (ix + 3), a ; Y position.
  ld (ix + 4), c ; Enemy state
  add hl, de
  push de
  ld de, enemyMemorySize
  add ix, de
  pop de
  djnz _setup_enemy_table_row_2

  ; Row 3
  add a, e
  ld b, enemyColumns
  ld hl, enemyOffsetX
_setup_enemy_table_row_3:
  ld (ix), hl ; X position.
  ld (ix + 3), a ; Y position.
  ld (ix + 4), c ; Enemy state
  add hl, de
  push de
  ld de, enemyMemorySize
  add ix, de
  pop de
  djnz _setup_enemy_table_row_3

  ; Row 4
  add a, e
  ld b, enemyColumns
  ld c, enemyState3
  ld hl, enemyOffsetX
_setup_enemy_table_row_4:
  ld (ix), hl ; X position.
  ld (ix + 3), a ; Y position.
  ld (ix + 4), c ; Enemy state
  add hl, de
  push de
  ld de, enemyMemorySize
  add ix, de
  pop de
  djnz _setup_enemy_table_row_4

  ; Row 2
  add a, e
  ld b, enemyColumns
  ld hl, enemyOffsetX
_setup_enemy_table_row_5:
  ld (ix), hl ; X position.
  ld (ix + 3), a ; Y position.
  ld (ix + 4), c ; Enemy state
  add hl, de
  push de
  ld de, enemyMemorySize
  add ix, de
  pop de
  djnz _setup_enemy_table_row_5

  ret

PlayerPosition:
  .dl playerStartingX

PlayerProjectileSpawned:
  .db $00
PlayerProjectileX:
  .dl $000000
PlayerProjectileY:
  .db $00

; Counts up each frame.
; Overflow expected.
; First frame is 0.
GameCounter:
  .db $FF

ScoreCounter:
  .dl 0

;;; Game Flags ;;;
; Is turned on for frames where the enemies should move.
; 0: False (default)
; 1: True
gameFlagEnemyMove      .equ 0
; Toggles every move.
; 0: Left
; 1: Right (default)
gameFlagEnemyDirection .equ 1
gameFlagEnemyDirectionBitmask .equ 1 << gameFlagEnemyDirection
; Whether the enemies should move down this frame.
; 0: False (default)
; 1: True
gameFlagEnemyDown      .equ 2
gameFlagEnemyDownBitmask     .equ 1 << gameFlagEnemyDown
; A enemy has moved to the edge of the screen.
; 0: False (default)
; 1: True
gameFlagEnemyEdge      .equ 3
gameFlagEnemyEdgeBitmask     .equ 1 << gameFlagEnemyEdge
; Is set when the score should update.
; 0: False (default)
; 1: True
gameFlagScoreUpdate    .equ 4

GameFlags:
  .db %00000010

;;; Enemy States ;;;
;   Used for score and death check
enemyStateDead      .equ 3 * 0
enemyStateExplosion .equ 3 * 1
enemyState1         .equ 3 * 2
enemyState2         .equ 3 * 3
enemyState3         .equ 3 * 4

EnemySpriteTable:
  .dl 0 ; Dead
  .dl SpriteEnemyDeath ; Offset: 3
  .dl SpriteEnemy1a    ; Offset: 6
  .dl SpriteEnemy2a    ; Offset: 9
  .dl SpriteEnemy3a    ; Offset: 12

EnemyScoreTable:
  .dl 0, 0 ; Death, death animation.
  .dl enemyScore1 ; Offset: 6
  .dl enemyScore2 ; Offset: 9
  .dl enemyScore3 ; Offset: 12

; 11x4     Size: 220
; Enemy    Size: 5
;   X      Size: 3, Offset: 0
;   Y      Size: 1, Offset: 3
;   Type   Size: 1, Offset: 4
EnemyTable:
  .db 0, 0, 0, 0, 0
  .db 0, 0, 0, 0, 0
  .db 0, 0, 0, 0, 0
  .db 0, 0, 0, 0, 0
  .db 0, 0, 0, 0, 0
  .db 0, 0, 0, 0, 0
  .db 0, 0, 0, 0, 0
  .db 0, 0, 0, 0, 0
  .db 0, 0, 0, 0, 0
  .db 0, 0, 0, 0, 0
  .db 0, 0, 0, 0, 0
  .db 0, 0, 0, 0, 0
  .db 0, 0, 0, 0, 0
  .db 0, 0, 0, 0, 0
  .db 0, 0, 0, 0, 0
  .db 0, 0, 0, 0, 0
  .db 0, 0, 0, 0, 0
  .db 0, 0, 0, 0, 0
  .db 0, 0, 0, 0, 0
  .db 0, 0, 0, 0, 0
  .db 0, 0, 0, 0, 0
  .db 0, 0, 0, 0, 0
  .db 0, 0, 0, 0, 0
  .db 0, 0, 0, 0, 0
  .db 0, 0, 0, 0, 0
  .db 0, 0, 0, 0, 0
  .db 0, 0, 0, 0, 0
  .db 0, 0, 0, 0, 0
  .db 0, 0, 0, 0, 0
  .db 0, 0, 0, 0, 0
  .db 0, 0, 0, 0, 0
  .db 0, 0, 0, 0, 0
  .db 0, 0, 0, 0, 0
  .db 0, 0, 0, 0, 0
  .db 0, 0, 0, 0, 0
  .db 0, 0, 0, 0, 0
  .db 0, 0, 0, 0, 0
  .db 0, 0, 0, 0, 0
  .db 0, 0, 0, 0, 0
  .db 0, 0, 0, 0, 0
  .db 0, 0, 0, 0, 0
  .db 0, 0, 0, 0, 0
  .db 0, 0, 0, 0, 0
  .db 0, 0, 0, 0, 0
  .db 0, 0, 0, 0, 0
  .db 0, 0, 0, 0, 0
  .db 0, 0, 0, 0, 0
  .db 0, 0, 0, 0, 0
  .db 0, 0, 0, 0, 0
  .db 0, 0, 0, 0, 0
  .db 0, 0, 0, 0, 0
  .db 0, 0, 0, 0, 0
  .db 0, 0, 0, 0, 0
  .db 0, 0, 0, 0, 0
  .db 0, 0, 0, 0, 0
