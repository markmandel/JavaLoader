<html>
	<head><title>JavaLoader Spring Example</title></head>
	<style type="text/css">
		body {
			font-family: Verdana, Helvetica, san-serif;
			font-size: small;
		}
	</style>
	<body>
		<p>
			In this example we will be using the Spring integration that enables us to use ColdFusion components inside Spring.
		</p>
		<p>
			Some bootstrap code will be neccessary to make Spring work in this environment.
		</p>
		<p>
			We will also being using the dynamic compilation power of JavaLoader to provide the Java objects that Spring is going to utilise
		</p>
		<p>
			We will create a Java Object called <a href="src/com/MessageReceiver.java">MessageReciever</a>, which will take a CFC named 'Message',
			which has a method called 'getMessage()', which the Java object will call.
		</p>

		<cfscript>
			libpaths = [];

			//MUST have Spring in our classpath
			ArrayAppend(libpaths, expandPath("./lib/spring.jar"));
			//MUST have the cglib library for run time proxying in Spring
			ArrayAppend(libpaths, expandPath("./lib/cglib-nodep-2.1_3.jar"));

			//MUST have the JavaLoader's ColdFusion Dynamic Proxy
			ArrayAppend(libpaths, expandPath("/javaloader/support/cfcdynamicproxy/lib/cfcdynamicproxy.jar"));
			//MUST include the JavaLoader's Spring Integration library
			ArrayAppend(libpaths, expandPath("/javaloader/support/spring/lib/spring-coldfusion.jar"));

			//this is the directory that stores all our Java source
			srcpaths = [ expandPath("./src") ];

			//We have to load the ColdFusion classpath as the ColdFusion dynamic proxy requires it.
			loader = createObject("component", "javaloader.JavaLoader").init(loadPaths=libpaths, loadColdFusionClassPath=true, sourceDirectories=srcpaths);

			//this is the path to our XML file. Note the 'file://' prefix, this is important to Spring
			path = "file://" & expandPath("./spring.xml");
			//Some windows users need to use this: path = "file:/" & expandPath("./spring.xml");

			//The FileSystemXMLApplicationContext I find is the easiest way to load up Spring
			spring = loader.create("org.springframework.context.support.FileSystemXmlApplicationContext").init();

			/*
			we HAVE to set the classloader from JavaLoader as the Spring ClassLoader, so Spring knows where
			to create Java Object from.
			*/
			spring.setClassLoader(loader.getURLClassLoader());

			spring.setConfigLocation(path);

			spring.refresh();

			//finally, after all that, let's grab our MessageReciever Java Object!
			messageReceiver = spring.getBean("messageReceiver");
        </cfscript>
		<p>
			Spring Says:
			<cfoutput>
			<strong>#messageReceiver.getMessage().getMessage()#</strong>
			</cfoutput>
		</p>
	</body>
</html>