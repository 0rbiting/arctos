<cfinclude template="/includes/_header.cfm">
<cfsetting requesttimeout="600">
<!----

little cache to speed things along - probably a good idea to delete from this and start over

create table temp_img_migr (path varchar2(4000),status varchar2(255));

---->
<cfoutput>
	<CFDIRECTORY
		ACTION="List"
		DIRECTORY="#Application.webDirectory#/mediaUploads"
		NAME="mediaUploads"
		recurse="yes"
		type="file">
	<cfquery name="temp_img_migr" datasource="uam_god">
		select * from temp_img_migr
	</cfquery>
	<cfloop query="mediaUploads">
		<cfset dirpath="#DIRECTORY#/#name#">
		<p>
			<br>dirpath: #dirpath#
			<cfquery name="alreadygotone" dbtype="query">
				select count(*) c from temp_img_migr where path='#dirpath#'
			</cfquery>
			<cfif alreadygotone.c gt 0>
				<br>alreadygotone
			<cfelse>
				<cfset olddpath=replace(dirpath,"/usr/local/httpd/htdocs/wwwarctos",application.serverRootURL)>
				<br>olddpath: #olddpath#
				<cfset newpath=replace(dirpath,"/usr/local/httpd/htdocs/wwwarctos","http://web.corral.tacc.utexas.edu/UAF/arctos")>
				<br>newpath: #newpath#
				<cfquery name="old_media" datasource="uam_god">
					select count(*) c from media where media_uri='#olddpath#'
				</cfquery>
				<cfquery name="old_thumb" datasource="uam_god">
					select count(*) c from media where PREVIEW_URI='#olddpath#'
				</cfquery>
				<cfquery name="new_media" datasource="uam_god">
					select count(*) c from media where media_uri='#newpath#'
				</cfquery>
				<cfquery name="new_thumb" datasource="uam_god">
					select count(*) c from media where PREVIEW_URI='#newpath#'
				</cfquery>
				<!---- only do things where
					- old is NOT used
					- new IS used

					anything else could be mid-processing
				---->

				<cfif old_media.c is 0 and old_thumb.c is 0 and (new_media.c gt 0 or new_thumb.c gt 0)>
					<br>DELETING #DIRECTORY#/#name#
					<cffile action = "delete" file = "#DIRECTORY#/#name#">

				<cfelseif old_media.c is 1 and new_media.c is 0>
					<cfhttp url='#newpath#' method="head"></cfhttp>
					<cfif cfhttp.statuscode is "200 OK">
						<br>update media set media_uri='#newpath#' where media_uri='#olddpath#'
						<cfquery name="udm" datasource="uam_god">
							update media set media_uri='#newpath#' where media_uri='#olddpath#'
						</cfquery>
					<cfelse>
						<cfquery name="ss" datasource="uam_god">
							insert into temp_img_migr (path,status) values ('#dirpath#','new_not_found')
						</cfquery>

						<br>WONKY NEW NOT FOUND!!
					</cfif>
				<cfelseif old_thumb.c is 1 and new_thumb.c is 0>
					<cfhttp url='#newpath#' method="head"></cfhttp>
					<cfif cfhttp.statuscode is "200 OK">
						<br>update media set preview_uri='#newpath#' where preview_uri='#olddpath#'
						<cfquery name="udmp" datasource="uam_god">
							update media set preview_uri='#newpath#' where preview_uri='#olddpath#'
						</cfquery>

					<cfelse>
						<cfquery name="ss" datasource="uam_god">
							insert into temp_img_migr (path,status) values ('#dirpath#','new_not_found')
						</cfquery>
						<br>WONKY NEW NOT FOUND!!
					</cfif>
				<cfelse>
						<cfquery name="ss" datasource="uam_god">
							insert into temp_img_migr (path,status) values ('#dirpath#','not_used')
						</cfquery>
					<br>CAUTION:
					<br>old_media.c: #old_media.c#
					<br>old_thumb.c: #old_thumb.c#
					<br>new_media.c: #new_media.c#
					<br>new_thumb.c: #new_thumb.c#
				</cfif>

			</cfif>
			<!----
			<cfif old.c is 0>
				<br>the old path is not used....
			<cfelse>
				<br>CAUTION: old path IS used
			</cfif>
			<cfquery name="new" datasource="uam_god">
				select count(*) c from media where media_uri='#newpath#' or PREVIEW_URI='#newpath#'
			</cfquery>
			<cfif new.c is 0>
				<br>CAUTION: the new path is not used....
			<cfelseif new.c is 1>
				<br>new path IS used
			<cfelse>
				<br>WUT??
			</cfif>
			<cfif old.c is 0 and new.c is 1>
				<cfscript>
					variables.joFileWriter.writeLine('rm #DIRECTORY#/#name#');
				</cfscript>

				<br>everything looks in order this can probably be deleted
			</cfif>
			---->
		</p>
		<cfflush>
	</cfloop>




</cfoutput>
<cfinclude template="/includes/_footer.cfm">