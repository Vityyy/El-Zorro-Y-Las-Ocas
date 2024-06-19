%include "macros.asm"

global validador_formato

section .data
    salir_programa           db "-1",0
    espacio                  db " ",0
    coma                     db ",",0
    formato                  db "%li",0
    mensaje_invalido         db "Coordenada ingresada invalida, intente nuevamente",0
    mensaje_ocas             db "Ingrese la coordenada de la Oca a seleccionar y la coordenada donde deseada a moverse",0
    mensaje_movimiento       db "Ingrese coordenada a la que desea moverse",0

section .bss
    fila                    resq 1
    columna                 resq 1
    fila_origen             resq 1
    columna_origen          resq 1
    fila_destino            resq 1
    columna_destino         resq 1
    coordenada_multiple     resb 10
    posicion_oca            resb 5
    coordenada_seleccionada resq 1
    coordenada_seleccionada_destino resb 5

section .text

validador_formato:
    cmp rdi,0
    je  mensaje_moverse

mensaje_seleccion_ocas:
    mPuts mensaje_ocas
    mGets coordenada_multiple

    mov rdi,[coordenada_multiple]
    sub rsp,8
    call validar_exit
    add rsp,8

    cmp rax,-1
    je  fin_validacion

    mov rcx,-1
caso_particular:       
    inc rcx            
    mov dl,[coordenada_multiple + rcx]
    cmp dl,0
    jne caso_particular

    cmp rcx,7
    jne mensaje_seleccion_ocas
    
    _movsb coordenada_multiple,posicion_oca,0,3
    _movsb coordenada_multiple+4,coordenada_seleccionada_destino,0,3
    
asignacion:
    mov rdi, [posicion_oca]
    mov rsi, fila_origen
    mov rdx, columna_origen
    sub rsp,8
    call validador 
    add rsp,8
    
    cmp rax,0
    je mensaje_seleccion_ocas

    mov rdi, [coordenada_seleccionada_destino]
    mov rsi, fila_destino
    mov rdx, columna_destino
    sub rsp,8
    call validador 
    add rsp,8
    
    cmp rax,0
    je mensaje_seleccion_ocas

    mov rdx,[fila_origen]
    mov rcx,[columna_origen]
    jmp fin_validacion
    
mensaje_moverse:
    mPuts mensaje_movimiento
    mGets coordenada_seleccionada_destino

    mov rdi,[coordenada_seleccionada_destino]
    sub rsp,8
    call validar_exit
    add rsp,8

    cmp rax,-1
    je  fin_validacion

    mov rdi,[coordenada_seleccionada_destino]
    mov rsi,fila_destino
    mov rdx,columna_destino
    
    sub rsp,8
    call validador 
    add rsp,8
    
fin_validacion:
    mov rdi,[fila_destino]
    mov rsi,[columna_destino]
    ret
;**********************************************************************
;valida el formato de la entrada y que no este fuera del tablero
;devuelve -1 si es fin de programa, 0 si la entrada es invalida, 1 si es valida

validador:
    mov [coordenada_seleccionada],rdi
    mov [fila],rsi
    mov [columna],rdx
    mov rcx,-1

validar_input:
    inc rcx
    ; mov r10,[coordenada_seleccionada]
    mov dl,[coordenada_seleccionada + rcx]
    cmp dl,0
    jne validar_input

    cmp rcx,3  
    jne input_invalido

validar_tipo:
    ; mov r10,[coordenada_seleccionada]
    mCMPSB coma,coordenada_seleccionada+1,1
    jne input_invalido

    mSscanf coordenada_seleccionada, formato, [fila]
    cmp rax,1
    jl input_invalido

    mSscanf coordenada_seleccionada+2, formato, [columna]
    cmp rax,1
    jl input_invalido

validar_rango:
    mov r10,[fila]
    mov r11,[columna]

    cmp     qword[r10], 7
    jg      input_invalido

    cmp     qword[r11], 7
    jg      input_invalido

    cmp     qword[r11], 3
    jl      filaCortada

    cmp     qword[r11], 5
    jg      filaCortada

    mov     rax,1
    jmp     fin_validador_interno

filaCortada:
    cmp     qword[r10], 3
    jl      input_invalido

    cmp     qword[r10], 5
    jg      input_invalido
    
    mov     rax,1
    jmp     fin_validador_interno
    
input_invalido:
    mPuts mensaje_invalido
    mov     rax,0

fin_validador_interno:
    ret
    
validar_exit:
    mov     [coordenada_seleccionada],rdi
    xor     rax,rax
    mCMPSB salir_programa,coordenada_seleccionada,3
    jne     fin_validar_exit
    mov     rax,-1
    
fin_validar_exit:
    ret