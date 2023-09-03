.nolist
#include "includes/ti84pce.inc"
.list

.org userMem-2
ProgramStart:
  .db tExtTok,tAsm84CeCmp

PROGRAM_HEADER:
  jp PROGRAM_START

PROGRAM_START:
  ld a, 64
  ld b, 25
  jp ALPHABET
  ret

ALPHABET:
  inc a
  call _putc
  ; Decrease b
  ; If b == 0 -> continue
  ; If b != 0 -> ALPHABET
  djnz ALPHABET
  ret
