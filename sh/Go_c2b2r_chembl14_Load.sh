#!/bin/sh
#############################################################################
### Go_c2b2r_chembl14_Load.sh
### 
### Jeremy Yang
### 30 Sep 2012
#############################################################################
set -x
#
#
gunzip -c chembl_14/data/chembl_14.pgdump.sql.gz \
	| perl -pe 's/CREATE\s+TABLE\s+([^\s]+)\s/CREATE TABLE chembl_14_$1 /' \
	| perl -pe 's/COPY\s+([^\s]+)\s/COPY chembl_14_$1 /'  \
	| perl -pe 's/ALTER\s+TABLE\s+ONLY\s+([^\s]+)\s/ALTER TABLE ONLY chembl_14_$1 /' \
	| perl -pe 's/CREATE\s+INDEX\s+([^\s]+)\s+ON\s+([^\s]+)\s/CREATE INDEX chembl_14_$1 ON chembl_14_$2 /' \
	| perl -pe 's/CREATE\s+UNIQUE\s+INDEX\s+([^\s]+)\s+ON\s+([^\s]+)\s/CREATE UNIQUE INDEX chembl_14_$1 ON chembl_14_$2 /' \
	| perl -pe 's/ADD\s+CONSTRAINT\s+([^\s]+)\s+(.*)REFERENCES\s+([^\s\(]+)(\(.*)$/ADD CONSTRAINT $1 $2 REFERENCES chembl_14_$3 $4/' \
	| gzip -c \
	> data/chembl_14_pgdump_fixed.sql.gz
#
#
gunzip -c data/chembl_14_pgdump_fixed.sql.gz \
	| psql -S -U cicc3 chord 
#
# Write DROP SQL
gunzip -c data/chembl_14_pgdump_fixed.sql.gz \
	| perl -ne 'print if /^\s*CREATE\s+TABLE\s+([^\s]+)\s/' \
	| perl -pe 's/^\s*CREATE\s+TABLE\s+([^\s]+)\s.*$/DROP TABLE $1 CASCADE ;/' \
	>data/drop_chembl_14.sql
#
# Write DESCRIBE SQL
gunzip -c data/chembl_14_pgdump_fixed.sql.gz \
	| perl -ne 'print if /^\s*CREATE\s+TABLE\s+([^\s]+)\s/' \
	| perl -pe 's/^\s*CREATE\s+TABLE\s+([^\s]+)\s.*$/\\d $1\nSELECT COUNT(*) AS "COUNT($1)" FROM $1 ;/' \
	>data/describe_chembl_14.sql
#
