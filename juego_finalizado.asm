%include "macros.asm"

global condicion_de_fin
extern validador_rango
section .data
    CANT_COL              dq      7
    LONG_ELEMEN           dq      1
    espacio               db  " ",0

section .bss
    direc_tablero         resq 1
    fila_zorro            resq 1
    columna_zorro         resq 1
    fila_actual           resq 1
    columna_actual        resq 1
    fila_aux              resq 1
    columna_aux           resq 1

section .text
condicion_de_fin:
    sub rsp,8
    mov [direc_tablero],rdi
    mov [fila_zorro],rsi
    mov [columna_zorro],rdx

inicializacion:
    mov rax,[fila_zorro]
    dec rax
    mov [fila_actual],rax

    mov rax,[columna_zorro]
    dec rax
    mov [columna_actual],rax

    mov rbx, 3

esta_dentro_de_tablero?:
    mov rdi,[fila_actual]
    mov rsi,[columna_actual]
    call validador_rango

    cmp rax,1
    jl  mover_columna
    
hay_movimiento_valido?:    
    buscarPosicion fila_actual,columna_actual,LONG_ELEMEN,CANT_COL
    mCMPSB espacio,[direc_tablero],rdx,1
    je continua_juego

hay_salto_valido?:
    mov r12,[fila_actual]
    mov [fila_aux],r12
    sub r12,[fila_zorro]
    add [fila_actual],r12

    mov r13,[columna_actual]
    mov [columna_aux],r13
    sub r13,[columna_zorro]
    add [columna_actual],r13

    mov rdi,[fila_actual]
    mov rsi,[columna_actual]
    
    call validador_rango

    cmp rax,1
    jl  devolver_valores

    buscarPosicion fila_actual,columna_actual,LONG_ELEMEN,CANT_COL
    mCMPSB espacio,[direc_tablero],rdx,1
    je continua_juego

devolver_valores:
    mov r12,[fila_aux]
    mov [fila_actual],r12
    mov r13,[columna_aux]
    mov [columna_actual],r13

mover_columna:
    dec rbx
    inc qword[columna_actual]
    cmp rbx,0
    jne esta_dentro_de_tablero?

mover_fila:
    mov rbx, 3
    
    inc qword[fila_actual]

    mov rax,[columna_zorro]
    dec rax
    mov [columna_actual],rax

    mov rax,[fila_actual]
    sub rax,[fila_zorro]
    cmp rax,1
    jg  termina_juego 

    jmp esta_dentro_de_tablero?
    
continua_juego:
    mov rax,1
    jmp fin

termina_juego:
    mov rax,0

fin:
    add rsp,8
    ret