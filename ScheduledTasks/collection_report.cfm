<cfinclude template="/includes/_header.cfm">
<script src="/includes/sorttable.js"></script>
<cfset title="collection contact report">
<style>
	.hasNoContact{color:red;}
</style>

<cfset summary=querynew("u","p","s")>
<cfoutput>
	<cfsavecontent variable="details">

	<cfquery name="coln" datasource="uam_god">
		select guid_prefix, collection_id from collection where upper(guid_prefix)='#ucase(guid_prefix)#'
	</cfquery>
	<cfif coln.recordcount neq 1>
		collection not found<cfabort>
	</cfif>
	<cfquery name="users" datasource="uam_god">
		select
			agent.agent_id,
			grantee username,
			agent.preferred_agent_name
		from
			dba_role_privs,
			agent_name,
			agent
		where
			upper(dba_role_privs.granted_role) = upper(replace('#guid_prefix#',':','_')) and
			upper(dba_role_privs.grantee) = upper(agent_name.agent_name) and
			agent_name.agent_name_type='login' and
			agent_name.agent_id=agent.agent_id
		order by
			agent.preferred_agent_name
	</cfquery>

	<p>
		User report for collection #coln.guid_prefix#
	</p>

	<cfloop query="users">
		<cfquery name="acts" datasource="uam_god">
			select account_status FROM dba_users where username='#users.username#'
		</cfquery>

		<cfset queryaddrow(summary,
			{u=users.username,
			p=users.preferred_agent_name,
			s=acts.account_status}
		)>



		<hr>
		<br>Preferred Name: #users.preferred_agent_name#
		<br>Username: #users.username# (Account Status: #acts.account_status#)
		<cfquery name="cct" datasource="uam_god">
			select * from collection_contacts where CONTACT_AGENT_ID=#users.agent_id#  and
			collection_contacts.collection_id=#coln.collection_id#
			order by CONTACT_ROLE
		</cfquery>
		<cfloop query="cct">
			<br>Collection Contact Role: #cct.CONTACT_ROLE#
		</cfloop>
		<cfquery name="addr" datasource="uam_god">
			select * from address where agent_id=#users.agent_id#
		</cfquery>
		<cfloop query="addr">
			<br>#replace(ADDRESS_TYPE,chr(10),"<br>","all")#: #ADDRESS# (<cfif VALID_ADDR_FG is 1>valid<cfelse>not valid</cfif>)
		</cfloop>
		<cfquery name="role" datasource="uam_god">
			select
				granted_role
			from
				dba_role_privs
			where
				upper(grantee) = '#users.username#'
				and granted_role not in (select upper(replace(guid_prefix,':','_')) from collection)
				order by granted_role
		</cfquery>
		<p>Roles</p>
		<ul>
			<cfloop query="role">
				<li>#granted_role#</li>
			</cfloop>
		</ul>
	</cfloop>
	</cfsavecontent>
	Summary

	<cfdump var=#summary#>

	<!----
	<table border>
		<tr>
			<th>Username</th>
			<th>Preferred Name</th>
			<th>Account Status</th>
		</tr>
		<cfloop query="summary">
			<tr>
				<td>#u#</td>
				<td>#p#</td>
				<td>#s#</td>
			</tr>
		</cfloop>
	</table>
	---->
	<p></p>
	#details#


<!----

select
					granted_role role_name
				from
					dba_role_privs,
					collection
				where
					upper(dba_role_privs.granted_role) = upper(replace(collection.guid_prefix,':','_')) and
					upper(grantee) = '#ucasename#'




	<cfquery name="c" datasource="uam_god">
		select
			collection.guid_prefix,
			collection.collection_id,
			collection_contacts.CONTACT_ROLE,
			getPreferredAgentName(collection_contacts.CONTACT_AGENT_ID) contactName,
			get_address(collection_contacts.contact_agent_id,'email',1) activeEmail,
			get_address(collection_contacts.contact_agent_id,'email',0) allEmail
		from
			collection,
			collection_contacts
		where
			collection.guid_prefix='UAM:Mamm' and
			collection.collection_id=collection_contacts.collection_id (+)
		order by
			collection.guid_prefix,
			collection_contacts.CONTACT_ROLE,
			getPreferredAgentName(collection_contacts.CONTACT_AGENT_ID)
	</cfquery>
	<p>
		<ul>
			<li><strong>Email</strong> is email address attached to agent record</li>
			<li>
				<strong>Active Email</strong> is valid email address attached to agent record of active Operator. This is generally
				the only address used when sending notifications to collection contacts.
			</li>
		</ul>
	</p>

	<table border id="t" class="sortable">
		<tr>
			<th>Collection</th>
			<th>Contact</th>
			<th>Role</th>
			<th>Email</th>
			<th>Active Email</th>
		</tr>
		<cfloop query="c">
			<tr>

				<td>
					#c.guid_prefix#
					<cfquery name="hasDQ" dbtype="query">
						select count(*) c from c where guid_prefix='#guid_prefix#' and activeEmail is not null
						and CONTACT_ROLE='data quality'
					</cfquery>
					<cfif hasDQ.c lt 1>
						<div class="hasNoContact">
							no active data quality contact
						</div>
					</cfif>
					<cfquery name="hasLR" dbtype="query">
						select count(*) c from c where guid_prefix='#guid_prefix#' and activeEmail is not null
						and CONTACT_ROLE='loan request'
					</cfquery>
					<cfif hasLR.c lt 1>
						<div class="hasNoContact">
							no active loan request contact
						</div>
					</cfif>
					<cfquery name="hasTS" dbtype="query">
						select count(*) c from c where guid_prefix='#guid_prefix#' and activeEmail is not null
						and CONTACT_ROLE='technical support'
					</cfquery>
					<cfif hasTS.c lt 1>
						<div class="hasNoContact">
							no active technical support contact
						</div>
					</cfif>
				</td>
				<td>#c.contactName#</td>
				<td>#c.CONTACT_ROLE#</td>
				<td>#c.allEmail#</td>
				<td>#c.activeEmail#</td>

			</tr>
		</cfloop>
	</table>
	--->
	</cfoutput>
<cfinclude template="/includes/_footer.cfm">
