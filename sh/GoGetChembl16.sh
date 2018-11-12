#!/bin/sh
#
#
set -x
set -e
#
ver="16"
#
ftp_server="ftp://ftp.ebi.ac.uk"
ftp_subdir="pub/databases/chembl/ChEMBLdb/releases/chembl_${ver}"
#
datadir="chembl_${ver}/data"
#
FTPGET=ftpget.py
#
cd ${datadir}
#
for f in \
	README \
	chembl_${ver}_postgresql.tar.gz \
	chembl_${ver}_release_notes.txt \
	chembl_${ver}_erd.png \
	; do
	$FTPGET "${ftp_server}/${ftp_subdir}/${f}"
done
