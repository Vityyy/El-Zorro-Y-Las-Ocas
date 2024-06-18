%include "macros.asm"
global jugar_zorro

section  .data
    CANT_COL              dq      7
    LONG_ELEMEN           dq      1
    espacio               db  " ",0                 
    salir_programa        db "-1",0
    coma                  db ",",0
    mensaje_Jugador_Zorro db "Ingrese coordenada a la que desea moverse",0
    formato               db "%li",0

section  .bss
    direc_caracter_zorro    resq 1
    direc_fila_zorro        resq 1
    direc_columna_zorro     resq 1
    direc_tablero           resq 1
    fila                    resq 1
    columna                 resq 1
    coordenada_seleccionada resb 5

section  .text

jugar_zorro:
    
    mov [direc_tablero],rdi
    mov [direc_caracter_zorro],rsi
    mov [direc_fila_zorro],rdx
    mov [direc_columna_zorro],rcx

turno_zorro:
    mPuts mensaje_Jugador_Zorro
    mGets coordenada_seleccionada

    mov rcx,-1

validar_largo_input:
    inc rcx
    mov dl,[coordenada_seleccionada+rcx]
    cmp dl,0
    jne validar_largo_input

    cmp rcx,3  
    jg  turno_zorro

    cmp rcx,1
    jle  turno_zorro

    cmp rcx,2
    je  validar_exit

validar_formato:
    mCMPSB coma,coordenada_seleccionada+1,1
    jne turno_zorro

    mSscanf coordenada_seleccionada, formato, fila
    cmp rax,1
    jl turno_zorro

    mSscanf coordenada_seleccionada+2, formato, columna
    cmp rax,1
    jl turno_zorro

validar_rango:
    cmp         qword[fila], 7
    jg          turno_zorro

    cmp         qword[columna], 7
    jg          turno_zorro

    cmp         qword[columna], 3
    jl          filaCortada

    cmp         qword[columna], 5
    jg          filaCortada

    jmp         validar_movimiento

filaCortada:
    cmp         qword[fila], 3
    jl          turno_zorro

    cmp         qword[fila], 5
    jg          turno_zorro

validar_movimiento:
    mov r10,[direc_fila_zorro]
    mov r12,[r10]
    sub r12,[fila]
    cmp r12,1
    jg turno_zorro
    cmp r12,-1
    jl turno_zorro

    mov r10,[direc_columna_zorro]
    mov r13,[r10]
    sub r13,[columna]
    cmp r13,1
    jg turno_zorro
    cmp r13,-1
    jl turno_zorro

    add r12,r13     ;caso particular en que la coordenada sea la misma en la que estaba
    cmp r12,0
    je turno_zorro

mover_zorro:
    buscarPosicion fila,columna,LONG_ELEMEN,CANT_COL
    _movsb [direc_caracter_zorro], [direc_tablero], rdx, 1

borrar_posicion_anterior:
    mov r10,[direc_fila_zorro]
    mov r11,[direc_columna_zorro]
    buscarPosicion r10,r11,LONG_ELEMEN,CANT_COL
    _movsb espacio,[direc_tablero],rdx,1

actualizar_posicion_zorro:
    mov rdi,[fila]
    mov rsi,[direc_fila_zorro]
    mov [rsi],rdi
    mov rdi,[columna]
    mov rsi,[direc_columna_zorro]
    mov [rsi],rdi
    jmp end

validar_exit:
    mCMPSB salir_programa,coordenada_seleccionada,3
    jne turno_zorro
    mov rax,-1

end:
    ret