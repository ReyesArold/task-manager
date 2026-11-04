Bug-adjacent / risky
1. Notification permission on Android 13+: requestNotificationsPermission is called every time a task is added, and the settings toggle only requests when turning on. Check NotificationHelper.show path works when permission was denied — a hard denial won't re-prompt, so add a graceful fallback (just no notification, not an error).
2. DONE Profile image is stored by raw path (profile_image_helper.dart:11). If the OS cleans the temp/cache the image breaks. Better: copy the picked file into the app's documents directory and store that path.
Feature wins (high user value)
3. DONE Search/filter tasks — a small search field on the dashboard filters _tasks (title/description). Cheap, high impact.
4. Task progress summary — show e.g. "3/10 done" with a small LinearProgressIndicator in the dashboard header. Easy win.
5. Locale-aware dates — intl is already a dependency; replace the hand-rolled mm/dd/yyyy in the task details (home_page.dart:415) with DateFormat(..., locale).format() so it follows the chosen language.
Security / data
6. Hash the stored password (settings_helper.dart:53). SharedPreferences stores it in plaintext. A simple SHA-256 (or crypto package) would be much better; also verifies current password against the hash.
7. Per-user data: tasks/profile are global right now. If you ever add a second user, they'd share everything — consider keying tasks by username.
Housekeeping
8. Tests: only 2 smoke tests exist. Add widget tests for login validation, change-password flow, and delete-confirm/undo.
9. App branding: default Flutter launcher icon/name/README. Custom icon + updating README (and pubspec description) makes it feel finished.
10. Username display in home: the header shows @username, but after editing profile from the drawer it won't refresh until the header card is tapped — worth a consistent refresh (e.g. await the drawer navigation)