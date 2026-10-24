"""Captures one screenshot per Figma frame into docs/screenshots (uv run python capture_screens.py).

SCR_08 needs a build with registration closed:
  flutter build apk --debug --dart-define=CONFIG_OVERRIDES=registration_closed=true
then: uv run python capture_screens.py pool
"""

import sys
import time
from pathlib import Path

from device import Device

OUT = Path(__file__).resolve().parent.parent / "docs" / "screenshots"
d = Device("emulator-5554")


def shot(name: str) -> None:
    time.sleep(1.2)  # let transitions and snackbars settle
    d.screenshot(OUT / f"{name}.png")
    print("saved", name)


def main() -> None:
    OUT.mkdir(parents=True, exist_ok=True)
    if sys.argv[1:] == ["pool"]:
        d.sign_in("an.tran@fpt.edu.vn")
        shot("scr02_home_registration_closed")
        d.tap(id="btn_view_matching_status")
        d.wait_for(id="card_pool_progress")
        shot("scr08_random_pool")
        return

    d.reset_app()
    d.launch()
    d.wait_for(id="btn_google_sign_in", timeout=40)
    shot("scr01_sign_in")
    d.tap(id="btn_google_sign_in")
    d.wait_for(id="account_minh.le@fpt.edu.vn")
    shot("scr01_account_picker")

    # Flow 1 as An Tran
    d.sign_in("an.tran@fpt.edu.vn")
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
    d.shell("input", "keyevent", "KEYCODE_BACK")
    d.tap(id="browse_search_field")
    d.shell("input", "text", "quantum")
    d.shell("input", "keyevent", "66")
    d.wait_for(id="state_empty")
    shot("scr03_browse_empty")

    # Flows 2 and 3 as Minh Le
    d.sign_in("minh.le@fpt.edu.vn")
    shot("scr02_home")
    d.tap(id="nav_team")
    d.wait_for(id="btn_vote_leader")
    shot("scr05_my_team")
    d.tap(id="btn_vote_leader")
    d.wait_for(id="candidate_s_minh")
    d.tap(id="candidate_s_minh")
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
    d.wait_for(id="banner_pool_joined", timeout=20)
    time.sleep(3)
    shot("scr07_pool_member_joined")
    d.shell("input", "swipe", "540", "1800", "540", "600", "300")
    d.tap(id="btn_lock_roster")
    d.wait_for(id="dialog_lock_confirm")
    shot("scr07_lock_dialog")
    d.tap(id="dialog_lock_confirm")
    d.wait_for(id="state_locked")
    shot("scr07_locked")
    d.tap(id="btn_back_to_team")
    d.tap(id="nav_alerts")
    d.wait_for(id="alert_filters")
    shot("scr09_alerts")
    d.tap(id="btn_open_profile")
    d.tap(id="btn_export_upload")
    d.wait_for(id="export_done", timeout=20)
    shot("profile_export_done")


if __name__ == "__main__":
    main()
