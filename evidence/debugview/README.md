# Google Analytics DebugView Evidence

This directory documents the real-time event tracking verified in **Firebase Analytics DebugView** for project `prm393-lab-3-exematching`.

## 1. How to Reproduce DebugView Tracking
Run via ADB on the connected Android emulator/device:
```bash
adb shell setprop debug.firebase.analytics.app com.devorganize222.exematching
```

To turn off after testing:
```bash
adb shell setprop debug.firebase.analytics.app .none.
```

## 2. Event Tracking Specification (9 Verified Events)
All events strictly adhere to Privacy-by-Design principles (zero PII: no email, no name, no raw student code).

| Event Name | Screen / Trigger | Parameters Verified | Expected Product Question Answered |
|---|---|---|---|
| `login` | SCR_01 / Google Sign-in Success | `login_method="google"` | Weekly active returning student volume |
| `search_teams` | SCR_03 / Query or filter changed | `query_length`, `result_count`, `filter_count` | Popular topics and zero-result rates |
| `view_team` | SCR_04 / Group details opened | `team_id`, `team_code` | Most visited teams in semester |
| `join_team` | SCR_04 / Confirmed join dialog | `team_id`, `member_count` | Speed of roster fill across categories |
| `cast_vote` | SCR_06 / Vote submitted for leader | `team_id`, `changed=true/false` | Consensus rate on leader elections |
| `invite_pool` | SCR_07 / Waiting pool candidate invite | `team_id`, `invited_count` | Success rate of automated pool matching |
| `lock_roster` | SCR_07 / Leader locks confirmed team | `team_id`, `member_count` | On-time roster completion rate |
| `export_report` | Profile / Export & upload team PDF | `team_id`, `file_size_kb` | Ratio of students archiving proof PDF |
| `logout` | Profile / Sign-out confirmed | *(no parameters)* | Active session duration |

## 3. Screenshots Checklist
- `debugview_overview.png`: Real-time stream of 9 events on the left timeline.
- `debugview_user_id.png`: Shows `setUserId` with Auth UID on the top right.
- `debugview_params_detail.png`: Detailed inspector verifying custom parameters and types.

