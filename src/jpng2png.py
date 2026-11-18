import argparse
import io
import struct
from pathlib import Path

from PIL import Image

JPNG_STRUCT = "<IIHBBI"
PNG_HEADER = b"\x89PNG\x0D\x0A\x1A\x0A"

IMAGE_SIZE_IDX = 0
IDENTIFIER_IDX = 5


def split_jpng(path, index):
    with open(path, "rb") as file:
        file.seek(0)
        bytes_ = file.read()
        return (bytes_[:index], bytes_[index:])


def main():
    parser = argparse.ArgumentParser(description="png2jpng")
    parser.add_argument("input")
    parser.add_argument("output")
    parser.add_argument("-o", "--overwrite", action="store_true", help="Overwrite output file")
    args = parser.parse_args()

    if not args.overwrite and Path(args.output).is_file():
        raise FileExistsError("Output file already exists!")

    with open(args.input, "rb") as f:
        f.seek(-16, io.SEEK_END)
        data = struct.unpack(JPNG_STRUCT, f.read(16))

        if data[IDENTIFIER_IDX] != int.from_bytes(b"GNPJ", byteorder="little"):
            raise Exception(f"{args.input} is not a jpng file!")

    (jpeg, png) = split_jpng(args.input, data[IMAGE_SIZE_IDX])

    with Image.open(io.BytesIO(jpeg), formats=["jpeg"]) as rgb, Image.open(io.BytesIO(png), formats=["png"]) as alpha:
        rgb.putalpha(alpha)
        rgb.save(args.output)


if __name__ == "__main__":
    main()
