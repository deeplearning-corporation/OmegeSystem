# Omege System 0.1 Makefile for MinGW32-make

NASM = nasm
QEMU = qemu-system-i386
RM = rm -f
MKDIR = mkdir -p
DD = dd

# 目录
BOOT_DIR = boot
KERNEL_DIR = kernel
DRIVERS_DIR = drivers
PACKMGR_DIR = packmgr
INCLUDE_DIR = include
BUILD_DIR = build

# 所有汇编源文件
BOOT_SRC = $(BOOT_DIR)/boot.asm
KERNEL_MAIN_SRC = $(KERNEL_DIR)/kernel.asm
COMMANDS_SRC = $(KERNEL_DIR)/commands.asm
TTY_SRC = $(KERNEL_DIR)/tty.asm
FS_SRC = $(KERNEL_DIR)/fs.asm
KEYBOARD_SRC = $(DRIVERS_DIR)/keyboard.asm
PACKMGR_SRC = $(PACKMGR_DIR)/packmgr.asm

# 目标文件
BOOT_BIN = $(BUILD_DIR)/boot.bin
KERNEL_BIN = $(BUILD_DIR)/kernel.bin
OS_IMG = $(BUILD_DIR)/OmegeSystem.img

# 标志
NASM_FLAGS = -f bin -I include/

# 检测CPU核心数
ifeq ($(OS),Windows_NT)
    NPROC := $(NUMBER_OF_PROCESSORS)
    ifeq ($(NPROC),)
        NPROC := 1
    endif
else
    NPROC := 1
endif

# 默认目标
all: directories $(OS_IMG)
	@echo =========================================
	@echo Build complete: $(OS_IMG)
	@echo Use mingw32-make run to start the OS
	@echo =========================================

# 创建目录
directories:
	@if not exist $(BUILD_DIR) mkdir $(BUILD_DIR)

# 汇编bootloader
$(BOOT_BIN): $(BOOT_SRC)
	@echo ASM      $(BOOT_SRC)
	$(NASM) $(NASM_FLAGS) $< -o $@

# 汇编内核及所有模块
$(KERNEL_BIN): $(KERNEL_MAIN_SRC) $(COMMANDS_SRC) $(TTY_SRC) $(FS_SRC) $(KEYBOARD_SRC) $(PACKMGR_SRC)
	@echo ASM      $(KERNEL_MAIN_SRC)
	@echo ASM      $(COMMANDS_SRC)
	@echo ASM      $(TTY_SRC)
	@echo ASM      $(FS_SRC)
	@echo ASM      $(KEYBOARD_SRC)
	@echo ASM      $(PACKMGR_SRC)
	@echo BUILD    $@
	$(NASM) $(NASM_FLAGS) $(KERNEL_MAIN_SRC) -o $@

# 创建磁盘镜像
$(OS_IMG): $(BOOT_BIN) $(KERNEL_BIN)
	@echo DD       $@
	$(DD) if=/dev/zero of=$@ bs=512 count=2880 2>nul
	$(DD) if=$(BOOT_BIN) of=$@ bs=512 count=1 conv=notrunc 2>nul
	$(DD) if=$(KERNEL_BIN) of=$@ bs=512 seek=1 conv=notrunc 2>nul
	@echo DD       Done

# 运行
run: $(OS_IMG)
	@echo Starting Omege System 0.1 with $(NPROC) CPU cores...
	$(QEMU) -drive format=raw,file=$(OS_IMG) -m 128 -smp $(NPROC)

# 调试模式
debug: $(OS_IMG)
	@echo Starting in debug mode...
	$(QEMU) -drive format=raw,file=$(OS_IMG) -m 128 -s -S -smp $(NPROC)

# 单核运行
run-single: $(OS_IMG)
	@echo Starting Omege System 0.1 (single core)...
	$(QEMU) -drive format=raw,file=$(OS_IMG) -m 128

# 清理
clean:
	@echo Cleaning build files...
	@if exist $(BUILD_DIR) del /q $(BUILD_DIR)\*.bin 2>nul
	@if exist $(BUILD_DIR) del /q $(BUILD_DIR)\*.img 2>nul
	@echo Clean complete

# 深度清理
distclean: clean
	@echo Removing build directory...
	@if exist $(BUILD_DIR) rmdir /s /q $(BUILD_DIR) 2>nul
	@echo Done

# 帮助
help:
	@echo Omege System 0.1 Makefile
	@echo.
	@echo Targets:
	@echo   all          - Build the OS (default)
	@echo   run          - Run in QEMU with $(NPROC) cores
	@echo   run-single   - Run in QEMU with single core
	@echo   debug        - Run with GDB debug server
	@echo   clean        - Remove build files
	@echo   distclean    - Remove build directory
	@echo   help         - Show this help
	@echo.
	@echo Examples:
	@echo   mingw32-make all
	@echo   mingw32-make run
	@echo   mingw32-make clean

.PHONY: all directories run debug clean distclean help run-single
