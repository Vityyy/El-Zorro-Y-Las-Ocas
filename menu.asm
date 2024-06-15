%macro mPuts 0
    sub rsp,8
    call puts
    add rsp,8
%endmacro

%macro mGets 0
    sub rsp,8
    call gets
    add rsp,8
%endmacro

%macro mSscanf 0
    sub rsp,8
    call sscanf
    add rsp,8
%endmacro

%macro mSystem 0
    mov rdi,cdm_clear
    sub rsp,8
    call system
    add rsp,8
%endmacro

global mostrarMenu
extern puts,gets,sscanf,system

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
    mSystem
    mov rdi,mensaje_menu
    mPuts
    mov rdi,eleccion_usuario
    mGets

    mov rdi,eleccion_usuario
    mov rsi,formato
    mov rdx,numero_eleccion
    mSscanf

    cmp rax,1
    jl  input_Invalido

    cmp byte[numero_eleccion],1
    je  fin_del_menu

    cmp byte[numero_eleccion],2
    je  fin_del_menu
    

input_Invalido:
    mSystem
    mov rdi,mensaje_Input_Invalido
    mPuts
    mov rdi,solo_enter
    mGets
    jmp mostrarMenu

fin_del_menu:
    mSystem
    mov rax,[numero_eleccion]
    ret
    


