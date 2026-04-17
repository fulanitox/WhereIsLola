include "include/hardware.inc"


SECTION "VRAM Code Section", ROM0

CleanOAM:
   ;;LIMPIAR OAM
   ld b, 160
   ld a, 0
   ld hl, $FE00
   .loop
      ld [hl+], a
      dec b
      jr nz, .loop
   ;;---------------
   ret

StartOAM:   
    call CleanOAM
    call ActivarSprites

ActivarSprites:
    ld a, [$FF40]
    or %00000010
    ld [$FF40], a
    ret
