<!---
	sent comforting email
---->
<cfoutput>
	<cfmail to="arctos.is.not.dead@gmail.com" cc="dustymc@gmail.com" #Application.fromEmail#" type="html" subject="not dead">
		im not dead
	</cfmail>
</cfoutput>