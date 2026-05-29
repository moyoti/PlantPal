from PIL import Image, ImageDraw
import os, math

SIZE = 48
IOS = "/Users/jenkins3/Documents/dqh/AIGenPrj/ios/PlantPal/PlantPal/Resources/Sprites"
AND = "/Users/jenkins3/Documents/dqh/AIGenPrj/android/app/src/main/res/drawable"

os.makedirs(IOS, exist_ok=True)
os.makedirs(AND, exist_ok=True)


def px(d, x, y, c):
    if 0 <= x < SIZE and 0 <= y < SIZE:
        d.point((x, y), fill=c)


def rect(d, x1, y1, x2, y2, c):
    for y in range(max(0, y1), min(SIZE, y2 + 1)):
        for x in range(max(0, x1), min(SIZE, x2 + 1)):
            d.point((x, y), fill=c)


def circ(d, cx, cy, r, c):
    for y in range(max(0, cy - r), min(SIZE, cy + r + 1)):
        for x in range(max(0, cx - r), min(SIZE, cx + r + 1)):
            if (x - cx) ** 2 + (y - cy) ** 2 <= r * r:
                d.point((x, y), fill=c)


C = {
    "g": (76, 175, 80),
    "gd": (56, 142, 60),
    "gl": (129, 199, 132),
    "b": (66, 165, 245),
    "bd": (30, 136, 229),
    "bl": (144, 202, 249),
    "y": (255, 213, 79),
    "yd": (255, 193, 7),
    "yl": (255, 236, 179),
    "br": (141, 110, 99),
    "brd": (109, 76, 65),
    "brl": (188, 170, 164),
    "p": (236, 64, 122),
    "pl": (248, 187, 208),
    "pu": (156, 39, 176),
    "pul": (206, 147, 216),
    "o": (255, 152, 0),
    "ol": (255, 204, 128),
    "r": (244, 67, 54),
    "rl": (239, 154, 154),
    "cr": (255, 248, 225),
    "w": (255, 255, 255),
    "bk": (33, 33, 33),
    "gy": (158, 158, 158),
    "gyl": (224, 224, 224),
    "gd2": (255, 215, 0),
    "t": (0, 150, 136),
    "tl": (128, 203, 196),
}


def save(img, name):
    img.save(os.path.join(IOS, f"{name}.png"))
    img.save(os.path.join(AND, f"{name}.png"))
    print(f"Saved {name}.png")
