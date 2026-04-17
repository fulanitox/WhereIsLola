SECTION "Entry point", ROM0[$150]

main::
   call timer_init
   call Setup
   call gameLoop
   di     ;; Disable Interrupts
   halt   ;; Halt the CPU (stop procesing here)
