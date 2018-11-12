#!/bin/sh
#
set -x
#
gunzip -c chembl_14/data/chembl_14.pgdump.sql.gz \
	| pgdump_sample.py \
	> data/chembl_14_pgdump_sample.sql
#
cat data/chembl_14_pgdump_sample.sql \
	| perl -pe 's/CREATE\s+TABLE\s+([^\s]+)\s/CREATE TABLE chembl_14_$1 /' \
	| perl -pe 's/COPY\s+([^\s]+)\s/COPY chembl_14_$1 /'  \
	| perl -pe 's/CREATE\s+INDEX\s+([^\s]+)\s+ON\s+([^\s]+)\s/CREATE INDEX chembl_14_$1 ON chembl_14_$2 /' \
	| perl -pe 's/CREATE\s+UNIQUE\s+INDEX\s+([^\s]+)\s+ON\s+([^\s]+)\s/CREATE UNIQUE INDEX chembl_14_$1 ON chembl_14_$2 /' \
	> data/chembl_14_pgdump_sample_fixed.sql
#
#
cat data/chembl_14_pgdump_sample_fixed.sql \
	| psql -S -U cicc3 chord 
#
#
# Write drop.sql
cat data/chembl_14_pgdump_sample_fixed.sql \
        | perl -ne 'print if /^\s*CREATE\s+TABLE\s+([^\s]+)\s/' \
        | perl -pe 's/^\s*CREATE\s+TABLE\s+([^\s]+)\s.*$/DROP TABLE $1 ;/' \
	>data/drop_chembl_14.sql
#
