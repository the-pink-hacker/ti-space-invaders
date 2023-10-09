
#include "build/sprites/player.asm"
;#include "build/sprites/debug.asm"
#include "build/sprites/projectile.asm"
#include "build/sprites/enemy_death.asm"
#include "build/sprites/enemy_1.asm"
#include "build/sprites/enemy_2.asm"
#include "build/sprites/enemy_3.asm"
#include "build/sprites/characters.asm"

spriteEnemy1BitmaskMs .equ ((SpriteEnemy1a & $00FF00) >> 8) ^ ((SpriteEnemy1b & $00FF00) >> 8)
spriteEnemy1BitmaskLs .equ (SpriteEnemy1a & $0000FF) ^ (SpriteEnemy1b & $0000FF)
spriteEnemy2BitmaskMs .equ ((SpriteEnemy2a & $00FF00) >> 8) ^ ((SpriteEnemy2b & $00FF00) >> 8)
spriteEnemy2BitmaskLs .equ (SpriteEnemy2a & $0000FF) ^ (SpriteEnemy2b & $0000FF)
spriteEnemy3BitmaskMs .equ ((SpriteEnemy3a & $00FF00) >> 8) ^ ((SpriteEnemy3b & $00FF00) >> 8)
spriteEnemy3BitmaskLs .equ (SpriteEnemy3a & $0000FF) ^ (SpriteEnemy3b & $0000FF)
