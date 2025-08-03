# RSA Assembly Project

This is a pure-Assembly demonstration of RSA (small primes only, 64-bit math).

## Files

- **bignum.asm** Modular multiply
- **modexp.asm** Modular exponentiation
- **gcd.asm** Extended GCD & modular inverse
- **rsa_keygen.asm** Key generation (`n`, `d`)
- **rsa_encrypt.asm** Encryption wrapper
- **rsa_decrypt.asm** Decryption wrapper
- **main.asm** Orchestrates calls & prints results
- **Makefile**
- **test_vectors.txt** Known small-prime test values

## Build

```bash
make
