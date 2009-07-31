<cfcomponent output="false">

<!------------------------------------------- PUBLIC ------------------------------------------->

<cffunction name="foo" hint="the foo method" access="public" returntype="any" output="false">
	<cfargument name="arg1" hint="" type="any" required="Yes">
	
	<cfreturn arguments.arg1 />
</cffunction>

<cffunction	name="onMissingMethod" access="public" returntype="any" output="false" hint="invoked when a method could not be found">
	<cfargument	name="missingMethodName" type="string"	required="true"	hint=""	/>
	<cfargument	name="missingMethodArguments" type="struct" required="true"	hint=""/>
	
	<cfreturn "I could not find my method: " & arguments.missingMethodName />
</cffunction>

<!------------------------------------------- PACKAGE ------------------------------------------->

<!------------------------------------------- PRIVATE ------------------------------------------->

</cfcomponent>