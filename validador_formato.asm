%include "macros.asm"

global validador_formato
extern validador_rango

section .data
    salir_programa           db "-1",0
    guardar_estado           db "-2",0
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
    sub rsp,8
    cmp rdi,0
    je  mensaje_moverse_zorro

mensaje_seleccion_ocas:
    mPuts mensaje_ocas
    mGets coordenada_multiple

    mov rdi,[coordenada_multiple]
    call validar_exit

    cmp rax,-1
    je  fin_validacion

    mov rdi,[coordenada_multiple]
    call validar_guardar

    cmp rax,-2
    je  fin_validacion

    mov rcx,-1
caso_particular_ocas:       
    inc rcx            
    mov dl,[coordenada_multiple + rcx]
    cmp dl,0
    jne caso_particular_ocas

    cmp rcx,7 
    jne mensaje_seleccion_ocas
    
    _movsb coordenada_multiple,posicion_oca,0,3
    _movsb coordenada_multiple+4,coordenada_seleccionada_destino,0,3
    
asignacion:
    mov rdi, [posicion_oca]
    mov rsi, fila_origen
    mov rdx, columna_origen
    call validador 
    
    cmp rax,0
    je mensaje_seleccion_ocas

    mov rdi, [coordenada_seleccionada_destino]
    mov rsi, fila_destino
    mov rdx, columna_destino
    call validador 
    
    cmp rax,0
    je mensaje_seleccion_ocas

    mov rdx,[fila_origen]
    mov rcx,[columna_origen]
    jmp fin_validacion
    
mensaje_moverse_zorro:
    mPuts mensaje_movimiento
    mGets coordenada_seleccionada_destino

    mov rdi,[coordenada_seleccionada_destino]
    call validar_exit

    cmp rax,-1
    je  fin_validacion

    mov rdi,[coordenada_seleccionada_destino]
    call validar_guardar

    cmp rax,-2
    je  fin_validacion

    mov rdi,[coordenada_seleccionada_destino]
    mov rsi,fila_destino
    mov rdx,columna_destino

    call validador 

    cmp rax,0
    je mensaje_moverse_zorro
    
fin_validacion:
    mov rdi,[fila_destino]
    mov rsi,[columna_destino]
    add rsp,8
    ret ;return de la rutina externa
;**********************************************************************
;valida el formato de la entrada y que no este fuera del tablero
;0 si la entrada es invalida, 1 si es valida

validador:
    sub rsp,8
    mov [coordenada_seleccionada],rdi
    mov [fila],rsi
    mov [columna],rdx
    mov rcx,-1

validar_input:
    inc rcx
    mov dl,[coordenada_seleccionada + rcx]
    cmp dl,0
    jne validar_input

    cmp rcx,3  
    jne input_invalido

validar_tipo:
    mCMPSB coma,coordenada_seleccionada+1,0,1
    jne input_invalido

    mSscanf coordenada_seleccionada, formato, [fila]
    cmp rax,1
    jl input_invalido

    mSscanf coordenada_seleccionada+2, formato, [columna]
    cmp rax,1
    jl input_invalido

validar_rango:
    mov r12,[fila]
    mov r13,[columna]
    mov rdi,[r12]
    mov rsi,[r13]
    call validador_rango

    cmp rax,1
    je  fin_validador_interno

input_invalido:
    mPuts mensaje_invalido
    mov rax,0

fin_validador_interno:
    add rsp,8
    ret
    
validar_exit:
    mov     rax,1
    mov     [coordenada_seleccionada],rdi
    mCMPSB  salir_programa,coordenada_seleccionada,0,3
    jne     fin_validar_exit
    mov     rax,-1

fin_validar_exit:
    ret

validar_guardar:
    mov     rax,1
    mov     [coordenada_seleccionada],rdi
    mCMPSB  guardar_estado,coordenada_seleccionada,0,3
    jne     fin_validar_exit
    mov     rax,-2

fin_validar_guardar:
    ret
