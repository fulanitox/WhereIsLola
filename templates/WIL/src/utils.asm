include "include/hardware.inc"
SECTION "Utils", ROM0 [$300]

utils::
;---------------------------------------------------------
; Función: ActivarSprites
;---------------------------------------------------------
; ActivarSprites:
;     ld a, [$FF40]
;     or %00000010
;     ld [$FF40], a
; ret

;---------------------------------------------------------
; Función: Pintar los tiles en VRAM ordenados
; Input: HL = Dirección de inicio de los tiles
;        BC = Dirección de inicio de los tiles en ROM
;        DE = Número de bytes a copiar
; Destruye: AF, BC, DE
;---------------------------------------------------------
CopiarEnVRAM_cuadrados:
    .bucle
        ld a, 32
        .arriba
            push af

            ld a, h             ; Con esto realizamos bien el salto de linea
            cp $81
            jr nz, .no_sumo
            ld a, l
            cp $00
            jr nz, .no_sumo
            ld h, $82
            ld l, $00

            .no_sumo
            ld a, [bc]
            ld [hl+], a
            inc bc
            pop af
            dec de
            dec a
        jr nz, .arriba

        ld a, 32
        push hl
        push bc
        ld bc, $E0
        add hl, bc
        pop bc
        .abajo
            push af
            ld a, [bc]
            ld [hl+], a
            inc bc
            pop af
            dec de
            dec a
        jr nz, .abajo
        pop hl

        ld a, d
        or e
    jr nz, .bucle
    ret


;---------------------------------------------------------
; Función: Pintar los tiles en VRAM ordenados
; Input: HL = Dirección de inicio de los tiles
;        BC = Dirección de inicio de los tiles en ROM
;        DE = Número de bytes a copiar
; Destruye: AF, BC, DE
;---------------------------------------------------------


CopiarEnVRAM_recto:
    .loop
        ld a, [bc]
        ld [hl+], a
        inc bc
        dec de          ; Decrementa DE
        ld a, e         ; Carga el byte menos significativo de DE
        or d            ; Comprueba si DE es cero
        jr nz, .loop    ; Si 'e' no es cero, repite el bucle    
    ret
;---------------------------------------------------------
; Función: Copiar en VRAM a caca
; Destruye: HL, BC, DE
;---------------------------------------------------------
CopiarEnVRAM_caca:
    ld hl, $82E0
    ld bc, CACA_SP
    ld de, CACA_SP_END - CACA_SP
    call CopiarEnVRAM_cuadrados
    ret

;---------------------------------------------------------
; Función: Copiar en VRAM a laly
; Destruye: HL, BC, DE
;---------------------------------------------------------
CopiarEnVRAM_laly:
    ld hl, $8280
    ld bc, LALY_SP
    ld de, LALY_SP_END - LALY_SP
    call CopiarEnVRAM_cuadrados
    ret

;---------------------------------------------------------
; Función: Copiar en VRAM a robert
; Destruye: HL, BC, DE
;---------------------------------------------------------
CopiarEnVRAM_robert:
    ld hl, $8000
    ld bc, ROB_SP
    ld de, ROB_SP_END - ROB_SP
    call CopiarEnVRAM_cuadrados
    ret

;---------------------------------------------------------
; Función: Copiar en VRAM a robert
; Destruye: HL, BC, DE
;---------------------------------------------------------

CopiarEnVRAM_vallas:
    ld hl, $8600
    ld bc, VALLAS_TL
    ld de, VALLAS_TL_END - VALLAS_TL
    call CopiarEnVRAM_recto

    ld hl, $85F0
    ld bc, FONDO_TL
    ld de, FONDO_TL_END - FONDO_TL
    call CopiarEnVRAM_recto
    ret

CopiarEnVRAM_numeros:
    ld hl, $8800
    ld bc, NUMEROS_SP
    ld de, NUMEROS_SP_END - NUMEROS_SP
    call CopiarEnVRAM_recto
    ret
;---------------------------------------------------------
; Función: Copiar en VRAM mis tiles
;---------------------------------------------------------
CopiarEnVRAM:
    call CopiarEnVRAM_robert
    call CopiarEnVRAM_laly
    call CopiarEnVRAM_caca
    call CopiarEnVRAM_vallas
    call CopiarEnVRAM_numeros
ret

;---------------------------------------------------------
; Función: Wait VBLANK
;---------------------------------------------------------
wait_VBLANK:
   ld a, [$FF44]
   cp 144
   jr nz, wait_VBLANK
ret
;---------------------------------------------------------
; Función: VBLANK Handler
;---------------------------------------------------------
vblankHandler:
    push hl
    push af
    ld hl, vblankFlag
    ld a, 1
    ld [hl], a
    pop af
    pop hl
ret
;---------------------------------------------------------
; Función: Limpiar pantalla 
;---------------------------------------------------------
cleanScreen:
    ld hl, $9800
    ld a, $7F
    ld c, 200000
    .total
        ld b, 32
        .pintar:
            ld [hl], a
            inc hl
            dec b
        jr nz, .pintar
        dec c
    jr nz, .total
    ret

;---------------------------------------------------------
; Pintar Mapa
;---------------------------------------------------------
pintarMapa:
    ld hl, $9800
    ld bc, MAPA_TL
    ld de, MAPA_TL_END - MAPA_TL
    .loop
        ld a, [bc]
        ld [hl], a
        inc hl
        inc bc
        dec de          ; Decrementa DE
        ld a, e         ; Carga el byte menos significativo de DE
        or d            ; Comprueba si DE es cero
        jr nz, .loop    ; Si 'e' no es cero, repite el bucle    
    ret

;---------------------------------------------------------
; Función: Setup 
;---------------------------------------------------------
; setup:
;     call cleanScreen
    
;     call StartOAM           ; Inicializa la OAM
;     call CopiarEnVRAM       ; Copia los tiles en la VRAM
    
;     ;Aumentamos el tamaño de los sprites a 8x16
;     ld a,[$FF40]
;     or %00000100
;     ld [$FF40],a 

;     ;Valores Paleta VRAM
;      ld a, %11100100  ; Aquí defines los colores en la paleta (el formato es BGR en bits)
;      ld [$FF47], a     ; Guardas la paleta en el registro de paleta de fondo

;     ; ;Valores Paleta OAM
;     ld a, %11100100  ; Aquí defines los colores en la paleta (el formato es BGR en bits)
;     ld [$FF48], a     ; Guardas la paleta en el registro de paleta de fondo
; ret

; ----------------------------------------ESCUTIA--------------------
; ----------------------------------------ESCUTIA--------------------
; ----------------------------------------ESCUTIA--------------------
; ----------------------------------------ESCUTIA--------------------
; ----------------------------------------ESCUTIA--------------------
; ----------------------------------------ESCUTIA--------------------
; ----------------------------------------ESCUTIA--------------------
; ----------------------------------------ESCUTIA--------------------

Setup:

    call ScreenOff

    ; call man_entity_init
    ; call anim_init

    ; INICIO SETUP
    ; --------------------------------------
    ;GUARDAR PALETA VRAM
    ld a, %11100100
    ld [$FF47], a

    ; GUARDAR PALETA OAM
    ld a, %11100100
    ld [$FF48], a
    

    call cleanScreen
    ;SAVE ROCA TO VRAM

    ;Pone Boton inicial a 0 para que empieze quieto
    ld hl, lastBTN
    ld [hl], 0

    
    call ScreenOn
ret



ScreenOff:
    call wait_VBLANK
    ld a, [rLCDC]
    res 7 , a
    ld [rLCDC], a
    ret

ScreenOn: 
    ld a, [rLCDC]
    set 7 , a
    ld [rLCDC], a
    ret


CleanVRAM:
    ld hl, $8000
    ld a, $00
    ld c, 916
    .total
        ld b, $10
        .pintar:
            ld [hl], a
            inc hl
            dec b
        jr nz, .pintar
        dec c
    jr nz, .total
    ret