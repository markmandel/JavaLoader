<cfcomponent extends="unittests.AbstractTestCase" output="false">

<!------------------------------------------- PUBLIC ------------------------------------------->

<cffunction name="setup" hint="setup function" access="public" returntype="void" output="false">
	<cfscript>
		var local = {};
		super.setup();
		clean();
		
		local.libpaths = [];
		ArrayAppend(local.libpaths, expandPath("/javaloader/support/cfcdynamicproxy/lib/cfcdynamicproxy.jar"));
	</cfscript>
	
	<cfdirectory action="list" directory="#instance.libPath#/spring" name="local.qJars" filter="*.jar">
	
	<cfloop query="local.qJars">
		<cfset arrayAppend(local.libpaths, directory & "/" & name)>
	</cfloop> 
	
	<cfscript>
		local.srcparths = [instance.srcPath & "/spring"];
		
		instance.loader = createObject("component", "javaloader.JavaLoader").init(loadPaths=local.libpaths, loadColdFusionClassPath=true, sourceDirectories=local.srcparths);		
    </cfscript>
</cffunction>

<!------------------------------------------- PACKAGE ------------------------------------------->

<cffunction name="loadSpringTest" hint="can we load spring and get a bean?" access="public" returntype="void" output="false">
	<cfscript>
		local = {};
		
		local.spring = instance.loader.create("org.springframework.context.support.FileSystemXmlApplicationContext").init();
    </cfscript>
</cffunction>

<!------------------------------------------- PRIVATE ------------------------------------------->

</cfcomponent>