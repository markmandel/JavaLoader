<html>
	<head><title>JavaLoader Compilation Example</title></head>
	<style type="text/css">
		body {
			font-family: Verdana, Helvetica, san-serif;
			font-size: small;
		}
	</style>
	<body>
		<p>
			Example of creating a 'HelloWorld' Java object, by compiling the Java source dynamically.
		</p>
		<p>
			The source for the HelloWord class can be found in /src.
		</p>
		
		<cfscript>
			/*
			An array of source paths to be dynamically compiled by JavaLoader.
			In this case we are just loading the ./src directory 
			*/
			sourcePaths = [expandPath("./src")];
		
			/*
			While we can combine .jar loading and compilation, we are just going to compile and load our
			HelloWorld example from its source.  
			*/
			loader = createObject("component", "javaloader.JavaLoader").init(sourceDirectories=sourcePaths);
			
			//create an instance of hello world
			hello = loader.create("HelloWorld").init();
        </cfscript>
		
		<p>I say: Hello Java!  <br/>
		   Java says:
			<!--- let's say hello --->
			<cfoutput>#hello.hello()#</cfoutput>
		</p>

		<p>
		<a href="src/HelloWorld.java">HelloWorld.java</a>
		</p>
	</body>
</html>