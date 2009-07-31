<cfcomponent output="false">

<!------------------------------------------- PUBLIC ------------------------------------------->

<cffunction name="foo" hint="the foo method" access="public" returntype="any" output="false">
	<cfargument name="arg1" hint="" type="any" required="Yes">
	
	<cfreturn request.foo & " :: " &  arguments.arg1 />
</cffunction>

<!------------------------------------------- PACKAGE ------------------------------------------->

<!------------------------------------------- PRIVATE ------------------------------------------->

</cfcomponent>