#!/bin/sh
#
DB="chord"
#
# psql -P pager=off -q -d $DB -c "SELECT DISTINCT table_schema,table_name FROM information_schema.columns ORDER BY table_schema,table_name"
#
for schema in "gnova" "ob" "oc" "public" ; do
	tables=`psql -q -d $DB -tAc "SELECT table_name FROM information_schema.tables WHERE table_schema = '$schema' ORDER BY table_name"`
	#
	for table in $tables ; do
		printf "%s.%s:\n" $schema $table
		psql -P pager=off -q -d $DB -c "SELECT column_name,data_type FROM information_schema.columns WHERE table_schema = '$schema' AND table_name = '$table' ORDER BY column_name"
	done
done
#
for schema in "gnova" "ob" "oc" "public" ; do
	printf "%s FUNCTIONS:\n" $schema
	psql -q -d $DB -tAc "SELECT '  $schema.'||routine_name FROM information_schema.routines WHERE routine_schema = '$schema' ORDER BY routine_name"
done
