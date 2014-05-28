<cfinclude template="/includes/_header.cfm">
	<cfset title="attribtue search builder thingee">
	<cfoutput>
		<cfquery name="d" datasource="uam_god">
			select ATTRIBUTE_TYPE from ctattribute_type group by ATTRIBUTE_TYPE order by lower(ATTRIBUTE_TYPE)
		</cfquery>
		<cfquery name="fattrorder" datasource="uam_god">
			select max(DISP_ORDER) mdo from ssrch_field_doc
		</cfquery>
		<cfset n=ceiling(fattrorder.mdo) +1>			
		<cfset variables.encoding="UTF-8">
		<cfset variables.f_srch_field_doc="#Application.webDirectory#/download/srch_field_doc.sql">
		<cfset variables.f_ss_doc="#Application.webDirectory#/download/specsrch.txt">
		<cfset x='<!---Autogenerated by /Admin/buildAttributeSearchByNameCode.cfm. Do not manually modify this file.---->' & chr(10)>
		<!---- get all units code tables, plus ass in the stuff we can guess via eg, to_meters function ---->
		<cfset attrunits="M,METERS,METER,FT,FEET,FOOT,KM,KILOMETER,KILOMETERS,MM,MILLIMETER,MILLIMETERS,CM,CENTIMETER,CENTIMETERS,MI,MILE,MILES,YD,YARD,YARDS,FM,FATHOM,FATHOMS">
		<cfquery name="uct" datasource="uam_god">
			select UNITS_CODE_TABLE from ctattribute_code_tables group by UNITS_CODE_TABLE
		 </cfquery>
		 <cfloop query="uct">
		 	<cfquery name="tct" datasource="uam_god">
		 		select * from #UNITS_CODE_TABLE#
		 	</cfquery>
		 	<cfloop list="#tct.columnlist#" index="thecolname">
				<cfif thecolname is not "description" and thecolname is not "collection_cde">
					<cfset ctColName=thecolname>
				</cfif>
			</cfloop>
			<cfquery name="cto" dbtype="query">
				select #ctColName# as thisctvalue from tct group by #ctColName# order by #ctColName#
			</cfquery>
			<cfset attrunits=listappend(attrunits,valuelist(cto.thisctvalue))>
		 </cfloop>
		 #attrunits#
		 
		<cfset x=x&'<cfset attrunits="M,METERS,METER,FT,FEET,FOOT,KM,KILOMETER,KILOMETERS,MM,MILLIMETER,MILLIMETERS,CM,CENTIMETER,CENTIMETERS,MI,MILE,MILES,YD,YARD,YARDS,FM,FATHOM,FATHOMS">'>
		<cfset x=x&'<cfset charattrschops="=,!"><cfset numattrschops="=,!,<,>">'>
		<cfscript>
			variables.josrch_field_doc = createObject('Component', '/component.FileWriter').init(variables.f_srch_field_doc, variables.encoding, 32768);
			variables.josrch_field_doc.writeLine("delete from ssrch_field_doc where CATEGORY='attribute';#chr(10)#");
			variables.f_ss_doc = createObject('Component', '/component.FileWriter').init(variables.f_ss_doc, variables.encoding, 32768);
			variables.f_ss_doc.writeLine(x);
		</cfscript>	
		<cfloop query="d">
			<cfquery name="tctl" datasource="uam_god">
				select 
					CTATTRIBUTE_TYPE.ATTRIBUTE_TYPE,
					CTATTRIBUTE_TYPE.DESCRIPTION,
					ctattribute_code_tables.VALUE_CODE_TABLE,
					ctattribute_code_tables.UNITS_CODE_TABLE 
				from 
					CTATTRIBUTE_TYPE,
					ctattribute_code_tables
				where 
					CTATTRIBUTE_TYPE.ATTRIBUTE_TYPE=ctattribute_code_tables.ATTRIBUTE_TYPE (+) and
					CTATTRIBUTE_TYPE.ATTRIBUTE_TYPE='#ATTRIBUTE_TYPE#'
				group by
					CTATTRIBUTE_TYPE.ATTRIBUTE_TYPE,
					CTATTRIBUTE_TYPE.DESCRIPTION,
					ctattribute_code_tables.VALUE_CODE_TABLE,
					ctattribute_code_tables.UNITS_CODE_TABLE  
			</cfquery>
			<cfset attrvar=lcase(trim(replace(replace(replace(ATTRIBUTE_TYPE,' ','_','all'),'-','_','all'),"/","_","all")))>
			<cfif len(tctl.VALUE_CODE_TABLE) gt 0>
				<cfset srchhint='Search for underbar (_) to require #ATTRIBUTE_TYPE#. Prefix value with "=","<",">","!" (exact, less than, more than, is not). Suffix with appropriate units. "<5mm" or "! 2 years'>
			<cfelse>
				<cfset srchhint='Search for underbar (_) to require #ATTRIBUTE_TYPE#. You may prefix with "=" to require an exact match, or "!" to exclude a value. "=male" matches only male, "male" matches male and fe<strong>male</strong>, "!male" matches everything except male.'>
			</cfif>
<cfset v="insert into ssrch_field_doc (
	CATEGORY,
	CF_VARIABLE,
	CONTROLLED_VOCABULARY,
	DEFINITION,
	DISPLAY_TEXT,
	DOCUMENTATION_LINK,
	PLACEHOLDER_TEXT,
	SEARCH_HINT,
	SQL_ELEMENT,
	SPECIMEN_RESULTS_COL,
	DISP_ORDER,
	SPECIMEN_QUERY_TERM
) values (
	'attribute',
	'#attrvar#',
	'#tctl.VALUE_CODE_TABLE#',
	'#escapeQuotes(tctl.DESCRIPTION)#',
	'#ATTRIBUTE_TYPE#',
	'',
	'#ATTRIBUTE_TYPE#',
	'#srchhint#',
	'concatAttributeValue(flatTableName.collection_object_id,''#ATTRIBUTE_TYPE#'')',
	1,
	#n#,
	1
);
">
			
<cfset n=n+1>
<cfset x='<cfif isdefined("#attrvar#") and len(#attrvar#) gt 0>'>
<cfset x=x & chr(10) & '    <cfset mapurl = "##mapurl##&#attrvar#=###attrvar###">'>
<cfset x=x & chr(10) & '    <cfset basJoin = " ##basJoin## INNER JOIN v_attributes tbl_#attrvar# ON (##session.flatTableName##.collection_object_id = tbl_#attrvar#.collection_object_id)">'>
<cfset x=x & chr(10) & '    <cfset basQual = " ##basQual## AND tbl_#attrvar#.attribute_type = ''#ATTRIBUTE_TYPE#''">'>
<cfset x=x & chr(10) & '    <cfif session.flatTableName is not "flat">'>
<cfset x=x & chr(10) & '        <cfset basQual = " ##basQual## AND tbl_#attrvar#.is_encumbered = 0">'>
<cfset x=x & chr(10) & '    </cfif>'>
<cfset x=x & chr(10) & '    <cfset schunits="">'>
<cfset x=x & chr(10) & '    <cfif #attrvar# neq "_">'>
<cfset x=x & chr(10) & '        <cfset oper=left(#attrvar#,1)>'>
<cfif len(tctl.UNITS_CODE_TABLE) gt 0>
	<cfset x=x & chr(10) & '        <cfif listfind(numattrschops,oper)>'>
<cfelse>
	<cfset x=x & chr(10) & '        <cfif listfind(charattrschops,oper)>'>
</cfif>
<cfset x=x & chr(10) & '            <cfset schTerm=ucase(right(#attrvar#,len(#attrvar#)-1))>'>
<cfset x=x & chr(10) & '        <cfelse>'>
<cfset x=x & chr(10) & '            <cfset oper="like"><cfset schTerm=ucase(#attrvar#)>'>
<cfset x=x & chr(10) & '        </cfif>'>
<cfset x=x & chr(10) & '        <cfif oper is "!"><cfset oper="!="></cfif>'>
<cfif len(tctl.UNITS_CODE_TABLE) gt 0>
	<cfset x=x & chr(10) & '     <cfset temp=trim(rereplace(schTerm,"[0-9]","","all"))>'>    
	<cfset x=x & chr(10) & '     <cfif len(temp) gt 0 and listfindnocase(attrunits,temp) and isnumeric(replace(schTerm,temp,""))>'>  
	<cfset x=x & chr(10) & '         <cfset schTerm=replace(schTerm,temp,"")><cfset schunits=temp>'>  
	<cfset x=x & chr(10) & '     </cfif>'> 
</cfif>
<cfset x=x & chr(10) & '      <cfif len(schunits) gt 0>'>  
<cfset x=x & chr(10) & '         <cfset basQual = " ##basQual## AND to_meters(tbl_#attrvar#.attribute_value,tbl_#attrvar#.attribute_units) ##oper## to_meters(##schTerm##,''##schunits##'')">'>  
<cfset x=x & chr(10) & '     <cfelseif oper is not "like" and len(schunits) is 0>'> 
<cfset x=x & chr(10) & '         <cfset basQual = " ##basQual## AND upper(tbl_#attrvar#.attribute_value) ##oper## ''##escapeQuotes(schTerm)##''">'>  
<cfset x=x & chr(10) & '     <cfelse>'> 
<cfset x=x & chr(10) & '         <cfset basQual = " ##basQual## AND upper(tbl_#attrvar#.attribute_value) like ''%##ucase(escapeQuotes(schTerm))##%''">'>  
<cfset x=x & chr(10) & '     </cfif>'> 
<cfset x=x & chr(10) & '    </cfif>'>
<cfset x=x & chr(10) &  '</cfif>'>
<cfset x=x & chr(10)>
			<cfscript>
				variables.josrch_field_doc.writeLine(v);
				variables.f_ss_doc.writeLine(x);
			</cfscript>
		</cfloop>
		<cfscript>	
			variables.josrch_field_doc.close();
			variables.f_ss_doc.close();
		</cfscript>
		This app just builds text.
		<p>
			Get the SQL to update ssrch_field_doc <a href="/download/srch_field_doc.sql">here</a>
		</p>
		
		<p>
			Get the CFML to build /includes/SearchSql_attributes.cfm <a href="/download/specsrch.txt">here</a>
		</p>
		
			<!--- completely unrelated, but here's a handy time to integerize disp_order.
		
		---->
		<p>To avoid strange fractions and gaps, run this, commit, and then reload this page.</p>
<textarea rows="10" cols="100">
declare 
  n number;
  begin
    n:=1;
    for r in (select disp_order from ssrch_field_doc where DISP_ORDER is not null order by DISP_ORDER) loop
      update ssrch_field_doc set disp_order=n where disp_order=r.disp_order;
      n:=n+1;
    end loop;
end;
/
</textarea>
	</cfoutput>
<cfinclude template="/includes/_footer.cfm">