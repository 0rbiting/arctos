<cfoutput>
<cfinclude template="/includes/_header.cfm">
<cfset variables.fileName="#Application.webDirectory#/robots.txt">
<cfset variables.encoding="US-ASCII">
<cfscript>
	variables.joFileWriter = createObject('Component', '/component.FileWriter').init(variables.fileName, variables.encoding, 32768);
</cfscript>



<cfset robotscontent="User-agent: *">
<cfset robotscontent=robotscontent & chr(10) & "crawl-delay: 10">


<cfset dad="">



<cfif application.version is "test">
	<!---- by default we disallow all directories - list of things we DO want bots to scrape ---->
	<cfdirectory directory="#application.webDirectory#" action="list" name="q" sort="name" recurse="false" type="dir">

	<cfset allowDirs=valuelist(q.name)>


	<br>allowDirs: #allowDirs#



	<cfset forceDisallowFile="contact.cfm">
	<br>forceDisallowFile: #forceDisallowFile#
	<cfset forceDisallowDir="digir">
	<br>forceDisallowDir: #forceDisallowDir#

	<cfset forceAllowFile="favicon.ico,robots.txt">
	<br>forceAllowFile: #forceAllowFile#
	<cfset forceAllowDir="Collections,m">
	<br>forceAllowDir: #forceAllowDir#

	<cfquery name="portals" datasource="cf_dbuser">
		select portal_name from cf_collection
	</cfquery>
	<cfset forceDisallowDir=listappend(forceDisallowDir,valuelist(portals.portal_name))>
	<br>appended portals now...
	<br>
	<br>forceAllowDir: #forceAllowDir#




	<br>default allowDirs: #allowDirs#
		<cfset allowDirs=listappend(forceDisallowDir,valuelist(portals.portal_name))>


	<cfloop query="q">
		<cfif not listfindnocase(forceDisallowDir,name)>
			<cfset dad=dad & chr(10) & "Disallow: /" & name & "/">
		</cfif>
	</cfloop>



	<cfdirectory directory="#application.webDirectory#" action="list" name="q" sort="name" recurse="false" type="file">

	<cfloop query="q">
		<cfquery name="current" datasource="cf_dbuser">
			select count(*) c from cf_form_permissions where form_path='/#name#' and role_name='public'
		</cfquery>
		<cfif current.c is 0 and right(name,7) is not ".xml.gz" and not listfindnocase(forceAllowFile,name)>
			<cfset dad=dad & chr(10) & "Disallow: /" & name>
		</cfif>
	</cfloop>
	<cfscript>


		variables.joFileWriter.writeLine(robotscontent);
		variables.joFileWriter.writeLine(dad);
		variables.joFileWriter.writeLine('Sitemap: ' & application.serverRootUrl & '/sitemapindex.xml.gz');
	</cfscript>
<cfelse>
	<!---- not prod ---->
	<cfscript>
		variables.joFileWriter.writeLine('Disallow: /');
	</cfscript>
</cfif>
<cfscript>
	variables.joFileWriter.close();
</cfscript>
</cfoutput>