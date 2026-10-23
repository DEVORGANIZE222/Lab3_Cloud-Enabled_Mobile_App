"""TC-12, TC-13: Alerts (SCR_09) and Profile export/upload."""

import re

from conftest import LEADER


async def test_tc12_decline_invite_then_undo(device, artemis):
    device.sign_in(LEADER)

    run = await artemis(
        "Open the Alerts tab and switch to the Invites filter. Decline the invite from FinTech Guard, "
        "then use Undo in the message at the bottom of the screen. Report how many invites are listed "
        "right after declining and after undoing.",
        'Return JSON: {"invites_after_decline": int, "invites_after_undo": int, "invite_team": string}',
    )

    assert run.data["invites_after_decline"] == 0
    assert run.data["invites_after_undo"] == 1
    assert "FinTech Guard" in run.data["invite_team"]
    assert "Invites (1)" in run.screen


async def test_tc13_export_and_upload_team_summary(device, artemis):
    device.sign_in(LEADER)

    run = await artemis(
        "Open your profile from the avatar at the top right. Under Team summary, tap 'Export & Upload PDF' "
        "and wait until the upload finishes. Report the uploaded file name and its size.",
        'Return JSON: {"uploaded": bool, "file_name": string, "size_kb": int}',
    )

    assert run.data["uploaded"] is True
    assert re.fullmatch(r"team-ai-04-\d{8}-\d{4}\.pdf", run.data["file_name"])
    assert run.data["size_kb"] > 0
    # Ground truth: the success banner holds the uploaded file's URL, ending in the same name.
    assert re.search(r"\[export_done\].*/reports/s_minh/team-ai-04-\d{8}-\d{4}\.pdf", run.screen, re.S)
    assert run.data["file_name"] in run.screen
    assert "export_report" in device.analytics_events()
