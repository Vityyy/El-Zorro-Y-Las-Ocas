%include "macros.asm"

global mostrarMenu

section .data
    mensaje_menu           db "Bienvenido al juego del Zorro y las Ocas",10,"Presione el numero correspondiente a la accion requerida",10,"1-Jugar",10,"2-Opciones",0
    formato                db "%li",0
    mensaje_Input_Invalido db "Input invalido, presione enter para volver",0
    cdm_clear              db "clear",0

section .bss
    solo_enter       resq 1
    eleccion_usuario resb 20
    numero_eleccion  resb 20 
    
section .text
mostrarMenu:
    mSystem cdm_clear

    mPuts mensaje_menu
    mGets eleccion_usuario

    mSscanf eleccion_usuario,formato,numero_eleccion

    cmp rax,1
    jl  input_Invalido

    cmp byte[numero_eleccion],1
    je  fin_del_menu

    cmp byte[numero_eleccion],2
    je  fin_del_menu
    

input_Invalido:
    mSystem cdm_clear

    mPuts mensaje_Input_Invalido
    mGets solo_enter
    
    jmp mostrarMenu

fin_del_menu:
    mSystem cdm_clear
    mov rax,[numero_eleccion]
    ret
    


