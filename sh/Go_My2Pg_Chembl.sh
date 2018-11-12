#!/bin/sh
#
set -e
set -x
#
# From SM's version on habanero:
#
#mysqldump -u jjyang -p******* \
#	--compatible=postgresql \
#	--single-transaction \
#	chembl_13 \
#	| gzip -c \
#	> data/chembl_13-mysqldump-pgcompatible.sql.gz
#
# Fix table names with custom script.
# E.g.: "activities" -> "public.chembl_13_activities"
#
gunzip -c data/chembl_13-mysqldump-pgcompatible.sql.gz \
	| ./c2b2r_fix_chembl_mysqldump.py \
	| gzip -c \
	> data/chembl_13-mysqldump-pgcompatible-fixed.sql.gz 
#
