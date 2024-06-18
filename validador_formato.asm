%include "macros.asm"

global validador_formato

section .data
    salir_programa           db "-1",0
    coma                     db ",",0
    formato                  db "%li",0
    mensaje_invalido         db "Coordenada ingresada invalida, intente nuevamente",0
    mensaje_seleccionar_ocas db "Ingrese la coordenada de la Oca a seleccionar",0
    mensaje_movimiento       db "Ingrese coordenada a la que desea moverse",0

section .bss
    fila                    resq 1
    columna                 resq 1
    coordenada_seleccionada resb 5

section .text

validador_formato:
    cmp rdi,0
    je  mensaje_moverse

mensaje_seleccion_ocas:
    mPuts mensaje_seleccionar_ocas
    mGets coordenada_seleccionada

    jmp inicializa_contador
    
mensaje_moverse:
    mPuts mensaje_movimiento
    mGets coordenada_seleccionada

    jmp inicializa_contador

mensaje_coord_incorrecta:
    mPuts mensaje_invalido
    mGets coordenada_seleccionada

inicializa_contador:
    mov rcx,-1

validar_largo_input:
    inc rcx
    mov dl,[coordenada_seleccionada + rcx]
    cmp dl,0
    jne validar_largo_input

    cmp rcx,3  
    jg  mensaje_coord_incorrecta

    cmp rcx,1
    jle mensaje_coord_incorrecta

    cmp rcx,2
    je  validar_exit

validar_tipo:
    mCMPSB coma,coordenada_seleccionada+1,1
    jne mensaje_coord_incorrecta

    mSscanf coordenada_seleccionada, formato, fila
    cmp rax,1
    jl mensaje_coord_incorrecta

    mSscanf coordenada_seleccionada+2, formato, columna
    cmp rax,1
    jl mensaje_coord_incorrecta

validar_rango:
    cmp         qword[fila], 7
    jg          mensaje_coord_incorrecta

    cmp         qword[columna], 7
    jg          mensaje_coord_incorrecta

    cmp         qword[columna], 3
    jl          filaCortada

    cmp         qword[columna], 5
    jg          filaCortada

    jmp         fin_validacion

filaCortada:
    cmp         qword[fila], 3
    jl          mensaje_coord_incorrecta

    cmp         qword[fila], 5
    jg          mensaje_coord_incorrecta

validar_exit:
    mCMPSB salir_programa,coordenada_seleccionada,3
    jne mensaje_coord_incorrecta
    mov rax,-1

fin_validacion:
    mov rdi,[fila]
    mov rsi,[columna]
    ret