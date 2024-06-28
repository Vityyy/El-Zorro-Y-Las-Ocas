%include "macros.asm"

global mostrar_interfaz
extern validador_rango

section .data
    ; relacionado al tablero
    CANT_COL            dq      7
    LONG_ELEMEN         dq      1
    posCol              dq      1
    posFil              dq      1
    
    ;imprimir por pantalla
    mensaje_saltos                  db "Cantidad de saltos:",10,"   $ Arriba Izquierda: %hhi",10,"   $ Arriba: %hhi",10,"   $ Arriba Derecha: %hhi",10,"   $ Izquierda: %hhi",10,0
    mensaje_saltos2                 db "   $ Derecha: %hhi",10,"   $ Abajo Izquierda: %hhi",10,"   $ Abajo: %hhi",10,"   $ Abajo Derecha: %hhi",10,10,0
    mensaje_movimiento              db "Cantidad de movimientos:",10,"   $ Arriba Izquierda: %hhi",10,"   $ Arriba: %hhi",10,"   $ Arriba Derecha: %hhi",10,"   $ Izquierda: %hhi",10,0
    espacio                         db      " ",0
    mostrarFicha                    db     " %c ", 0
    textFila                        db      "F",0
    textColumna                     db      "C",0
    mostrarIndicador                db      " %c%li",0
    separadorVertical               db      "|",0
    separadorHorizontal             db      "    ----------------------------",10,0
    separadorHorizontalCortado      db      "           -------------        ",10,0
    saltoLinea                      db      "",10,0

section .bss
    direc_tablero        resq 1
section .text
    
mostrar_interfaz:
    sub         rsp,8
    mov         [direc_tablero],rdi
    mov         qword[posFil], 0
    mov         qword[posCol], 0
    cmp rsi,2
    je  mostrar_stats
    
mostrarTablero:    
    cmp         qword[posFil], 0
    je          identificarColumnas

    cmp         qword[posCol], 1
    jg          mostrarPosicion

    mov         rdi, mostrarIndicador
    mov         rsi, [textFila]
    mov         rdx, [posFil]
    mPrintf
    mov         rdi, separadorVertical
    mPrintf

mostrarPosicion:

    buscarPosicion  posFil, posCol, LONG_ELEMEN, CANT_COL
    mov             rdi, mostrarFicha
    mov             r10,[direc_tablero]
    mov             rsi, [r10 + rdx]
    mPrintf

    mov             rdi,[posFil]
    mov             rsi,[posCol]
    call            validador_rango
    
    cmp             rax, 1
    je              separadorColumnas

    cmp             qword[posCol], 2
    je              separadorColumnas

    mov             rdi, espacio
    mPrintf

    jmp             avanzarMostrarTablero

identificarColumnas:
    mov             rdi, mostrarIndicador
    mov             rsi, [textColumna]
    mov             rdx, [posCol]
    mPrintf

separadorColumnas:             
    mov             rdi, separadorVertical
    mPrintf

avanzarMostrarTablero:
    inc         qword[posCol]
    cmp         qword[posCol], 7
    jle         mostrarTablero

    mov         rdi, saltoLinea
    mPrintf

    cmp         qword[posFil], 2
    jl         separadorFilasCortado
    
    cmp         qword[posFil], 6
    jge         separadorFilasCortado

    mov         rdi, separadorHorizontal
    mPrintf

    jmp         avanzarFila

separadorFilasCortado:
    mov         rdi, separadorHorizontalCortado
    mPrintf

avanzarFila:
    mov         qword[posCol], 1
    inc         qword[posFil]

    cmp         qword[posFil], 7
    jle         mostrarTablero

fin:
    add         rsp,8
    ret

mostrar_stats:
    mov r13,[direc_tablero]           
    mov rdi,mensaje_saltos 
    mov rsi,[r13]
    mov rdx,[r13+2]
    mov rcx,[r13+4]
    mov r8,[r13+10]
    mPrintf
    mov rdi,mensaje_saltos2
    mov rsi,[r13+14]
    mov rdx,[r13+20]
    mov rcx,[r13+22]
    mov r8,[r13+24]
    mPrintf

    mov rdi,mensaje_movimiento
    mov rsi,[r13+6]
    mov rdx,[r13+7]
    mov rcx,[r13+8]
    mov r8,[r13+11]
    mPrintf
    mov rdi,mensaje_saltos2
    mov rsi,[r13+13]
    mov rdx,[r13+16]
    mov rcx,[r13+17]
    mov r8,[r13+18]
    mPrintf

    jmp fin                                                                                                                                                                                                                                                                   