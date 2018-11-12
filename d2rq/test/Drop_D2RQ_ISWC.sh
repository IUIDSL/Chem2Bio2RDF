#!/bin/sh
#
set -e
set -x
#
DBNAME='iswc'
DATADIR=.
#
mysql -u jjyang -v <<__EOF__
DROP DATABASE $DBNAME;
__EOF__
#
