import argparse
import os
import struct
from pathlib import Path

from PIL import Image

JPNG_STRUCT = "<IIHBBI"


def quality(value):
    i = int(value)
    if not (1 <= i <= 100):
        raise argparse.ArgumentTypeError(f"value must be between [1, 100]; (got {i})")
    return i

def main():
    parser = argparse.ArgumentParser(description="png2jpng")
    parser.add_argument("input")
    parser.add_argument("output")
    parser.add_argument("-q", "--quality", type=quality, metavar="[1, 100]")
    parser.add_argument("-o", "--overwrite", action="store_true", help="Overwrite output file")
    args = parser.parse_args()

    if not args.overwrite and Path(args.output).is_file():
        raise FileExistsError("Output file already exists!")

    with Image.open(args.input) as rgba:
        alpha: Image.Image = rgba.getchannel("A")

        rgb = rgba.convert("RGB")
        rgb.save(args.output, "jpeg", quality=args.quality)

        output_file = open(args.output, "ab")
        image_size = os.fstat(output_file.fileno()).st_size

        alpha.save(output_file, "png", compress_level=9)
        alpha.save("alpha.png")
        mask_size = os.fstat(output_file.fileno()).st_size - image_size

        footer = struct.pack(
            JPNG_STRUCT,
            image_size,
            mask_size,
            0x10,
            0x01,
            0x00,
            int.from_bytes(b"GNPJ", byteorder="little")
        )
        output_file.write(footer)


if __name__ == "__main__":
    main()
