; Sprites
include "src/generated/sprites/player.asm"
include "src/generated/sprites/projectile.asm"
include "src/generated/sprites/enemy_death.asm"
include "src/generated/sprites/enemy_1.asm"
include "src/generated/sprites/enemy_2.asm"
include "src/generated/sprites/enemy_3.asm"
include "src/generated/sprites/enemy_4.asm"
include "src/generated/sprites/characters.asm"
include "src/generated/sprites/shield_1.asm"
include "src/generated/sprites/shield_2.asm"
include "src/generated/sprites/shield_3.asm"
include "src/generated/sprites/shield_4.asm"

spriteEnemy1BitmaskMs := ((SpriteEnemy1a and $00FF00) shr 8) xor ((SpriteEnemy1b and $00FF00) shr 8)
spriteEnemy1BitmaskLs := (SpriteEnemy1a and $0000FF) xor (SpriteEnemy1b and $0000FF)
spriteEnemy2BitmaskMs := ((SpriteEnemy2a and $00FF00) shr 8) xor ((SpriteEnemy2b and $00FF00) shr 8)
spriteEnemy2BitmaskLs := (SpriteEnemy2a and $0000FF) xor (SpriteEnemy2b and $0000FF)
spriteEnemy3BitmaskMs := ((SpriteEnemy3a and $00FF00) shr 8) xor ((SpriteEnemy3b and $00FF00) shr 8)
spriteEnemy3BitmaskLs := (SpriteEnemy3a and $0000FF) xor (SpriteEnemy3b and $0000FF)

; Text
include "src/generated/texts.asm"
