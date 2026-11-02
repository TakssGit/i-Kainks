"""Package the existing HTML prototype, without native code or browser data."""
from pathlib import Path
import shutil
import subprocess
import sys

root = Path(__file__).resolve().parents[1]
out = Path(sys.argv[1]).resolve()
if out.exists():
    raise SystemExit('Use a new output directory; existing files are preserved.')
out.mkdir(parents=True)
source = root / 'web'
for path in source.rglob('*'):
    if not path.is_file() or path.name == 'index.html':
        continue
    if path.suffix not in {'.html', '.js', '.css', '.json', '.txt', '.svg', '.png'}:
        continue
    target = out / path.relative_to(source)
    target.parent.mkdir(parents=True, exist_ok=True)
    if path.suffix in {'.html', '.js', '.css', '.json', '.txt', '.svg'}:
        text = path.read_text()
        # Isolate demo storage from earlier prototype deployments.
        text = text.replace('ikainks_dev_015', 'ikainks_public_preview_v2')
        target.write_text(text)
    else:
        shutil.copyfile(path, target)
revision = subprocess.check_output(['git', 'rev-parse', 'HEAD'], cwd=root, text=True).strip()
(out / '.nojekyll').touch()
(out / 'source-version.txt').write_text(revision + '\n')
(out / 'index.html').write_text('''<!doctype html><html lang="fr"><meta charset="utf-8">
<meta name="viewport" content="width=device-width,initial-scale=1"><title>i-Kaink’s — état actuel</title>
<style>body{font:18px system-ui;background:#eef3f8;color:#163451;margin:0;padding:clamp(20px,6vw,80px)}main{max-width:800px;margin:auto;background:white;padding:32px;border-radius:16px}a{display:inline-block;padding:16px;margin:8px;background:#185ca3;color:white;border-radius:8px}code{overflow-wrap:anywhere}</style>
<main><h1>i-Kaink’s — aperçu de l’état actuel</h1><p>Prototype interactif PC et mobile, avant les prochaines évolutions fonctionnelles.</p>
<p>Démonstration uniquement : utilisez des données fictives. Les saisies restent dans ce navigateur, sans synchronisation multi-utilisateur. Ce prototype ne constitue pas un build Flutter ni une version commerciale validée.</p>
<a href="preview_pc.html">Tester sur PC</a><a href="preview_mobile.html">Tester sur mobile</a>
<p>Dans les paramètres, vous pouvez créer les données de démonstration.</p>
<p>Version source : <code>''' + revision + '</code></p></main></html>')
print(f'Preview packaged: {out}, source {revision}')
