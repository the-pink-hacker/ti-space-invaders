; Color constants
black .equ %00000000
white .equ %11111111
red   .equ %11100000
green .equ %00000011
blue  .equ %00011100
spriteWidth .equ 16

SpritePlayer:
  .db black, black, black, black, black, black, black, white
  .db black, black, black, black, black, black, black, black
  .db black, black, black, black, black, black, white, white
  .db white, black, black, black, black, black, black, black
  .db black, black, black, black, black, black, white, white
  .db white, black, black, black, black, black, black, black
  .db black, black, black, white, white, white, white, white
  .db white, white, white, white, white, black, black, black
  .db black, black, white, white, white, white, white, white
  .db white, white, white, white, white, white, black, black
  .db black, black, white, white, white, white, white, white
  .db white, white, white, white, white, white, black, black
  .db black, black, white, white, white, white, white, white
  .db white, white, white, white, white, white, black, black
  .db black, black, white, white, white, white, white, white
  .db white, white, white, white, white, white, black, black
