#!/usr/bin/env python3
"""PlantPal Pixel Art Sprite Generator"""
from PIL import Image, ImageDraw
import os

OUT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "generated")
os.makedirs(OUT, exist_ok=True)

# Color Palette
G_DARK=(46,125,50); G_MID=(102,187,106); G_LIGHT=(129,199,132); G_PALE=(165,214,167)
P_DARK=(236,64,122); P_MID=(244,143,177); P_LIGHT=(248,187,208)
SKIN=(255,204,128); EYE_D=(62,39,35); EYE_W=(255,255,255)
BLUSH=(255,171,145); MOUTH=(191,54,12)
BR_DARK=(121,85,72); BR_MID=(141,110,99); BR_LIGHT=(161,136,127)
GOLD=(255,193,7); GOLD_D=(255,160,0); GOLD_L=(255,224,130)
YELLOW=(255,213,79); ORANGE=(255,167,38)
WATER=(66,165,245); SKY=(100,181,246)
WHITE=(255,255,255); BLACK=(0,0,0)
SOIL_D=BR_MID; SOIL_L=BR_LIGHT
PURPLE=(156,39,176); PURPLE_L=(186,104,200); PURPLE_D=(106,27,154)
RED=(244,67,54); TRANS=(0,0,0,0)
DKGREEN=(27,94,32); GREY=(158,158,158); DKGREY=(97,97,97)

def new_img(w=64, h=64):
    return Image.new('RGBA', (w, h), TRANS)

def px(d, x, y, c):
    if 0 <= x and 0 <= y:
        d.point((int(x), int(y)), fill=c)

def rect(d, x, y, w, h, c):
    for dy in range(h):
        for dx in range(w):
            px(d, x+dx, y+dy, c)

def circle(d, cx, cy, r, c):
    for dy in range(-r, r+1):
        for dx in range(-r, r+1):
            if dx*dx + dy*dy <= r*r:
                px(d, cx+dx, cy+dy, c)

def draw_eyes(d, cx, cy, gap=4, sz=2):
    rect(d, cx-gap-sz, cy-sz+1, sz*2, sz*2, EYE_D)
    rect(d, cx-gap-sz+1, cy-sz+1, 1, 1, EYE_W)
    rect(d, cx+gap-sz, cy-sz+1, sz*2, sz*2, EYE_D)
    rect(d, cx+gap-sz+1, cy-sz+1, 1, 1, EYE_W)

def draw_closed_eyes(d, cx, cy, gap=4):
    for i in range(3):
        px(d, cx-gap-1+i, cy, EYE_D)
        px(d, cx+gap-1+i, cy, EYE_D)

def draw_blush(d, cx, cy, gap=6):
    for ox in [-gap-1, -gap]:
        px(d, cx+ox, cy+2, BLUSH)
    px(d, cx-gap, cy+3, BLUSH)
    for ox in [gap, gap+1]:
        px(d, cx+ox, cy+2, BLUSH)
    px(d, cx+gap, cy+3, BLUSH)

def draw_mouth(d, cx, cy):
    for i in range(-1,2): px(d, cx+i, cy, MOUTH)

def draw_smile(d, cx, cy):
    px(d, cx-1, cy, MOUTH); px(d, cx, cy+1, MOUTH); px(d, cx+1, cy, MOUTH)

def draw_sparkle(d, x, y, c=YELLOW):
    px(d, x, y-1, c); px(d, x-1, y, c); px(d, x, y, c)
    px(d, x+1, y, c); px(d, x, y+1, c)

def draw_zzz(d, x, y, c=SKY):
    px(d, x+2, y, c); px(d, x+3, y, c)
    px(d, x+3, y+1, c)
    px(d, x+2, y+2, c); px(d, x+3, y+2, c)
    px(d, x+5, y-3, c); px(d, x+6, y-3, c); px(d, x+7, y-3, c)
    px(d, x+7, y-2, c); px(d, x+6, y-1, c)
    px(d, x+5, y, c); px(d, x+6, y, c); px(d, x+7, y, c)

def save(img, name):
    p = os.path.join(OUT, name)
    img.save(p)
    print(f"  Saved {name}")

# ===== SPRITE 1: Seed Guardian =====
def sprite_1_idle():
    img = new_img(); d = ImageDraw.Draw(img)
    draw_sparkle(d, 28, 50, G_LIGHT)
    px(d, 24, 46, G_PALE); px(d, 25, 46, G_PALE)
    px(d, 38, 48, G_PALE); px(d, 39, 48, G_PALE)
    px(d, 26, 54, G_LIGHT); px(d, 36, 52, G_LIGHT)
    circle(d, 32, 34, 10, G_MID)
    circle(d, 32, 33, 8, G_LIGHT)
    circle(d, 32, 32, 5, G_PALE)
    px(d, 28, 28, WHITE); px(d, 29, 28, WHITE); px(d, 28, 29, WHITE)
    rect(d, 26, 32, 3, 3, EYE_D); rect(d, 27, 32, 1, 1, EYE_W)
    rect(d, 35, 32, 3, 3, EYE_D); rect(d, 36, 32, 1, 1, EYE_W)
    draw_blush(d, 32, 33, gap=5)
    draw_mouth(d, 32, 36)
    draw_sparkle(d, 32, 20, YELLOW)
    px(d, 20, 30, YELLOW); px(d, 21, 30, YELLOW)
    px(d, 43, 32, YELLOW); px(d, 44, 32, YELLOW)
    return img

# ===== SPRITE 2: Sprout Fairy =====
def sprite_2_idle():
    img = new_img(); d = ImageDraw.Draw(img)
    for i in range(6):
        px(d, 16+i, 28-i, G_DARK); px(d, 16+i, 29-i, G_MID)
    for i in range(4):
        px(d, 18+i, 24-i, G_DARK); px(d, 18+i, 25-i, G_MID)
    for i in range(6):
        px(d, 47-i, 28-i, G_DARK); px(d, 47-i, 29-i, G_MID)
    for i in range(4):
        px(d, 45-i, 24-i, G_DARK); px(d, 45-i, 25-i, G_MID)
    rect(d, 28, 36, 8, 10, P_MID)
    rect(d, 26, 42, 12, 6, P_MID)
    rect(d, 27, 38, 10, 2, P_LIGHT)
    circle(d, 32, 30, 8, SKIN)
    rect(d, 24, 24, 16, 4, G_MID)
    rect(d, 23, 26, 3, 4, G_MID); rect(d, 38, 26, 3, 4, G_MID)
    rect(d, 30, 19, 4, 3, G_DARK); rect(d, 31, 17, 2, 3, G_DARK)
    px(d, 32, 16, G_MID)
    draw_eyes(d, 32, 30); draw_blush(d, 32, 32); draw_mouth(d, 32, 34)
    rect(d, 25, 38, 3, 2, SKIN); rect(d, 36, 38, 3, 2, SKIN)
    rect(d, 28, 48, 3, 2, SKIN); rect(d, 33, 48, 3, 2, SKIN)
    return img

# ===== SPRITE 3: Bud Fairy =====
def sprite_3_idle():
    img = new_img(); d = ImageDraw.Draw(img)
    for i in range(7):
        px(d, 14+i, 30-i, P_MID); px(d, 14+i, 31-i, P_LIGHT)
    for i in range(5):
        px(d, 16+i, 25-i, P_MID); px(d, 16+i, 26-i, P_LIGHT)
    for i in range(7):
        px(d, 49-i, 30-i, P_MID); px(d, 49-i, 31-i, P_LIGHT)
    for i in range(5):
        px(d, 47-i, 25-i, P_MID); px(d, 47-i, 26-i, P_LIGHT)
    rect(d, 27, 36, 10, 10, PURPLE)
    rect(d, 25, 42, 14, 6, PURPLE)
    rect(d, 26, 38, 12, 2, PURPLE_L)
    circle(d, 32, 30, 8, SKIN)
    rect(d, 24, 24, 16, 4, BR_MID)
    rect(d, 23, 26, 3, 5, BR_MID); rect(d, 38, 26, 3, 5, BR_MID)
    circle(d, 32, 20, 4, P_MID)
    circle(d, 28, 22, 2, P_LIGHT); circle(d, 36, 22, 2, P_LIGHT)
    circle(d, 32, 16, 2, YELLOW)
    draw_eyes(d, 32, 30); draw_blush(d, 32, 32); draw_mouth(d, 32, 34)
    rect(d, 24, 38, 3, 2, SKIN); rect(d, 37, 38, 3, 2, SKIN)
    rect(d, 28, 48, 3, 2, SKIN); rect(d, 33, 48, 3, 2, SKIN)
    return img

# ===== SPRITE 4: Bloom Fairy =====
def sprite_4_idle():
    img = new_img(); d = ImageDraw.Draw(img)
    for i in range(9):
        px(d, 12+i, 32-i, P_MID); px(d, 12+i, 33-i, P_LIGHT)
    for i in range(6):
        px(d, 14+i, 25-i, P_MID); px(d, 14+i, 26-i, P_LIGHT)
    for i in range(4):
        px(d, 15+i, 21-i, P_LIGHT)
    for i in range(9):
        px(d, 51-i, 32-i, P_MID); px(d, 51-i, 33-i, P_LIGHT)
    for i in range(6):
        px(d, 49-i, 25-i, P_MID); px(d, 49-i, 26-i, P_LIGHT)
    for i in range(4):
        px(d, 48-i, 21-i, P_LIGHT)
    rect(d, 27, 35, 10, 12, P_MID)
    rect(d, 24, 43, 16, 4, P_MID)
    rect(d, 23, 46, 18, 3, P_LIGHT)
    px(d, 30, 43, P_LIGHT); px(d, 34, 43, P_LIGHT)
    px(d, 28, 46, P_DARK); px(d, 32, 46, P_DARK); px(d, 36, 46, P_DARK)
    circle(d, 32, 29, 8, SKIN)
    rect(d, 24, 23, 16, 4, G_MID)
    rect(d, 23, 25, 3, 6, G_MID); rect(d, 38, 25, 3, 6, G_MID)
    px(d, 24, 31, G_MID); px(d, 39, 31, G_MID)
    circle(d, 28, 20, 2, P_DARK); circle(d, 32, 19, 2, P_MID)
    circle(d, 36, 20, 2, P_DARK)
    circle(d, 30, 18, 2, YELLOW); circle(d, 34, 18, 2, YELLOW)
    draw_eyes(d, 32, 29); draw_blush(d, 32, 31)
    draw_smile(d, 32, 33)
    rect(d, 24, 37, 3, 2, SKIN); rect(d, 37, 37, 3, 2, SKIN)
    rect(d, 28, 49, 3, 2, SKIN); rect(d, 33, 49, 3, 2, SKIN)
    draw_sparkle(d, 20, 20, YELLOW); draw_sparkle(d, 44, 22, YELLOW)
    return img

# ===== SPRITE 5: Fruit Fairy Queen =====
def sprite_5_idle():
    img = new_img(); d = ImageDraw.Draw(img)
    for pos in [(14,18),(50,18),(12,32),(52,32),(18,48),(46,48),(32,12),(20,26),(44,26)]:
        px(d, pos[0], pos[1], GOLD_L)
    draw_sparkle(d, 16, 22, GOLD_L); draw_sparkle(d, 48, 22, GOLD_L)
    draw_sparkle(d, 32, 10, GOLD_L)
    for i in range(10):
        px(d, 10+i, 33-i, GOLD); px(d, 10+i, 34-i, GOLD_L)
    for i in range(7):
        px(d, 12+i, 25-i, GOLD); px(d, 12+i, 26-i, GOLD_L)
    for i in range(5):
        px(d, 13+i, 20-i, GOLD_L)
    for i in range(10):
        px(d, 51-i, 33-i, GOLD); px(d, 51-i, 34-i, GOLD_L)
    for i in range(7):
        px(d, 49-i, 25-i, GOLD); px(d, 49-i, 26-i, GOLD_L)
    for i in range(5):
        px(d, 48-i, 20-i, GOLD_L)
    rect(d, 26, 35, 12, 12, GOLD)
    rect(d, 24, 43, 16, 4, GOLD)
    rect(d, 23, 46, 18, 3, GOLD_L)
    rect(d, 28, 37, 8, 2, GOLD_D)
    px(d, 28, 43, GOLD_D); px(d, 32, 43, GOLD_D); px(d, 36, 43, GOLD_D)
    circle(d, 32, 29, 8, SKIN)
    rect(d, 24, 23, 16, 4, GOLD_D)
    rect(d, 23, 25, 3, 6, GOLD_D); rect(d, 38, 25, 3, 6, GOLD_D)
    rect(d, 25, 17, 14, 4, GOLD)
    rect(d, 26, 14, 3, 4, GOLD); rect(d, 32, 13, 3, 5, GOLD)
    rect(d, 37, 14, 3, 4, GOLD)
    px(d, 27, 13, GOLD_L); px(d, 33, 12, GOLD_L); px(d, 38, 13, GOLD_L)
    px(d, 30, 13, RED); px(d, 36, 13, RED)
    draw_eyes(d, 32, 29); draw_blush(d, 32, 31)
    draw_smile(d, 32, 33)
    rect(d, 24, 37, 3, 2, SKIN); rect(d, 37, 37, 3, 2, SKIN)
    rect(d, 28, 49, 3, 2, SKIN); rect(d, 33, 49, 3, 2, SKIN)
    return img

# ===== SLEEPING SPRITES =====
def sprite_1_sleep():
    img = sprite_1_idle(); d = ImageDraw.Draw(img)
    # Remove eyes, draw closed
    circle(d, 27, 33, 2, G_LIGHT)  # cover left eye area
    circle(d, 37, 33, 2, G_LIGHT)  # cover right eye area
    draw_closed_eyes(d, 32, 33, gap=5)
    draw_zzz(d, 40, 18, SKY)
    return img

def sprite_2_sleep():
    img = sprite_2_idle(); d = ImageDraw.Draw(img)
    circle(d, 28, 31, 2, SKIN); circle(d, 36, 31, 2, SKIN)
    draw_closed_eyes(d, 32, 30, gap=4)
    draw_zzz(d, 44, 16, SKY)
    return img

def sprite_3_sleep():
    img = sprite_3_idle(); d = ImageDraw.Draw(img)
    circle(d, 28, 31, 2, SKIN); circle(d, 36, 31, 2, SKIN)
    draw_closed_eyes(d, 32, 30, gap=4)
    draw_zzz(d, 44, 16, SKY)
    return img

def sprite_4_sleep():
    img = sprite_4_idle(); d = ImageDraw.Draw(img)
    circle(d, 28, 30, 2, SKIN); circle(d, 36, 30, 2, SKIN)
    draw_closed_eyes(d, 32, 29, gap=4)
    draw_zzz(d, 44, 14, SKY)
    return img

def sprite_5_sleep():
    img = sprite_5_idle(); d = ImageDraw.Draw(img)
    circle(d, 28, 30, 2, SKIN); circle(d, 36, 30, 2, SKIN)
    draw_closed_eyes(d, 32, 29, gap=4)
    draw_zzz(d, 44, 14, SKY)
    return img

# ===== PLANT GROWTH STAGES =====
def plant_seed():
    img = new_img(); d = ImageDraw.Draw(img)
    # Soil
    rect(d, 8, 44, 48, 16, SOIL_D)
    rect(d, 10, 44, 44, 3, SOIL_L)
    # Seed
    circle(d, 32, 42, 4, BR_DARK)
    circle(d, 31, 41, 2, BR_MID)
    # Shimmer
    px(d, 35, 39, YELLOW); px(d, 36, 39, YELLOW)
    px(d, 34, 40, GOLD_L); px(d, 37, 40, GOLD_L)
    px(d, 29, 38, YELLOW)
    return img

def plant_sprout():
    img = new_img(); d = ImageDraw.Draw(img)
    rect(d, 8, 44, 48, 16, SOIL_D)
    rect(d, 10, 44, 44, 3, SOIL_L)
    # Stem
    rect(d, 31, 28, 2, 16, G_DARK)
    # Left leaf
    rect(d, 24, 30, 7, 2, G_MID)
    rect(d, 22, 32, 9, 2, G_MID)
    rect(d, 24, 34, 7, 2, G_LIGHT)
    # Right leaf
    rect(d, 33, 28, 7, 2, G_MID)
    rect(d, 33, 26, 9, 2, G_MID)
    rect(d, 33, 28, 7, 2, G_LIGHT)
    return img

def plant_bud():
    img = new_img(); d = ImageDraw.Draw(img)
    rect(d, 8, 44, 48, 16, SOIL_D)
    rect(d, 10, 44, 44, 3, SOIL_L)
    # Taller stem
    rect(d, 31, 20, 2, 24, G_DARK)
    # Left leaves
    rect(d, 22, 28, 9, 2, G_MID)
    rect(d, 20, 30, 11, 2, G_MID)
    rect(d, 22, 32, 9, 2, G_LIGHT)
    # Right leaves
    rect(d, 33, 24, 9, 2, G_MID)
    rect(d, 33, 22, 11, 2, G_MID)
    rect(d, 33, 24, 9, 2, G_LIGHT)
    # Pink bud forming at top
    circle(d, 32, 17, 4, P_DARK)
    circle(d, 32, 16, 3, P_MID)
    circle(d, 32, 15, 2, P_LIGHT)
    return img

def plant_bloom():
    img = new_img(); d = ImageDraw.Draw(img)
    rect(d, 8, 44, 48, 16, SOIL_D)
    rect(d, 10, 44, 44, 3, SOIL_L)
    # Stem
    rect(d, 31, 16, 2, 28, G_DARK)
    # Leaves
    rect(d, 22, 26, 9, 2, G_MID)
    rect(d, 20, 28, 11, 2, G_MID)
    rect(d, 22, 30, 9, 2, G_LIGHT)
    rect(d, 33, 22, 9, 2, G_MID)
    rect(d, 33, 20, 11, 2, G_MID)
    rect(d, 33, 22, 9, 2, G_LIGHT)
    # Open flower with pink petals
    for angle_offset in range(6):
        cx = 32 + int(5 * (1 if angle_offset % 2 == 0 else -1) * (1 if angle_offset < 3 else 0.5))
        cy = 14 + int(3 * (1 if angle_offset < 2 else -1))
    # Petals (simplified)
    circle(d, 32, 10, 3, P_DARK)
    circle(d, 28, 12, 3, P_MID)
    circle(d, 36, 12, 3, P_MID)
    circle(d, 27, 9, 2, P_LIGHT)
    circle(d, 37, 9, 2, P_LIGHT)
    circle(d, 32, 8, 2, P_MID)
    # Yellow center
    circle(d, 32, 11, 2, YELLOW)
    return img

def plant_fruit():
    img = new_img(); d = ImageDraw.Draw(img)
    rect(d, 8, 44, 48, 16, SOIL_D)
    rect(d, 10, 44, 44, 3, SOIL_L)
    # Stem
    rect(d, 31, 18, 2, 26, G_DARK)
    # Leaves
    rect(d, 22, 26, 9, 2, G_MID)
    rect(d, 20, 28, 11, 2, G_MID)
    rect(d, 33, 22, 9, 2, G_MID)
    rect(d, 33, 20, 11, 2, G_MID)
    # Orange/red fruit
    circle(d, 32, 16, 5, ORANGE)
    circle(d, 32, 15, 4, RED)
    circle(d, 30, 14, 2, ORANGE)
    # Remaining petals
    px(d, 26, 10, P_MID); px(d, 27, 9, P_LIGHT)
    px(d, 38, 10, P_MID); px(d, 37, 9, P_LIGHT)
    px(d, 32, 7, P_LIGHT)
    return img

# ===== FLOWER POTS =====
def pot_default():
    img = new_img(); d = ImageDraw.Draw(img)
    # Rim
    rect(d, 16, 16, 32, 6, BR_MID)
    rect(d, 18, 16, 28, 2, BR_LIGHT)
    # Body (tapered trapezoid shape)
    for row in range(20):
        w = 28 - row
        x = 32 - w // 2
        rect(d, x, 22+row, w, 1, BR_DARK if row < 18 else BR_MID)
    # Rim highlight
    rect(d, 18, 17, 28, 1, BR_LIGHT)
    # Soil
    rect(d, 18, 22, 28, 3, SOIL_D)
    return img

def pot_ceramic():
    img = new_img(); d = ImageDraw.Draw(img)
    # Rim
    rect(d, 16, 16, 32, 6, WHITE)
    rect(d, 18, 16, 28, 2, LTGREY if 'LTGREY' in dir() else (224,224,224))
    # Body
    for row in range(20):
        w = 28 - row
        x = 32 - w // 2
        c = (240,240,240) if row % 4 < 2 else WHITE
        rect(d, x, 22+row, w, 1, c)
    # Blue stripe
    for row in range(3):
        w = 26 - row
        x = 32 - w // 2
        rect(d, x, 30+row, w, 1, WATER)
    # Soil
    rect(d, 18, 22, 28, 3, SOIL_D)
    return img

def pot_wooden():
    img = new_img(); d = ImageDraw.Draw(img)
    # Rim
    rect(d, 16, 16, 32, 6, BR_DARK)
    rect(d, 18, 16, 28, 2, BR_MID)
    # Body - wooden barrel with bands
    for row in range(20):
        w = 28 - row
        x = 32 - w // 2
        rect(d, x, 22+row, w, 1, BR_MID)
    # Metal bands
    for row in [25, 32]:
        w = 27 - (row - 22)
        x = 32 - w // 2
        rect(d, x, row, w, 2, GREY)
    # Vertical plank lines
    for row in range(20):
        w = 28 - row
        x = 32 - w // 2
        px(d, x + w//4, 22+row, BR_DARK)
        px(d, x + w//2, 22+row, BR_DARK)
        px(d, x + 3*w//4, 22+row, BR_DARK)
    # Soil
    rect(d, 18, 22, 28, 3, SOIL_D)
    return img

def pot_golden():
    img = new_img(); d = ImageDraw.Draw(img)
    # Rim
    rect(d, 16, 16, 32, 6, GOLD)
    rect(d, 18, 16, 28, 2, GOLD_L)
    # Body
    for row in range(20):
        w = 28 - row
        x = 32 - w // 2
        rect(d, x, 22+row, w, 1, GOLD if row % 3 != 0 else GOLD_D)
    # Shiny highlights
    for row in range(6):
        w = 27 - row
        x = 32 - w // 2
        px(d, x+3, 24+row, GOLD_L)
        px(d, x+4, 24+row, GOLD_L)
    # Soil
    rect(d, 18, 22, 28, 3, SOIL_D)
    return img

def pot_crystal():
    img = new_img(); d = ImageDraw.Draw(img)
    # Rim
    rect(d, 16, 16, 32, 6, PURPLE_L)
    rect(d, 18, 16, 28, 2, (220,180,240))
    # Body
    for row in range(20):
        w = 28 - row
        x = 32 - w // 2
        c = PURPLE if row % 4 < 2 else PURPLE_D
        rect(d, x, 22+row, w, 1, c)
    # Glow effect
    for row in range(8):
        w = 26 - row
        x = 32 - w // 2
        px(d, x+2, 26+row, PURPLE_L)
    # Sparkles
    px(d, 20, 28, (200,150,255)); px(d, 42, 30, (200,150,255))
    px(d, 28, 36, (220,180,255)); px(d, 36, 34, (220,180,255))
    # Soil
    rect(d, 18, 22, 28, 3, SOIL_D)
    return img

# ===== BACKGROUND SCENES (128x128) =====
def bg_garden():
    img = new_img(128, 128); d = ImageDraw.Draw(img)
    # Sky
    rect(d, 0, 0, 128, 60, SKY)
    # Clouds
    circle(d, 20, 16, 8, WHITE); circle(d, 28, 14, 6, WHITE)
    circle(d, 100, 20, 7, WHITE); circle(d, 108, 18, 5, WHITE)
    # Grass
    rect(d, 0, 60, 128, 68, G_MID)
    rect(d, 0, 68, 128, 60, G_LIGHT)
    # Ground
    rect(d, 0, 68, 128, 60, G_LIGHT)
    rect(d, 0, 100, 128, 28, G_PALE)
    # Fence
    for x in range(0, 128, 16):
        rect(d, x, 48, 4, 22, BR_DARK)
        rect(d, x, 46, 4, 2, BR_LIGHT)
    rect(d, 0, 54, 128, 2, BR_MID)
    rect(d, 0, 62, 128, 2, BR_MID)
    # Small flowers
    for fx, fy in [(10,74),(30,78),(50,72),(70,80),(90,76),(110,74)]:
        px(d, fx, fy, P_MID); px(d, fx-1, fy+1, P_MID)
        px(d, fx+1, fy+1, P_MID); px(d, fx, fy+2, YELLOW)
        px(d, fx, fy+3, G_DARK); px(d, fx, fy+4, G_DARK)
    # Path
    rect(d, 56, 68, 16, 60, SOIL_L)
    rect(d, 60, 68, 8, 60, SOIL_D)
    return img

def bg_forest():
    img = new_img(128, 128); d = ImageDraw.Draw(img)
    # Sky (filtered through canopy)
    rect(d, 0, 0, 128, 40, (70,130,70))
    rect(d, 0, 40, 128, 88, G_DARK)
    # Ground
    rect(d, 0, 88, 128, 40, G_DARK)
    rect(d, 0, 100, 128, 28, BR_MID)
    # Trees (left)
    rect(d, 8, 30, 8, 70, BR_DARK)
    circle(d, 12, 20, 14, DKGREEN); circle(d, 12, 14, 10, G_DARK)
    # Trees (right)
    rect(d, 108, 30, 8, 70, BR_DARK)
    circle(d, 112, 20, 14, DKGREEN); circle(d, 112, 14, 10, G_DARK)
    # Tree (center back)
    rect(d, 56, 10, 8, 80, BR_DARK)
    circle(d, 60, 6, 12, DKGREEN); circle(d, 60, 0, 8, G_DARK)
    # Dappled light
    for lx, ly in [(20,50),(40,60),(80,55),(100,48),(50,45),(70,65)]:
        px(d, lx, ly, G_LIGHT); px(d, lx+1, ly, G_LIGHT)
    # Mushrooms
    rect(d, 28, 96, 2, 6, WHITE)
    circle(d, 29, 94, 4, RED); px(d, 28, 93, WHITE); px(d, 30, 92, WHITE)
    rect(d, 96, 98, 2, 5, WHITE)
    circle(d, 97, 96, 3, RED); px(d, 96, 95, WHITE)
    return img

def bg_beach():
    img = new_img(128, 128); d = ImageDraw.Draw(img)
    # Sky
    rect(d, 0, 0, 128, 50, SKY)
    # Sun
    circle(d, 105, 15, 10, YELLOW)
    circle(d, 105, 15, 8, GOLD_L)
    # Water
    rect(d, 0, 50, 128, 20, WATER)
    rect(d, 0, 55, 128, 2, SKY)
    rect(d, 0, 60, 128, 2, WATER)
    # Waves
    for x in range(0, 128, 8):
        px(d, x, 48, WHITE); px(d, x+1, 48, WHITE)
        px(d, x+4, 49, WHITE); px(d, x+5, 49, WHITE)
    # Sand
    rect(d, 0, 70, 128, 58, GOLD_L)
    rect(d, 0, 90, 128, 38, GOLD)
    # Shells
    px(d, 20, 80, P_LIGHT); px(d, 21, 80, P_MID); px(d, 22, 80, P_LIGHT)
    px(d, 80, 85, P_MID); px(d, 81, 85, P_DARK); px(d, 82, 85, P_MID)
    px(d, 60, 95, P_LIGHT); px(d, 61, 95, P_LIGHT)
    # Palm tree
    rect(d, 15, 30, 4, 50, BR_DARK)
    # Palm leaves
    for i in range(12):
        px(d, 17-i, 28-i, G_DARK); px(d, 18-i, 29-i, G_MID)
    for i in range(10):
        px(d, 17+i, 28-i, G_DARK); px(d, 16+i, 29-i, G_MID)
    for i in range(8):
        px(d, 19+i, 30, G_DARK); px(d, 19+i, 31, G_MID)
    return img

def bg_night():
    img = new_img(128, 128); d = ImageDraw.Draw(img)
    # Night sky
    rect(d, 0, 0, 128, 80, (25,25,80))
    rect(d, 0, 80, 128, 48, (20,20,60))
    # Moon
    circle(d, 100, 20, 12, (230,230,200))
    circle(d, 96, 18, 10, (25,25,80))
    # Stars
    for sx, sy in [(10,8),(25,15),(45,6),(60,22),(80,10),(15,30),(55,35),(90,28),(35,42),(70,40),(110,35)]:
        px(d, sx, sy, YELLOW); px(d, sx+1, sy, (200,200,150))
    # Ground
    rect(d, 0, 90, 128, 38, G_DARK)
    rect(d, 0, 100, 128, 28, (30,60,30))
    # Grass tufts
    for gx in range(0, 128, 12):
        px(d, gx, 88, G_MID); px(d, gx+1, 87, G_MID); px(d, gx+2, 88, G_MID)
    # Fireflies
    for fx, fy in [(20,55),(40,60),(65,50),(85,65),(30,70),(100,55),(50,75)]:
        px(d, fx, fy, YELLOW); px(d, fx, fy+1, GOLD_L)
    return img

def bg_rainbow():
    img = new_img(128, 128); d = ImageDraw.Draw(img)
    # Sky
    rect(d, 0, 0, 128, 70, SKY)
    # Rainbow arc
    for i, c in enumerate([RED, ORANGE, YELLOW, G_LIGHT, WATER, PURPLE_L]):
        for x in range(128):
            y_center = 60
            r = 50 - i * 3
            dy = y_center - int((r*r - (x-64)*(x-64))**0.5) if abs(x-64) < r else 999
            if abs(x-64) < r and dy < 70:
                px(d, x, dy, c)
    # Hills
    circle(d, 30, 75, 25, G_MID)
    circle(d, 90, 75, 20, G_MID)
    circle(d, 64, 80, 30, G_LIGHT)
    # Ground
    rect(d, 0, 85, 128, 43, G_LIGHT)
    rect(d, 0, 100, 128, 28, G_PALE)
    # Clouds
    circle(d, 20, 25, 8, WHITE); circle(d, 28, 23, 6, WHITE); circle(d, 14, 23, 5, WHITE)
    circle(d, 105, 30, 7, WHITE); circle(d, 112, 28, 5, WHITE)
    # Small flowers
    for fx, fy in [(15,90),(35,88),(55,92),(75,87),(95,90),(115,88)]:
        px(d, fx, fy, P_MID); px(d, fx, fy+1, YELLOW)
        px(d, fx, fy+2, G_DARK)
    return img

# ===== MAIN GENERATION =====
def generate_all():
    print("Generating PlantPal sprites...")
    # Sprite evolution levels - idle
    for i, fn in enumerate([sprite_1_idle, sprite_2_idle, sprite_3_idle, sprite_4_idle, sprite_5_idle], 1):
        save(fn(), f"sprite_{i}_idle.png")
    # Sprite evolution levels - sleep
    for i, fn in enumerate([sprite_1_sleep, sprite_2_sleep, sprite_3_sleep, sprite_4_sleep, sprite_5_sleep], 1):
        save(fn(), f"sprite_{i}_sleep.png")
    # Plant growth stages
    for fn, name in [(plant_seed, "plant_seed.png"), (plant_sprout, "plant_sprout.png"),
                     (plant_bud, "plant_bud.png"), (plant_bloom, "plant_bloom.png"),
                     (plant_fruit, "plant_fruit.png")]:
        save(fn(), name)
    # Flower pots
    for fn, name in [(pot_default, "pot_default.png"), (pot_ceramic, "pot_ceramic.png"),
                     (pot_wooden, "pot_wooden.png"), (pot_golden, "pot_golden.png"),
                     (pot_crystal, "pot_crystal.png")]:
        save(fn(), name)
    # Backgrounds
    for fn, name in [(bg_garden, "bg_garden.png"), (bg_forest, "bg_forest.png"),
                     (bg_beach, "bg_beach.png"), (bg_night, "bg_night.png"),
                     (bg_rainbow, "bg_rainbow.png")]:
        save(fn(), name)
    print(f"\nAll sprites generated in: {OUT}")

if __name__ == "__main__":
    generate_all()
