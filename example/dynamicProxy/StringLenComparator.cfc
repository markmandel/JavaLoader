<cfcomponent output="false">

<!--- match methods to java.util.Comparator interface --->

<!------------------------------------------- PUBLIC ------------------------------------------->

<!---
Apologies for the convoluted use on onMissingMethod.  This is only done because 'equals' and 'compare' are reserved
words in ColdFusion, and we can't declare methods with those names.

If your Java interface does not have any conflicts with ColdFusion's reserved function names, you don't need to take this approach, and
can simply define your functions normally.
 --->

<cffunction	name="onMissingMethod" access="public" returntype="any" output="false" hint="Since 'compare' and 'equals' are reserved method names, we have to escape them">
	<cfargument	name="missingMethodName" type="string"	required="true"	hint=""	/>
	<cfargument	name="missingMethodArguments" type="struct" required="true"	hint=""/>

	<cfset var local = {}>

	<cfif structKeyExists(arguments.missingMethodArguments, "__fromMissingMethod")>
		<!--- we've been here before --->
		<cfthrow type="MethodNotFoundException" message="The method '#arguments.missingMethodName#' could not be found."
				 detail="The method '#arguments.missingMethodName#' could not be found in component '#getMetadata(this).name#'">
	</cfif>

	<!--- add in an extra argument, so we can catch onMissingMethod based stack overflows --->
	<cfset arguments.missingMethodArguments.__fromMissingMethod = true>

	<!--- call the same method name, just with an $ before it, so ColdFusion doesn't get upset --->
	<cfinvoke component="#this#" method="$#arguments.missingMethodName#" argumentcollection="#arguments.missingMethodArguments#" returnvariable="local.result">
	<cfif structKeyExists(local, "result")>
		<cfreturn local.result />
	</cfif>
</cffunction>

<cffunction name="$compare" hint="compares 2 objects" access="public" returntype="numeric" output="false">
	<cfargument name="obj1" hint="the first object" type="string" required="Yes">
	<cfargument name="obj2" hint="the second object" type="string" required="Yes">
	<cfscript>
		var len1 = Len(arguments.obj1);
		var len2 = Len(arguments.obj2);
		var result = 0;

		if(len1 lt len2)
		{
			result = -1;
		}
		else if(len1 gt len2)
		{
			result = 1;
		}

		//have to java cast to make sure it corresponds to the interface
		return JavaCast("int", result);
    </cfscript>
</cffunction>

<!--- we probably don't need the below function but to fulfil the inerface' --->
<cffunction name="$equals" hint=" Indicates whether some other object is 'equal to' this comparator." access="public" returntype="boolean" output="false">
	<cfscript>
		return false;
    </cfscript>
</cffunction>

<!------------------------------------------- PACKAGE ------------------------------------------->

<!------------------------------------------- PRIVATE ------------------------------------------->

</cfcomponent>