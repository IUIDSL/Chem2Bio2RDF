#!/usr/bin/env python
#############################################################################
### Fixes the mysqldump Chembl so it can be loaded into Pgsql in the "public"
### schema.  mysqldump --compatibility=postgresql should also have been used.
### Jeremy Yang
### 26 Jun 2012
#############################################################################
import sys,os,re

PROG=os.path.basename(sys.argv[0])

rob1=re.compile(r'^([A-Z]+\s+TABLES?\s+[^"]*")([^"]+)(".*)$')
rob2=re.compile(r'^(INSERT INTO\s+[^"]*")([^"]+)(".*)$')

n_lines=0
n_fixed=0

while True:
  line=sys.stdin.readline()
  if not line: break
  n_lines+=1
  m1=rob1.match(line)
  m2=rob2.match(line)
  if m1:
    line_fixed=("%spublic.chembl_13_%s%s"%(m1.group(1),m1.group(2),m1.group(3)))
    n_fixed+=1
    print line_fixed
  elif m2:
    line_fixed=("%spublic.chembl_13_%s%s"%(m2.group(1),m2.group(2),m2.group(3)))
    n_fixed+=1
    print line_fixed
  else:
    print line

print >>sys.stderr, '%s: lines: %d'%(PROG,n_lines)
print >>sys.stderr, '%s: lines fixed: %d'%(PROG,n_fixed)
