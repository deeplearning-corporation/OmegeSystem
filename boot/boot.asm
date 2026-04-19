; Omege System 0.1 Bootloader
; 汇编语言：NASM

[org 0x7c00]
[bits 16]

BOOT_DRIVE db 0

start:
    mov [BOOT_DRIVE], dl
    
    ; 设置段寄存器
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7c00
    
    ; 清屏
    mov ax, 0x0003
    int 0x10
    
    ; 显示启动信息
    mov si, boot_msg
    call print_string
    
    ; 加载内核
    call load_kernel
    
    ; 进入保护模式
    call switch_to_pm
    
    jmp $

print_string:
    lodsb
    or al, al
    jz .done
    mov ah, 0x0e
    int 0x10
    jmp print_string
.done:
    ret

load_kernel:
    mov si, loading_msg
    call print_string
    
    mov bx, 0x1000          ; 加载到0x1000
    mov ah, 0x02
    mov al, 0x30            ; 加载48个扇区
    mov ch, 0x00
    mov cl, 0x02
    mov dh, 0x00
    mov dl, [BOOT_DRIVE]
    int 0x13
    jc .error
    ret
.error:
    mov si, load_error
    call print_string
    jmp $

switch_to_pm:
    cli
    lgdt [gdt_descriptor]
    mov eax, cr0
    or eax, 0x1
    mov cr0, eax
    jmp CODE_SEG:init_pm

[bits 32]
init_pm:
    mov ax, DATA_SEG
    mov ds, ax
    mov ss, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    
    mov ebp, 0x90000
    mov esp, ebp
    
    jmp 0x1000               ; 跳转到内核

; GDT
gdt_start:
    dd 0x0
    dd 0x0
gdt_code:
    dw 0xffff
    dw 0x0
    db 0x0
    db 10011010b
    db 11001111b
    db 0x0
gdt_data:
    dw 0xffff
    dw 0x0
    db 0x0
    db 10010010b
    db 11001111b
    db 0x0
gdt_end:

gdt_descriptor:
    dw gdt_end - gdt_start - 1
    dd gdt_start

CODE_SEG equ gdt_code - gdt_start
DATA_SEG equ gdt_data - gdt_start

; 数据
boot_msg db 'Omege System 0.1 Starting...', 0x0d, 0x0a, 0
loading_msg db 'Loading kernel...', 0x0d, 0x0a, 0
load_error db 'Failed to load kernel!', 0x0d, 0x0a, 0

times 510 - ($-$$) db 0
dw 0xaa55
