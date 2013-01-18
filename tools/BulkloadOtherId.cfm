<cfsetting requesttimeout="600">

<cfinclude template="/includes/_header.cfm">
<!---- make the table

drop table cf_temp_oids;
drop public synonym cf_temp_oids;

create table cf_temp_oids (
	key number,
	collection_object_id number,
	guid_prefix varchar2(20),
	existing_other_id_type varchar2(60),
	existing_other_id_number varchar2(60),
	new_other_id_type varchar2(60),
	new_other_id_number varchar2(60),
	new_other_id_references varchar2(60)
	);

	create public synonym cf_temp_oids for cf_temp_oids;
	grant select,insert,update,delete on cf_temp_oids to uam_query,uam_update;

	 CREATE OR REPLACE TRIGGER cf_temp_oids_key
 before insert  ON cf_temp_oids
 for each row
    begin
    	if :NEW.key is null then
    		select somerandomsequence.nextval into :new.key from dual;
    	end if;
    end;
/
sho err

alter table cf_temp_oids add status varchar2(4000);

------>
<cfif action is "template">
	<cfoutput>
		<cfset d="guid_prefix,EXISTING_OTHER_ID_TYPE,EXISTING_OTHER_ID_NUMBER,NEW_OTHER_ID_TYPE,NEW_OTHER_ID_NUMBER,NEW_OTHER_ID_REFERENCES">
		<cfset variables.encoding="UTF-8">
		<cfset variables.fileName="#Application.webDirectory#/download/BulkloadOtherId.csv">
		<cfscript>
			variables.joFileWriter = createObject('Component', '/component.FileWriter').init(variables.fileName, variables.encoding, 32768);
			variables.joFileWriter.writeLine(d);
			variables.joFileWriter.close();
		</cfscript>
		<cflocation url="/download.cfm?file=BulkloadOtherId.csv" addtoken="false">
		<a href="/download/BulkloadOtherId.csv">Click here if your file does not automatically download.</a>
	</cfoutput>
</cfif>
<cfif action is "nothing">
Step 1: Upload a comma-delimited text file (csv). <a href="BulkloadOtherId.cfm?action=template">get a template here</a>
Include column headings, spelled exactly as below.
<br><span class="likeLink" onclick="document.getElementById('template').style.display='block';">view template</span>
	<div id="template" style="display:none;">
		<label for="t">Copy the following code and save as a .csv file</label>
		<textarea rows="2" cols="80" id="t">COLLECTION_CDE,INSTITUTION_ACRONYM,EXISTING_OTHER_ID_TYPE,EXISTING_OTHER_ID_NUMBER,NEW_OTHER_ID_TYPE,NEW_OTHER_ID_NUMBER</textarea>
	</div>
<p></p>

<table border>
	<tr>
		<th>Column</th>
		<th>Required</th>
		<th>ExampleData</th>
		<th>Wutsitdo</th>
	</tr>
	<tr>
		<td>guid_prefix</td>
		<td>yes</td>
		<td>UAM:Mamm - UAMObs:Mamm</td>
		<td>
			guid_prefix from manage collection; identifies the collection which owns the specimen
			to which the other ID is being attached. Usually a concatenation of institution_acronym and
			collection_cde
		</td>
	</tr>
	<tr>
		<td>existing_other_id_type</td>
		<td>yes</td>
		<td>
			"catalog number" or OTHER_ID_TYPE from <a href="/info/ctDocumentation.cfm?table=CTCOLL_OTHER_ID_TYPE">CTCOLL_OTHER_ID_TYPE</a>
		</td>
		<td>
			used to find the specimen; in conjunction with existing_other_id_number, must resolve to exactly one cataloged item
		</td>
	</tr>
	<tr>
		<td>new_other_id_number</td>
		<td>yes</td>
		<td>
			catalog number when existing_other_id_type is "catalog number", or value corresponding to
			existing_other_id_type
		</td>
		<td>
			used to find the specimen; in conjunction with existing_other_id_type, must resolve to exactly one cataloged item
		</td>
	</tr>
	<tr>
		<td>new_other_id_type</td>
		<td>yes</td>
		<td>
			OTHER_ID_TYPE from <a href="/info/ctDocumentation.cfm?table=CTCOLL_OTHER_ID_TYPE">CTCOLL_OTHER_ID_TYPE</a>
		</td>
		<td>
			type of identifier to add
		</td>
	</tr>
	<tr>
		<td>new_other_id_number</td>
		<td>yes</td>
		<td>
			-
		</td>
		<td>
			Value of new identifier
		</td>
	</tr>
	<tr>
		<td>new_other_id_references</td>
		<td>no</td>
		<td>
			ID_REFERENCES from <a href="/info/ctDocumentation.cfm?table=CTID_REFERENCES">CTID_REFERENCES</a>
		</td>
		<td>
			Used when the other ID references another data object, such as a host's catalog number if existing specimen is a parasite. Creates relationships.
			leave blank or use "self" when the ID references this specimen (such as when loading GenBank numbers)
		</td>
	</tr>
</table>




<cfform name="oids" method="post" enctype="multipart/form-data">
			<input type="hidden" name="Action" value="getFile">
			  <input type="file"
		   name="FiletoUpload"
		   size="45" onchange="checkCSV(this);">
			  <input type="submit" value="Upload this file">
  </cfform>

</cfif>
<!------------------------------------------------------->
<cfif #action# is "getFile">
<cfoutput>
	<!--- put this in a temp table --->
	<cfquery name="killOld" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		delete from cf_temp_oids
	</cfquery>
	<cffile action="READ" file="#FiletoUpload#" variable="fileContent">
	<cfset fileContent=replace(fileContent,"'","''","all")>
	<cfset arrResult = CSVToArray(CSV = fileContent.Trim()) />
	<cfset colNames="">
	<cfloop from="1" to ="#ArrayLen(arrResult)#" index="o">
		<cfset colVals="">
			<cfloop from="1"  to ="#ArrayLen(arrResult[o])#" index="i">
				<cfset thisBit=arrResult[o][i]>
				<cfif #o# is 1>
					<cfset colNames="#colNames#,#thisBit#">
				<cfelse>
					<cfset colVals="#colVals#,'#thisBit#'">
				</cfif>
			</cfloop>
		<cfif #o# is 1>
			<cfset colNames=replace(colNames,",","","first")>
		</cfif>
		<cfif len(#colVals#) gt 1>
			<cfset colVals=replace(colVals,",","","first")>
			<cfquery name="ins" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				insert into cf_temp_oids (#colNames#) values (#preservesinglequotes(colVals)#)
			</cfquery>
		</cfif>
	</cfloop>
	<!----


		<cfset i=1>
	<cfloop index="line" list="#fileContent#" delimiters="#chr(10)#">
		<cfset sql = "">
		<cfset line = #replace(line,'#chr(9)##chr(9)#','#chr(9)#null#chr(9)#','all')#>
		<cfloop index="field" list="#line#" delimiters="#chr(9)#">
			<cfset field = #replace(field,"'","''","all")#>
			<cfset sql = #replace(sql,'{comma}',',','all')#>
			<cfset sql = "#sql#'#trim(replace(field,'"','','all'))#',">

		</cfloop>
	 	<cfset sql = #reverse(replace(reverse(sql),",","","first"))#>
		<cfset sql = "#i#,#sql#">
		<cfset i=#i#+1>
		<cfquery name="newRec" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			INSERT INTO cf_temp_oids (
				key,
				collection_cde,
				institution_acronym,
				existing_other_id_type,
				existing_other_id_number,
				new_other_id_type,
				new_other_id_number
				)
			VALUES (
				#preservesinglequotes(sql)#
				)
			</cfquery>
    </cfloop>
	---->
	<cflocation url="BulkloadOtherId.cfm?action=validate" addtoken="false">
</cfoutput>
</cfif>
<!------------------------------------------------------->
<!------------------------------------------------------->
<cfif #action# is "validate">
<cfoutput>
	<cfquery name="data" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select * from cf_temp_oids
	</cfquery>
	<cfloop query="data">
		<cfset err="">
		<cfif len(existing_other_id_type) is 0>
			<cfset err=listappend(err,"You must specify an other ID type.")>
		</cfif>
		<cfif len(existing_other_id_number) is 0>
			<cfset err=listappend(err,"You must specify an other ID number.")>
		</cfif>
		<cfif len(collection_cde) is 0>
			<cfset err=listappend(err,"You must specify a collection_cde.")>
		</cfif>
		<cfif len(institution_acronym) is 0>
			<cfset err=listappend(err,"You must specify a institution_acronym.")>
		</cfif>
		<cfif len(err) is 0>
			<cfif existing_other_id_type is not "catalog number">
				<cfquery name="collObj" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
					SELECT
						coll_obj_other_id_num.collection_object_id
					FROM
						coll_obj_other_id_num,
						cataloged_item
					WHERE
						coll_obj_other_id_num.collection_object_id = cataloged_item.collection_object_id and
						cataloged_item.collection_id = (
							select collection_id from collection where
							collection.collection_cde = '#collection_cde#' and
							collection.institution_acronym = '#institution_acronym#') and
						other_id_type = '#existing_other_id_type#' and
						display_value = '#existing_other_id_number#'
				</cfquery>
			<cfelse>
				<cfquery name="collObj" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
					SELECT
						collection_object_id
					FROM
						cataloged_item
					WHERE
						cataloged_item.collection_id = (
							select collection_id from collection where
							collection.collection_cde = '#collection_cde#' and
							collection.institution_acronym = '#institution_acronym#') and
						cat_num=#existing_other_id_number#
				</cfquery>
			</cfif>
			<cfif collObj.recordcount is not 1>
				<cfset err=listappend(err,"#data.institution_acronym# #data.collection_cde# #data.existing_other_id_number# #data.existing_other_id_type# could not be found!")>
			</cfif>
		</cfif>
		<cfif len(err) is 0>
			<cfquery name="isValid" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
				select other_id_type from ctcoll_other_id_type where other_id_type = '#new_other_id_type#'
			</cfquery>
			<cfif isValid.recordcount is not 1>
				<cfset err=listappend(err,"Other ID type #new_other_id_type# was not found.")>
			</cfif>
		</cfif>
		<cfif len(err) is 0>
			<cfquery name="insColl" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				UPDATE cf_temp_oids SET collection_object_id = #collObj.collection_object_id# where
				key = #key#
			</cfquery>
		<cfelse>
			<cfquery name="fail" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				update cf_temp_oids set status='#err#' where key=#key#
			</cfquery>
		</cfif>
	</cfloop>
	<cflocation url="BulkloadOtherId.cfm?action=showCheck" addtoken="false">
</cfoutput>
</cfif>




<cfif #action# is "showCheck">
	<cfquery name="data" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select * from cf_temp_oids where status is not null
	</cfquery>
	<cfif data.recordcount gt 0>
		You must fix everything in the table below and reload your file to continue.
		<cfdump var=#data#>
	<cfelse>
		<a href="BulkloadOtherId.cfm?action=loadData">checks out...proceed to load</a>
	</cfif>
</cfif>


<!------------------------------------------------------->
<cfif action is "loadData">

<cfoutput>


	<cfquery name="getTempData" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select * from cf_temp_oids
	</cfquery>

	<cftransaction>
	<cfloop query="getTempData">
		<!---<cfquery name="newID" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		 	{EXEC parse_other_id(#collection_object_id#, '#new_other_id_number#', '#new_other_id_type#')}
		</cfquery>
		--->
		<cfstoredproc procedure="parse_other_id" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">


    <cfprocparam
      cfsqltype="cf_sql_numeric"
      value="#collection_object_id#">

    <cfprocparam
      cfsqltype="cf_sql_varchar"
      value="#new_other_id_number#">
	<cfprocparam
      cfsqltype="cf_sql_varchar"
      value="#new_other_id_type#">

  </cfstoredproc>

	</cfloop>
	</cftransaction>

	Spiffy, all done.
</cfoutput>
</cfif>
<cfinclude template="/includes/_footer.cfm">
