#!/usr/bin/env bash
# Strip the recursive-proving stack (ClientIVC/Chonk, Goblin, ECCVM, Translator,
# Hypernova, Mega) from a libswoirenberg.a. On-device proving is UltraHonk-only, so
# this code is never called; a few bbapi/ACIR entry points still reference it at link
# time, so we delete the objects and satisfy those refs with trap stubs (~5MB off).
#
# Usage: strip-recursive-proving.sh <libswoirenberg.a> <arch> <sdk>
#   arch: arm64 | x86_64   sdk: iphoneos | iphonesimulator | macosx
set -euo pipefail
LIB="${1:?lib path}"; ARCH="${2:?arch (arm64|x86_64)}"; SDK="${3:?sdk}"
case "$SDK" in
  iphoneos)        MINFLAG="-mios-version-min=15.2" ;;
  iphonesimulator) MINFLAG="-mios-simulator-version-min=15.2" ;;
  macosx)          MINFLAG="-mmacosx-version-min=13.0" ;;
  *) echo "unknown sdk $SDK" >&2; exit 1 ;;
esac
PAT='eccvm|translator|chonk|goblin|hypernova|op_queue|databus|merge_prover|merge_verifier|batch_merge|_mega|mega_|protogalaxy|ivc'

objs=$(ar t "$LIB" | grep -iE "$PAT" || true)
[ -z "$objs" ] && { echo "strip-recursive: no recursive objects in $LIB"; exit 0; }
printf '%s\n' "$objs" | while IFS= read -r o; do [ -n "$o" ] && ar d "$LIB" "$o"; done
ranlib "$LIB"

# Symbols referenced but no longer defined anywhere (their defining object was
# deleted). Stub ONLY these: a symbol still defined by a kept object (e.g.
# create_recursion_constraints, which UltraHonk proving genuinely uses) must stay
# real, or the linker would pick the trap stub over the real definition and crash.
# (nm can exit non-zero with benign warnings on the just-modified archive, and comm
# is picky about sort order, so tolerate both.)
syms=$(nm "$LIB" 2>/dev/null || true)
defs=$(printf '%s\n' "$syms" | grep -E '^[0-9a-f]+ [A-Za-z] ' | awk '{print $3}' | sort -u || true)
undef=$(printf '%s\n' "$syms" | grep -E '^ *U ' | awk '{print $2}' | sort -u || true)
und=$(printf '%s\n' "$undef" | grep -Fxv -f <(printf '%s\n' "$defs") || true)
[ -z "$und" ] && { echo "strip-recursive: nothing to stub"; exit 0; }

case "$ARCH" in
  arm64)  trap_insn='brk #0x1' ;;
  x86_64) trap_insn='ud2' ;;
  *) echo "unknown arch $ARCH" >&2; exit 1 ;;
esac
tmp=$(mktemp -d)
{ echo ".text"; echo ".p2align 2"
  printf '%s\n' "$und" | while IFS= read -r s; do
    [ -z "$s" ] && continue; printf '.globl %s\n%s:\n    %s\n' "$s" "$s" "$trap_insn"
  done
} > "$tmp/stub.s"
xcrun -sdk "$SDK" clang -arch "$ARCH" $MINFLAG -c "$tmp/stub.s" -o "$tmp/stub.o"
ar q "$LIB" "$tmp/stub.o"; ranlib "$LIB"
rm -rf "$tmp"
echo "strip-recursive: stripped $(printf '%s\n' "$objs" | grep -c . ) objects, stubbed $(printf '%s\n' "$und" | grep -c .) symbols in $LIB"
