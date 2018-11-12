\pset format unaligned
\pset footer off
\pset fieldsep ' '
\o data/chembl_14_dump_cpds.inchi
--
SELECT
	standard_inchi,
	molregno
FROM
	chembl_14_compound_structures
ORDER BY molregno
	;
--
