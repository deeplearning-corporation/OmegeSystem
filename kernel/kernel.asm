; Omege System 0.1 Kernel
[bits 32]
[org 0x1000]

%include "include/macros.inc"
%include "include/syscalls.inc"

start:
    ; 初始化TTY
    call init_tty
    
    ; 显示欢迎信息
    mov esi, welcome_msg
    call print_string
    
    ; 初始化文件系统
    call init_fs
    
    ; 初始化包管理器
    call init_packmgr
    
    ; 主命令循环
main_loop:
    mov esi, prompt
    call print_string
    
    call read_command
    
    call execute_command
    
    jmp main_loop

; 命令执行函数
execute_command:
    mov esi, command_buffer
    
    ; grep命令
    mov edi, cmd_grep
    call strcmp
    jc .grep
    
    ; rm命令
    mov edi, cmd_rm
    call strcmp
    jc .rm
    
    ; rmdir命令
    mov edi, cmd_rmdir
    call strcmp
    jc .rmdir
    
    ; mkdir命令
    mov edi, cmd_mkdir
    call strcmp
    jc .mkdir
    
    ; ls命令
    mov edi, cmd_ls
    call strcmp
    jc .ls
    
    ; cd命令
    mov edi, cmd_cd
    call strcmp
    jc .cd
    
    ; help命令
    mov edi, cmd_help
    call strcmp
    jc .help
    
    ; shutdown命令
    mov edi, cmd_shutdown
    call strcmp
    jc .shutdown
    
    ; time命令
    mov edi, cmd_time
    call strcmp
    jc .time
    
    ; date命令
    mov edi, cmd_date
    call strcmp
    jc .date
    
    ; reboot命令
    mov edi, cmd_reboot
    call strcmp
    jc .reboot
    
    ; packagemgr命令
    mov edi, cmd_packagemgr
    call strcmp
    jc .packagemgr
    
    ; 未知命令
    mov esi, unknown_cmd_msg
    call print_string
    ret

.grep:
    call cmd_grep_func
    ret
.rm:
    call cmd_rm_func
    ret
.rmdir:
    call cmd_rmdir_func
    ret
.mkdir:
    call cmd_mkdir_func
    ret
.ls:
    call cmd_ls_func
    ret
.cd:
    call cmd_cd_func
    ret
.help:
    call cmd_help_func
    ret
.shutdown:
    call cmd_shutdown_func
    ret
.time:
    call cmd_time_func
    ret
.date:
    call cmd_date_func
    ret
.reboot:
    call cmd_reboot_func
    ret
.packagemgr:
    call cmd_packagemgr_func
    ret

; 字符串比较
strcmp:
.loop:
    mov al, [esi]
    mov bl, [edi]
    cmp al, bl
    jne .notequal
    test al, al
    jz .equal
    inc esi
    inc edi
    jmp .loop
.equal:
    stc
    ret
.notequal:
    clc
    ret

; 读取命令
read_command:
    mov edi, command_buffer
    xor ecx, ecx
.read_loop:
    call getchar
    cmp al, 0x0d            ; Enter键
    je .done
    cmp al, 0x08            ; Backspace
    je .backspace
    stosb
    inc ecx
    mov ah, 0x0e
    mov al, al
    call putchar
    jmp .read_loop
.backspace:
    test ecx, ecx
    jz .read_loop
    dec edi
    dec ecx
    mov al, 0x08
    call putchar
    mov al, ' '
    call putchar
    mov al, 0x08
    call putchar
    jmp .read_loop
.done:
    mov al, 0
    stosb
    call do_newline
    ret

; 包含其他模块
%include "drivers/keyboard.asm"
%include "kernel/tty.asm"
%include "kernel/fs.asm"
%include "kernel/commands.asm"
%include "packmgr/packmgr.asm"

; 数据
welcome_msg db 'Omege System 0.1', 0x0d, 0x0a, 'Type "help" for commands', 0x0d, 0x0a, 0
prompt db 'Omege> ', 0
unknown_cmd_msg db 'Unknown command', 0x0d, 0x0a, 0

cmd_grep db 'grep', 0
cmd_rm db 'rm', 0
cmd_rmdir db 'rmdir', 0
cmd_mkdir db 'mkdir', 0
cmd_ls db 'ls', 0
cmd_cd db 'cd', 0
cmd_help db 'help', 0
cmd_shutdown db 'shutdown', 0
cmd_time db 'time', 0
cmd_date db 'date', 0
cmd_reboot db 'reboot', 0
cmd_packagemgr db 'packagemgr', 0

command_buffer times 256 db 0
