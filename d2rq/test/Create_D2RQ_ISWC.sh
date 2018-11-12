#!/bin/sh
#
set -e
set -x
#
DBNAME='iswc'
DATADIR=.
#
mysql -u jjyang -v <<__EOF__
CREATE DATABASE $DBNAME;
__EOF__
#
cat iswc-mysql.sql \
	| mysql -u jjyang $DBNAME
#
