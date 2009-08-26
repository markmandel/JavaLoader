<cfcomponent hint="The application.cfc" output="false">

<cfscript>
	this.name = "JavaLoader Unit Tests";
	this.mappings["/ut"] = expandPath("/");
	this.sessionmanagement = true;
	
	structClear(server);	
</cfscript>

</cfcomponent>