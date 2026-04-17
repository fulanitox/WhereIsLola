include "include/hardware.inc"
SECTION "Render Section VARS", WRAM0
    timer: DS 1
    tiempoANT: DS 1
SECTION "Render Section", ROM0
renderExtra_init:
    ld a, [maxscore]
    ld b,a
    and %11110000        ; Aislar el nibble más significativo
    swap a               ; Intercambiar los nibbles
    rla 
    rla 
    add $80              ; Ajustar para que el tile '0' sea el correcto
    ld [$99A8], a        ; Guardar el primer dígito en la posición del tile
    inc a
    ld [$99C8], a
    inc a
    ld [$99A9], a
    inc a
    ld [$99C9], a

    ; Extraer la parte menos significativa (unidades)
    ld a, b              ; Cargar el tiempo anterior de nuevo en A
    and %00001111        ; Aislar el nibble menos significativo
    rla 
    rla 
    add $80              ; Ajustar para que el tile '0' sea el correcto
    ld [$99AA], a        ; Guardar el segundo dígito en la siguiente posición del tile
    inc a
    ld [$99CA], a
    inc a
    ld [$99AB], a
    inc a
    ld [$99CB], a

    ret
renderGameOver_init:
    ld a, [score]
    ld b,a
    and %11110000        ; Aislar el nibble más significativo
    swap a               ; Intercambiar los nibbles
    rla 
    rla 
    add $80              ; Ajustar para que el tile '0' sea el correcto
    ld [$99C8], a        ; Guardar el primer dígito en la posición del tile
    inc a
    ld [$99E8], a
    inc a
    ld [$99C9], a
    inc a
    ld [$99E9], a

    ; Extraer la parte menos significativa (unidades)
    ld a, b              ; Cargar el tiempo anterior de nuevo en A
    and %00001111        ; Aislar el nibble menos significativo
    rla 
    rla 
    add $80              ; Ajustar para que el tile '0' sea el correcto
    ld [$99CA], a        ; Guardar el segundo dígito en la siguiente posición del tile
    inc a
    ld [$99EA], a
    inc a
    ld [$99CB], a
    inc a
    ld [$99EB], a

    ld a, [maxscore]
    ld b,a
    and %11110000        ; Aislar el nibble más significativo
    swap a               ; Intercambiar los nibbles
    rla 
    rla 
    add $80              ; Ajustar para que el tile '0' sea el correcto
    ld [$9A88], a        ; Guardar el primer dígito en la posición del tile
    inc a
    ld [$9AA8], a
    inc a
    ld [$9A89], a
    inc a
    ld [$9AA9], a

    ; Extraer la parte menos significativa (unidades)
    ld a, b              ; Cargar el tiempo anterior de nuevo en A
    and %00001111        ; Aislar el nibble menos significativo
    rla 
    rla 
    add $80              ; Ajustar para que el tile '0' sea el correcto
    ld [$9A8A], a        ; Guardar el segundo dígito en la siguiente posición del tile
    inc a
    ld [$9AAA], a
    inc a
    ld [$9A8B], a
    inc a
    ld [$9AAB], a

    ret
renderGameOver_update:
    ret
renderGame_update:
    ld de, renderGame_draw
    call man_entity_for_each
    call renderCRONO
    call renderSCORE
    ret
renderCRONO:
    ld a, [timer]
    ld b, a
    ; Extraer la parte más significativa (decenas)
    and %11110000        ; Aislar el nibble más significativo
    swap a               ; Intercambiar los nibbles
    add $80              ; Ajustar para que el tile '0' sea el correcto
    ld [$9C01], a        ; Guardar el primer dígito en la posición del tile

    ; Extraer la parte menos significativa (unidades)
    ld a, b              ; Cargar el tiempo anterior de nuevo en A
    and %00001111        ; Aislar el nibble menos significativo
    add $80              ; Ajustar para que el tile '0' sea el correcto
    ld [$9C02], a        ; Guardar el segundo dígito en la siguiente posición del tile

    ld a, [tileClock]
    ld [$9C00], a
    ret
renderSCORE:
    ld a, [score]
    ld b, a
    and %11110000        ; Aislar el nibble más significativo
    swap a               ; Intercambiar los nibbles
    add $80              ; Ajustar para que el tile '0' sea el correcto
    ld [$9C05], a        ; Guardar el primer dígito en la posición del tile

    ld a, b              ; Cargar el tiempo anterior de nuevo en A
    and %00001111        ; Aislar el nibble menos significativo
    add $80              ; Ajustar para que el tile '0' sea el correcto
    ld [$9C06], a        ; Guardar el segundo dígito en la siguiente posición del tile
    ret
renderMain_update:
    call renderMain_draw
    call moveMaxscore
    ret
;-------------------------------------------------------------------------------
;---------------------------------RENDER GAME-----------------------------------
; Funcion que dibuja una entidad en la escena del juego en cada frame
; Entradas: HL -> Direccion de memoria de la entidad
; Salidas: Ninguna
; Destruye: 
;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
renderGame_draw:
    call wait_VBLANK
    ;----------------------------------------------------------------------------------------------------------------------------------------
    ;-------------------------------------------- Obtenemos todas las variables de la entidad -----------------------------------------------
    ;----------------------------------------------------------------------------------------------------------------------------------------
    inc hl
    ld a, [hl]      ; Nos movemos hasta el idOAM de la entidad
    ld [posOAM], a  ; Guardamos el ID de la OAM

    inc hl          ; Nos movemos hasta la posicion Y de la entidad
    ld a, [hl]
    ld [posY], a    ; Guardamos la posición Y de la entidad

    inc hl          ; Nos movemos hasta la posicion X de la entidad
    ld a, [hl]
    ld [posX], a    ; Guardamos la posición X de la entidad

    inc hl          ; Nos movemos hasta la posición del tile de la entidad
    inc hl
    inc hl
    ld a, [hl]      
    ld [tile], a    ; Guardamos el tile id 
    
    inc hl          ; Nos movemos hasta el atributo
    ld a, [hl]
    ld [attr], a    ; Guardamos el atributo

    ;----------------------------------------------------------------------------------------------------------------------------------------
    ;---------------------------------------------- Ahora vamos a copiar en la OAM la entidad -----------------------------------------------
    ;----------------------------------------------------------------------------------------------------------------------------------------

    ld de, $FE00    ; A DE le añadimos el indice de la oam que corresponde a la entidad
    ld a, [posOAM]
    ld e, a         

                    ; Siguiente byte en la OAM (Y)
    ld a, [posY]    ; El primer tile tendrá la posicion Y especificada en la Entidad
    ld [de], a      

    inc de          ; Siguiente byte en la OAM (X)
    ld a, [posX]    ; El primer tile tendrá la posicion X especificada en la Entidad
    ld [de], a      

    inc de          ; Siguiente byte en la OAM (Tile Index)   
    ld a,[tile]                 
    ld [de], a      ; Coloca el índice del tile

    inc de          ; Siguiente byte en la OAM (Atributos)
    ld a, [attr]    ; Atributos del sprite (sin flips, prioridad detrás de fondo, paleta 0)
    ld [de], a      ; Coloca los atributos

    ;-----------------------------------------------------------------------------------------
    inc de          ; Siguiente byte en la OAM (Y)
    ld a, [posY]    ; El primer tile tendrá la posicion Y especificada en la Entidad
    ld [de], a      

    inc de          ; Siguiente byte en la OAM (X)
    ld a, [posX]
    add 8           ; El primer tile tendrá la posicion X especificada en la Entidad
    ld [de], a      

    inc de          ; Siguiente byte en la OAM (Tile Index) 
    ld a,[tile]    
    add $01         
    ld [de], a      ; Coloca el índice del tile

    inc de          ; Siguiente byte en la OAM (Atributos)
    ld a, [attr]    ; Atributos del sprite (sin flips, prioridad detrás de fondo, paleta 0)
    ld [de], a      ; Coloca los atributos

    ;-----------------------------------------------------------------------------------------
    inc de          ; Siguiente byte en la OAM (Y)
    ld a, [posY]    ; El primer tile tendrá la posicion Y especificada en la Entidad
    add 8
    ld [de], a      

    inc de          ; Siguiente byte en la OAM (X)
    ld a, [posX]    ; El primer tile tendrá la posicion X especificada en la Entidad
    ld [de], a      

    inc de          ; Siguiente byte en la OAM (Tile Index)   
    ld a,[tile]                 
    add $10
    ld [de], a      ; Coloca el índice del tile

    inc de          ; Siguiente byte en la OAM (Atributos)
    ld a, [attr]    ; Atributos del sprite (sin flips, prioridad detrás de fondo, paleta 0)
    ld [de], a      ; Coloca los atributos
    ;-----------------------------------------------------------------------------------------
    inc de          ; Siguiente byte en la OAM (Y)
    ld a, [posY]   
    add 8           ; El primer tile tendrá la posicion Y especificada en la Entidad
    ld [de], a      

    inc de          ; Siguiente byte en la OAM (X)
    ld a, [posX]    
    add 8           ; El primer tile tendrá la posicion X especificada en la Entidad 
    ld [de], a      

    inc de          ; Siguiente byte en la OAM (Tile Index)   
    ld a,[tile]
    add $11             
    ld [de], a      ; Coloca el índice del tile

    inc de          ; Siguiente byte en la OAM (Atributos)
    ld a, [attr]    ; Atributos del sprite (sin flips, prioridad detrás de fondo, paleta 0)
    ld [de], a      ; Coloca los atributos

    ret

;-------------------------------------------------------------------------------
;---------------------------------RENDER MAIN-----------------------------------
;-------------------------------------------------------------------------------
moveMaxscore:
    

    ret
renderMain_draw:
    call wait_VBLANK
    ld a, [EstadoFlecha]
    cp 0
    jr z, .pinto0

    ld a, $7F
    ld [$9984], a
    ld [$99A4], a

    ld a, $92
    ld [$99C4], a

    ld a, $93
    ld [$99E4], a
    ret

    .pinto0
    ld a, $7F
    ld [$99C4], a
    ld [$99E4], a

    ld a, $92
    ld [$9984], a

    ld a, $93
    ld [$99A4], a
    .salto
    ret

