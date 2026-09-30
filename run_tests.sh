#!/usr/bin/env bash
# Test harness: round-trips every vector in test_vectors.txt through ./rsa,
# then checks that invalid inputs are rejected with the right error.
set -u
cd "$(dirname "$0")"

BIN=./rsa
VECTORS=test_vectors.txt
pass=0
fail=0

note_fail() {
    echo "FAIL: $1"
    fail=$((fail + 1))
}

note_pass() {
    pass=$((pass + 1))
}

# --- positive tests: known-good vectors must round-trip ---
while read -r p q e m expected_c; do
    case "$p" in ''|'#'*) continue ;; esac
    out=$("$BIN" "$p" "$q" "$e" "$m" 2>&1)
    rc=$?
    ct=$(awk '/^ciphertext/ {print $3}' <<<"$out")
    rec=$(awk '/^recovered/ {print $3}' <<<"$out")
    if [[ $rc -ne 0 ]]; then
        note_fail "p=$p q=$q e=$e m=$m exited with $rc: $out"
    elif [[ "$ct" != "$expected_c" ]]; then
        note_fail "p=$p q=$q e=$e m=$m: ciphertext $ct, expected $expected_c"
    elif [[ "$rec" != "$m" ]]; then
        note_fail "p=$p q=$q e=$e m=$m: recovered $rec, expected $m"
    else
        note_pass
    fi
done < "$VECTORS"

# --- default run (no arguments) must use the textbook example ---
out=$("$BIN" 2>&1)
if [[ $? -eq 0 ]] && grep -q '^ciphertext = 2790$' <<<"$out" && grep -q 'round-trip OK' <<<"$out"; then
    note_pass
else
    note_fail "default run: $out"
fi

# --- negative tests: bad inputs must be rejected on stderr with exit != 0 ---
expect_error() {
    local desc=$1 pattern=$2
    shift 2
    local err rc
    err=$("$BIN" "$@" 2>&1 >/dev/null)
    rc=$?
    if [[ $rc -eq 0 ]]; then
        note_fail "$desc: expected nonzero exit"
    elif ! grep -q "$pattern" <<<"$err"; then
        note_fail "$desc: expected \"$pattern\", got: $err"
    else
        note_pass
    fi
}

expect_error "composite p"        "p (15) is not prime"        15 53 17 65
expect_error "composite q"        "q (91) is not prime"        61 91 17 65
expect_error "p == q"             "must be distinct"           61 61 17 65
expect_error "e not coprime"      "not coprime"                61 53 16 65
expect_error "message too large"  "must be smaller than n"     61 53 17 5000
expect_error "n overflows"        "overflows 64 bits"          18446744073709551557 18446744073709551533 17 65
expect_error "wrong arg count"    "usage:"                     61 53 17

echo
echo "passed: $pass, failed: $fail"
[[ $fail -eq 0 ]]
