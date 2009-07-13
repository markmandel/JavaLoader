<cfcomponent hint="The application.cfc" output="false">

<cfscript>
	this.name = "JavaLoader Unit Tests";
	this.mappings["/ut"] = expandPath("/");	
</cfscript>

</cfcomponent>