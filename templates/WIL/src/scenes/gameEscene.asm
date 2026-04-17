    include "include/hardware.inc"
    include "include/gbt_player.inc"

    EXPORT poop3_data
    EXPORT gotCow_data
SECTION "Game Escene Vars 2", WRAM0[$c080]
    tileClock: DS 1
    score: DS 1
    maxscore: DS 1
    scene: DS 1
SECTION "Game Escene Vars", WRAM0
    
    velXdes: DS 1
    velYdes: DS 1
SECTION "Game Escene Section", ROM0

;-------------------------------------------------------------------------------
;---------------------------------UPDATE ESCENA--------------------------------
; Funcion que actualiza la escena del juego en cada frame
; Entradas: Ninguna
; Salidas: Ninguna
; Destruye: ninguna
;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
gameScene_init:
    call ScreenOff
    call CleanVRAM
    call cleanScreen
    call CopiarEnVRAM
    call initWindow
    call StartOAM
    call gbt_stop
    call man_entity_init
    call pintarMapa
    call anim_init
    call initScrollGAME
    ; call timer_init
    call crono_init
    ; call random_init
    ld a, 0
    call gbt_loop
    ld [velXdes], a
    ld [velYdes], a
    ld [score], a
    ld [scene], a
    call ScreenOn
    ret

gameEscene_update:
    call gbt_update
    call animationGame_update
    call renderGame_update
    ;call gbt_stop
    call updateTimeFunctions
    call actualize_VELOCIDAD
    call sys_collision_update
    call physics_update
    ; call TIMER_CONTROL
    call cpct_nextRandom_mxor_u8
    call compChangeScene   
    ;call gbt_stop 
    ; call ia 
    ; call colisiones
    ret
updateTimeFunctions:
    ld a, [tiempoANT]     ; Cargar el tiempo anterior en A
    ld b, a               ; Guardar el tiempo anterior en B
    ld a, [SECONDS]       ; Cargar el valor actual de SECONDS
    cp b                  ; Comparar con el tiempo anterior
    jr z, .end          ; Si no hay cambio, saltar
    
    ld [tiempoANT], a     ; Guardar el tiempo actual como tiempo anterior
    call actualize_crono

    .end
    ret
compChangeScene:
    ld a, [scene]
    cp 2
    jr nz, .end
    ld a, 2
    call changeScene
    .end
    ret

;-------------------------------------------------------------------------------
;---------------------------------TIMER CONTROL---------------------------------
;-------------------------------------------------------------------------------
crono_init:
    ld a, $30
    ld [timer], a
    ld a, 0
    ld [tiempoANT], a
    ld a, $8A
    ld [tileClock], a
    ld a, $92
    ld [$9C04], a
    ld a, $80
    ld [$9C05], a
    ld [$9C06], a
    ret
actualize_crono:
    ld a, [$9C00]
    cp $91
    jr z, .next
    inc a
    ld [tileClock], a 
    jr .sigo
    .next
    ld a,$8A
    ld [tileClock], a
    .sigo

    ld a,[timer]
    sub 1                 ; Decrementar el tiempo en 1
    ld [timer], a         ; Guardar el nuevo tiempo
    ld b, a               ; Guardar el tiempo actual en B
    and %00001111
    cp %00001111
    jr nz, .end         ; Si el tiempo no ha llegado a 0, saltar
    ld a, b
    and %11110000
    add %00001001
    ld [timer], a

    .end
    ld a, [timer]
    cp $F9
    jr nz, .final
    ld a, 2
    ld [scene], a
    .final
    ret

suma_crono:
    ld a, [timer]
    ld b, a
    and %00001111
    ; cp 5
    ; jr nz, .compruebo6
    ; ld a, b
    ; and %11110000
    ; add %00010000
    ; jr .final
    .compruebo6
    cp 6
    jr nz, .compruebo7
    ld a, b
    and %11110000
    add %00010000
    jr .final
    .compruebo7
    cp 7
    jr nz, .compruebo8
    ld a, b
    and %11110000
    add %00010001
    jr .final
    .compruebo8
    cp 8
    jr nz, .compruebo9
    ld a, b
    and %11110000
    add %00010010
    jr .final
    .compruebo9
    cp 9
    jr nz, .sinAcarreo
    ld a, b
    and %11110000
    add %00010011
    jr .final
    .sinAcarreo
    ld a, b
    add 4
    .final
    ld [timer], a

    ld a, 0
    ld [lastBTN], a
    ret

suma_score:
    ld a, [score]
    ld b, a
    and %00001111
    cp %00001001
    jr nz, .sumo_normal
    ld a, b
    and %11110000
    add %00010000
    jr .final
    .sumo_normal
    ld a, b
    inc a
    .final
    ld [score], a
    ld a, 0
    ld [lastBTN], a
    ret
;-------------------------------------------------------------------------------
;---------------------------------ACTUALIZAR VELOCIDAD--------------------------
;-------------------------------------------------------------------------------
actualize_VELOCIDAD:
    ld c, 0
    ld a, [lastBTN]
                                 
    ld b, a                     ;Guardamos la dirección en b
    and %10000000               ;abajo
    cp 0
    jr z, .arriba               ;Si no es abajo, vamos a  comprobar si es arriba
    ld a, 0                     ;Si es abajo, indice de personaje 0
    ld d, %0001                 ;Velocidad de movimiento abajo X = 0, Y = 2
    ld e, %0000
    ;call man_actualize_VX_VY    ;Actualizamos la velocidad de la entidad
    ld a, 1
    ld [velYdes], a
    ld a, 0
    ld [velXdes], a

    jr .final

    .arriba                     
    ld a, b                     ;recuperamos el input
    and %01000000               ;arriba
    cp 0
    jr z, .izquierda            ;Si no es arriba, vamos a comprobar si es izquierda
    ld a, 0                     ;Si es arriba, indice de personaje 0
    ld d, %0010                 ;Velocidad de movimiento arriba X = 0, Y = 1
    ld e, %0000
    ;call man_actualize_VX_VY    ;Actualizamos la velocidad de la entidad

    ld a, 2
    ld [velYdes], a
    ld a, 0
    ld [velXdes], a

    jr .final

    .izquierda
    ld a, b                     ;recuperamos el input
    and %00100000               ;izquierda
    cp 0
    jr z, .derecha              ;Si no es izquierda, vamos a comprobar si es derecha
    ld a, 0                     ;Si es izquierda, indice de personaje 0
    ld d, %0000                 ;Velocidad de movimiento izquierda X = 2, Y = 0
    ld e, %0010
    ;call man_actualize_VX_VY    ;Actualizamos la velocidad de la entidad

    ld a, 0
    ld [velYdes], a
    ld a, 2
    ld [velXdes], a

    jr .final

    .derecha
    ld a, b                     ;recuperamos el input
    and %00010000               ;derecha
    cp 0
    jr z, .final                ;Si no es derecha, salimos
    ld a, 0                     ;Si es derecha, indice de personaje 0
    ld d, %0000                 ;Velocidad de movimiento derecha X = 1, Y = 0
    ld e, %0001
    ;call man_actualize_VX_VY    ;Actualizamos la velocidad de la entidad

    ld a, 0
    ld [velYdes], a
    ld a, 1
    ld [velXdes], a

    jr .final

    .final
    ret
;-------------------------------------------------------------------------------
;---------------------------------INITS-----------------------------------------
;-------------------------------------------------------------------------------
initWindow:
    ld a, [$FF40]       ; Cargar el valor actual de LCDC
    or %01100000       ; Activa el bit 5 (window enable) y el bit 6 (window map en $9C00)
    ld [$FF40], a      ; Escribe el valor de vuelta en LCDC
    ld a, 135          ; Cargar el valor actual de WY
    ld [$FF4A], a      ; Escribe el valor de vuelta en WY

    ld a, 104           ; Cargar el valor actual de WX
    add 7
    ld [$FF4B], a      ; Escribe el valor de vuelta en WX
    ret
initScrollGAME:
    ld hl, $FF42
    ld a, 72
    ld [hl], a
    ld hl, $FF43
    ld a, 36
    ld [hl], a
    ret

;-------------------------------------------------------------------------------
;---------------------------------VACA------------------------------------------
;-------------------------------------------------------------------------------
get_Lola:
    call limpiar_vaca
    ; ld a, %11110000   ; Configurar canal 2 (volumen máximo, encendido)
    ; ld [$FF16], a     ; Registrar NR21: Duración del sonido y onda cuadrada (modo de longitud de onda)

    ; ld a, %11111111   ; Configurar envolvente de volumen (inicial y decreciente más lento)
    ; ld [$FF17], a     ; Registrar NR22: Configuración de la envolvente

    ; ld a, $20       ; Parte baja de la frecuencia (frecuencia más baja para sonido grave)
    ; ld [$FF18], a     ; Registrar NR23: Parte baja de la frecuencia

    ; ld a, %11001000   ; Parte alta de la frecuencia y reiniciar el canal 2 (frecuencia más baja)
    ; ld [$FF19], a  
    call gbt_stop
    ld      de, gotCow_data
    ld      bc, BANK(gotCow_data)
    ld      a, $07
    call    gbt_play 

    ld a, $5f
    ld [de], a
    ld [bc], a
    ld [hl], a

    call suma_crono
    call suma_score

ret


limpiar_vaca:
    call wait_VBLANK
    
    ld a, 0
    ld [VacaBool], a
    ld a, [VacaPos1]
    ld h,a
    ld a, [VacaPos2]
    ld l,a
    
    ld a, $5f
    ld [hl], a

    inc hl
    ld a, $5f
    ld [hl], a


    ld bc, 32
    add hl, bc
    ld a, $5f
    ld [hl], a

    dec hl
    ld a, $5f
    ld [hl], a
    ret


cagar_vaca:
    call gbt_stop
    ld      de, poop3_data
    ld      bc, BANK(poop3_data)
    ld      a, $07
    call    gbt_play 
    
    call wait_VBLANK
    
    ld a, 0
    ld [VacaBool], a
    ld a, [VacaPos1]
    ld h,a
    ld a, [VacaPos2]
    ld l,a
    
    ld a, $2E
    ld [hl], a

    inc hl
    ld a, $2F
    ld [hl], a


    ld bc, 32
    add hl, bc
    ld a, $3F
    ld [hl], a

    dec hl
    ld a, $3E
    ld [hl], a
    ret