#!/bin/sh
#
DBNAME="chord"
DBUSR="cicc3"
DBPW=""
#
#
APPNAME="uniprot"
#
CONFIGFILE="data/config_${APPNAME}.ttl"
#
#Learn prior columns:
# grep column /var/lib/tomcat5.old-cheminfov/webapps/uniprot/WEB-INF/mapping.n3
#
columns="\
c2b2r_UNIPROT.uniprot,\
c2b2r_gene.geneSymbol,\
c2b2r_gene.geneID,\
c2b2r_enzyme.ec_number,\
c2b2r_GI.GI,\
c2b2r_PDB.pdb\
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
# grep uriPattern /var/lib/tomcat5.old-cheminfov/webapps/uniprot/WEB-INF/mapping.n3
###
#Edit config, fix some uriPatterns:
#
perl -pi -e 's/d2rq:uriPattern "c2b2r_UNIPROT/d2rq:uriPattern "uniprot/' $TMPFILE
perl -pi -e 's/d2rq:uriPattern "c2b2r_gene.*$/d2rq:uriPattern "gene\/\@\@c2b2r_gene.geneSymbol|urlify\@\@";/' $TMPFILE
perl -pi -e 's/d2rq:uriPattern "c2b2r_enzyme/d2rq:uriPattern "enzyme/' $TMPFILE
perl -pi -e 's/d2rq:uriPattern "c2b2r_GI/d2rq:uriPattern "gi/' $TMPFILE
perl -pi -e 's/d2rq:uriPattern "c2b2r_PDB/d2rq:uriPattern "pdb/' $TMPFILE
#
###
#Learn prior joins:
# grep join /var/lib/tomcat5.old-cheminfov/webapps/uniprot/WEB-INF/mapping.n3
###
#
table="c2b2r_UNIPROT"
jline="\td2rq:join \"c2b2r_Gi2UNIPROT.uniprot => c2b2r_UNIPROT.uniprot\";"
perl -pi -e "s/^(\s*d2rq:column \"${table}\..*)\$/\$1\n${jline}/" $TMPFILE
#
table="c2b2r_GI"
jline="\td2rq:join \"c2b2r_Gi2UNIPROT.gi => c2b2r_GI.GI\";"
perl -pi -e "s/^(\s*d2rq:column \"${table}\..*)\$/\$1\n${jline}/" $TMPFILE
#
table="c2b2r_UNIPROT"
jline="\td2rq:join \"c2b2r_GENE2UNIPROT.uniprot => c2b2r_UNIPROT.uniprot\";"
perl -pi -e "s/^(\s*d2rq:column \"${table}\..*)\$/\$1\n${jline}/" $TMPFILE
#
table="c2b2r_gene"
jline="\td2rq:join \"c2b2r_GENE2UNIPROT.geneSymbol => c2b2r_gene.geneSymbol\";"
perl -pi -e "s/^(\s*d2rq:column \"${table}\..*)\$/\$1\n${jline}/" $TMPFILE
#
table="c2b2r_goa_human"
jline="\td2rq:join \"c2b2r_gene.geneSymbol <= c2b2r_goa_human.db_object_symbol\";"
perl -pi -e "s/^(\s*d2rq:column \"${table}\..*)\$/\$1\n${jline}/" $TMPFILE
#
###
#
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
