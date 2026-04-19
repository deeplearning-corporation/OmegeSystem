; 简单文件系统

init_fs:
    mov esi, fs_init_msg
    call print_string
    ret

fs_create_file:
    ret

fs_delete_file:
    ret

fs_create_directory:
    ret

fs_delete_directory:
    ret

fs_list_directory:
    mov esi, dummy_ls
    call print_string
    ret

fs_change_directory:
    ret

fs_init_msg db 'Filesystem initialized', 0x0d, 0x0a, 0
dummy_ls db 'kernel.bin boot/ usr/', 0x0d, 0x0a, 0
