#!/bin/sh
#
#
set -x
#
#
opts="--v --inchi --firstonly"
#opts="$opts --skip 329200"
#opts="$opts --skip 914900"
opts="$opts --skip 986100"
#
ifile=data/chembl_14_dump_cpds.inchi
#ofile=data/chembl_14_dump_cpds_from-inchi_wCIDs.inchi
#ofile=data/chembl_14_dump_cpds_from-inchi_wCIDs_2.inchi
#ofile=data/chembl_14_dump_cpds_from-inchi_wCIDs_3.inchi
ofile=data/chembl_14_dump_cpds_from-inchi_wCIDs_4.inchi
#
pug_rest_mols2ids.py \
	--i $ifile \
	--o $ofile \
	$opts
#
