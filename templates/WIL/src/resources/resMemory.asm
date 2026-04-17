SECTION "btn", HRAM
   lastBTN:: DS 1

   
SECTION "Variables", WRAM0
   vblankFlag:
      ds 1

SECTION "Timer Data", WRAM0
   _CTIMER: DS 1
   SECONDS: DS 1