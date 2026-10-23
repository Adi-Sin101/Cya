# Isolated Android release QA

These developer tools drive the **normal Cya! release** through Android UI,
Storage Access Framework, notifications, native PendingIntents and accessibility.
They are not shipped in Cya! and add no application dependencies or permissions.
No account, API or network is used by the fixtures.

Use only synthetic data. The driver refuses an AVD other than
`CyaQA_20261023` on `emulator-5560`. Do not change that target to a personal phone.
Cases intentionally edit/delete synthetic records and forcibly stop the app.
They are ordered exploratory groups, not a resettable one-command certification.
Inspect the actual UI and saved evidence after a failed assertion before resuming.

Prerequisites: installed Android34 Google APIs x86_64 image, SDK at `D:\Android`,
JDK17 at the path in `build_fixture.py` (or set `JAVA_HOME`), Python3 and a local
release APK. Create a separate AVD, disable host microphone and Wi-Fi/mobile data,
wait for `sys.boot_completed=1`, then install the release without touching any
personal device or another AVD. Host GPU worked around this PC's QEMU crashes;
see the QA report for exact environment and limitations.

```powershell
python tool/qa/build_fixture.py
D:\Android\platform-tools\adb.exe -s emulator-5560 install -r .buildlog/qa22/fixture/fixture.apk
D:\Android\platform-tools\adb.exe -s emulator-5560 install -r .buildlog/qa22/fixture/driver.apk
python tool/qa/emulator_qa.py dump
python tool/qa/run_emulator_cases.py onboarding
python tool/qa/run_emulator_cases.py text
```

The fixture hosts real RemoteViews, receives actual exported URI bytes, and can
provide synthetic Unicode clipboard/share input. A **separate** driver package
takes Android accessibility snapshots and uses public editable-node actions.
Keeping them separate matters: `am instrument` restarts its target process,
which must never be the Cya! process or the running widget/export host.

Snapshots do not wait for total animation idleness. Scrolls first dismiss the
IME so they cannot become swipe-typing. Both native text and content descriptions
are queried. Native buttons may expose uppercase labels; lazy lists need scrolling.
Cold startup and accessibility attachment can require retries on a loaded host.

Evidence is ignored under `.buildlog/qa22`: screenshots, accessibility trees,
append-only `cases.jsonl`, actual exports and logs. Early driver failures remain
in that log; distinguish them from reproducible application defects. A passing
case is a bounded assertion, not proof of every edge condition or physical-device
performance. The readable QA report records coverage and exclusions explicitly.

Model checks require the exact locally supplied artifact from the compatibility
document; do not download or substitute one silently. Public speech fixtures and
their provenance are documented under `tool/benchmarks` and `docs/revamp`.
