# Makefile
AS      = nasm
ASFLAGS = -f elf64 -g -F dwarf
LD      = gcc
LDFLAGS = -no-pie

OBJS = \
    bignum.o \
    modexp.o \
    gcd.o \
    rsa_keygen.o \
    rsa_encrypt.o \
    rsa_decrypt.o \
    main.o

all: rsa

%.o: %.asm
	$(AS) $(ASFLAGS) $< -o $@

rsa: $(OBJS)
	$(LD) $(LDFLAGS) -o $@ $(OBJS)

clean:
	rm -f $(OBJS) rsa
