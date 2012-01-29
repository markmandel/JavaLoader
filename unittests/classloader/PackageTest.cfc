<cfcomponent hint="Test for ensuring we get the correct package data" extends="unittests.AbstractTestCase" output="false">

<!------------------------------------------- PUBLIC ------------------------------------------->

<cffunction name="setup" hint="setup function" access="public" returntype="void" output="false">
	<cfscript>
		var local = {};
		super.setup();
		clean();

		local.libpaths = [];
		ArrayAppend(local.libpaths, expandPath("/javaloader/support/cfcdynamicproxy/lib/cfcdynamicproxy.jar"));

		local.srcparths = [instance.srcPath & "/dynamicproxy"];

		jl = createObject("component", "javaloader.JavaLoader").init(loadPaths = local.libpaths, loadColdFusionClassPath = true, sourceDirectories = local.srcparths);
	</cfscript>
</cffunction>


<cffunction name="testSystemPackage" hint="can we get at a system package through the classloader?" access="public" returntype="void" output="false">
	<cfscript>
		var local = {};

		local.string = jl.create("java.lang.String");
		local.class = local.string.getClass();

		assertEquals("java.lang.String", local.class.getName());

		local.package = local.class.getPackage();

		assertEquals("java.lang", local.package.getName());
	</cfscript>
</cffunction>

<cffunction name="testCustomPackage" hint="Can we get a package through the classLoader?" access="public" returntype="void" output="false">
	<cfscript>
		var local = {};

		local.dp = jl.create("com.compoundtheory.coldfusion.cfc.CFCDynamicProxy");
		local.class = local.dp.getClass();

		assertEquals("com.compoundtheory.coldfusion.cfc.CFCDynamicProxy", local.class.getName());

		local.package = local.class.getPackage();

		assertEquals("com.compoundtheory.coldfusion.cfc", local.package.getName());
	</cfscript>
</cffunction>

<!------------------------------------------- PACKAGE ------------------------------------------->

<!------------------------------------------- PRIVATE ------------------------------------------->

</cfcomponent>