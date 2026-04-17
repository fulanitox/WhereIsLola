SECTION "TILES DE LA COLISION", WRAM0
    TILE_HL1: DS 1
    TILE_HL2: DS 1
    TILE_DE1: DS 1
    TILE_DE2: DS 1
    triple: DS 1
    contVacas: DS 1
    contMovimiento: DS 1
SECTION "Collisions", ROM0

sys_collision_update_one_entity:
    ;; Tx x/4
    ;; Ty y/8
    ;; tw ancho del tilemap = 32
    ;; p = tilemap + ty * tw + tx

    ;--------------------------------------------------------------------
    ;--------------------------------------------------------------------
    ;--------------------------------------------------------------------
    ;--------------------- Solo scroll ----------------------------------
    ;--------------------------------------------------------------------
    ;--------------------------------------------------------------------
    ;--------------------------------------------------------------------
    ;--------------------------------------------------------------------
    ld a, [entity_array + 5]
    cp 2
    jr z, .comprobarIzquierda

    cp 1
    jp z, .comprobarDerecha

    ld a, [entity_array + 4]
    cp 1
    jp z, .comprobarAbajo

    cp 2
    jp z, .comprobarArriba

    ret

    .comprobarIzquierda
    ld a, [$FF43] ;pos SCROLL X
    ld b,a
    ld a, [entity_array + 3]
    add a , b
    sub 8

    srl a
    srl a ;tx = posx/4
    srl a ; posX/8

    ld c,a 
    ld b, 0
    ld a, [$FF42] ;pos SCROLL Y
    ld b,a
    ld a, [entity_array + 2]
    add a, b
    sub 16
    
    and %00000111
    jr nz, .tripleIzq

    ld hl, triple
    ld a, 0
    ld [hl], a

    ld a, [$FF42] ;pos SCROLL Y
    ld b,a
    ld a, [entity_array + 2]
    add a, b
    sub 16

    ; sra a
    ; srl a
    ; srl a
    and %11111000
    ld b,0
    ld l, a
    ld h, b


    add hl, hl
    add hl, hl ; posY /8 * 32

    add hl, bc
    
    ld de, $9800

    add hl, de

    ld d, h
    ld e, l ; de = hl = primera posicion

    ld c, 32
    ld b, 0
    add hl, bc ; hl = siguiente cuadrado

    ld a, [de]
    call comprobarloladoble
    ret
    
    ;--------------------------------------------------------------------
    ;--------------------------------------------------------------------
    ;----------------------Triple IZQUIERDA------------------------------
    ;--------------------------------------------------------------------
    ;--------------------------------------------------------------------
    
    .tripleIzq
    ld a, [$FF43] ;pos SCROLL X
    ld b,a
    ld a, [entity_array + 3]
    add a , b
    sub 8

    

    srl a
    srl a ;tx = posx/4
    srl a ; posX/8

    ld c,a 
    ld b, 0
    ld a, [$FF42] ;pos SCROLL Y
    ld b,a
    ld a, [entity_array + 2]
    add a, b
    sub 16

    ; sra a
    ; srl a
    ; srl a
    and %11111000
    ld b,0
    ld l, a
    ld h, b


    add hl, hl
    add hl, hl ; posY /8 * 32

    add hl, bc
    
    ld de, $9800

    add hl, de

    ld d, h
    ld e, l ; de = hl = primera posicion

    ld c, 32
    ld b, 0
    add hl, bc ; hl = siguiente cuadrado

    push hl

    add hl, bc ; hl = siguiente cuadrado
    ld b, h
    ld c, l
    ld hl, triple
    ld a, 1
    ld [hl], a
    pop hl

    ld a, [bc]
    ret























    .comprobarDerecha
    ld a, [$FF43] ;pos SCROLL X
    ld b,a
    ld a, [entity_array + 3]
    add a , b
    add 7

    srl a
    srl a ;tx = posx/4
    srl a ; posX/8

    ld c,a 
    ld b, 0
    ld a, [$FF42] ;pos SCROLL Y
    ld b,a
    ld a, [entity_array + 2]
    add a, b
    sub 16
    
    and %00000111
    jr nz, .tripleDer

    ld hl, triple
    ld a, 0
    ld [hl], a

    ld a, [$FF42] ;pos SCROLL Y
    ld b,a
    ld a, [entity_array + 2]
    add a, b
    sub 16

    ; sra a
    ; srl a
    ; srl a
    and %11111000
    ld b,0
    ld l, a
    ld h, b


    add hl, hl
    add hl, hl ; posY /8 * 32

    add hl, bc
    
    ld de, $9800

    add hl, de

    ld d, h
    ld e, l ; de = hl = primera posicion

    ld c, 32
    ld b, 0
    add hl, bc ; hl = siguiente cuadrado

    ld a, [de]
    call comprobarloladoble

    ret
    
    ;--------------------------------------------------------------------
    ;--------------------------------------------------------------------
    ;----------------------Triple Derecha--------------------------------
    ;--------------------------------------------------------------------
    ;--------------------------------------------------------------------
    
    .tripleDer
    ld a, [$FF43] ;pos SCROLL X
    ld b,a
    ld a, [entity_array + 3]
    add a , b
    add 7

    

    srl a
    srl a ;tx = posx/4
    srl a ; posX/8

    ld c,a 
    ld b, 0
    ld a, [$FF42] ;pos SCROLL Y
    ld b,a
    ld a, [entity_array + 2]
    add a, b
    sub 16

    ; sra a
    ; srl a
    ; srl a
    and %11111000
    ld b,0
    ld l, a
    ld h, b


    add hl, hl
    add hl, hl ; posY /8 * 32

    add hl, bc
    
    ld de, $9800

    add hl, de

    ld d, h
    ld e, l ; de = hl = primera posicion

    ld c, 32
    ld b, 0
    add hl, bc ; hl = siguiente cuadrado

    push hl

    add hl, bc ; hl = siguiente cuadrado
    ld b, h
    ld c, l
    ld hl, triple
    ld a, 1
    ld [hl], a
    pop hl

    ld a, [bc]
    ret

















    .comprobarAbajo
    ld a, [$FF43] ;pos SCROLL X
    ld b,a
    ld a, [entity_array + 3]
    add a , b
    sub 8
    and %00000111
    jr nz, .tripleAbj
    ld hl, triple
    ld a, 0
    ld [hl], a

    ld a, [$FF43] ;pos SCROLL X
    ld b,a
    ld a, [entity_array + 3]
    add a , b
    sub 8

    srl a
    srl a ;tx = posx/4
    srl a ; posX/8

    ld c,a 
    ld b, 0
    
    
    
    ld a, [$FF42] ;pos SCROLL Y
    ld b,a
    ld a, [entity_array + 2]
    add a, b
    sub 17

    ; sra a
    ; srl a
    ; srl a
    and %11111000
    ld b,0
    ld l, a
    ld h, b


    add hl, hl
    add hl, hl ; posY /8 * 32

    add hl, bc
    
    ld de, $9800

    add hl, de

    ld c, 64
    ld b, 0
    add hl, bc ; hl = siguiente cuadrado

    ld d, h
    ld e, l ; de = hl = primera posicion

    inc hl

    ld a, [de]
    call comprobarloladoble

    ret
    
    ;--------------------------------------------------------------------
    ;--------------------------------------------------------------------
    ;----------------------Triple Abajo------------------------------
    ;--------------------------------------------------------------------
    ;--------------------------------------------------------------------
    
    .tripleAbj
    ld a, [$FF43] ;pos SCROLL X
    ld b,a
    ld a, [entity_array + 3]
    add a , b
    sub 9

    

    srl a
    srl a ;tx = posx/4
    srl a ; posX/8

    ld c,a 
    ld b, 0
    ld a, [$FF42] ;pos SCROLL Y
    ld b,a
    ld a, [entity_array + 2]
    add a, b
    sub 17

    ; sra a
    ; srl a
    ; srl a
    and %11111000
    ld b,0
    ld l, a
    ld h, b


    add hl, hl
    add hl, hl ; posY /8 * 32

    add hl, bc
    
    ld de, $9800

    add hl, de

    ld c, 64
    ld b, 0
    add hl, bc 

    ld d, h
    ld e, l ; de = hl = primera posicion

    inc hl; hl = siguiente cuadrado
    ld b, h
    ld c, l

    push hl

    inc hl; hl = siguiente cuadrado
    ld b, h
    ld c, l
    ld hl, triple
    ld a, 1
    ld [hl], a
    pop hl

    ld a, [bc]
    ret























    .comprobarArriba
    ld a, [$FF43] ;pos SCROLL X
    ld b,a
    ld a, [entity_array + 3]
    add a , b
    sub 8
    and %00000111
    jr nz, .tripleArr
    ld hl, triple
    ld a, 0
    ld [hl], a

    ld a, [$FF43] ;pos SCROLL X
    ld b,a
    ld a, [entity_array + 3]
    add a , b
    sub 8

    srl a
    srl a ;tx = posx/4
    srl a ; posX/8

    ld c,a 
    ld b, 0
    
    
    
    ld a, [$FF42] ;pos SCROLL Y
    ld b,a
    ld a, [entity_array + 2]
    add a, b
    sub 16

    ; sra a
    ; srl a
    ; srl a
    and %11111000
    ld b,0
    ld l, a
    ld h, b


    add hl, hl
    add hl, hl ; posY /8 * 32

    add hl, bc
    
    ld de, $9800

    add hl, de

    ld d, h
    ld e, l ; de = hl = primera posicion

    inc hl ;hl = siguiente cuadrado

    ld a, [de]
    call comprobarloladoble

    ret
    
    ;--------------------------------------------------------------------
    ;--------------------------------------------------------------------
    ;----------------------Triple IZQUIERDA------------------------------
    ;--------------------------------------------------------------------
    ;--------------------------------------------------------------------
    
    .tripleArr
    ld a, [$FF43] ;pos SCROLL X
    ld b,a
    ld a, [entity_array + 3]
    add a , b
    sub 8

    

    srl a
    srl a ;tx = posx/4
    srl a ; posX/8

    ld c,a 
    ld b, 0
    ld a, [$FF42] ;pos SCROLL Y
    ld b,a
    ld a, [entity_array + 2]
    add a, b
    sub 16

    ; sra a
    ; srl a
    ; srl a
    and %11111000
    ld b,0
    ld l, a
    ld h, b


    add hl, hl
    add hl, hl ; posY /8 * 32

    add hl, bc
    
    ld de, $9800

    add hl, de
    

    ld d, h
    ld e, l ; de = hl = primera posicion

    inc hl ; siguiente cuadrado

    push hl

    inc hl ; hl = siguiente cuadrado
    ld b, h
    ld c, l
    ld hl, triple
    ld a, 1
    ld [hl], a
    pop hl

    ld a, [bc]
    ret




sys_collision_update:
    call sys_collision_update_one_entity_DESEADA
    ld a, [contMovimiento]
    cp 1
    ret z

    call sys_collision_update_one_entity
    
    cp $5F
    jr z, .segundaComp 

    push hl
    call undo_movement 
    pop hl

    ret

    .segundaComp
    ld a, [hl]
    cp $5F
    jr z, .terceraComp
    call undo_movement 
    ret

    .terceraComp
    ld bc, triple
    ld a, [bc]
    cp 1
    ret nz
    ld a, [de]
    cp $5F
    ret z
    call undo_movement
    

ret


comprobarloladoble:
    cp $28
    call z, get_Lola
    cp $29
    call z, get_Lola
    cp $38
    call z, get_Lola
    cp $39
    call z, get_Lola
ret

comprobarlolatriple:

ret











sys_collision_update_one_entity_DESEADA:
    ;; Tx x/4
    ;; Ty y/8
    ;; tw ancho del tilemap = 32
    ;; p = tilemap + ty * tw + tx
    ld a, 0
    ld [contMovimiento], a

    ;--------------------------------------------------------------------
    ;--------------------------------------------------------------------
    ;--------------------------------------------------------------------
    ;--------------------- Solo scroll ----------------------------------
    ;--------------------------------------------------------------------
    ;--------------------------------------------------------------------
    ;--------------------------------------------------------------------
    ;--------------------------------------------------------------------
    ld a, [velXdes]
    cp 2
    jr z, .comprobarIzquierda

    cp 1
    jp z, .comprobarDerecha

    ld a, [velYdes]
    cp 1
    jp z, .comprobarAbajo

    cp 2
    jp z, .comprobarArriba

    ret

    .comprobarIzquierda
    ld a, [$FF43] ;pos SCROLL X
    ld b,a
    ld a, [entity_array + 3]
    add a , b
    sub 8

    srl a
    srl a ;tx = posx/4
    srl a ; posX/8

    ld c,a 
    ld b, 0
    ld a, [$FF42] ;pos SCROLL Y
    ld b,a
    ld a, [entity_array + 2]
    add a, b
    sub 16
    
    and %00000111
    jr nz, .tripleIzq

    ld hl, triple
    ld a, 0
    ld [hl], a

    ld a, [$FF42] ;pos SCROLL Y
    ld b,a
    ld a, [entity_array + 2]
    add a, b
    sub 16

    ; sra a
    ; srl a
    ; srl a
    and %11111000
    ld b,0
    ld l, a
    ld h, b


    add hl, hl
    add hl, hl ; posY /8 * 32

    add hl, bc
    
    ld de, $9800

    add hl, de

    ld d, h
    ld e, l ; de = hl = primera posicion

    ld c, 32
    ld b, 0
    add hl, bc ; hl = siguiente cuadrado

    ld a, [de]
    call comprobarloladobleDeseada
    ret
    
    ;--------------------------------------------------------------------
    ;--------------------------------------------------------------------
    ;----------------------Triple IZQUIERDA------------------------------
    ;--------------------------------------------------------------------
    ;--------------------------------------------------------------------
    
    .tripleIzq
    ld a, 0
    ld [contMovimiento], a
    ret

    .comprobarDerecha
    ld a, [$FF43] ;pos SCROLL X
    ld b,a
    ld a, [entity_array + 3]
    add a , b
    add 7

    srl a
    srl a ;tx = posx/4
    srl a ; posX/8

    ld c,a 
    ld b, 0
    ld a, [$FF42] ;pos SCROLL Y
    ld b,a
    ld a, [entity_array + 2]
    add a, b
    sub 16
    
    and %00000111
    jr nz, .tripleDer

    ld hl, triple
    ld a, 0
    ld [hl], a

    ld a, [$FF42] ;pos SCROLL Y
    ld b,a
    ld a, [entity_array + 2]
    add a, b
    sub 16

    ; sra a
    ; srl a
    ; srl a
    and %11111000
    ld b,0
    ld l, a
    ld h, b


    add hl, hl
    add hl, hl ; posY /8 * 32

    add hl, bc
    
    ld de, $9800

    add hl, de

    ld d, h
    ld e, l ; de = hl = primera posicion

    ld c, 32
    ld b, 0
    add hl, bc ; hl = siguiente cuadrado

    ld a, [de]
    call comprobarloladobleDeseada

    ret
    
    ;--------------------------------------------------------------------
    ;--------------------------------------------------------------------
    ;----------------------Triple Derecha--------------------------------
    ;--------------------------------------------------------------------
    ;--------------------------------------------------------------------
    
    .tripleDer
    ld a, 0
    ld [contMovimiento], a
    ret


    .comprobarAbajo
    ld a, [$FF43] ;pos SCROLL X
    ld b,a
    ld a, [entity_array + 3]
    add a , b
    sub 8
    and %00000111
    jr nz, .tripleAbj
    ld hl, triple
    ld a, 0
    ld [hl], a

    ld a, [$FF43] ;pos SCROLL X
    ld b,a
    ld a, [entity_array + 3]
    add a , b
    sub 8

    srl a
    srl a ;tx = posx/4
    srl a ; posX/8

    ld c,a 
    ld b, 0
    
    
    
    ld a, [$FF42] ;pos SCROLL Y
    ld b,a
    ld a, [entity_array + 2]
    add a, b
    sub 17

    ; sra a
    ; srl a
    ; srl a
    and %11111000
    ld b,0
    ld l, a
    ld h, b


    add hl, hl
    add hl, hl ; posY /8 * 32

    add hl, bc
    
    ld de, $9800

    add hl, de

    ld c, 64
    ld b, 0
    add hl, bc ; hl = siguiente cuadrado

    ld d, h
    ld e, l ; de = hl = primera posicion

    inc hl

    ld a, [de]
    call comprobarloladobleDeseada

    ret
    
    ;--------------------------------------------------------------------
    ;--------------------------------------------------------------------
    ;----------------------Triple Abajo------------------------------
    ;--------------------------------------------------------------------
    ;--------------------------------------------------------------------
    
    .tripleAbj
    ld a, 0
    ld [contMovimiento], a
    ret

    .comprobarArriba
    ld a, [$FF43] ;pos SCROLL X
    ld b,a
    ld a, [entity_array + 3]
    add a , b
    sub 8
    and %00000111
    jr nz, .tripleArr
    ld hl, triple
    ld a, 0
    ld [hl], a

    ld a, [$FF43] ;pos SCROLL X
    ld b,a
    ld a, [entity_array + 3]
    add a , b
    sub 8

    srl a
    srl a ;tx = posx/4
    srl a ; posX/8

    ld c,a 
    ld b, 0
    
    
    
    ld a, [$FF42] ;pos SCROLL Y
    ld b,a
    ld a, [entity_array + 2]
    add a, b
    sub 16

    ; sra a
    ; srl a
    ; srl a
    and %11111000
    ld b,0
    ld l, a
    ld h, b


    add hl, hl
    add hl, hl ; posY /8 * 32

    add hl, bc
    
    ld de, $9800

    add hl, de

    ld d, h
    ld e, l ; de = hl = primera posicion

    inc hl ;hl = siguiente cuadrado

    ld a, [de]
    call comprobarloladobleDeseada

    ret
    
    ;--------------------------------------------------------------------
    ;--------------------------------------------------------------------
    ;----------------------Triple IZQUIERDA------------------------------
    ;--------------------------------------------------------------------
    ;--------------------------------------------------------------------
    
    .tripleArr
    ld a, 0
    ld [contMovimiento], a
    ret


comprobarloladobleDeseada:
    cp $28
    call z, get_Lola
    cp $29
    call z, get_Lola
    cp $38
    call z, get_Lola
    cp $2A
    call z, get_Lola
    cp $2C
    call z, get_Lola
    cp $39
    call z, get_Lola

    ld a, [de]
    cp $5f
    jr nz, .final

    ld a, [hl]
    cp $28
    call z, get_Lola
    cp $2A
    call z, get_Lola
    cp $2C
    call z, get_Lola
    cp $29
    call z, get_Lola
    cp $38
    call z, get_Lola
    cp $39
    call z, get_Lola
    cp $5F
    jr nz, .final


    ld a, [velXdes]
    ld [entity_array + 5], a

    ld a, [velYdes]
    ld [entity_array + 4], a

    ld a, 1
    ld [contMovimiento], a
    jp .salir

    .final
    call undo_movement_deseado
    .salir
ret