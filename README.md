

# RSA Assembly Project

This is a pure x86-64 NASM assembly demonstration of RSA key generation, encryption, and decryption using small 64-bit integers for clarity. It implements core number-theoretic algorithms such as modular multiplication, fast modular exponentiation, and the extended Euclidean algorithm entirely in assembly. The implementation is intended for educational purposes only and is not cryptographically secure.

## Files

* `bignum.asm` Modular multiply
* `modexp.asm` Modular exponentiation (square-and-multiply)
* `gcd.asm` Extended GCD and modular inverse
* `rsa_keygen.asm` Key generation (`n`, `d`)
* `rsa_encrypt.asm` Encryption wrapper
* `rsa_decrypt.asm` Decryption wrapper
* `main.asm` Orchestrates calls and prints results
* `Makefile` Build script
* `test_vectors.txt` Known small-prime test values

## Build

```bash
make
```

## Run

```bash
./rsa
```

### Expected Output

```
n = 3233
d = 2753
Original message: 65
Encrypting with e=17, n=3233
Ciphertext: 2790
Plaintext: 65
```

## Notes

* This code is for demonstration and learning. It uses small integer parameters and is not secure for real encryption.
* The modular arithmetic routines can be extended to handle large integers for realistic RSA.

## License

MIT
