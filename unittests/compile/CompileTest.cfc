<cfcomponent hint="unit test for compilation" extends="ut.unittests.AbstractTestCase" output="false">

<!------------------------------------------- PUBLIC ------------------------------------------->

<cffunction name="setup" hint="setup function" access="public" returntype="void" output="false">
	<cfscript>
		super.setup();
		clean();
    </cfscript>
</cffunction>

<cffunction name="simpleCompilerTest" hint="test a simple hello world compilation" access="public" returntype="void" output="false">
	<cfscript>
		var local = StructNew();
		
		local.compiler = createObject("component", "javaloader.JavaCompiler").init();
		
		local.paths = [instance.srcPath];
		
		local.jar = local.compiler.compile(local.paths);
		
		local.paths = [local.jar];
		
		local.loader = createObject("component", "javaloader.JavaLoader").init(local.paths);
		
		local.helloWorld = local.loader.create("com.HelloWorld").init();
		
		assertEquals(local.helloWorld.hello(), "Hello World");
    </cfscript>
</cffunction>

<cffunction name="javaLoaderCompileTest" hint="tell JL to compile, and run the test that way" access="public" returntype="void" output="false">
	<cfscript>
		var local = {};
		
		local.paths = [instance.srcPath];
		
		local.loader = createObject("component", "javaloader.JavaLoader").init(sourceDirectories=local.paths);
		
		local.helloWorld = local.loader.create("com.HelloWorld").init();
		
		assertEquals(local.helloWorld.hello(), "Hello World");		
    </cfscript>
</cffunction>

<cffunction name="brokenCompilerTest" hint="tell JL to compile, and run the test that way" access="public" returntype="void" output="false">
	<cfscript>
		var local = {};
		
		local.check = false;
		
		fileMove(instance.srcPath & "/com/HelloWorldBroken.java.bad", instance.srcPath & "/com/HelloWorldBroken.java");
		
		local.compiler = createObject("component", "javaloader.JavaCompiler").init();
		
		local.paths = [instance.srcPath];
		
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
			fileMove(instance.srcPath & "/com/HelloWorldBroken.java", instance.srcPath & "/com/HelloWorldBroken.java.bad");
		}
		
		AssertTrue(local.check, "An error should have been thrown on the compilation");
		
		//reset it
		fileMove(instance.srcPath & "/com/HelloWorldBroken.java", instance.srcPath & "/com/HelloWorldBroken.java.bad");		
    </cfscript>
</cffunction>
<!------------------------------------------- PACKAGE ------------------------------------------->

<!------------------------------------------- PRIVATE ------------------------------------------->

</cfcomponent>