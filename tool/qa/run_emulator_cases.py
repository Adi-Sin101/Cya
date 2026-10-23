"""Production UI checks; synthetic data only in the guarded QA AVD.

Run one named group at a time after inspecting the installed UI. Assertions and
screenshots are written by emulator_qa.case; no production services are mocked.
"""
import sys
import time
import base64
import re
import json
import hashlib
import zipfile
import emulator_qa as q


def onboarding():
    q.launch()
    # Resume the current synthetic onboarding step after an environment restart.
    for _ in range(3):
        if q.find('Allow notifications'):
            break
        if q.find('Next'):
            q.tap('Next')
        else:
            q.tap('Got it', scroll=4)
    q.tap('Not now', scroll=4)
    q.tap('Remind me later', scroll=4)
    q.expect('What should I call you?')
    q.enter('Cya QA')
    q.back()
    q.tap('Continue', scroll=3)
    q.tap('Skip — no lock', scroll=3)
    q.expect('Home', contains=True, timeout=20)
    assert 'granted=false' in q.shell('dumpsys', 'package', q.PACKAGE).split('android.permission.POST_NOTIFICATIONS:')[-1][:30]


def write_thought(text):
    q.top()
    q.tap('Write a thought', contains=True, scroll=3)
    q.expect('Save a thought')
    q.enter(text)
    q.back()
    q.tap('Save thought')
    time.sleep(.6)


def typed_capture():
    write_thought('QA original thought about learning Bangla and daily walks')
    q.tap('Memories', contains=True)
    q.reveal('QA original thought', contains=True)


def bangla_capture():
    write_thought('আজ বিকেলে হাঁটতে যাব এবং বই পড়ব')
    q.reveal('আজ বিকেলে', contains=True)


def banglish_capture():
    write_thought('Aj bikele hata ar boi porar plan ache QA')
    q.reveal('Aj bikele hata', contains=True)


def draft_cancel():
    q.top()
    q.tap('Write a thought', contains=True, scroll=3)
    q.enter('QA draft must never become a saved memory')
    q.back()
    q.tap('Cancel')
    q.expect('Leave this draft?')
    q.tap('Keep writing')
    q.expect('QA draft', contains=True)
    q.tap('Cancel')
    q.tap('Discard draft')
    q.expect('Leave this draft?', absent=True)
    q.expect('QA draft must never become a saved memory', absent=True)


def voice_denied():
    q.top()
    q.tap('Record voice')
    q.expect('Start recording')
    q.tap('Start recording')
    q.tap('Don’t allow', contains=True)
    q.expect('Could not start recording.', contains=True)
    q.expect('Microphone permission settings')
    q.tap('Close', scroll=3)


def voice_record():
    q.top()
    q.tap('Record voice')
    q.tap('Start recording')
    if q.find('While using the app', contains=True):
        q.tap('While using the app', contains=True)
    q.expect('Stop and save', timeout=15)
    time.sleep(3)
    q.tap('Stop to review')
    q.expect('Save voice thought')
    q.tap('Play original')
    time.sleep(1)
    q.tap('Stop playback')
    q.tap('Save voice thought')
    q.top()
    q.tap('Voice', scroll=3)
    q.reveal('Play original audio', contains=True)
    q.tap('Play original audio', contains=True)
    q.expect('Stop audio playback')
    q.tap('Stop audio playback')


def voice_recovery():
    q.top()
    q.tap('Record voice')
    q.tap('Start recording')
    q.expect('Stop and save')
    time.sleep(3)
    q.shell('am','force-stop',q.PACKAGE)
    q.launch()
    q.expect('Home', timeout=20)
    q.tap('Record voice', scroll=3)
    q.reveal('Interrupted or unsaved recordings')
    q.tap('Recover', scroll=3)
    q.expect('Save voice thought', timeout=15)
    q.tap('Save voice thought')


def home_garden():
    q.tap('Home')
    q.top()
    q.tap('Open Memory Garden.', contains=True)
    q.expect('Memory Garden', contains=True)
    q.back()
    q.expect('Record voice')


def profile_garden():
    q.tap('Profile')
    q.top()
    q.tap('Open Memory Garden.', contains=True, scroll=2)
    q.expect('Memory Garden', contains=True)
    q.back()
    q.reveal('Your name', contains=True)


def model_missing():
    q.tap('Memories')
    q.top()
    q.tap('Local semantic model')
    q.expect('Local semantic memory')
    q.reveal('Choose local model file')
    q.screenshot('model-missing-details')
    q.back()


def clear_memory_filters():
    q.tap('Memories', index=-1)
    q.top()
    q.tap('All memories', scroll=2)
    q.top()
    q.enter('')
    q.back()


def keyword_search():
    clear_memory_filters()
    for query, expected in [('Bangla','QA original thought'),
                            ('বিকেলে','আজ বিকেলে'),
                            ('bikele','Aj bikele hata')]:
        q.top()
        q.enter(query)
        q.back()
        q.reveal(expected, contains=True)
        q.screenshot('keyword-'+('bangla' if query=='বিকেলে' else query.lower()))
    q.top()
    q.enter('')
    q.back()


def memory_edit_history():
    clear_memory_filters()
    q.enter('QA original thought')
    q.back()
    q.reveal('Memory actions')
    q.tap('Memory actions')
    q.tap('Edit')
    q.enter('QA updated reflection about learning Bangla')
    q.back()
    q.tap('Save thought')
    q.top()
    q.enter('QA updated reflection')
    q.back()
    q.reveal('Memory actions')
    q.tap('Memory actions')
    q.tap('History')
    q.expect('QA updated reflection', contains=True)
    q.reveal('QA original thought', contains=True)
    q.back()


def branch():
    q.reveal('Branch')
    q.tap('Branch')
    q.expect('Explore a separate branch')
    q.enter('QA branch exploring a smaller reading habit')
    q.back()
    q.tap('Save branch')
    q.top()
    q.enter('QA branch')
    q.back()
    q.reveal('Connections')
    q.tap('Connections')
    q.expect('Connections')
    q.reveal('QA updated reflection', contains=True)
    q.back()


def archive_restore_delete():
    q.reveal('Memory actions')
    q.tap('Memory actions')
    q.tap('Archive')
    q.top()
    q.tap('Show archived thoughts')
    q.reveal('QA branch', contains=True)
    q.reveal('Memory actions')
    q.tap('Memory actions')
    q.tap('Restore')
    q.top()
    q.tap('Show active thoughts')
    q.reveal('QA branch', contains=True)
    q.reveal('Memory actions')
    q.tap('Memory actions')
    q.tap('Delete permanently')
    q.expect('Delete this thought permanently?')
    q.tap('Keep thought')
    q.tap('Memory actions')
    q.tap('Delete permanently')
    q.tap('Delete permanently')
    q.expect('QA branch exploring a smaller reading habit', contains=True, absent=True)
    q.top()
    q.enter('')
    q.back()


def create_topic():
    clear_memory_filters()
    q.tap('Topics and projects', scroll=3)
    q.tap('Create topic or project', scroll=3)
    q.enter('QA reading topic')
    q.back()
    q.tap('Save')
    q.reveal('QA reading topic', contains=True)
    q.tap('QA reading topic', contains=True)
    q.expect('QA reading topic', contains=True)
    q.back()
    q.back()


def focus_clock():
    q.tap('Rhythm')
    q.tap('Focus on one thing', scroll=4)
    q.enter('QA read one page')
    q.back()
    q.tap('15 min', scroll=3)
    q.tap('Begin focus', scroll=3)
    q.tap('Pause', scroll=3)
    q.expect('Resume')
    q.shell('am','force-stop',q.PACKAGE)
    q.launch()
    q.expect('Home',timeout=20)
    q.tap('Rhythm')
    q.tap('QA read one page', contains=True,scroll=3)
    q.reveal('Resume')
    q.tap('Resume')
    q.expect('Pause')
    q.tap('Save a thought',index=0)
    q.enter('QA thought saved during chosen focus')
    q.back()
    q.tap('Save thought')
    q.expect('You chose',contains=True)
    q.tap('End focus',scroll=3)
    q.expect('Your rhythm',timeout=12)
    q.reveal('Focus on one thing')


def create_routine():
    q.tap('Rhythm')
    q.top()
    q.tap('Manage routines')
    q.tap('Create routine',scroll=4)
    q.enter('QA daily reading')
    q.enter('Open book\nRead a page\nWrite one thought',index=1)
    q.back()
    q.tap('Fri',scroll=2)
    q.tap('Save routine',scroll=4)
    q.reveal('QA daily reading',contains=True)
    q.back()
    q.top()
    q.tap('Add routines to this day',scroll=4)
    q.tap('QA daily reading',contains=True)
    q.reveal('QA daily reading',contains=True)
    q.reveal('Routine options')


def routine_outcomes():
    q.tap('Routine options')
    q.tap('Skip this occurrence')
    q.reveal('Skipped',contains=True)
    q.tap('Choose again',scroll=2)
    q.tap('Routine options')
    q.tap('Make it lighter / change time')
    q.expect('Make this occurrence fit')
    q.enter('Read a sentence',index=0)
    q.back()
    q.tap('Save this plan',scroll=3)
    q.reveal('Read a sentence',contains=True)
    q.tap('Mark completed',scroll=3)
    q.reveal('Done',contains=True)
    q.tap('Routine options')
    q.tap('Occurrence history')
    q.reveal('completed',contains=True)
    q.back()


def daily_review():
    q.top()
    q.tap('Look back, gently',contains=True,scroll=5)
    q.expect('A little perspective')
    q.reveal('Save optional note',scroll=6)
    q.enter('QA review: a small reading step helped')
    q.back()
    q.tap('Save optional note',scroll=3)
    q.screenshot('review-note-saved')
    q.tap('Done for now',scroll=3)


def promise_capture():
    q.tap('Home')
    q.tap('Capture')
    q.tap('Capture a promise',contains=True)
    q.enter('QA promise to finish reading')
    q.back()
    q.tap('Tomorrow',scroll=3)
    q.tap('Weekend',scroll=3)
    q.tap('Tonight',scroll=3)
    q.tap('Save to Cya!',contains=True,scroll=3)
    q.tap('Promises',index=-1)
    q.reveal('QA promise to finish reading',contains=True)
    q.tap('QA promise to finish reading',contains=True)
    q.reveal('Mark as Done')
    q.tap('Snooze',scroll=3)
    q.tap('In an hour')
    q.reveal('Mark as Done')
    q.tap('Mark as Done')
    q.reveal('Mark as not done')
    q.tap('Mark as not done')
    for _ in range(2):
        q.tap('Snooze',scroll=3)
        q.tap('In an hour')
    q.reveal('Let it go (archive)')
    q.tap('Let it go (archive)')
    q.back()


def native_capture():
    q.shell('am','force-stop',q.PACKAGE)
    q.adb('logcat','-c')
    q.shell('am','start','-n','dev.cya.qafixture/.FixtureActivity',
            '--es','mode','share','--es','base64',
            base64.b64encode('QA native share বাংলা example https://example.invalid/qa'.encode()).decode())
    time.sleep(1)
    q.shell('am','start','-n',q.PACKAGE+'/.capture.CaptureActivity',
            '-a','android.intent.action.PROCESS_TEXT','-t','text/plain',
            '--es','android.intent.extra.PROCESS_TEXT','QA_native_process_text')
    time.sleep(1)
    logs=q.adb('logcat','-d','-s','CyaCapture','flutter')
    (q.OUT/'native-capture.log').write_text(logs,encoding='utf-8')
    assert len(re.findall('capture_ok',logs))==2,logs
    assert 'Flutter engine' not in logs,logs
    q.launch()
    q.expect('Promises',timeout=20)
    q.tap('Promises',index=-1)
    q.reveal('QA_native_process_text',contains=True)
    q.enter('native share')
    q.back()
    q.reveal('QA native share',contains=True)


def widget_host():
    q.shell('am','start','-n','dev.cya.qafixture/.FixtureActivity','--es','mode','widget')
    time.sleep(1)
    if q.find('Allow'):
        q.tap('Allow')
    if q.find('Create'):
        q.tap('Create')
    q.screenshot('widget-host-initial')
    q.expect('Save something to Cya!')
    q.tap('Save something to Cya!')
    q.expect('What do you want to save for later?')
    q.enter('QA widget native capture')
    q.hide_keyboard()
    q.tap('SAVE TO CYA!')
    q.launch()
    q.expect('Home',timeout=20)
    q.tap('Promises',index=-1)
    q.enter('QA widget native capture')
    q.back()
    q.reveal('QA widget native capture',contains=True)


def quick_settings_tile():
    component=q.PACKAGE+'/.tile.CyaTileService'
    q.shell('cmd','statusbar','add-tile',component)
    q.shell('cmd','statusbar','expand-settings')
    time.sleep(1)
    q.shell('cmd','statusbar','click-tile',component)
    q.expect('What do you want to save for later?',timeout=15)
    q.enter('QA Quick Settings tile capture')
    q.hide_keyboard()
    q.tap('SAVE TO CYA!')
    q.shell('cmd','statusbar','collapse')
    q.launch()
    q.expect('Home',timeout=20)
    q.tap('Promises',index=-1)
    q.enter('QA Quick Settings tile capture')
    q.back()
    q.reveal('QA Quick Settings tile capture',contains=True)


def schedule_notification():
    q.shell('pm','grant',q.PACKAGE,'android.permission.POST_NOTIFICATIONS')
    now=q.shell('date','+%H:%M').strip()
    hour,minute=map(int,now.split(':'))
    minute+=3
    hour=(hour+minute//60)%24
    minute%=60
    q.tap('Home')
    q.tap('Capture')
    q.tap('Capture a promise',contains=True)
    q.enter('QA timed notification delivery')
    q.back()
    q.tap('Pick date',scroll=3)
    q.tap('OK')
    q.tap('Switch to text input mode')
    q.enter(str(hour%12 or 12),index=0)
    q.enter(str(minute).zfill(2),index=1)
    q.hide_keyboard()
    q.tap('OK')
    q.tap('Save to Cya!',contains=True,scroll=3)
    alarms=q.shell('dumpsys','alarm')
    assert q.PACKAGE in alarms
    (q.OUT/'scheduled-alarms.txt').write_text(alarms,encoding='utf-8')


def notification_done():
    q.shell('cmd','statusbar','expand-notifications')
    q.reveal('QA timed notification delivery',scroll=8)
    if not q.find('Done'):
        title=q.find('QA timed notification delivery')[0]
        arrows=q.find('Expand')
        q.tap_node(min(arrows,key=lambda n:abs(q.center(n)[1]-q.center(title)[1])))
    q.screenshot('notification-delivered')
    q.tap('Done',contains=True)
    q.shell('cmd','statusbar','collapse')
    q.launch()
    if not q.find('Promises'):
        q.back()
    q.tap('Promises',index=-1)
    q.enter('QA timed notification delivery')
    q.back()
    q.tap('All',contains=False)
    q.tap('QA timed notification delivery',contains=True)
    q.reveal('Mark as not done')


def start_expiry_probe():
    q.tap('Home')
    q.tap('Rhythm')
    q.top()
    q.reveal('Routine options')
    q.tap('Routine options')
    q.tap('Plan for the selected day')
    q.tap('Focus',scroll=3)
    q.tap('15 min',scroll=3)
    q.tap('Begin focus',scroll=3)
    q.expect('Pause')
    (q.OUT/'focus-expiry-start.txt').write_text(q.shell('date','+%s').strip(),encoding='utf-8')
    q.back()


def check_expiry_probe():
    start=int((q.OUT/'focus-expiry-start.txt').read_text())
    now=int(q.shell('date','+%s').strip())
    assert now-start>=900, 'Actual 15-minute interval has not elapsed'
    if q.find('Focus'):
        q.top()
    else:
        q.tap('Rhythm')
        q.top()
        q.tap('QA daily reading',contains=True,scroll=3)
    q.reveal('time is up')
    q.screenshot('expired-focus-awaits-explicit-outcome')
    q.tap('End focus',scroll=3)
    q.reveal('Mark completed')


def profile_preferences_and_lock():
    q.tap('Profile')
    q.top()
    q.tap('Your name',contains=True,scroll=4)
    q.enter('Cya QA Updated')
    q.back()
    q.tap('Save')
    q.tap('Dark mode',contains=True,scroll=2)
    q.expect('Using the calm night palette',contains=True)
    q.screenshot('profile-dark-mode')
    q.tap('Dark mode',contains=True)
    q.expect('Using the bright garden palette',contains=True)
    q.tap('App lock',contains=True,scroll=4)
    q.expect('Set a new PIN')
    for digit in '2468':q.tap(digit,scroll=2)
    q.expect('Type it once more')
    for digit in '2468':q.tap(digit)
    # Verify the persisted credential through a fresh process, rather than
    # assuming the settings route has returned at a particular animation frame.
    q.shell('am','force-stop',q.PACKAGE)
    q.launch()
    q.expect('Welcome back',timeout=20)
    q.expect('Home',absent=True)
    for digit in '1111':q.tap(digit)
    q.expect('Not quite.',contains=True)
    for digit in '2468':q.tap(digit)
    q.expect('Home',timeout=15)
    q.tap('Profile')
    q.tap('Turn off the lock',contains=True,scroll=6)
    q.enter('2468')
    q.back()
    q.tap('Turn off')
    q.expect('Lock removed.',contains=True)


def verify_existing_pin():
    q.shell('am','force-stop',q.PACKAGE)
    q.launch()
    q.expect('Welcome back',timeout=20)
    q.expect('Home',absent=True)
    for digit in '1111':q.tap(digit)
    q.expect('Not quite.',contains=True)
    for digit in '2468':q.tap(digit)
    q.expect('Home',timeout=15)
    q.tap('Profile')
    q.tap('Turn off the lock',contains=True,scroll=8)
    q.enter('2468')
    q.hide_keyboard()
    q.tap('Turn off')
    q.expect('Lock removed.',contains=True)


def export_backup():
    q.tap('Profile')
    q.top()
    q.tap('Export my data',contains=True,scroll=8)
    q.tap('Cya QA Fixture',contains=True,scroll=3)
    q.expect('QA export received:',contains=True,timeout=15)
    q.adb('pull','/sdcard/Android/data/dev.cya.qafixture/files/received.zip',q.OUT/'roundtrip.zip')
    with zipfile.ZipFile(q.OUT/'roundtrip.zip') as archive:
        manifest=archive.read('manifest.json')
        assert hashlib.sha256(manifest).hexdigest()==archive.read('manifest.sha256').decode()
        data=json.loads(manifest)
        assert data['formatVersion']==8
        assert data['memories'] and data['memoryAttachments'] and data['routines']
        assert not any(key.startswith('lock_pin_') for key in data['preferences'])
        (q.OUT/'export-manifest.json').write_bytes(manifest)
        for item in data['memoryAttachments']:
            audio=archive.read('attachments/'+item['relativePath'])
            assert audio[:4]==b'RIFF'
            assert hashlib.sha256(audio).hexdigest()==item['sha256']
    q.adb('push',q.OUT/'roundtrip.zip','/sdcard/Download/cya-qa-roundtrip.zip')
    (q.OUT/'invalid.zip').write_bytes(b'Invalid Cya QA archive')
    q.adb('push',q.OUT/'invalid.zip','/sdcard/Download/cya-qa-invalid.zip')
    q.launch()


def choose_download(name):
    # Real Storage Access Framework picker, never a fabricated app callback.
    if q.find('Show roots'):
        q.tap('Show roots')
    if q.find('Downloads'):
        q.tap('Downloads')
    else:
        q.tap('Download',contains=True)
    q.tap(name,contains=True,scroll=6)


def import_invalid_backup():
    q.tap('Profile')
    q.top()
    q.tap('Import a backup',contains=True,scroll=8)
    q.tap('Choose local backup',scroll=3)
    choose_download('cya-qa-invalid.zip')
    q.reveal('Could not validate this backup.',contains=True)
    q.expect('Import as new copies',absent=True)


def import_valid_backup():
    q.top()
    q.tap('Choose local backup',scroll=3)
    choose_download('cya-qa-roundtrip.zip')
    q.tap('Import as new copies',scroll=8)
    q.reveal('Backup imported as new copies.',contains=True,scroll=8)
    q.back()


def model_install():
    q.tap('Memories',index=-1)
    q.top()
    q.tap('Local semantic model')
    q.tap('Choose local model file',scroll=4)
    choose_download('embeddinggemma-2-740m.litertlm')
    q.reveal('Local model installed.',contains=True,scroll=5)


GROUPS = {
    'onboarding': [('01-onboarding-permission-declined', onboarding)],
    'text': [('02-text-capture', typed_capture),
             ('03-bangla-capture', bangla_capture),
             ('04-banglish-capture', banglish_capture),
             ('05-draft-discard-confirmation', draft_cancel)],
    'unicode': [('03-bangla-capture', bangla_capture),
                ('04-banglish-capture', banglish_capture),
                ('05-draft-discard-confirmation', draft_cancel)],
    'voice-denied': [('06-microphone-denied', voice_denied)],
    'voice': [('07-record-review-play-save', voice_record),
              ('08-interrupted-recording-recovery', voice_recovery)],
    'navigation': [('09-home-garden-return', home_garden),
                   ('10-profile-garden-return', profile_garden),
                   ('11-missing-model-controls', model_missing)],
    'memory-lifecycle': [('12-multilingual-keyword-search', keyword_search),
                         ('13-edit-preserves-original-history', memory_edit_history),
                         ('14-source-linked-branch', branch),
                         ('15-memory-archive-restore-delete', archive_restore_delete)],
    'memory-delete': [('15-memory-archive-restore-delete', archive_restore_delete)],
    'topic': [('16-create-and-open-topic',create_topic)],
    'focus': [('17-focus-pause-restart-capture-end',focus_clock)],
    'routines': [('18-create-and-select-routine',create_routine),
                 ('19-skip-replan-adjust-complete-history',routine_outcomes),
                 ('20-daily-review-note',daily_review)],
    'promise': [('21-promise-presets-snooze-done-reopen-archive',promise_capture)],
    'native': [('22-cold-native-share-and-process-text',native_capture)],
    'widget': [('23-real-remoteviews-in-test-host',widget_host)],
    'tile': [('28-system-quick-settings-native-capture',quick_settings_tile)],
    'schedule-notification': [('24-custom-promise-and-real-alarm-scheduling',schedule_notification)],
    'notification': [('25-delivered-notification-done-action',notification_done)],
    'start-expiry': [('26-start-real-15-minute-expiry-probe',start_expiry_probe)],
    'expiry': [('27-time-passage-does-not-complete-routine',check_expiry_probe)],
    'profile-lock': [('29-profile-theme-pin-wrong-pin-unlock-remove',profile_preferences_and_lock)],
    'verify-pin': [('29b-persisted-pin-wrong-pin-unlock-remove',verify_existing_pin)],
    'export': [('30-versioned-export-real-share-and-audio-integrity',export_backup)],
    'import': [('31-corrupt-backup-rejected',import_invalid_backup),
               ('32-valid-backup-appends-copies',import_valid_backup)],
    'model-install': [('33-user-selected-pinned-local-model-install',model_install)],
}

if __name__ == '__main__':
    q.guard()
    for name, work in GROUPS[sys.argv[1]]:
        if not q.case(name, work):
            raise SystemExit('Stopped at failed assertion; inspect UI before continuing.')
