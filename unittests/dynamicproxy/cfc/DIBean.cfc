<cfcomponent hint="Bean setup for DI" output="false">

<!------------------------------------------- PUBLIC ------------------------------------------->

<cffunction name="init" hint="Constructor" access="public" returntype="DIBean" output="false">
	<cfscript>
		setInitValue("I've been init");
	
		return this;
	</cfscript>
</cffunction>

<cffunction name="getInitValue" access="public" returntype="string" output="false">
	<cfreturn instance.InitValue />
</cffunction>

<cffunction name="getStringValue" access="public" returntype="any" output="false">
	<cfreturn instance.StringValue />
</cffunction>

<cffunction name="setStringValue" access="public" returntype="void" output="false">
	<cfargument name="StringValue" type="any" required="true">
	<cfset instance.StringValue = arguments.StringValue />
</cffunction>

<cffunction name="getBar" access="public" returntype="any" output="false">
	<cfreturn instance.Bar />
</cffunction>

<cffunction name="setBar" access="public" returntype="void" output="false">
	<cfargument name="Bar" type="any" required="true">
	<cfset instance.Bar = arguments.Bar />
</cffunction>

<!------------------------------------------- PACKAGE ------------------------------------------->

<!------------------------------------------- PRIVATE ------------------------------------------->

<cffunction name="setInitValue" access="private" returntype="void" output="false">
	<cfargument name="InitValue" type="string" required="true">
	<cfset instance.InitValue = arguments.InitValue />
</cffunction>

</cfcomponent>