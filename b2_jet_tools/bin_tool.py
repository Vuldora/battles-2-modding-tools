#!/usr/bin/env python3

from pathlib import Path
import argparse
import os
import struct
import sys
import zlib


# %BIN_2.0 encryption constants
KEY_BIN = b"Es_wZek8q+$XZx=d"
SALT_DWORD = 0x775f7345
MAGIC = b"%BIN_2.0"
MODULUS = 2147483647


def make_keystream(file_size: int) -> bytearray:
    """
    Reproduce the original %BIN_2.0 keystream generation.

    file_size is the size used by the original format:
        encrypted file size = plaintext size + 8
    """
    seed = (file_size ^ SALT_DWORD) % MODULUS

    if seed == 0:
        seed = 1

    state = seed
    keystream = bytearray()

    for i in range(8):
        state = (state * 48271) % MODULUS

        if i % 2 == 0:
            keystream.extend(struct.pack("<I", state))

    for i in range(16):
        keystream[i] ^= KEY_BIN[i]

    return keystream


def encrypt_bin_data(plain_bytes: bytes, compress: bool = False) -> bytes:
    """Encrypt raw bytes into the original %BIN_2.0 format."""

    if compress:
        plain_bytes = zlib.compress(plain_bytes)

    file_size = len(plain_bytes) + 8
    keystream = make_keystream(file_size)

    ciphertext = bytearray(len(plain_bytes))

    for i, plain_byte in enumerate(plain_bytes):
        keystream_byte = keystream[15 - (i % 16)]

        ciphertext[i] = (
            ((i * 2) % 256)
            ^ keystream_byte
            ^ plain_byte
        )

    return MAGIC + bytes(ciphertext)


def decrypt_bin_data(file_data: bytes):
    """
    Decrypt a %BIN_2.0 file.

    Returns:
        (decrypted_bytes, was_compressed)

    The original implementation does not actually validate the magic,
    so this tool validates it before attempting decryption.
    """
    if not file_data.startswith(MAGIC):
        raise ValueError("file does not start with %BIN_2.0")

    file_size = len(file_data)
    keystream = make_keystream(file_size)

    decrypted = bytearray(file_size - 8)

    for i in range(file_size - 8):
        keystream_byte = keystream[15 - (i % 16)]

        decrypted[i] = (
            ((i * 2) % 256)
            ^ keystream_byte
            ^ file_data[8 + i]
        )

    decrypted = bytes(decrypted)

    # Same compression detection used by the original code.
    was_compressed = decrypted.startswith(b"\x78")

    if was_compressed:
        try:
            decrypted = zlib.decompress(decrypted)
        except zlib.error as exc:
            raise ValueError(
                f"decrypted data appears compressed, but zlib decompression failed: {exc}"
            ) from exc

    return decrypted, was_compressed


def process_file(
    input_path: Path,
    output_path: Path,
    mode: str,
    compress: bool = False,
):
    with input_path.open("rb") as f:
        data = f.read()

    if mode == "encrypt":
        result = encrypt_bin_data(data, compress=compress)
    else:
        result, _ = decrypt_bin_data(data)

    output_path.parent.mkdir(parents=True, exist_ok=True)

    # Write atomically when overwriting a file.
    if input_path.resolve() == output_path.resolve():
        temp_path = output_path.with_name(output_path.name + ".tmp")
        try:
            with temp_path.open("wb") as f:
                f.write(result)
            os.replace(temp_path, output_path)
        finally:
            if temp_path.exists():
                temp_path.unlink()
    else:
        with output_path.open("wb") as f:
            f.write(result)


def get_files(path: Path):
    if path.is_file():
        yield path
    elif path.is_dir():
        # Recursive, deterministic traversal.
        for file_path in sorted(path.rglob("*")):
            if file_path.is_file():
                yield file_path
    else:
        raise FileNotFoundError(f"not found: {path}")


def process_path(
    input_path: Path,
    output_path: Path | None,
    mode: str,
    compress: bool,
):
    files = list(get_files(input_path))

    if input_path.is_file():
        destination = output_path if output_path else input_path

        process_file(
            input_path,
            destination,
            mode,
            compress,
        )

        print(f"[V] {mode}: {input_path} -> {destination}")
        return

    # Directory mode.
    for source_file in files:
        relative = source_file.relative_to(input_path)

        if output_path is None:
            # No output directory means modify files in place.
            destination = source_file
        else:
            destination = output_path / relative

        try:
            process_file(
                source_file,
                destination,
                mode,
                compress,
            )

            print(f"[V] {mode}: {source_file} -> {destination}")

        except ValueError as exc:
            # In decrypt mode, directories may contain non-BIN files.
            # Skip them rather than stopping the entire recursive operation.
            if mode == "decrypt":
                print(f"[!] Skipping {source_file}: {exc}")
            else:
                raise


def main():
    parser = argparse.ArgumentParser(
        description=(
            "Encrypt/decrypt files using the original %BIN_2.0 algorithm "
            "from the supplied code."
        )
    )

    mode = parser.add_mutually_exclusive_group(required=True)
    mode.add_argument(
        "-e",
        "--encrypt",
        action="store_true",
        help="encrypt the input file/directory",
    )
    mode.add_argument(
        "-d",
        "--decrypt",
        action="store_true",
        help="decrypt the input file/directory",
    )

    parser.add_argument(
        "input",
        type=Path,
        help="input file or directory",
    )

    parser.add_argument(
        "-o",
        "--output",
        type=Path,
        help=(
            "output file/directory. If omitted, files are modified in place."
        ),
    )

    parser.add_argument(
        "-c",
        "--compress",
        action="store_true",
        help=(
            "compress before encryption using zlib. "
            "This matches encrypt_bin_data(..., compress=True)."
        ),
    )

    args = parser.parse_args()

    input_path = args.input.resolve()
    output_path = args.output.resolve() if args.output else None
    operation = "encrypt" if args.encrypt else "decrypt"

    if not input_path.exists():
        print(f"[-] Input does not exist: {input_path}", file=sys.stderr)
        return 1

    if output_path is not None:
        if input_path.is_file() and output_path.exists() and output_path.is_dir():
            print(
                "[-] For a single input file, --output must be a file path.",
                file=sys.stderr,
            )
            return 1

        if input_path.is_dir() and output_path.exists() and output_path.is_file():
            print(
                "[-] For a directory input, --output must be a directory path.",
                file=sys.stderr,
            )
            return 1

    try:
        process_path(
            input_path,
            output_path,
            operation,
            args.compress,
        )
    except (OSError, ValueError) as exc:
        print(f"[-] Error: {exc}", file=sys.stderr)
        return 1

    print("[+] Done.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
