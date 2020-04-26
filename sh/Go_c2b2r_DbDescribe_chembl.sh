$#!/bin/sh

PGUSR=cicc3
PGDB=chord
PGSCHEMA=public
#
psql -U $PGUSR -d $PGDB <<__EOF__
\d+ $PGSCHEMA.chembl_02_activities
\d+ $PGSCHEMA.chembl_02_assay2target
\d+ $PGSCHEMA.chembl_02_assay_type
\d+ $PGSCHEMA.chembl_02_assays
\d+ $PGSCHEMA.chembl_02_compound_properties
\d+ $PGSCHEMA.chembl_02_compound_records
\d+ $PGSCHEMA.chembl_02_compound_synonyms
\d+ $PGSCHEMA.chembl_02_compounds
\d+ $PGSCHEMA.chembl_02_confidence_score_lookup
\d+ $PGSCHEMA.chembl_02_docs
\d+ $PGSCHEMA.chembl_02_relationship_type
\d+ $PGSCHEMA.chembl_02_source
\d+ $PGSCHEMA.chembl_02_target_class
\d+ $PGSCHEMA.chembl_02_target_dictionary
\d+ $PGSCHEMA.chembl_02_target_type
__EOF__
