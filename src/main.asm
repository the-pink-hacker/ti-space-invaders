.nolist
#include "includes/ti84pce.inc"
.list

.org userMem - 2
.db tExtTok, tAsm84CeCmp
Start:
  call _RunIndicOff
  call _ClrLCDAll
  call _GetKey
Exit:
  call _ClrLCDAll
  call _DrawStatusBar
  call _GrBufClr ; Clears the graph
  set graphDraw, (iy + graphFlags) ; Forces the graph to rerender
  ret

GameLoop:
  call _GrBufClr
  ld de, PlotSScreen
  ;ld hl, Data
  ld bc, 64
  ldir
  call _GrBufCpyV
  call _GetKey
  cp kClear
  jr nz, GameLoop
  ret

.end
