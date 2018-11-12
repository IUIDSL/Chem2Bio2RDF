#!/bin/sh
#
#
set -x
set -e
#
ftp_server="ftp://ftp.ebi.ac.uk"
ftp_subdir="pub/databases/chembl/ChEMBLdb/releases/chembl_13"
#
datadir="data"
#
FTPGET=ftpget.py
#
cd ${datadir}
#
for f in \
	README \
	chembl_13_mysql.tar.gz \
	chembl_13_release_notes.txt \
	chembl_13_erd.png \
	; do
	$FTPGET "${ftp_server}/${ftp_subdir}/${f}"
done
