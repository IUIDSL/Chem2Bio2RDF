#!/bin/sh
#
#
set -x
set -e
#
ftp_server="ftp://ftp.ebi.ac.uk"
ftp_subdir="pub/databases/chembl/ChEMBLdb/releases/chembl_15"
#
datadir="data"
#
FTPGET=ftpget.py
#
cd ${datadir}
#
for f in \
	README \
	chembl_15_postgresql.tar.gz \
	chembl_15_release_notes.txt \
	chembl_15_erd.png \
	; do
	$FTPGET "${ftp_server}/${ftp_subdir}/${f}"
done
