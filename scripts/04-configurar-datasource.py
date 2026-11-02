"""Chamado pelo CD: gera arquivo privado temporario para az webapp config."""
import json, os, pathlib, subprocess, tempfile
keys = ['SPRING_DATASOURCE_URL','SPRING_DATASOURCE_USERNAME','SPRING_DATASOURCE_PASSWORD']
settings = {key: os.environ[key] for key in keys}
if any(not value or value.startswith('$(') for value in settings.values()):
    raise SystemExit('Configure todas as variaveis secretas de datasource no Azure DevOps.')
fd, path = tempfile.mkstemp(prefix='zelo-settings-', suffix='.json')
try:
    with os.fdopen(fd, 'w') as file:
        json.dump(settings, file)
    subprocess.run(['az','webapp','config','appsettings','set','--resource-group',os.environ['APP_RG'],
                    '--name',os.environ['WEB_APP_NAME'],'--settings','@'+path,'--output','none'],check=True)
finally:
    pathlib.Path(path).unlink(missing_ok=True)
