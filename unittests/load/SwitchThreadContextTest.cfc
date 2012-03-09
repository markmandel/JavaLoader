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
		var urlClassLoader = createObject("java", "java.net.URLClassLoader").init(ArrayNew(1));

		var classLoader = javaloader.switchThreadContextClassLoader(returnCurrentClassLoader, urlClassLoader);
		assertSame(urlClassLoader, classLoader);
	</cfscript>
</cffunction>
	
<cffunction name="testPassObjectAndMethodName" hint="pass in the object and the method name" access="public" returntype="void" output="false">
	<cfscript>
		var local = {};
		local.class = getMetadata(this).name;
		local.object = createObject("component", local.class);

		makePublic(local.object, "returnCurrentClassLoader");

		local.classLoader = javaloader.switchThreadContextClassLoader(local.object, "returnCurrentClassLoader");

		assertSame(javaloader.getURLClassLoader(), local.classLoader);
	</cfscript>
</cffunction>

<cffunction name="testPassObjectAndMethodNameWithCustomClassLoader" hint="pass in the object and the method name, with a custom classloader" access="public" returntype="void" output="false">
	<cfscript>
		var local = {};
		local.class = getMetadata(this).name;
		local.object = createObject("component", local.class);
		local.urlClassLoader = createObject("java", "java.net.URLClassLoader").init(ArrayNew(1));

		makePublic(local.object, "returnCurrentClassLoader");

		local.classLoader = javaloader.switchThreadContextClassLoader(local.object, "returnCurrentClassLoader");

		assertSame(javaloader.getURLClassLoader(), local.classLoader);
	</cfscript>
</cffunction>

<cffunction name="testMixinApproachWithArguments" hint="testing using the mixing" access="public" returntype="void" output="false">
	<cfscript>
		var mixin = javaloader.switchThreadContextClassLoader;
		var args = { arg1 = 1, arg2 = 2};
		var result = mixin("returnCurrentClassLoaderAndArguments", args, javaloader.getURLClassLoader());
		assertSame(javaloader.getURLClassLoader(), result.classLoader);
		assertStructEquals(args, result.args);
	</cfscript>
</cffunction>

<cffunction name="testPassUDFInWithArguments" hint="pass in a UDF with arguments" access="public" returntype="void" output="false">
	<cfscript>
		var args = { arg1 = 1, arg2 = 2};
		var result = javaloader.switchThreadContextClassLoader(returnCurrentClassLoaderAndArguments, args);
		assertSame(javaloader.getURLClassLoader(), result.classLoader);
		assertStructEquals(args, result.args);
	</cfscript>
</cffunction>

<cffunction name="testPassUDFInWithArgumentsWithCustomClassLoader" hint="pass in a UDF with arguments" access="public" returntype="void" output="false">
	<cfscript>
		var urlClassLoader = createObject("java", "java.net.URLClassLoader").init(ArrayNew(1));
		var args = { arg1 = 1, arg2 = 2};
		var result = javaloader.switchThreadContextClassLoader(returnCurrentClassLoaderAndArguments, args, urlClassLoader);
		assertSame(urlClassLoader, result.classLoader);
		assertStructEquals(args, result.args);
	</cfscript>
</cffunction>

<cffunction name="testPassObjectAndMethodNameWithArguments" hint="pass in the object and method name with arguments" access="public" returntype="void" output="false">
	<cfscript>
		var local = {};
		local.class = getMetadata(this).name;
		local.object = createObject("component", local.class);
		local.args = { arg1 = 1, arg2 = 2};
		
		makePublic(local.object, "returnCurrentClassLoaderAndArguments");
		
		local.result = javaloader.switchThreadContextClassLoader(local.object, "returnCurrentClassLoaderAndArguments", local.args);
		assertSame(javaloader.getURLClassLoader(), local.result.classLoader);
		assertStructEquals(local.args, local.result.args);
	</cfscript>
</cffunction>

<cffunction name="testPassObjectAndMethodNameWithArgumentsWithCustomClassLoader" hint="pass in the object and method name with arguments, with a custom classloader" access="public" returntype="void" output="false">
	<cfscript>
		var local = {};
		local.class = getMetadata(this).name;
		local.object = createObject("component", local.class);
		local.urlClassLoader = createObject("java", "java.net.URLClassLoader").init(ArrayNew(1));
		local.args = { arg1 = 1, arg2 = 2};

		makePublic(local.object, "returnCurrentClassLoaderAndArguments");

		local.result = javaloader.switchThreadContextClassLoader(local.object, "returnCurrentClassLoaderAndArguments", local.args, local.urlClassLoader);
		assertSame(local.urlClassLoader, local.result.classLoader);
		assertStructEquals(local.args, local.result.args);
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

<cffunction name="returnCurrentClassLoaderAndArguments" hint="returns the current contexts classloader and any arguments passed in" access="private" returntype="any" output="false">
	<cfscript>
		var Thread = createObject("java", "java.lang.Thread");
		var result = { classLoader = Thread.currentThread().getContextClassLoader(), args = arguments };
		return result;
	</cfscript>
</cffunction>

</cfcomponent>