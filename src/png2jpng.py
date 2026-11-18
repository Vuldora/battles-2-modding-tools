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

def png_to_jpng(input_path, output_path, quality, overwrite):
    if not overwrite and Path(output_path).is_file():
        raise FileExistsError("Output file already exists!")

    with Image.open(input_path) as rgba:
        alpha: Image.Image = rgba.getchannel("A")

        rgb = rgba.convert("RGB")
        rgb.save(output_path, "jpeg", quality=quality)

        output_file = open(output_path, "ab")
        image_size = os.fstat(output_file.fileno()).st_size

        alpha.save(output_file, "png", compress_level=9)
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

def main():
    parser = argparse.ArgumentParser(description="png2jpng")
    parser.add_argument("input")
    parser.add_argument("output")
    parser.add_argument("-q", "--quality", type=quality, metavar="[1, 100]", default=100)
    parser.add_argument("-o", "--overwrite", action="store_true", help="Overwrite output file")
    args = parser.parse_args()

    png_to_jpng(args.input, args.output, args.quality, args.overwrite)




if __name__ == "__main__":
    main()
