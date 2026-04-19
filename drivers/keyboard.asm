; 键盘驱动

keyboard_map:
    db 0, 27, '1', '2', '3', '4', '5', '6', '7', '8', '9', '0', '-', '=', 0x08
    db 0x09, 'q', 'w', 'e', 'r', 't', 'y', 'u', 'i', 'o', 'p', '[', ']', 0x0a
    db 0, 'a', 's', 'd', 'f', 'g', 'h', 'j', 'k', 'l', ';', "'", '`', 0
    db '\\', 'z', 'x', 'c', 'v', 'b', 'n', 'm', ',', '.', '/', 0, '*', 0

keyboard_handler:
    in al, 0x60
    cmp al, 0x80
    jae .release
    movzx ebx, al
    mov al, [keyboard_map + ebx]
    test al, al
    jz .done
    call putchar
.release:
.done:
    ret
