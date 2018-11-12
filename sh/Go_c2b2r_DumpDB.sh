#!/bin/sh
#
set -x
#
TABLES="\
c2b2r_chembl_08_target_class \
c2b2r_chebi_relations \
c2b2r_compound_new \
c2b2r_chembl_08_target_dictionary \
c2b2r_goa_human \
c2b2r_chembl_08_target_type \
c2b2r_PDBLigand2CID \
c2b2r_chembl_08_assay_type \
c2b2r_drugbankdrug_substructure \
c2b2r_chembl_08_assays \
c2b2r_PDB \
c2b2r_chembl_08_chembl_id_lookup \
c2b2r_drugbankdrug_042011 \
c2b2r_drugbanktarget_042011 \
c2b2r_drugbankdrugtarget_042011 \
c2b2r_chembl_08_activities \
c2b2r_side_effect \
c2b2r_ChEBI2PubChem \
c2b2r_TTD_disease_mapped \
c2b2r_ctd_chem_disease_publish \
c2b2r_omim_disease \
c2b2r_OMIM_disease \
c2b2r_PDB_chemicals \
c2b2r_PDBbind \
c2b2r_drug_disease \
c2b2r_DrugBankDrugDrug \
c2b2r_omim \
c2b2r_chembl_02_activities \
c2b2r_chembl_02_assay2target \
c2b2r_chembl_02_assay_type \
c2b2r_chembl_02_assays \
c2b2r_chembl_02_chemogenomics \
c2b2r_chembl_02_compound_properties \
c2b2r_chembl_02_compound_records \
c2b2r_chembl_02_compound_synonyms \
c2b2r_chembl_02_compounds \
c2b2r_chembl_02_confidence_score_lookup \
c2b2r_chembl_02_docs \
c2b2r_chembl_02_relationship_type \
c2b2r_chembl_02_source \
c2b2r_chembl_02_target_class \
c2b2r_chembl_02_target_type \
c2b2r_compound_synonym \
c2b2r_disease \
c2b2r_gene \
c2b2r_uniprot2PDB \
c2b2r_BindingDBLigand \
c2b2r_CTD_chem_disease_old \
c2b2r_DIP_PPI \
c2b2r_GENE2UNIPROT \
c2b2r_Gi2UNIPROT \
c2b2r_HPRD_PPI \
c2b2r_KEGG_pathway_info \
c2b2r_KEGG_pathway \
c2b2r_OMIM \
c2b2r_GI \
c2b2r_PubMed2compound \
c2b2r_Reactome_pathway \
c2b2r_TTD_drug \
c2b2r_BindingDBProtein \
c2b2r_BindingMOAD \
c2b2r_chembl_02_target_dictionary \
c2b2r_reactome_pathways \
c2b2r_CTD_chem_gene \
c2b2r_DCDB_DC_TO_COMPONENTS \
c2b2r_DCDB_DC_USAGE \
c2b2r_DCDB_drug_interaction \
c2b2r_DCDB_components \
c2b2r_DrugBankDrug \
c2b2r_DCDB_DC_TO_DCU \
c2b2r_DCDB_DC_TO_DI \
c2b2r_DCDB_combination_drug \
c2b2r_DrugBankTarget \
c2b2r_HGNC \
c2b2r_reactome_pathway_protein \
c2b2r_kegg_ligand_compound_enzyme \
c2b2r_enzyme \
c2b2r_kegg_ligand_compound_basic \
c2b2r_Kidb \
c2b2r_matador \
c2b2r_UNIPROT \
c2b2r_PharmGKB_pharmagenomics \
c2b2r_PharmGKB_Relationships \
c2b2r_pubchem_bioassay_description \
c2b2r_PubChem_BioAssay \
c2b2r_QSAR \
c2b2r_PharmGKB_relation2diseases \
c2b2r_PharmGKB_Diseases \
c2b2r_PharmGKB_relation2drugs \
c2b2r_chemogenomics_2 \
c2b2r_PharmGKB_Drugs \
c2b2r_PharmGKB_relation2genes \
c2b2r_PharmGKB_Genes \
c2b2r_compound \
c2b2r_sider_costart \
c2b2r_TTD_target \
c2b2r_reactome_proteins \
c2b2r_chembl_08_assay2target \
c2b2r_chembl_08_compound_properties \
c2b2r_hprd_tissue_expressions \
c2b2r_chembl_08_compound_records \
c2b2r_chembl_08_compound_synonyms \
c2b2r_chembl_08_confidence_score_lookup \
c2b2r_chembl_08_docs \
c2b2r_chembl_08_molecule_hierarchy \
c2b2r_chembl_08_relationship_type \
c2b2r_chembl_08_research_codes \
c2b2r_chembl_08_source \
c2b2r_chembl_08_version \
c2b2r_biogrid \
c2b2r_chembl_08_compounds \
c2b2r_chembl_08_chemogenomics \
c2b2r_chemogenomics \
c2b2r_compound_neighbors_old \
c2b2r_compound_neighbors \
c2b2r_array_results \
c2b2r_arrayExpressAltas \
c2b2r_pesticide \
c2b2r_food_additive \
c2b2r_Gi2UNIPROT_new \
c2b2r_slap_feedback \
c2b2r_chebi \
c2b2r_interpro2protein \
pubchem_compound"
#
set -e
#
for table in $TABLES ; do
	sqlgzfile="data/c2b2r-pgdump-public-${table}.sql.gz"
	if [ -e "$sqlgzfile" ]; then
		printf "File exists, not overwritten: %s\n" $sqlgzfile
		continue
	fi
	printf "pg_dump %s: %s\n" $table $sqlgzfile
	pg_dump -U cicc3 \
		--schema=public \
		--table="public.\"${table}\"" \
		-v chord \
		|gzip -c >$sqlgzfile
done
#
#	|wc -c > pg_size_of_gzdumpfile.out
#
#
