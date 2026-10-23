"""Shared fixtures: the ARTEMIS client, the device, repeated runs and evidence.

Environment:
  ARTEMIS_BASE_URL   daemon URL (default http://127.0.0.1:8000, started by `uv run artemis ui`)
  ARTEMIS_PROFILE    flash (default) or pro
  DEVICE_SERIAL      adb serial (default emulator-5554)
  E2E_RUNS           runs per test case (default 3)
"""

from __future__ import annotations

import json
import os
import re
from dataclasses import dataclass
from datetime import datetime
from pathlib import Path
from typing import Any

import pytest
from artemis_client import ArtemisClient

from device import PACKAGE, Device

BASE_URL = os.environ.get("ARTEMIS_BASE_URL", "http://127.0.0.1:8000")
PROFILE = os.environ.get("ARTEMIS_PROFILE", "flash")
SERIAL = os.environ.get("DEVICE_SERIAL", "emulator-5554")
RUNS = int(os.environ.get("E2E_RUNS", "3"))
EVIDENCE = Path(__file__).parent / "evidence"

# Seeded test accounts (assets/seed/seed.json). They have no password: the app's
# local auth shows them in a simulated Google account picker.
LEADER = "minh.le@fpt.edu.vn"  # in Team AI-04, 3 of 5 members, no leader yet
NEWCOMER = "an.tran@fpt.edu.vn"  # not in a team


def pytest_generate_tests(metafunc: pytest.Metafunc) -> None:
    # Every test case runs RUNS times; each run is reported separately.
    if "attempt" in metafunc.fixturenames:
        metafunc.parametrize("attempt", range(1, RUNS + 1), ids=lambda n: f"run{n}")


@pytest.fixture(scope="session")
def device() -> Device:
    return Device(SERIAL)


@pytest.fixture(scope="session")
def client() -> ArtemisClient:
    return ArtemisClient(BASE_URL, device_serial=SERIAL, default_profile=PROFILE)


def parse_output(output: Any) -> dict[str, Any]:
    """The Outputter's answer as a dict: accepts a dict, JSON text or JSON inside prose/markdown."""
    if isinstance(output, dict):
        return output
    text = output if isinstance(output, str) else json.dumps(output)
    for candidate in re.findall(r"\{.*\}", text, flags=re.DOTALL):
        try:
            value = json.loads(candidate)
        except json.JSONDecodeError:
            continue
        if isinstance(value, dict):
            return value
    raise AssertionError(f"ARTEMIS output has no JSON object: {text[:500]!r}")


@dataclass
class Run:
    result: Any
    data: dict[str, Any]
    screen: str
    folder: Path


@pytest.fixture
def artemis(client: ArtemisClient, device: Device, request: pytest.FixtureRequest, attempt: int):
    """Runs one goal, saves evidence, and returns the parsed output plus the real screen."""
    folder = EVIDENCE / request.node.originalname / f"run{attempt}"
    folder.mkdir(parents=True, exist_ok=True)

    async def run(goal: str, expected_output: str, *, timeout: float = 900) -> Run:
        started = datetime.now()
        result = await client.run(
            goal,
            profile=PROFILE,
            device_serial=SERIAL,
            locked_app_package=PACKAGE,
            expected_output=expected_output,
            enable_outputter=True,
            timeout=timeout,
        )
        screen = device.screen_text()
        device.screenshot(folder / "final.png")
        (folder / "screen.txt").write_text(screen, encoding="utf-8")
        (folder / "analytics.txt").write_text("\n".join(device.analytics_events()), encoding="utf-8")
        record = {
            "test": request.node.nodeid,
            "attempt": attempt,
            "profile": PROFILE,
            "trace_id": result.trace_id,
            "status": result.status,
            "turns": result.turns,
            "started": started.isoformat(timespec="seconds"),
            "seconds": round((datetime.now() - started).total_seconds(), 1),
            "goal": goal,
            "expected_output": expected_output,
            "output": result.output,
            "error": result.error,
        }
        (folder / "result.json").write_text(json.dumps(record, indent=2, ensure_ascii=False, default=str), "utf-8")
        assert result.succeeded, f"ARTEMIS task {result.trace_id} ended {result.status}: {result.error}"
        return Run(result=result, data=parse_output(result.output), screen=screen, folder=folder)

    yield run
    device.set_network(True)  # never leave the emulator offline after a failed test
