<cfcomponent extends="unittests.AbstractTestCase" output="false">

<!------------------------------------------- PUBLIC ------------------------------------------->

<cffunction name="setup" hint="setup function" access="public" returntype="void" output="false">
	<cfscript>
		var local = {};
		super.setup();
		clean();
		
		local.libpaths = [];
		ArrayAppend(local.libpaths, expandPath("/javaloader/support/cfcdynamicproxy/lib/cfcdynamicproxy.jar"));
		ArrayAppend(local.libpaths, expandPath("/javaloader/support/spring/lib/spring-coldfusion.jar"));
	</cfscript>
	
	<cfdirectory action="list" directory="#instance.libPath#/spring" name="local.qJars" filter="*.jar">
	
	<cfloop query="local.qJars">
		<cfset arrayAppend(local.libpaths, directory & "/" & name)>
	</cfloop> 
	
	<cfscript>
		local.srcparths = [instance.srcPath & "/spring", instance.srcPath & "/dynamicproxy"];
		
		instance.loader = createObject("component", "javaloader.JavaLoader").init(loadPaths=local.libpaths, loadColdFusionClassPath=true, sourceDirectories=local.srcparths);		
    </cfscript>
</cffunction>

<!------------------------------------------- PACKAGE ------------------------------------------->

<cffunction name="loadSpringTest" hint="can we load spring and get a bean?" access="public" returntype="void" output="false">
	<cfscript>
		local = {};
		
		//don't ask me why we need the extra "/", but we do.
		local.path = "file://" & getDirectoryFromPath(getMetaData(this).path) & "/xml/spring.xml";
		
		//create our properties file
		local.properties = createObject("java", "java.util.Properties").init();
		local.properties.put("rootPath", expandPath("/"));
		
		local.fo = createObject("java", "java.io.FileOutputStream").init(instance.srcPath & "/spring/ut3/default.properties");
		
		local.properties.store(local.fo, "Default Properties");
		
		try
        {
        	local.spring = instance.loader.create("org.springframework.context.support.FileSystemXmlApplicationContext").init();
			
			local.spring.setClassLoader(instance.loader.getURLClassLoader());
			
			local.spring.setConfigLocation(local.path);
			
			local.spring.refresh();
        }
        catch(Any e)
        {
			debug(e.stacktrace);
			fail("Error occured");
        }
		
		local.foo = local.spring.getBean("foo");
		
		debug(local.foo);
    </cfscript>
</cffunction>

<!------------------------------------------- PRIVATE ------------------------------------------->

</cfcomponent>