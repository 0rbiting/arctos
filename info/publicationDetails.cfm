<cfif not isdefined("doi") or len(doi) is 0>
	DOI is required
</cfif>
<cfoutput>
	<cfhttp method="get" url="https://api.crossref.org/v1/works/http://dx.doi.org/#doi#">
		<cfhttpparam type = "header" name = "User-Agent" value = "Arctos (https://arctos.database.museum; mailto:dustymc@gmail.com)">
	</cfhttp>
	<cfif not isjson(cfhttp.Filecontent)>
		invalid return
		<cfdump var=#cfhttp#>
		<cfabort>
	</cfif>

	<cfset x=DeserializeJSON(cfhttp.Filecontent)>

	<cfif structKeyExists(x.message,"title")>
		<cfset tar=x.message["title"]>
		<p>
			Title: #tar[1]#
		</p>
	</cfif>
	<cfif structKeyExists(x.message,"publisher")>
		<cfdump var=#x.message["publisher"]#>
		<!----
		<cfset tar=x.message["publisher"]>
		<p>
			Publisher: #tar[1]#
		</p>
		---->
	</cfif>
	<cfif structKeyExists(x.message,"container-title")>
		<cfset tar=x.message["container-title"]>
		<p>
			Container Title: #tar[1]#
		</p>
	</cfif>
	<cfif structKeyExists(x.message,"issue")>
		<cfset tar=x.message["issue"]>
		<p>
			Issue: #tar[1]#
		</p>
	</cfif>
	<cfif structKeyExists(x.message,"type")>
		<cfset tar=x.message["type"]>
		<p>
			Type: #tar[1]#
		</p>
	</cfif>
	<cfif structKeyExists(x.message,"volume")>
		<cfset tar=x.message["volume"]>
		<p>
			Volume: #tar[1]#
		</p>
	</cfif>
	<cfif structKeyExists(x.message,"page")>
		<cfset tar=x.message["page"]>
		<p>
			Page: #tar[1]#
		</p>
	</cfif>
	<cfif structKeyExists(x.message,"reference-count")>
		<cfset tar=x.message["reference-count"]>
		<p>
			Reference Count: #tar[1]#
		</p>
	</cfif>

	<cfif structKeyExists(x.message,"is-referenced-by-count")>
		<cfset tar=x.message["is-referenced-by-count"]>
		<p>
			Referenced By Count: #tar[1]#
		</p>
	</cfif>


	<p>
		Authors
	</p>
	<cfif structKeyExists(x.message,"author")>
		<cfloop array="#x.message.author#" index="idx">
		    <cfif StructKeyExists(idx, "given")>
				<br>#idx["given"]#
			</cfif>
		    <cfif StructKeyExists(idx, "family")>
				#idx["family"]#
			</cfif>

			<cfif StructKeyExists(idx, "sequence")>
				(#idx["sequence"]#)
			</cfif>

		</cfloop>
	</cfif>





	<cfif structKeyExists(x.message,"reference")>
		<cfdump var=#x.message.reference#>
		<cfloop array="#x.message.reference#" index="idx">
		   <cfdump var="#idx#">
		    <cfset rfs="">
		    <cfif StructKeyExists(idx, "author")>
				<cfset rfs=rfs & idx["author"]>
			</cfif>
		    <cfif StructKeyExists(idx, "year")>
				<cfset rfs=rfs & ' ' & idx["year"] & '. '>
			</cfif>
		   <cfif StructKeyExists(idx, "article-title")>
			   <cfset rfs=rfs & idx["article-title"]>
			<cfelseif StructKeyExists(idx, "volume-title")>
			   <cfset rfs=rfs & idx["volume-title"]>
					journal-title
			</cfif>
		   <cfif StructKeyExists(idx, "doi")>
				<cfset rfs=rfs & '. <a class="external" target="_blank" href="http://dx.doi.org/#idx["doi"]#">http://dx.doi.org/#idx["doi"]#</a>'>
			</cfif>
			<br>#rfs#
		</cfloop>
	</cfif>


							<cfdump var=#cfhttp#>

	<cfdump var=#x#>


</cfoutput>