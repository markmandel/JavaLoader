<cfcomponent extends="unittests.AbstractTestCase" output="false">

<!------------------------------------------- PUBLIC ------------------------------------------->

<cffunction name="setup" hint="setup" access="public" returntype="void" output="false">
	<cfscript>
		super.setup();
		paths = ArrayNew(1);
		paths[1] = instance.libPath & "/helloworld.jar";

		javaloader = createObject("component", "javaloader.JavaLoader").init(paths);
	</cfscript>
</cffunction>

<cffunction name="testMixinApproach" hint="testing using the mixing" access="public" returntype="void" output="false">
	<cfscript>
		var mixin = javaloader.switchThreadContextClassLoader;

		var classLoader = mixin("returnCurrentClassLoader", javaloader.getURLClassLoader());

		assertSame(javaloader.getURLClassLoader(), classLoader);
	</cfscript>
</cffunction>

<cffunction name="testPassUDFIn" hint="pass in the UDF" access="public" returntype="void" output="false">
	<cfscript>
		var classLoader = javaloader.switchThreadContextClassLoader(returnCurrentClassLoader);
		assertSame(javaloader.getURLClassLoader(), classLoader);
	</cfscript>
</cffunction>

<cffunction name="testPassUDFInWithCustomClassLoader" hint="pass in the UDF" access="public" returntype="void" output="false">
	<cfscript>
		var urlClassLoader = createObject("java", "java.net.URLClassLoader").init([]);

		var classLoader = javaloader.switchThreadContextClassLoader(returnCurrentClassLoader, urlClassLoader);
		assertSame(urlClassLoader, classLoader);
	</cfscript>
</cffunction>
	
<cffunction name="testPassObjectAndMethodName" hint="pass in the object and the method name" access="public" returntype="void" output="false">
	<cfscript>
		var local = {};
		local.class = getMetadata(this).name;
		local.object = createObject("component", class);

		makePublic(local.object, "returnCurrentClassLoader");

		local.classLoader = javaloader.switchThreadContextClassLoader(local.object, "returnCurrentClassLoader");

		assertSame(javaloader.getURLClassLoader(), local.classLoader);
	</cfscript>
</cffunction>

<cffunction name="testPassObjectAndMethodNameWithCustomClassLoader" hint="pass in the object and the method name, with a custom classloader" access="public" returntype="void" output="false">
	<cfscript>
		var local = {};
		local.class = getMetadata(this).name;
		local.object = createObject("component", class);
		local.urlClassLoader = createObject("java", "java.net.URLClassLoader").init([]);

		makePublic(local.object, "returnCurrentClassLoader");

		local.classLoader = javaloader.switchThreadContextClassLoader(local.object, "returnCurrentClassLoader");

		assertSame(javaloader.getURLClassLoader(), local.classLoader);
	</cfscript>
</cffunction>

<!------------------------------------------- PACKAGE ------------------------------------------->

<!------------------------------------------- PRIVATE ------------------------------------------->

<cffunction name="returnCurrentClassLoader" hint="returns the current contexts classloader" access="private" returntype="any" output="false">
	<cfscript>
		var Thread = createObject("java", "java.lang.Thread");
		return Thread.currentThread().getContextClassLoader();
	</cfscript>
</cffunction>

</cfcomponent>