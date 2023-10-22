number_to_string:
; Input:
;   hl = *number (24-bit)
;   ix = *output (8-bytes)
; Output:
;   String is placed at *output
  ld bc, $1234
  ld de, $5678
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
