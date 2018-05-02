<cfinclude template="/includes/_header.cfm">
<!---
	https://github.com/ArctosDB/arctos/issues/1446
	1) make this asynchronous
	2) move Media to s3/corral

	create table cf_temp_zipload (
		zid number not null,
		username varchar2(255) not null,
		email  varchar2(255) not null,
		jobname  varchar2(255) not null,
		status  varchar2(255) not null
	);

	create public synonym cf_temp_zipload for cf_temp_zipload;

	grant insert,select on cf_temp_zipload to manage_media;


	-- processing table
	-- only UAM will interact; no synonyms necessary
	create table cf_temp_zipfiles (
		zid number not null,
		filename varchar2(255),
		new_filename varchar2(255),
		preview_filename varchar2(255),
		localpath varchar2(255),
		remotepath varchar2(255),
		status varchar2(255)
	);

	alter table cf_temp_zipfiles add new_filename varchar2(255);
	alter table cf_temp_zipfiles add preview_filename varchar2(255);
--->
<cfset goodExtensions="jpg,png">
<cfset baseWebDir="#application.serverRootURL#/mediaUploads/#session.username#/#dateformat(now(),'yyyy-mm-dd')#">
<cfset baseFileDir="#application.webDirectory#/mediaUploads/#session.username#/#dateformat(now(),'yyyy-mm-dd')#">
<cfset sandboxdir="#application.sandbox#/#session.username#">



reset

delete from cf_temp_zipfiles;
update cf_temp_zipload set status='new';
<hr>
This form is under redevelopment.

cfabort


<p></p>

<br>thisform
<br>s1: <a href="uploadMedia.cfm?action=nothing">nothing</a>
<br>s2: getFile (submit f. nothing)
<br>will schedule
<br><a href="uploadMedia.cfm?action=unzip">unzip</a>
<br><a href="uploadMedia.cfm?action=rename">rename</a>

<hr>

<!------------------------------------------------------------------------------------------------>
<cfif action is "rename">
	<cfoutput>
		<cfquery name="d" datasource="uam_god">
			select * from cf_temp_zipload where status='unzipped' and rownum=1
		</cfquery>
		<cfdump var=#d#>
		<cfloop query="d">
			<cfquery name="f" datasource="uam_god">
				select * from cf_temp_zipfiles where zid=#d.zid#
			</cfquery>
			<cfloop query="f">
				<cfset fext=listlast(filename,".")>
				<cfif not listfindnocase(goodExtensions,fext)>
					update cf_temp_zipload set status='FATAL ERROR: #filename# contains an invalid extension' where zid=#d.zid#
					<cfbreak>
				</cfif>
				<br>#filename#

				<cfset fName=listdeleteat(fileName,listlen(filename,'.'),'.')>
				<cfset fName=REReplace(fName,"[^A-Za-z0-9_$]","_","all")>
				<cfset fName=replace(fName,'__','_','all')>
				<cfset nfileName=fName & '.' & fext>

				<br>new:#nfileName#




			</cfloop>
		</cfloop>
	</cfoutput>
</cfif>
<!------------------------------------------------------------------------------------------------>
<cfif action is "nothing">
	<cfoutput>
		<p>
			Upload a ZIP archive of image files. Arctos will attempt to move them to an archival file server, create thumbnail/previews, and
			email you a media bulkloader template.
		</p>
		<ul>
			<li>Only .jpg, .jpeg, and .png (case-insensitive) files will be accepted. File an Issue with expansion requests.</li>
			<li>Files which start with _ or . will be ignored.</li>
			<li>Filenames containing characters other than A-Z, a-z, and 0-9 will be changed.</li>
			<li>The ZIP should contain only image files, no folders etc.</li>
		</ul>

		<cfquery name="addr" datasource="uam_god">
			select get_Address(#session.myagentid#,'email') addr from dual
		</cfquery>

		<form name="mupl" method="post" enctype="multipart/form-data">
			<input type="hidden" name="Action" value="getFile">
			<label for ="username">Username</label>
			<input name="username" class="reqdClr" required value="#session.username#">
			<label for ="email">Email</label>
			<input name="email" class="reqdClr" required value="#addr.addr#">
			<label for ="jobname">Job Name (must be unique; any string is OK; used to keep track of this batch)</label>
			<input name="jobname" class="reqdClr" required value="#CreateUUID()#">
			<label for="FiletoUpload">Upload a ZIP file</label>
			<input type="file" name="FiletoUpload" size="45">
			<input type="submit" value="Upload this file" class="savBtn">
	  </form>
	</cfoutput>
</cfif>
<!------------------------------------------------------------------------------------------------>
<cfif action is "getFile">
	<!---- temp directory is good for 3 days, should be plenty ---->
	<!--- first insert - will guarantee a unique job name ---->
	<cfquery name="cjob" datasource="uam_god">
		insert into cf_temp_zipload (
			zid,
			username,
			email,
			jobname,
			status
		) values (
			somerandomsequence.nextval,
			'#username#',
			'#email#',
			'#jobname#',
			'new'
		)
	</cfquery>
	<!--- get the ID we just used for a file name---->
	<cfquery name="jid" datasource="uam_god">
		select zid from cf_temp_zipload where jobname='#jobname#'
	</cfquery>
	<!---- now upload the ZIP ---->
	<cffile action="upload"	destination="#Application.webDirectory#/temp/#jid.zid#.zip" nameConflict="overwrite" fileField="Form.FiletoUpload" mode="600">
	<p>
		You will receive email when processing has completed, usually within 24 hours.
	</p>
	<p>
		Your ZIP has been loaded and a job created. You will receive email from Arctos referencing job #jobname#. Do not delete the ZIP file until you
		are notified that the process is complete and you have confirmed that all of your data are on Corral.
	</p>

</cfif>
<!------------------------------------------------------------------------------------------------>
<cfif action is "unzip">
	<cfoutput>
		<!--- see if there's anything new; just grab one --->
		<cfquery name="jid" datasource="uam_god">
			select * from cf_temp_zipload where status='new' and rownum=1
		</cfquery>
		<cfdump var=#jid#>

		<cfloop query="jid">
			<cfdirectory action = "create" directory = "#Application.webDirectory#/temp/#jid.zid#" >
			<br>jidloop
			<cfzip file="#Application.webDirectory#/temp/#jid.zid#.zip" action="unzip" destination="#Application.webDirectory#/temp/#jid.zid#/"/>
			<cfdirectory action="LIST" directory="#Application.webDirectory#/temp/#jid.zid#" name="dir" recurse="no">
			<cfdump var=#dir#>
			<cfloop query="dir">
				<br>insert #name#
				<cfif left(name,1) is not "." and left(name,1) is not "_">
					<cfquery name="faf" datasource="uam_god">
						insert into cf_temp_zipfiles (zid,filename) values (#jid.zid#,'#name#')
					</cfquery>
				</cfif>
			</cfloop>
		</cfloop>
		<cfquery name="uz" datasource="uam_god">
			update cf_temp_zipload set status='unzipped' where zid=#jid.zid#
		</cfquery>
	</cfoutput>

<!----
<br />

	-- only UAM will interact; no synonyms necessary
	create table cf_temp_zipfiles (
		zid number not null,
		filename varchar2(255),
		localpath varchar2(255),
		remotepath varchar2(255),
		status varchar2(255)
	);



	The following files were extracted:
	<table border>
		<tr>
			<th>Filename</th>
			<th>KB</th>
			<th>Status</th>
		</tr>
	<cfloop query="dir">
		<cfset s=round(size/1024)>
		<tr>
			<td>#name#</td>
			<td>#s#</td>
			<td>
				<cfif type is "File" and
					listlen(name,".") is 2 and
					listfindnocase(goodExtensions,listlast(name,".")) and
					left(name,1) is not "_" and
					left(name,1) is not "." and
					REfind("[^A-Za-z0-9_]",listgetat(name,1,".")) eq 0>
					Acceptable - processing
				<cfelse>
					Unacceptable - DELETING....
					<cfif type is "file">
				 		<cffile action="DELETE" file="#sandboxdir#/#name#">
					<cfelse>
						<cfdirectory action="DELETE" recurse="true" directory="#sandboxdir#/#name#">
					</cfif>
					deleted
				</cfif>
			</td>
		</tr>
	</cfloop>
	</table>
	You can now <a href="uploadMedia.cfm?action=thumb">create thumbnails</a>, or skip to
	<a href="uploadMedia.cfm?action=webserver">moving your files to the webserver</a> if you don't need thumbs.
	<p>
		Rename and reload if anything useful was deleted above.
	</p>
	</cfoutput>
	---->
</cfif>
<!---------------------------------------------------------------------------->
<cfif action is "thumb">
	<cfdirectory action="LIST" directory="#sandboxdir#" name="dir" recurse="yes">
	<cfoutput>
	<cfloop query="dir">
		<cfif listfindnocase(goodExtensions,listlast(name,".")) and left(name,1) is not "_" and left(name,1) is not ".">
			<cfimage action="info" structname="imagetemp" source="#directory#/#name#">
			<cfset x=min(150/imagetemp.width, 113/imagetemp.height)>
			<cfset newwidth = x*imagetemp.width>
			<cfset newheight = x*imagetemp.height>
			<cfimage action="resize" source="#sandboxdir#/#name#" width="#newwidth#" height="#newheight#"
				destination="#sandboxdir#/tn_#name#" overwrite="yes">
		</cfif>
	</cfloop>
	Thumbnails created.
	<a href="uploadMedia.cfm?action=webserver">Continue to move your files to the webserver</a>.
	</cfoutput>
</cfif>
<!---------------------------------------------------------------------------->
<cfif action is "webserver">
	<!----
		we have to do this before we can preview.
		Everything up until this point has happened in the sandbox,
		and users cannot acccess anything in the sandbox directly.
		The steps above should have deleted anything even slightly wonky or dangerous, so
		make a daily directory and rock on.
	---->
<cfoutput>
	<cftry>
		<cfdirectory action="create" directory="#baseFileDir#">
		<cfcatch><!--- exists ---></cfcatch>
	</cftry>
	<cfdirectory action="LIST" directory="#sandboxdir#" name="dir" recurse="no">
	<cfloop query="dir">
		<br>moving #name# to #baseWebDir#/#name#
		<cffile action="move" source="#sandboxdir#/#name#" destination="#baseFileDir#/#name#">
	</cfloop>
	<p>
		<br>Your files are now on the webserver.
		<br><a href="uploadMedia.cfm?action=preview">Preview them here</a>.
		<br>If the above looks wrong, you can <a href="uploadMedia.cfm?action=deleteTodayDir">delete your #dateformat(now(),'yyyy-mm-dd')# directory</a>
		from the webserver. CAUTION: This deletes EVERYTHING you've loaded today.
	</p>
</cfoutput>
</cfif>
<!---------------------------------------------------------------------------->
<cfif action is "preview">
	<cfoutput>
		<p>
			NOTE: This lists everything from your today-directory. You may need to delete or ignore some stuff.
		</p>
		<p>
			Click on a few links and make sure everything looks OK before proceeding.
		</p>
		<p>
			If things are wonky, you can
			<a href="uploadMedia.cfm?action=deleteTodayDir">delete your #dateformat(now(),'yyyy-mm-dd')# directory</a>
		</p>
		<p>
			If things are less-wonky, you can
			<a href="uploadMedia.cfm?action=getBLTemp">download a bulkloader template</a>.
			If you've loaded multiple batches today the template will contain them all; you may have to delete some stuff.
		</p>
		<p>
			Re-load the template to create Media at <a href="/tools/BulkloadMedia.cfm">BulkloadMedia</a>
		</p>
		<cfdirectory action="LIST" directory="#baseFileDir#" name="dir" recurse="yes">
		<table border>
			<tr>
				<td>thumb</td>
				<td>image URL</td>
			</tr>
			<cfloop query="dir">
				<cfif left(name,3) is not "tn_">
					<cfquery name="thumb" dbtype="query">
						select * from dir where name='tn_#name#'
					</cfquery>
					<tr>
						<td>
							<cfif thumb.recordcount gt 0>
								<img src="#baseWebDir#/#thumb.name#">
							<cfelse>
								NO THUMBNAIL
							</cfif>
						</td>
						<td>
							<a href="#baseWebDir#/#name#" target="_blank">#baseWebDir#/#name#</a>
						</td>
					</tr>
				</cfif>
			</cfloop>
		</table>
	</cfoutput>
</cfif>
<!---------------------------------------------------------------------------->
<cfif action is "getBLTemp">
	<cfdirectory action="LIST" directory="#baseFileDir#" name="dir">


	<cfset header="MEDIA_URI,MIME_TYPE,MEDIA_TYPE,PREVIEW_URI,media_license">



	<cfloop from="1" to="10" index="i">
		<cfset header=listappend(header,"media_label_#i#")>
		<cfset header=listappend(header,"media_label_value_#i#")>
	</cfloop>
	<cfloop from="1" to="5" index="i">
		<cfset header=listappend(header,"media_relationship_#i#")>
		<cfset header=listappend(header,"media_related_key_#i#")>
		<cfset header=listappend(header,"media_related_term_#i#")>
	</cfloop>
	<!--- create a string containing a blank for each of:
				10 labels
				10 label values
				5 relationships
				5 relationship terms
				5 relationship keys
			append it to the data from the files below
	---->
	<cfset blanks="">
	<cfloop from="1" to="35" index="i">
		<cfset blanks=blanks & ',""'>
	</cfloop>

	<cfset s = createObject("java","java.lang.StringBuilder")>
	<cfset newString = header>
	<cfset s.append(newString)>

	<cfloop query="dir">
		<cfif left(name,3) is not "tn_">
			<cfset mpath="#baseWebDir#/#name#">
			<cfquery name="thumb" dbtype="query">
				select * from dir where name='tn_#name#'
			</cfquery>
			<cfif thumb.recordcount gt 0>
				<cfset thumbpath="#baseWebDir#/#thumb.name#">
			<cfelse>
				<cfset thumbpath="">
			</cfif>
			<cfif listlast(name,'.') is "png">
				<cfset mimetype="image/png">
				<cfset mediatype="image">
			<cfelseif listlast(name,'.') is "jpg" or listlast(name,'.') is "jpeg">
				<cfset mimetype="image/jpeg">
				<cfset mediatype="image">
			<cfelse>
				<cfset mimetype="">
				<cfset mediatype="">
			</cfif>
			<!--- from header above --->
			<cfset thisRow='"#mpath#","#mimetype#","#mediatype#","#thumbpath#",""#blanks#'>
			<cfset s.append(chr(13) & thisRow)>
		</cfif>
	</cfloop>
	<cffile action="write" addnewline="no" file="#Application.webDirectory#/download/BulkMediaTemplate_#session.username#..csv" output="#s.toString()#">
	<cflocation url="/download.cfm?file=BulkMediaTemplate_#session.username#.csv" addtoken="false">
</cfif>
<!---------------------------------------------------------------------------->
<cfif action is "deleteTodayDir">
	<cfdirectory action="LIST" directory="#application.webDirectory#/mediaUploads/#session.username#/#dateformat(now(),'yyyy-mm-dd')#" name="dir" recurse="yes">
	<cfdump var=#dir#>
	<br><a href="uploadMedia.cfm?action=reallyDeleteTodayDir">Seriously, delete everything in the table above!</a>
</cfif>
<!---------------------------------------------------------------------------->
<cfif action is "reallyDeleteTodayDir">
	<cfdirectory action="LIST" directory="#application.webDirectory#/mediaUploads/#session.username#/#dateformat(now(),'yyyy-mm-dd')#" name="dir" recurse="yes">
	<cfloop query="dir">
		<cfset fp="#application.serverRootURL#/mediaUploads/#session.username#/#dateformat(now(),'yyyy-mm-dd')#/#name#">
		<cfquery name="d" datasource="uam_god">
			select count(*) c from media where media_uri='#fp#' or preview_uri='#fp#'
		</cfquery>
		<cfif d.c is not 0>
			<cfoutput>
				<br>#fp# is used in Media and cannot be deleted.
			</cfoutput>
			<cfabort>
		</cfif>
	</cfloop>
	<cfloop query="dir">
		<cfif type is "file">
			<cffile action="DELETE" file="#DIRECTORY#/#name#">
		<cfelse>
			<cfdirectory action="DELETE" recurse="true" directory="#DIRECTORY#/#name#">
		</cfif>
	</cfloop>
	<p>
		All gone. <a href="uploadMedia.cfm">Try again.</a>
	</p>
</cfif>
<cfinclude template="/includes/_footer.cfm">