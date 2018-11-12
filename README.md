# Chem2Bio2RDF

Some notes.

cheminfov:

From http://i571.wikispaces.com/2D+chemical+database+searching+systems:


> psql -U cicc3 -d chord
or
> psql -U cicc3 -d gnova
create table gnovatest (smiles VARCHAR(200), name VARCHAR(50), logp real, fkey BIT(166));
>
> \d gnovatest
>
> INSERT INTO gnovatest (smiles, name, logp) VALUES ( 'CC(=O)Nc1ccc(O)cc1', 'Acetaminophen', 0.27 );
> INSERT INTO gnovatest (smiles, name, logp) VALUES ( 'CC(C)NCC(O)COc1ccccc1CC=C', 'Alprenolol', 2.81);
> INSERT INTO gnovatest (smiles, name, logp) VALUES ( 'CC(N)Cc1ccccc1', 'Amphetamine', 1.76 );
> INSERT INTO gnovatest (smiles, name, logp) VALUES ( 'CC(CS)C(=O)N1CCCC1C(=O)O', 'Captopril', 0.84 );
> INSERT INTO gnovatest (smiles, name, logp) VALUES ( 'CN(C)CCCN1c2ccccc2Sc3ccc(Cl)cc13', 'Chlorpromazine', 5.20 );
> INSERT INTO gnovatest (smiles, name, logp) VALUES ( 'OC(=O)Cc1ccccc1Nc2c(Cl)cccc2Cl', 'Diclofenac', 4.02 );
> INSERT INTO gnovatest (smiles, name, logp) VALUES ( 'NCC1(CC(=O)O)CCCCC1', 'Gabapentin', -1.37 );
> INSERT INTO gnovatest (smiles, name, logp) VALUES ( 'COC(=O)c1ccccc1O', 'Salicylate', 2.60 );


> update gnovatest set fkey = public166keys(smiles);
>
> select smiles,name,logp from gnovatest;
> select * from gnovatest;

> select smiles,name,logp from gnovatest where matches(smiles, '*C(=O)O');

> select smiles,name,logp from gnovatest where (matches(smiles, '*C(=O)O') AND (logp>1.0));

> select smiles,name,logp from gnovatest where tanimoto(fkey, public166keys('CC(=O)Oc1ccccc1C(=O)O')) > 0.6;

> drop table gnovatest;

> \dt

> select count(*) from public.chembl_02_compounds ;

> select table_name from information_schema.tables where table_schema='public' AND table_name LIKE 'chembl%' ;

> \d+ public.chembl_02_compounds

> $ cat describe_chembl.sql
> \d+ public.chembl_02_activities
> \d+ public.chembl_02_assay2target
> \d+ public.chembl_02_assay_type
> \d+ public.chembl_02_assays
> \d+ public.chembl_02_compound_properties
> \d+ public.chembl_02_compound_records
> \d+ public.chembl_02_compound_synonyms
> \d+ public.chembl_02_compounds
> \d+ public.chembl_02_confidence_score_lookup
> \d+ public.chembl_02_docs
> \d+ public.chembl_02_relationship_type
> \d+ public.chembl_02_source
> \d+ public.chembl_02_target_class
> \d+ public.chembl_02_target_dictionary
> \d+ public.chembl_02_target_type


How to dump specific dataset from pg?  In C2B2R, all data is in database "chord", schema "public", in
sets of tables such as:

 `drugbank`
 `drugbank_drug`
 `drugbank_drug_sp`
 `drugbank_drugtarget`
 `drugbank_drugtarget_sp`
 `drugbank_target`
 `drugbank_target_seq`

`pg_dump -U cicc3 \
	--schema=public \
	-t drugbank \
	-t drugbank_drug \
	-t drugbank_drug_sp \
	-t drugbank_drugtarget \
	-t drugbank_drugtarget_sp \
	-t drugbank_target \
	-t drugbank_target_seq \
	-v \
	chord \
	> drugbank-pgdump.sql`

On cheminfov, in the PostgreSQL instance, all data is in database "chord" (this was a design choice and
not required).  The schema "gnova" provides gNova Chord functionality as usual in accordance with
Chord documentation.  (Another database could have been used.)  All data is in the schema "public"
within database "chord", another design choice.  Each dataset (drugbank, chembl, etc.) could have
been implemented as a distinct schema.

Oops!  Missed some drugbank tables.  The list is:

> `chord=> select table_name from information_schema.tables where table_schema='public' and table_name ilike '%drugbank%' ORDER BY table_name;`
> `            table_name            `
> `----------------------------------`
> ` c2b2r_DrugBankDrug`
> ` c2b2r_drugbankdrug_042011`
> ` c2b2r_DrugBankDrugDrug`
> ` c2b2r_drugbankdrug_substructure`
> ` c2b2r_drugbankdrugtarget_042011`
> ` c2b2r_DrugBankTarget`
> ` c2b2r_drugbanktarget_042011`
> ` ctd_disease_drugbank`
> ` ctd_gene_drugbank`
> ` doid_drugbank`
> ` drugbank`
> ` drugbank_drug`
> ` drugbank_drug_sp`
> ` drugbank_drugtarget`
> ` drugbank_drugtarget_sp`
> ` drugbank_target`
> ` drugbank_target_seq`
> ` gene_drugbank`
> ` goid_drugbank`
> ` huge_genopedia_gene_drugbank`
> ` huge_phenopedia_disease_drugbank`
> `(21 rows)`

(Non-trivial to associate tables with source datasets!)

Not all tables in d2rq mapping, so some are unused?:

Not in mapping, so irrelevant?

> `huge_genopedia_gene_drugbank`
> `huge_phenopedia_disease_drugbank`
> `c2b2r_drugbankdrug_042011`
> `c2b2r_drugbankdrugtarget_042011`
> `c2b2r_drugbanktarget_042011`
> `ctd_disease_drugbank`
> `ctd_gene_drugbank`
> `doid_drugbank`
> `goid_drugbank`
> `gene_drugbank`

`grants$ gunzip -c chembl_13-mysqldump-pgcompatible.sql.gz | ~/c2b2r_fix_chembl_mysqldump.py | gzip -c > chembl_13-mysqldump-pgcompatible-fixed.sql.gz`

`c2b2r_fix_chembl_mysqldump.py: lines: 4945`
`c2b2r_fix_chembl_mysqldump.py: lines fixed: 4162`
