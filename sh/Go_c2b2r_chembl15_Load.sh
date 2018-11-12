#!/bin/sh
#############################################################################
### Go_c2b2r_chembl15_Load.sh
### 
### Jeremy Yang
### 16 Apr 2013
#############################################################################
set -x
#
VER="15"
#
gunzip -c chembl_${VER}/data/chembl_${VER}.pgdump.sql.gz \
	| perl -pe "s/CREATE\s+TABLE\s+([^\s]+)\s/CREATE TABLE chembl_${VER}_\$1 /" \
	| perl -pe "s/COPY\s+([^\s]+)\s/COPY chembl_${VER}_\$1 /"  \
	| perl -pe "s/ALTER\s+TABLE\s+ONLY\s+([^\s]+)\s/ALTER TABLE ONLY chembl_${VER}_\$1 /" \
	| perl -pe "s/CREATE\s+INDEX\s+([^\s]+)\s+ON\s+([^\s]+)\s/CREATE INDEX chembl_${VER}_\$1 ON chembl_${VER}_\$2 /" \
	| perl -pe "s/CREATE\s+UNIQUE\s+INDEX\s+([^\s]+)\s+ON\s+([^\s]+)\s/CREATE UNIQUE INDEX chembl_${VER}_\$1 ON chembl_${VER}_\$2 /" \
	| perl -pe "s/ADD\s+CONSTRAINT\s+([^\s]+)\s+(.*)REFERENCES\s+([^\s\(]+)(\(.*)\$/ADD CONSTRAINT \$1 \$2 REFERENCES chembl_${VER}_\$3 \$4/" \
	| gzip -c \
	> data/chembl_${VER}_pgdump_fixed.sql.gz
#
#
# Write DROP SQL
gunzip -c data/chembl_${VER}_pgdump_fixed.sql.gz \
	| perl -ne 'print if /^\s*CREATE\s+TABLE\s+([^\s]+)\s/' \
	| perl -pe 's/^\s*CREATE\s+TABLE\s+([^\s]+)\s.*$/DROP TABLE $1 CASCADE ;/' \
	>data/drop_chembl_${VER}.sql
#
# Write DESCRIBE SQL
gunzip -c data/chembl_${VER}_pgdump_fixed.sql.gz \
	| perl -ne 'print if /^\s*CREATE\s+TABLE\s+([^\s]+)\s/' \
	| perl -pe 's/^\s*CREATE\s+TABLE\s+([^\s]+)\s.*$/\\d $1\nSELECT COUNT(*) AS "COUNT($1)" FROM $1 ;/' \
	>data/describe_chembl_${VER}.sql
#
# Load database
#gunzip -c data/chembl_${VER}_pgdump_fixed.sql.gz \
#	| psql -S -U cicc3 chord 
#
