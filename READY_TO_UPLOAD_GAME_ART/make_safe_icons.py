from PIL import Image, ImageEnhance
from pathlib import Path
src = Path(r'D:\Openclaw\READY_TO_UPLOAD_GAME_ART\UPLOAD_GAME_ICON_1024_MASTER.png')
out = Path(r'D:\Openclaw\READY_TO_UPLOAD_GAME_ART')
im = Image.open(src).convert('RGB')
# Make strict Roblox-safe square versions, no alpha, normal RGB.
for size in [512, 1024]:
    x = im.resize((size, size), Image.Resampling.LANCZOS)
    x = ImageEnhance.Color(x).enhance(1.10)
    x = ImageEnhance.Contrast(x).enhance(1.06)
    x.save(out / f'ROBLOX_SAFE_ICON_{size}.png', optimize=True)
    x.save(out / f'ROBLOX_SAFE_ICON_{size}.jpg', quality=90, optimize=True, progressive=False)
# Extra small for picky uploader/network issues.
x = im.resize((512,512), Image.Resampling.LANCZOS)
x.save(out / 'TRY_THIS_FIRST_ICON_512_JPG.jpg', quality=85, optimize=True, progressive=False)
x.save(out / 'TRY_THIS_FIRST_ICON_512_PNG.png', optimize=True)
for p in sorted(out.glob('*ICON*')):
    print(p.name, p.stat().st_size)
