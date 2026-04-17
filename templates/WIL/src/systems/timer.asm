include "include/hardware.inc"

SECTION "TimerInt",ROM0[$0050]
    call TIMER_CONTROL
    reti

timer_init:
    ld a, %00000100 ; bit 2
    ld [rIE], a     ; activar interrupcion del timer
    ld [rTAC], a    ; encender el timer
    ld a, 51    
    ld [rTMA], a    ; cuando TIMA se desborde, este es su

    ; valor inicial, (1/4096)*(255-51) = 0.049 s
    ld [rTIMA], a   ; tiempo inicial (solo primera interrupcion)
    ld a, 0
    ld [_CTIMER], a ; Contador del timer
    ld a, 0         ; Inicializar los segundos a (60)
    ld [SECONDS], a ; Inicializar los segundos
    ret

TIMER_CONTROL:
    ld a, [_CTIMER]
    cp 56              ; si a == 60, pasa 1 minuto ((20))
    jr z, .inc_seconds ; if a == 20, pasa 1 segundo

    inc a
    ld [_CTIMER], a ; si no, se incrementa el control
    jr .tend

    .inc_seconds
    ld a, 0
    ld [_CTIMER], a ; reiniciar el contador
    ld a, [SECONDS]
    inc a
    ld [SECONDS], a ; incrementar los segundos

    ld a, [currentScene]
    cp 1
    jr nz, .tend
    
    call checkTimerVaca
    .tend
    ret

;; Añaide segundos al timer
;; INPUT: B = Seconds to add
add_timer:
    ld a,[SECONDS]
    add b
    ld [SECONDS], a
    ret

checkTimerVaca:
    ld a, [VacaTime]
    dec a
    ld [VacaTime], a
    cp 0
    ret nz
    call cagar_vaca
    call cpct_nextRandom_mxor_u8
    ret