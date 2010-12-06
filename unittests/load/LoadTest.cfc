<cfcomponent extends="unittests.AbstractTestCase" output="false">

<!------------------------------------------- PUBLIC ------------------------------------------->

<cffunction name="helloWorldTest" hint="test of simple hello world" access="public" returntype="void" output="false">
	<cfscript>
		var local = StructNew();

		local.paths = ArrayNew(1);

		local.paths[1] = instance.libPath & "/helloworld.jar";

		local.loader = createObject("component", "javaloader.JavaLoader").init(local.paths);

		local.helloWorld = local.loader.create("HelloWorld").init();

		assertEquals(local.helloWorld.hello(), "Hello World");
    </cfscript>
</cffunction>

<cffunction name="missingClassTest" hint="test requesting a missing class, and giving a good error message" access="public" returntype="void" output="false"
	mxunit:expectedException="javaloader.ClassNotFoundException"
	>
	<cfscript>
		var local = StructNew();

		local.paths = [];

		local.paths[1] = instance.libPath & "/helloworld.jar";

		local.loader = createObject("component", "javaloader.JavaLoader").init(local.paths);

		local.helloWorld = local.loader.create("HelloWorldDoesNotExist").init();
    </cfscript>
</cffunction>

<!------------------------------------------- PACKAGE ------------------------------------------->

<!------------------------------------------- PRIVATE ------------------------------------------->

</cfcomponent>