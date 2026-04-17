include "include/hardware.inc"
;;; INDICE DE ENTIDADES; AQUI SE DEFINE QUE POSICIÒN DE LA MEMORIA CORRESPONDE A CADA ENTIDAD
;;; CADA ENTIDAD TIENE 10 BYTES DE INFORMACION
;;; 0 -> ROBERT
;;; 1 -> LOLA
;;; 2 -> OVNI 1
;;; 3 -> OVNI 2
;;; 4 -> OVNI 3
;;; 5 -> OVNI 4
;;; SIEMPRE HABRÁ QUE PASAR POR PARAMETRO ESOS ÍNDICES, EL ENTITY MANAGER SE DEBE ENCARGAR DE AJUSTAR LA POSICIÓN DEL ARRAY
;;; CONSTANTS

    DEF SIZEOF_E = 9
    DEF DEFAULT_CMP = $01
    DEF MAX_ENTITIES = 5
    DEF ENTITY_ARRAY_SIZE = MAX_ENTITIES * SIZEOF_E

    ;;States of entities

    DEF e_type_invalid =    %00000000
    DEF e_type_default =    %00000001
    DEF e_type_dead    =    %00000010

    ;;Types of entities

    DEF e_type_player  =    %00000001
    DEF e_type_enemy   =    %00000010
    DEF e_type_cow     =    %00000100

;---------------------------------------------------------
;---------------------------------------------------------
SECTION "Entity Array", WRAM0[$c000]
;; DATA
    DEF E_comp  = 0
    DEF E_OAMID = 1
    DEF E_PosY  = 2
    DEF E_PosX  = 3
    DEF E_VY    = 4
    DEF E_VX    = 5
    DEF E_Tile  = 6
    DEF E_Attr  = 7
    DEF E_anim  = 8
;; Space for the entities
    entity_array: DS ENTITY_ARRAY_SIZE

;---------------------------------------------------------
;---------------------------------------------------------
SECTION "Entity Manager Section", ROM0
;;--------------------------------------------------------
;; Inicializa el array de entidades.
;; Limpia el array de entidades (pone todos a 0’s)
;---------------------------------------------------------
;; ADVERTENCIA: Solo funciona para arrays menores a 256 bytes
;; DESTROYS: AF, B, HL
man_entity_init:
    ld a, 0
    ld b, ENTITY_ARRAY_SIZE
    ld hl, entity_array
    .loop
        ld [hl+], a
        dec b
        jr nz, .loop

    call man_entity_alloc

    inc hl
    ld [hl], $00
    inc hl
    ld [hl], $48
    inc hl
    ld [hl], $50
    inc hl
    inc hl
    inc hl
    ld [hl], $00
    inc hl
    inc hl
    ld [hl], $06

    ; call man_entity_alloc

    ; inc hl
    ; ld [hl], $10
    ; inc hl
    ; ld [hl], 16
    ; inc hl
    ; ld [hl], 8
    ; inc hl
    ; inc hl
    ; inc hl
    ; ld [hl], $00

    ret
    
;;--------------------------------------------------------
;; Encuentra el primer slot libre en el array de entidades
;;--------------------------------------------------------
;; WARNING: Goes beyond entity array if full.
;; DESTROYS: AF, HL, DE
;; OUTPUT:
;; - HL -> First free slot
;; - DE = SIZEOF_E
;;
man_entity_find_first_free_slot:
    ld de, SIZEOF_E
    ld hl, entity_array
    .loop
        ld a, [hl]
        cp 0
        jp z, .end
        add hl, de
        jp .loop
    .end
    ret

;;-------------------------------------------------------
;; Allocates space in the entity vector for a new entity
;; - Reserves a free entity slot for a new entity
;; - Marcs it with default components to make it reserved
;; WARNING: Goes beyond entity array if full.
;; DESTROYS: AF, HL, DE
;; OUTPUT:
;; - HL -> Reserved slot for the new entity
;; - DE = SIZEOF_E
;;
man_entity_alloc:
    call man_entity_find_first_free_slot
    ld [hl], DEFAULT_CMP
    ret

;;-------------------------------------------------------
;; Frees an entity in the entity array, leaving it
;; available for later use for new entities
;; - Marcs the entity as free
;; WARNING: Assumes HL points to a valid entity
;; INPUT:
;; -A -> ÍNDICE DE LA ENTIDAD
;;
; man_entity_free:
;     ld [hl], $00
;     ret

;;------------------------------------------------------- ESTO HAY QUE REVISARLO, AHORA MISMO SIEMPRE BUSCA LOS VIVOS
;;INPUT: B -> Entity Component
;;INPUT: DE -> Function to call
man_entity_foreach_component:
    ld hl, entity_array
    ld a, 0
    .loop
        push af

        ld a, [hl]
        cp 0
        jp z, .next        

        ld bc, .next
        push bc
        push de
        ret

        .next
            pop af
            add SIZEOF_E
            ld bc, SIZEOF_E
            add hl, bc
            cp ENTITY_ARRAY_SIZE
            jp nz, .loop
    ret


;;-------------------------------------------------------
;; Performs an operation on all the valid (reserved)
;; entities in the array:
;; - Iterates through all the entities
;; - For each valid entity, it calls the function
;;   given as argument (the operation).
;; - When calling the function (operation), HL
;;   must be the address of the valid entity being
;;   iterated.
;; DESTROYS: AF, BC, DE, HL
;; INPUT:
;; - DE -> Pointer to a function (operation) to be
;;   performed on all valid entities one by one.
;;   This function expects HL to have the address
;;   of the entity.
;;

man_entity_for_each:
    ld hl, entity_array
    ld a, 0
    .loop
        push af
        push de
        push hl
        ld a, [hl]
        cp 0
        jr z, .next

        ld bc, .next
        push bc
        push de
        ret

        .next
        pop hl
        pop de
        pop af
        add SIZEOF_E
        ld bc, SIZEOF_E
        add hl, bc
        cp ENTITY_ARRAY_SIZE
        jp nz, .loop
    ret

;;-----------------------------------------------------------------------------------------------------------
;;-----------------------------------------------------------------------------------------------------------
;; Marcamos para morir una entidad en especifico del array. 
;; Deberemos de pasarle por parametro el indice de la entidad
;;
;; Entrada: A -> Índice de la entidad
;; Salida: Ninguna
;; Destruye: AF, HL, DE
;;-----------------------------------------------------------------------------------------------------------
;;-----------------------------------------------------------------------------------------------------------
man_entity_4_destroy:
    ld hl, entity_array
    ld de, SIZEOF_E
    .loop  
        cp 0
        jp z, .next
        add hl, de
        dec a
        jp nz, .loop
    .next
    ld [hl], e_type_dead
    ret

;;-----------------------------------------------------------------------------------------------------------
;;-----------------------------------------------------------------------------------------------------------
;; Recorremos todo el array y se destruyen las que estén marcadas como muertas
;;
;; Entrada: Ninguna
;; Salida: Ninguna
;; Destruye: AF, BC, HL
;;-----------------------------------------------------------------------------------------------------------
;;-----------------------------------------------------------------------------------------------------------
man_entity_2_destroy:
    ld hl, entity_array
    ld b, 0
    .loop
        ld a, b
        cp MAX_ENTITIES
        jp z, .end
        ld a, [hl]
        cp e_type_dead
        ld [hl], e_type_invalid
        inc b
        jp .loop
    .end
    ret

man_respawn_ovni:
    ld hl, entity_array + 7
    ld bc, SIZEOF_E
    .loop
        ld a, [hl]
        cp e_type_enemy
        jp nz, .next
        ld [hl], e_type_default
        ret
        .next
            add SIZEOF_E
            add hl, bc
            cp ENTITY_ARRAY_SIZE
            jp nz, .loop

;;-----------------------------------------------------------------------------------------------------------
;;-----------------------------------------------------------------------------------------------------------
;; Actualiza la velocidad de la entidad pasada por parámetro
;;
;; Entrada: A -> Indice de la entidad
;; Entrada: DE -> Nuevas velocidades  (VX, VY) XXXX | YYYY
;; Salida: Ninguna
;; Destruye: AF, BC, HL
;;
;; Inicialmente para velocidad nula será un 0, para velocidad positiva será un 1 y para velocidad negativa será un 2
;;-----------------------------------------------------------------------------------------------------------
;;-----------------------------------------------------------------------------------------------------------
man_actualize_VX_VY:
    ld hl, entity_array
    ld bc, SIZEOF_E
    .loop                   ;; Recorremos el array de entidades hasta encontrar la entidad que queremos
        cp 0
        jp z, .next
        add hl, bc
        dec a
        jp nz, .loop
    .next

    inc hl       ;; Nos movemos a la posición de la velocidad en Y
    inc hl
    inc hl
    inc hl

    ld [hl], d       ;; Actualizamos la velocidad en Y
    inc hl
    ld [hl], e       ;; Actualizamos la velocidad en X
    ret

;;-----------------------------------------------------------------------------------------------------------
;;-----------------------------------------------------------------------------------------------------------
;; Actualiza la posición de la entidad pasada por parámetro
;;
;; Entrada: A -> Indice de la entidad
;; Entrada: DE -> Nuevas posiciones  (PY, PX) YYYYY | XXXXX
;; Salida: Ninguna
;; Destruye: AF, BC, HL
;;
;; Inicialmente para velocidad nula será un 0, para velocidad positiva será un 1 y para velocidad negativa será un 2
;;-----------------------------------------------------------------------------------------------------------
;;-----------------------------------------------------------------------------------------------------------
man_actualize_PX_PY:
    ld hl, entity_array
    ld bc, SIZEOF_E
    .loop                   ;; Recorremos el array de entidades hasta encontrar la entidad que queremos
        cp 0
        jp z, .next
        add hl, bc
        dec a
        jp nz, .loop
    .next

    inc hl                  ;; Nos movemos a la posición de la velocidad en Y
    inc hl

    ld [hl], d       ;; Actualizamos la velocidad en Y
    inc hl
    ld [hl], e       ;; Actualizamos la velocidad en X
    ret


;;-----------------------------------------------------------------------------------------------------------
;;-----------------------------------------------------------------------------------------------------------
;; Actualiza la velocidad de la entidad pasada por parámetro
;;
;; Entrada: A -> Indice de la entidad
;; Entrada: DE -> Nuevos tiles y atributos  
;; Salida: Ninguna
;; Destruye: AF, BC, HL
;;
;; Inicialmente para velocidad nula será un 0, para velocidad positiva será un 1 y para velocidad negativa será un 2
;;-----------------------------------------------------------------------------------------------------------
;;-----------------------------------------------------------------------------------------------------------
man_actualize_TILE_ATTR:
    ld hl, entity_array
    ld bc, SIZEOF_E
    .loop                   ;; Recorremos el array de entidades hasta encontrar la entidad que queremos
        cp 0
        jp z, .next
        add hl, bc
        dec a
        jp nz, .loop
    .next

    ld bc, 6
    add hl, bc

    ld [hl], d       ;; Actualizamos el tile
    ; inc hl
    ; ld [hl], e       ;; Actualizamos el atributo
    ret