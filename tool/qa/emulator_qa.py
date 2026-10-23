"""Offline, synthetic-data UI QA utilities for the dedicated Cya! emulator.

Uses only the standard library/ADB. No app internals are replaced. Actions and
screenshots are recorded under ignored .buildlog/qa22. Never targets a phone.
"""
from pathlib import Path
import base64
import json
import re
import subprocess
import sys
import time
import xml.etree.ElementTree as ET

ROOT = Path(__file__).resolve().parents[2]
OUT = ROOT / '.buildlog/qa22'
OUT.mkdir(parents=True, exist_ok=True)
ADB = r'D:\Android\platform-tools\adb.exe'
SERIAL = 'emulator-5560'
PACKAGE = 'dev.cya.app'


def adb(*args, binary=False, timeout=45):
    value = subprocess.check_output([ADB, '-s', SERIAL, *map(str, args)], stderr=subprocess.STDOUT, timeout=timeout)
    return value if binary else value.decode('utf-8', errors='replace')


def shell(*args, **kwargs):
    return adb('shell', *args, **kwargs)


def guard():
    if 'CyaQA_20261023' not in adb('emu', 'avd', 'name'):
        raise RuntimeError('Refusing to drive a device other than the dedicated synthetic QA AVD')


def nodes():
    for attempt in range(3):
        try:
            # Framework UIAutomator waits for complete idleness and stalls on
            # the deliberately looping onboarding illustration. Snapshot the
            # same public accessibility tree without that idle prerequisite.
            result = shell('am', 'instrument', '-w',
                           'dev.cya.qadriver/dev.cya.qafixture.QaInstrumentation', timeout=25)
            match = re.search(r'INSTRUMENTATION_RESULT: tree=([^\r\n]+)', result)
            if not match:
                raise ET.ParseError(result)
            xml = base64.b64decode(match.group(1)).decode('utf-8')
            return list(ET.fromstring(xml).iter('node'))
        except (subprocess.SubprocessError, ET.ParseError):
            if attempt == 2:
                raise
            time.sleep(.5)


def label(node):
    return node.get('text') or node.get('content-desc') or ''


def summary():
    return [{'text': label(n), 'bounds': n.get('bounds'), 'class': n.get('class'),
             'description': n.get('content-desc'),
             'package': n.get('package'), 'id': n.get('resource-id')}
            for n in nodes() if label(n) or n.get('class') == 'android.widget.EditText']


def center(node):
    a, b, c, d = map(int, re.findall(r'\d+', node.get('bounds')))
    return (a+c)//2, (b+d)//2


def tap_node(node):
    x, y = center(node)
    shell('input', 'tap', x, y)
    time.sleep(.7)


def find(text, *, contains=False, exact=None):
    return [n for n in nodes() if any(
        text in value if contains else value == text
        for value in (n.get('text',''), n.get('content-desc','')))]


def tap(text, *, contains=False, scroll=0, index=0):
    if text in ('Home', 'Memories', 'Rhythm', 'Promises', 'Profile'):
        hide_keyboard()
    for i in range(scroll+1):
        found = find(text, contains=contains)
        if not found:
            time.sleep(.5)
            found = find(text, contains=contains)
        non_fields = [n for n in found if n.get('class') != 'android.widget.EditText']
        if non_fields:
            found = non_fields
        if found:
            tap_node(found[index])
            return
        if i < scroll:
            swipe()
    raise AssertionError('UI target not found: ' + text)


def swipe(up=True):
    hide_keyboard()
    size = re.findall(r'(\d+)x(\d+)', shell('wm', 'size'))[-1]
    w,h = map(int,size)
    shell('input', 'swipe', w//2, int(h*(.78 if up else .30)), w//2, int(h*(.30 if up else .78)), 300)
    time.sleep(.3)


def top():
    for _ in range(3):
        swipe(False)


def expect(text, *, contains=False, absent=False, timeout=8):
    deadline = time.monotonic() + timeout
    while True:
        try:
            found = find(text, contains=contains)
        except (subprocess.SubprocessError, ET.ParseError):
            if time.monotonic() >= deadline:
                raise
            time.sleep(.3)
            continue
        if bool(found) != absent:
            return
        if time.monotonic() >= deadline:
            raise AssertionError(('Unexpected visible: ' if absent else 'Expected visible: ') + text)
        time.sleep(.3)


def reveal(text, *, contains=False, scroll=5):
    for i in range(scroll+1):
        if find(text, contains=contains):
            return
        if i < scroll:
            swipe()
    raise AssertionError('Expected in scrollable content: ' + text)


def back():
    shell('input', 'keyevent', 4)
    time.sleep(.8)


def hide_keyboard():
    if re.search(r'(mInputShown|isInputViewShown)=true', shell('dumpsys', 'input_method')):
        back()


def launch():
    shell('am', 'start', '-n', PACKAGE + '/.MainActivity')
    time.sleep(1)


def enter(text, index=0, clear=True):
    fields = [n for n in nodes() if n.get('class') == 'android.widget.EditText']
    if not fields:
        raise AssertionError('No editable field')
    tap_node(fields[index])
    if clear:
        result = shell('am', 'instrument', '-w', '-e', 'input',
                       base64.b64encode(text.encode()).decode() or "''", '-e', 'index', index,
                       'dev.cya.qadriver/dev.cya.qafixture.QaInstrumentation')
        if 'INSTRUMENTATION_CODE: -1' not in result:
            raise AssertionError('Android accessibility text input refused: '+result)
        time.sleep(.3)
        return
    if text.isascii() and re.fullmatch(r'[\w .:/?&=+@-]*', text):
        # Shell quote arguments independently of subprocess/JSON quoting.
        from shlex import quote
        shell('input', 'text', quote(text.replace(' ', '%s')))
    else:
        encoded = base64.b64encode(text.encode()).decode()
        shell('am', 'start', '-n', 'dev.cya.qafixture/.FixtureActivity',
              '--es', 'mode', 'clipboard', '--es', 'base64', encoded)
        time.sleep(.6)
        field = [n for n in nodes() if n.get('class') == 'android.widget.EditText'][index]
        tap_node(field)
        x, y = center(field)
        shell('input', 'swipe', x, y, x, y, 1000)
        tap('Paste')
    time.sleep(.2)


def screenshot(name):
    (OUT / (name + '.png')).write_bytes(adb('exec-out', 'screencap', '-p', binary=True))
    (OUT / (name + '.json')).write_text(json.dumps(summary(), ensure_ascii=False, indent=2), encoding='utf-8')


def case(name, work):
    result = {'case': name}
    start = time.monotonic()
    try:
        guard()
        work()
        result['status'] = 'pass'
    except Exception as error:
        result.update(status='fail', error=type(error).__name__ + ': ' + str(error))
    result['seconds'] = round(time.monotonic()-start, 2)
    try:
        screenshot(name)
        result['evidence'] = name + '.png'
    except Exception as error:
        result['evidence_error'] = type(error).__name__
    with (OUT / 'cases.jsonl').open('a', encoding='utf-8') as output:
        output.write(json.dumps(result, ensure_ascii=False) + '\n')
    print(json.dumps(result, ensure_ascii=False), flush=True)
    return result['status'] == 'pass'


if __name__ == '__main__':
    guard()
    action = sys.argv[1] if len(sys.argv)>1 else 'dump'
    if action == 'dump':
        print(json.dumps(summary(), ensure_ascii=False, indent=2))
    elif action == 'tap':
        tap(sys.argv[2], contains='--contains' in sys.argv)
    elif action == 'text':
        enter(sys.argv[2])
    elif action == 'back':
        back()
    elif action == 'shot':
        screenshot(sys.argv[2])
