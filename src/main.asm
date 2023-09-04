.nolist
#include "includes/ti84pce.inc"
.list

.org userMem - 2
Start:
  .db tExtTok,tAsm84CeCmp
  call _ClrLCDFull
  jr KeyTest
  ret

KeyTest:
  call _GetKey
  cp kEnter
  jr nz, KeyTest
  ret

.end
