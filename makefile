# ASM = nasm

# SRC_DIR = src 

# BUILD_DIR = build 


# #.BUILDALL: all floppy_image kernel bootlader clean

# #***********************************************************#
# #                     FLOPPY IMAGE                          #
# #***********************************************************#

# floppy_image: $(BUILD_DIR)/main.img


# $(BUILD_DIR)/main.img: $(BUILD_DIR)/bootloader.bin $(BUILD_DIR)/kernel.bin
# 	dd if=/dev/zero of=$(BUILD_DIR)/main.img bs=512 count=2880
# 	mkfs.fat -F 12 -n "NOVICEOS" $(BUILD_DIR)/main.img
# 	dd if=$(BUILD_DIR)/bootloader.bin of=$(BUILD_DIR)/main.img conv=notrunc
# 	mcopy -i $(BUILD_DIR)/main.img $(BUILD_DIR)/kernel.bin "::kernel.bin" 





# #***********************************************************#
# #                       BOOTLOADER                          #
# #***********************************************************#


# bootloader: $(BUILD_DIR)/bootloader.bin

# $(BUILD_DIR)/bootloader.bin:  $(SRC_DIR)/bootloader/boot.asm
# 	$(ASM) $(SRC_DIR)/bootloader/boot.asm -f bin -o $(BUILD_DIR)/bootloader.bin
# #	$(ASM) $< -f bin -o $@


# #***********************************************************#
# #                         KERNEL                            #
# #***********************************************************#


# kernel: $(BUILD_DIR)/kernel.bin

# $(BUILD_DIR)/kernel.bin: $(SRC_DIR)/kernel/main.asm
# 	$(ASM) $(SRC_DIR)/kernel/main.asm -f bin -o $(BUILD_DIR)/kernel.bin
# #	$(ASM) $< -f bin -o $@








#**********************************
#		check it
#**********************************




ASM = nasm
SRC_DIR = src
BUILD_DIR = build

# Ensure the build directory exists before creating targets
.PHONY: all
all: floppy_image

#***********************************************************#
#                     FLOPPY IMAGE                          #
#***********************************************************#

floppy_image: $(BUILD_DIR)/main.img

$(BUILD_DIR)/main.img: $(BUILD_DIR)/bootloader.bin $(BUILD_DIR)/kernel.bin
	dd if=/dev/zero of=$(BUILD_DIR)/main.img bs=512 count=2880
	mkfs.fat -F 12 -n "NOVICEOS" $(BUILD_DIR)/main.img
	dd if=$(BUILD_DIR)/bootloader.bin of=$(BUILD_DIR)/main.img conv=notrunc
	mcopy -i $(BUILD_DIR)/main.img $(BUILD_DIR)/kernel.bin "::kernel.bin"

#***********************************************************#
#                       BOOTLOADER                          #
#***********************************************************#

bootloader: $(BUILD_DIR)/bootloader.bin

$(BUILD_DIR)/bootloader.bin: $(SRC_DIR)/bootloader/boot.asm
	$(ASM) $< -f bin -o $@

#***********************************************************#
#                         KERNEL                            #
#***********************************************************#

kernel: $(BUILD_DIR)/kernel.bin

$(BUILD_DIR)/kernel.bin: $(SRC_DIR)/kernel/main.asm
	$(ASM) $< -f bin -o $@

# Ensure that the build directory exists
$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

# Include the directory creation as a dependency
$(BUILD_DIR)/bootloader.bin: | $(BUILD_DIR)
$(BUILD_DIR)/kernel.bin: | $(BUILD_DIR)
$(BUILD_DIR)/main.img: | $(BUILD_DIR)
