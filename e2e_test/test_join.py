"""TC-06, TC-07: Team Detail and join (SCR_04), Flow 1 happy and alternative paths."""

import pytest

from conftest import NEWCOMER


@pytest.mark.flow1
async def test_tc06_join_team_with_open_slot(device, artemis):
    device.sign_in(NEWCOMER)

    run = await artemis(
        "Find the team 'FinTech Guard' on the Browse tab, open its details and join it, "
        "confirming in the dialog. After joining, report the team shown on My Team and its member count.",
        'Return JSON: {"joined": bool, "my_team_name": string, "members_text": string}',
    )

    assert run.data["joined"] is True
    assert run.data["my_team_name"] == "FinTech Guard"
    assert "3 of 5" in run.data["members_text"]
    assert "[card_my_team_header] FIN-02" in run.screen
    assert "[member_s_an]" in run.screen
    assert "join_group" in device.analytics_events()


@pytest.mark.flow1
async def test_tc07_team_fills_before_confirming(device, artemis):
    device.sign_in(NEWCOMER)

    run = await artemis(
        "Open 'EduSmart Analytics' from the Browse tab and try to join it, confirming in the dialog. "
        "Report what the app says happened and whether the Join Team button is still available.",
        'Return JSON: {"joined": bool, "message_title": string, "join_button_enabled": bool, "member_count_text": string}',
    )

    assert run.data["joined"] is False
    assert "just filled up" in run.data["message_title"]
    assert run.data["join_button_enabled"] is False
    assert "5 of 5" in run.data["member_count_text"] or "5/5" in run.data["member_count_text"]
    assert "[banner_team_filled]" in run.screen
    assert "[join_blocked_reason] This team is full (5/5)." in run.screen
