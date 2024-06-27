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
    fila_salto              resq 1
    columna_salto           resq 1
    coordenada_seleccionada resb 5
    comio_oca?              resq 1

section  .text

jugar_zorro:
    
    mov [direc_tablero],rdi
    mov [direc_caracter_zorro],rsi
    mov [direc_fila_zorro],rdx
    mov [direc_columna_zorro],rcx
    mov byte[comio_oca?],0

inicio:
    mov rdi,0
    sub rsp,8
    call validador_formato
    add rsp,8

    cmp rax,-1
    jle  fin_turno

    mov [fila_destino],rdi
    mov [columna_destino],rsi

validar_colision:
    buscarPosicion fila_destino,columna_destino,LONG_ELEMEN,CANT_COL
    mCMPSB espacio,[direc_tablero],rdx,1
    jne inicio

validar_movimiento:
    mov r10,[direc_fila_zorro]
    mov r12,[fila_destino]
    sub r12,[r10]
    imul r12,r12

    mov r10,[direc_columna_zorro]
    mov r13,[columna_destino]
    sub r13,[r10]
    imul r13,r13

    add r12,r13

    cmp r12, 1
    je  mover_zorro
    cmp r12, 2
    je  mover_zorro
    cmp r12, 4
    je  validar_salto
    cmp r12, 8
    je  validar_salto

    jmp inicio

validar_salto:
    mov r8,2
    mov r10,[direc_fila_zorro]
    mov r12,[fila_destino]
    add r12,[r10]
    
    mov r10,[direc_columna_zorro]
    mov r13,[columna_destino]
    add r13,[r10]

    xor rax,rax
    xor rdx,rdx

    mov rax,r12
    idiv r8
    mov [fila_salto],rax

    mov rax,r13
    idiv r8
    mov [columna_salto],rax

    buscarPosicion fila_salto,columna_salto,LONG_ELEMEN,CANT_COL
    mCMPSB espacio,[direc_tablero],rdx,1
    je inicio
    
comer_oca:
    _movsb espacio,[direc_tablero],rdx,1
    inc qword[comio_oca?]
    
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

fin_turno:
    mov rbx,[comio_oca?]
    ret