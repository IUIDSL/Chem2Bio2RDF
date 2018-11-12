#!/bin/sh
#
set -x
#
gunzip -c $HOME/Download/drugbank-pgdump.sql.gz \
	| psql -U jjyang chord
#
