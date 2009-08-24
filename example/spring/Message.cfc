<cfcomponent hint="I have a message to send!" output="false">

<!------------------------------------------- PUBLIC ------------------------------------------->

<!--- we will tell Spring to run this method as our  --->

<cffunction name="init" hint="Constructor" access="public" returntype="Message" output="false">
	<cfscript>
		setMessage("Hello from Spring!");
		
		return this;			
	</cfscript>
</cffunction>

<!------------------------------------------- PACKAGE ------------------------------------------->

<!------------------------------------------- PRIVATE ------------------------------------------->

<cffunction name="getMessage" access="public" returntype="string" output="false">
	<cfreturn instance.Message />
</cffunction>

<cffunction name="setMessage" access="private" returntype="void" output="false">
	<cfargument name="Message" type="string" required="true">
	<cfset instance.Message = arguments.Message />
</cffunction>

</cfcomponent>