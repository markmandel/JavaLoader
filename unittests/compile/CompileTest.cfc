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

<!------------------------------------------- PACKAGE ------------------------------------------->

<!------------------------------------------- PRIVATE ------------------------------------------->

</cfcomponent>