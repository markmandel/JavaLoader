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

		try
        {
			local.spring = loadSpring();
        }
        catch(Any e)
        {
			debug(e.stacktrace);
			fail("Error occured: #e.stacktrace#");
        }

		local.foo = local.spring.getBean("foo");

		debug(local.foo);

		assertEquals("Hello!", local.foo.foo("Hello!"));

		assertEquals("I could not find my method: doesNotExist", local.foo.doesNotExist());

		local.interfaces = local.foo.getClass().getInterfaces();
		for(local.i = 1; local.i lte arraylen(local.interfaces); local.i++)
		{
			local.class = local.interfaces[local.i];
			debug(local.class.toString());

			assertEquals(local.class.getName(), "ut2.IFoo");
		}
    </cfscript>
</cffunction>

<cffunction name="relativeLoadSpringTest" hint="can we load spring and get a bean, that has been defined relatively?" access="public" returntype="void" output="false">
	<cfscript>
		local = {};

		try
        {
			local.spring = loadSpring();
        }
        catch(Any e)
        {
			debug(e.stacktrace);
			fail("Error occured: #e.stacktrace#");
        }

		local.foo = local.spring.getBean("relativeBean");

		debug(local.foo);

		assertEquals("Hello!", local.foo.foo("Hello!"));

		assertEquals("I could not find my method: doesNotExist", local.foo.doesNotExist());

		local.interfaces = local.foo.getClass().getInterfaces();
		for(local.i = 1; local.i lte arraylen(local.interfaces); local.i++)
		{
			local.class = local.interfaces[local.i];
			debug(local.class.toString());

			assertEquals(local.class.getName(), "ut2.IFoo");
		}
    </cfscript>
</cffunction>

<cffunction name="manualDITest" hint="test the init function" access="public" returntype="void" output="false">
	<cfscript>
		var local = {};

		try
        {
			local.spring = loadSpring();

			local.dibean = local.spring.getBean("dibean");

			local.dibean2 = local.spring.getBean("dibean");
        }
        catch(Any e)
        {
			debug(e);
			fail(e.stacktrace);
        }

		assertEquals("I've been init", local.dibean.getInitValue());
		assertEquals("I've been init", local.dibean2.getInitValue());

		assertEquals("This is my String!", local.dibean.getStringValue());
		assertEquals("This is my String!", local.dibean2.getStringValue());

		assertNotSame(local.dibean, local.dibean2);
    </cfscript>
</cffunction>

<cffunction name="autowireDITest" hint="test the init function" access="public" returntype="void" output="false">
	<cfscript>
		var local = {};

		try
        {
			local.spring = loadSpring();

			local.dibean = local.spring.getBean("dibeanSingle");

			local.dibean2 = local.spring.getBean("dibeanSingle");
        }
        catch(Any e)
        {
			debug(e);
			fail(e.stacktrace);
        }

		local.interfaces = local.dibean.getClass().getMethods();
		for(local.i = 1; local.i lte arraylen(local.interfaces); local.i++)
		{
			local.class = local.interfaces[local.i];
			debug(local.class.toString());
		}

		assertEquals("I've been init", local.dibean.getInitValue());
		assertEquals("I've been init", local.dibean2.getInitValue());

		assertEquals("Foo!", local.dibean.getBar().getValue());

		assertSame(local.dibean, local.dibean2);
    </cfscript>
</cffunction>

<!------------------------------------------- PRIVATE ------------------------------------------->


<cffunction name="loadSpring" hint="" access="private" returntype="any" output="false">
	<cfscript>
    	local = {};

		local.path = "file://" & getDirectoryFromPath(getMetaData(this).path) & "/xml/spring.xml";

		//create our properties file
		local.properties = createObject("java", "java.util.Properties").init();
		local.properties.put("rootPath", expandPath("/"));

		local.fo = createObject("java", "java.io.FileOutputStream").init(instance.srcPath & "/spring/ut3/default.properties");

		local.properties.store(local.fo, "Default Properties");

    	local.spring = instance.loader.create("org.springframework.context.support.FileSystemXmlApplicationContext").init();

		local.spring.setClassLoader(instance.loader.getURLClassLoader());

		local.spring.setConfigLocation(local.path);

		local.spring.refresh();

		return local.spring;
    </cfscript>
</cffunction>

</cfcomponent>