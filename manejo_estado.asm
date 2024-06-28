%include "macros.asm"

global manejo_archivos

section .data
    mensaje_guardar         db 'Ingrese el nombre del archivo a guardar (maximo de 16 caracteres + .bin)', 0
    mensaje_cargar          db 'Ingrese el nombre del archivo a cargar (.bin)', 0
    mensaje_error           db 'Error. En caso de querer guardar, asegurarse de cumplir el formato. En caso de querer cargar, asegurarse que exista el archivo. Presione enter para continuar.', 0
    modo_leer               db 'rb',0
    modo_escribir           db 'wb',0
    punto                   db '.'
    extension               db ".bin"

section .bss
    direc_tablero                   resq    1
    id_archivo                      resq    1
    nombre_archivo                  resb    50

section .text
manejo_archivos:
    sub rsp,8
    mov [direc_tablero],rsi
    cmp rdi,1
    je  guardar

cargar:
    mPuts   mensaje_cargar
    mGets   nombre_archivo

    mFopen nombre_archivo,modo_leer
    cmp rax,0
    jle error

    mov qword[id_archivo],rax

leer:
    mFread [direc_tablero],150,1,[id_archivo]
    jmp cerrar_archivo

guardar:
    mPuts   mensaje_guardar
    mGets   nombre_archivo
    mov rbx,0
    jmp validar_extension

crear_archivo:
    mFopen nombre_archivo,modo_escribir
    cmp rax,0
    jle error

    mov qword[id_archivo],rax

escribir:
    mFwrite [direc_tablero],150,1,[id_archivo]

cerrar_archivo:
    mFclose [id_archivo]
    jmp fin
    
validar_extension:
    mCMPSB punto,nombre_archivo,rbx,1
    je corroborar_extension
    inc rbx
    cmp rbx,16
    jle validar_extension
    
corroborar_extension:
    mCMPSB extension,nombre_archivo,rbx,4
    jne error
    jmp crear_archivo

error: 
    mPuts   mensaje_error
    mGets   id_archivo
    mov rax,-1
    
fin:
    add rsp,8
    ret
    