<cfinclude template="/includes/functionLib.cfm">
hi

<cfset list = "1999,1.234,1.23,bob">
<cfoutput>
<cfloop list="#list#" index="s" delimiters=",">
	- #s# -<cfif isYear(s)>
		yep
	</cfif><br>
</cfloop>
</cfoutput>