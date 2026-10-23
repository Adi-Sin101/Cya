"""Build an offline emulator-only fixture using the installed Android SDK/JDK.

No Gradle/download/dependency or Cya! manifest changes. Outputs stay ignored.
"""
from pathlib import Path
import os
import subprocess
import zipfile

root = Path(__file__).resolve().parents[2]
out = root / '.buildlog/qa22/fixture'
out.mkdir(parents=True, exist_ok=True)
sdk = Path(os.environ.get('ANDROID_HOME', r'D:\Android'))
jdk = Path(os.environ.get('JAVA_HOME', r'C:\Program Files\Eclipse Adoptium\jdk-17.0.17.10-hotspot'))
bt = sdk / 'build-tools/36.0.0'
jar = sdk / 'platforms/android-36/android.jar'
source = root / 'tool/qa/android'
classes = out / 'classes'
classes.mkdir(exist_ok=True)
dex = out / 'dex'
dex.mkdir(exist_ok=True)

def run(*args):
    subprocess.run([str(a) for a in args], check=True)

run(jdk / 'bin/javac.exe', '-source', '8', '-target', '8', '-classpath', jar,
    '-d', classes, *source.glob('*.java'))
run(bt / 'd8.bat', '--lib', jar, '--output', dex, *classes.rglob('*.class'))
for name, manifest in [('fixture', 'AndroidManifest.xml'), ('driver', 'DriverManifest.xml')]:
    unsigned = out / (name+'-unsigned.apk')
    packaged_manifest = out / name / 'AndroidManifest.xml'
    packaged_manifest.parent.mkdir(exist_ok=True)
    packaged_manifest.write_bytes((source / manifest).read_bytes())
    run(bt / 'aapt.exe', 'package', '-f', '-M', packaged_manifest, '-I', jar, '-F', unsigned)
    with zipfile.ZipFile(unsigned, 'a') as archive:
        archive.write(dex / 'classes.dex', 'classes.dex')
    aligned = out / (name+'.apk')
    run(bt / 'zipalign.exe', '-f', '4', unsigned, aligned)
    run(bt / 'apksigner.bat', 'sign', '--ks', Path.home() / '.android/debug.keystore',
        '--ks-pass', 'pass:android', '--key-pass', 'pass:android', aligned)
    print(aligned)
