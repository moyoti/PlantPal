#!/usr/bin/env python3
"""PlantPal Animation Frame Generator

Generates multi-frame sprite animation PNGs by applying pixel-level
modifications to the base sprites from generate_sprites.py.

Frame counts match iOS Animations.swift references exactly.
"""

import sys
import os
import math
import shutil

# Ensure we can import from the same directory
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from PIL import Image, ImageDraw

# Import everything from the base generator
from generate_sprites import (
    OUT,
    TRANS,
    G_DARK,
    G_MID,
    G_LIGHT,
    G_PALE,
    P_DARK,
    P_MID,
    P_LIGHT,
    SKIN,
    EYE_D,
    EYE_W,
    BLUSH,
    MOUTH,
    BR_DARK,
    BR_MID,
    BR_LIGHT,
    GOLD,
    GOLD_D,
    GOLD_L,
    YELLOW,
    ORANGE,
    WATER,
    SKY,
    WHITE,
    BLACK,
    SOIL_D,
    SOIL_L,
    PURPLE,
    PURPLE_L,
    PURPLE_D,
    RED,
    GREY,
    DKGREY,
    DKGREEN,
    new_img,
    px,
    rect,
    circle,
    draw_eyes,
    draw_closed_eyes,
    draw_blush,
    draw_mouth,
    draw_smile,
    draw_sparkle,
    draw_zzz,
    sprite_1_idle,
    sprite_2_idle,
    sprite_3_idle,
    sprite_4_idle,
    sprite_5_idle,
    sprite_1_sleep,
    sprite_2_sleep,
    sprite_3_sleep,
    sprite_4_sleep,
    sprite_5_sleep,
    plant_seed,
    plant_sprout,
    plant_bud,
    plant_bloom,
    plant_fruit,
    pot_default,
    pot_ceramic,
    pot_wooden,
    pot_golden,
    pot_crystal,
    bg_garden,
    bg_forest,
    bg_beach,
    bg_night,
    bg_rainbow,
    save,
)


def shift_image(img, dx, dy):
    w, h = img.size
    out = Image.new("RGBA", (w, h), TRANS)
    out.paste(img, (dx, dy))
    return out


def cover_circle(d, cx, cy, r, c):
    for dy in range(-r, r + 1):
        for dx in range(-r, r + 1):
            if dx * dx + dy * dy <= r * r:
                if 0 <= cx + dx < 64 and 0 <= cy + dy < 64:
                    d.point((cx + dx, cy + dy), fill=c)


def draw_sweat(d, x, y, c=WATER):
    px(d, x, y, c)
    px(d, x - 1, y + 1, c)
    px(d, x, y + 1, c)
    px(d, x + 1, y + 1, c)
    px(d, x - 1, y + 2, c)
    px(d, x, y + 2, c)
    px(d, x + 1, y + 2, c)
    px(d, x, y + 3, c)


def draw_frown(d, cx, cy):
    px(d, cx - 1, cy + 1, MOUTH)
    px(d, cx, cy, MOUTH)
    px(d, cx + 1, cy + 1, MOUTH)


def draw_star(d, x, y, c=YELLOW):
    px(d, x, y - 2, c)
    px(d, x - 1, y - 1, c)
    px(d, x, y - 1, c)
    px(d, x + 1, y - 1, c)
    px(d, x - 2, y, c)
    px(d, x - 1, y, c)
    px(d, x, y, c)
    px(d, x + 1, y, c)
    px(d, x + 2, y, c)
    px(d, x - 1, y + 1, c)
    px(d, x, y + 1, c)
    px(d, x + 1, y + 1, c)
    px(d, x, y + 2, c)


def draw_big_sparkle(d, x, y, c=YELLOW):
    draw_sparkle(d, x, y, c)
    px(d, x, y - 2, c)
    px(d, x - 2, y, c)
    px(d, x + 2, y, c)
    px(d, x, y + 2, c)


def make_idle_frame(base_func, frame_num, total_frames):
    img = base_func()
    d = ImageDraw.Draw(img)
    phase = (frame_num - 1) / total_frames * 2 * math.pi
    bob_y = int(round(math.sin(phase) * 1.5))
    if bob_y != 0:
        img = shift_image(img, 0, bob_y)
        d = ImageDraw.Draw(img)
    sparkle_positions = [
        (20, 18),
        (44, 20),
        (16, 36),
        (48, 38),
        (24, 14),
        (40, 16),
        (12, 28),
        (52, 30),
        (22, 10),
        (42, 12),
    ]
    idx = (frame_num - 1) % len(sparkle_positions)
    if frame_num % 2 == 1:
        sx, sy = sparkle_positions[idx]
        sx = max(2, min(61, sx))
        sy = max(2, min(61, sy))
        draw_sparkle(d, sx, sy, G_LIGHT if frame_num % 3 == 1 else YELLOW)
    shift_x = int(round(math.cos(phase) * 0.5))
    if shift_x != 0 and frame_num <= 2:
        for y_pos in [20, 22, 24]:
            px(d, 32 + shift_x * 2, y_pos, YELLOW)
    return img


def make_happy_frame(base_func, frame_num, total_frames, sprite_num):
    img = base_func()
    d = ImageDraw.Draw(img)
    phase = (frame_num - 1) / total_frames * 2 * math.pi
    bounce_y = int(round(math.sin(phase) * 3.5))
    if bounce_y != 0:
        img = shift_image(img, 0, bounce_y)
        d = ImageDraw.Draw(img)
    mouth_y_map = {1: 36, 2: 34, 3: 34, 4: 33, 5: 33}
    mouth_y = mouth_y_map.get(sprite_num, 34)
    cover_circle(d, 32, mouth_y, 2, TRANS)
    px(d, 30, mouth_y, MOUTH)
    px(d, 31, mouth_y + 1, MOUTH)
    px(d, 32, mouth_y + 2, MOUTH)
    px(d, 33, mouth_y + 1, MOUTH)
    px(d, 34, mouth_y, MOUTH)
    px(d, 26, mouth_y - 4, BLUSH)
    px(d, 27, mouth_y - 4, BLUSH)
    px(d, 37, mouth_y - 4, BLUSH)
    px(d, 38, mouth_y - 4, BLUSH)
    star_patterns = [
        [(18, 16), (46, 18)],
        [(14, 22), (50, 14)],
        [(20, 12), (44, 24)],
        [(16, 28), (48, 10)],
        [(12, 18), (52, 20)],
        [(22, 10), (42, 26)],
        [(10, 24), (54, 16)],
        [(24, 8), (40, 28)],
    ]
    for sx, sy in star_patterns[(frame_num - 1) % len(star_patterns)]:
        sx = max(3, min(60, sx))
        sy = max(3, min(60, sy))
        draw_star(d, sx, sy, YELLOW)
    if frame_num % 2 == 1:
        draw_big_sparkle(d, 32, max(3, 6 + bounce_y), GOLD_L)
    if bounce_y < -1:
        eye_y_map = {1: 32, 2: 30, 3: 30, 4: 29, 5: 29}
        ey = eye_y_map.get(sprite_num, 30)
        px(d, 28, ey - 3, WHITE)
        px(d, 36, ey - 3, WHITE)
    return img


def make_worried_frame(base_func, frame_num, total_frames, sprite_num):
    img = base_func()
    d = ImageDraw.Draw(img)
    img = shift_image(img, 0, 1)
    d = ImageDraw.Draw(img)
    mouth_y_map = {1: 36, 2: 34, 3: 34, 4: 33, 5: 33}
    mouth_y = mouth_y_map.get(sprite_num, 34)
    cover_circle(d, 32, mouth_y + 1, 2, TRANS)
    draw_frown(d, 32, mouth_y + 1)
    sweat_y_offset = (frame_num - 1) * 2
    sweat_x_positions = [38, 40, 42, 44]
    sweat_x = sweat_x_positions[min(frame_num - 1, len(sweat_x_positions) - 1)]
    draw_sweat(d, sweat_x, 24 + min(sweat_y_offset, 8))
    if frame_num % 2 == 0:
        draw_sweat(d, 42, 20 + min(sweat_y_offset // 2, 4))
    eye_y_map = {1: 33, 2: 31, 3: 31, 4: 30, 5: 30}
    ey = eye_y_map.get(sprite_num, 31)
    for ex in [28, 36]:
        px(d, ex - 1, ey - 3, EYE_D)
        px(d, ex, ey - 3, EYE_D)
    body_color_map = {1: G_LIGHT, 2: SKIN, 3: SKIN, 4: SKIN, 5: SKIN}
    body_c = body_color_map.get(sprite_num, SKIN)
    cover_circle(d, 26, ey + 3, 2, body_c)
    cover_circle(d, 38, ey + 3, 2, body_c)
    return img


def make_sleep_frame(base_func, frame_num, total_frames, sprite_num):
    img = base_func()
    d = ImageDraw.Draw(img)
    phase = (frame_num - 1) / total_frames * 2 * math.pi
    sway_x = int(round(math.sin(phase) * 1.0))
    breath_y = int(round(math.sin(phase * 0.5) * 0.5))
    if sway_x != 0 or breath_y != 0:
        img = shift_image(img, sway_x, breath_y)
        d = ImageDraw.Draw(img)
    zzz_base_x = 40
    zzz_base_y = {1: 18, 2: 16, 3: 16, 4: 14, 5: 14}[sprite_num]
    drift_y = (frame_num - 1) * 2
    drift_x = int(round(math.sin(phase) * 2))
    z_positions = [
        (zzz_base_x + drift_x, zzz_base_y - drift_y),
        (zzz_base_x + 3 + drift_x, zzz_base_y - drift_y - 4),
        (zzz_base_x - 1 + drift_x, zzz_base_y - drift_y - 8),
    ]
    for i, (zx, zy) in enumerate(z_positions[: min(frame_num, 3)]):
        zy_c = max(2, min(60, zy))
        zx_c = max(2, min(60, zx))
        if i == 0:
            px(d, zx_c, zy_c, SKY)
            px(d, zx_c + 1, zy_c, SKY)
        elif i == 1:
            px(d, zx_c, zy_c, SKY)
            px(d, zx_c + 1, zy_c, SKY)
            px(d, zx_c + 1, zy_c + 1, SKY)
        else:
            px(d, zx_c, zy_c, SKY)
            px(d, zx_c + 1, zy_c, SKY)
            px(d, zx_c + 2, zy_c, SKY)
            px(d, zx_c + 2, zy_c + 1, SKY)
            px(d, zx_c + 1, zy_c + 2, SKY)
    return img


def plant_wilted():
    img = new_img()
    d = ImageDraw.Draw(img)
    rect(d, 8, 44, 48, 16, BR_MID)
    rect(d, 10, 44, 44, 3, BR_LIGHT)
    # Droopy stem bent to the right
    rect(d, 31, 32, 2, 12, DKGREEN)
    rect(d, 33, 26, 2, 6, DKGREEN)
    rect(d, 35, 22, 2, 4, DKGREEN)
    # Wilting leaves (brownish/grey, drooping)
    rect(d, 22, 36, 9, 2, GREY)
    rect(d, 20, 38, 11, 2, GREY)
    rect(d, 22, 40, 9, 2, DKGREY)
    rect(d, 33, 32, 9, 2, GREY)
    rect(d, 35, 34, 7, 2, DKGREY)
    # Fallen petals on ground
    px(d, 18, 43, P_LIGHT)
    px(d, 19, 43, GREY)
    px(d, 42, 43, P_MID)
    px(d, 43, 43, GREY)
    px(d, 24, 42, P_LIGHT)
    px(d, 38, 42, GREY)
    # Dead flower head
    circle(d, 37, 20, 3, DKGREY)
    circle(d, 36, 19, 2, GREY)
    px(d, 35, 18, BR_LIGHT)
    # Droop lines
    px(d, 33, 24, DKGREEN)
    px(d, 34, 25, DKGREEN)
    return img


SPRITE_FRAME_COUNTS = {
    1: {"idle": 4, "happy": 4, "worried": 2, "sleep": 4},
    2: {"idle": 6, "happy": 6, "worried": 3, "sleep": 4},
    3: {"idle": 6, "happy": 6, "worried": 4, "sleep": 4},
    4: {"idle": 8, "happy": 8, "worried": 4, "sleep": 4},
    5: {"idle": 8, "happy": 8, "worried": 4, "sleep": 4},
}

SPRITE_IDLE_FUNCS = {
    1: sprite_1_idle,
    2: sprite_2_idle,
    3: sprite_3_idle,
    4: sprite_4_idle,
    5: sprite_5_idle,
}

SPRITE_SLEEP_FUNCS = {
    1: sprite_1_sleep,
    2: sprite_2_sleep,
    3: sprite_3_sleep,
    4: sprite_4_sleep,
    5: sprite_5_sleep,
}


def generate_all_frames():
    """Generate all animation frame PNGs."""
    print("Generating PlantPal animation frames...")
    count = 0

    # --- Sprite animation frames ---
    for sprite_num in range(1, 6):
        counts = SPRITE_FRAME_COUNTS[sprite_num]
        idle_func = SPRITE_IDLE_FUNCS[sprite_num]
        sleep_func = SPRITE_SLEEP_FUNCS[sprite_num]

        # Idle frames
        for f in range(1, counts["idle"] + 1):
            name = f"sprite_{sprite_num}_idle_{f}.png"
            img = make_idle_frame(idle_func, f, counts["idle"])
            save(img, name)
            count += 1

        # Happy frames
        for f in range(1, counts["happy"] + 1):
            name = f"sprite_{sprite_num}_happy_{f}.png"
            img = make_happy_frame(idle_func, f, counts["happy"], sprite_num)
            save(img, name)
            count += 1

        # Worried frames
        for f in range(1, counts["worried"] + 1):
            name = f"sprite_{sprite_num}_worried_{f}.png"
            img = make_worried_frame(idle_func, f, counts["worried"], sprite_num)
            save(img, name)
            count += 1

        # Sleep frames
        for f in range(1, counts["sleep"] + 1):
            name = f"sprite_{sprite_num}_sleep_{f}.png"
            img = make_sleep_frame(sleep_func, f, counts["sleep"], sprite_num)
            save(img, name)
            count += 1

    # --- Plant growth stages (single-frame, including new wilted) ---
    for fn, name in [
        (plant_seed, "plant_seed.png"),
        (plant_sprout, "plant_sprout.png"),
        (plant_bud, "plant_bud.png"),
        (plant_bloom, "plant_bloom.png"),
        (plant_fruit, "plant_fruit.png"),
        (plant_wilted, "plant_wilted.png"),
    ]:
        save(fn(), name)
        count += 1

    # --- Flower pots ---
    for fn, name in [
        (pot_default, "pot_default.png"),
        (pot_ceramic, "pot_ceramic.png"),
        (pot_wooden, "pot_wooden.png"),
        (pot_golden, "pot_golden.png"),
        (pot_crystal, "pot_crystal.png"),
    ]:
        save(fn(), name)
        count += 1

    # --- Backgrounds ---
    for fn, name in [
        (bg_garden, "bg_garden.png"),
        (bg_forest, "bg_forest.png"),
        (bg_beach, "bg_beach.png"),
        (bg_night, "bg_night.png"),
        (bg_rainbow, "bg_rainbow.png"),
    ]:
        save(fn(), name)
        count += 1

    print(f"\nTotal PNGs generated: {count}")
    print(f"Output directory: {OUT}")

    # --- Deploy to platform directories ---
    deploy_to_platforms()
    return count


def deploy_to_platforms():
    """Copy generated PNGs to iOS and Android resource directories."""
    project_root = os.path.dirname(
        os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    )

    # iOS destination
    ios_dir = os.path.join(
        project_root, "ios", "PlantPal", "PlantPal", "Resources", "Sprites"
    )
    os.makedirs(ios_dir, exist_ok=True)

    # Android destination
    android_dir = os.path.join(
        project_root, "android", "app", "src", "main", "res", "drawable"
    )
    os.makedirs(android_dir, exist_ok=True)

    # Copy all PNGs to both directories
    png_files = [f for f in os.listdir(OUT) if f.endswith(".png")]
    ios_count = 0
    android_count = 0

    for png_file in sorted(png_files):
        src = os.path.join(OUT, png_file)

        # Copy to iOS
        dst_ios = os.path.join(ios_dir, png_file)
        shutil.copy2(src, dst_ios)
        ios_count += 1

        # Copy to Android (lowercase with underscore naming)
        android_name = png_file.lower().replace("-", "_")
        dst_android = os.path.join(android_dir, android_name)
        shutil.copy2(src, dst_android)
        android_count += 1

    # Android naming compatibility: sprite_seed, sprite_sprout, etc.
    # Map growth stage names to evolution level sprites (first idle frame as static)
    stage_mapping = {
        "sprite_seed.png": "sprite_1_idle_1.png",
        "sprite_sprout.png": "sprite_2_idle_1.png",
        "sprite_bud.png": "sprite_3_idle_1.png",
        "sprite_bloom.png": "sprite_4_idle_1.png",
        "sprite_fruit.png": "sprite_5_idle_1.png",
    }

    for stage_name, source_name in stage_mapping.items():
        src = os.path.join(OUT, source_name)
        if os.path.exists(src):
            dst = os.path.join(android_dir, stage_name)
            shutil.copy2(src, dst)
            android_count += 1

    print(f"\nDeployed {ios_count} PNGs to iOS: {ios_dir}")
    print(f"Deployed {android_count} PNGs to Android: {android_dir}")


if __name__ == "__main__":
    generate_all_frames()
