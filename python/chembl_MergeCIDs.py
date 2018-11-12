#!/usr/bin/python
### #!/usr/bin/env python	## python2.4 has pgdb ; python 2.6 does not, alas.
#############################################################################
### chembl_MergeCIDs.py - 
### 
### The purpose of this program is to update the global public.c2b2r_compound
### with new CIDs (new compounds, or existing structures with new CIDs),
###  from the newly created and populated "chembl_14_compound_molregno2cid"
### (columns molregno and cid), and chembl_14_compound_structures (which
### contains standard_inchi and canonical_smiles columns).
### 
### Jeremy Yang
###  6 Nov 2012
#############################################################################
import sys,os,re,getopt,time
import pgdb

import c2b2r_utils

PROG=os.path.basename(sys.argv[0])

DBSCHEMA='public'
DBTABLE='chembl_14_compound_molregno2cid'
DBHOST='localhost'
DBNAME='openchord'
DBUSR='cicc3'
DBPW=None

#############################################################################
def ChemblGetStruct(dbcon,molregno):
  if not dbcon:
    db,cur = c2b2r_utils.Connect(dbhost=DBHOST,dbname=DBNAME,dbusr=DBUSR,dbpw=DBPW)
  else:
    cur=dbcon.cursor()

  sql=('SELECT standard_inchi,canonical_smiles FROM chembl_14_compound_structures WHERE molregno='+molregno)
  cur.execute(sql)

  rows=cur.fetchall()
  smi,inchi = None,None
  if rows:
    try:
      smi=rows[0][0] 
      inchi=rows[0][1] 
    except:
      pass
  cur.close()
  if not dbcon:
    db.close()
  
  return smi,inchi 

#############################################################################
if __name__=='__main__':

  usage='''
  %(PROG)s - update public.c2b2r_compound with new compounds

  options:
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
  nmax=0; nskip=0;
  verbose=0;
  opts,pargs = getopt.getopt(sys.argv[1:],'',['h','v','vv',
        'i=','o=','nmax=','nskip=','dbschema=','dbtable=','update'])
  if not opts: ErrorExit(usage)
  for (opt,val) in opts:
    if opt=='--h': ErrorExit(usage)
    elif opt=='--dbschema': DBSCHEMA=val
    elif opt=='--dbtable': DBTABLE=val
    elif opt=='--update': update=True
    elif opt=='--nmax': nmax=int(val)
    elif opt=='--nskip': nskip=int(val)
    elif opt=='--vv': verbose=2
    elif opt=='--v': verbose=1
    else: ErrorExit('Illegal option: %s'%val)

  db,cur = c2b2r_utils.Connect(dbhost=DBHOST,dbname=DBNAME,dbusr=DBUSR,dbpw=DBPW)

  sql=('SELECT molregno,cid FROM chembl_14_compound_molregno2cid')

  n_new=0; n_add=0; n_err=0;
  cur.execute(sql)
  while True:
    row=cur.fetchone()
    if not row: break

    try:
      molregno=int(row[0])
      cid=int(row[1])
    except:
      continue

    if not c2b2r_utils.ContainsCID(db,cid):
      n_new+=1
      smi,inchi = ChemblGetStruct(db,molregno)
      ok=c2b2r_utils.AddNewCID(DBSCHEMA,cid,smi,inchi,db)
      if ok: n_add+=1

  cur.close()
