<cfinclude template = "includes/_header.cfm">
<cfif not isdefined("project_id") or not isnumeric(#project_id#)>
	<p style="color:#FF0000; font-size:14px;">
		Did not get a project ID - aborting....
	</p>
	<cfabort>
</cfif>

<style>
	.proj_title {font-size:2em;font-weight:900;text-align:center;}
	.proj_sponsor {font-size:1.5em;font-weight:800;text-align:center;}
	.proj_agent {font-weight:800;text-align:center;}
	.cdiv {text-align:center;}
</style>
<cfoutput>
	<cfquery name="proj" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		SELECT 
			project.project_id,
			project_name,
			project_description,
			start_date,
			end_date,
			agent_name.agent_name, 
			agent_position,
			project_agent_role,
			ps.agent_name sponsor,
			acknowledgement
		FROM 
			project,
			project_agent,
			agent_name,
			project_sponsor,
			agent_name ps
		WHERE 
			project.project_id = project_agent.project_id AND 
			project_agent.agent_name_id = agent_name.agent_name_id and
			project.project_id=project_sponsor.project_id (+) and
			project_sponsor.agent_name_id=ps.agent_name_id and
			project.project_id = #project_id# 
	</cfquery>
	<cfquery name="p" dbtype="query">
		select 
			project_id,
			project_name,
			project_description,
			start_date,
			end_date
		from
			proj
		group by
			project_id,
			project_name,
			project_description,
			start_date,
			end_date
	</cfquery>
	<cfquery name="a" dbtype="query">
		select
			agent_name,
			project_agent_role
		from 
			proj
		group by
			agent_name,
			project_agent_role
		order by 
			agent_position
	</cfquery>
	<cfquery name="s" dbtype="query">
		select 
			sponsor,
			acknowledgement
		from
			proj
		where
			sponsor is not null
		group by			
			sponsor,
			acknowledgement
	</cfquery>
	<cfset title = "Project Detail: #p.project_name#">
	<div class="proj_title">#p.project_name#</div>
	<cfloop query="s">
		<div class="proj_sponsor">
			Sponsored by #sponsor# <cfif len(ACKNOWLEDGEMENT) gt 0>: #ACKNOWLEDGEMENT#</cfif>
		</div>
	</cfloop>
	<cfloop query="a">
		<div class="proj_agent">
			#agent_name#: #project_agent_role#
		</div>
	</cfloop>
	<div class="cdiv">
		#dateformat(p.start_date,"dd mmmm yyyy")# - #dateformat(p.end_date,"dd mmmm yyyy")#
	</div>
	<h2>Publications</h2>
	<cfquery name="pubs" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		SELECT 
			formatted_publication.publication_id,
			formatted_publication, 
			DESCRIPTION,
			LINK
		FROM 
			project_publication,
			formatted_publication,
			publication_url
		WHERE 
			project_publication.publication_id = formatted_publication.publication_id AND
			project_publication.publication_id = publication_url.publication_id (+) AND
			format_style = 'full citation' and
			project_publication.project_id = #p.project_id#
		order by
			formatted_publication
	</cfquery>
	<cfquery name="pub" dbtype="query">
		select
			formatted_publication,
			publication_id
		from
			pubs
		group by 
			formatted_publication,
			publication_id
		order by
			formatted_publication
	</cfquery>
	<cfif pub.recordcount is 0>
		<div class="notFound">
			No publications matched your criteria.
		</div>
	<cfelse>
		<cfset i=1>
		<cfloop query="pub">
			<div #iif(i MOD 2,DE("class='evenRow'"),DE("class='oddRow'"))#>
				<p class="indent">
					#formatted_publication#
				</p>
				<a href="/PublicationResults.cfm?publication_id=#publication_id#">Details</a>
				&nbsp;~&nbsp;
				<a href="/SpecimenResults.cfm?publication_id=#publication_id#">Cited Specimens</a>
				<cfquery name="links" dbtype="query">
					select description,
					link from pubs
					where publication_id=#publication_id#
				</cfquery>
				<cfif len(#links.description#) gt 0>
					<ul>
						<cfloop query="links">
							<li><a href="#link#" target="_blank">#description#</a></li>
						</cfloop>
					</ul>
				</cfif>			
			</div>
		</cfloop>
	</cfif>
</cfoutput>


<hr>

		
		
		

	<cfif #Action# is "viewUser">
		<cfquery name="getUsers" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			SELECT project.project_id,project_name FROM project,
			project_agent,agent_name WHERE project.project_id = project_agent.project_id AND
			 project_agent.agent_name_id = agent_name.agent_name_id AND project.project_id 
			 IN (SELECT project_trans.project_id FROM project, project_trans, 
			 loan_item, cataloged_item 
			 where project_trans.transaction_id = loan_item.transaction_id AND 
			 loan_item.collection_object_id = cataloged_item.collection_object_id AND 
			 project_trans.project_id = project.project_id AND cataloged_item.collection_object_id 
			 IN 
			 (SELECT cataloged_item.collection_object_id FROM project,project_trans,accn,cataloged_item 
			 WHERE accn.transaction_id = cataloged_item.accn_id AND 
			 project_trans.transaction_id = accn.transaction_id AND 
			 project_trans.project_id = project.project_id AND 
			 project.project_id = #project_id#))  
			 ORDER BY project_name,project_id,agent_position
</cfquery>
		<cfif getUsers.recordcount is 0>
			No projects have used specimens contributed by this project.
		<cfelse>
			The following projects have contributed specimens. 
				Click the title to open that project in a new window.<br>
			<ul>
			<cfoutput query="getUsers" group="project_id">
				<li><a href="ProjectDetail.cfm?project_id=#project_id#">#project_name#</a></li>
			</cfoutput>
			</ul>
		</cfif>
		
	</cfif>
	<cfif #Action# is "viewUsed"><!---Specimens Used--->
		<!--- get specimen parts --->
		<cfquery name="getUsedParts" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			SELECT 
				cat_num, cataloged_item.collection_object_id
			FROM 
				cataloged_item,
				specimen_part,
				loan_item,
				project_trans
			WHERE
				specimen_part.derived_from_cat_item = cataloged_item.collection_object_id
				AND specimen_part.collection_object_id = loan_item.collection_object_id AND
				loan_item.transaction_id = project_trans.transaction_id AND
				project_trans.project_id = #project_id#	
		</cfquery>
		<!--- get specimen tissues --->
		<!---
		<cfquery name="getUsedTiss" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			SELECT 
				cat_num, cataloged_item.collection_object_id
			FROM 
				cataloged_item,
				tissue_sample,
				loan_item,
				project_trans
			WHERE
				tissue_sample.derived_from_biol_indiv = cataloged_item.collection_object_id
				AND tissue_sample.collection_object_id = loan_item.collection_object_id AND
				loan_item.transaction_id = project_trans.transaction_id AND
				project_trans.project_id = #project_id#	
		</cfquery>
		--->
		<!--- get cataloged items that have been loaned --->
		<cfquery name="getUsedSpecs" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			SELECT 
				cat_num, loan_item.collection_object_id
			FROM 
				cataloged_item,
				loan_item,
				project_trans
			WHERE
				cataloged_item.collection_object_id = loan_item.collection_object_id AND
				loan_item.transaction_id = project_trans.transaction_id AND
				project_trans.project_id = #project_id#
		</cfquery>
		
			
			<cfset collObjIds = "">
			<cfloop query="getUsedParts">
				<cfif len(#collObjIds#) is 0>
					<cfset collObjIds = "#getUsedParts.collection_object_id#">
				  <cfelse>
				  	<cfset collObjIds = "#collObjIds#,#getUsedParts.collection_object_id#">
				</cfif>
			</cfloop>
			
			<cfloop query="getUsedSpecs">
				<cfif len(#collObjIds#) is 0>
					<cfset collObjIds = "#getUsedSpecs.collection_object_id#">
				  <cfelse>
				  	<cfset collObjIds = "#collObjIds#,#getUsedSpecs.collection_object_id#">
				</cfif>
			</cfloop>
			
			
			
		<cfset numItems = getUsedSpecs.recordcount +  getUsedParts.recordcount>
		<cfoutput>
			<cfif #numItems# gt 0>
				This project used <cfoutput>#numItems#</cfoutput> specimens. 
				<form action="SpecimenResults.cfm" method="post" >
				<input type="submit" value="View Specimen Details" class="lnkBtn"
   onmouseover="this.className='lnkBtn btnhov'" onmouseout="this.className='lnkBtn'">	
   
   
				
				<input type="hidden" name="collection_object_id" value="#collObjIds#">
				
				<input type="hidden" name="newQuery" value="1">
				<input type="hidden" name="displayRows" value="10"> <!--- just show them 10 rows --->
				</form>
				
			<cfelse>This project used no specimens.<br>
			</cfif>
		</cfoutput>
	</cfif>
		<cfif #Action# is "viewCont">
		
			<cfquery name="getContributors" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
				SELECT project.project_id,project_name,start_date,end_date,agent_name,project_agent_role 
				FROM project,project_agent,agent_name WHERE project.project_id = project_agent.project_id AND
				project_agent.agent_name_id = agent_name.agent_name_id AND project.project_id IN 
				(SELECT project_trans.project_id FROM project, project_trans, accn, cataloged_item 
				where project_trans.transaction_id = accn.transaction_id AND 
				accn.transaction_id = cataloged_item.accn_id 
				AND project_trans.project_id = project.project_id 
				AND cataloged_item.collection_object_id IN 
				(
				SELECT cataloged_item.collection_object_id 
				FROM project,project_trans,loan_item,cataloged_item 
				WHERE loan_item.collection_object_id = cataloged_item.collection_object_id AND
				project_trans.transaction_id = loan_item.transaction_id AND 
				project_trans.project_id = project.project_id AND project.project_id = #project_id#
				UNION
				SELECT 
					cataloged_item.collection_object_id 
				FROM 
					project,
					project_trans,
					loan_item,
					specimen_part,
					cataloged_item 
				WHERE 
					loan_item.collection_object_id = specimen_part.collection_object_id AND
					specimen_part.derived_from_cat_item = cataloged_item.collection_object_id AND
				project_trans.transaction_id = loan_item.transaction_id AND 
				project_trans.project_id = project.project_id AND project.project_id = #project_id#))  
				ORDER BY project_name,project_id,agent_position
		</cfquery>
			<cfif getContributors.recordcount gt 0>
			<cfquery name="contCnt" dbtype="query">
				select distinct(project_id) from getContributors
			</cfquery>
				<cfoutput>
					#contCnt.recordcount# projects contributed specimens used by
					this project. <br>
				</cfoutput>
				<ul>
				<cfoutput query="getContributors" group="project_id">
					<li><a href="ProjectDetail.cfm?project_id=#project_id#">#project_name#</a></li>
				</cfoutput>
				</ul>
			<cfelse>No projects contributed specimens used by this project.<br>
			</cfif>
			
	</cfif>
	<cfif #Action# is "viewSpec">
		<cfquery name="getContSpecs" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			SELECT 
				cat_num,cataloged_item.collection_object_id 
			FROM 
				project,project_trans,accn,cataloged_item
			WHERE 
				accn.transaction_id = cataloged_item.accn_id AND 
				project_trans.transaction_id = accn.transaction_id AND 
				project.project_id = project_trans.project_id AND 
				project.project_id = #project_id#
		</cfquery>
			<cfif getContSpecs.recordcount gt 0>
				<cflocation url="SpecimenResults.cfm?project_id=#project_id#">
			<cfelse>
				This project contributed no specimens.<br>
			</cfif>
		
	</cfif>
	
	</td>
  </tr>
</table>
<cf_log cnt=1 coll=na>	 
<cfinclude template = "includes/_footer.cfm">
