#!/usr/bin/env python3
"""Generate 11 pixel art interaction icons for PlantPal."""

from PIL import Image, ImageDraw

SIZE = 32


def make_icon(name, draw_func):
    img = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    draw_func(d)
    img.save(f"generated/icon_{name}.png")
    print(f"  icon_{name}.png")


def px(d, x, y, color):
    d.point([(x, y)], fill=color)


def rect(d, x1, y1, x2, y2, color):
    for x in range(x1, x2 + 1):
        for y in range(y1, y2 + 1):
            px(d, x, y, color)


WATER = (66, 165, 245)
WATER_D = (30, 120, 200)
SUN = (255, 213, 79)
SUN_D = (255, 183, 30)
EARTH = (141, 110, 99)
EARTH_D = (100, 75, 65)
PINK = (236, 64, 122)
PINK_D = (180, 30, 90)
PURPLE = (156, 39, 176)
PURPLE_D = (120, 20, 140)
GREEN = (102, 187, 106)
GREEN_D = (60, 140, 65)
ORANGE = (255, 152, 0)
ORANGE_D = (200, 110, 0)
RED = (244, 67, 54)
RED_D = (190, 30, 25)
WHITE = (255, 255, 255)
BROWN = (161, 136, 127)


# Water drop
def draw_water(d):
    for y in range(8, 26):
        hw = min(y - 8, 25 - y) // 2 + 1
        cx = 16
        for x in range(cx - hw, cx + hw + 1):
            px(d, x, y, WATER if x < cx else WATER_D)
    px(d, 15, 7, WATER)
    px(d, 16, 7, WATER_D)
    px(d, 16, 6, WATER)
    for y in range(14, 20):
        px(d, 13, y, WHITE)


# Sun
def draw_light(d):
    for y in range(11, 21):
        for x in range(11, 21):
            px(d, x, y, SUN if (x + y) % 2 == 0 else SUN_D)
    for i in range(4):
        cx, cy = 16, 16
        dx = [0, 1, 0, -1][i]
        dy = [-1, 0, 1, 0][i]
        for j in range(4, 7):
            px(d, cx + dx * j, cy + dy * j, SUN)
    for i in range(4):
        dx2 = [1, 1, -1, -1][i]
        dy2 = [-1, 1, 1, -1][i]
        px(d, 16 + dx2 * 4, 16 + dy2 * 4, SUN)
        px(d, 16 + dx2 * 5, 16 + dy2 * 5, SUN_D)


# Leaf
def draw_fertilize(d):
    for y in range(10, 23):
        w = min(y - 10, 22 - y) + 1
        for x in range(16 - w, 16 + w + 1):
            px(d, x, y, GREEN if x <= 16 else GREEN_D)
    for y in range(7, 18):
        px(d, 16, y, BROWN)
    for y in range(18, 24):
        px(d, 16, y, EARTH_D)
    for x in range(13, 20):
        px(d, x, 23, EARTH)


# Hand
def draw_touch(d):
    for y in range(10, 24):
        for x in range(10, 22):
            px(d, x, y, PINK if x < 16 else PINK_D)
    for y in range(6, 10):
        for x in range(12, 16):
            px(d, x, y, PINK)
    px(d, 14, 8, WHITE)
    px(d, 15, 9, WHITE)


# Speech bubble
def draw_talk(d):
    for y in range(8, 20):
        for x in range(8, 25):
            px(d, x, y, WHITE)
    for y in range(8, 20):
        px(d, 8, y, PURPLE)
        px(d, 24, y, PURPLE)
    for x in range(8, 25):
        px(d, x, 8, PURPLE)
        px(d, x, 19, PURPLE)
    px(d, 10, 13, PURPLE)
    px(d, 10, 14, PURPLE)
    px(d, 13, 13, PURPLE)
    px(d, 13, 14, PURPLE)
    px(d, 16, 13, PURPLE)
    px(d, 16, 14, PURPLE)
    px(d, 10, 20, PURPLE)
    px(d, 11, 21, PURPLE)


# Music note
def draw_sing(d):
    for y in range(18, 25):
        for x in range(8, 14):
            px(d, x, y, PINK)
    for y in range(6, 19):
        px(d, 13, y, PINK_D)
        px(d, 14, y, PINK_D)
    for y in range(6, 9):
        for x in range(14, 23):
            px(d, x, y, PINK)
    px(d, 22, 9, PINK)
    px(d, 22, 10, PINK)


# Cross/heal
def draw_heal(d):
    for y in range(8, 24):
        for x in range(13, 19):
            px(d, x, y, GREEN if x < 16 else GREEN_D)
    for y in range(13, 19):
        for x in range(8, 24):
            px(d, x, y, GREEN if x < 16 else GREEN_D)
    px(d, 14, 10, WHITE)
    px(d, 15, 11, WHITE)


# Game controller
def draw_play(d):
    for y in range(12, 22):
        for x in range(6, 27):
            px(d, x, y, ORANGE if x < 16 else ORANGE_D)
    for y in range(10, 12):
        for x in range(10, 22):
            px(d, x, y, ORANGE)
    px(d, 9, 14, WHITE)
    px(d, 9, 15, WHITE)
    px(d, 9, 16, WHITE)
    px(d, 8, 15, WHITE)
    px(d, 9, 15, WHITE)
    px(d, 10, 15, WHITE)
    for x in range(18, 23):
        for y in range(14, 17):
            px(d, x, y, WHITE)


# Shield
def draw_shield(d):
    for y in range(6, 26):
        hw = min(y - 6, 25 - y) + 2
        for x in range(16 - hw, 16 + hw + 1):
            px(d, x, y, WATER if x < 16 else WATER_D)
    for y in range(9, 23):
        hw2 = min(y - 9, 22 - y)
        for x in range(16 - hw2, 16 + hw2 + 1):
            px(d, x, y, WHITE if (x + y) % 3 != 0 else (200, 230, 255))


# Dancing figure
def draw_dance(d):
    for y in range(6, 10):
        for x in range(14, 18):
            px(d, x, y, PINK)
    for y in range(10, 18):
        px(d, 15, y, PINK_D)
        px(d, 16, y, PINK_D)
    px(d, 12, 12, PINK)
    px(d, 13, 13, PINK)
    px(d, 14, 14, PINK)
    px(d, 18, 12, PINK_D)
    px(d, 19, 11, PINK_D)
    px(d, 20, 10, PINK_D)
    px(d, 12, 18, PINK)
    px(d, 11, 19, PINK)
    px(d, 19, 18, PINK_D)
    px(d, 20, 17, PINK_D)
    px(d, 14, 10, PINK)
    px(d, 17, 10, PINK)


# Brush/comb for pet
def draw_pet(d):
    for y in range(8, 24):
        for x in range(14, 18):
            px(d, x, y, BROWN if x < 16 else EARTH_D)
    for y in range(6, 14):
        for x in range(8, 14):
            px(d, x, y, PINK if y % 3 != 0 else PINK_D)
    for x in range(8, 14):
        px(d, x, 5, PINK_D)


import os

os.makedirs("generated", exist_ok=True)

make_icon("water", draw_water)
make_icon("light", draw_light)
make_icon("fertilize", draw_fertilize)
make_icon("touch", draw_touch)
make_icon("talk", draw_talk)
make_icon("sing", draw_sing)
make_icon("heal", draw_heal)
make_icon("play", draw_play)
make_icon("shield", draw_shield)
make_icon("dance", draw_dance)
make_icon("pet", draw_pet)

print("Done! 11 pixel art icons generated.")
