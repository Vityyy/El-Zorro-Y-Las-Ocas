%include "macros.asm"
global jugar_zorro
extern validador_formato

section  .data
    CANT_COL              dq      7
    LONG_ELEMEN           dq      1
    espacio               db  " ",0                 
    salir_programa        db "-1",0

section  .bss
    direc_caracter_zorro    resq 1
    direc_fila_zorro        resq 1                 ; Fila actual
    direc_columna_zorro     resq 1                 ; Columna actual
    direc_tablero           resq 1
    fila_destino            resq 1                 ; Fila destino
    columna_destino         resq 1                 ; Columna destino
    coordenada_seleccionada resb 5

section  .text

jugar_zorro:
    
    mov [direc_tablero],rdi
    mov [direc_caracter_zorro],rsi
    mov [direc_fila_zorro],rdx
    mov [direc_columna_zorro],rcx

inicio:
    mov rdi,0
    sub rsp,8
    call validador_formato
    add rsp,8

    cmp rax,-1
    je  fin_turno

    mov [fila_destino],rdi
    mov [columna_destino],rsi

validar_colision:
    buscarPosicion fila_destino,columna_destino,LONG_ELEMEN,CANT_COL
    mov r10,[direc_tablero]
    add r10,rdx
    mCMPSB r10,espacio,1
    jne inicio

validar_movimiento:
    mov r10,[direc_fila_zorro]
    mov r12,[r10]
    sub r12,[fila_destino]
    cmp r12,1
    jg inicio
    cmp r12,-1
    jl inicio

    mov r10,[direc_columna_zorro]
    mov r13,[r10]
    sub r13,[columna_destino]
    cmp r13,1
    jg inicio
    cmp r13,-1
    jl inicio

    or r12,r13
    jz inicio

mover_zorro:
    buscarPosicion fila_destino,columna_destino,LONG_ELEMEN,CANT_COL
    _movsb [direc_caracter_zorro], [direc_tablero], rdx, 1

borrar_posicion_anterior:
    mov r10,[direc_fila_zorro]
    mov r11,[direc_columna_zorro]
    buscarPosicion r10,r11,LONG_ELEMEN,CANT_COL
    _movsb espacio,[direc_tablero],rdx,1

actualizar_posicion_zorro:
    mov rdi,[fila_destino]
    mov rsi,[direc_fila_zorro]
    mov [rsi],rdi
    mov rdi,[columna_destino]
    mov rsi,[direc_columna_zorro]
    mov [rsi],rdi
    jmp fin_turno

fin_turno:
    ret