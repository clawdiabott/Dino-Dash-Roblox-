from PIL import Image, ImageDraw, ImageFont, ImageFilter, ImageEnhance
from pathlib import Path
out=Path(r'D:\Openclaw\GRASS_GOBBLER_COW_CONTEST\assets\marketing')
out.mkdir(parents=True, exist_ok=True)

def font(size):
    for f in [r'C:\Windows\Fonts\impact.ttf', r'C:\Windows\Fonts\arialbd.ttf', r'C:\Windows\Fonts\segoeuib.ttf']:
        try: return ImageFont.truetype(f,size)
        except: pass
    return ImageFont.load_default()

def text_center(draw, box, text, fnt, fill, stroke=(0,0,0), sw=4):
    bbox=draw.textbbox((0,0),text,font=fnt,stroke_width=sw)
    x=box[0]+(box[2]-box[0]-(bbox[2]-bbox[0]))/2
    y=box[1]+(box[3]-box[1]-(bbox[3]-bbox[1]))/2
    draw.text((x,y),text,font=fnt,fill=fill,stroke_width=sw,stroke_fill=stroke)

def cow(draw,cx,cy,s):
    # body/head
    draw.ellipse((cx-170*s,cy-90*s,cx+170*s,cy+105*s),fill=(245,245,235),outline=(20,20,20),width=int(7*s))
    draw.ellipse((cx-105*s,cy-205*s,cx+105*s,cy-35*s),fill=(245,245,235),outline=(20,20,20),width=int(7*s))
    # spots
    draw.ellipse((cx-120*s,cy-45*s,cx-25*s,cy+45*s),fill=(20,20,20))
    draw.ellipse((cx+35*s,cy+5*s,cx+135*s,cy+75*s),fill=(20,20,20))
    draw.ellipse((cx+18*s,cy-175*s,cx+80*s,cy-118*s),fill=(20,20,20))
    # eyes muzzle horns
    draw.ellipse((cx-50*s,cy-140*s,cx-25*s,cy-115*s),fill=(0,0,0))
    draw.ellipse((cx+25*s,cy-140*s,cx+50*s,cy-115*s),fill=(0,0,0))
    draw.ellipse((cx-70*s,cy-95*s,cx+70*s,cy-35*s),fill=(245,190,190),outline=(80,40,40),width=int(4*s))
    draw.ellipse((cx-32*s,cy-70*s,cx-12*s,cy-50*s),fill=(70,40,40))
    draw.ellipse((cx+12*s,cy-70*s,cx+32*s,cy-50*s),fill=(70,40,40))
    draw.polygon([(cx-80*s,cy-175*s),(cx-150*s,cy-230*s),(cx-95*s,cy-135*s)],fill=(235,220,170),outline=(20,20,20))
    draw.polygon([(cx+80*s,cy-175*s),(cx+150*s,cy-230*s),(cx+95*s,cy-135*s)],fill=(235,220,170),outline=(20,20,20))

# thumbnail
W,H=1920,1080
img=Image.new('RGB',(W,H),(80,190,70))
d=ImageDraw.Draw(img)
# sky/field gradients
for y in range(H):
    if y<430:
        c=(90-int(y*0.05),180-int(y*0.12),255-int(y*0.18))
    else:
        c=(60+int((y-430)*0.02),170+int((y-430)*0.03),55)
    d.line((0,y,W,y),fill=c)
# grass patches
import random
random.seed(12)
for i in range(260):
    x=random.randint(0,W); y=random.randint(420,H); l=random.randint(20,70)
    col=random.choice([(30,230,60),(80,255,80),(190,240,50),(20,160,40)])
    d.line((x,y,x+random.randint(-20,20),y-l),fill=col,width=random.randint(4,9))
# timer and text
cow(d, 960, 610, 1.65)
text_center(d,(0,35,W,210),'GRASS GOBBLER',font(150),(255,255,70),(0,90,0),9)
text_center(d,(0,215,W,330),'EAT GRASS • ADD TIME • GO INFINITE',font(64),(255,255,255),(0,0,0),6)
text_center(d,(55,805,640,970),'60 SEC START',font(86),(255,80,80),(0,0,0),7)
text_center(d,(1270,805,1880,970),'MULTIPLIER!',font(92),(120,255,90),(0,0,0),7)
# border
for i,c in enumerate([(255,255,0),(0,255,80),(255,255,255)]):
    d.rounded_rectangle((18+i*10,18+i*10,W-18-i*10,H-18-i*10),radius=35,outline=c,width=6)
img=ImageEnhance.Contrast(img).enhance(1.08)
img=ImageEnhance.Color(img).enhance(1.12)
img.save(out/'UPLOAD_THUMBNAIL_1920x1080.png',optimize=True)
img.save(out/'UPLOAD_THUMBNAIL_1920x1080.jpg',quality=91,optimize=True,progressive=False)
# icon square crop/recompose
S=512
icon=Image.new('RGB',(S,S),(70,190,60))
id=ImageDraw.Draw(icon)
for y in range(S):
    c=(70,190+min(40,y//10),65) if y>180 else (90,190,250)
    id.line((0,y,S,y),fill=c)
cow(id,256,325,0.62)
text_center(id,(0,8,S,120),'COW',font(92),(255,255,70),(0,80,0),5)
text_center(id,(0,110,S,185),'CHOW',font(92),(255,255,255),(0,0,0),5)
for i,c in enumerate([(255,255,0),(0,255,80)]):
    id.rounded_rectangle((8+i*7,8+i*7,S-8-i*7,S-8-i*7),radius=22,outline=c,width=5)
icon.save(out/'UPLOAD_GAME_ICON_512.png',optimize=True)
icon.save(out/'UPLOAD_GAME_ICON_512.jpg',quality=90,optimize=True,progressive=False)
print('created')
for p in out.iterdir(): print(p, p.stat().st_size)
