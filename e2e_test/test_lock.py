"""TC-10, TC-11: Review & Lock (SCR_07), Flow 3 error, recovery and native share sheet."""

import re

import pytest

from conftest import LEADER


def elect_minh(device) -> None:
    """Precondition: Minh is the elected leader of Team AI-04 (3 of 5 members)."""
    device.sign_in(LEADER)
    device.tap(id="nav_team")
    device.tap(id="btn_vote_leader")
    device.tap(id="candidate_s_minh")
    device.tap(id="btn_submit_vote")
    device.wait_for(id="banner_leader_elected")
    device.tap(id="btn_back_to_team")
    device.wait_for(id="btn_review_lock")


@pytest.mark.flow3
async def test_tc10_lock_blocked_then_recovered_from_pool(device, artemis):
    elect_minh(device)

    run = await artemis(
        "On My Team, open 'Review & Lock'. Note the error that explains why the roster can't be locked. "
        "Recover from it: invite students from the Waiting Pool, then wait until a new member joins "
        "(it takes a few seconds). When every check is done, lock the roster and confirm. "
        "Report the error you saw first, the name of the student who joined, and the confirmation code.",
        'Return JSON: {"first_error": string, "joined_member": string, "locked": bool, "confirmation_code": string}',
    )

    assert run.data["first_error"].startswith("Can't lock yet")
    assert run.data["joined_member"] == "Khanh Vo"
    assert run.data["locked"] is True
    assert re.fullmatch(r"CM-AI04-[0-9A-F]{4}", run.data["confirmation_code"])
    assert "[state_locked]" in run.screen
    assert run.data["confirmation_code"] in run.screen
    events = device.analytics_events()
    assert "invite_from_pool" in events and "lock_roster" in events


@pytest.mark.flow3
@pytest.mark.native
async def test_tc11_share_team_link_opens_android_share_sheet(device, artemis):
    elect_minh(device)

    run = await artemis(
        "On My Team, open 'Review & Lock' and tap 'Share Team Link'. "
        "Stop when the Android share sheet is open and report what it shows. Do not share to any app.",
        'Return JSON: {"share_sheet_open": bool, "shared_text_mentions_team": bool}',
        timeout=600,
    )

    assert run.data["share_sheet_open"] is True
    assert run.data["shared_text_mentions_team"] is True
    # Ground truth: the system chooser (outside the app) is in the foreground.
    assert "intentresolver" in device.foreground_activity(expect="intentresolver")
    device.shell("input", "keyevent", "KEYCODE_BACK")  # close the sheet without sharing
