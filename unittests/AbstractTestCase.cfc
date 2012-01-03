<cfcomponent hint="An abstract test case for default setup, teardown, and util methods" extends="mxunit.framework.TestCase" output="false">

<!------------------------------------------- PUBLIC ------------------------------------------->

<cffunction name="setup" hint="setup function" access="public" returntype="void" output="false">
	<cfscript>
		instance.libPath = expandPath("/unittests/lib");
		instance.srcPath = expandPath("/unittests/src");
    </cfscript>
</cffunction>


<cffunction name="teardown" hint="tear down function" access="public" returntype="void" output="false">

</cffunction>

<!------------------------------------------- PACKAGE ------------------------------------------->

<!------------------------------------------- PRIVATE ------------------------------------------->

<cffunction name="clean" hint="deletes all the class files" access="private" returntype="void" output="false">
	<cfscript>
		var local = {};
    </cfscript>

	<cfdirectory action="list" recurse="true" directory="#instance.srcPath#" filter="*.class" name="local.qClasses">

	<cfloop query="local.qClasses">
		<cffile action="delete" file="#directory#/#name#">
	</cfloop>

	<cfdirectory action="list" recurse="true" directory="#expandPath('/javaloader/tmp')#" filter="*.jar" name="local.qJars">

	<cfloop query="local.qJars">
		<cffile action="delete" file="#directory#/#name#">
	</cfloop>
</cffunction>

<cffunction name="println" hint="" access="private" returntype="void" output="false">
	<cfargument name="str" hint="" type="string" required="Yes">
	<cfscript>
		createObject("Java", "java.lang.System").out.println(arguments.str);
	</cfscript>
</cffunction>


</cfcomponent>