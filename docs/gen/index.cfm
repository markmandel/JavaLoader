<cfsetting requesttimeout="9600">

<cfoutput>
<cfscript>
	base = expandPath("/javaloader");
	path = expandPath("../api/javaloader");

	colddoc = createObject("component", "colddoc.ColdDoc").init();
	strategy = createObject("component", "colddoc.strategy.api.HTMLAPIStrategy").init(path, "JavaLoader - 1.1");
	colddoc.setStrategy(strategy);

	colddoc.generate(base, "javaloader");
</cfscript>
</cfoutput>
<h1>Done!</h1>

<p>
<cfoutput>#now()#</cfoutput>
</p>

<a href="../api/javaloader">Documentation</a>
