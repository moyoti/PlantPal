# Part 2: Tab icon drawing functions


def draw_tab_garden():
    img = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    rect(d, 14, 30, 33, 38, C["br"])
    rect(d, 16, 28, 31, 29, C["brd"])
    rect(d, 15, 39, 32, 41, C["brd"])
    rect(d, 15, 28, 30, 29, C["brl"])
    rect(d, 23, 16, 25, 28, C["gd"])
    circ(d, 19, 17, 4, C["g"])
    circ(d, 19, 17, 2, C["gl"])
    circ(d, 29, 17, 4, C["g"])
    circ(d, 29, 17, 2, C["gl"])
    circ(d, 24, 12, 4, C["p"])
    circ(d, 24, 12, 2, C["y"])
    px(d, 12, 14, C["y"])
    px(d, 34, 12, C["yl"])
    return img


def draw_tab_collection():
    img = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    rect(d, 8, 12, 39, 38, C["pu"])
    rect(d, 9, 13, 38, 37, C["pul"])
    rect(d, 8, 12, 11, 38, C["pu"])
    rect(d, 12, 15, 36, 18, C["cr"])
    rect(d, 12, 21, 36, 24, C["cr"])
    rect(d, 12, 27, 36, 30, C["cr"])
    rect(d, 12, 33, 36, 35, C["cr"])
    circ(d, 24, 8, 3, C["y"])
    px(d, 24, 4, C["yl"])
    px(d, 24, 12, C["yl"])
    px(d, 20, 8, C["yl"])
    px(d, 28, 8, C["yl"])
    px(d, 15, 8, C["yl"])
    px(d, 33, 9, C["yl"])
    return img


def draw_tab_settings():
    img = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    circ(d, 24, 24, 8, C["gy"])
    circ(d, 24, 24, 5, C["gyl"])
    circ(d, 24, 24, 3, C["w"])
    for i in range(8):
        a = i * math.pi / 4
        cx = 24 + int(10 * math.cos(a))
        cy = 24 + int(10 * math.sin(a))
        rect(d, cx - 2, cy - 2, cx + 2, cy + 2, C["gy"])
        px(d, cx - 1, cy - 1, C["gyl"])
    px(d, 22, 23, C["bk"])
    px(d, 26, 23, C["bk"])
    px(d, 23, 26, C["pl"])
    px(d, 25, 26, C["pl"])
    return img


def gen_tabs():
    save(draw_tab_garden(), "tab_garden")
    save(draw_tab_collection(), "tab_collection")
    save(draw_tab_settings(), "tab_settings")
