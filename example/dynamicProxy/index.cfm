<html>
	<head><title>JavaLoader Dynamic Proxy Example</title></head>
	<style type="text/css">
		body {
			font-family: Verdana, Helvetica, san-serif;
			font-size: small;
		}
	</style>
	<body>
		<p>
			This is an example of how we can use the ColdFusion Component Dynamic Proxy to pass a CFC to a Java Object
			and have the Java Object think that it is simply an instance of a Java Interface.
		</p>
		<p>
			In this example, we will take an array of Strings, and sort them by the number of letters in each String.
		</p>
		<p>
			We will use the dynamic proxy so we can use a ColdFusion Component as a <a href="http://java.sun.com/javase/6/docs/api/java/util/Comparator.html">Comparator</a>
			in a <a href="http://java.sun.com/javase/6/docs/api/java/util/Collections.html#sort(java.util.List,%20java.util.Comparator)">Collections.sort()</a> call, thus
			demonstrating how we can achieve seamlesss communication from Java Objects to ColdFusion Components
		</p>
		<cfscript>
			//this is our array to sort
			stringArray = ["Hello", "GoodBye", "Yes", "No", "Wait a second!", "Do something"];
			
			//keep a copy to show
			originalStringArray = duplicate(stringArray);
			
			//add the javaloader dynamic proxy library to javaloader
			libpaths = [];
			ArrayAppend(libpaths, expandPath("/javaloader/support/cfcdynamicproxy/lib/cfcdynamicproxy.jar"));
			
			//we HAVE to load the ColdFusion class path to use the dynamic proxy, as it uses ColdFusion's classes
			loader = createObject("component", "javaloader.JavaLoader").init(loadPaths=libpaths, loadColdFusionClassPath=true);
			
			//grab us Collections
			Collections = createObject("java", "java.util.Collections");

			//get a reference to the dynamic proxy class
			CFCDynamicProxy = loader.create("com.compoundtheory.coldfusion.cfc.CFCDynamicProxy");
			
			//grab us our CFC that will act as a comparator
			comparator = createObject("component", "StringLenComparator");
			
			//we can pass in an array of strings which name all the interfaces we want out dynamic proxy to implement
			interfaces = ["java.util.Comparator"];
			
			//create the proxy we will pass to the Collections object
			comparatorProxy = CFCDynamicProxy.createInstance(comparator, interfaces);
			
			Collections.sort(stringArray, comparatorProxy);
        </cfscript>
		<p>
		The original string array:
		<cfdump var="#originalStringArray#">
		</p>
		<p>
		The sorted String array, by string length
		<cfdump var="#stringArray#" label="Sorted String Array">
		</p>
	</body>
</html>