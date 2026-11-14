import sys
# mkr.py base out 'extra rule text'  : append a rule before final ")" of :rules list
src=open(sys.argv[1]).read().rstrip()
assert src.endswith('))')
src=src[:-2]+' '+sys.argv[3]+'))'
import re
src=re.sub(r':id :[^ ]+',':id :c-ki-i-r2-b0a0',src,1)
open(sys.argv[2],'w').write(src+'\n')
