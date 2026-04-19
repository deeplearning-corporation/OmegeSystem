; 简单测试

[bits 32]
[org 0x1000]

start:
    mov esi, test_msg
    call print_string
    ret

print_string:
    pusha
.loop:
    lodsb
    test al, al
    jz .done
    mov ah, 0x0e
    int 0x10
    jmp .loop
.done:
    popa
    ret

test_msg db 'Test passed!', 0x0d, 0x0a, 0
