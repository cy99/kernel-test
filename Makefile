CC = gcc
LD = ld
AS = as
LDFILE = ld_script.ld
OBJCOPY = objcopy
DUMP = objdump
DUMP_FLAGS = -D -b binary -mi386 -M addr16 -M data16

ASM_SRC = $(wildcard *.s)
ASM_OBJ = $(patsubst %.s, %.o, $(ASM_SRC))
ASM_ELF = $(patsubst %.s, %.elf, $(ASM_SRC))
ASM_BIN = $(patsubst %.s, %.bin, $(ASM_SRC))
ASM_DMP = $(patsubst %.s, %.dmp, $(ASM_SRC))


.PHONY: all clean dump

all: linux.img

dump: $(ASM_DMP)

# @dd if=/dev/zero of=$@ seek=2 bs=512 count=2878

linux.img: $(ASM_BIN)
	@dd if=bootsect.bin of=$@ bs=512 count=1
	@dd if=setup.bin of=$@ seek=1 bs=512 count=4
	@dd if=hellosect.bin of=$@ seek=5 bs=512 count=1
	@dd if=/dev/zero of=$@ seek=6 bs=512 count=2874

$(ASM_BIN): %.bin: %.elf
	@$(OBJCOPY) -R .pdr -R .comment -R .note -S -O binary $< $@

$(ASM_ELF): %.elf: %.o
	$(LD) $< -o $@ -T$(LDFILE)

$(ASM_OBJ): %.o: %.s
	$(AS) $< -o $@


$(ASM_DMP): %.dmp: %.bin
	$(DUMP)  $(DUMP_FLAGS) $< > $@

clean:
	@rm -rf $(ASM_OBJ) $(ASM_ELF) $(ASM_BIN) $(ASM_DMP) linux.img
