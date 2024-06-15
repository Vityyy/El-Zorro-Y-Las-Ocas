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

%macro      mPrintf 0
    sub         rsp, 8
    call        printf
    add         rsp, 8
%endmacro

%macro mSscanf 0
    sub rsp,8
    call sscanf
    add rsp,8
%endmacro

%macro mSystem 0
    sub rsp,8
    call system
    add rsp,8
%endmacro

%macro      _movsb      3
    ;   %1 ->    direccion del string origen
    ;   %2 ->    direccion del string destino
    ;   %3 ->    desplazamiento, en caso de querer cambiar algo en el tablero
    ;           0, en cualquier otro caso
    sub         rsi, rsi
    sub         rdi, rdi
    
    mov         rsi, %1
    mov         rdi, %2
    add         rdi, %3
    mov         rcx, 1
    rep     movsb

%endmacro

%macro      buscarPosicion 4
    ; %1 = fil
    ; %2 = col
    ; %3 = longElemento
    ; %4 = cantCol
    mov         rax, [%1]
    dec         rax
    imul        qword[%4]
    add         rdx, rax

    mov         rcx, rdx

    mov         rax, [%2]
    dec         rax
    imul        qword[%3]
    add         rdx, rax
    
    add         rdx, rcx

    ; deja el desplazamiento en el rdx
%endmacro

extern puts,gets,system,sscanf,printf