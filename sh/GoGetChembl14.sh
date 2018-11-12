#!/bin/sh
#
#
set -x
set -e
#
ftp_server="ftp://ftp.ebi.ac.uk"
ftp_subdir="pub/databases/chembl/ChEMBLdb/releases/chembl_14"
#
datadir="data"
#
FTPGET=ftpget.py
#
cd ${datadir}
#
for f in \
	README \
	chembl_14_postgresql.tar.gz \
	chembl_14_release_notes.txt \
	chembl_14_erd.png \
	; do
	$FTPGET "${ftp_server}/${ftp_subdir}/${f}"
done
