#!/bin/sh
#
DBNAME="chord"
DBUSR="cicc3"
DBPW=""
#
#
APPNAME="drugbank"
#
CONFIGFILE="data/config_${APPNAME}.ttl"
#
#Learn prior columns:
# grep column /var/lib/tomcat5.old-cheminfov/webapps/drugbank/WEB-INF/mapping.n3
#
columns="\
c2b2r_DrugBankDrug.CASRN,\
c2b2r_DrugBankDrug.DBID,\
c2b2r_DrugBankDrugDrug.drug1,\
c2b2r_DrugBankDrugDrug.drug2,\
c2b2r_DrugBankDrug.Generic_Name,\
c2b2r_DrugBankDrug.PubChemSID,\
c2b2r_DrugBankDrug.SwissProt_ID,\
c2b2r_DrugBankTarget.GeneBank_ID,\
c2b2r_DrugBankTarget.human,\
c2b2r_DrugBankTarget.ID,\
c2b2r_DrugBankTarget.Name,\
c2b2r_DrugBankTarget.promiscuous,\
c2b2r_DrugBankTarget.seq,\
c2b2r_DrugBankDrug.dailymed_URI,\
c2b2r_DrugBankDrug.dbpedia_URI\
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
#Learn prior uriPatterns:
# grep uriPattern /var/lib/tomcat5.old-cheminfov/webapps/drugbank/WEB-INF/mapping.n3
###
#Edit config, fix some uriPatterns:
#
perl -pi -e 's/^\s*d2rq:uriPattern "c2b2r_DrugBankDrug.*$/\td2rq:uriPattern "drugbank_drug\/\@\@c2b2r_DrugBankDrug.DBID\@\@";/' $TMPFILE
perl -pi -e 's/^\s*d2rq:uriPattern "c2b2r_DrugBankDrugDrug.*$/\td2rq:uriPattern "drugbank_drug_drug\/\@\@c2b2r_DrugBankDrugDrug.dbid1|urlify\@\@_\@\@c2b2r_DrugBankDrugDrug.dbid2\@\@";/' $TMPFILE
perl -pi -e 's/^\s*d2rq:uriPattern "c2b2r_DrugBankTarget.*$/\td2rq:uriPattern "drugbank_interaction\/\@\@c2b2r_DrugBankTarget.ID\@\@";/' $TMPFILE
#
###
#Learn prior joins:
# grep join /var/lib/tomcat5.old-cheminfov/webapps/drugbank/WEB-INF/mapping.n3
###
#
table="c2b2r_DrugBankDrug"
jline="\td2rq:join \"c2b2r_DrugBankTarget.DBID => c2b2r_DrugBankDrug.DBID\";"
perl -pi -e "s/^(\s*d2rq:column \"${table}\..*)\$/\$1\n${jline}/" $TMPFILE
jline="\td2rq:join \"c2b2r_DrugBankDrugDrug.dbid1 => c2b2r_DrugBankDrug.DBID\";"
perl -pi -e "s/^(\s*d2rq:column \"${table}\..*)\$/\$1\n${jline}/" $TMPFILE
jline="\td2rq:join \"c2b2r_DrugBankDrugDrug.dbid2 => c2b2r_DrugBankDrug.DBID\";"
perl -pi -e "s/^(\s*d2rq:column \"${table}\..*)\$/\$1\n${jline}/" $TMPFILE
#
###
#
mv $TMPFILE $CONFIGFILE
#
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
