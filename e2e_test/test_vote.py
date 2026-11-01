"""TC-08, TC-09: Leader Voting (SCR_06), Flow 2, on live Firestore.

Precondition for both: the test account holds Minh Le's seat in Team AI-04
(3 of 5 members). Quynh has voted for that seat, Hoang for himself, and the
test account has not voted, so its own vote decides the majority.
"""

import pytest

from conftest import ACCOUNT


@pytest.mark.flow2
async def test_tc08_tallies_hidden_until_voting(device, backend, me, artemis):
    backend.reset(me, team="team_ai04")
    device.sign_in(ACCOUNT)

    run = await artemis(
        "Go to My Team and open 'Vote for Leader'. Do not vote. "
        "Report whether any vote counts are visible and what the information box says.",
        'Return JSON: {"vote_counts_visible": bool, "info_title": string, "submit_enabled": bool}',
    )

    assert run.data["vote_counts_visible"] is False
    assert run.data["info_title"] == "Results appear after you vote"
    assert run.data["submit_enabled"] is False
    assert "/3" not in run.screen  # no "x/3" tally bars on screen
    assert me.uid not in backend.get("teams/team_ai04")["votes"]  # nothing was written


@pytest.mark.flow2
async def test_tc09_vote_elects_leader(device, backend, me, artemis):
    backend.reset(me, team="team_ai04")
    device.sign_in(ACCOUNT)

    run = await artemis(
        f"Go to My Team, open 'Vote for Leader', select {me.full_name} (you) and submit the vote. "
        "Report who the team leader is now and how many votes they have.",
        'Return JSON: {"leader_name": string, "leader_votes": int, "tallies_visible": bool}',
    )

    assert run.data["leader_name"] == me.full_name
    assert run.data["leader_votes"] == 2
    assert run.data["tallies_visible"] is True
    assert f"[banner_leader_elected] {me.full_name} is your team leader" in run.screen
    assert "cast_vote" in device.analytics_events()
    # Ground truth: vote and leader are stored in Firestore.
    team = backend.get("teams/team_ai04")
    assert team["votes"][me.uid] == me.uid
    assert team["leaderId"] == me.uid
