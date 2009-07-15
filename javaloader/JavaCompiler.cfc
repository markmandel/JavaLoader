<cfcomponent hint="Compiles Java source dirs to an array of .jar files." output="false">

<!------------------------------------------- PUBLIC ------------------------------------------->

<cffunction name="init" hint="Constructor" access="public" returntype="JavaCompiler" output="false">
	<cfargument name="jarDirectory" hint="the directory to build the .jar file in, defaults to ./tmp" type="string" required="No" default="#getDirectoryFromPath(getMetadata(this).path)#/tmp">
	<cfscript>
		var data = {};
		var defaultCompiler = "com.sun.tools.javac.api.JavacTool";
		
		//we have to manually go looking for the compiler
		
		try
		{
			data.compiler = getPageContext().getClass().getClassLoader().loadClass(defaultCompiler).newInstance();
		}
		catch(any exc)
		{
			println("Error loading compiler:");
			println(exc.toString());
		}
		
		/*
		If not by THIS point do we have a compiler, then throw an exception 
		 */
		if(NOT StructKeyExists(data, "compiler"))
		{
			throwException("javaCompiler.NoCompilerAvailableException", 
				"No Java Compiler is available",
				"There is no Java Compiler available. Make sure tools.jar is in your classpath and you are running Java 1.6+");
		}
		
		setCompiler(data.compiler);
		setJarDirectory(arguments.jarDirectory);
		
		return this;
	</cfscript>
</cffunction>

<cffunction name="compile" hint="compiles Java to bytecode, and returns a JAR" access="public" returntype="any" output="false">
	<cfargument name="directoryArray" hint="array of directories to compile" type="array" required="Yes">
	<cfscript>
		//setup file manager with default exception handler, default locale, and default character set
		var fileManager = getCompiler().getStandardFileManager(JavaCast("null", ""), JavaCast("null", ""), JavaCast("null", ""));
		var qFiles = 0;
		var fileArray = 0;
		var directoryToCompile = 0;
		var fileObjects = 0;
		var os = getPageContext().getResponse().getOutputStream();
		var osw = createObject("java", "java.io.OutputStreamWriter").init(os);
		var jarName = getJarDirectory() & "/" & createUUID() & ".jar";
    </cfscript>
	
	<cfloop array="#arguments.directoryArray#" index="directoryToCompile">
		<cfdirectory action="list" directory="#directoryToCompile#" name="qFiles" recurse="true" filter="*.java">
		
		<cfloop query="qFiles">
			<cfscript>
				fileArray = [];
				
				ArrayAppend(fileArray, qFiles.directory & "/" & qFiles.name);
				
				fileObjects = fileManager.getJavaFileObjectsFromStrings(fileArray);
				
				//does the compilation
				getCompiler().getTask(osw, fileManager, JavaCast("null", ""), JavaCast("null", ""), JavaCast("null", ""), fileObjects).call();
	        </cfscript>
		</cfloop>
		
		<cfzip action="zip" file="#jarName#" recurse="yes" source="#directoryToCompile#" overwrite="no">			
	</cfloop>
	
	<!--- now add in the manifest --->
	<cfzip action="zip" file="#jarName#" recurse="yes" source="#getDirectoryFromPath(getMetadata(this).path)#/compile" overwrite="no">
	
	<cfreturn jarName />
</cffunction>

<cffunction name="getVersion" hint="returns the version number" access="public" returntype="string" output="false">
	<cfreturn "0.1.a" />
</cffunction>

<!------------------------------------------- PACKAGE ------------------------------------------->

<!------------------------------------------- PRIVATE ------------------------------------------->

<cffunction name="getCompiler" access="private" returntype="any" output="false">
	<cfreturn instance.Compiler />
</cffunction>

<cffunction name="setCompiler" access="private" returntype="void" output="false">
	<cfargument name="Compiler" type="any" required="true">
	<cfset instance.Compiler = arguments.Compiler />
</cffunction>

<cffunction name="getJarDirectory" access="private" returntype="string" output="false">
	<cfreturn instance.jarDirectory />
</cffunction>

<cffunction name="setJarDirectory" access="private" returntype="void" output="false">
	<cfargument name="jarDirectory" type="string" required="true">
	<cfset instance.jarDirectory = arguments.jarDirectory />
</cffunction>

<cffunction name="throwException" access="private" hint="Throws an Exception" output="false">
	<cfargument name="type" hint="The type of exception" type="string" required="Yes">
	<cfargument name="message" hint="The message to accompany the exception" type="string" required="Yes">
	<cfargument name="detail" type="string" hint="The detail message for the exception" required="No" default="">
		<cfthrow type="#arguments.type#" message="#arguments.message#" detail="#arguments.detail#">
</cffunction>

<cffunction name="println" hint="" access="private" returntype="void" output="false">
	<cfargument name="str" hint="" type="string" required="Yes">
	<cfscript>
		createObject("Java", "java.lang.System").out.println(arguments.str);
	</cfscript>
</cffunction>

</cfcomponent>