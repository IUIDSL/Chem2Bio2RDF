#!/usr/bin/env python
#############################################################################
### chembl_CID2sql.py - convert CIDs plus smiles|inchi to SQL;
### link database with existing chem2bio2rdf compounds.
### 
### INPUT:
###   <SMILES> <CID> "<MOLREGNO>"
### OR:
###   <INCHI> <CID> "<MOLREGNO>"
### (note: CID=0 means not found)
#############################################################################
import sys,os,re,getopt

PROG=os.path.basename(sys.argv[0])

#############################################################################
if __name__=='__main__':

  DBSCHEMA='public'
  DBTABLE='chembl_14_compound_molregno2cid'

  usage='''
  %(PROG)s - compound CIDs and MOLREGNOs SQL

  required:
  --i=<INFILE> ................. input file
  --o=<OUTFILE> ................ output file

  options:
  --inchi ...................... for InChI input; default=SMILES
  --dbschema=<DBSCHEMA> ........ [default="%(DBSCHEMA)s"]
  --dbtable=<DBTABLE> .......... [default="%(DBTABLE)s"]
  --nmax=<NMAX> ................ quit after NMAX cpds
  --nskip=<NSKIP> .............. skip first NSKIP cpds
  --v .......................... verbose
  --h .......................... this help
'''%{'PROG':PROG,'DBSCHEMA':DBSCHEMA,'DBTABLE':DBTABLE}

  def ErrorExit(msg):
    print >>sys.stderr,msg
    sys.exit(1)

  ifile=None; ofile=None; update=False;
  inchi_input=False;
  nmax=0; nskip=0;
  verbose=0;
  opts,pargs = getopt.getopt(sys.argv[1:],'',['h','v','vv',
        'i=','o=','nmax=','nskip=','dbschema=','dbtable=','update','inchi'])
  if not opts: ErrorExit(usage)
  for (opt,val) in opts:
    if opt=='--h': ErrorExit(usage)
    elif opt=='--i': ifile=val
    elif opt=='--o': ofile=val
    elif opt=='--dbschema': DBSCHEMA=val
    elif opt=='--dbtable': DBTABLE=val
    elif opt=='--update': update=True
    elif opt=='--inchi': inchi_input=True
    elif opt=='--nmax': nmax=int(val)
    elif opt=='--nskip': nskip=int(val)
    elif opt=='--vv': verbose=2
    elif opt=='--v': verbose=1
    else: ErrorExit('Illegal option: %s'%val)

  fin=file(ifile)
  if not fin:
    ErrorExit('ERROR: cannot open %s'%ifile)

  fout=sys.stdout
  if ofile:
    fout=open(ofile,"w")
    if not fout:
      ErrorExit('ERROR: cannot open %s'%ofile)

  n_in=0;
  n_out=0;
  n_err=0;
  n_nocid=0;
  while True:
    line=fin.readline()
    if not line: break
    n_in+=1
    if nskip>0 and n_in<=nskip:
      continue
    line=line.strip()
    if not line or line[0]=='#':
      continue
    fields=re.split('\s',line)
    if len(fields)<3:
      print >>sys.stderr, "Bad line: %s"%line
      n_err+=1
      continue

    #smi=fields[0]
    #smi=re.sub(r'\\',r"'||E'\\\\'||'",smi)
    inch=None
    smi,cid,molregno = fields[:3]
    if inchi_input:
      inch=smi
      smi=None
    molregno=molregno.replace('"','')
    try:
      cid=int(cid)
      molregno=int(molregno)
    except:
      print >>sys.stderr, "Bad line: %s"%line
      n_err+=1
      continue

    if cid==0:
      print >>sys.stderr, "No CID: %s"%line
      n_nocid+=1
      continue

    fout.write("INSERT INTO %s.%s (molregno,cid) VALUES (%d, %d);\n"%(DBSCHEMA,DBTABLE,molregno,cid))

    n_out+=1
    if nmax>0 and (n_in-nskip)>=nmax:
      break

  fin.close()
  fout.close()
  print >>sys.stderr, "%s: lines in: %d ; converted to sql: %d"%(PROG,n_in,n_out)
  print >>sys.stderr, "%s: errors: %d"%(PROG,n_err)
  print >>sys.stderr, "%s: missing CIDs: %d"%(PROG,n_nocid)
