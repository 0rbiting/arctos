<cfinclude template="/includes/_header.cfm">
<cfif action is "nothing">

<a href="downloadData.cfm?action=highergeog">higher geog</a>
<br /><a href="downloadData.cfm?action=afnum">all "AF"</a>
<br /><a href="downloadData.cfm?action=agentnames">agent names</a>
<br /><a href="downloadData.cfm?action=taxonomy">scientific name</a>
<cfquery name="ct" datasource="uam_god">
	select table_name from user_tables where table_name like 'CT%' order by table_name
</cfquery>
<cfoutput>
	<cfloop query="ct">
		<br /><a href="downloadData.cfm?action=#table_name#">#table_name#</a>
	</cfloop>
</cfoutput>
<cfinclude template="/includes/_footer.cfm">
</cfif>
<!------------------------------>

<cfif action is "afnum">
	<cfquery name="afnum" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select display_value as af from coll_obj_other_id_num where other_id_type='AF'
	</cfquery>
	<cffile action="write" file="#application.webDirectory#/temp/afnum.txt" addnewline="yes" output="afnum">

	<cfoutput query="afnum">
		<cffile action="append" file="#application.webDirectory#/temp/afnum.txt" addnewline="yes" output="#af#">
	</cfoutput>
	<a href="/temp/afnum.txt">download afnum</a>
<cfelseif action is "taxonomy">
	<cfquery name="taxonomy" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select scientific_name from taxonomy order by scientific_name
	</cfquery>
	<cffile action="write" file="#application.webDirectory#/temp/taxonomy.txt" addnewline="yes" output="scientific_name">

	<cfoutput query="taxonomy">
		<cffile action="append" file="#application.webDirectory#/temp/taxonomy.txt" addnewline="yes" output="#scientific_name#">
	</cfoutput>
	<a href="/temp/taxonomy.txt">download taxonomy</a>
<cfelseif action is  "agentnames">
	<cfquery name="agentnames" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select agent_name from agent_name
	</cfquery>
	<cffile action="write" file="#application.webDirectory#/temp/agentnames.txt" addnewline="yes" output="agent_name">

	<cfoutput query="agentnames">
		<cffile action="append" file="#application.webDirectory#/temp/agentnames.txt" addnewline="yes" output="#agent_name#">
	</cfoutput>
	<a href="/temp/agentnames.txt">download agents</a>
<cfelseif action is  "codeTableZip">
	<cfsetting requesttimeout="600">
	<cfoutput>
		<cfquery name="ct" datasource="uam_god">
			select table_name from user_tables where table_name like 'CT%' AND
			table_name not in (
				'CTATTRIBUTE_CODE_TABLES',
				'CTCOLLECTION_CDE',
				'CTCONTAINER_TYPE_SIZE',
				'CTPUBLICATION_ATTRIBUTE',
				'CTSPECIMEN_PART_LIST_ORDER',
				'CTSPEC_PART_ATT_ATT',
				'CTYES_NO',
				'CTACCN_STATUS',
				'CTACCN_TYPE',
				'CTADDR_TYPE',
				'CTAGENT_NAME_TYPE',
				'CTAGENT_RANK',
				'CTAGENT_RELATIONSHIP',
				'CTAGENT_TYPE',
				'CTAUTHOR_ROLE',
				'CTBORROW_STATUS',
				'CTCATALOGED_ITEM_TYPE',
				'CTCF_LOAN_USE_TYPE',
				'CTCITATION_TYPE_STATUS',
				'CTCLASS',
				'CTCOLL_CONTACT_ROLE',
				'CTCONTINENT',
				'CTDOWNLOAD_PURPOSE',
				'CTELECTRONIC_ADDR_TYPE',
				'CTENCUMBRANCE_ACTION',
				'CTEW',
				'CTFEATURE',
				'CTFLUID_CONCENTRATION',
				'CTGEOREFMETHOD',
				'CTIMAGE_OBJECT_TYPE',
				'CTINFRASPECIFIC_RANK',
				'CTISLAND_GROUP',
				'CTJOURNAL_NAME',
				'CTLOAN_STATUS',
				'CTLOAN_TYPE',
				'CTMEDIA_LABEL',
				'CTMEDIA_RELATIONSHIP',
				'CTMEDIA_TYPE',
				'CTMIME_TYPE',
				'CTNS',
				'CTPART_ATTRIBUTE_PART',
				'CTPERMIT_TYPE',
				'CTPREFIX',
				'CTPROJECT_AGENT_ROLE',
				'CTPUBLICATION_TYPE',
				'CTSECTION_TYPE',
				'CTSHIPPED_CARRIER_METHOD',
				'CTSPECPART_ATTRIBUTE_TYPE',
				'CTSUFFIX',
				'CTTAXA_FORMULA',
				'CTTAXONOMIC_AUTHORITY',
				'CTTAXON_RELATION',
				'CTTAXON_VARIABLE',
				'CTTRANSACTION_TYPE',
				'CTTRANS_AGENT_ROLE',
				'CTFLUID_TYPE',
				'CTGEOG_SOURCE_AUTHORITY',
				'CTLAT_LONG_REF_SOURCE'
			) order by table_name
		</cfquery>
		<cfif not directoryexists("#Application.webDirectory#/temp/ctzip")>
			<cfdirectory action="create" directory="#Application.webDirectory#/temp/ctzip">
		</cfif>
		<cffile action="write" file="#Application.webDirectory#/temp/ctzip/imp.sql" addnewline="yes" output='.separator "|"'>

	
		<cfloop query="ct">
		<cftry>
		<HR>
			<br>table_name: #table_name#
			<cfquery name="d" datasource="cf_dbuser">
				select * from #table_name#
			</cfquery>
			<cfset f=d.columnlist>
			<br>f:#f#
			<cfset stuffToDie="description,CTSPNID,IS_TISSUE,base_url">
			<cfloop list="#stuffToDie#" index="i">
				<cfif listfindnocase(f,i)>
					<cfset f=listdeleteat(f,listfindnocase(f,i))>
				</cfif>
			</cfloop>
			<cfset r=table_name>
			<cfif listfindnocase(f,"collection_cde")>
				<cfset hasCollCde=true>
				<cfset theColumn=listdeleteat(f,listfindnocase(f,"collection_cde"))>
				<cfset ss="create table if not exists #lcase(table_name)# (#lcase(theColumn)# char);">
			<cfelse>
				<cfset hasCollCde=false>
				<cfset theColumn=f>				
				<cfset ss="create table if not exists #lcase(table_name)# (#lcase(theColumn)# char,collection_cde char);">
			</cfif>
			<br>theColumn: #theColumn#
			<br>hasCollCde: #hasCollCde#
			<cfset ss=ss & chr(10) & "delete from #lcase(table_name)#;">
			<cfset ss=ss & chr(10) & ".import ctzip/#lcase(table_name)#.csv #lcase(table_name)#" & chr(10)>

			<cffile action="append" file="#Application.webDirectory#/temp/ctzip/imp.sql" addnewline="no" output="#ss#">

			<cfset variables.fileName="#Application.webDirectory#/temp/ctzip/#lcase(table_name)#.csv">
			<cfset variables.encoding="US-ASCII">
			<cfscript>
				variables.joFileWriter = createObject('Component', '/component.FileWriter').init(variables.fileName, variables.encoding, 32768);
			</cfscript>		
			<cfloop query="d">
				<cfset t=evaluate("d." & theColumn)>				
				<cfif hasCollCde>
					<cfset t=t & '|' & d.collection_cde>
				</cfif>
				<cfscript>
					variables.joFileWriter.writeLine(t);
				</cfscript>
			</cfloop>
			<cfscript>
				variables.joFileWriter.close();
			</cfscript>
			
			<cfcatch>
				<br>FAIL on #table_name#
			</cfcatch>
			</cftry>
		</cfloop>
		
		
		<cfquery name="taxonomy" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			select scientific_name from taxonomy order by scientific_name
		</cfquery>
		<cfset variables.fileName="#Application.webDirectory#/temp/ctzip/taxonomy.csv">
		<cfset variables.encoding="US-ASCII">
		<cfscript>
			variables.joFileWriter = createObject('Component', '/component.FileWriter').init(variables.fileName, variables.encoding, 32768);
		</cfscript>
		<cfloop query="taxonomy">
			<cfscript>
				variables.joFileWriter.writeLine(scientific_name);
			</cfscript>
		</cfloop>
		<cfscript>
			variables.joFileWriter.close();
		</cfscript>
		<cfset ss="create table if not exists taxonomy (scientific_name char);">
		<cfset ss=ss & chr(10) & "delete from taxonomy;">
		<cfset ss=ss & chr(10) & ".import ctzip/taxonomy.csv taxonomy" & chr(10)>
		<cffile action="append" file="#Application.webDirectory#/temp/ctzip/imp.sql" addnewline="no" output="#ss#">
		
		
		<cfquery name="agent_name" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			select agent_name from agent_name order by agent_name
		</cfquery>
		<cfset variables.fileName="#Application.webDirectory#/temp/ctzip/agent_name.csv">
		<cfset variables.encoding="US-ASCII">
		<cfscript>
			variables.joFileWriter = createObject('Component', '/component.FileWriter').init(variables.fileName, variables.encoding, 32768);
		</cfscript>
		<cfloop query="agent_name">
			<cfscript>
				variables.joFileWriter.writeLine(agent_name);
			</cfscript>
		</cfloop>
		<cfscript>
			variables.joFileWriter.close();
		</cfscript>
		<cfset ss="create table if not exists agent_name (agent_name char);">
		<cfset ss=ss & chr(10) & "delete from agent_name;">
		<cfset ss=ss & chr(10) & ".import ctzip/agent_name.csv agent_name" & chr(10)>
		<cffile action="append" file="#Application.webDirectory#/temp/ctzip/imp.sql" addnewline="no" output="#ss#">
		
		
		<cfquery name="higher_geog" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			select higher_geog from geog_auth_rec order by higher_geog
		</cfquery>
		<cfset variables.fileName="#Application.webDirectory#/temp/ctzip/higher_geog.csv">
		<cfset variables.encoding="US-ASCII">
		<cfscript>
			variables.joFileWriter = createObject('Component', '/component.FileWriter').init(variables.fileName, variables.encoding, 32768);
		</cfscript>
		<cfloop query="higher_geog">
			<cfscript>
				variables.joFileWriter.writeLine(higher_geog);
			</cfscript>
		</cfloop>
		<cfscript>
			variables.joFileWriter.close();
		</cfscript>
		<cfset ss="create table if not exists higher_geog (higher_geog char);">
		<cfset ss=ss & chr(10) & "delete from higher_geog;">
		<cfset ss=ss & chr(10) & ".import ctzip/higher_geog.csv higher_geog" & chr(10)>
		<cffile action="append" file="#Application.webDirectory#/temp/ctzip/imp.sql" addnewline="no" output="#ss#">
		
		
		
	
	
		<cfzip file="#Application.webDirectory#/download/ctzip.zip" source="#Application.webDirectory#/temp/ctzip">
		<!---
		<cflocation url="/download.cfm?file=ctzip.zip">
		
		--->
		
		<a href="/download.cfm?file=ctzip.zip">download</a>
	</cfoutput>
<cfelse>
	<cfoutput>
	<cfset tablename=action>
	<cfquery name="d" datasource="cf_dbuser">
		select * from #tablename#
	</cfquery>
	<cfset f=d.columnlist>
	<cfset stuffToDie="description,CTSPNID,IS_TISSUE,base_url">
	<cfloop list="#stuffToDie#" index="i">
		<cfif listfindnocase(f,i)>
			<cfset f=listdeleteat(f,listfindnocase(f,i))>
		</cfif>
	</cfloop>
	<cfset r=tablename>
	<cfif listfindnocase(f,"collection_cde")>
		<cfset hasCollCde=true>
		<cfset theColumn=listdeleteat(f,listfindnocase(f,"collection_cde"))>
	<cfelse>
		<cfset hasCollCde=false>
		<cfset theColumn=f>
	</cfif>
	
	<cfset variables.fileName="#Application.webDirectory#/download/#lcase(tablename)#.csv">
	<cfset variables.encoding="US-ASCII">
	<cfscript>
		variables.joFileWriter = createObject('Component', '/component.FileWriter').init(variables.fileName, variables.encoding, 32768);
	</cfscript>		
	<cfloop query="d">
		<cfset t= evaluate("d." & theColumn)>
		<cfif hasCollCde>
			<cfset t=t & ',' & d.collection_cde>
		</cfif>
		<cfscript>
			variables.joFileWriter.writeLine(t);
		</cfscript>
	</cfloop>
	<cfscript>
		variables.joFileWriter.close();
	</cfscript>
	<cflocation url="/download.cfm?file=#lcase(tablename)#.csv">
</cfoutput>

</cfif>
<!------------------------------>
<cfif #action# is "highergeog">
	<cfquery name="geog" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select higher_geog from geog_auth_rec order by higher_geog
	</cfquery>
	<cffile action="write" file="#application.webDirectory#/temp/geog.txt" addnewline="yes" output="higher_geog">

	<cfoutput query="geog">
		<cffile action="append" file="#application.webDirectory#/temp/geog.txt" addnewline="yes" output="#higher_geog#">
	</cfoutput>
	<cflocation url="/temp/geog.txt">
</cfif>
