#!/bin/sh
#
DBNAME="chord"
DBUSR="cicc3"
DBPW=""
#
#
APPNAME="pubchem"
#
CONFIGFILE="data/config_${APPNAME}.ttl"
#
columns="\
c2b2r_compound.CID,\
c2b2r_compound.openeye_can_smiles,\
c2b2r_compound.openeye_iso_smiles,\
c2b2r_compound.std_inchi,\
c2b2r_pubchem_bioassay_description.aid,\
c2b2r_pubchem_bioassay_description.ttype,\
c2b2r_pubchem_bioassay_description.nmol,\
c2b2r_pubchem_bioassay_description.title,\
c2b2r_pubchem_bioassay_description.description,\
c2b2r_PubChem_BioAssay.ID,\
c2b2r_PubChem_BioAssay.SID,\
c2b2r_PubChem_BioAssay.Score,\
c2b2r_PubChem_BioAssay.outcome,\
c2b2r_PubChem_BioAssay.promiscuous\
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
#Edit config, fix some uriPatterns to conform with prior definitions (BinChen).
#
perl -pi -e 's/^\s*d2rq:uriPattern "c2b2r_compound.*$/\td2rq:uriPattern "pubchem_compound\/\@\@c2b2r_compound.CID\@\@";/;' $TMPFILE
#
perl -pi -e 's/^\s*d2rq:uriPattern "c2b2r_pubchem_bioassay_description*$/\td2rq:uriPattern "pubchem_bioassay\/\@\@c2b2r_pubchem_bioassay_description.aid\@\@";/;' $TMPFILE
#
perl -pi -e 's/^\s*d2rq:uriPattern "c2b2r_PubChem_BioAssay.*$/\td2rq:uriPattern "pubchem_bioassay_interaction\/\@\@c2b2r_PubChem_BioAssay.ID\@\@";/;' $TMPFILE
#
###
#Learn prior joins:
# grep join /var/lib/tomcat5.old-cheminfov/webapps/pubchem/WEB-INF/mapping.n3
###
#
table="pubchem_synonym"
jline="\td2rq:join \"c2b2r_compound.CID <= pubchem_synonym.cid\";"
perl -pi -e "s/^(\s*d2rq:column \"${table}\..*)\$/\$1\n${jline}/" $TMPFILE
#
table="c2b2r_PubMed2compound"
jline="\td2rq:join \"c2b2r_compound.CID <= c2b2r_PubMed2compound.cid\";"
perl -pi -e "s/^(\s*d2rq:column \"${table}\..*)\$/\$1\n${jline}/" $TMPFILE
#
table="c2b2r_compound_neighbors"
jline="\td2rq:join \"c2b2r_compound.CID <= c2b2r_compound_neighbors.CID\";"
perl -pi -e "s/^(\s*d2rq:column \"${table}\..*)\$/\$1\n${jline}/" $TMPFILE
#
table="c2b2r_chemogenomics"
jline="\td2rq:join \"c2b2r_compound.CID <= c2b2r_chemogenomics.CID\";"
perl -pi -e "s/^(\s*d2rq:column \"${table}\..*)\$/\$1\n${jline}/" $TMPFILE
#
table="c2b2r_food_additive"
jline="\td2rq:join \"c2b2r_compound.CID <= c2b2r_food_additive.cid1\";"
perl -pi -e "s/^(\s*d2rq:column \"${table}\..*)\$/\$1\n${jline}/" $TMPFILE
#
table="c2b2r_pesticide"
jline="\td2rq:join \"c2b2r_compound.CID <= c2b2r_pesticide.cid1\";"
perl -pi -e "s/^(\s*d2rq:column \"${table}\..*)\$/\$1\n${jline}/" $TMPFILE
#
table="c2b2r_compound"
jline="\td2rq:join \"c2b2r_PubChem_BioAssay.CID => c2b2r_compound.CID\";"
perl -pi -e "s/^(\s*d2rq:column \"${table}\..*)\$/\$1\n${jline}/" $TMPFILE
#
table="c2b2r_pubchem_bioassay_description"
jline="\td2rq:join \"c2b2r_PubChem_BioAssay.AID => c2b2r_pubchem_bioassay_description.aid\";"
perl -pi -e "s/^(\s*d2rq:column \"${table}\..*)\$/\$1\n${jline}/" $TMPFILE
#
###
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
