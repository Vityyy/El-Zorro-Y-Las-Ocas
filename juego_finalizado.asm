%include "macros.asm"

global condicion_de_fin

section .data
    CANT_COL              dq      7
    LONG_ELEMEN           dq      1
    espacio               db  " ",0

section .bss
    direc_tablero         resq 1
    fila_zorro            resq 1
    columna_zorro         resq 1
    
    step                  resq 1
    fila_actual           resq 1
    columna_actual        resq 1

section .text
condicion_de_fin:
    mov [direc_tablero],rdi
    mov [fila_zorro],rsi
    mov [columna_zorro],rdx
    mov [step],rcx

inicializacion:
    mov rax,[fila_zorro]
    sub rax,[step]
    mov [fila_actual],rax

    mov rax,[columna_zorro]
    sub rax,[step]
    mov [columna_actual],rax

    mov rbx, 3

esta_dentro_de_tablero?:
    jmp validar_rango
    
hay_movimiento_valido?:    
    buscarPosicion fila_actual,columna_actual,LONG_ELEMEN,CANT_COL
    mov r10,[direc_tablero]
    add r10,rdx
    mCMPSB r10,espacio,1
    je continua_juego
    
mover_columna:
    dec rbx
    mov rax,[step]
    add [columna_actual],rax
    cmp rbx,0
    jne esta_dentro_de_tablero?

mover_fila:
    mov rbx, 3
    
    mov rax,[step]
    add [fila_actual],rax

    mov rax,[columna_zorro]
    sub rax,[step]
    mov [columna_actual],rax

    mov rax,[fila_actual]
    sub rax,[fila_zorro]
    cmp rax,[step]
    jg  termina_juego 

    jmp esta_dentro_de_tablero?
    
continua_juego:
    mov rax,1
    jmp fin

termina_juego:
    mov rax,0
    jmp fin

validar_rango:
    cmp     qword[fila_actual], 7
    jg      mover_columna

    cmp     qword[columna_actual], 7
    jg      mover_columna

    cmp     qword[columna_actual], 3
    jl      filaCortada

    cmp     qword[columna_actual], 5
    jg      filaCortada

    jmp     hay_movimiento_valido?

filaCortada:
    cmp     qword[fila_actual], 3
    jl      mover_columna

    cmp     qword[fila_actual], 5
    jg      mover_columna
    
    jmp     hay_movimiento_valido?

fin:
    ret