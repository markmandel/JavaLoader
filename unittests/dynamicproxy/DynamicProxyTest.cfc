<cfcomponent extends="unittests.AbstractTestCase" output="false">

<!------------------------------------------- PUBLIC ------------------------------------------->

<cffunction name="setup" hint="setup function" access="public" returntype="void" output="false">
	<cfscript>
		super.setup();
		clean();
    </cfscript>
</cffunction>

<cffunction name="useDynamicProxyInCFTest" hint="test to create a CFC dynamic proxy, and call it from within CF" access="public" returntype="void" output="false">
	<cfscript>
		var local = {};
		
		local.libpaths = [];
		ArrayAppend(local.libpaths, expandPath("/javaloader/support/cfcdynamicproxy/lib/cfcdynamicproxy.jar"));
		
		local.srcparths = [instance.srcPath & "/dynamicproxy"];
		
		local.loader = createObject("component", "javaloader.JavaLoader").init(loadPaths=local.libpaths, loadColdFusionClassPath=true, sourceDirectories=local.srcparths);
    </cfscript>
</cffunction>

<!------------------------------------------- PACKAGE ------------------------------------------->

<!------------------------------------------- PRIVATE ------------------------------------------->

</cfcomponent>