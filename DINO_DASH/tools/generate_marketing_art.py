from PIL import Image, ImageDraw, ImageFont
from pathlib import Path
import math
import random

out = Path('/mnt/d/Openclaw/DINO_DASH/assets/marketing')
out.mkdir(parents=True, exist_ok=True)
font_bold = '/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf'

def font(size: int) -> ImageFont.FreeTypeFont:
    return ImageFont.truetype(font_bold, size)

def gradient(size, top, bottom):
    w, h = size
    img = Image.new('RGB', size)
    pix = img.load()
    for y in range(h):
        t = y / (h - 1)
        r = int(top[0] * (1 - t) + bottom[0] * t)
        g = int(top[1] * (1 - t) + bottom[1] * t)
        b = int(top[2] * (1 - t) + bottom[2] * t)
        for x in range(w):
            pix[x, y] = (r, g, b)
    return img.convert('RGBA')

def shadow_text(draw, xy, text, fnt, fill, stroke=(61, 30, 0), sw=8):
    x, y = xy
    draw.text((x + 5, y + 7), text, font=fnt, fill=(0, 0, 0, 95), stroke_width=sw, stroke_fill=(0, 0, 0, 95))
    draw.text((x, y), text, font=fnt, fill=fill, stroke_width=sw, stroke_fill=stroke)

def draw_star(draw, cx, cy, r, fill):
    pts = []
    for i in range(10):
        a = -math.pi / 2 + i * math.pi / 5
        rr = r if i % 2 == 0 else r * 0.45
        pts.append((cx + math.cos(a) * rr, cy + math.sin(a) * rr))
    draw.polygon(pts, fill=fill)

def draw_leaf(draw, x, y, s, color):
    draw.ellipse((x - s, y - s * 0.45, x + s, y + s * 0.45), fill=color, outline=(28, 83, 45), width=max(1, int(s * 0.08)))
    draw.line((x - s * 0.8, y + s * 0.05, x + s * 0.8, y - s * 0.05), fill=(28, 83, 45), width=max(1, int(s * 0.08)))

def draw_volcano(draw, base_y, offset=0, scale=1):
    draw.polygon([(60 * scale + offset, base_y), (210 * scale + offset, base_y - 210 * scale), (360 * scale + offset, base_y)], fill=(102, 51, 27), outline=(73, 31, 20))
    draw.polygon([(210 * scale + offset, base_y - 210 * scale), (170 * scale + offset, base_y - 120 * scale), (250 * scale + offset, base_y - 120 * scale)], fill=(47, 29, 22))
    draw.polygon([(188 * scale + offset, base_y - 160 * scale), (210 * scale + offset, base_y - 210 * scale), (232 * scale + offset, base_y - 160 * scale)], fill=(255, 107, 53))
    draw.ellipse((180 * scale + offset, base_y - 230 * scale, 240 * scale + offset, base_y - 190 * scale), fill=(255, 187, 51))

def draw_egg(draw, cx, cy, w, h, cracked=True, base=(255, 244, 180), accent=(255, 207, 72)):
    box = (cx - w / 2, cy - h / 2, cx + w / 2, cy + h / 2)
    draw.ellipse(box, fill=base, outline=(138, 91, 22), width=max(4, int(w * 0.035)))
    draw.ellipse((cx - w * 0.23, cy - h * 0.28, cx + w * 0.12, cy + h * 0.08), fill=(255, 255, 235, 120))
    for dx, dy, rr in [(-0.22, 0.18, 0.055), (0.2, 0.1, 0.047), (0.08, -0.18, 0.04)]:
        draw.ellipse((cx + w * dx - w * rr, cy + h * dy - h * rr, cx + w * dx + w * rr, cy + h * dy + h * rr), fill=accent)
    if cracked:
        pts = [(cx - w * 0.35, cy - h * 0.08), (cx - w * 0.17, cy + h * 0.01), (cx - w * 0.05, cy - h * 0.05), (cx + w * 0.08, cy + h * 0.04), (cx + w * 0.23, cy - h * 0.02), (cx + w * 0.36, cy + h * 0.06)]
        draw.line(pts, fill=(92, 60, 22), width=max(4, int(w * 0.025)), joint='curve')

def draw_dino(draw, cx, cy, s, body=(52, 211, 153), belly=(190, 242, 100)):
    draw.polygon([(cx - s * 1.0, cy + s * 0.28), (cx - s * 0.26, cy + s * 0.08), (cx - s * 0.54, cy + s * 0.47)], fill=(34, 197, 94), outline=(21, 128, 61))
    draw.ellipse((cx - s * 0.45, cy - s * 0.05, cx + s * 0.38, cy + s * 0.72), fill=body, outline=(21, 128, 61), width=max(3, int(s * 0.035)))
    draw.ellipse((cx - s * 0.16, cy + s * 0.16, cx + s * 0.25, cy + s * 0.62), fill=belly)
    draw.ellipse((cx - s * 0.18, cy - s * 0.62, cx + s * 0.58, cy + s * 0.12), fill=body, outline=(21, 128, 61), width=max(3, int(s * 0.035)))
    draw.ellipse((cx + s * 0.22, cy - s * 0.33, cx + s * 0.78, cy + s * 0.02), fill=body, outline=(21, 128, 61), width=max(2, int(s * 0.025)))
    draw.arc((cx + s * 0.26, cy - s * 0.23, cx + s * 0.74, cy + s * 0.04), 15, 165, fill=(80, 37, 22), width=max(3, int(s * 0.025)))
    for ex in [cx + s * 0.05, cx + s * 0.36]:
        draw.ellipse((ex - s * 0.055, cy - s * 0.36, ex + s * 0.055, cy - s * 0.25), fill='white')
        draw.ellipse((ex - s * 0.02, cy - s * 0.33, ex + s * 0.025, cy - s * 0.275), fill=(15, 23, 42))
    for i in range(5):
        x = cx - s * 0.14 + i * s * 0.14
        draw.polygon([(x, cy - s * 0.54), (x + s * 0.07, cy - s * 0.77), (x + s * 0.14, cy - s * 0.52)], fill=(250, 204, 21), outline=(133, 77, 14))
    draw.ellipse((cx + s * 0.23, cy + s * 0.08, cx + s * 0.5, cy + s * 0.22), fill=body, outline=(21, 128, 61))
    draw.ellipse((cx - s * 0.36, cy + s * 0.55, cx - s * 0.08, cy + s * 0.82), fill=(34, 197, 94), outline=(21, 128, 61))
    draw.ellipse((cx + s * 0.16, cy + s * 0.54, cx + s * 0.48, cy + s * 0.82), fill=(34, 197, 94), outline=(21, 128, 61))

# ICON
W = H = 1024
img = gradient((W, H), (53, 189, 255), (15, 118, 110))
d = ImageDraw.Draw(img, 'RGBA')
for r, alpha in [(360, 35), (260, 55), (170, 85)]:
    d.ellipse((W - 210 - r, H * 0.2 - r, W - 210 + r, H * 0.2 + r), fill=(255, 214, 102, alpha))
draw_volcano(d, 660, -20, 1.1)
d.ellipse((-220, 520, 520, 980), fill=(22, 163, 74, 210))
d.ellipse((400, 545, 1250, 1010), fill=(34, 197, 94, 220))
random.seed(9)
for _ in range(28):
    x = random.randint(40, W - 40)
    y = random.randint(130, 840)
    if random.random() < 0.45:
        draw_star(d, x, y, random.randint(9, 22), (255, 244, 128, 190))
    else:
        draw_leaf(d, x, y, random.randint(13, 28), (74, 222, 128, 190))
draw_egg(d, W / 2, 605, 520, 600, True)
draw_dino(d, W / 2 - 10, 445, 270)
for cx, cy, w, h, col in [(190, 800, 150, 190, (203, 213, 225)), (820, 795, 165, 205, (252, 165, 165)), (710, 880, 115, 145, (196, 181, 253)), (310, 890, 120, 150, (147, 197, 253))]:
    draw_egg(d, cx, cy, w, h, False, col, (250, 204, 21))
badge = Image.new('RGBA', (900, 210), (0, 0, 0, 0))
bd = ImageDraw.Draw(badge, 'RGBA')
bd.rounded_rectangle((18, 35, 882, 180), radius=44, fill=(15, 23, 42, 225), outline=(250, 204, 21, 255), width=8)
shadow_text(bd, (80, 42), 'DINO', font(76), (255, 255, 255), stroke=(20, 83, 45), sw=5)
shadow_text(bd, (375, 30), 'DASH', font(92), (250, 204, 21), stroke=(124, 45, 18), sw=6)
img.alpha_composite(badge, (62, 30))
icon_path = out / 'dino-dash-icon-1024.png'
img.convert('RGB').save(icon_path, quality=95)
img.resize((512, 512), Image.Resampling.LANCZOS).save(out / 'dino-dash-icon-512.png')

# THUMBNAIL
W, H = 1920, 1080
thumb = gradient((W, H), (56, 189, 248), (20, 184, 166))
d = ImageDraw.Draw(thumb, 'RGBA')
for r, alpha in [(520, 30), (370, 55), (250, 85)]:
    d.ellipse((1550 - r, 160 - r, 1550 + r, 160 + r), fill=(255, 220, 110, alpha))
draw_volcano(d, 760, 70, 1.35)
draw_volcano(d, 800, 1210, 0.95)
d.ellipse((-250, 650, 1350, 1300), fill=(34, 197, 94, 230))
d.ellipse((700, 620, 2200, 1320), fill=(22, 163, 74, 230))
d.polygon([(760, 1080), (1010, 625), (1220, 1080)], fill=(251, 191, 36, 160))
for x, y, s in [(330, 760, 185), (500, 835, 135), (1350, 830, 150), (1515, 760, 110)]:
    draw_egg(d, x, y, s * 0.7, s, False, (254, 249, 195), (96, 165, 250))
draw_egg(d, 930, 710, 470, 545, True, (255, 244, 180), (251, 146, 60))
draw_dino(d, 905, 520, 255)
draw_dino(d, 520, 720, 155, (96, 165, 250), (191, 219, 254))
draw_dino(d, 1350, 715, 170, (168, 85, 247), (233, 213, 255))
for x, y, text, color in [(155, 405, 'HATCH\nRARE DINOS', (250, 204, 21)), (1420, 420, 'UPGRADE\nYOUR NEST', (129, 140, 248))]:
    d.rounded_rectangle((x, y, x + 350, y + 170), radius=28, fill=(15, 23, 42, 220), outline=color, width=7)
    lines = text.split('\n')
    for j, line in enumerate(lines):
        bbox = d.textbbox((0, 0), line, font=font(48))
        tw = bbox[2] - bbox[0]
        shadow_text(d, (x + 175 - tw / 2, y + 28 + j * 58), line, font(48), (255, 255, 255) if j == 0 else color, sw=3)
random.seed(12)
for _ in range(80):
    x = random.randint(30, W - 30)
    y = random.randint(80, 950)
    if random.random() < 0.65:
        draw_star(d, x, y, random.randint(6, 18), (255, 245, 157, 170))
    else:
        draw_leaf(d, x, y, random.randint(10, 24), (134, 239, 172, 170))
shadow_text(d, (90, 70), 'DINO', font(120), (255, 255, 255), stroke=(20, 83, 45), sw=9)
shadow_text(d, (90, 190), 'DASH', font(150), (250, 204, 21), stroke=(124, 45, 18), sw=11)
shadow_text(d, (95, 360), 'Hatch • Upgrade • Collect', font(46), (236, 253, 245), stroke=(15, 23, 42), sw=4)
thumb_path = out / 'dino-dash-thumbnail-1920x1080.png'
thumb.convert('RGB').save(thumb_path, quality=95)
thumb.resize((1280, 720), Image.Resampling.LANCZOS).save(out / 'dino-dash-thumbnail-1280x720.png')

print(icon_path)
print(out / 'dino-dash-icon-512.png')
print(thumb_path)
print(out / 'dino-dash-thumbnail-1280x720.png')
