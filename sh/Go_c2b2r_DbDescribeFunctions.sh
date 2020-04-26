#!/bin/sh
#
DB="chord"
#
#
for schema in "gnova" "ob" "oc" ; do
	printf "%s FUNCTIONS:\n" $schema
	psql -q -d $DB <<__EOF__
SELECT
	'$schema.'||r.routine_name,
	p.data_type,
	p.ordinal_position
FROM
	information_schema.routines r
JOIN information_schema.parameters p ON r.specific_name=p.specific_name
WHERE
	r.specific_schema='$schema'
ORDER BY r.routine_name, p.ordinal_position
	;
__EOF__
done
