SELECT 
	chembl_15_source.src_id,
	chembl_15_source.src_description,
	chembl_15_source.src_short_name,
	q1.cpd_count
FROM 
	chembl_15_source,
	( SELECT 
		chembl_15_source.src_id,
		count(chembl_15_compound_records.record_id) AS cpd_count
	FROM 
		chembl_15_source,
		chembl_15_compound_records 
	WHERE
		chembl_15_source.src_id=chembl_15_compound_records.src_id 
		
	GROUP BY 
		chembl_15_source.src_id
	) AS q1
WHERE
	chembl_15_source.src_id=q1.src_id
ORDER BY 
	q1.src_id
;
