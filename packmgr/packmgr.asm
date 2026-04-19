; 包管理器

init_packmgr:
    mov esi, packmgr_init_msg
    call print_string
    ret

package_manager:
    mov esi, argument_buffer
    cmp byte [esi], 0
    je .show_help
    
    ; 检查子命令
    mov edi, cmd_install
    call strcmp
    jc .install
    
    mov edi, cmd_remove
    call strcmp
    jc .remove
    
    mov edi, cmd_update
    call strcmp
    jc .update
    
    mov edi, cmd_list
    call strcmp
    jc .list
    
.show_help:
    mov esi, packmgr_help
    call print_string
    ret

.install:
    call get_package_name
    mov esi, install_msg
    call print_string
    ret

.remove:
    call get_package_name
    mov esi, remove_msg
    call print_string
    ret

.update:
    mov esi, update_msg
    call print_string
    ret

.list:
    mov esi, list_msg
    call print_string
    ret

get_package_name:
    mov esi, argument_buffer
    ; 跳过packagemgr命令
    xor ecx, ecx
.skip_cmd:
    lodsb
    test al, al
    jz .done
    cmp al, ' '
    jne .skip_cmd
.skip_spaces:
    lodsb
    cmp al, ' '
    je .skip_spaces
    cmp al, 0
    je .done
    dec esi
    mov edi, package_name
.copy:
    lodsb
    test al, al
    jz .done
    cmp al, ' '
    je .done
    stosb
    jmp .copy
.done:
    mov al, 0
    stosb
    ret

package_name times 64 db 0

cmd_install db 'install', 0
cmd_remove db 'remove', 0
cmd_update db 'update', 0
cmd_list db 'list', 0

packmgr_init_msg db 'Package Manager initialized', 0x0d, 0x0a, 0
packmgr_help db 'Package Manager Commands:', 0x0d, 0x0a
            db '  packagemgr install <pkg>', 0x0d, 0x0a
            db '  packagemgr remove <pkg>', 0x0d, 0x0a
            db '  packagemgr update', 0x0d, 0x0a
            db '  packagemgr list', 0x0d, 0x0a, 0
install_msg db 'Installing package...', 0x0d, 0x0a, 0
remove_msg db 'Removing package...', 0x0d, 0x0a, 0
update_msg db 'Updating package list...', 0x0d, 0x0a, 0
list_msg db 'Installed packages: coreutils, bash, gcc', 0x0d, 0x0a, 0
