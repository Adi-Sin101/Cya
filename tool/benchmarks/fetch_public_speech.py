"""Host-only public Google FLEURS fixture preparation, CC-BY-4.0.

Source/card: https://huggingface.co/datasets/google/fleurs
Never reads or uploads personal content. No app dependency or downloader.
Run from repository root; outputs are ignored under .buildlog/speech-corpus.
"""
import urllib.request, tarfile, pathlib, json, hashlib, io, wave, struct, math

root = pathlib.Path('.buildlog/speech-corpus')
root.mkdir(exist_ok=True)
revision = '70bb2e84b976b7e960aa89f1c648e09c59f894dd'
base = f'https://huggingface.co/datasets/google/fleurs/resolve/{revision}/data/'
records = []
for language in ['en_us', 'bn_in']:
    metadata = urllib.request.urlopen(base+language+'/dev.tsv',timeout=45).read()
    (root/(language+'-dev.tsv')).write_bytes(metadata)
    lines = [line.split('\t') for line in metadata.decode('utf-8').splitlines()]
    by_name = {line[1]:line for line in lines if len(line)>3}
    count = 0
    with urllib.request.urlopen(base+language+'/audio/dev.tar.gz',timeout=90) as response:
        with tarfile.open(fileobj=response, mode='r|gz') as archive:
            for member in archive:
                name = pathlib.PurePosixPath(member.name).name
                if not member.isfile() or name not in by_name or member.size>5_000_000:
                    continue
                original = archive.extractfile(member).read()
                pos=12; fmt=None; data=None
                while pos+8<=len(original):
                    tag=original[pos:pos+4];size=struct.unpack_from('<I',original,pos+4)[0]
                    chunk=original[pos+8:pos+8+size]
                    if tag==b'fmt ': fmt=struct.unpack_from('<HHIIHH',chunk)
                    if tag==b'data': data=chunk
                    pos+=8+size+(size%2)
                if fmt is None or data is None or fmt[1]!=1 or fmt[2]!=16000:
                    raise RuntimeError('Unexpected source WAV format')
                if fmt[0]==3 and fmt[5]==32:
                    floats=struct.unpack('<%df'%(len(data)//4),data)
                    if not all(math.isfinite(n) for n in floats): raise RuntimeError('Nonfinite PCM')
                    pcm=struct.pack('<%dh'%min(len(floats),320000),
                        *(max(-32768,min(32767,round(n*32767))) for n in floats[:320000]))
                elif fmt[0]==1 and fmt[5]==16: pcm=data[:640000]
                else: raise RuntimeError('Unsupported source PCM')
                target=root/(language+'-'+name)
                with wave.open(str(target),'wb') as out:
                    out.setnchannels(1);out.setsampwidth(2);out.setframerate(16000);out.writeframes(pcm)
                line=by_name[name]
                records.append(dict(language=language,file=target.name,source=member.name,
                    sentence_id=line[0],raw_transcription=line[2],transcription=line[3],
                    original_sha256=hashlib.sha256(original).hexdigest(),conversion='float32-or-PCM16 to PCM16, first20s',
                    seconds=len(pcm)/32000,sha256=hashlib.sha256(target.read_bytes()).hexdigest()))
                count+=1
                if count==10: break
    print(language, count, 'public clips saved',flush=True)
    (root/'samples.json').write_text(json.dumps(records,ensure_ascii=False,indent=2),encoding='utf-8')
