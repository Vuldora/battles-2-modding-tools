import os
import struct
import zlib

JET_PASSWORD = "bJ2thyhRsN69jDD6"

CRC_TABLE = []

for i in range(256):
    entry = i

    for _ in range(8):
        if entry & 1:
            entry = (entry >> 1) ^ 0xEDB88320
        else:
            entry >>= 1

    CRC_TABLE.append(entry)


def update_keys(b, keys):
    k0, key1, key2 = keys

    k0 = (k0 >> 8) ^ CRC_TABLE[(k0 ^ b) & 0xFF]

    key1 = (
        ((key1 + (k0 & 0xFF)) * 0x08088405 + 1)
        & 0xFFFFFFFF
    )

    key2 = (
        (key2 >> 8)
        ^ CRC_TABLE[(key2 ^ (key1 >> 24)) & 0xFF]
    )

    return k0, key1, key2


def init_keys(password):
    keys = (
        0x12345678,
        0x23456789,
        0x34567890
    )

    for b in password.encode("utf-8"):
        keys = update_keys(b, keys)

    return keys


def decrypt_zip_payload(data, password):
    keys = init_keys(password)

    decrypted = bytearray(len(data))

    for i in range(len(data)):
        cipher_byte = data[i]

        temp = (keys[2] & 0xFFFD) | 2
        byte_key = ((temp ^ 1) * temp) >> 8 & 0xFF

        plain_byte = cipher_byte ^ byte_key

        keys = update_keys(plain_byte, keys)
        decrypted[i] = plain_byte

    # Remove the 12-byte encryption header.
    return bytes(decrypted[12:])


# ============================================================================
# JET EXTRACTION
# ============================================================================

def extract_jet(jet_path, target_dir):
    """
    Extract a .jet archive into target_dir.
    """

    print(
        f"[*] Extracting archive "
        f"{os.path.basename(jet_path)}..."
    )

    with open(jet_path, "rb") as f:
        data = f.read()

    os.makedirs(target_dir, exist_ok=True)

    pos = 0

    while pos < len(data):

        # Local file header
        if data[pos:pos + 4] != b"PK\x03\x04":
            break

        flags = struct.unpack(
            "<H",
            data[pos + 6:pos + 8]
        )[0]

        comp_method = struct.unpack(
            "<H",
            data[pos + 8:pos + 10]
        )[0]

        comp_size = struct.unpack(
            "<I",
            data[pos + 18:pos + 22]
        )[0]

        name_len = struct.unpack(
            "<H",
            data[pos + 26:pos + 28]
        )[0]

        extra_len = struct.unpack(
            "<H",
            data[pos + 28:pos + 30]
        )[0]

        file_name = data[
            pos + 30:
            pos + 30 + name_len
        ].decode("utf-8")

        payload_start = (
            pos
            + 30
            + name_len
            + extra_len
        )

        payload_end = payload_start + comp_size

        payload = data[
            payload_start:
            payload_end
        ]

        # Decrypt if the encrypted flag is set.
        if flags & 0x0001:
            payload = decrypt_zip_payload(
                payload,
                JET_PASSWORD
            )

        # Skip directory entries.
        if file_name and not file_name.endswith("/"):

            if comp_method == 8:
                decompressed = zlib.decompress(
                    payload,
                    -15
                )
            else:
                decompressed = payload

            out_path = os.path.join(
                target_dir,
                file_name
            )

            os.makedirs(
                os.path.dirname(out_path),
                exist_ok=True
            )

            with open(out_path, "wb") as out_f:
                out_f.write(decompressed)

        pos = payload_end

    print(
        f"[V] Successfully extracted to: {target_dir}"
    )


# ============================================================================
# COMMAND LINE USAGE
# ============================================================================

if __name__ == "__main__":
    import sys

    if len(sys.argv) != 3:
        print(
            "Usage: python extract_jet.py "
            "<input.jet> <output_directory>"
        )
        sys.exit(1)

    extract_jet(
        sys.argv[1],
        sys.argv[2]
    )
