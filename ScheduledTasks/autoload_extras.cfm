<!---
	deal with "data entry extras" marked "autoload"

	just run until we finish or time out



---->
<cfoutput>
		<cfset components = CreateObject("component","component.components")>

	<cfquery name="d" datasource="uam_god">
		select
			cf_temp_specevent.key,
			flat.guid
		from
			cf_temp_specevent,
			flat,
			coll_obj_other_id_num
		where
			coll_obj_other_id_num.OTHER_ID_TYPE='UUID' and
			coll_obj_other_id_num.COLLECTION_OBJECT_ID=flat.COLLECTION_OBJECT_ID and
			coll_obj_other_id_num.DISPLAY_VALUE=cf_temp_specevent.UUID and
			cf_temp_specevent.status='autoload' and
			cf_temp_specevent.guid is null
	</cfquery>
	<cfloop query="d">
		<cfquery name="ud" datasource="uam_god">
			update cf_temp_specevent set guid='#d.guid#' where key=#d.key#
		</cfquery>
	</cfloop>
	<cfquery name="d2" datasource="uam_god">
		select
			*
		from
			cf_temp_specevent
		where
			cf_temp_specevent.status='autoload' and
			cf_temp_specevent.guid is not null
	</cfquery>
	<cfdump var=#d2#>


	<cfloop query="d2">
		<cfquery name="thisRow" dbtype="query">
			select * from d2 where [key] = #d2.key#
		</cfquery>
		<cfset x=components.validateSpecimenEvent(thisRow)>
		<cfdump var=#x#>

		<cfquery name="ud" datasource="uam_god">
			update cf_temp_specevent set
				key=key
				<cfif isdefined("x.problems") and len(x.problems) gt 0>
					,status='autoload:#x.problems#'
				</cfif>
				<cfif isdefined("x.collection_object_id") and len(x.collection_object_id) gt 0>
					,l_collection_object_id=#x.collection_object_id#
				</cfif>
				<cfif isdefined("x.agent_id") and len(x.agent_id) gt 0>
					,l_event_assigned_id=#x.agent_id#
				</cfif>
			where
				key=#x.key#
		</cfquery>
	</cfloop>

	<cfquery name="d3" datasource="uam_god">
		select * from
			cf_temp_specevent
		where
			cf_temp_specevent.status='autoload:precheck_pass' and
			cf_temp_specevent.guid is not null
	</cfquery>
		<cfdump var=#d3#>
	<cfloop query="d3">
		<cfquery name="thisRow" dbtype="query">
			select * from d3 where [key] = #d3.key#
		</cfquery>
		<cfset x=components.createSpecimenEvent(thisRow)>
		<cfdump var=#x#>
		<cfquery name="ud" datasource="uam_god">
			update cf_temp_specevent set
				status='autoload:#x.status#'
			where
				key=#x.key#
		</cfquery>
	</cfloop>
</cfoutput>



	<!--------
	<cfif isdefined("cf_temp_specevent_key") and len(cf_temp_specevent_key) gt 0>
		<cfquery name="cf_temp_specevent" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			update cf_temp_specevent set status='autoload' where key in (#ListQualify(cf_temp_specevent_key, "'")#)
		</cfquery>
	</cfif>

	<cfif isdefined("cf_temp_parts_key") and len(cf_temp_parts_key) gt 0>
		<cfquery name="cf_temp_parts" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			update cf_temp_parts set status='autoload' where key in (#ListQualify(cf_temp_parts_key, "'")#)
		</cfquery>
	</cfif>


	<cfif isdefined("cf_temp_attributes_key") and len(cf_temp_attributes_key) gt 0>
		<cfquery name="cf_temp_attributes" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			update cf_temp_attributes set status='autoload' where key in (#ListQualify(cf_temp_attributes_key, "'")#)
		</cfquery>
	</cfif>


	<cfif isdefined("cf_temp_oids_key") and len(cf_temp_oids_key) gt 0>
		<cfquery name="cf_temp_oids" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			update cf_temp_oids set status='autoload' where key in (#ListQualify(cf_temp_oids_key, "'")#)
		</cfquery>
	</cfif>

	<cfif isdefined("cf_temp_collector_key") and len(cf_temp_collector_key) gt 0>
		<cfquery name="cf_temp_collector" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			update cf_temp_collector set status='autoload' where key in (#ListQualify(cf_temp_collector_key, "'")#)
		</cfquery>
	</cfif>
	---------->
