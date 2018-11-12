#!/usr/bin/env python
#############################################################################
### pgdump_sample.py
### 
### Extract full schema and sample data from large PGDump file,
### such as chembl_14.pgdump.sql.gz.
### For testing, development.
### 
### to do:
###   [ ] handle INSERTs
### 
### Jeremy Yang
### 23 Sep 2012
#############################################################################
import sys,os,re

PROG=os.path.basename(sys.argv[0])

#############################################################################
def PrintToEOStatement():
  n_in,n_out = 0,0
  while True:
    line=sys.stdin.readline()
    if not line: break
    n_in+=1
    sys.stdout.write(line)
    n_out+=1
    if re.match(r'[^;]*;\s*$',line):
      break
  return n_in,n_out

#############################################################################
### End of data delimited by line with "\.".
def SampleData(n_max):
  n_in,n_out = 0,0
  done_sample=False
  while True:
    line=sys.stdin.readline()
    if not line: break
    n_in+=1
    if re.match(r'\\\.\s*$',line):
      sys.stdout.write(line)
      n_out+=1
      break
    elif not done_sample:
      sys.stdout.write(line)
      n_out+=1
    if n_out==n_max:
      done_sample=True
  return n_in,n_out

#############################################################################
if __name__=='__main__':
  n_sample_max=100

  n_in, n_out = 0,0
  n_table, n_data = 0,0

  while True:
    line=sys.stdin.readline()
    if not line: break
    n_in+=1
    if re.match(r'--.*$',line):	### comment
      sys.stdout.write(line)
      n_out+=1
    elif re.match(r'\s*$',line):	### blank
      sys.stdout.write(line)
      n_out+=1
    elif re.match(r'CREATE\s[^;]*;\s*$',line,re.I):
      sys.stdout.write(line)
      if re.match(r'CREATE\s*TABLE',line,re.I): n_table+=1
      n_out+=1
    elif re.match(r'CREATE\s[^;]*$',line,re.I):
      sys.stdout.write(line)
      if re.match(r'CREATE\s*TABLE',line,re.I): n_table+=1
      n_out+=1
      n_in_this,n_out_this = PrintToEOStatement()
      n_in+=n_in_this
      n_out+=n_out_this
    elif re.match(r'COPY\s[^;]*;\s*$',line,re.I):
      sys.stdout.write(line)
      n_out+=1
      n_in_this,n_out_this = SampleData(n_sample_max)
      n_in+=n_in_this
      n_out+=n_out_this
      n_data+=1

  print >>sys.stderr, "%s: n_in: %d"%(PROG,n_in)
  print >>sys.stderr, "%s: n_out: %d"%(PROG,n_out)
  print >>sys.stderr, "%s: n_table: %d"%(PROG,n_table)
  print >>sys.stderr, "%s: n_data: %d"%(PROG,n_data)
