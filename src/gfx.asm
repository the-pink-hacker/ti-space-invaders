vBufferSize .equ (vRamEnd - vRam) / 2
vBuffer0 .equ vRam
vBuffer1 .equ vBuffer0 + vBufferSize

RenderBuffer:
  .dl vBuffer1

fill_screen:
; Fill the entire screen with one color.
;
; Inputs:
;   a = palette-color
; Destorys:
;   Registers:
;     de
;     hl
;     bc
;   Flags (reset):
;     n
;     p/v
;     h
  ld hl, (RenderBuffer)
  ld de, (RenderBuffer)
  inc de
  ld (hl), a
  ld bc, lcdHeight * lcdWidth - 1
  ldir
  ret

put_sprite_16:
; Inputs:
;   de = x
;   b = y (>0)
;   a = height
;   ix = *sprite
; Destorys:
;   All
  ld hl, (RenderBuffer)
  add hl, de
  ld de, lcdWidth
_put_sprite_16_yshift_loop:
  add hl, de
  djnz _put_sprite_16_yshift_loop ; y=0 => y=255
  ex de, hl ; de=*sprite_origin
  ld b, a ; Moves height into b
  push ix ; Move *sprite into hl
  pop hl
_put_sprite_16_render_loop:
  push bc ; 1: height
  ld bc, spriteWidthBig
  ldir
  ex de, hl
  ld bc, lcdWidth - spriteWidthBig
  add hl, bc
  ex de, hl
  pop bc ; 1: height
  djnz _put_sprite_16_render_loop
  ret

put_string:
; Inputs:
;   hl = *str
;   de = x
;   b = y (>0)
  ld a, (hl)
  cp $FF ; Exit if $FF
  ret z
  push hl ; TODO: Look into shadow registers
  push de
  push bc
  call put_char
  pop bc
  pop de

  ld hl, spriteWidthSmall
  add hl, de
  ex de, hl

  pop hl
  inc hl
  jr put_string

put_char:
; Input:
;   de = x
;   b = y
;   a = char_index
; Destroys:
;   All
  ld ix, CharacterTable
  or a
  jr z, _put_char_index_loop_skip
  push bc
  ld b, a
_put_char_index_loop: ; ix += char_index * 3
  inc ix
  inc ix
  inc ix
  djnz _put_char_index_loop
  pop bc
_put_char_index_loop_skip:
  ld a, spriteWidthSmall
  ld ix, (ix)

put_sprite_8:
; Inputs:
;   de = x
;   b = y (>0)
;   a = height
;   ix = *sprite
; Destorys:
;   All
  ld hl, (RenderBuffer)
  add hl, de
  ld de, lcdWidth
_put_sprite_8_yshift_loop:
  add hl, de
  djnz _put_sprite_8_yshift_loop ; y=0 => y=255
  ex de, hl ; de=*sprite_origin
  ld b, a ; Moves height into b
  push ix ; Move *sprite into hl
  pop hl
_put_sprite_8_render_loop:
  push bc ; 1: height
  ld bc, spriteWidthSmall
  ldir
  ex de, hl
  ld bc, lcdWidth - spriteWidthSmall
  add hl, bc
  ex de, hl
  pop bc ; 1: height
  djnz _put_sprite_8_render_loop
  ret

init_lcd:
; Sets up the lcd for 8-bit color and
; loads the color palette.
  call copy_hl_1555_palette
  ld a, lcdBpp8    ; Enable 8-bit color
  ld (mpLcdCtrl), a
  ret

clean_up_lcd:
; Resets lcd to default
  ld a, lcdBpp16
  ld (mpLcdCtrl), a ; Default color mode
  ld hl, vRam
  ld (mpLcdBase), hl
  ret

; https://wikiti.brandonw.net/index.php?title=84PCE:Ports:4000
copy_hl_1555_palette:
; Creates palette
;
; Destorys:
;   All
  ld hl, mpLcdPalette ; palette mem
  ld b, 0
_copy_hl_1555_palette_loop:
  ld d, b
  ld a, b
  and %11000000
  srl d
  rra
  ld e,a
  ld a, %00011111
  and b
  or e
  ld (hl), a
  inc hl
  ld (hl), d
  inc hl
  inc b
  jr nz, _copy_hl_1555_palette_loop
  ret

; 1101 0100 0000 0000 0000 0000
; 1101 0101 0010 1100 0000 0000
; 0000 0001 0010 1100 0000 0000

swap_vbuffer:
; Destorys:
;   Registers:
;     af
  ; Toggles vRam
  ld a, (mpLcdBase + 1)
  push af
  xor %00101100
  ld (mpLcdBase + 1), a
  pop af
  ld (RenderBuffer + 1), a
  ; Second byte
  ld a, (mpLcdBase + 2)
  push af
  xor %00000001
  ld (mpLcdBase + 2), a
  pop af
  ld (RenderBuffer + 2), a
  ret
