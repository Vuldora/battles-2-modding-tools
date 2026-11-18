import os
import struct
import zlib
import random


JET_PASSWORD = "bJ2thyhRsN69jDD6"


# ============================================================================
# ZIP CRYPTO
# ============================================================================

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


def encrypt_zip_payload(data, password, file_crc32):
    keys = init_keys(password)

    header = bytearray(
        random.getrandbits(8)
        for _ in range(11)
    )

    # Final encryption-header byte contains the high byte of the CRC.
    header.append(
        (file_crc32 >> 24) & 0xFF
    )

    encrypted = bytearray(
        12 + len(data)
    )

    for i in range(12):
        plain_byte = header[i]

        temp = (keys[2] & 0xFFFD) | 2
        byte_key = ((temp ^ 1) * temp) >> 8 & 0xFF

        encrypted[i] = (
            plain_byte ^ byte_key
        )

        keys = update_keys(
            plain_byte,
            keys
        )

    for i in range(len(data)):
        plain_byte = data[i]

        temp = (keys[2] & 0xFFFD) | 2
        byte_key = ((temp ^ 1) * temp) >> 8 & 0xFF

        encrypted[12 + i] = (
            plain_byte ^ byte_key
        )

        keys = update_keys(
            plain_byte,
            keys
        )

    return bytes(encrypted)


# ============================================================================
# JET ARCHIVING
# ============================================================================

def pack_jet(source_dir, output_jet_path):
    """
    Pack source_dir into a .jet archive.
    """

    print(
        f"[*] Packing {source_dir} "
        f"-> {output_jet_path}"
    )

    entries = []
    all_files = []

    # ------------------------------------------------------------------------
    # Collect files
    # ------------------------------------------------------------------------

    for root, _, files in os.walk(source_dir):

        for file in files:

            full_path = os.path.join(
                root,
                file
            )

            rel_path = os.path.relpath(
                full_path,
                source_dir
            ).replace("\\", "/")

            # These files should not be packed.
            if (
                file == "original_bin_files.txt"
                or file.endswith(".dec")
            ):
                continue

            all_files.append(
                (full_path, rel_path)
            )

    # manifest.txt must be the first entry.
    all_files.sort(
        key=lambda x:
        0 if x[1] == "manifest.txt" else 1
    )

    # ------------------------------------------------------------------------
    # Create archive
    # ------------------------------------------------------------------------

    with open(output_jet_path, "wb") as jet_f:

        for full_path, rel_path in all_files:

            local_offset = jet_f.tell()

            with open(full_path, "rb") as f:
                uncomp_data = f.read()

            crc = zlib.crc32(
                uncomp_data
            ) & 0xFFFFFFFF

            # Raw DEFLATE, matching the original archive format.
            compressor = zlib.compressobj(
                level=9,
                method=zlib.DEFLATED,
                wbits=-15
            )

            comp_data = (
                compressor.compress(uncomp_data)
                + compressor.flush()
            )

            encrypted_data = encrypt_zip_payload(
                comp_data,
                JET_PASSWORD,
                crc
            )

            name_bytes = rel_path.encode("utf-8")

            # ----------------------------------------------------------------
            # Local file header
            # ----------------------------------------------------------------

            jet_f.write(
                b"PK\x03\x04"
            )

            jet_f.write(
                struct.pack(
                    "<HHHHH",
                    20,     # version needed
                    1,      # encrypted
                    8,      # DEFLATED
                    0,      # time
                    0       # date
                )
            )

            jet_f.write(
                struct.pack(
                    "<IIIHH",
                    crc,
                    len(encrypted_data),
                    len(uncomp_data),
                    len(name_bytes),
                    0
                )
            )

            jet_f.write(name_bytes)
            jet_f.write(encrypted_data)

            entries.append({
                "name": rel_path,
                "offset": local_offset,
                "crc": crc,
                "comp_size": len(encrypted_data),
                "uncomp_size": len(uncomp_data)
            })

        # --------------------------------------------------------------------
        # Central directory
        # --------------------------------------------------------------------

        cd_offset = jet_f.tell()

        for entry in entries:

            name_bytes = entry["name"].encode("utf-8")

            jet_f.write(
                b"PK\x01\x02"
            )

            jet_f.write(
                struct.pack(
                    "<HHHHHHIIIHHHHHII",
                    20,
                    20,
                    1,
                    8,
                    0,
                    0,
                    entry["crc"],
                    entry["comp_size"],
                    entry["uncomp_size"],
                    len(name_bytes),
                    0,
                    0,
                    0,
                    0,
                    0,
                    entry["offset"]
                )
            )

            jet_f.write(name_bytes)

        # --------------------------------------------------------------------
        # End of central directory
        # --------------------------------------------------------------------

        cd_size = (
            jet_f.tell()
            - cd_offset
        )

        jet_f.write(
            b"PK\x05\x06"
        )

        jet_f.write(
            struct.pack(
                "<HHHHIIH",
                0,
                0,
                len(entries),
                len(entries),
                cd_size,
                cd_offset,
                0
            )
        )

    print(
        f"[V] Successfully created: "
        f"{output_jet_path}"
    )


# ============================================================================
# COMMAND LINE USAGE
# ============================================================================

if __name__ == "__main__":
    import sys

    if len(sys.argv) != 3:
        print(
            "Usage: python archive_jet.py "
            "<source_directory> <output.jet>"
        )
        sys.exit(1)

    pack_jet(
        sys.argv[1],
        sys.argv[2]
    )
