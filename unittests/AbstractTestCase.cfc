<cfcomponent hint="An abstract test case for default setup, teardown, and util methods" extends="mxunit.framework.TestCase" output="false">

<!------------------------------------------- PUBLIC ------------------------------------------->

<cffunction name="setup" hint="setup function" access="public" returntype="void" output="false">
	<cfscript>
		instance.libPath = expandPath("/unittests/lib");    	    
		instance.srcPath = expandPath("/unittests/src");
    </cfscript>
</cffunction>

<!------------------------------------------- PACKAGE ------------------------------------------->

<!------------------------------------------- PRIVATE ------------------------------------------->

<cffunction name="clean" hint="deletes all the class files" access="public" returntype="void" output="false">
	<cfscript>
		var local = {};
    </cfscript>
	
	<cfdirectory action="list" recurse="true" directory="#instance.srcPath#" filter="*.class" name="local.qClasses">
	
	<cfloop query="local.qClasses">
		<cffile action="delete" file="#directory#/#name#">
	</cfloop>
</cffunction>

</cfcomponent>