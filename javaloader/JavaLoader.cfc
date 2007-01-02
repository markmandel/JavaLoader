<!--- Document Information -----------------------------------------------------

Title:      JavaLoader.cfc

Author:     Mark Mandel
Email:      mark@compoundtheory.com

Website:    http://www.compoundtheory.com

Purpose:    Utlitity class for loading Java Classes

Usage:

Modification Log:

Name			Date			Description
================================================================================
Mark Mandel		08/05/2006		Created
Mark Mandel		22/06/2006		Added verification that the path exists

------------------------------------------------------------------------------->
<cfcomponent name="JavaLoader" hint="Loads External Java Classes, while providing access to ColdFusion classes">

<cfscript>
	instance = StructNew();
</cfscript>

<!------------------------------------------- PUBLIC ------------------------------------------->
<cffunction name="init" hint="Constructor" access="public" returntype="JavaLoader" output="false">
	<cfargument name="loadPaths" hint="An array of directories of classes, or paths to .jar files to load" type="array" default="#ArrayNew(1)#" required="no">
	<cfargument name="loadColdFusionClassPath" hint="Loads the ColdFusion libraries" type="boolean" required="No" default="false">
	<cfargument name="loadedClassPathBias" hint="If loading classes on top of a parent classpath, search the loaded classes before searching the parent ClassPath" type="boolean" required="No" default="true">
	<cfargument name="parentClassLoader" hint="(Expert use only) The parent java.lang.ClassLoader to set when creating the URLClassLoader" type="any" default="" required="false">

	<cfscript>
		var iterator = arguments.loadPaths.iterator();
		var Array = createObject("java", "java.lang.reflect.Array");
		var Class = createObject("java", "java.lang.Class");
		var URLs = Array.newInstance(Class.forName("java.net.URL"), JavaCast("int", ArrayLen(arguments.loadPaths)));
		var file = 0;
		var classLoader = 0;
		var counter = 0;
		var javaloader = 0;

		while(iterator.hasNext())
		{
			file = createObject("java", "java.io.File").init(iterator.next());
			if(NOT file.exists())
			{
				throw("PathNotFoundException", "The path you have specified could not be found", file.getAbsolutePath() & " does not exist");
			}
			Array.set(URLs, JavaCast("int", counter), file.toURL());
			counter = counter + 1;
		}

		if(arguments.loadColdFusionClassPath)
		{
			arguments.parentClassLoader = createObject("java", "java.lang.Thread").currentThread().getContextClassLoader();
		}

		if(arguments.loadedClassPathBias)
		{
			javaloader = createObject("component", "JavaLoader").init(loadPaths=queryJars(), loadedClassPathBias=false);
			if(isObject(arguments.parentClassLoader))
			{
				classLoader = javaloader.create("com.compoundtheory.classloader.ChildBiasURLClassLoader").init(URLs, arguments.parentClassLoader);
			}
			else
			{
				classLoader = javaloader.create("com.compoundtheory.classloader.ChildBiasURLClassLoader").init(URLs);
			}
		}
		else
		{
			if(isObject(arguments.parentClassLoader))
			{
				classLoader = createObject("java", "java.net.URLClassLoader").init(URLs, arguments.parentClassLoader);
			}
			else
			{
				classLoader = createObject("java", "java.net.URLClassLoader").init(URLs);
			}
		}

		//pass in the system loader
		setURLClassLoader(classLoader);

		return this;
	</cfscript>
</cffunction>

<cffunction name="create" hint="Retrieves a reference to the java class. To create a instance, you must run init() on this object" access="public" returntype="any" output="false">
	<cfargument name="className" hint="The name of the class to create" type="string" required="Yes">
	<cfscript>
		var class = getURLClassLoader().loadClass(arguments.className);

		return createObject("java", "coldfusion.runtime.java.JavaProxy").init(class);
	</cfscript>
</cffunction>

<cffunction name="getURLClassLoader" hint="Returns the java.net.URLClassLoader in case you need access to it" access="public" returntype="any" output="false">
	<cfreturn instance.ClassLoader />
</cffunction>

<cffunction name="getVersion" hint="Retrieves the version of the loader you are using" access="public" returntype="string" output="false">
	<cfreturn "0.3">
</cffunction>

<!------------------------------------------- PACKAGE ------------------------------------------->

<!------------------------------------------- PRIVATE ------------------------------------------->

<cffunction name="queryJars" hint="pulls a query of all the jars in the /resources/lib folder" access="private" returntype="array" output="false">
	<cfscript>
		var qJars = 0;
		//the path to my jar library
		var path = getDirectoryFromPath(getMetaData(this).path) & "lib/";
		var jarList = "";
		var aJars = ArrayNew(1);
		var libName = 0;
	</cfscript>

	<cfdirectory action="list" name="qJars" directory="#path#" filter="*.jar" sort="name desc"/>

	<cfloop query="qJars">
		<cfscript>
			libName = ListGetAt(name, 1, "-");
			//let's not use the lib's that have the same name, but a lower datestamp
			if(NOT ListFind(jarList, libName))
			{
				ArrayAppend(aJars, directory & "/" & name);
				jarList = ListAppend(jarList, libName);
			}
		</cfscript>
	</cfloop>

	<cfreturn aJars>
</cffunction>

<cffunction name="setURLClassLoader" access="private" returntype="void" output="false">
	<cfargument name="ClassLoader" type="any" required="true">
	<cfset instance.ClassLoader = arguments.ClassLoader />
</cffunction>

<cffunction name="throw" access="private" hint="Throws an Exception" output="false">
	<cfargument name="type" hint="The type of exception" type="string" required="Yes">
	<cfargument name="message" hint="The message to accompany the exception" type="string" required="Yes">
	<cfargument name="detail" type="string" hint="The detail message for the exception" required="No" default="">
		<cfthrow type="#arguments.type#" message="#arguments.message#" detail="#arguments.detail#">
</cffunction>

</cfcomponent>