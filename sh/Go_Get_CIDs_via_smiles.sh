#!/bin/sh
#
nskip=549700
#
pug_rest_mols2ids.py \
	--v \
	--firstonly \
	--skip $nskip \
	--i data/chembl_14_dump_cpds.smi \
	--o data/chembl_14_dump_cpds_wCIDs.smi-${nskip}- \
#
