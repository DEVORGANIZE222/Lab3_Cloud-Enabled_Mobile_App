"""Captures one screenshot per Figma frame into docs/screenshots from the Firebase build.

Uses the same preconditions as the E2E suite (backend.reset, a real Google sign-in), so it
needs the Firebase CLI login and the E2E account on the device:

  DEVICE_SERIAL=emulator-5556 uv run python capture_screens.py

Flutter errors printed while the screens are visited are saved to
docs/screenshots/capture-flutter-errors.txt (empty when every screen laid out cleanly).
SCR_08 (Random Pool) needs registration closed: publish registration_closed=true in Remote
Config, then run `uv run python capture_screens.py pool`.
"""

import os
import re
import sys
import time
from pathlib import Path

from backend import Backend
from conftest import ACCOUNT
from device import Device

OUT = Path(__file__).resolve().parent.parent / "docs" / "screenshots"
d = Device(os.environ.get("DEVICE_SERIAL", "emulator-5554"))
b = Backend()
me = b.account(ACCOUNT)
errors: list[str] = []


def shot(name: str) -> None:
    time.sleep(1.5)  # let transitions and snackbars settle
    d.screenshot(OUT / f"{name}.png")
    log = d.adb("logcat", "-d", "-s", "flutter")
    found = re.findall(r"(EXCEPTION CAUGHT BY [^\n]*|A RenderFlex overflowed[^\n]*|The relevant error-causing widget was:?[^\n]*\n[^\n]*)", log)
    for e in found:
        errors.append(f"{name}: {e.strip()}")
    d.adb("logcat", "-c")
    print("saved", name, f"({len(found)} errors)" if found else "")


def scroll_down() -> None:
    d.shell("input", "swipe", "540", "1800", "540", "700", "300")


def back() -> None:
    d.shell("input", "keyevent", "KEYCODE_BACK")


def newcomer() -> None:
    """A student without a team: Flow 1, Alerts."""
    b.reset(me)
    b.add_invite(me, "team_fin02", "FinTech Guard")
    d.reset_app()
    d.launch()
    d.wait_for(id="btn_google_sign_in", timeout=40)
    shot("scr01_sign_in")
    d.tap(id="btn_google_sign_in")
    d.wait_for(text=ACCOUNT, timeout=15)
    shot("scr01_account_picker")
    d.tap(text=ACCOUNT)
    d.wait_for(id="nav_home", timeout=40)
    shot("scr02_home_no_team")

    d.tap(id="nav_browse")
    d.wait_for(id="browse_result_count")
    shot("scr03_browse")
    d.tap(id="btn_view_FIN-02")
    d.wait_for(id="btn_join_team")
    shot("scr04_team_detail")
    d.tap(id="btn_join_team")
    d.wait_for(id="dialog_join_confirm")
    shot("scr04_join_dialog")
    d.tap(id="dialog_join_cancel")
    time.sleep(1)
    back()
    d.tap(id="browse_search_field")
    d.shell("input", "text", "quantum")
    d.wait_for(id="state_empty")
    d.shell("input", "keyevent", "KEYCODE_ESCAPE")
    shot("scr03_browse_empty")

    d.tap(id="btn_open_alerts")
    d.wait_for(id="alert_filters")
    shot("scr09_alerts")
    back()
    d.tap(id="nav_team")
    shot("scr05_no_team")
    d.tap(id="nav_settings")
    shot("settings")


def member_then_leader() -> None:
    """Flows 2 and 3 in Minh Le's seat of Team AI-04."""
    b.reset(me, team="team_ai04")
    d.sign_in(ACCOUNT)
    shot("scr02_home")
    d.tap(id="nav_team")
    d.wait_for(id="btn_vote_leader")
    shot("scr05_my_team")
    d.tap(id="btn_vote_leader")
    d.tap(id=f"candidate_{me.uid}")
    shot("scr06_voting_selected")
    d.tap(id="btn_submit_vote")
    d.wait_for(id="banner_leader_elected")
    time.sleep(4)  # let the snackbar close
    shot("scr06_voting_elected")
    d.tap(id="btn_back_to_team")
    d.wait_for(id="btn_review_lock")
    shot("scr05_my_team_leader")
    d.tap(id="btn_review_lock")
    d.wait_for(id="banner_lock_error")
    shot("scr07_lock_error")
    d.tap(id="btn_invite_pool")
    d.wait_for(id="banner_pool_joined", timeout=40)
    time.sleep(2)
    shot("scr07_pool_member_joined")
    scroll_down()
    d.tap(id="btn_lock_roster")
    d.wait_for(id="dialog_lock_confirm")
    shot("scr07_lock_dialog")
    d.tap(id="dialog_lock_confirm")
    d.wait_for(id="state_locked", timeout=30)
    shot("scr07_locked")
    d.tap(id="btn_back_to_team")
    time.sleep(1)
    d.tap(id="btn_open_profile")
    d.wait_for(id="card_account")
    shot("profile")
    d.tap(id="btn_export_upload")
    d.wait_for(id="export_done", timeout=40)
    shot("profile_export_done")
    scroll_down()
    shot("profile_config_diagnostics")


def pool() -> None:
    b.reset(me)
    d.sign_in(ACCOUNT)
    shot("scr02_home_registration_closed")
    d.tap(id="btn_view_matching_status")
    d.wait_for(id="card_pool_progress")
    shot("scr08_random_pool")


def main() -> None:
    OUT.mkdir(parents=True, exist_ok=True)
    try:
        if sys.argv[1:] == ["pool"]:
            pool()
        else:
            newcomer()
            member_then_leader()
    finally:
        b.reset(me)
        report = OUT / "capture-flutter-errors.txt"
        report.write_text("\n".join(errors) + ("\n" if errors else ""), encoding="utf-8")
        print(f"{len(errors)} Flutter errors -> {report}")


if __name__ == "__main__":
    main()
