#!/bin/sh
#
set -x
#
pg_dump -U cicc3 \
        --schema=public \
	-t "\"c2b2r_DrugBankDrug\"" \
	-t "\"c2b2r_DrugBankDrugDrug\"" \
	-t "\"c2b2r_drugbankdrug_substructure\"" \
	-t "\"c2b2r_DrugBankTarget\"" \
	-t drugbank \
	-t drugbank_drug \
	-t drugbank_drug_sp \
	-t drugbank_drugtarget \
	-t drugbank_drugtarget_sp \
	-t drugbank_target \
	-t drugbank_target_seq \
	-v \
	chord \
	| gzip -c \
	>$HOME/Download/drugbank-pgdump.sql.gz
#
###Not in mapping, so irrelevant?
#	-t huge_genopedia_gene_drugbank \
#	-t huge_phenopedia_disease_drugbank \
#	-t c2b2r_drugbankdrug_042011 \
#	-t c2b2r_drugbankdrugtarget_042011 \
#	-t c2b2r_drugbanktarget_042011 \
#	-t ctd_disease_drugbank \
#	-t ctd_gene_drugbank \
#	-t doid_drugbank \
#	-t goid_drugbank \
#	-t gene_drugbank \
