; TTY模块

init_tty:
    mov byte [cursor_x], 0
    mov byte [cursor_y], 0
    ret

putchar:
    pusha
    mov ah, 0x0e
    int 0x10
    popa
    ret

getchar:
    mov ah, 0x00
    int 0x16
    ret

print_string:
    pusha
.loop:
    lodsb
    test al, al
    jz .done
    call putchar
    jmp .loop
.done:
    popa
    ret

do_newline:
    pusha
    mov al, 0x0d
    call putchar
    mov al, 0x0a
    call putchar
    popa
    ret

print_hex:
    pusha
    mov ecx, 8
.loop:
    rol eax, 4
    mov ebx, eax
    and ebx, 0x0f
    cmp bl, 9
    jle .digit
    add bl, 'A' - 10
    jmp .print
.digit:
    add bl, '0'
.print:
    mov al, bl
    call putchar
    dec ecx
    jnz .loop
    popa
    ret

; BCD转二进制
bcd_to_bin:
    push ebx
    mov bl, al
    and al, 0x0f
    shr bl, 4
    mov bh, 10
    mul bh
    add al, bl
    pop ebx
    ret

; 打印两位数
print_two_digits:
    pusha
    mov bl, 10
    div bl
    add al, '0'
    call putchar
    add ah, '0'
    mov al, ah
    call putchar
    popa
    ret

; 获取时间
get_time:
    pusha
    mov esi, time_str
    call print_string
    
    ; 读取小时
    mov al, 0x04
    out 0x70, al
    in al, 0x71
    call bcd_to_bin
    call print_two_digits
    
    mov al, ':'
    call putchar
    
    ; 读取分钟
    mov al, 0x02
    out 0x70, al
    in al, 0x71
    call bcd_to_bin
    call print_two_digits
    
    mov al, ':'
    call putchar
    
    ; 读取秒
    mov al, 0x00
    out 0x70, al
    in al, 0x71
    call bcd_to_bin
    call print_two_digits
    
    call do_newline
    popa
    ret

; 获取日期
get_date:
    pusha
    mov esi, date_str
    call print_string
    
    ; 读取年
    mov al, 0x09
    out 0x70, al
    in al, 0x71
    call bcd_to_bin
    mov ah, al
    mov al, '2'
    call putchar
    mov al, '0'
    call putchar
    mov al, ah
    call print_two_digits
    
    mov al, '/'
    call putchar
    
    ; 读取月
    mov al, 0x08
    out 0x70, al
    in al, 0x71
    call bcd_to_bin
    call print_two_digits
    
    mov al, '/'
    call putchar
    
    ; 读取日
    mov al, 0x07
    out 0x70, al
    in al, 0x71
    call bcd_to_bin
    call print_two_digits
    
    call do_newline
    popa
    ret

; 清屏
clear_screen:
    pusha
    mov ax, 0x0003
    int 0x10
    popa
    ret

cursor_x db 0
cursor_y db 0
time_str db 'Time: ', 0
date_str db 'Date: ', 0
