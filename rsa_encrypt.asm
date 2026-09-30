; rsa_encrypt.asm — encryption wrapper
section .text
global rsa_encrypt
extern modexp

; uint64_t rsa_encrypt(uint64_t msg, uint64_t e, uint64_t n)
; c = msg^e mod n. Arguments are already in the registers modexp
; expects, so this is a pure tail call.
rsa_encrypt:
    jmp modexp

section .note.GNU-stack noalloc noexec nowrite progbits
