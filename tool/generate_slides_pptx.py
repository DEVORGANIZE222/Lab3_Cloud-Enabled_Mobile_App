"""Editable PowerPoint version of the Lab 3 deck, for Canva or PowerPoint.

Same 17 slides as tool/generate_slides_pdf.dart, but every title, text, card, chip and
number is a native text box or shape, so it can be edited after importing the .pptx
into Canva. Screenshots become phone or browser-frame pictures. Numbers and "verified"
states are read from the repository, as in the PDF deck.

  pip install python-pptx pillow
  python tool/generate_slides_pptx.py        (from the repository root)
"""

from __future__ import annotations

import re
import tempfile
from pathlib import Path

from PIL import Image, ImageDraw, ImageFont
from pptx import Presentation
from pptx.dml.color import RGBColor
from pptx.enum.shapes import MSO_SHAPE
from pptx.enum.text import MSO_ANCHOR, PP_ALIGN
from pptx.util import Pt

ROOT = Path(__file__).resolve().parent.parent
OUT = ROOT / "slides" / "Lab03_DEVORGANIZE222_slides.pptx"
TMP = Path(tempfile.mkdtemp(prefix="exematching-pptx-"))

# Fonts Canva offers; PowerPoint substitutes them if they are not installed.
HEAD, BODY = "Montserrat", "Open Sans"

GREEN900, GREEN800, GREEN, GREEN100 = "052E16", "14532D", "15803D", "DCFCE7"
ORANGE, ORANGE100 = "B4530A", "FDE8DA"
INK, MUTED, LINE, PAPER = "1A1D1E", "596066", "E1E3E5", "F6F8F4"
RED, RED100, BLUE, BLUE100 = "B91C1C", "FEE2E2", "1D4ED8", "DBEAFE"
MINT, MINT_TEXT, WHITE = "86EFAC", "D1FAE5", "FFFFFF"

# Material icon code points, the same constants as the Dart deck (tool/fonts/material_icons_subset.ttf).
ICONS = {
    m.group(1): int(m.group(2), 16)
    for m in re.finditer(r"\b(i[A-Z]\w*) = (0x[0-9a-f]+)", (ROOT / "tool" / "generate_slides_pdf.dart").read_text(encoding="utf-8"))
}
ICON_FONT = ROOT / "tool" / "fonts" / "material_icons_subset.ttf"

# Text widths are estimated with local fonts and a margin, because Montserrat / Open Sans
# are wider than Segoe UI.
_MEASURE = {False: "C:/Windows/Fonts/arial.ttf", True: "C:/Windows/Fonts/arialbd.ttf"}


def text_width(text: str, size: float, bold: bool = False, head: bool = False) -> float:
    try:
        font = ImageFont.truetype(_MEASURE[bold], 100)
        w = font.getlength(text) * size / 100
    except OSError:
        w = len(text) * size * 0.55
    return w * (1.16 if head else 1.08)


def wrap_lines(text: str, size: float, width: float, bold: bool = False) -> int:
    lines = 0
    for paragraph in text.split("\n"):
        line = ""
        lines += 1
        for word in paragraph.split(" "):
            trial = f"{line} {word}".strip()
            if text_width(trial, size, bold) > width and line:
                lines += 1
                line = word
            else:
                line = trial
    return lines


def rgb(hex_: str) -> RGBColor:
    return RGBColor.from_string(hex_)


# ---------------------------------------------------------------- repository data
def read_junit(path: str) -> dict[str, list[bool]]:
    file = ROOT / path
    outcome: dict[str, bool] = {}
    if file.exists():
        xml = file.read_text(encoding="utf-8")
        for m in re.finditer(r'<testcase [^>]*name="(test_tc\d+[^"]*\[run\d+\])"[^>]*?(/>|>([\s\S]*?)</testcase>)', xml):
            failed = "<failure" in (m.group(3) or "") or "<error" in (m.group(3) or "")
            outcome[m.group(1)] = outcome.get(m.group(1), True) and not failed
    runs: dict[str, list[bool]] = {}
    for name in sorted(outcome):
        runs.setdefault("TC-" + re.search(r"test_tc(\d+)", name).group(1), []).append(outcome[name])
    return runs


def passed_of(runs):
    return sum(ok for r in runs.values() for ok in r)


def total_of(runs):
    return sum(len(r) for r in runs.values())


def captured(files) -> bool:
    return all((ROOT / f).exists() for f in files)


def count_matches(folder: str, pattern: str) -> int:
    return sum(len(re.findall(pattern, p.read_text(encoding="utf-8"))) for p in (ROOT / folder).rglob("*.dart"))


FINAL = read_junit("e2e_test/evidence/junit.xml")
ATTEMPTS = [
    ("Attempt 1", read_junit("e2e_test/evidence-attempt1/junit.xml")),
    ("Attempt 2", read_junit("e2e_test/evidence-attempt2/junit.xml")),
    ("Final run", FINAL),
]
UI_FIREBASE_IMPORTS = count_matches("lib/screens", r"import 'package:(firebase|cloud_firestore)") + count_matches(
    "lib/widgets", r"import 'package:(firebase|cloud_firestore)")
TRANSACTIONS = count_matches("lib/firebase", r"runTransaction\(")
_rules = (ROOT / "firebase" / "firestore.rules").read_text(encoding="utf-8") if (ROOT / "firebase" / "firestore.rules").exists() else ""
_has_only = re.search(r"hasOnly\(\s*\[([^\]]*)\]", _rules)
WRITABLE_FIELDS = len(re.findall(r"'[^']+'", _has_only.group(1))) if _has_only else 0
EVIDENCE = {
    "Authentication": ["evidence/console/console_auth_users.jpg"],
    "Firestore": ["evidence/console/console_firestore_teams.jpg", "evidence/console/console_firestore_rules_teams.jpg"],
    "Storage": ["evidence/console/console_storage_files.jpg", "evidence/console/console_storage_rules.jpg"],
    "Cloud Messaging": ["evidence/fcm/foreground_alerts.png", "evidence/fcm/background_opened.png", "evidence/fcm/terminated_opened.png"],
    "Analytics": ["evidence/debugview/debugview_login_user_id.jpg", "evidence/debugview/debugview_search_teams_params.jpg",
                  "evidence/debugview/debugview_cast_vote_params.jpg"],
    "Crashlytics": ["evidence/crashlytics/crashlytics_nonfatal_keys.jpg", "evidence/crashlytics/crashlytics_crash_keys.jpg",
                    "evidence/crashlytics/crashlytics_crash_user.jpg"],
    "Remote Config": ["evidence/remote_config/app_before.png", "evidence/remote_config/console_published.jpg",
                      "evidence/remote_config/app_after.png"],
}
_summary = ROOT / "e2e_test" / "exploratory" / "summary.txt"
EXPLORATORY = [re.sub(r"^[-•]\s*", "", l).strip() for l in _summary.read_text(encoding="utf-8").splitlines() if l.strip()] if _summary.exists() else []


# ---------------------------------------------------------------- images made with Pillow
SCALE = 4  # pixels per point for generated pictures


def icon_png(code: int, color: str, size: float) -> Path:
    path = TMP / f"icon_{code:x}_{color}_{int(size)}.png"
    if not path.exists():
        px = int(size * SCALE)
        img = Image.new("RGBA", (px, px), (0, 0, 0, 0))
        font = ImageFont.truetype(str(ICON_FONT), px)
        ImageDraw.Draw(img).text((0, 0), chr(code), font=font, fill="#" + color)
        img.save(path)
    return path


def rounded(img: Image.Image, radius: int) -> Image.Image:
    mask = Image.new("L", img.size, 0)
    ImageDraw.Draw(mask).rounded_rectangle((0, 0, img.width - 1, img.height - 1), radius, fill=255)
    out = Image.new("RGBA", img.size, (0, 0, 0, 0))
    out.paste(img.convert("RGBA"), (0, 0), mask)
    return out


def phone_png(path: str, h: float) -> Path | None:
    src = ROOT / path
    if not src.exists():
        return None
    out = TMP / f"phone_{abs(hash((path, h)))}.png"
    w = h * 0.45
    sw, sh = int(w * SCALE), int(h * SCALE)
    screen = Image.open(src).convert("RGB")
    ratio = max(sw / screen.width, sh / screen.height)
    screen = screen.resize((int(screen.width * ratio) + 1, int(screen.height * ratio) + 1), Image.LANCZOS)
    screen = screen.crop((0, 0, sw, sh))
    pad = 4 * SCALE
    frame = Image.new("RGBA", (sw + 2 * pad, sh + 2 * pad), (0, 0, 0, 0))
    ImageDraw.Draw(frame).rounded_rectangle((0, 0, frame.width - 1, frame.height - 1), int(h * 0.06 * SCALE), fill="#111827")
    frame.alpha_composite(rounded(screen, int(h * 0.05 * SCALE)), (pad, pad))
    frame.save(out)
    return out


def browser_png(path: str, w: float, h: float | None) -> tuple[Path | None, float]:
    src = ROOT / path
    if not src.exists():
        return None, (h or w * 0.6) + 16
    shot = Image.open(src).convert("RGB")
    pw_, bar = int(w * SCALE), 16 * SCALE
    body_h = int(pw_ * shot.height / shot.width)
    shot = shot.resize((pw_, body_h), Image.LANCZOS)
    if h is not None:
        shot = shot.crop((0, 0, pw_, min(body_h, int(h * SCALE))))
    img = Image.new("RGB", (pw_, bar + shot.height), "white")
    d = ImageDraw.Draw(img)
    d.rectangle((0, 0, pw_, bar), fill="#EEF0F2")
    for i, c in enumerate(["#F87171", "#FBBF24", "#34D399"]):
        cx = (11 + i * 10) * SCALE
        d.ellipse((cx - 3 * SCALE, bar // 2 - 3 * SCALE, cx + 3 * SCALE, bar // 2 + 3 * SCALE), fill=c)
    try:
        d.text((48 * SCALE, bar // 2), "console.firebase.google.com", fill="#596066", anchor="lm",
               font=ImageFont.truetype("C:/Windows/Fonts/segoeui.ttf", int(6.5 * SCALE)))
    except OSError:
        pass
    img.paste(shot, (0, bar))
    framed = rounded(img, 10 * SCALE)
    ImageDraw.Draw(framed).rounded_rectangle((0, 0, framed.width - 1, framed.height - 1), 10 * SCALE, outline="#E1E3E5", width=SCALE)
    out = TMP / f"browser_{abs(hash((path, w, h)))}.png"
    framed.save(out)
    return out, framed.height / SCALE


def circle_photo(path: str) -> Path | None:
    src = ROOT / path
    if not src.exists():
        return None
    img = Image.open(src).convert("RGB")
    side = min(img.size)
    img = img.crop(((img.width - side) // 2, (img.height - side) // 2, (img.width + side) // 2, (img.height + side) // 2)).resize((400, 400))
    mask = Image.new("L", (400, 400), 0)
    ImageDraw.Draw(mask).ellipse((0, 0, 399, 399), fill=255)
    out = Image.new("RGBA", (400, 400), (0, 0, 0, 0))
    out.paste(img, (0, 0), mask)
    p = TMP / "persona.png"
    out.save(p)
    return p


# ---------------------------------------------------------------- drawing helpers (all sizes in points)
prs = Presentation()
prs.slide_width, prs.slide_height = Pt(960), Pt(540)
BLANK = prs.slide_layouts[6]


def shape(slide, kind, x, y, w, h, fill=None, line=None, radius=None, name=None):
    s = slide.shapes.add_shape(kind, Pt(x), Pt(y), Pt(w), Pt(h))
    s.shadow.inherit = False
    if fill:
        s.fill.solid()
        s.fill.fore_color.rgb = rgb(fill)
    else:
        s.fill.background()
    if line:
        s.line.color.rgb = rgb(line)
        s.line.width = Pt(0.8)
    else:
        s.line.fill.background()
    if radius is not None and kind == MSO_SHAPE.ROUNDED_RECTANGLE:
        s.adjustments[0] = min(0.5, radius / min(w, h))
    if name:
        s.name = name
    s.text_frame.text = ""
    return s


def box(slide, x, y, w, h, fill=WHITE, line=LINE, radius=14, name=None):
    return shape(slide, MSO_SHAPE.ROUNDED_RECTANGLE, x, y, w, h, fill, line, radius, name)


def text(slide, x, y, w, h, value, size, color=INK, bold=False, italic=False, head=False, align=PP_ALIGN.LEFT,
         anchor=MSO_ANCHOR.TOP, spacing=None, line_spacing=None, name=None):
    tb = slide.shapes.add_textbox(Pt(x), Pt(y), Pt(w), Pt(h))
    tf = tb.text_frame
    tf.word_wrap = True
    tf.margin_left = tf.margin_right = tf.margin_top = tf.margin_bottom = 0
    tf.vertical_anchor = anchor
    for i, para in enumerate(value.split("\n")):
        p = tf.paragraphs[0] if i == 0 else tf.add_paragraph()
        p.alignment = align
        if line_spacing:
            p.line_spacing = line_spacing
        r = p.add_run()
        r.text = para
        f = r.font
        f.size, f.bold, f.italic, f.name = Pt(size), bold, italic, HEAD if head else BODY
        f.color.rgb = rgb(color)
        if spacing:
            r._r.get_or_add_rPr().set("spc", str(int(spacing * 100)))
    if name:
        tb.name = name
    return tb


def icon(slide, key, x, y, size, color=GREEN):
    slide.shapes.add_picture(str(icon_png(ICONS[key], color, size)), Pt(x), Pt(y), Pt(size), Pt(size))


def bubble(slide, key, x, y, d, color=GREEN, bg=GREEN100):
    shape(slide, MSO_SHAPE.OVAL, x, y, d, d, bg)
    icon(slide, key, x + d * 0.24, y + d * 0.24, d * 0.52, color)


def chip(slide, x, y, value, bg=GREEN100, fg=GREEN800, size=9, icon_key=None) -> float:
    pad, gap = 9, (size + 6 if icon_key else 0)
    w = text_width(value, size, bold=True) + 2 * pad + gap
    h = size + 9
    box(slide, x, y, w, h, bg, None, h / 2)
    if icon_key:
        icon(slide, icon_key, x + pad - 1, y + (h - size - 2) / 2, size + 2, fg)
    text(slide, x + pad + gap, y, w - 2 * pad - gap + 4, h, value, size, fg, bold=True, anchor=MSO_ANCHOR.MIDDLE)
    return w


def chips(slide, x, y, width, items, gap=6) -> float:
    """items: (text, kwargs); wraps inside width; returns the bottom y."""
    cx, cy, row_h = x, y, 0
    for value, kw in items:
        w = text_width(value, kw.get("size", 9), True) + 18 + (kw.get("size", 9) + 6 if kw.get("icon_key") else 0)
        if cx + w > x + width and cx > x:
            cx, cy = x, cy + row_h + gap
        chip(slide, cx, cy, value, **kw)
        cx += w + gap
        row_h = kw.get("size", 9) + 9
    return cy + row_h


def point(slide, key, title, body, x, y, w, color=GREEN, bg=GREEN100, big=False) -> float:
    d, ts, bs, gap = (42, 16, 12, 14) if big else (28, 12, 10, 10)
    bubble(slide, key, x, y, d, color, bg)
    tw = w - d - gap
    th = wrap_lines(title, ts, tw, True) * ts * 1.3
    bh = wrap_lines(body, bs, tw) * bs * 1.35
    text(slide, x + d + gap, y, tw, th, title, ts, bold=True)
    text(slide, x + d + gap, y + th + 1, tw, bh, body, bs, MUTED)
    return y + max(d, th + bh) + (22 if big else 10)


def phone(slide, path, x, y, h, label=None, label_orange=False, rotation=0.0):
    img = phone_png(path, h)
    w = h * 0.45 + 8
    if img is None:
        box(slide, x, y, w, h + 8, RED100, None, 8)
        text(slide, x + 4, y + h / 2, w - 8, 20, f"missing\n{path}", 7, RED, align=PP_ALIGN.CENTER)
    else:
        pic = slide.shapes.add_picture(str(img), Pt(x), Pt(y), Pt(w), Pt(h + 8))
        pic.rotation = rotation
    if label:
        cw = text_width(label, 8.5, True) + 18
        chip(slide, x + (w - cw) / 2, y + h + 15, label, ORANGE100 if label_orange else GREEN100, ORANGE if label_orange else GREEN800, 8.5)
    return w


def browser(slide, path, x, y, w, h=None, caption=None) -> float:
    img, height = browser_png(path, w, h)
    if img is None:
        box(slide, x, y, w, height, RED100, None, 8)
        text(slide, x + 8, y + 8, w - 16, 20, f"missing {path}", 7, RED)
    else:
        slide.shapes.add_picture(str(img), Pt(x), Pt(y), Pt(w), Pt(height))
    if caption:
        text(slide, x, y + height + 5, w, 14, caption, 8.5, MUTED)
        height += 19
    return y + height


def stat(slide, x, y, w, value, label, color=GREEN, size=34):
    text(slide, x, y, w, size * 1.25, value, size, color, bold=True, head=True)
    text(slide, x, y + size * 1.25, w, 26, label, 9.5, MUTED)


def arrow(slide, x, y, size=22, color=ORANGE):
    icon(slide, "iEast", x, y, size, color)


SLIDES: list = []


def content(kicker, title):
    s = prs.slides.add_slide(BLANK)
    s.background.fill.solid()
    s.background.fill.fore_color.rgb = rgb(PAPER)
    shape(s, MSO_SHAPE.OVAL, 960 - 220, -150, 330, 330, "E6F9EB")
    shape(s, MSO_SHAPE.OVAL, -70, 540 - 100, 190, 190, "FCEBE0")
    box(s, 46, 30, 6, 42, GREEN, None, 3)
    text(s, 64, 31, 700, 14, kicker.upper(), 9, ORANGE, bold=True, spacing=1.6)
    text(s, 64, 43, 840, 34, title, 25, INK, bold=True, head=True)
    text(s, 46, 512, 400, 12, "EXEMatching  ·  PRM393 Lab 3  ·  DEVORGANIZE222", 7.5, MUTED)
    SLIDES.append(s)
    return s


def dark():
    s = prs.slides.add_slide(BLANK)
    fill = s.background.fill
    fill.gradient()
    fill.gradient_angle = 35
    stops = fill.gradient_stops
    stops[0].color.rgb, stops[1].color.rgb = rgb(GREEN900), rgb(GREEN)
    shape(s, MSO_SHAPE.OVAL, 960 - 300, 540 - 260, 420, 420, "1B7A40")
    shape(s, MSO_SHAPE.OVAL, 300, -120, 240, 240, "0E4A28")
    SLIDES.append(s)
    return s


# ================================================================= 1 · cover
s = dark()
box(s, 56, 46, 40, 40, WHITE, None, 10)
if (ROOT / "assets/brand/logo.png").exists():
    s.shapes.add_picture(str(ROOT / "assets/brand/logo.png"), Pt(61), Pt(51), Pt(30), Pt(30))
text(s, 106, 55, 200, 22, "EXEMatching", 16, WHITE, bold=True)
text(s, 56, 160, 460, 14, "PRM393 · MOBILE PROGRAMMING · LAB 3", 10, MINT, bold=True, spacing=2)
text(s, 56, 180, 480, 140, "Find your capstone team.\nElect a leader.\nLock the roster.", 33, WHITE, bold=True, head=True, line_spacing=1.05)
text(s, 56, 326, 440, 40, "A cloud-enabled Flutter app on Firebase, tested end to end\non a real emulator by Google ARTEMIS.", 13, MINT_TEXT)
cx = 56
for label in ["Flutter · MVVM", "7 Firebase services", "13 E2E cases × 3 runs", "Gemini code review"]:
    cx += chip(s, cx, 384, label, GREEN800, WHITE, 9.5) + 8
text(s, 56, 494, 480, 12, "Team DEVORGANIZE222  ·  Firebase project prm393-lab-3-exematching", 9, "A7F3D0")
phone(s, "docs/screenshots/scr03_browse.png", 548, 140, 290, rotation=7)
phone(s, "docs/screenshots/scr07_pool_member_joined.png", 772, 130, 290, rotation=-7)
phone(s, "docs/screenshots/scr02_home.png", 640, 66, 380)

# ================================================================= 2 · persona
s = content("Lab 2 recap", "Who we built it for")
box(s, 46, 96, 300, 404)
photo = circle_photo("assets/images/persona_minh.jpg")
if photo:
    s.shapes.add_picture(str(photo), Pt(66), Pt(116), Pt(74), Pt(74))
text(s, 154, 120, 180, 24, "Minh Lê", 18, bold=True, head=True)
text(s, 154, 146, 180, 28, "Final-year Software Engineering student", 10, MUTED)
chip(s, 154, 174, "Persona · Lab 2", ORANGE100, ORANGE, 8)
icon(s, "iQuote", 66, 210, 26)
text(s, 66, 240, 262, 120, "I have two weeks to register a capstone team. I don't know who has the skills we need, nobody wants "
     "to say who should lead, and if one person drops out we can't lock.", 13, italic=True, line_spacing=1.15)
text(s, 66, 396, 200, 12, "GOALS", 9, MUTED, bold=True, spacing=1.4)
chips(s, 66, 414, 262, [("Teammates with matching skills", {"icon_key": "iGroups"}),
                         ("A fair leader vote", {"icon_key": "iVote", "bg": ORANGE100, "fg": ORANGE}),
                         ("Locked before the deadline", {"icon_key": "iLock", "bg": BLUE100, "fg": BLUE})])
text(s, 372, 100, 400, 14, "THREE PAINS, THREE FLOWS", 10, MUTED, bold=True, spacing=1.4)
y = point(s, "iSearch", "Finding teammates with the right skills", "Browse open teams by topic, skill and open slot, and join one in two taps.", 372, 126, 542, big=True)
y = point(s, "iVote", "Choosing a leader without peer pressure", "Votes stay hidden until you vote; a majority elects the leader.", 372, y, 542, ORANGE, ORANGE100, True)
point(s, "iGroupAdd", "Recovering when a member drops out", "A team below 4 members can invite students from the Waiting Pool, then lock.", 372, y, 542, BLUE, BLUE100, True)
box(s, 372, 446, 542, 54, GREEN, None, 12)
icon(s, "iTrophy", 388, 462, 22, WHITE)
text(s, 420, 446, 480, 54, "Success = a locked team of 4–5 members with an elected leader, before the deadline.", 12.5, WHITE, bold=True, anchor=MSO_ANCHOR.MIDDLE)

# ================================================================= 3 · three flows
s = content("The 3 critical flows", "From browsing to a locked roster")
cw = (868 - 32) / 3
for i, (n, title, shot, route, alt, c, bg) in enumerate([
    ("1", "Discover & join", "docs/screenshots/scr04_join_dialog.png", "Home → Browse → Team detail → Join", "Alt: team fills first · no results · offline", GREEN, GREEN100),
    ("2", "Elect a leader", "docs/screenshots/scr06_voting_elected.png", "My Team → Vote → majority wins", "Alt: tallies hidden until you vote · change vote", ORANGE, ORANGE100),
    ("3", "Lock the roster", "docs/screenshots/scr07_pool_member_joined.png", "Review & Lock → Waiting Pool → Lock", "Alt: fewer than 4 members blocks the lock", BLUE, BLUE100),
]):
    x = 46 + i * (cw + 16)
    box(s, x, 96, cw, 404)
    shape(s, MSO_SHAPE.OVAL, x + 14, 110, 26, 26, c)
    text(s, x + 14, 110, 26, 26, n, 13, WHITE, bold=True, align=PP_ALIGN.CENTER, anchor=MSO_ANCHOR.MIDDLE)
    text(s, x + 48, 110, cw - 60, 26, title, 15, bold=True, head=True, anchor=MSO_ANCHOR.MIDDLE)
    phone(s, shot, x + (cw - 115) / 2, 146, 238)
    text(s, x + 12, 404, cw - 24, 16, route, 9.5, c, bold=True, align=PP_ALIGN.CENTER)
    box(s, x + 14, 428, cw - 28, 52, bg, None, 8)
    text(s, x + 22, 428, cw - 44, 52, alt, 10, align=PP_ALIGN.CENTER, anchor=MSO_ANCHOR.MIDDLE)

# ================================================================= 4 · Figma → app
s = content("Design traceability", "Figma frames, built in Flutter")
pair_w = 2 * (250 * 0.45 + 8) + 30
gap = (868 - 3 * pair_w) / 2
for i, (figma, app, label) in enumerate([
    ("assets/figma/SCR_02_ Dashboard.png", "docs/screenshots/scr02_home.png", "SCR_02 · Home"),
    ("assets/figma/SCR_03_ Browse Groups.png", "docs/screenshots/scr03_browse.png", "SCR_03 · Browse"),
    ("assets/figma/SCR_07_ Group Lock Review & Error Recovery.png", "docs/screenshots/scr07_lock_error.png", "SCR_07 · Review & Lock"),
]):
    x = 46 + i * (pair_w + gap)
    w = phone(s, figma, x, 100, 250, "Figma")
    arrow(s, x + w + 6, 216, 18)
    phone(s, app, x + w + 30, 100, 250, "App", True)
    text(s, x, 388, pair_w, 16, label, 11, bold=True, align=PP_ALIGN.CENTER)
text(s, 46, 432, 150, 18, "Deliberate deviations", 10, MUTED, bold=True, anchor=MSO_ANCHOR.MIDDLE)
chips(s, 190, 432, 724, [("DV-01 “Team” everywhere", {}), ("DV-04 Direct join", {}), ("DV-08 Bell + Settings tab", {}),
                         ("DV-09/10 WCAG AA contrast", {}), ("DV-14 Icon + label, not colour only", {}),
                         ("16 in docs/design-traceability.md", {"bg": ORANGE100, "fg": ORANGE})])

# ================================================================= 5 · architecture
s = content("Architecture", "MVVM with one-way dependencies")
for i, (key, name, path, role, c, bg) in enumerate([
    ("iPalette", "Screens & widgets", "lib/screens · lib/widgets", "Declarative UI only: no Firebase SDK, no business rules", GREEN, GREEN100),
    ("iTune", "ViewModels", "lib/viewmodels", "ChangeNotifier owning ViewState<T>, validation and analytics calls", ORANGE, ORANGE100),
    ("iTree", "Service interfaces", "lib/services", "Contracts the view-models depend on; local fakes for tests", BLUE, BLUE100),
    ("iCloud", "Firebase implementations", "lib/firebase", "Auth, Firestore, Storage, FCM, Analytics, Crashlytics, Remote Config", GREEN800, GREEN100),
]):
    y = 96 + i * 100
    box(s, 46, y, 520, 80, radius=10)
    box(s, 60, y + 17, 4, 46, c, None, 2)
    bubble(s, key, 76, y + 20, 40, c, bg)
    text(s, 130, y + 18, 420, 22, name, 15, bold=True, head=True)
    text(s, 130 + text_width(name, 15, True, True) + 10, y + 22, 200, 16, path, 9.5, MUTED)
    text(s, 130, y + 44, 420, 18, role, 11, MUTED)
    if i < 3:
        s.shapes.add_picture(str(icon_png(ICONS["iEast"], MUTED, 16)), Pt(298), Pt(y + 82), Pt(16), Pt(16)).rotation = 90
box(s, 590, 96, 324, 84)
text(s, 606, 108, 300, 18, "Every screen renders one ViewState<T>", 12, bold=True)
chips(s, 606, 134, 300, [("Loading", {"bg": BLUE100, "fg": BLUE}), ("Empty + action", {"bg": ORANGE100, "fg": ORANGE}),
                         ("Failure + retry", {"bg": RED100, "fg": RED}), ("Data", {})])
box(s, 590, 196, 324, 96)
stat(s, 606, 206, 120, str(UI_FIREBASE_IMPORTS), "Firebase imports in\nlib/screens + lib/widgets", GREEN if UI_FIREBASE_IMPORTS == 0 else RED, 40)
text(s, 740, 220, 160, 40, "Counted from the source when this deck is generated.", 9.5, MUTED)
box(s, 590, 308, 324, 188)
point(s, "iKey", "One composition root", "lib/app/providers.dart wires the Firebase services into the view-models with Provider.", 606, 324, 292, big=True)

# ================================================================= 6 · Firebase services
s = content("Cloud backend", "7 Firebase services, each with console proof")
tw, th = (868 - 36) / 4, 186
tiles = [
    ("iLogin", "Authentication", "Google Sign-In, limited to the class roster", "Users tab · roster rejection (TC-01)"),
    ("iStorage", "Firestore", "Teams, votes and the Waiting Pool in transactions", "Team documents · deployed rules"),
    ("iUpload", "Storage", "Team PDF uploaded to reports/{uid}/", "Uploaded PDFs · owner-only rules"),
    ("iBell", "Cloud Messaging", "Invites and updates in all 3 app states", "Foreground · background · terminated"),
    ("iInsights", "Analytics", "10 events, IDs and counts only", "DebugView · Logcat per E2E run"),
    ("iBug", "Crashlytics", "Crashes and non-fatals with user ID and keys", "Test crash + non-fatal, Nov 4"),
    ("iTune", "Remote Config", "Registration and pool switches, live", "Published, seen live, reverted"),
]
for i, (key, name, what, proof) in enumerate(tiles):
    x, y = 46 + (i % 4) * (tw + 12), 96 + (i // 4) * (th + 12)
    box(s, x, y, tw, th)
    bubble(s, key, x + 14, y + 14, 40)
    ok = captured(EVIDENCE[name])
    label = "VERIFIED" if ok else "NOT CAPTURED"
    chip(s, x + tw - 14 - (text_width(label, 8, True) + 32), y + 24, label, GREEN100 if ok else LINE, GREEN800 if ok else MUTED, 8,
         "iCheck" if ok else "iSchedule")
    text(s, x + 14, y + 66, tw - 28, 22, name, 15, bold=True, head=True)
    text(s, x + 14, y + 90, tw - 28, 40, what, 10.5, MUTED)
    shape(s, MSO_SHAPE.RECTANGLE, x + 14, y + th - 34, tw - 28, 0.8, LINE)
    text(s, x + 14, y + th - 26, tw - 28, 14, proof, 8.5, GREEN800)
x, y = 46 + 3 * (tw + 12), 96 + th + 12
box(s, x, y, tw, th, GREEN, None, 14)
icon(s, "iShield", x + 14, y + 16, 26, WHITE)
text(s, x + 14, y + 52, tw - 28, 20, "Security rules", 15, WHITE, bold=True, head=True)
text(s, x + 14, y + 76, tw - 28, 60, "Firestore and Storage rules, deployed and screenshotted from the console.", 10.5, GREEN100)
text(s, 46, 488, 868, 14, "VERIFIED means the console or device screenshots are in evidence/ when this deck is generated.", 9, MUTED, align=PP_ALIGN.CENTER)

# ================================================================= 7 · Auth
s = content("Cloud service 1 · Authentication", "Google Sign-In, roster only")
w = phone(s, "docs/screenshots/scr01_sign_in.png", 46, 100, 330)
phone(s, "docs/screenshots/scr01_account_picker.png", 46 + w + 12, 100, 330)
x = 46 + 2 * w + 36
y = browser(s, "evidence/console/console_auth_users.jpg", x, 96, 380, 150, "Authentication → Users: Google-provider accounts with their UIDs") + 14
tc01 = FINAL.get("TC-01")
y = point(s, "iLogin", "Google credential → FirebaseAuth", "authStateChanges() drives routing; sign-out clears Google and Firebase.", x, y, 914 - x)
y = point(s, "iShield", "Roster check in app and rules", "allowedEmails/{email} must be enabled; rules check isRosterMember().", x, y, 914 - x, ORANGE, ORANGE100)
point(s, "iCancel", "Not on the roster? Rejected",
      f"E2E TC-01 passed {sum(tc01)}/{len(tc01)} runs." if tc01 else "Covered by E2E TC-01.", x, y, 914 - x, RED, RED100)

# ================================================================= 8 · Firestore
s = content("Cloud service 2 · Cloud Firestore", "Transactions and tight security rules")
browser(s, "evidence/console/console_firestore_rules_teams.jpg", 46, 96, 470, 300, "Deployed rules: a student may change only roster fields (GR-01)")
x = 538
box(s, x, 96, 182, 92)
stat(s, x + 14, 104, 160, str(TRANSACTIONS), "mutations run in\nrunTransaction")
box(s, x + 194, 96, 182, 92)
stat(s, x + 208, 104, 160, str(WRITABLE_FIELDS), "fields a student\nmay change", ORANGE)
y = point(s, "iGroups", "Join, leave, vote, lock, invite", "Each re-reads the team inside the transaction, so two students can't take the last slot.", x, 206, 376)
y = point(s, "iLock", "affectedKeys().hasOnly([...])", "Topic, capacity and supervisor can't be edited by a client.", x, y, 376, ORANGE, ORANGE100)
point(s, "iHidden", "Waiting Pool privacy", "Leaders read only unassigned candidates; assigned records stay private.", x, y, 376, BLUE, BLUE100)

# ================================================================= 9 · Storage
s = content("Cloud service 3 · Cloud Storage", "Team PDF, private to its owner")
w = phone(s, "docs/screenshots/profile_export_done.png", 46, 96, 330, "Export & Upload")
x = 46 + w + 30
y = browser(s, "evidence/console/console_storage_files.jpg", x, 96, 520, 170, "Storage → reports/{uid}/: PDFs uploaded by the app (E2E TC-13)") + 12
box(s, x, y, 520, 92, "0F172A", None, 10)
text(s, x + 14, y + 10, 400, 12, "firebase/storage.rules", 8, "94A3B8")
code = text(s, x + 14, y + 26, 490, 60, "match /reports/{userId}/{allPaths=**} {\n  allow read, write: if request.auth != null\n                     && request.auth.uid == userId;\n}", 10, "A7F3D0")
for p in code.text_frame.paragraphs:
    for r in p.runs:
        r.font.name = "Courier New"
cx = x
for label, key in [("PDF built on the device", "iPdf"), ("Upload progress 0 → 100 %", "iUpload"), ("Download link shown", "iCheck")]:
    cx += chip(s, cx, y + 106, label, icon_key=key) + 6

# ================================================================= 10 · FCM
s = content("Cloud service 4 · Cloud Messaging", "One test message, three app states")
for i, (state, path, how, c) in enumerate([
    ("Foreground", "evidence/fcm/foreground_alerts.png", "onMessage stores it; it appears in Alerts at once", GREEN),
    ("Background", "evidence/fcm/background.png", "Android shows it; a tap runs onMessageOpenedApp", ORANGE),
    ("Terminated", "evidence/fcm/terminated_opened.png", "Process killed; a tap cold-starts the app into the team", BLUE),
]):
    cxm = 46 + 868 * (i * 2 + 1) / 6
    pw_ = text_width(state, 11, True) + 26
    box(s, cxm - pw_ / 2, 96, pw_, 22, c, None, 11)
    text(s, cxm - pw_ / 2, 96, pw_, 22, state, 11, WHITE, bold=True, align=PP_ALIGN.CENTER, anchor=MSO_ANCHOR.MIDDLE)
    phone(s, path, cxm - (290 * 0.45 + 8) / 2, 126, 290)
    text(s, cxm - 100, 432, 200, 34, how, 10, MUTED, align=PP_ALIGN.CENTER)
    if i < 2:
        arrow(s, 46 + 868 * (i + 1) / 3 - 11, 260)

# ================================================================= 11 · Analytics
s = content("Cloud service 5 · Google Analytics", "10 events, no personal data")
text(s, 46, 98, 380, 16, "Recommended events", 11, MUTED, bold=True)
y = chips(s, 46, 118, 400, [(e, {"icon_key": "iInsights"}) for e in ["login", "logout", "search_teams", "view_team"]]) + 12
text(s, 46, y, 380, 16, "Domain events", 11, MUTED, bold=True)
y = chips(s, 46, y + 20, 400, [(e, {"icon_key": "iBolt", "bg": ORANGE100, "fg": ORANGE})
                              for e in ["create_team", "join_team", "cast_vote", "invite_pool", "lock_roster", "export_report"]]) + 20
y = point(s, "iHidden", "IDs and counts only", "search_teams sends query_length, never the search text; no email or name.", 46, y, 400)
y = point(s, "iPerson", "User ID after sign-in", "setUserId(uid) links events to the account, not to a name.", 46, y, 400, ORANGE, ORANGE100)
point(s, "iFact", "Checked twice", "DebugView screenshots, and every E2E run saves the events it caused from Logcat.", 46, y, 400, BLUE, BLUE100)
browser(s, "evidence/debugview/debugview_search_teams_params.jpg", 468, 96, 446, None, "DebugView: search_teams with query_length, result_count and filter_count")

# ================================================================= 12 · Crashlytics
s = content("Cloud service 6 · Crashlytics", "Crashes and handled errors, with context")
w = phone(s, "docs/screenshots/profile_non_fatal_sent.png", 46, 96, 330, "Send Test Error")
x = 46 + w + 30
y = browser(s, "evidence/crashlytics/crashlytics_crash_keys.jpg", x, 96, 520, 150, "Test crash of Nov 4, 06:51:57 · Keys: screen = profile") + 10
y = browser(s, "evidence/crashlytics/crashlytics_crash_user.jpg", x, y, 520, 95, "Same event · Data: the user ID is the Firebase Auth UID") + 10
chips(s, x, y, 560, [("FlutterError.onError → fatal", {"icon_key": "iBug", "bg": RED100, "fg": RED}),
                     ("recordError → non-fatal", {"icon_key": "iWarn", "bg": ORANGE100, "fg": ORANGE}),
                     ("keys: screen · student_cohort · team_id", {"icon_key": "iKey"})])

# ================================================================= 13 · Remote Config
s = content("Cloud service 7 · Remote Config", "Close registration without an app update")
w = phone(s, "evidence/remote_config/app_before.png", 46, 96, 290, "Before · false")
arrow(s, 46 + w + 14, 230)
browser(s, "evidence/remote_config/console_published.jpg", 46 + w + 50, 150, 260, 185, "registration_closed = true, published")
arrow(s, 46 + w + 324, 230)
phone(s, "evidence/remote_config/app_after.png", 914 - 2 * w - 16, 96, 290, "After · true", True)
phone(s, "evidence/remote_config/app_after_home.png", 914 - w, 96, 290, "Home: closed", True)
box(s, 46, 440, 868, 52, WHITE, LINE, 12)
icon(s, "iSync", 62, 456, 20)
text(s, 94, 440, 804, 52, "onConfigUpdated activates the new value and the view-models rebuild: the open app changed within a minute, "
     "with no restart or reinstall. The parameter was deleted again afterwards.", 11, anchor=MSO_ANCHOR.MIDDLE)

# ================================================================= 14 · ARTEMIS
s = content("Quality · Google ARTEMIS", "13 cases × 3 runs on a real emulator")
passed, total = passed_of(FINAL), total_of(FINAL)
box(s, 46, 96, 380, 82)
text(s, 62, 102, 110, 64, str(passed) if total else "–", 48, GREEN, bold=True, head=True)
text(s, 62 + text_width(str(passed), 48, True, True) + 4, 128, 80, 34, f"/ {total}", 22, MUTED, bold=True)
text(s, 236, 116, 180, 44, "runs passed in the final run\n(e2e_test/evidence/junit.xml)", 9.5, MUTED)
text(s, 46, 192, 380, 16, "Every attempt, as recorded", 11, MUTED, bold=True)
for i, (name, runs) in enumerate(ATTEMPTS):
    y = 214 + i * 22
    text(s, 46, y, 62, 14, name, 9.5, bold=True, anchor=MSO_ANCHOR.MIDDLE)
    box(s, 112, y, 230, 14, LINE, None, 7)
    if total_of(runs) and passed_of(runs):
        box(s, 112, y, 230 * passed_of(runs) / total_of(runs), 14, GREEN if name == "Final run" else MINT, None, 7)
    text(s, 350, y, 70, 14, f"{passed_of(runs)}/{total_of(runs)}" if total_of(runs) else "n/a", 9.5, bold=True, anchor=MSO_ANCHOR.MIDDLE)
y = point(s, "iRobot", "The agent's SUCCESS is not trusted", "Each run is checked against the accessibility tree, Logcat and Firestore.", 46, 296, 380, BLUE, BLUE100)
point(s, "iWarn", "Failed runs are explained", "Bugs found, harness fixes and Gemini free-tier 429s, per trace ID: docs/test-plan.md §3.", 46, y, 380, ORANGE, ORANGE100)
box(s, 446, 96, 468, 404)
text(s, 462, 108, 200, 14, "Test case", 9, MUTED, bold=True)
text(s, 812, 108, 90, 14, "Run 1 · 2 · 3", 9, MUTED, bold=True, align=PP_ALIGN.RIGHT)
shape(s, MSO_SHAPE.RECTANGLE, 462, 126, 436, 0.8, LINE)
names = ["Account not on roster", "Sign in with roster account", "Search & filter", "Empty state + clear filters", "Offline error + retry",
         "Join a team with an open slot", "Team fills before confirming", "Tallies hidden until voting", "Vote elects the leader",
         "Lock blocked → pool recovery", "Share link → Android share sheet", "Decline invite + Undo", "Export & upload team PDF"]
for i, name in enumerate(names):
    case = f"TC-{i + 1:02d}"
    y = 134 + i * 27.5
    text(s, 462, y, 44, 16, case, 9.5, GREEN800, bold=True, anchor=MSO_ANCHOR.MIDDLE)
    text(s, 508, y, 280, 16, name, 10, anchor=MSO_ANCHOR.MIDDLE)
    runs = FINAL.get(case, [])
    for r in range(3):
        ok = runs[r] if r < len(runs) else None
        dx = 846 + r * 18
        shape(s, MSO_SHAPE.OVAL, dx, y + 1, 14, 14, LINE if ok is None else (GREEN if ok else RED))
        if ok is not None:
            icon(s, "iCheck" if ok else "iCancel", dx + 2.5, y + 3.5, 9, WHITE)

# ================================================================= 15 · AI code review
s = content("AI-assisted code review", "Gemini reviews the PR, people decide")
cx = 46
for label, key, bg, fg in [("Pull request", "iCode", BLUE100, BLUE), ("gemini_review.py · one API request", "iSpark", ORANGE100, ORANGE),
                           ("gemini-3.5-flash-lite", "iRobot", GREEN100, GREEN800), ("Inline review comments", "iFact", BLUE100, BLUE)]:
    cx += chip(s, cx, 96, label, bg, fg, 9, key) + 6
    if label != "Inline review comments":
        arrow(s, cx, 98, 14)
        cx += 20
findings = [
    ("GR-01", "Security · High", "isSelfJoin only checked the roster size, so a client could also rewrite topic, capacity or supervisor.", True, "Fixed for all 5 team mutations · c9543a3"),
    ("GR-02", "Concurrency · Med", "Querying the Waiting Pool outside the transaction could let two teams pick the same student.", False, "The client SDK can't query in a transaction; the candidate is re-read inside it"),
    ("GR-03", "Reliability · Med", "A missing Firebase CLI login raised a bare KeyError in the E2E backend.", True, "Actionable message · ee6ec78"),
    ("GR-04", "Reliability · Low", "The Remote Config start-up catch dropped the error message.", True, "Logged, defaults kept · d6926d1"),
    ("GR-05", "Reliability · Med", "Slicing the error body to 2000 chars might split a UTF-8 character.", False, "False positive: decoded before slicing"),
]
for i, (fid, cat, what, accepted, decision) in enumerate(findings):
    y = 130 + i * 74
    box(s, 46, y, 868, 64, WHITE, MINT if accepted else "FCA5A5", 12)
    text(s, 62, y + 12, 90, 18, fid, 13, bold=True, head=True)
    text(s, 62, y + 32, 100, 14, cat, 8.5, MUTED)
    text(s, 170, y + 8, 480, 48, what, 10.5, anchor=MSO_ANCHOR.MIDDLE)
    label = "ACCEPTED" if accepted else "REJECTED"
    lw = text_width(label, 8, True) + 32
    chip(s, 898 - lw, y + 10, label, GREEN100 if accepted else RED100, GREEN800 if accepted else RED, 8, "iCheck" if accepted else "iCancel")
    text(s, 668, y + 32, 230, 26, decision, 8.5, MUTED, align=PP_ALIGN.RIGHT)

# ================================================================= 16 · lessons
s = content("What testing taught us", "Real bugs, found on a real device")
box(s, 46, 96, 425, 404)
icon(s, "iBug", 62, 112, 18, RED)
text(s, 86, 110, 360, 22, "Bugs the runs exposed, all fixed", 13, bold=True, head=True)
y = 144
for key, title, body in [
    ("iGroupAdd", "Invite from Waiting Pool always failed", "Rules hid unassigned pool records from leaders (PERMISSION_DENIED)."),
    ("iSearch", "Typing did nothing for TalkBack and ARTEMIS", "A Semantics wrapper created a second, non-editable text field."),
    ("iInsights", "Voting showed a false error", "cast_vote sent a bool parameter that Analytics rejects."),
    ("iWarn", "Undo after declining never appeared", "The card was disposed before the snackbar showed."),
]:
    y = point(s, key, title, body, 62, y, 393, RED, RED100, True)
box(s, 489, 96, 425, 300)
icon(s, "iBulb", 505, 112, 18, ORANGE)
text(s, 529, 110, 360, 22, "Lessons", 13, bold=True, head=True)
y = 144
for key, title, body in [
    ("iRobot", "An agent's “success” is not evidence", "TC-12 reported the invite restored while the screen showed none."),
    ("iVerified", "Only recorded runs count", "Trace IDs, screenshots and Firestore checks, never a typed-in 39/39."),
    ("iShield", "Test rules with the real flows", "A correct-looking rule broke Flow 3 until the app ran against it."),
]:
    y = point(s, key, title, body, 505, y, 393, ORANGE, ORANGE100, True)
box(s, 489, 410, 425, 90, BLUE100, None, 12)
icon(s, "iScience", 505, 424, 18, BLUE)
text(s, 531, 422, 368, 70, "Exploratory session: " + " · ".join(EXPLORATORY) if EXPLORATORY
     else "ARTEMIS Pro exploratory session: not run yet (docs/test-plan.md §4).", 10.5)

# ================================================================= 17 · thank you
s = dark()
text(s, 56, 170, 400, 16, "THANK YOU", 11, MINT, bold=True, spacing=3)
text(s, 56, 190, 460, 64, "Questions?", 48, WHITE, bold=True, head=True)
for i, (key, value) in enumerate([("iCode", "github.com/DEVORGANIZE222/Lab3_Cloud-Enabled_Mobile_App"),
                                  ("iFact", "docs/test-plan.md · evidence/ · report/Lab03_DEVORGANIZE222.pdf"),
                                  ("iCloud", "Firebase project prm393-lab-3-exematching")]):
    icon(s, key, 56, 282 + i * 24, 15, MINT)
    text(s, 80, 280 + i * 24, 460, 18, value, 11, MINT_TEXT)
text(s, 56, 494, 480, 12, "Team DEVORGANIZE222  ·  PRM393 Mobile Programming  ·  FPT University", 9, "A7F3D0")
phone(s, "docs/screenshots/scr06_voting_elected.png", 588, 152, 300)
phone(s, "docs/screenshots/scr07_locked.png", 742, 72, 380)

# ---------------------------------------------------------------- page numbers on content slides
for n, slide in enumerate(SLIDES, 1):
    if n in (1, len(SLIDES)):
        continue
    label = f"{n:02d} / {len(SLIDES)}"
    w = text_width(label, 7.5, True) + 18
    box(slide, 914 - w, 509, w, 15, GREEN, None, 7.5)
    text(slide, 914 - w, 509, w, 15, label, 7.5, WHITE, bold=True, align=PP_ALIGN.CENTER, anchor=MSO_ANCHOR.MIDDLE)

OUT.parent.mkdir(exist_ok=True)
prs.save(OUT)
print(f"Successfully generated {OUT.relative_to(ROOT)} ({OUT.stat().st_size} bytes, {len(SLIDES)} slides)")
