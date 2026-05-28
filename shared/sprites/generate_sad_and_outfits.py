#!/usr/bin/env python3
"""Generate sad animation frames + outfit sprites for PlantPal"""

import sys, os, math

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from PIL import Image, ImageDraw
from generate_sprites import *
from generate_animation_frames import (
    shift_image,
    draw_frown,
    draw_sweat,
    make_worried_frame,
    cover_circle,
)

OUT_DIR = os.path.join(os.path.dirname(os.path.abspath(__file__)), "generated")
os.makedirs(OUT_DIR, exist_ok=True)


def draw_tear(d, x, y, c=WATER):
    """Draw a small teardrop"""
    px(d, x, y, c)
    px(d, x - 1, y + 1, c)
    px(d, x, y + 1, c)
    px(d, x + 1, y + 1, c)
    px(d, x, y + 2, c)
    px(d, x, y + 3, c)


def make_sad_frame(base_func, frame_num, total_frames, sprite_num):
    """Create a sad animation frame - slower bob, tears, downturned mouth"""
    img = base_func()
    d = ImageDraw.Draw(img)
    phase = (frame_num - 1) / max(total_frames, 1) * 2 * math.pi

    # Slow sad bob (half amplitude)
    bob_y = int(round(math.sin(phase) * 1.0))
    if bob_y != 0:
        img = shift_image(img, 0, bob_y)
        d = ImageDraw.Draw(img)

    # Frown mouth
    mouth_y_map = {1: 36, 2: 34, 3: 34, 4: 33, 5: 33}
    my = mouth_y_map.get(sprite_num, 34)
    cover_circle(d, 32, my, 2, TRANS)
    draw_frown(d, 32, my)

    # Tears (alternating sides based on frame)
    eye_y_map = {1: 24, 2: 22, 3: 22, 4: 21, 5: 21}
    ey = eye_y_map.get(sprite_num, 22)

    if frame_num % 2 == 1:
        draw_tear(d, 26, ey + 5, WATER)
        draw_tear(d, 27, ey + 8, WATER)
    else:
        draw_tear(d, 37, ey + 5, WATER)
        draw_tear(d, 38, ey + 8, WATER)

    # Sad eyebrow droop
    if sprite_num >= 3:
        for x_off in [-3, -2, -1, 0]:
            px(d, 28 + x_off, ey - 5 + abs(x_off), DKGREY)
        for x_off in [0, 1, 2, 3]:
            px(d, 36 + x_off, ey - 5 + abs(x_off - 3), DKGREY)

    return img


# === Generate sad frames for all 5 sprite levels ===
sad_frame_counts = {1: 4, 2: 4, 3: 4, 4: 4, 5: 4}
base_funcs = {
    1: sprite_1_idle,
    2: sprite_2_idle,
    3: sprite_3_idle,
    4: sprite_4_idle,
    5: sprite_5_idle,
}

for level, count in sad_frame_counts.items():
    for f in range(1, count + 1):
        img = make_sad_frame(base_funcs[level], f, count, level)
        fname = f"sprite_{level}_sad_{f}.png"
        img.save(os.path.join(OUT_DIR, fname))
        print(f"  Generated {fname}")

# === Generate outfit overlay PNGs (64x64 transparent) ===
# Outfits are small pixel accessories that render ON TOP of the sprite


def make_outfit_crown():
    """Small golden crown - sits on top of sprite head"""
    img = Image.new("RGBA", (64, 64), TRANS)
    d = ImageDraw.Draw(img)
    # Crown base
    for x in range(26, 38):
        px(d, x, 10, GOLD)
        px(d, x, 11, GOLD)
        px(d, x, 12, GOLD_D)
    # Crown points
    for x, peak_y in [(26, 7), (29, 5), (32, 4), (35, 5), (38, 7)]:
        px(d, x, peak_y, GOLD_L)
        px(d, x, peak_y + 1, GOLD)
        px(d, x, peak_y + 2, GOLD)
    # Gems
    px(d, 29, 10, RED)
    px(d, 32, 9, WATER)
    px(d, 35, 10, RED)
    return img


def make_outfit_scarf():
    """Red scarf around neck area"""
    img = Image.new("RGBA", (64, 64), TRANS)
    d = ImageDraw.Draw(img)
    # Scarf wrap
    for x in range(22, 42):
        px(d, x, 30, RED)
        px(d, x, 31, RED)
        px(d, x, 32, (200, 50, 50, 255))
    # Scarf tails
    for y in range(32, 42):
        px(d, 25, y, RED)
        px(d, 26, y, (200, 50, 50, 255))
    for y in range(32, 40):
        px(d, 38, y, RED)
        px(d, 39, y, (200, 50, 50, 255))
    return img


def make_outfit_glasses():
    """Round glasses on face"""
    img = Image.new("RGBA", (64, 64), TRANS)
    d = ImageDraw.Draw(img)
    # Left lens
    for angle in range(0, 360, 15):
        x = int(27 + 4 * math.cos(math.radians(angle)))
        y = int(23 + 3 * math.sin(math.radians(angle)))
        px(d, x, y, DKGREY)
    # Right lens
    for angle in range(0, 360, 15):
        x = int(37 + 4 * math.cos(math.radians(angle)))
        y = int(23 + 3 * math.sin(math.radians(angle)))
        px(d, x, y, DKGREY)
    # Bridge
    for x in range(30, 35):
        px(d, x, 23, DKGREY)
    # Temples
    for x in range(22, 28):
        px(d, x, 22, DKGREY)
    for x in range(37, 43):
        px(d, x, 22, DKGREY)
    return img


def make_outfit_wings():
    """Fairy wings on back"""
    img = Image.new("RGBA", (64, 64), TRANS)
    d = ImageDraw.Draw(img)
    # Left wing
    for angle in range(0, 360, 10):
        r = 8
        x = int(14 + r * math.cos(math.radians(angle)))
        y = int(28 + r * 0.7 * math.sin(math.radians(angle)))
        if 0 <= x < 64 and 0 <= y < 64:
            px(d, x, y, (200, 220, 255, 180))
    # Left wing fill
    for angle in range(0, 360, 20):
        r = 5
        x = int(14 + r * math.cos(math.radians(angle)))
        y = int(28 + r * 0.7 * math.sin(math.radians(angle)))
        if 0 <= x < 64 and 0 <= y < 64:
            px(d, x, y, (230, 240, 255, 120))
    # Right wing
    for angle in range(0, 360, 10):
        r = 8
        x = int(50 + r * math.cos(math.radians(angle)))
        y = int(28 + r * 0.7 * math.sin(math.radians(angle)))
        if 0 <= x < 64 and 0 <= y < 64:
            px(d, x, y, (200, 220, 255, 180))
    for angle in range(0, 360, 20):
        r = 5
        x = int(50 + r * math.cos(math.radians(angle)))
        y = int(28 + r * 0.7 * math.sin(math.radians(angle)))
        if 0 <= x < 64 and 0 <= y < 64:
            px(d, x, y, (230, 240, 255, 120))
    return img


def make_outfit_party_hat():
    """Colorful party hat"""
    img = Image.new("RGBA", (64, 64), TRANS)
    d = ImageDraw.Draw(img)
    # Cone
    for row in range(10):
        width = row + 1
        cx = 32
        y = 2 + row
        for x in range(cx - width, cx + width + 1):
            if 0 <= x < 64:
                colors = [
                    GOLD,
                    RED,
                    WATER,
                    YELLOW,
                    PURPLE,
                    ORANGE,
                    P_MID,
                    SKY,
                    GOLD_L,
                    RED,
                ]
                px(d, x, y, colors[row % len(colors)])
    # Pom pom
    px(d, 32, 1, WHITE)
    px(d, 31, 2, WHITE)
    px(d, 32, 2, WHITE)
    px(d, 33, 2, WHITE)
    # Brim
    for x in range(22, 42):
        px(d, x, 12, GOLD)
        px(d, x, 13, GOLD_D)
    return img


def make_outfit_default():
    """Default - just a small star badge"""
    img = Image.new("RGBA", (64, 64), TRANS)
    d = ImageDraw.Draw(img)
    draw_sparkle(d, 48, 18, YELLOW)
    return img


outfits = {
    "outfit_default": make_outfit_default,
    "outfit_crown": make_outfit_crown,
    "outfit_scarf": make_outfit_scarf,
    "outfit_glasses": make_outfit_glasses,
    "outfit_wings": make_outfit_wings,
    "outfit_party_hat": make_outfit_party_hat,
}

for name, func in outfits.items():
    img = func()
    fname = f"{name}.png"
    img.save(os.path.join(OUT_DIR, fname))
    print(f"  Generated {fname}")

print("\nDone! Generated sad frames + outfit PNGs.")
