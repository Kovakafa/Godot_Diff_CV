import os
import cv2
import numpy as np

# ----------- AYARLAR ------------
# HSV eşiği 
HUE_THRESH  = 10
SAT_THRESH  = 30

# Kontur filtresi
MIN_AREA    = 300      # Kutucuk çizmek için minimum bölge alanı
AR_MIN      = 0.01       # Aspect ratio min (w/h)
AR_MAX      = 5.0       # Aspect ratio max (w/h)

# Morfoloji çekirdekleri
OPEN_KSIZE   = (3, 3)
CLOSE_KSIZE  = (7, 7)

SHOW_DEBUG   = True     # Maskeleri de göster
# --------------------------------

# 1) Yol kurulum
script_dir   = os.path.dirname(os.path.abspath(__file__))
project_root = os.path.abspath(os.path.join(script_dir, os.pardir))
shots_dir    = os.path.join(project_root, "screenshots")
full_path    = os.path.join(shots_dir, "full_scene.png")
bg_path      = os.path.join(shots_dir, "background_only.png")

# 2) Görüntüleri yükle
full = cv2.imread(full_path)
bg   = cv2.imread(bg_path)
if full is None or bg is None:
    raise FileNotFoundError(f"Images not found:\n {full_path}\n {bg_path}")

# 3) Gerekirse döndür
full = cv2.flip(full, -1)
bg   = cv2.flip(bg,   -1)

# 4) HSV'ye çevir ve H/S kanalları al
hsv_full = cv2.cvtColor(full, cv2.COLOR_BGR2HSV)
hsv_bg   = cv2.cvtColor(bg,   cv2.COLOR_BGR2HSV)
h_full, s_full, _ = cv2.split(hsv_full)
h_bg,   s_bg,   _ = cv2.split(hsv_bg)

# 5) Hue & Sat mutlak farkı
dh = cv2.absdiff(h_full, h_bg)
ds = cv2.absdiff(s_full, s_bg)

# 6) Binary mask (H veya S farkına göre)
_, mh = cv2.threshold(dh, HUE_THRESH, 255, cv2.THRESH_BINARY)
_, ms = cv2.threshold(ds, SAT_THRESH, 255, cv2.THRESH_BINARY)
mask  = cv2.bitwise_or(mh, ms)

if SHOW_DEBUG:
    cv2.imshow("Raw HSV Mask", mask)

# 7) Morfoloji (gürültü temizleme)
open_k  = cv2.getStructuringElement(cv2.MORPH_RECT, OPEN_KSIZE) # Erosion
close_k = cv2.getStructuringElement(cv2.MORPH_RECT, CLOSE_KSIZE) # Dilation
mask    = cv2.morphologyEx(mask, cv2.MORPH_OPEN,  open_k,  iterations=1)
mask    = cv2.morphologyEx(mask, cv2.MORPH_CLOSE, close_k, iterations=1)

if SHOW_DEBUG:
    cv2.imshow("Clean HSV Mask", mask)

# 8) Kontur bul ve filtrele
cnts, _ = cv2.findContours(mask, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)
out = full.copy()
for c in cnts:
    area = cv2.contourArea(c)
    if area < MIN_AREA:
        continue
    x,y,w,h = cv2.boundingRect(c)
    ar = w/float(h) if h>0 else 0
    if ar < AR_MIN or ar > AR_MAX:
        continue
    cv2.rectangle(out, (x,y), (x+w,y+h), (0,0,255), 2)

# 9) Sonucu göster & kaydet
cv2.imshow("Differences", out)
out_path = os.path.join(shots_dir, "differences_marked.png")
cv2.imwrite(out_path, out)
print(f"✅ Saved: {out_path}")
print("Press 'q' to close windows.")

# 10) 'q' tuşu ile çıkış
while True:
    if cv2.waitKey(10) & 0xFF == ord('q'):
        break

cv2.destroyAllWindows()
