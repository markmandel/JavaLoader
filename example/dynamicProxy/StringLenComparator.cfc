<cfcomponent output="false">

<!--- match methods to java.util.Comparator interface --->

<!------------------------------------------- PUBLIC ------------------------------------------->

<cffunction name="compare" hint="compares 2 objects" access="public" returntype="numeric" output="false">
	<cfargument name="obj1" hint="the first object" type="string" required="Yes">
	<cfargument name="obj2" hint="the second object" type="string" required="Yes">
	<cfscript>
		var len1 = Len(arguments.obj1);
		var len2 = Len(arguments.obj2);
		
		if(len1 lt len2)
		{
			return -1;
		}
		else if(len1 gt len2)
		{
			return 1;
		}
		
		return 0;
    </cfscript>
</cffunction>

<!--- we probably don't need the below function but to fulfil the inerface' --->

<cffunction name="equals" hint=" Indicates whether some other object is 'equal to' this comparator." access="public" returntype="boolean" output="false">
	<cfscript>
		return false;    	    
    </cfscript>
</cffunction>

<!------------------------------------------- PACKAGE ------------------------------------------->

<!------------------------------------------- PRIVATE ------------------------------------------->

</cfcomponent>