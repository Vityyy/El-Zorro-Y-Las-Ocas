global validador_rango

section .data

section .bss
    fila_candidata    resq 1
    columna_candidata resq 1

section .text

; Verifica que la fila y la columna pertenezcan al tablero. En caso afirmativo, devuelve 1, en caso contrario, 0.
validador_rango:
    mov [fila_candidata],rdi
    mov [columna_candidata],rsi

inicio:
    mov     rax,1

    cmp     qword[fila_candidata], 7
    jg      invalido

    cmp     qword[columna_candidata], 7
    jg      invalido

    cmp     qword[fila_candidata], 1
    jl      invalido

    cmp     qword[columna_candidata], 1
    jl      invalido

    cmp     qword[columna_candidata], 3
    jl      filaCortada

    cmp     qword[columna_candidata], 5
    jg      filaCortada

    jmp     fin_validacion

filaCortada:
    cmp     qword[fila_candidata], 3
    jl      invalido

    cmp     qword[fila_candidata], 5
    jg      invalido
    
    jmp     fin_validacion

invalido:
    mov rax,0

fin_validacion:
    ret