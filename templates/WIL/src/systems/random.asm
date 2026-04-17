include "include/hardware.inc"

SECTION "Random DATA", WRAM0
; Definir el estado en memoria (32 bits -> 4 bytes)
    state_x:  DS 1 ; Valores iniciales arbitrarios
    state_y:  DS 1
    state_z:  DS 1
    state_w:  DS 1
    VacaPos1: DS 1
    VacaPos2: DS 1
    VacaBool: DS 1
    VacaTime: DS 1

SECTION "Random Section", ROM0
random_init:
    ld a, 0
    ld [VacaBool], a
    ld a, 7
    ld [VacaTime], a
    ld a, [_CTIMER]
    ld b, a
    ld a, [score]
    add a, b
    ld [state_x], a
    ld a, $08
    ld [state_y], a
    ld a, $56
    ld [state_z], a
    ld a, $88
    ld [state_w], a
    ret
; Funcion cpct_nextRandom_mxor_u8 para generar una dirección en el rango $9800 - $9BFF
cpct_nextRandom_mxor_u8:
    ld a, [VacaBool]
    cp 1
    ret z
    ld a, [SECONDS]
    ld [state_x], a
.try_again:
    ld a, [state_x]        ; A = x
    ld b, a                ; Guardar x en B
    ld a, [state_y]        ; A = y
    ld [state_x], a        ; x' = y
    ld a, [state_z]        ; A = z
    ld [state_y], a        ; y' = z
    ld a, [state_w]        ; A = w
    ld [state_z], a        ; z' = w

    ; Calcular t = x ^ (x << 3)
    ld a, b                ; A = x original
    sla a                  ; A = x << 1
    sla a                  ; A = x << 2
    sla a                  ; A = x << 3
    xor b                  ; A = x ^ (x << 3)

    ; Calcular t = t ^ (t >> 1)
    ld b, a                ; Guardar t en B
    srl a                  ; A = t >> 1
    xor b                  ; A = t ^ (t >> 1)
    push af

    ; Calcular w' = w ^ (w << 1) ^ t
    ld a, [state_w]        ; A = w
    ld b, a                ; Guardar w en B
    pop af
    ld c, a                ; C = t
    sla b                  ; B = w << 1
    ld a, [state_w]        ; A = w
    xor b                  ; A = w ^ (w << 1)
    xor c                  ; A = w' = w ^ (w << 1) ^ t
    ld [state_w], a        ; Guardar el nuevo w' en estado

    ; Ajustar el valor en A para abarcar el rango completo de $9800 - $9BFF
    ; Esto requiere un valor de 9 bits (0-1023), dividido en partes H y L.

    ; Limitar A a 8 bits (0-255) para HL
    ld l, a                ; Guardamos A en L como parte baja

    ; Generar bit extra para manejar el cambio de $98xx a $9Bxx
    ld a, [state_y]        ; Cargar estado alternativo en A para variación adicional
    and $03                ; Limitar a los 2 bits bajos (0-3)
    add a, $98             ; Base de rango
    ld h, a                ; Guardamos en H la parte alta dentro del rango $98-$9B

    .check_grass:
    ld d, h
    ld e, l
    ld a, [hl+]
    cp $5f
    jp nz, .try_again

    ld a, [hl]
    cp $5f
    jp nz, .try_again

    ld bc, $001F
    add hl, bc
    ld a, [hl+]
    cp $5f
    jp nz, .try_again

    ld a, [hl]
    cp $5f
    jp nz, .try_again

.done:
    ; Retornar la dirección en HL
    ld h, d
    ld l, e  
    ld bc, $001F
    call pintarVacaCuadrada
    ret


pintarVacaCuadrada:
    call wait_VBLANK
    ld a, 7
    ld [VacaTime], a
    ld a, 1
    ld [VacaBool], a
    ld a, h
    ld [VacaPos1], a
    ld a, l
    ld [VacaPos2], a
    ld a, $28
    ld [hl+], a
    inc a
    ld [hl], a
    add hl, bc
    add $0F
    ld [hl+], a
    inc a
    ld [hl], a
    ret