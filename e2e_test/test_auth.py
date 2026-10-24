"""TC-01, TC-02: Sign In (SCR_01)."""

from conftest import LEADER


async def test_tc01_wrong_domain_is_rejected(device, artemis):
    device.reset_app()
    device.launch()
    device.wait_for(id="btn_google_sign_in", timeout=40)

    run = await artemis(
        "Tap 'Continue with Google'. In the account list, choose the personal Gmail account "
        "(minh.personal@gmail.com), not an fpt.edu.vn one. Then read the message the app shows.",
        'Return JSON: {"signed_in": bool, "error_title": string, "error_mentions_fpt_domain": bool}',
    )

    assert run.data["signed_in"] is False
    assert "not an fpt account" in run.data["error_title"].lower()
    assert run.data["error_mentions_fpt_domain"] is True
    # Ground truth: still on Sign In, with the wrong-account banner.
    assert "[sign_in_message] This is not an FPT account" in run.screen
    assert "[btn_google_sign_in]" in run.screen


async def test_tc02_sign_in_with_fpt_account(device, artemis):
    device.reset_app()
    device.launch()
    device.wait_for(id="btn_google_sign_in", timeout=40)

    run = await artemis(
        f"Sign in with Google using the account {LEADER}. "
        "When the Home screen opens, read the greeting, the registration deadline and the team name.",
        'Return JSON: {"greeting": string, "deadline_text": string, "team_name": string}',
    )

    assert run.data["greeting"].startswith("Hi, Minh")
    assert "left" in run.data["deadline_text"]
    assert "AI-04" in run.data["team_name"]
    assert "[card_deadline]" in run.screen
    assert "login" in device.analytics_events()
