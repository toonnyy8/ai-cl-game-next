import sys,re
# usage: mk.py base.lisp out.lisp key val [key val ...]  (replaces existing key in :base or appends)
src=open(sys.argv[1]).read()
for k,v in zip(sys.argv[3::2],sys.argv[4::2]):
    m=re.search(r'(?<=[ (])'+re.escape(k)+r' [-0-9.]+',src)
    if m: src=src[:m.start()]+k+' '+v+src[m.end():]
    else: src=src.replace(':base (',':base ('+k+' '+v+' ',1)
src=re.sub(r':id :[^ ]+',':id :c-ki-i-r2-b0a0',src,1)
open(sys.argv[2],'w').write(src)
