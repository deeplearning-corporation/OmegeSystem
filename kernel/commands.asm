; 命令实现模块

; grep命令
cmd_grep_func:
    mov esi, grep_usage
    call print_string
    ret

grep_usage db 'Usage: grep [pattern] [file]', 0x0d, 0x0a, 0

; rm命令
cmd_rm_func:
    call get_argument
    call fs_delete_file
    ret

; rmdir命令
cmd_rmdir_func:
    call get_argument
    call fs_delete_directory
    ret

; mkdir命令
cmd_mkdir_func:
    call get_argument
    call fs_create_directory
    ret

; ls命令
cmd_ls_func:
    call fs_list_directory
    ret

; cd命令
cmd_cd_func:
    call get_argument
    call fs_change_directory
    ret

; help命令
cmd_help_func:
    mov esi, help_text
    call print_string
    ret

help_text db 'Omege System 0.1 Commands:', 0x0d, 0x0a
         db '  grep      - Search text in files', 0x0d, 0x0a
         db '  rm        - Remove files', 0x0d, 0x0a
         db '  rmdir     - Remove directories', 0x0d, 0x0a
         db '  mkdir     - Create directories', 0x0d, 0x0a
         db '  ls        - List directory contents', 0x0d, 0x0a
         db '  cd        - Change directory', 0x0d, 0x0a
         db '  help      - Show this help', 0x0d, 0x0a
         db '  shutdown  - Shutdown the system', 0x0d, 0x0a
         db '  time      - Show system time', 0x0d, 0x0a
         db '  date      - Show system date', 0x0d, 0x0a
         db '  reboot    - Reboot the system', 0x0d, 0x0a
         db '  packagemgr- Package manager', 0x0d, 0x0a, 0

; shutdown命令
cmd_shutdown_func:
    mov esi, shutdown_msg
    call print_string
    ; APM关机
    mov ax, 0x5301
    xor bx, bx
    int 0x15
    mov ax, 0x5307
    mov bx, 0x0001
    mov cx, 0x0003
    int 0x15
    jmp $
    
shutdown_msg db 'Shutting down...', 0x0d, 0x0a, 0

; time命令
cmd_time_func:
    call get_time
    ret

; date命令
cmd_date_func:
    call get_date
    ret

; reboot命令
cmd_reboot_func:
    mov esi, reboot_msg
    call print_string
    ; 重启
    mov ax, 0x0003
    int 0x10
    jmp 0xffff:0x0000
    
reboot_msg db 'Rebooting...', 0x0d, 0x0a, 0

; packagemgr命令
cmd_packagemgr_func:
    call get_argument
    call package_manager
    ret

; 获取参数
get_argument:
    mov esi, command_buffer
    ; 跳过命令名
    xor ecx, ecx
.skip:
    lodsb
    test al, al
    jz .noarg
    cmp al, ' '
    je .found
    inc ecx
    jmp .skip
.found:
    ; 跳过空格
.skip_space:
    lodsb
    cmp al, ' '
    je .skip_space
    cmp al, 0
    je .noarg
    dec esi
    mov edi, argument_buffer
.copy_arg:
    lodsb
    test al, al
    jz .done
    cmp al, ' '
    je .done
    stosb
    jmp .copy_arg
.done:
    mov al, 0
    stosb
    ret
.noarg:
    mov edi, argument_buffer
    mov al, 0
    stosb
    ret

argument_buffer times 256 db 0
