#!/bin/sh
#
DBNAME="chord"
DBUSR="cicc3"
DBPW=""
#
#
#APPNAME="d2rq_chembl"
APPNAME="chembl"
#
CONFIGFILE="data/config_${APPNAME}.ttl"
#
#Learn prior columns:
# grep column /var/lib/tomcat5.old-cheminfov/webapps/chembl/WEB-INF/mapping.n3 |perl -pe 's/^.*"(.*)".*$/$1/'
#
columns="\
c2b2r_chembl_08_chemogenomics.cid_gene_activities,\
c2b2r_chembl_08_activities.activity_id,\
c2b2r_chembl_08_activities.relation,\
c2b2r_chembl_08_activities.published_value,\
c2b2r_chembl_08_activities.published_units,\
c2b2r_chembl_08_activities.standard_value,\
c2b2r_chembl_08_activities.standard_units,\
c2b2r_chembl_08_activities.standard_flag,\
c2b2r_chembl_08_activities.standard_type,\
c2b2r_chembl_08_activities.activity_comment,\
c2b2r_chembl_08_activities.published_activity_type,\
c2b2r_chembl_08_assay2target.assay_tax_id,\
c2b2r_chembl_08_assay2target.assay_organism,\
c2b2r_chembl_08_assay2target.complex,\
c2b2r_chembl_08_assay2target.multi,\
c2b2r_chembl_08_assay2target.assay_strain,\
c2b2r_chembl_08_assay2target.confidence_score,\
c2b2r_chembl_08_confidence_score_lookup.description,\
c2b2r_chembl_08_assay2target.relationship_type,\
c2b2r_chembl_08_relationship_type.relationship_desc,\
c2b2r_chembl_08_assays.assay_id,\
c2b2r_chembl_08_assays.description,\
c2b2r_chembl_08_assays.assay_type,\
c2b2r_chembl_08_assay_type.assay_desc,\
c2b2r_chembl_08_compounds.molregno,\
c2b2r_chembl_08_compounds.molweight,\
c2b2r_chembl_08_compounds.molformula,\
c2b2r_chembl_08_compounds.canonical_smiles,\
c2b2r_chembl_08_compounds.inchi,\
c2b2r_chembl_08_compounds.inchi_key,\
c2b2r_chembl_08_compounds.standard_inchi,\
c2b2r_chembl_08_compounds.standard_inchi_key,\
c2b2r_chembl_08_compounds.downgraded,\
c2b2r_chembl_08_compounds.max_phase,\
c2b2r_chembl_08_compounds.pref_name,\
c2b2r_chembl_08_compounds.therapeutic_flag,\
c2b2r_chembl_08_compound_synonyms.synonyms,\
c2b2r_chembl_08_compound_synonyms.syn_type,\
c2b2r_chembl_08_compound_properties.mw_freebase,\
c2b2r_chembl_08_compound_properties.alogp,\
c2b2r_chembl_08_compound_properties.hba,\
c2b2r_chembl_08_compound_properties.hbd,\
c2b2r_chembl_08_compound_properties.psa,\
c2b2r_chembl_08_compound_properties.rtb,\
c2b2r_chembl_08_compound_properties.ro3_pass,\
c2b2r_chembl_08_compound_properties.num_ro5_violations,\
c2b2r_chembl_08_compound_properties.med_chem_friendly,\
c2b2r_chembl_08_compound_properties.acd_most_apka,\
c2b2r_chembl_08_compound_properties.med_chem_friendly,\
c2b2r_chembl_08_compound_properties.acd_logp,\
c2b2r_chembl_08_compound_properties.acd_logd,\
c2b2r_chembl_08_compound_properties.molecular_species,\
c2b2r_chembl_08_compound_records.record_id,\
c2b2r_chembl_08_compound_records.compound_key,\
c2b2r_chembl_08_compound_records.compound_name,\
c2b2r_chembl_08_source.src_description,\
c2b2r_chembl_08_docs.doc_id,\
c2b2r_chembl_08_docs.journal,\
c2b2r_chembl_08_docs.year,\
c2b2r_chembl_08_docs.volume,\
c2b2r_chembl_08_docs.issue,\
c2b2r_chembl_08_docs.first_page,\
c2b2r_chembl_08_docs.last_page,\
c2b2r_chembl_08_docs.pubmed_id,\
c2b2r_chembl_08_docs.doi,\
c2b2r_chembl_08_target_class.tc_id,\
c2b2r_chembl_08_target_class.l1,\
c2b2r_chembl_08_target_class.l2,\
c2b2r_chembl_08_target_class.l3,\
c2b2r_chembl_08_target_class.l4,\
c2b2r_chembl_08_target_class.l5,\
c2b2r_chembl_08_target_class.l6,\
c2b2r_chembl_08_target_class.l7,\
c2b2r_chembl_08_target_class.l8,\
c2b2r_chembl_08_target_class.target_classification,\
c2b2r_chembl_08_target_dictionary.tid,\
c2b2r_chembl_08_target_dictionary.db_source,\
c2b2r_chembl_08_target_dictionary.description,\
c2b2r_chembl_08_target_dictionary.gene_names,\
c2b2r_chembl_08_target_dictionary.pref_name,\
c2b2r_chembl_08_target_dictionary.synonyms,\
c2b2r_chembl_08_target_dictionary.keywords,\
c2b2r_chembl_08_target_dictionary.protein_sequence,\
c2b2r_chembl_08_target_dictionary.protein_md5sum,\
c2b2r_chembl_08_target_dictionary.tax_id,\
c2b2r_chembl_08_target_dictionary.organism,\
c2b2r_chembl_08_target_dictionary.tissue,\
c2b2r_chembl_08_target_dictionary.strain,\
c2b2r_chembl_08_target_dictionary.db_version,\
c2b2r_chembl_08_target_dictionary.cell_line,\
c2b2r_chembl_08_target_dictionary.target_type,\
c2b2r_chembl_08_target_type.target_desc\
"
#
/usr/local/d2rq-0.8.1/generate-mapping \
	-d org.postgresql.Driver \
	-u "$DBUSR" \
	-p "$DBPW" \
	--columns "$columns" \
	-o $CONFIGFILE \
	"jdbc:postgresql://localhost/${DBNAME}"
#
HOSTFQ=`hostname --fqdn`
#
###
# Edits:
#====================================================================================
TMPFILE="data/tmp.ttl"
rm -f $TMPFILE
touch $TMPFILE
#
cat $CONFIGFILE \
	| sed -e '/map:database/,$d' \
	>>$TMPFILE
#
cat <<__EOF__ >>$TMPFILE
#====================================================================================
@prefix d2r: <http://sites.wiwiss.fu-berlin.de/suhl/bizer/d2r-server/config.rdf#> .
  
<> a d2r:Server;
 	rdfs:label "D2RQ Server: ${APPNAME}";
 	d2r:baseURI <http://${HOSTFQ}:8080/${APPNAME}/>;
 	d2r:port 8080;
 	d2r:vocabularyIncludeInstances true;
 	d2r:sparqlTimeout 300;
 	d2r:pageTimeout 5;
 	.
#====================================================================================
__EOF__
#
#
cat $CONFIGFILE \
	| sed -e '/map:database/,$!d' \
	>>$TMPFILE
#
###
#Learn prior uriPatterns:
# grep uriPattern /var/lib/tomcat5.old-cheminfov/webapps/chembl/WEB-INF/mapping.n3
###
#Edit config, fix some uriPatterns:
#
perl -pi -e 's/d2rq:uriPattern "c2b2r_chembl_08_activities/d2rq:uriPattern "chembl_activities/' $TMPFILE
perl -pi -e 's/d2rq:uriPattern "c2b2r_chembl_08_assays/d2rq:uriPattern "chembl_assays/' $TMPFILE
perl -pi -e 's/d2rq:uriPattern "c2b2r_chembl_08_compounds/d2rq:uriPattern "chembl_compounds/' $TMPFILE
perl -pi -e 's/d2rq:uriPattern "c2b2r_chembl_08_docs/d2rq:uriPattern "chembl_docs/' $TMPFILE
perl -pi -e 's/d2rq:uriPattern "c2b2r_chembl_08_target_class/d2rq:uriPattern "chembl_target_class/' $TMPFILE
perl -pi -e 's/d2rq:uriPattern "c2b2r_chembl_08_target_dictionary/d2rq:uriPattern "chembl_targets/' $TMPFILE
#
perl -pi -e 's/d2rq:uriPattern "c2b2r_chembl_08_chemogenomics.*$/d2rq:uriPattern "chembl_chemogenomics\/\@\@c2b2r_chembl_08_chemogenomics.cid_gene_activities\@\@";/' $TMPFILE
perl -pi -e 's/d2rq:uriPattern "c2b2r_chembl_08_assay2target.*$/d2rq:uriPattern "chembl_assay2targets\/\@\@c2b2r_chembl_08_assay2target.assay_id\@\@~\@\@c2b2r_chembl_08_assay2target.tid|urlify\@\@";/' $TMPFILE
perl -pi -e 's/d2rq:uriPattern "c2b2r_chembl_08_compound_records.*$/d2rq:uriPattern "chembl_compound_records\/\@\@c2b2r_chembl_08_compound_records.record_id\@\@";/' $TMPFILE
#
#When table has no primary key, no auto-generated uriPattern from generate-mapping, so must do manually.
perl -pi -e 's/d2rq:uriPattern "c2b2r_chembl_08_assay_type.*$/d2rq:uriPattern "chembl_assay_type\/\@\@c2b2r_chembl_08_assay_type.assay_type\@\@";/' $TMPFILE
perl -pi -e 's/d2rq:uriPattern "c2b2r_chembl_08_compound_properties.*$/d2rq:uriPattern "chembl_compound_properties\/\@\@c2b2r_chembl_08_compound_properties.molregno\@\@";/' $TMPFILE
perl -pi -e 's/d2rq:uriPattern "c2b2r_chembl_08_compound_synonyms.*$/d2rq:uriPattern "chembl_compound_synonyms\/\@\@c2b2r_chembl_08_compound_synonyms.molregno\@\@";/' $TMPFILE
perl -pi -e 's/d2rq:uriPattern "c2b2r_chembl_08_confidence_score_lookup.*$/d2rq:uriPattern "chembl_confidence_score_lookup\/\@\@c2b2r_chembl_08_confidence_score_lookup.confidence_score\@\@";/' $TMPFILE
perl -pi -e 's/d2rq:uriPattern "c2b2r_chembl_08_relationship_type.*$/d2rq:uriPattern "chembl_relationship_type\/\@\@c2b2r_chembl_08_relationship_type.relationship_type\@\@";/' $TMPFILE
perl -pi -e 's/d2rq:uriPattern "c2b2r_chembl_08_source.*$/d2rq:uriPattern "chembl_source\/\@\@c2b2r_chembl_08_source.src_id\@\@";/' $TMPFILE
perl -pi -e 's/d2rq:uriPattern "c2b2r_chembl_08_target_type.*$/d2rq:uriPattern "chembl_target_type\/\@\@c2b2r_chembl_08_target_type.target_type\@\@";/' $TMPFILE
#
###
#Learn prior joins:
# grep join /var/lib/tomcat5.old-cheminfov/webapps/chembl/WEB-INF/mapping.n3
###
table="c2b2r_chembl_08_activities"
jline="\td2rq:join \"c2b2r_chembl_08_chemogenomics.activity_id => ${table}.activity_id\";"
perl -pi -e "s/^(\s*d2rq:column \"${table}\..*)\$/\$1\n${jline}/" $TMPFILE
#
table="c2b2r_chembl_08_assays\";"
jline="\td2rq:join \"c2b2r_chembl_08_activities.assay_id => ${table}.assay_id\";"
perl -pi -e "s/^(\s*d2rq:column \"${table}\..*)\$/\$1\n${jline}/" $TMPFILE
jline="\td2rq:join \"c2b2r_chembl_08_assay2target.assay_id => ${table}.assay_id\";"
perl -pi -e "s/^(\s*d2rq:column \"${table}\..*)\$/\$1\n${jline}/" $TMPFILE
#
table="c2b2r_chembl_08_compound_properties"
jline="\td2rq:join \"c2b2r_chembl_08_compounds.molregno <= ${table}.molregno\";"
perl -pi -e "s/^(\s*d2rq:column \"${table}\..*)\$/\$1\n${jline}/" $TMPFILE
#
table="c2b2r_chembl_08_compound_synonyms"
jline="\td2rq:join \"c2b2r_chembl_08_compounds.molregno <= ${table}.molregno\";"
perl -pi -e "s/^(\s*d2rq:column \"${table}\..*)\$/\$1\n${jline}/" $TMPFILE
#
table="c2b2r_chembl_08_compound_records"
jline="\td2rq:join \"c2b2r_chembl_08_compounds.molregno <= ${table}.molregno\";"
perl -pi -e "s/^(\s*d2rq:column \"${table}\..*)\$/\$1\n${jline}/" $TMPFILE
jline="\td2rq:join \"c2b2r_chembl_08_activities.record_id => ${table}.record_id\";"
perl -pi -e "s/^(\s*d2rq:column \"${table}\..*)\$/\$1\n${jline}/" $TMPFILE
#
table="c2b2r_chembl_08_confidence_score_lookup"
jline="\td2rq:join \"c2b2r_chembl_08_assay2target.confidence_score => ${table}.confidence_score\";"
perl -pi -e "s/^(\s*d2rq:column \"${table}\..*)\$/\$1\n${jline}/" $TMPFILE
#
table="c2b2r_chembl_08_docs"
jline="\td2rq:join \"c2b2r_chembl_08_activities.doc_id => ${table}.doc_id\";"
perl -pi -e "s/^(\s*d2rq:column \"${table}\..*)\$/\$1\n${jline}/" $TMPFILE
jline="\td2rq:join \"c2b2r_chembl_08_assays.doc_id => c2b2r_chembl_08_docs.doc_id\";"
perl -pi -e "s/^(\s*d2rq:column \"${table}\..*)\$/\$1\n${jline}/" $TMPFILE
jline="\td2rq:join \"c2b2r_chembl_08_compound_records.doc_id => c2b2r_chembl_08_docs.doc_id\";"
perl -pi -e "s/^(\s*d2rq:column \"${table}\..*)\$/\$1\n${jline}/" $TMPFILE
#
table="c2b2r_chembl_08_relationship_type"
jline="\td2rq:join \"c2b2r_chembl_08_assay2target.relationship_type => ${table}.relationship_type\";"
perl -pi -e "s/^(\s*d2rq:column \"${table}\..*)\$/\$1\n${jline}/" $TMPFILE
#
table="c2b2r_chembl_08_target_dictionary"
jline="\td2rq:join \"c2b2r_chembl_08_target_class.tid => ${table}.tid\";"
perl -pi -e "s/^(\s*d2rq:column \"${table}\..*)\$/\$1\n${jline}/" $TMPFILE
#
table="c2b2r_chembl_08_source"
jline="\td2rq:join \"c2b2r_chembl_08_compound_records.src_id <= c2b2r_chembl_08_source.src_id\";"
perl -pi -e "s/^(\s*d2rq:column \"${table}\..*)\$/\$1\n${jline}/" $TMPFILE
#
table="c2b2r_chembl_08_target_type"
jline="\td2rq:join \"c2b2r_chembl_08_target_dictionary.target_type => ${table}.target_type\";"
perl -pi -e "s/^(\s*d2rq:column \"${table}\..*)\$/\$1\n${jline}/" $TMPFILE
#
###
mv $TMPFILE $CONFIGFILE
#
#
###
APPDIR="data/${APPNAME}"
rm -rf ${APPDIR}
mkdir ${APPDIR}
(cd ${APPDIR} ; unzip -o /usr/local/d2rq/d2rq.war)
###
cp $CONFIGFILE ${APPDIR}/WEB-INF/config.ttl
###
#Edit web.xml, to refer to config.ttl.
perl -pi -e 's/config-example\.ttl/config.ttl/;' ${APPDIR}/WEB-INF/web.xml
###
#Make WAR:
(cd  ${APPDIR} ; zip -r ../${APPNAME}.war .)
#
#Cleanup:
rm -rf ${APPDIR}
#
