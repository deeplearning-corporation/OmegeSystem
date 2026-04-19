; 宏定义

%macro print 1
    pusha
    mov esi, %1
    call print_string
    popa
%endmacro

%macro newline 0
    pusha
    call do_newline
    popa
%endmacro

%macro println 1
    pusha
    mov esi, %1
    call print_string
    call do_newline
    popa
%endmacro
