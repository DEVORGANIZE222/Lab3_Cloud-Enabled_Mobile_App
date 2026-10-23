"""TC-08, TC-09: Leader Voting (SCR_06), Flow 2."""

import pytest

from conftest import LEADER


@pytest.mark.flow2
async def test_tc08_tallies_hidden_until_voting(device, artemis):
    device.sign_in(LEADER)

    run = await artemis(
        "Go to My Team and open 'Vote for Leader'. Do not vote. "
        "Report whether any vote counts are visible and what the information box says.",
        'Return JSON: {"vote_counts_visible": bool, "info_title": string, "submit_enabled": bool}',
    )

    assert run.data["vote_counts_visible"] is False
    assert run.data["info_title"] == "Results appear after you vote"
    assert run.data["submit_enabled"] is False
    assert "/2" not in run.screen  # no "x/2" tally bars on screen


@pytest.mark.flow2
async def test_tc09_vote_elects_leader(device, artemis):
    device.sign_in(LEADER)

    run = await artemis(
        "Go to My Team, open 'Vote for Leader', select Minh Le (you) and submit the vote. "
        "Report who the team leader is now and how many votes they have.",
        'Return JSON: {"leader_name": string, "leader_votes": int, "tallies_visible": bool}',
    )

    assert run.data["leader_name"] == "Minh Le"
    assert run.data["leader_votes"] == 2
    assert run.data["tallies_visible"] is True
    assert "[banner_leader_elected] Minh Le is your team leader" in run.screen
    assert "cast_vote" in device.analytics_events()
