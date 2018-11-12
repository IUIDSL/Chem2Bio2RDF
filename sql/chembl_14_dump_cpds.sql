\pset format unaligned
\pset footer off
\pset fieldsep ' '
\o data/chembl_14_dump_cpds.smi
--\pset fieldsep ','
--\o data/chembl_14_dump_cpds.csv
--
SELECT
	canonical_smiles,
	molregno
FROM
	chembl_14_compound_structures
ORDER BY molregno
	;
--
