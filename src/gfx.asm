vBufferSize := (ti.vRamEnd - ti.vRam) / 2
vBuffer0 := ti.vRam
vBuffer1 := vBuffer0 + vBufferSize

RenderBuffer:
  dl vBuffer1

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
  ld bc, ti.lcdHeight * ti.lcdWidth - 1
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
  ld de, ti.lcdWidth
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
  ld bc, ti.lcdWidth - spriteWidthBig
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
; Outputs:
;   hl = *str_end
;   de = x_end
;   b = y
  ld a, (hl)
  cp $FF ; Exit if $FF
  jr z, _put_string_exit
  cp 36 ; Space
  jr z, _put_string_space
  push hl
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

_put_string_space:
  push hl
  ld hl, spriteWidthSmall
  add hl, de
  ex de, hl
  pop hl
  inc hl
  jr put_string

_put_string_exit:
  inc hl
  ret

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
  ld de, ti.lcdWidth
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
  ld bc, ti.lcdWidth - spriteWidthSmall
  add hl, bc
  ex de, hl
  pop bc ; 1: height
  djnz _put_sprite_8_render_loop
  ret

init_lcd:
; Sets up the lcd for 8-bit color and
; loads the color palette.
  call copy_hl_1555_palette
  ld a, ti.lcdBpp8    ; Enable 8-bit color
  ld (ti.mpLcdCtrl), a
  ret

clean_up_lcd:
; Resets lcd to default
  ld a, ti.lcdBpp16
  ld (ti.mpLcdCtrl), a ; Default color mode
  ld hl, ti.vRam
  ld (ti.mpLcdBase), hl
  ret

; https://wikiti.brandonw.net/index.php?title=84PCE:Ports:4000
copy_hl_1555_palette:
; Creates palette
;
; Destorys:
;   All
  ld hl, ti.mpLcdPalette ; palette mem
  ld b, 0
_copy_hl_1555_palette_loop:
  ld d, b
  ld a, b
  and 11000000b
  srl d
  rra
  ld e,a
  ld a, 00011111b
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
  ld a, (ti.mpLcdBase + 1)
  push af
  xor 00101100b
  ld (ti.mpLcdBase + 1), a
  pop af
  ld (RenderBuffer + 1), a
  ; Second byte
  ld a, (ti.mpLcdBase + 2)
  push af
  xor 00000001b
  ld (ti.mpLcdBase + 2), a
  pop af
  ld (RenderBuffer + 2), a
  ret
