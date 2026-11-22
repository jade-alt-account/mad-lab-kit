# run_student.py: run every 'run:' step of the student build.yml, verbatim,
# inside a fresh copy of a student repository (secrets are empty, as in a
# new student repository)
import os, shutil, subprocess, sys, yaml

repo, out = sys.argv[1], sys.argv[2]
os.makedirs(out, exist_ok=True)
work = os.path.join(os.environ.get('RUNNER_TEMP', '/tmp'), 'student-repo')
shutil.rmtree(work, ignore_errors=True)
shutil.copytree(repo, work)
shutil.copy('student/build.yml', os.path.join(out, 'build.yml'))
subprocess.run('git init -q && git add -A && git -c user.name=s '
               '-c user.email=s@s commit -qm start', shell=True, cwd=work,
               check=True)
steps = yaml.safe_load(open('student/build.yml'))['jobs']['build']['steps']
summary = open(os.path.join(out, 'summary.txt'), 'w')
for n, step in enumerate(steps, 1):
    if 'run' not in step:
        continue
    env = dict(os.environ)
    for k, v in (step.get('env') or {}).items():
        env[k] = '' if '${{' in str(v) else str(v)
    script = os.path.join(work, '.step.sh')
    open(script, 'w').write(step['run'])
    log = os.path.join(out, f'step{n:02d}.log')
    with open(log, 'w') as f:
        r = subprocess.run(['bash', '--noprofile', '--norc', '-eo',
                            'pipefail', script], cwd=work, env=env,
                           stdout=f, stderr=subprocess.STDOUT)
    os.remove(script)
    line = f"step {n:02d} {step.get('name')}: exit {r.returncode}"
    print(line); summary.write(line + '\n'); summary.flush()
    if r.returncode != 0:
        sys.exit(1)
for path in ['build/app/outputs/flutter-apk/app-debug.apk',
             'release/app-release.aab', 'release/app-release.apk']:
    p = os.path.join(work, path)
    msg = f'{path}: {os.path.getsize(p)} bytes' if os.path.exists(p) \
        else f'{path}: MISSING'
    print(msg); summary.write(msg + '\n')
apk = os.path.join(work, 'build/app/outputs/flutter-apk/app-debug.apk')
if os.path.exists(apk):
    shutil.copy(apk, os.path.join(out, 'app-debug.apk'))
