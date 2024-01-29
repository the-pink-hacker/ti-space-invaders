startingFrame := $FF
spriteWidthSmall := 8
spriteWidthBig := 16
playerHeight := 8
enemyHeight := 8
enemyCollisionWidth := 11
enemyCollisionHeight := enemyHeight
enemyMoveDistance := 4
projectileHeight := 8
projectileMoveDistance := 2
playerScreenMargin := 8
playerStartingY := ti.lcdHeight - playerHeight - playerScreenMargin
playerStartingX := (ti.lcdWidth - spriteWidthBig) / 2
playerXMin := playerScreenMargin
playerXMax := ti.lcdWidth - spriteWidthBig - playerScreenMargin
enemyXMin := playerScreenMargin
enemyXMax := ti.lcdWidth - spriteWidthBig - playerScreenMargin
enemyColumns := 11
enemyRows    := 5
totalEnemies := enemyColumns * enemyRows
enemyMemorySize := 5
enemyOffsetX := 72
enemyOffsetY := 32

; 11x5     Size: 275
; Enemy    Size: 5
;   X      Size: 3, Offset: 0
;   Y      Size: 1, Offset: 3
;   Type   Size: 1, Offset: 4
enemyTable := ti.pixelShadow2
enemyTableEnd := enemyTable + (totalEnemies * enemyMemorySize) ; The byte right after enemyTable's end.

enemyScore1 := 30
enemyScore2 := 20
enemyScore3 := 10

; 4x8             Size: 256
; ShieldSegment   Size: 8
;   X             Size: 3, Offset: 0
;   Y             Size: 1, Offset: 3
;   Health        Size: 1, Offset: 4
;   SpriteTable   Size: 3, Offset: 5
shieldSegmentMemorySize := 8
shieldSegments := 4 * 2
totalShields := 4
shieldSegmentSize := 6
shieldsY := ti.lcdHeight - (2 * (shieldSegmentSize + playerScreenMargin)) - playerHeight
shieldXMargin := ((ti.lcdWidth / totalShields) - (shieldSegmentSize * totalShields)) / 2
shield1XOffset := shieldXMargin + 3 * shieldSegmentSize

; Hotkeys
inputLeftRow  := ti.kbdG7
inputLeftBit  := ti.kbitLeft
inputRightRow := ti.kbdG7
inputRightBit := ti.kbitRight
inputFireRow  := ti.kbdG1
inputFireBit  := ti.kbit2nd
inputExitRow  := ti.kbdG6
inputExitBit  := ti.kbitClear

game_loop:
  call setup_shield_table
_game_loop:
  ld a, (EnemyCounter)
  or a
  call z, setup_enemy_table

  ld ix, GameCounter
  inc (ix)

  ; Set enemy move flag
  ld hl, 0
  ld l, (ix)
  ld a, (EnemyCounter)
  add a, 64 - totalEnemies
  call ti.DivHLByA
  or a ; hl % a == 0
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
  ld ix, enemyTable
  ld b, totalEnemies

  ld hl, GameFlags
  ld a, (hl)

  bit gameFlagEnemyMove, a
  jr z, _update_enemies_move_check

  bit gameFlagEnemyEdge, a ; Check edge flag.
  jr z, _update_enemies_move_check
  
  xor a, gameFlagEnemyDirectionBitmask or gameFlagEnemyDownBitmask or gameFlagEnemyEdgeBitmask ; Invert direction, set down, reset edge
  ld (hl), a

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
  ld hl, EnemyCounter
  dec (hl)
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

  ld hl, (ScoreCounter)
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
  ld ix, enemyTable
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

  ; Reset counters.
  ld hl, EnemyCounter
  ld (hl), totalEnemies
  ld hl, GameCounter
  ld (hl), startingFrame

  ; Reset flags
  ld hl, GameFlags
  ld a, (hl)
  set gameFlagEnemyDirection, a ; Set enemy direction to right.
  res gameFlagEnemyEdge, a
  set gameFlagScoreUpdate, a
  ld (hl), a

  ret

setup_shield_table:
  ret

PlayerPosition:
  dl playerStartingX

PlayerProjectileSpawned:
  db $00
PlayerProjectileX:
  dl $000000
PlayerProjectileY:
  db $00

; Counts up each frame.
; Overflow expected.
; First frame is 0.
GameCounter:
  db startingFrame

ScoreCounter:
  dl $000000

EnemyCounter:
  db $00

;;; Game Flags ;;;
; Is set for frames when enemies should move.
; 0: False (default)
; 1: True
gameFlagEnemyMove      := 0
; Toggles every move.
; 0: Left
; 1: Right
gameFlagEnemyDirection := 1
gameFlagEnemyDirectionBitmask := 1 shl gameFlagEnemyDirection
; Whether the enemies should move down this frame.
; 0: False
; 1: True
gameFlagEnemyDown      := 2
gameFlagEnemyDownBitmask      := 1 shl gameFlagEnemyDown
; A enemy has moved to the edge of the screen.
; 0: False
; 1: True
gameFlagEnemyEdge      := 3
gameFlagEnemyEdgeBitmask      := 1 shl gameFlagEnemyEdge
; Set when the score should update.
; 0: False
; 1: True
gameFlagScoreUpdate    := 4

GameFlags:
  db 00010010b

;;; Enemy States ;;;
;   Used for score and death check
enemyStateDead      := 3 * 0
enemyStateExplosion := 3 * 1
enemyState1         := 3 * 2
enemyState2         := 3 * 3
enemyState3         := 3 * 4

EnemySpriteTable:
  dl 0 ; Dead
  dl SpriteEnemyDeath ; Offset: 3
  dl SpriteEnemy1a    ; Offset: 6
  dl SpriteEnemy2a    ; Offset: 9
  dl SpriteEnemy3a    ; Offset: 12

EnemyScoreTable:
  dl 0, 0 ; Death, death animation.
  dl enemyScore1 ; Offset: 6
  dl enemyScore2 ; Offset: 9
  dl enemyScore3 ; Offset: 12

; (0) 1  1  2
;  1  3  4  1
Shield0Table:
  dl 0 ; Dead
  dl SpriteShield1_0
  dl SpriteShield2_0
  dl SpriteShield3_0
  dl SpriteShield4_0

;  0 (1)(1) 2
; (1) 3  4 (1)
Shield1Table:
  dl 0 ; Dead
  dl SpriteShield1_1
  dl SpriteShield2_1
  dl SpriteShield3_1
  dl SpriteShield4_1

;  0  1  1 (2) Sometimes the same as
;  1  3  4  1  1's sprite.
Shield2Table:
  dl 0 ; Dead
  dl SpriteShield1_1
  dl SpriteShield2_2
  dl SpriteShield3_2
  dl SpriteShield4_2

;  0  1  1  2
;  1 (3) 4  1
Shield3Table:
  dl 0 ; Dead
  dl SpriteShield1_3
  dl SpriteShield2_3
  dl SpriteShield3_3
  dl SpriteShield4_3

;  0  1  1  2
;  1  3 (4) 1
Shield4Table:
  dl 0 ; Dead
  dl SpriteShield1_4
  dl SpriteShield2_4
  dl SpriteShield3_4
  dl SpriteShield4_4

ShieldTable:
; Shield 0
 dl shieldXMargin ; X
 db shieldsY      ; Y
 db 4             ; Health
 dl Shield0Table  ; SpriteTable

 dl shieldXMargin + shieldSegmentSize ; X
 db shieldsY                          ; Y
 db 4                                 ; Health
 dl Shield1Table                      ; SpriteTable

 dl shieldXMargin + (2 * shieldSegmentSize) ; X
 db shieldsY                                ; Y
 db 4                                       ; Health
 dl Shield1Table                            ; SpriteTable

 dl shieldXMargin + (3 * shieldSegmentSize) ; X
 db shieldsY                                ; Y
 db 4                                       ; Health
 dl Shield2Table                            ; SpriteTable

 dl shieldXMargin                ; X
 db shieldsY + shieldSegmentSize ; Y
 db 4                            ; Health
 dl Shield1Table                 ; SpriteTable

 dl shieldXMargin + shieldSegmentSize ; X
 db shieldsY + shieldSegmentSize      ; Y
 db 4                                 ; Health
 dl Shield3Table                      ; SpriteTable

 dl shieldXMargin + (2 * shieldSegmentSize) ; X
 db shieldsY + shieldSegmentSize            ; Y
 db 4                                       ; Health
 dl Shield4Table                            ; SpriteTable

 dl shieldXMargin + (3 * shieldSegmentSize) ; X
 db shieldsY + shieldSegmentSize            ; Y
 db 4                                       ; Health
 dl Shield1Table                            ; SpriteTable
