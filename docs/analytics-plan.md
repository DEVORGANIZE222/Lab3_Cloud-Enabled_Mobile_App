# EXEMatching analytics plan

Analytics records product actions only. It never sends names, e-mail addresses,
student codes, notification text, or PDF URLs.

| Event | Parameters |
| --- | --- |
| `login` | `login_method` |
| `logout` | none |
| `search_teams` | `query_length`, `result_count`, `filter_count` |
| `view_team` | `team_id`, `team_code` |
| `join_team` | `team_id`, `member_count` |
| `cast_vote` | `team_id`, `changed` |
| `invite_pool` | `team_id`, `invited_count` |
| `lock_roster` | `team_id`, `member_count` |
| `export_report` | `team_id`, `file_size_kb` |

Use Firebase Analytics DebugView on an Android debug build to verify events.
