"""Records the app demo video: the 3 Lab 2 flows on the real Firebase backend.

Each part is recorded with `adb shell screenrecord` while this script drives the app at
a watchable pace, then the parts are joined into a 1920x1080 video: the phone on one
side, Vietnamese captions on the other. Needs the Firebase CLI login, the E2E account on
the device, ffmpeg and Pillow.

  DEVICE_SERIAL=emulator-5554 python record_demo.py            record and compose
  DEVICE_SERIAL=emulator-5554 python record_demo.py flow3      re-record from Flow 3 on
  DEVICE_SERIAL=emulator-5554 python record_demo.py compose    compose the last recording
"""

import json
import os
import subprocess
import sys
import tempfile
import time
from pathlib import Path

from PIL import Image, ImageDraw, ImageFont

from backend import Backend
from conftest import ACCOUNT
from device import ADB, Device

SERIAL = os.environ.get("DEVICE_SERIAL", "emulator-5554")
ROOT = Path(__file__).resolve().parent.parent
OUT = ROOT / "evidence" / "demo" / "demo_app.mp4"
RAW = Path(tempfile.gettempdir()) / "exematching-demo"
FPS = 30
PANEL_W, PANEL_H = 840, 1080
BG, MINT, WHITE = "#0B3B24", "#86EFAC", "#FFFFFF"

d = Device(SERIAL)


class Part:
    """One screen recording (screenrecord stops by itself after 3 minutes)."""

    def __init__(self, name: str, label: str) -> None:
        self.name, self.label, self.captions = name, label, []
        self.remote = f"/sdcard/demo_{name}.mp4"

    def __enter__(self) -> "Part":
        self.proc = subprocess.Popen([ADB, "-s", SERIAL, "shell", "screenrecord", "--size", "720x1600", "--bit-rate", "8000000", self.remote])
        time.sleep(1.5)
        self.start = time.monotonic()
        return self

    def say(self, title: str, body: str, hold: float = 0) -> None:
        self.captions.append({"t": time.monotonic() - self.start, "title": title, "body": body})
        time.sleep(hold)

    def __exit__(self, *exc) -> None:
        time.sleep(1)
        d.adb("shell", "pkill", "-INT", "screenrecord", check=False)
        self.proc.wait(timeout=20)
        time.sleep(2)
        RAW.mkdir(exist_ok=True)
        d.adb("pull", self.remote, str(RAW / f"{self.name}.mp4"))
        d.adb("shell", "rm", self.remote, check=False)
        (RAW / f"{self.name}.json").write_text(json.dumps({"label": self.label, "captions": self.captions}, ensure_ascii=False), encoding="utf-8")
        print("recorded", self.name, f"{time.monotonic() - self.start:.0f}s")


def back() -> None:
    d.shell("input", "keyevent", "KEYCODE_BACK")


def swipe_up(start: int = 1700, end: int = 900) -> None:
    d.shell("input", "swipe", "540", str(start), "540", str(end), "400")
    time.sleep(1)


def search(term: str) -> None:
    d.tap(id="browse_search_field")
    d.shell("input", "keyevent", "KEYCODE_MOVE_END", *["KEYCODE_DEL"] * 20)
    if term:
        d.shell("input", "text", term)
    time.sleep(2)  # search is debounced
    back()  # hides the keyboard, which otherwise covers the result cards
    time.sleep(1.5)


def part_sign_in(b: Backend, me) -> None:
    b.reset(me)
    b.set_allowed(me, False)  # the same Google account, taken off the class roster for this step
    d.reset_app()
    d.launch()
    d.wait_for(id="btn_google_sign_in", timeout=40)
    with Part("1_sign_in", "Đăng nhập") as p:
        p.say("Đăng nhập bằng Google", "Chỉ tài khoản có trong danh sách lớp (Firestore: allowedEmails) mới vào được app.", 4)
        d.tap(id="btn_google_sign_in")
        d.wait_for(text=ACCOUNT, timeout=15)
        p.say("Tài khoản ngoài danh sách", "Tài khoản này vừa được tạm gỡ khỏi allowedEmails để thử trường hợp bị từ chối.", 3)
        d.tap(text=ACCOUNT)
        d.wait_for(id="sign_in_message", timeout=40)
        p.say("Bị từ chối", "App báo tài khoản không có trong danh sách lớp và ở lại màn hình đăng nhập.", 5)
        b.set_allowed(me, True)
        p.say("Thêm lại vào danh sách", "Tài khoản đã được bật lại trong allowedEmails. Đăng nhập lần nữa.", 3)
        d.tap(id="btn_google_sign_in")
        d.tap(text=ACCOUNT, timeout=15)
        d.wait_for(id="nav_home", timeout=40)
        p.say("Vào được Home", "Home hiện hạn đăng ký và trạng thái: sinh viên này chưa có nhóm.", 5)


def part_flow1(b: Backend, me) -> None:
    with Part("2_flow1", "Luồng 1 · Tìm & tham gia nhóm") as p:
        d.set_network(False)
        p.say("Mất mạng", "Tắt Wi-Fi và dữ liệu di động của máy, rồi mở tab Browse.", 2)
        d.tap(id="nav_browse")
        d.wait_for(id="state_error", timeout=60)
        p.say("Báo lỗi rõ ràng", "App báo không kết nối được và có nút Try Again, không bị treo.", 4)
        d.set_network(True)
        time.sleep(4)
        p.say("Có mạng lại", "Bật mạng và bấm Try Again: danh sách nhóm tải lại từ Firestore.", 1)
        d.tap(id="error_retry")
        d.wait_for(id="browse_result_count", timeout=40)
        time.sleep(3)
        p.say("Tìm theo từ khóa", "Tìm “drone”: danh sách lọc ngay khi gõ.", 0)
        search("drone")
        time.sleep(3)
        p.say("Không có kết quả", "Tìm “quantum”: app hiện trạng thái rỗng với nút Clear Filters.", 0)
        search("quantum")
        d.wait_for(id="state_empty")
        time.sleep(3)
        d.tap(id="empty_action")
        time.sleep(3)
        p.say("Chọn nhóm", "Tìm FinTech Guard và mở chi tiết: đề tài, thành viên, vị trí còn trống.", 0)
        search("FinTech")
        d.tap(id="btn_view_FIN-02")
        d.wait_for(id="btn_join_team")
        time.sleep(4)
        d.tap(id="btn_join_team")
        d.wait_for(id="dialog_join_confirm")
        p.say("Xác nhận tham gia", "Hộp thoại nêu rõ vị trí sẽ nhận. Việc tham gia chạy trong Firestore transaction.", 4)
        d.tap(id="dialog_join_confirm")
        d.wait_for(id="card_my_team_header", timeout=40)
        p.say("Đã vào nhóm", "My Team hiện FinTech Guard với 3/5 thành viên.", 5)
    assert me.uid in b.get("teams/team_fin02")["memberIds"]


def part_flow2(b: Backend, me) -> None:
    b.reset(me, team="team_ai04")  # 3 of 5 members; two votes are in, so this vote decides the majority
    d.sign_in(ACCOUNT)
    with Part("3_flow2", "Luồng 2 · Bầu trưởng nhóm") as p:
        p.say("Nhóm AI-04", "Dữ liệu mẫu: nhóm có 3 thành viên, 2 người đã bỏ phiếu, chưa có trưởng nhóm.", 3)
        d.tap(id="nav_team")
        d.wait_for(id="btn_vote_leader")
        time.sleep(3)
        d.tap(id="btn_vote_leader")
        d.wait_for(id=f"candidate_{me.uid}")
        p.say("Kết quả bị ẩn", "Chưa bỏ phiếu thì chưa thấy số phiếu, để không ảnh hưởng lựa chọn.", 5)
        d.tap(id=f"candidate_{me.uid}")
        p.say("Chọn và gửi phiếu", "Chọn một ứng viên rồi bấm Submit Vote.", 3)
        d.tap(id="btn_submit_vote")
        d.wait_for(id="banner_leader_elected", timeout=40)
        p.say("Đã có trưởng nhóm", "Đạt đa số 2/3 phiếu: trưởng nhóm được bầu và lưu vào Firestore.", 6)
        d.tap(id="btn_back_to_team")
        d.wait_for(id="btn_review_lock")
        p.say("Quay lại My Team", "Trưởng nhóm giờ có nút Review & Lock.", 4)
    assert b.get("teams/team_ai04")["leaderId"] == me.uid


def part_flow3(b: Backend, me, fresh: bool = False) -> None:
    if fresh:  # when re-recording from this part: the state part_flow2 leaves behind
        b.reset(me, team="team_ai04", leader=True)
        d.sign_in(ACCOUNT)
        d.tap(id="nav_team")
        d.wait_for(id="btn_review_lock")
    with Part("4_flow3", "Luồng 3 · Chốt danh sách") as p:
        p.say("Mở Review & Lock", "Trưởng nhóm vào màn hình kiểm tra điều kiện chốt nhóm.")
        d.tap(id="btn_review_lock")
        d.wait_for(id="banner_lock_error")
        p.say("Chưa chốt được", "Nhóm cần ít nhất 4 người, hiện chỉ có 3, nên app chặn thao tác chốt và nêu lý do.", 5)
        swipe_up()
        d.tap(id="btn_share_invite")
        d.foreground_activity("resolver", timeout=8)
        p.say("Chia sẻ link nhóm", "Share Team Link mở bảng chia sẻ của Android.", 4)
        back()
        time.sleep(2)
        p.say("Mời từ Waiting Pool", "Bấm Invite from Waiting Pool: hệ thống thêm một sinh viên chưa có nhóm.", 1)
        d.tap(id="btn_invite_pool")
        time.sleep(3)
        d.scroll_to_top()
        d.wait_for(id="banner_pool_joined", timeout=40)
        p.say("Khanh Vo vào nhóm", "Nhóm có 4/5 người, đủ sĩ số để chốt.", 4)
        swipe_up(1500, 1000)
        p.say("Cần bầu lại đa số", "Nhóm 4 người cần 3 phiếu, trưởng nhóm mới có 2 nên mục Leader elected chuyển về Pending.", 5)
        # Khanh Vo is a seeded student without a phone here, so the vote is written from the backend.
        votes = b.get("teams/team_ai04")["votes"]
        b.commit([b.patch("teams/team_ai04", {"votes": {**votes, "s_khanh": me.uid}})])
        p.say("Khanh Vo bỏ phiếu (mô phỏng)", "Phiếu của tài khoản mẫu này được ghi từ backend. App đang mở tự cập nhật: đạt 3/4 phiếu.", 5)
        swipe_up()
        swipe_up()
        d.tap(id="btn_lock_roster")
        d.wait_for(id="dialog_lock_confirm")
        p.say("Xác nhận chốt", "Hộp thoại cảnh báo: sau khi chốt, danh sách không còn thay đổi tự do.", 4)
        d.tap(id="dialog_lock_confirm")
        d.wait_for(id="state_locked", timeout=40)
        p.say("Đã chốt nhóm", "Danh sách được chốt và có mã xác nhận gửi phòng đào tạo.", 6)
    assert b.get("teams/team_ai04")["locked"] is True


def part_export() -> None:
    with Part("5_export", "Xuất báo cáo") as p:
        p.say("Về My Team", "Nhóm đã khóa và hiện mã xác nhận. Mở Profile để xuất báo cáo.")
        d.tap(id="btn_back_to_team")
        time.sleep(2)
        d.tap(id="btn_open_profile")
        d.wait_for(id="card_account")
        p.say("Xuất PDF của nhóm", "Profile: tạo PDF ngay trên máy rồi tải lên Cloud Storage.", 3)
        d.tap(id="btn_export_upload")
        d.wait_for(id="export_done", timeout=60)
        p.say("Tải lên thành công", "File nằm ở reports/{uid}/, chỉ chủ tài khoản đọc được. App hiện link tải về.", 6)


def record(from_flow3: bool = False) -> None:
    b = Backend()
    me = b.account(ACCOUNT)
    d.shell("settings", "put", "system", "show_touches", "1")
    try:
        if not from_flow3:
            part_sign_in(b, me)
            part_flow1(b, me)
            part_flow2(b, me)
        part_flow3(b, me, fresh=from_flow3)
        part_export()
    finally:
        d.set_network(True)
        b.set_allowed(me, True)
        b.reset(me)
        d.shell("settings", "put", "system", "show_touches", "0")


# ---------------------------------------------------------------- composing
def font(size: int, bold: bool = False) -> ImageFont.FreeTypeFont:
    return ImageFont.truetype("C:/Windows/Fonts/" + ("segoeuib.ttf" if bold else "segoeui.ttf"), size)


def wrapped(draw: ImageDraw.ImageDraw, text: str, f, width: int) -> list[str]:
    lines, line = [], ""
    for word in text.split(" "):
        trial = f"{line} {word}".strip()
        if draw.textlength(trial, font=f) > width and line:
            lines.append(line)
            line = word
        else:
            line = trial
    return lines + [line]


def panel(path: Path, label: str, title: str, body: str, width: int = PANEL_W) -> None:
    img = Image.new("RGB", (width, PANEL_H), BG)
    draw = ImageDraw.Draw(img)
    x, inner = 80, width - 140
    draw.text((x, 90), "EXEMatching · PRM393 Lab 3", font=font(26), fill=MINT)
    draw.text((x, 136), label, font=font(30, True), fill=MINT)
    y = 390
    for line in wrapped(draw, title, font(60, True), inner):
        draw.text((x, y), line, font=font(60, True), fill=WHITE)
        y += 76
    y += 24
    for line in wrapped(draw, body, font(36), inner):
        draw.text((x, y), line, font=font(36), fill="#D1FAE5")
        y += 52
    img.save(path)


def run(*args: str) -> None:
    subprocess.run(["ffmpeg", "-y", "-loglevel", "error", *args], check=True)


def duration(path: Path) -> float:
    out = subprocess.run(["ffprobe", "-v", "error", "-show_entries", "format=duration", "-of", "csv=p=0", str(path)], capture_output=True, text=True, check=True)
    return float(out.stdout)


def still(path: Path, image: Path, seconds: float) -> None:
    run("-loop", "1", "-t", str(seconds), "-i", str(image), "-vf", f"fps={FPS},format=yuv420p", "-c:v", "libx264", "-crf", "24", str(path))


def compose_part(name: str) -> Path:
    meta = json.loads((RAW / f"{name}.json").read_text(encoding="utf-8"))
    raw = RAW / f"{name}.mp4"
    total = duration(raw)
    caps = meta["captions"]
    listing = []
    for i, cap in enumerate(caps):
        image = RAW / f"{name}_{i}.png"
        panel(image, meta["label"], cap["title"], cap["body"])
        start = 0 if i == 0 else cap["t"]
        end = caps[i + 1]["t"] if i + 1 < len(caps) else total
        listing.append(f"file '{image.as_posix()}'\nduration {max(end - start, 0.1):.3f}")
    listing.append(f"file '{(RAW / f'{name}_{len(caps) - 1}.png').as_posix()}'")
    concat = RAW / f"{name}.txt"
    concat.write_text("\n".join(listing), encoding="utf-8")
    out = RAW / f"{name}_final.mp4"
    graph = (
        f"[0:v]fps={FPS},scale=-2:1040,pad={1920 - PANEL_W}:{PANEL_H}:(ow-iw)/2:(oh-ih)/2:color={BG}[phone];"
        f"[1:v]fps={FPS},scale={PANEL_W}:{PANEL_H},format=yuv420p[text];[text][phone]hstack,format=yuv420p[v]"
    )
    run("-i", str(raw), "-f", "concat", "-safe", "0", "-i", str(concat), "-filter_complex", graph, "-map", "[v]",
        "-t", f"{total:.3f}", "-c:v", "libx264", "-crf", "24", "-preset", "medium", str(out))
    return out


def card(path: Path, title: str, body: str) -> None:
    img = Image.new("RGB", (1920, 1080), BG)
    draw = ImageDraw.Draw(img)
    draw.text((960, 440), title, font=font(84, True), fill=WHITE, anchor="mm")
    draw.text((960, 550), body, font=font(38), fill="#D1FAE5", anchor="mm")
    draw.text((960, 980), "Nhóm DEVORGANIZE222 · PRM393 Lab 3", font=font(28), fill=MINT, anchor="mm")
    img.save(path)


def compose() -> None:
    names = sorted(p.stem for p in RAW.glob("*_*.json"))
    clips = []
    card(RAW / "intro.png", "EXEMatching", "Demo 3 luồng chính trên máy ảo Android, dữ liệu Firebase thật")
    still(RAW / "intro.mp4", RAW / "intro.png", 4)
    clips.append(RAW / "intro.mp4")
    clips += [compose_part(n) for n in names]
    card(RAW / "outro.png", "Hết phần demo", "Tìm nhóm → Bầu trưởng nhóm → Chốt danh sách")
    still(RAW / "outro.mp4", RAW / "outro.png", 3)
    clips.append(RAW / "outro.mp4")
    listing = RAW / "all.txt"
    listing.write_text("\n".join(f"file '{c.as_posix()}'" for c in clips), encoding="utf-8")
    OUT.parent.mkdir(parents=True, exist_ok=True)
    run("-f", "concat", "-safe", "0", "-i", str(listing), "-c:v", "libx264", "-crf", "26", "-preset", "medium", "-pix_fmt", "yuv420p", "-movflags", "+faststart", str(OUT))
    print(f"{OUT} {OUT.stat().st_size / 1e6:.1f} MB, {duration(OUT):.0f}s")


if __name__ == "__main__":
    if sys.argv[1:] != ["compose"]:
        record(from_flow3=sys.argv[1:] == ["flow3"])
    compose()
