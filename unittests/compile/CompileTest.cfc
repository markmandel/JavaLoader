<cfcomponent hint="unit test for compilation" extends="unittests.AbstractTestCase" output="false">

<!------------------------------------------- PUBLIC ------------------------------------------->

<cffunction name="setup" hint="setup function" access="public" returntype="void" output="false">
	<cfscript>
		super.setup();
		clean();
    </cfscript>
</cffunction>

<cffunction name="teardown" hint="tear down function" access="public" returntype="void" output="false">
	<cfscript>
	    super.teardown();
		clean();
    </cfscript>
</cffunction>

<cffunction name="simpleCompilerTest" hint="test a simple hello world compilation" access="public" returntype="void" output="false">
	<cfscript>
		var local = StructNew();

		local.compiler = createObject("component", "javaloader.JavaCompiler").init();

		local.paths = [instance.srcPath & "/helloworld"];

		local.jar = local.compiler.compile(local.paths);

		local.paths = [local.jar];

		local.loader = createObject("component", "javaloader.JavaLoader").init(local.paths);

		local.helloWorld = local.loader.create("ut1.HelloWorld").init();

		assertEquals(local.helloWorld.hello(), "Hello World");
    </cfscript>
</cffunction>

<cffunction name="javaLoaderCompileTest" hint="tell JL to compile, and run the test that way" access="public" returntype="void" output="false">
	<cfscript>
		var local = {};

		local.paths = [instance.srcPath & "/helloworld"];

		local.loader = createObject("component", "javaloader.JavaLoader").init(sourceDirectories=local.paths);

		local.helloWorld = local.loader.create("ut1.HelloWorld").init();

		assertEquals(local.helloWorld.hello(), "Hello World");
    </cfscript>
</cffunction>

<cffunction name="brokenCompilerTest" hint="tell JL to compile, and run the test that way" access="public" returntype="void" output="false">
	<cfscript>
		var local = {};

		local.check = false;

		fileMove(instance.srcPath & "/helloworld/ut1/HelloWorldBroken.java.bad", instance.srcPath & "/helloworld/ut1/HelloWorldBroken.java");

		local.compiler = createObject("component", "javaloader.JavaCompiler").init();

		local.paths = [instance.srcPath & "/helloworld"];

		try
		{
			local.jar = local.compiler.compile(local.paths);
		}
		catch(javacompiler.SourceCompilationException exc)
		{
			debug(exc);
			local.check = true;
		}
		catch(Any exc)
		{
			fileMove(instance.srcPath & "/helloworld/ut1/HelloWorldBroken.java", instance.srcPath & "/helloworld/ut1/HelloWorldBroken.java.bad");
		}

		AssertTrue(local.check, "An error should have been thrown on the compilation");

		//reset it
		fileMove(instance.srcPath & "/helloworld/ut1/HelloWorldBroken.java", instance.srcPath & "/helloworld/ut1/HelloWorldBroken.java.bad");
    </cfscript>
</cffunction>

<cffunction name="javaLoaderChangeSourceCompileTest" hint="test source, change the source, and then retest" access="public" returntype="void" output="false">
	<cfscript>
		var local = {};

		local.paths = [instance.srcPath & "/helloworld"];

		local.loader = createObject("component", "javaloader.JavaLoader").init(sourceDirectories=local.paths);

		local.helloWorld = local.loader.create("ut1.HelloWorld").init();

		assertEquals(local.helloWorld.hello(), "Hello World");

		sleep(100);

		fileMove(instance.srcPath & "/helloworld/ut1/HelloWorld.java", instance.srcPath & "/helloworld/ut1/HelloWorld.java.bak");

		local.content = fileRead(instance.srcPath & "/helloworld/ut1/HelloWorld.java.bak");

		local.content = replace(local.content, '"Hello World"', '"This has now been changed"');

		fileWrite(instance.srcPath & "/helloworld/ut1/HelloWorld.java", local.content);

		local.helloWorld = local.loader.create("ut1.HelloWorld").init();

		assertEquals("This has now been changed", local.helloWorld.hello());

		fileMove(instance.srcPath & "/helloworld/ut1/HelloWorld.java.bak", instance.srcPath & "/helloworld/ut1/HelloWorld.java");
    </cfscript>
</cffunction>

<cffunction name="javaLoaderTrustedSourceCompileTest" hint="test source, change the source, and then retest" access="public" returntype="void" output="false">
	<cfscript>
		var local = {};

		local.paths = [instance.srcPath & "/helloworld"];

		local.loader = createObject("component", "javaloader.JavaLoader").init(sourceDirectories=local.paths, trustedSource=true);

		local.helloWorld = local.loader.create("ut1.HelloWorld").init();

		assertEquals(local.helloWorld.hello(), "Hello World");

		fileMove(instance.srcPath & "/helloworld/ut1/HelloWorld.java", instance.srcPath & "/helloworld/ut1/HelloWorld.java.bak");

		local.content = fileRead(instance.srcPath & "/helloworld/ut1/HelloWorld.java.bak");

		local.content = replace(local.content, '"Hello World"', '"This has now been changed"');

		fileWrite(instance.srcPath & "/helloworld/ut1/HelloWorld.java", local.content);

		local.helloWorld = local.loader.create("ut1.HelloWorld").init();

		assertEquals("Hello World", local.helloWorld.hello());

		fileMove(instance.srcPath & "/helloworld/ut1/HelloWorld.java.bak", instance.srcPath & "/helloworld/ut1/HelloWorld.java");

		//now we run it again, to make sure it still works from the stored .jar file

        local.loader = createObject("component", "javaloader.JavaLoader").init(sourceDirectories=local.paths, trustedSource=true);

		local.helloWorld = local.loader.create("ut1.HelloWorld").init();

		assertEquals(local.helloWorld.hello(), "Hello World");
    </cfscript>
</cffunction>

<!------------------------------------------- PACKAGE ------------------------------------------->

<!------------------------------------------- PRIVATE ------------------------------------------->

</cfcomponent>