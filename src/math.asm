number_to_string:
; Input:
;   hl = number
;   ix = *output (8-bytes)
; Output:
;   String is placed at *output
  xor a
  ld b, a
  ld c, a
  ld d, a
  ld e, a

  bit 0, l
  jr z, _number_to_string_1_1

  inc e ; daa unnecessary.
        ; Always valid BCD.

_number_to_string_1_1: ; 00 00 00 02
  bit 1, l
  jr z, _number_to_string_1_2

  inc e ; daa unnecessary.
  inc e ; Always valid BCD.
_number_to_string_1_2: ; 00 00 00 04
  bit 2, l
  jr z, _number_to_string_1_3

  ; Byte-1
  ; Max: 07
  ld a, e
  add a, $04
  ld e, a
_number_to_string_1_3: ; 00 00 00 08
  bit 3, l
  jr z, _number_to_string_1_4

  ; Byte-1
  ; Max: 15
  ld a, e
  add a, $08
  daa
  ld e, a
_number_to_string_1_4: ; 00 00 00 16
  bit 4, l
  jr z, _number_to_string_1_5

  ; Byte-1
  ld a, e
  add a, $16
  daa
  ld e, a
_number_to_string_1_5: ; 32
  bit 5, l
  jr z, _number_to_string_1_6

  ; Byte-1
  ld a, e
  add a, $32
  daa
  ld e, a
_number_to_string_1_6: ; 00 00 00 64
  bit 6, l
  jr z, _number_to_string_1_7

  ; Byte-1
  ld a, e
  add a, $64
  daa
  ld e, a

  jr nc, _number_to_string_1_7

  ; Carry one.
  inc d

_number_to_string_1_7: ; 00 00 01 28
  bit 7, l
  jr z, _number_to_string_2_0

  ; Byte-1
  ld a, e
  add a, $28
  daa
  ld e, a

  ; Byte 2
  ; Max: 02
  ld a, d
  adc a, $01
  ld d, a
_number_to_string_2_0: ; 00 00 02 56
  bit 0, h
  jr z, _number_to_string_2_1

  ; Byte-1
  ld a, e
  add a, $56
  daa
  ld e, a

  ; Byte-2
  ; Max: 05
  ld a, d
  adc a, $02
  ld d, a

_number_to_string_2_1: ; 00 00 05 12
  bit 1, h
  jr z, _number_to_string_2_2

  ; Byte-1
  ld a, e
  add a, $12
  daa
  ld e, a

  ; Byte-2
  ; Max: 10
  ld a, d
  adc a, $05
  daa
  ld d, a
_number_to_string_2_2: ; 00 00 10 24
  bit 2, h
  jr z, _number_to_string_2_3

  ; Byte-1
  ld a, e
  add a, $24
  daa
  ld e, a

  ; Byte-2
  ; Max: 20
  ld a, d
  adc a, $10
  daa
  ld d, a
_number_to_string_2_3: ; 00 00 20 48
  bit 3, h
  jr z, _number_to_string_2_4

  ; Byte-1
  ld a, e
  add a, $48
  daa
  ld e, a

  ; Byte-2
  ; Max: 40
  ld a, d
  adc a, $20
  daa
  ld d, a
_number_to_string_2_4: ; 00 00 40 96
  bit 4, h
  jr z, _number_to_string_2_5

  ; Byte-1
  ld a, e
  add a, $96
  daa
  ld e, a

  ; Byte-2
  ; Max: 81
  ld a, d
  adc a, $40
  daa
  ld d, a
_number_to_string_2_5: ; 00 00 81 92
  bit 5, h
  jr z, _number_to_string_2_6

  ; Byte-1
  ld a, e
  add a, $92
  daa
  ld e, a

  ; Byte-2
  ld a, d
  adc a, $81
  daa
  ld d, a

  jr nc, _number_to_string_2_6

  inc c ; Carry.

_number_to_string_2_6: ; 00 01 63 84
  bit 6, h
  jr z, _number_to_string_2_7

  ; Byte-1
  ld a, e
  add a, $84
  daa
  ld e, a

  ; Byte-2
  ld a, d
  adc a, $63
  daa
  ld d, a

  ; Byte-3
  ; Max: 03
  ld a, c
  adc a, $01
  ld c, a
_number_to_string_2_7: ; 00 03 27 68
  bit 7, h
  jr z, _number_to_string_3_0

  ; Byte-1
  ld a, e
  add a, $68
  daa
  ld e, a

  ; Byte-2
  ld a, d
  adc a, $27
  daa
  ld d, a

  ; Byte-3
  ; Max: 06
  ld a, c
  adc a, $03
  ld c, a
_number_to_string_3_0: ; 00 06 55 36
  call _SetAToHLU
  ld h, a
  bit 0, h
  jr z, _number_to_string_3_1

  ; Byte-1
  ld a, e
  add a, $36
  daa
  ld e, a

  ; Byte-2
  ld a, d
  adc a, $55
  daa
  ld d, a

  ; Byte-3
  ; Max: 13
  ld a, c
  adc a, $06
  daa
  ld c, a
_number_to_string_3_1: ; 00 13 10 72
  bit 1, h
  jr z, _number_to_string_3_2

  ; Byte-1
  ld a, e
  add a, $72
  daa
  ld e, a

  ; Byte-2
  ld a, d
  adc a, $10
  daa
  ld d, a

  ; Byte-3
  ld a, c
  adc a, $13
  daa
  ld c, a
_number_to_string_3_2: ; 00 26 21 44
  bit 2, h
  jr z, _number_to_string_3_3

  ; Byte-1
  ld a, e
  add a, $44
  daa
  ld e, a

  ; Byte-2
  ld a, d
  adc a, $21
  daa
  ld d, a

  ; Byte-3
  ld a, c
  adc a, $26
  daa
  ld c, a
_number_to_string_3_3: ; 00 52 42 88
  bit 3, h
  jr z, _number_to_string_3_4

  ; Byte-1
  ld a, e
  add a, $88
  daa
  ld e, a

  ; Byte-2
  ld a, d
  adc a, $42
  daa
  ld d, a

  ; Byte-3
  ld a, c
  adc a, $52
  daa
  ld c, a

  jr nc, _number_to_string_3_4

  inc b ; Carry
_number_to_string_3_4: ; 01 04 85 76
  bit 4, h
  jr z, _number_to_string_3_5

  ; Byte-1
  ld a, e
  add a, $76
  daa
  ld e, a

  ; Byte-2
  ld a, d
  adc a, $85
  daa
  ld d, a

  ; Byte-3
  ld a, c
  adc a, $04
  daa
  ld c, a

  ; Byte-4
  ; Max: 02
  ld a, b
  adc a, $01
  ld b, a
_number_to_string_3_5: ; 02 09 71 52
  bit 5, h
  jr z, _number_to_string_3_6

  ; Byte-1
  ld a, e
  add a, $52
  daa
  ld e, a

  ; Byte-2
  ld a, d
  adc a, $71
  daa
  ld d, a

  ; Byte-3
  ld a, c
  adc a, $09
  daa
  ld c, a

  ; Byte-4
  ; Max: 04
  ld a, b
  adc a, $02
  ld b, a
_number_to_string_3_6: ; 04 19 43 04
  bit 6, h
  jr z, _number_to_string_3_7

  ; Byte-1
  ld a, e
  add a, $04
  daa
  ld e, a

  ; Byte-2
  ld a, d
  adc a, $43
  daa
  ld d, a

  ; Byte-3
  ld a, c
  adc a, $19
  daa
  ld c, a

  ; Byte-4
  ; Max: 08
  ld a, b
  adc a, $04
  ld b, a
_number_to_string_3_7: ; 08 38 86 08
  bit 7, h
  jr z, _number_to_string_end

  ; Byte-1
  ld a, e
  add a, $08
  daa
  ld e, a

  ; Byte-2
  ld a, d
  adc a, $86
  daa
  ld d, a

  ; Byte-3
  ld a, c
  adc a, $38
  daa
  ld c, a

  ; Byte-4
  ; Max: 16
  ld a, b
  adc a, $08
  daa
  ld b, a
_number_to_string_end:
  ld a, $0F
  and b
  ld (ix + 1), a

  srl b
  srl b
  srl b
  srl b
  ld (ix), b

  ld a, $0F
  and c
  ld (ix + 3), a

  srl c
  srl c
  srl c
  srl c
  ld (ix + 2), c

  ld a, $0F
  and d
  ld (ix + 5), a

  srl d
  srl d
  srl d
  srl d
  ld (ix + 4), d

  ld a, $0F
  and e
  ld (ix + 7), a

  srl e
  srl e
  srl e
  srl e
  ld (ix + 6), e

  ret
