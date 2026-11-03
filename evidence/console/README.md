# Firebase Console Verification Evidence

This directory contains verifiable screenshots from the official Firebase Console for project **`prm393-lab-3-exematching`** (Package: `com.devorganize222.exematching`).

## 1. Authentication & Users
- **Project ID Match:** `prm393-lab-3-exematching` (matches `android/app/google-services.json`).
- **Provider Status:** Google Sign-In Provider is **Enabled**.
- **SHA-1 Fingerprint:** Android debug keystore fingerprint registered under Android App settings.
- **Roster Account:** Tested with student test account `megalit2578@gmail.com` and FPT domain accounts.
- **Console Proof:**
  - `console_auth_users.png`: Lists registered test users with Provider icon (Google), UID, and creation timestamp.

## 2. Cloud Firestore
- **Database ID:** `(default)` in region `asia-southeast1`.
- **Collections verified:**
  - `configuration/registration`: Semester "Fall 2026", valid `opensAt` and `closesAt` Timestamps.
  - `allowedEmails`: Student roster allowlist with `enabled: true`.
  - `teams`: 5 seeded teams (`team_ai04`, `team_fin02`, `team_edu07`, `team_web11`, `team_mob03`).
  - `waitingPool`: Pool student candidate `s_khanh` (`Khanh Vo`) with `assigned: false` for Flow 3 recovery.
  - `students`: User profile metadata mapped by Auth UID.
- **Security Rules:** Deployed from `firebase/firestore.rules`.
- **Console Proof:**
  - `console_firestore_teams.png`: Shows team documents with real fields.
  - `console_firestore_rules.png`: Shows active security rules with `isValidTeamUpdate()` and `isRosterMember()`.

## 3. Cloud Storage
- **Bucket:** `prm393-lab-3-exematching.firebasestorage.app`.
- **Storage Path:** `reports/{uid}/team-ai-04-*.pdf`.
- **Security Rules:** Deployed from `firebase/storage.rules` enforcing strict UID isolation (`request.auth.uid == userId`).
- **Console Proof:**
  - `console_storage_bucket.png`: Shows uploaded PDF files in user subfolders.

