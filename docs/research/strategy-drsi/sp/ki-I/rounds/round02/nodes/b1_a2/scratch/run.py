import sys,subprocess,json,re
D=sys.argv[1]; base=open(D+'/p.lisp').read()
def var(name,subs,add=''):
    s=base
    for a,b in subs: 
        assert a in s,a; s=s.replace(a,b)
    if add: s=s.replace(':base (',':base ('+add+' ',1)
    f=f'{D}/v_{name}.lisp'; open(f,'w').write(s.replace(':c-ki-i-r2-b1a2',':c-ki-i-r2-b1a2'))
    o=subprocess.run(['python3','docs/research/strategy-drsi/sp/eval.py','--me','ichigo','--vs','kenpachi','--cand',f,'--seed0','300','-j','3'],capture_output=True,text=True,env={**__import__('os').environ,'SP_BUILD':'f5048d03'}).stdout.strip().splitlines()[-1]
    j=json.loads(o); g=j['groups']
    print(name,j['score'],[ (k,v['ko_wins'],v['ko_losses'],v['timeouts']) for k,v in g.items()],flush=True)
exec(open(sys.argv[2]).read())
