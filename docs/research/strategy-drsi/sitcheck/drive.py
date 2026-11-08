import concurrent.futures as cf, os, subprocess, sys
ROOT=os.path.abspath(os.path.dirname(os.path.abspath(__file__))+'/../../../..'); ECL=os.environ.get('ECL_HOST','/media/8tsp/projects/ecl-24.5.10/ecl-emscripten-host/bin/ecl')
SEEDS=ROOT+'/docs/research/strategy-drsi/seeds/'; OUT=os.path.dirname(os.path.abspath(__file__))+'/raw'; os.makedirs(OUT,exist_ok=True)
R={'ken':1,'ichigo':3,'hisagi':7}
SF={'s0':'s0-generic','s1':'s1-brawler','s3':'s3-zoner','kiken':'s5-ki-ken','kiichigo':'s6-ki-ichigo'}
DIF={'normal':1,'hard':2}
def job(a):
    me,op,s,seat,dif=a
    c1,c2=(R[me],R[op]) if seat==1 else (R[op],R[me])
    path=f'{OUT}/{me}_vs_{op}_{dif}_{s}_P{seat}.out'
    if os.path.exists(path): return
    env=dict(os.environ,LD_PRELOAD=ROOT+'/build/simgate/muslm.so',STRAT_WIN='1',**{f'STRAT_P{seat}':SEEDS+SF[s]+'.lisp'})
    cmds=[30200,31140,81000,81020+DIF[dif],81030,81040,200000+100*c1+10*c2]
    r=subprocess.run([ECL,'--norc','--load','tools/simgate/strat-run.lisp','--',ROOT+'/build/simgate/duel.fas']+list(map(str,cmds)),cwd=ROOT,capture_output=True,text=True,env=env)
    if r.returncode: print('FAIL',path,r.returncode,r.stderr[-300:],flush=True); return
    open(path,'w').write('\n'.join(l for l in r.stdout.splitlines() if l.startswith(('win ','duel gate row','strat '))))
jobs=[]
for dif in ('hard',):
    for me,op in (('ichigo','hisagi'),('hisagi','ichigo')):
        for s in ('s0','s1','s3'):
            for seat in (1,2): jobs.append((me,op,s,seat,dif))
for dif in ('normal','hard'):
    for s in ('s0','s1','s3','kiken'):
        for seat in (1,2): jobs.append(('ken','ichigo',s,seat,dif))
    for s in ('s0','s1','s3','kiichigo'):
        for seat in (1,2): jobs.append(('ichigo','ken',s,seat,dif))
for me,op in (('ken','hisagi'),('hisagi','ken')):
    for s in ('s0','s1','s3'):
        for seat in (1,2): jobs.append((me,op,s,seat,'normal'))
print(len(jobs),'jobs',flush=True)
with cf.ThreadPoolExecutor(10) as ex: list(ex.map(job,jobs))
print('done',flush=True)
