import pytest
import os

# Pytest fixture for Google ARTEMIS Client
# Requires environment variables: MULTIMODAL_API_KEY, ANDROID_DEVICE_SERIAL
@pytest.fixture
def artemis_profile():
    return {
        "profile": os.getenv("ARTEMIS_PROFILE", "flash"),
        "device_serial": os.getenv("ANDROID_DEVICE_SERIAL", "emulator-5554"),
    }
