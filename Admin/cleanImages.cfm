<cfinclude template="/includes/_header.cfm">
<cfsetting requesttimeout="600">

<p>
	Move media from webserver to archives.
</p>

<!----


<p>
	To the great astonishment of absolutely noone, this didn't turn into a nice script. Proceed with caution; aborting.
	<cfabort>
</p>


little cache to speed things along - probably a good idea to delete from this and start over


create table cf_media_migration (path varchar2(4000),status varchar2(255));


alter table cf_media_migration add fullLocalPath  varchar2(4000);
alter table cf_media_migration add fullRemotePath  varchar2(4000);


select * from cf_media_migration where fullRemotePath like 'STILL%';
---->
<cfoutput>

	<!---- weird migration paths... ---->



	<p>
		 <a href="cleanImages.cfm?action=confirmFullRemotePath">confirmFullRemotePath</a>
	</p>
	<p>
		<a href="cleanImages.cfm?action=confirmFullRemotePath2">confirmFullRemotePath2</a>
	</p>
	<p>
		<a href="cleanImages.cfm?action=confirmFullLocalPath">confirmFullLocalPath</a>
	</p>
	<p>
		<a href="cleanImages.cfm?action=checkLocalDir">checkLocalDir</a> to get all local media into the system
	</p>
	<p>
		<a href="cleanImages.cfm?action=checkFileServer">checkFileServer</a> to see what's where
	</p>
	<p>
		<a href="cleanImages.cfm?action=list_not_found">list_not_found</a> to get a list of the things that are NOT on
		Corral. Send this to TACC, ask them to move stuff
	</p>
	<p>
		<a href="cleanImages.cfm?action=find_not_used">find_not_used</a> to mark things that are NOT used in media
	</p>
	<p>
		<a href="cleanImages.cfm?action=update_media_and_delete__dryRun">update_media_and_delete__dryRun</a>: dry run
	</p>
	<p>
		<a href="cleanImages.cfm?action=stash_not_used">stash_not_used</a>
	</p>
	<p>
		<a href="cleanImages.cfm?action=update_media">update_media</a>
	</p>
	<p>
		<a href="cleanImages.cfm?action=ready_delete_flipped">ready_delete_flipped</a>
	</p>


	<p>
		After stuff has been moved, <a href="cleanImages.cfm?action=update_media_and_delete">update_media_and_delete</a>
		to update the media records and delete the local file
	</p>

select status,count(*) from cf_media_migration group by status;





	<cfif action is "ready_delete_flipped">
		<cfquery name="d" datasource="uam_god">
			select path from cf_media_migration where status='media_uris_flipped' and rownum<2000
		</cfquery>

		<cfloop query="d">
			<cftransaction>
			<br>#path#
			<cfset uname=listgetat(path,1,"/")>
			<cfset fname=listlast(path,"/")>
			<!--- dir exists? --->
			<cfif not DirectoryExists("#application.webDirectory#/download/temp_media_movetocorral/#uname#")>
				<!--- make it ---->
				<br>does not exist,making #application.webDirectory#/download/temp_media_movetocorral/#uname#
				<cfset DirectoryCreate("#application.webDirectory#/download/temp_media_movetocorral/#uname#")>
			</cfif>
			<!--- now move --->
			<br>moving #application.webDirectory#/mediaUploads/#path# to #application.webDirectory#/download/temp_media_movetocorral/#uname#/#fname#
			<cffile action = "move" destination = "#application.webDirectory#/download/temp_media_movetocorral/#uname#/#fname#"
				source = "#application.webDirectory#/mediaUploads/#path#">
			<br>moved....
			<cfquery name="ms" datasource="uam_god">
				update cf_media_migration set status='moved_to_junk' where path='#path#'
			</cfquery>
			</cftransaction>
		</cfloop>

	</cfif>




<cfif action is "update_media">
		<!---barf out sql ---->
		<cfquery name="d" datasource="uam_god">
			select * from  cf_media_migration where status='dry_run_happy' and rownum < 2000 order by path
		</cfquery>
		<cfset lclURL=replace(application.serverRootURL,'https://','http://')>
		<cfloop query="d">
			<cftransaction>
				<br>#path#
				<!---- make sure we're using this thing --->
				<cfquery name="mid" datasource="uam_god">
					select media_id from media where replace(media_uri,'https://','http://')='#lclURL#/mediaUploads#path#'
				</cfquery>
				<cfif len(mid.media_id) gt 0>
					<cfset usedas='media_uri'>
				<cfelse>
					<cfquery name="mid" datasource="uam_god">
						select media_id from media where replace(preview_uri,'https://','http://')='#lclURL#/mediaUploads#path#'
					</cfquery>
					<cfif len(mid.media_id) gt 0>
						<cfset usedas='preview_uri'>
					<cfelse>
						<cfset usedas='nothing'>
					</cfif>
				</cfif>
				<cfif usedas is 'nothing'>
					<br>not used!!
					<cfquery name="orp" datasource="uam_god">
						update cf_media_migration set status='found_on_corral_not_used_in_media' where path='#path#'
					</cfquery>
				<cfelse>
					<br>used, rock on....
					<br>media_id: #mid.media_id#
					<br>FULLLOCALPATH: #FULLLOCALPATH#
					<br>FULLREMOTEPATH: #FULLREMOTEPATH#



						<!--- now switcharoo media_uri or preview_uri.... ---->
						<!----
						<cfquery name="upmuri" datasource="uam_god">
							update media set #usedas#='https://web.corral.tacc.utexas.edu/UAF/arctos/mediaUploads#path#'
							where media_id=#mid.media_id#
						</cfquery>
						---->

						<br>update media set #usedas#='#FULLREMOTEPATH#' where media_id=#mid.media_id#
						<cfquery name="upm" datasource="uam_god">
							update media set #usedas#='#FULLREMOTEPATH#' where media_id=#mid.media_id#
						</cfquery>
						<br>update media_flat set #usedas#='#FULLREMOTEPATH#' where media_id=#mid.media_id#
						<cfquery name="upmf" datasource="uam_god">
							update media_flat set #usedas#='#FULLREMOTEPATH#' where media_id=#mid.media_id#
						</cfquery>
						<cfquery name="upmm" datasource="uam_god">
							update cf_media_migration set status='media_uris_flipped' where path='#path#'
						</cfquery>

						<!----  ....and delete the local file ---->
						<br>update cf_media_migration set status='media_uris_flipped' where path='#path#'


						<!----
						<cfquery name="orp" datasource="uam_god">
							update cf_media_migration set status='add_moved_over_ready_to_delete' where path='#path#'
						</cfquery>


						<cfquery name="orp" datasource="uam_god">
							update cf_media_migration set status='dry_run_happy' where path='#path#'
						</cfquery>
						<br>update cf_media_migration set status='dry_run_happy' where path='#path#'
						---->


						<!----
						<cffile action = "delete" file = "#application.webDirectory#/mediaUploads/#path#">
						---->

				</cfif>
			</cftransaction>
		</cfloop>
	</cfif>








	<cfif action is "stash_not_used">
		<cfquery name="d" datasource="uam_god">
			select path from cf_media_migration where status='found_on_corral_not_used_in_media' and rownum<200
		</cfquery>

		<cfloop query="d">
			<cftransaction>
			<br>#path#
			<cfset uname=listgetat(path,1,"/")>
			<cfset fname=listlast(path,"/")>
			<!--- dir exists? --->
			<cfif not DirectoryExists("#application.webDirectory#/download/temp_media_notused/#uname#")>
				<!--- make it ---->
				<br>does not exist,making #application.webDirectory#/download/temp_media_notused/#uname#
				<cfset DirectoryCreate("#application.webDirectory#/download/temp_media_notused/#uname#")>
			</cfif>
			<!--- now move --->
			<br>moving #application.webDirectory#/mediaUploads/#path# to #application.webDirectory#/download/temp_media_notused/#uname#/#fname#
			<cffile action = "move" destination = "#application.webDirectory#/download/temp_media_notused/#uname#/#fname#"
				source = "#application.webDirectory#/mediaUploads/#path#">
			<br>moved....
			<cfquery name="ms" datasource="uam_god">
				update cf_media_migration set status='stashed_as_notused' where path='#path#'
			</cfquery>
			</cftransaction>
		</cfloop>

	</cfif>

	<cfif action is "confirmFullRemotePath2">
		<cfquery name="d" datasource="uam_god">
			select * from cf_media_migration where fullRemotePath like 'STILLNOT %'
		</cfquery>
		<cfloop query="d">
			<cfset rp='http://web.corral.tacc.utexas.edu/UAF/arctos/mediaUploads/20170607/' & listlast(path,'/')>
			<br>#rp#

			<cfhttp method="head" url="#rp#"></cfhttp>
			<cfif cfhttp.statusCode is '200 OK'>
				<cfquery name="fl" datasource="uam_god">
					update cf_media_migration set fullRemotePath='#rp#' where path='#path#'
				</cfquery>
				<br>ishappy
			<cfelse>
				<cfquery name="fl" datasource="uam_god">
					update cf_media_migration set fullRemotePath='ANOTHERMISS #rp#' where path='#path#'
				</cfquery>
				<br>unhappy
			</cfif>
			---------->
		</cfloop>
	</cfif>




	<cfif action is "confirmFullRemotePath">
		<cfquery name="d" datasource="uam_god">
			select * from cf_media_migration where fullRemotePath is null
		</cfquery>
		<cfloop query="d">
			<cfset rp='https://web.corral.tacc.utexas.edu/UAF/arctos/mediaUploads2018/' & #path#>
			<br>#rp#
			<cfhttp method="head" url="#rp#"></cfhttp>
			<cfif cfhttp.statusCode is '200 OK'>
				<cfquery name="fl" datasource="uam_god">
					update cf_media_migration set fullRemotePath='#rp#' where path='#path#'
				</cfquery>
				<br>happy
			<cfelse>
				<cfquery name="fl" datasource="uam_god">
					update cf_media_migration set fullRemotePath='NOT #rp#' where path='#path#'
				</cfquery>
				<br>unhappy
			</cfif>
		</cfloop>
	</cfif>
	<cfif action is "confirmFullLocalPath">
		<cfquery name="d" datasource="uam_god">
			select * from cf_media_migration where fullLocalPath is null
		</cfquery>
		<cfloop query="d">
			<cfset lp=replace(application.serverRootURL,'https://','http://') & '/mediaUploads' & #path#>
			<br>#lp#
			<cfhttp method="head" url="#lp#"></cfhttp>
			<cfif cfhttp.statusCode is '200 OK'>
				<cfquery name="fl" datasource="uam_god">
					update cf_media_migration set fullLocalPath='#lp#' where path='#path#'
				</cfquery>
				<br>happy
			<cfelse>
				<cfdump var=#cfhttp#>
			</cfif>
		</cfloop>
	</cfif>
	<cfif action is "find_not_used">
		<!--- find and flag stuff that's not used. That's it. ---->
		<!---

		update cf_media_migration set status='found_on_corral' where fullRemotePath is not null;

		--->
		<cfquery name="d" datasource="uam_god">
			select * from  cf_media_migration where status='found_on_corral' and rownum < 501 order by path
		</cfquery>
		<cfset lclURL=replace(application.serverRootURL,'https://','http://')>
		<cfloop query="d">
			<cftransaction>
				<br>#path#
				<!---- make sure we're using this thing --->
				<cfquery name="mid" datasource="uam_god">
					select media_id from media where replace(media_uri,'https://','http://')='#lclURL#/mediaUploads#path#'
				</cfquery>
				<cfif len(mid.media_id) gt 0>
					<cfset usedas='media_uri'>
				<cfelse>
					<cfquery name="mid" datasource="uam_god">
						select media_id from media where replace(preview_uri,'https://','http://')='#lclURL#/mediaUploads#path#'
					</cfquery>
					<cfif len(mid.media_id) gt 0>
						<cfset usedas='preview_uri'>
					<cfelse>
						<cfset usedas='nothing'>
					</cfif>
				</cfif>
				<cfif usedas is 'nothing'>
					<br>not used!!
					<cfquery name="orp" datasource="uam_god">
						update cf_media_migration set status='found_on_corral_not_used_in_media' where path='#path#'
					</cfquery>
				<cfelse>
					<cfquery name="orp" datasource="uam_god">
						update cf_media_migration set status='found_on_corral_confirm_used_in_media' where path='#path#'
					</cfquery>
					<br>is used, flag so we can ignore on next loop....
				</cfif>
			</cftransaction>
		</cfloop>
	</cfif>

	<cfif action is "update_media_and_delete__dryRun">
		<!---barf out sql ---->
		<cfquery name="d" datasource="uam_god">
			select * from  cf_media_migration where status='found_on_corral_confirm_used_in_media' and rownum < 2000 order by path
		</cfquery>
		<cfset lclURL=replace(application.serverRootURL,'https://','http://')>
		<cfloop query="d">
			<cftransaction>
				<br>#path#
				<!---- make sure we're using this thing --->
				<cfquery name="mid" datasource="uam_god">
					select media_id from media where replace(media_uri,'https://','http://')='#lclURL#/mediaUploads#path#'
				</cfquery>
				<cfif len(mid.media_id) gt 0>
					<cfset usedas='media_uri'>
				<cfelse>
					<cfquery name="mid" datasource="uam_god">
						select media_id from media where replace(preview_uri,'https://','http://')='#lclURL#/mediaUploads#path#'
					</cfquery>
					<cfif len(mid.media_id) gt 0>
						<cfset usedas='preview_uri'>
					<cfelse>
						<cfset usedas='nothing'>
					</cfif>
				</cfif>
				<cfif usedas is 'nothing'>
					<br>not used!!
					<cfquery name="orp" datasource="uam_god">
						update cf_media_migration set status='found_on_corral_not_used_in_media' where path='#path#'
					</cfquery>
				<cfelse>
					<br>used, rock on....
					<br>media_id: #mid.media_id#
					<br>FULLLOCALPATH: #FULLLOCALPATH#
					<br>FULLREMOTEPATH: #FULLREMOTEPATH#
					<!--- grab a hash for the local file ---->
					<cfinvoke component="/component/functions" method="genMD5" returnVariable="lclHash">
						<cfinvokeargument name="returnFormat" value="plain">
						<cfinvokeargument name="uri" value="#FULLLOCALPATH#">
					</cfinvoke>
					<Cfdump var=#lclHash#>
					<!--- grab a hash for the remote file ---->
					<cfinvoke component="/component/functions" method="genMD5" returnVariable="rmtHash">
						<cfinvokeargument name="returnFormat" value="plain">
						<cfinvokeargument name="uri" value="#FULLREMOTEPATH#">
					</cfinvoke>
					<Cfdump var=#rmtHash#>
					<cfif len(lclHash) gt 0 and len(rmtHash) gt 0 and lclHash eq rmtHash>
						<br>hash match!
						<!--- already got a hash stored with the image?? --->
						<!--- only do this if it's media; not for thumbs ---->

						<cfif  usedas is 'media_uri'>
							<cfquery name="hh" datasource="uam_god">
								select count(*) c from media_labels where MEDIA_ID=#mid.media_id# and media_label='MD5 checksum'
							</cfquery>
							<cfif hh.c is 0>
								<br>insert into media_labels (
									MEDIA_LABEL_ID,
									MEDIA_ID,
									MEDIA_LABEL,
									LABEL_VALUE,
									ASSIGNED_BY_AGENT_ID
								) values (
									sq_MEDIA_LABEL_ID.nextval,
									#mid.media_id#,
									'MD5 checksum',
									'#lclHash#',
									#session.myAgentID#
								)
								<cfquery name="ilbl" datasource="uam_god">
									insert into media_labels (
										MEDIA_LABEL_ID,
										MEDIA_ID,
										MEDIA_LABEL,
										LABEL_VALUE,
										ASSIGNED_BY_AGENT_ID
									) values (
										sq_MEDIA_LABEL_ID.nextval,
										#mid.media_id#,
										'MD5 checksum',
										'#lclHash#',
										#session.myAgentID#
									)
								</cfquery>
							</cfif>
						<cfelse>
							<br>is thumb, no label necessary
						</cfif>
						<!--- now switcharoo media_uri or preview_uri.... ---->
						<!----
						<cfquery name="upmuri" datasource="uam_god">
							update media set #usedas#='https://web.corral.tacc.utexas.edu/UAF/arctos/mediaUploads#path#'
							where media_id=#mid.media_id#
						</cfquery>
						---->
						<br>
						update media set #usedas#='https://web.corral.tacc.utexas.edu/UAF/arctos/mediaUploads#path#'
							where media_id=#mid.media_id#
						<!----  ....and delete the local file ---->
						<br>deleting #application.webDirectory#/mediaUploads/#path#
						<!----
						<cfquery name="orp" datasource="uam_god">
							update cf_media_migration set status='add_moved_over_ready_to_delete' where path='#path#'
						</cfquery>
						---->
						<cfquery name="orp" datasource="uam_god">
							update cf_media_migration set status='dry_run_happy' where path='#path#'
						</cfquery>
						<br>update cf_media_migration set status='dry_run_happy' where path='#path#'

						<!----
						<cffile action = "delete" file = "#application.webDirectory#/mediaUploads/#path#">
						---->
					<cfelse>
						<cfquery name="orp" datasource="uam_god">
							update cf_media_migration set status='found_on_corral_bad_checksum' where path='#path#'
						</cfquery>
						<br>update cf_media_migration set status='found_on_corral_bad_checksum' where path='#path#'
					</cfif>
				</cfif>
			</cftransaction>
		</cfloop>
	</cfif>



	<cfif action is "update_media_and_delete">


	<cfabort>


		<cfquery name="d" datasource="uam_god">
			select * from  cf_media_migration where status='found_on_corral' and rownum < 2 order by path
		</cfquery>
		<cfset lclURL=replace(application.serverRootURL,'https://','http://')>
		<cfloop query="d">
			<cftransaction>
				<br>#path#
				<!---- make sure we're using this thing --->
				<cfquery name="mid" datasource="uam_god">
					select media_id from media where replace(media_uri,'https://','http://')='#lclURL#/mediaUploads#path#'
				</cfquery>
				<cfif len(mid.media_id) gt 0>
					<cfset usedas='media_uri'>
				<cfelse>
					<cfquery name="mid" datasource="uam_god">
						select media_id from media where replace(preview_uri,'https://','http://')='#lclURL#/mediaUploads#path#'
					</cfquery>
					<cfif len(mid.media_id) gt 0>
						<cfset usedas='preview_uri'>
					<cfelse>
						<cfset usedas='nothing'>
					</cfif>
				</cfif>
				<cfif usedas is 'nothing'>
					<br>not used!!
					<cfquery name="orp" datasource="uam_god">
						update cf_media_migration set status='found_on_corral_not_used_in_media' where path='#path#'
					</cfquery>
				<cfelse>
					<br>used, rock on....
					<br>media_id: #mid.media_id#
					<!--- grab a hash for the local file ---->
					<cfinvoke component="/component/functions" method="genMD5" returnVariable="lclHash">
						<cfinvokeargument name="returnFormat" value="plain">
						<cfinvokeargument name="uri" value="#lclURL#/mediaUploads#path#">
					</cfinvoke>
					<Cfdump var=#lclHash#>
					<!--- grab a hash for the remote file ---->
					<cfinvoke component="/component/functions" method="genMD5" returnVariable="rmtHash">
						<cfinvokeargument name="returnFormat" value="plain">
						<cfinvokeargument name="uri" value="http://web.corral.tacc.utexas.edu/UAF/arctos/mediaUploads#path#">
					</cfinvoke>
					<Cfdump var=#rmtHash#>
					<cfif len(lclHash) gt 0 and len(rmtHash) gt 0 and lclHash eq rmtHash>
						<br>hash match!
						<!--- already got a hash stored with the image?? --->
						<cfquery name="hh" datasource="uam_god">
							select count(*) c from media_labels where MEDIA_ID=#mid.media_id# and media_label='MD5 checksum'
						</cfquery>
						<cfdump var=#hh#>
						<cfif hh.c is 0>
							<br>insert into media_labels (
								MEDIA_LABEL_ID,
								MEDIA_ID,
								MEDIA_LABEL,
								LABEL_VALUE,
								ASSIGNED_BY_AGENT_ID
							) values (
								sq_MEDIA_LABEL_ID.nextval,
								#mid.media_id#,
								'MD5 checksum',
								'#lclHash#',
								#session.myAgentID#
							)
							<cfquery name="ilbl" datasource="uam_god">
								insert into media_labels (
									MEDIA_LABEL_ID,
									MEDIA_ID,
									MEDIA_LABEL,
									LABEL_VALUE,
									ASSIGNED_BY_AGENT_ID
								) values (
									sq_MEDIA_LABEL_ID.nextval,
									#mid.media_id#,
									'MD5 checksum',
									'#lclHash#',
									#session.myAgentID#
								)
							</cfquery>

						</cfif>
						<!--- now switcharoo media_uri or preview_uri.... ---->
						<cfquery name="upmuri" datasource="uam_god">
							update media set #usedas#='https://web.corral.tacc.utexas.edu/UAF/arctos/mediaUploads#path#'
							where media_id=#mid.media_id#
						</cfquery>
						<br>
						update media set #usedas#='https://web.corral.tacc.utexas.edu/UAF/arctos/mediaUploads#path#'
							where media_id=#mid.media_id#
						<!----  ....and delete the local file ---->
						<br>deleting #application.webDirectory#/mediaUploads/#path#

						<cfquery name="orp" datasource="uam_god">
							update cf_media_migration set status='add_moved_over_ready_to_delete' where path='#path#'
						</cfquery>
						<!----
						<cffile action = "delete" file = "#application.webDirectory#/mediaUploads/#path#">
						---->
					<cfelse>
						<cfquery name="orp" datasource="uam_god">
							update cf_media_migration set status='found_on_corral_bad_checksum' where path='#path#'
						</cfquery>
						<br>update cf_media_migration set status='found_on_corral_bad_checksum' where path='#path#'
					</cfif>
				</cfif>
			</cftransaction>
		</cfloop>
	</cfif>
	<cfif action is "checkFileServer">
		<!--- get 'new' stuff; list as text. Send this to TACC, request a move ---->
		<cfquery name="d" datasource="uam_god">
			select * from  cf_media_migration where status not like 'found_on_corral%' order by path
		</cfquery>
		<cfloop query="d">
			<br>checking http://web.corral.tacc.utexas.edu/UAF/arctos/mediaUploads#path#
			<cfhttp url='http://web.corral.tacc.utexas.edu/UAF/arctos/mediaUploads#path#' method="head"></cfhttp>
			<cfdump var=#cfhttp.Statuscode#>
			<cfif left(cfhttp.Statuscode,3) is "200">
				<cfset newstatus='found_on_corral'>
			<cfelse>
				<cfset newstatus='not_found_on_corral'>
			</cfif>
			<cfquery name="u" datasource="uam_god">
				update cf_media_migration set status='#newstatus#' where path='#path#'
			</cfquery>
		</cfloop>
	</cfif>
	<cfif action is "list_not_found">
		<!--- get 'new' stuff; list as text. Send this to TACC, request a move ---->
		<cfquery name="found_new" datasource="uam_god">
			select * from  cf_media_migration where status='not_found_on_corral' order by path
		</cfquery>
		<cfloop query="found_new">
			<br>#Application.webDirectory#/mediaUploads#path#
		</cfloop>
	</cfif>

	<cfif action is "checkLocalDir">
		<!--- first make sure we know about everything in the local directory ---->
		<CFDIRECTORY
			ACTION="List"
			DIRECTORY="#Application.webDirectory#/mediaUploads"
			NAME="mediaUploads"
			recurse="yes"
			type="file">
		<cfquery name="cf_media_migration" datasource="uam_god">
			select * from cf_media_migration
		</cfquery>
		<cfloop query="mediaUploads">
			<cfset dirpath="#DIRECTORY#/#name#">
			<br>DIRECTORY: #DIRECTORY#
			<br>name: #name#
			<br>dirpath: #dirpath#
			<cfset basepath=replace(dirpath,"#Application.webDirectory#/mediaUploads",'')>
			<br>basepath: #basepath#
			<cfquery name="alreadygotone" dbtype="query">
				select count(*) c from cf_media_migration where path='#basepath#'
			</cfquery>
			<cfif alreadygotone.c lt 1>
				<br>this is new insert into processing table
				<cfquery name="found_new" datasource="uam_god">
					insert into cf_media_migration (path,status) values ('#basepath#','new')
				</cfquery>
			</cfif>
		</cfloop>
	</cfif>



<!----

		<p>

			<cfquery name="alreadygotone" dbtype="query">
				select count(*) c from cf_media_migration where path='#dirpath#'
			</cfquery>
			<cfif alreadygotone.c gt 0>
				<p>this file is already being processed.....</p>
			<cfelse>
				<p>
					this file is new....inserting into migration workflow
				</p>
					<cfquery name="found_new" datasource="uam_god">
						insert into cf_media_migration (path,status) values (
					</cfquery>





				<br>dirpath: #dirpath#
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

					<!----
					<cffile action = "delete" file = "#DIRECTORY#/#name#">
					---->

				<cfelseif old_media.c is 1 and new_media.c is 0>
					<cfhttp url='#newpath#' method="head"></cfhttp>
					<cfif cfhttp.statuscode is "200 OK">
						<br>update media set media_uri='#newpath#' where media_uri='#olddpath#'

						<!----
						<cfquery name="udm" datasource="uam_god">
							update media set media_uri='#newpath#' where media_uri='#olddpath#'
						</cfquery>
						---->
					<cfelse>

					<!----
						<cfquery name="ss" datasource="uam_god">
							insert into cf_media_migration (path,status) values ('#dirpath#','new_not_found')
						</cfquery>
					----->
						<br>WONKY NEW NOT FOUND!!
					</cfif>
				<cfelseif old_thumb.c is 1 and new_thumb.c is 0>
					<cfhttp url='#newpath#' method="head"></cfhttp>
					<cfif cfhttp.statuscode is "200 OK">
						<br>update media set preview_uri='#newpath#' where preview_uri='#olddpath#'
						<!-----
						<cfquery name="udmp" datasource="uam_god">
							update media set preview_uri='#newpath#' where preview_uri='#olddpath#'
						</cfquery>
						---->
					<cfelse>
						<!----
						<cfquery name="ss" datasource="uam_god">
							insert into cf_media_migration (path,status) values ('#dirpath#','new_not_found')
						</cfquery>
						---->
						<br>WONKY NEW NOT FOUND!!
					</cfif>
				<cfelse>
				<!----
						<cfquery name="ss" datasource="uam_god">
							insert into cf_media_migration (path,status) values ('#dirpath#','not_used')
						</cfquery>
						---->
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
		---------->



</cfoutput>
<cfinclude template="/includes/_footer.cfm">