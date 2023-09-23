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
; Output:
;   hl = vRamEnd
;   de = vRamEnd
; Destorys:
;   Registers:
;     de
;     hl
;   Flags:
;     z
;     c
  ld hl, (RenderBuffer)
  ld de, 76800
_fill_screen_loop:
  ld (hl), a
  inc hl
  dec de
  push hl
  ld hl, 0
  call _CpHlDe ; Todo: Get rid of syscall
  pop hl
  jr nz, _fill_screen_loop
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
