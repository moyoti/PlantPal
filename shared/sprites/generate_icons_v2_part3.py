def draw_icon_water():
    img = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    for y in range(8, 42):
        if y < 16:
            w = max(1, (y - 8) // 2)
        else:
            w = min(12, 4 + (y - 16) // 2)
        for x in range(24 - w, 24 + w + 1):
            if x == 24 - w or x == 24 + w:
                px(d, x, y, C["bd"])
            elif x < 24:
                px(d, x, y, C["bl"])
            else:
                px(d, x, y, C["b"])
    px(d, 20, 18, C["w"])
    px(d, 21, 18, C["w"])
    px(d, 20, 19, C["w"])
    px(d, 21, 28, C["bk"])
    px(d, 27, 28, C["bk"])
    px(d, 23, 32, C["bd"])
    px(d, 24, 32, C["bd"])
    px(d, 25, 32, C["bd"])
    return img


def draw_icon_light():
    img = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    circ(d, 24, 24, 8, C["y"])
    circ(d, 24, 24, 6, C["yl"])
    for i in range(8):
        a = i * math.pi / 4
        for dist in range(10, 14):
            rx = 24 + int(dist * math.cos(a))
            ry = 24 + int(dist * math.sin(a))
            px(d, rx, ry, C["yd"])
            px(d, rx + 1, ry, C["y"])
    px(d, 21, 22, C["bk"])
    px(d, 27, 22, C["bk"])
    px(d, 23, 26, C["o"])
    px(d, 24, 26, C["o"])
    px(d, 25, 26, C["o"])
    px(d, 19, 25, C["ol"])
    px(d, 29, 25, C["ol"])
    return img


def draw_icon_fertilize():
    img = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    rect(d, 12, 14, 35, 40, C["brl"])
    rect(d, 13, 15, 34, 39, C["cr"])
    rect(d, 18, 10, 29, 14, C["brl"])
    rect(d, 20, 8, 27, 10, C["br"])
    rect(d, 22, 11, 25, 13, C["brd"])
    circ(d, 24, 26, 4, C["g"])
    circ(d, 24, 26, 2, C["gd"])
    px(d, 21, 32, C["bk"])
    px(d, 27, 32, C["bk"])
    px(d, 23, 35, C["pl"])
    px(d, 24, 35, C["pl"])
    px(d, 25, 35, C["pl"])
    return img


def draw_icon_touch():
    img = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    circ(d, 18, 18, 7, C["p"])
    circ(d, 18, 18, 4, C["pl"])
    circ(d, 30, 18, 7, C["p"])
    circ(d, 30, 18, 4, C["pl"])
    for y in range(20, 38):
        w = (y - 14) // 2
        for x in range(24 - w, 24 + w + 1):
            px(d, x, y, C["p"])
    px(d, 16, 14, C["w"])
    px(d, 17, 14, C["w"])
    px(d, 16, 15, C["w"])
    px(d, 21, 22, C["bk"])
    px(d, 27, 22, C["bk"])
    px(d, 23, 26, C["rl"])
    px(d, 24, 26, C["rl"])
    px(d, 25, 26, C["rl"])
    return img


def draw_icon_talk():
    img = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    rect(d, 6, 6, 40, 30, C["pul"])
    rect(d, 7, 7, 39, 29, C["w"])
    circ(d, 8, 8, 2, C["pul"])
    circ(d, 38, 8, 2, C["pul"])
    circ(d, 8, 28, 2, C["pul"])
    circ(d, 38, 28, 2, C["pul"])
    rect(d, 10, 30, 14, 34, C["pul"])
    rect(d, 8, 34, 12, 36, C["pul"])
    circ(d, 16, 18, 2, C["pu"])
    circ(d, 24, 18, 2, C["pu"])
    circ(d, 32, 18, 2, C["pu"])
    return img


def draw_icon_sing():
    img = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    circ(d, 20, 33, 5, C["p"])
    circ(d, 20, 33, 3, C["pl"])
    rect(d, 25, 8, 27, 34, C["p"])
    for y in range(8, 18):
        x_off = (18 - y) // 3
        px(d, 27 + x_off, y, C["p"])
        px(d, 28 + x_off, y, C["pl"])
    px(d, 10, 12, C["y"])
    px(d, 11, 12, C["yl"])
    px(d, 34, 10, C["yl"])
    px(d, 36, 14, C["y"])
    return img


def draw_icon_heal():
    img = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    rect(d, 20, 8, 28, 40, C["gl"])
    rect(d, 8, 20, 40, 28, C["gl"])
    rect(d, 21, 9, 27, 39, C["g"])
    rect(d, 9, 21, 39, 27, C["g"])
    circ(d, 30, 10, 4, C["gd"])
    circ(d, 30, 10, 2, C["gl"])
    circ(d, 24, 24, 3, C["pl"])
    return img


def draw_icon_play():
    img = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    for y in range(SIZE):
        for x in range(SIZE):
            dx = x - 24
            dy = y - 24
            angle = math.atan2(dy, dx)
            r = math.sqrt(dx * dx + dy * dy)
            star_r = 14 * (0.5 + 0.5 * abs(math.cos(2.5 * angle)))
            if r <= star_r:
                if r <= star_r * 0.7:
                    px(d, x, y, C["ol"])
                else:
                    px(d, x, y, C["o"])
    px(d, 20, 22, C["bk"])
    px(d, 28, 22, C["bk"])
    for xx in range(22, 27):
        px(d, xx, 27, C["rl"])
    return img


def draw_icon_shield():
    img = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    for y in range(6, 42):
        w = 14 - abs(y - 18) // 2
        if y > 30:
            w = max(1, w - (y - 30))
        for x in range(24 - w, 24 + w + 1):
            if x == 24 - w or x == 24 + w or y == 6:
                px(d, x, y, C["bd"])
            elif y > 30:
                px(d, x, y, C["bd"])
            else:
                px(d, x, y, C["b"])
    for y in range(10, 30):
        w = 10 - abs(y - 18) // 3
        for x in range(24 - w, 24 + w + 1):
            px(d, x, y, C["bl"])
    circ(d, 24, 20, 3, C["w"])
    px(d, 23, 19, C["w"])
    px(d, 25, 19, C["w"])
    return img


def draw_icon_dance():
    img = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    circ(d, 24, 8, 5, C["pl"])
    circ(d, 24, 8, 3, C["w"])
    rect(d, 22, 14, 26, 22, C["p"])
    rect(d, 16, 12, 22, 14, C["pl"])
    rect(d, 26, 12, 32, 14, C["pl"])
    rect(d, 16, 22, 20, 30, C["p"])
    rect(d, 28, 22, 32, 30, C["p"])
    circ(d, 18, 30, 2, C["pl"])
    circ(d, 30, 30, 2, C["pl"])
    px(d, 22, 7, C["bk"])
    px(d, 26, 7, C["bk"])
    for xx in range(22, 27):
        px(d, xx, 10, C["r"])
    px(d, 12, 8, C["y"])
    px(d, 36, 6, C["yl"])
    px(d, 8, 18, C["yl"])
    px(d, 40, 16, C["y"])
    return img


def draw_icon_pet():
    img = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    rect(d, 20, 6, 28, 38, C["brd"])
    rect(d, 21, 7, 27, 37, C["br"])
    for y in range(8, 36, 4):
        rect(d, 21, y, 27, y + 1, C["brl"])
    circ(d, 16, 8, 3, C["pl"])
    circ(d, 32, 8, 3, C["pl"])
    circ(d, 16, 38, 3, C["pl"])
    circ(d, 32, 38, 3, C["pl"])
    circ(d, 12, 22, 3, C["pl"])
    circ(d, 36, 22, 3, C["pl"])
    circ(d, 24, 20, 2, C["p"])
    return img


def gen_interaction():
    save(draw_icon_water(), "icon_water")
    save(draw_icon_light(), "icon_light")
    save(draw_icon_fertilize(), "icon_fertilize")
    save(draw_icon_touch(), "icon_touch")
    save(draw_icon_talk(), "icon_talk")
    save(draw_icon_sing(), "icon_sing")
    save(draw_icon_heal(), "icon_heal")
    save(draw_icon_play(), "icon_play")
    save(draw_icon_shield(), "icon_shield")
    save(draw_icon_dance(), "icon_dance")
    save(draw_icon_pet(), "icon_pet")
