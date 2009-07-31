<cfcomponent extends="unittests.AbstractTestCase" output="false">

<!------------------------------------------- PUBLIC ------------------------------------------->

<cffunction name="setup" hint="setup function" access="public" returntype="void" output="false">
	<cfscript>
		var local = {};
		super.setup();
		clean();
		
		local.libpaths = [];
		ArrayAppend(local.libpaths, expandPath("/javaloader/support/cfcdynamicproxy/lib/cfcdynamicproxy.jar"));
		
		local.srcparths = [instance.srcPath & "/dynamicproxy"];
		
		instance.loader = createObject("component", "javaloader.JavaLoader").init(loadPaths=local.libpaths, loadColdFusionClassPath=true, sourceDirectories=local.srcparths);		
    </cfscript>
</cffunction>

<cffunction name="simpleCFCTest" hint="test to create a CFC dynamic proxy, and call it from within CF" access="public" returntype="void" output="false">
	<cfscript>
		var local = {};
		
		
		local.cfcProxyTest = instance.loader.create("ut2.CFCProxyTest").init();
		
		local.bar = createObject("component", "SimpleBean");
		
		local.proxy = local.cfcProxyTest.getDynamicProxy(local.bar);
		
		assertEquals("Hello!", local.proxy.foo("Hello!"));
		
		assertEquals("I could not find my method: doesNotExist", local.proxy.doesNotExist());
		
		local.catch = false;
		
		try
        {
        	local.proxy.thisMethodReallyDoesNotExist();
        }
        catch(Object exc)
        {
			local.catch = true;
        }
		
		AssertTrue(local.catch, "Exception should be thrown");
		
		debug(local.cfcProxyTest);
		
		AssertEquals(local.cfcProxyTest.runDynamicProxyFoo(local.bar), "Hello from dyanmic proxy");
    </cfscript>
</cffunction>

<cffunction name="simpleCFCPathTest" hint="test to create a CFC dynamic proxy, and call it from within CF" access="public" returntype="void" output="false">
	<cfscript>
		var local = {};
		
		local.cfcProxyTest = instance.loader.create("ut2.CFCProxyTest").init();
		
		local.path = expandPath("/unittests/dynamicproxy/SimpleBean.cfc");
		
		local.proxy = local.cfcProxyTest.getDynamicProxy(local.path);
		
		assertEquals("Hello!", local.proxy.foo("Hello!"));
		
		assertEquals("I could not find my method: doesNotExist", local.proxy.doesNotExist());
		
		local.catch = false;
		
		try
        {
        	local.proxy.thisMethodReallyDoesNotExist();
        }
        catch(Object exc)
        {
			local.catch = true;
        }
		
		AssertTrue(local.catch, "Exception should be thrown");
		
		AssertEquals(local.cfcProxyTest.runDynamicProxyFoo(local.path), "Hello from dyanmic proxy");
    </cfscript>
</cffunction>

<cffunction name="requestScopeTest" hint="test if the request scope passes through" access="public" returntype="void" output="false">
	<cfscript>
		local.bar = createObject("component", "RequestBean");
		
		local.cfcProxyTest = instance.loader.create("ut2.CFCProxyTest").init();
		
		local.proxy = local.cfcProxyTest.getDynamicProxy(local.bar);
		
		request.foo = "yadda";
		
		AssertEquals("yadda :: Hello", local.proxy.foo("Hello"));
		
		local.path = expandPath("/unittests/dynamicproxy/RequestBean.cfc");
		
		local.proxy = local.cfcProxyTest.getDynamicProxy(local.path);
		
		request.foo = "yadda";
		
		AssertEquals("yadda :: Hello", local.proxy.foo("Hello"));		
    </cfscript>
</cffunction>

<cffunction name="applicationScopeTest" hint="test if the app scope passes through" access="public" returntype="void" output="false">
	<cfscript>
		local.bar = createObject("component", "ApplicationBean");
		
		local.cfcProxyTest = instance.loader.create("ut2.CFCProxyTest").init();
		
		local.proxy = local.cfcProxyTest.getDynamicProxy(local.bar);
		
		application.foo = "yadda";
		
		AssertEquals("yadda :: Hello", local.proxy.foo("Hello"));
		
		local.path = expandPath("/unittests/dynamicproxy/ApplicationBean.cfc");
		
		local.proxy = local.cfcProxyTest.getDynamicProxy(local.path);
		
		request.foo = "yadda";
		
		AssertEquals("yadda :: Hello", local.proxy.foo("Hello"));		
    </cfscript>
</cffunction>

<cffunction name="sessionScopeTest" hint="test if the session scope passes through" access="public" returntype="void" output="false">
	<cfscript>
		local.bar = createObject("component", "SessionBean");
		
		local.cfcProxyTest = instance.loader.create("ut2.CFCProxyTest").init();
		
		local.proxy = local.cfcProxyTest.getDynamicProxy(local.bar);
		
		session.foo = "yadda";
		
		AssertEquals("yadda :: Hello", local.proxy.foo("Hello"));
		
		local.path = expandPath("/unittests/dynamicproxy/SessionBean.cfc");
		
		local.proxy = local.cfcProxyTest.getDynamicProxy(local.path);
		
		session.foo = "yadda";
		
		AssertEquals("yadda :: Hello", local.proxy.foo("Hello"));
    </cfscript>
</cffunction>

<cffunction name="errorInCodeTest" hint="test if the session scope passes through" access="public" returntype="void" output="false">
	<cfscript>
		local.bar = createObject("component", "SessionBean");
		
		local.cfcProxyTest = instance.loader.create("ut2.CFCProxyTest").init();
		
		local.proxy = local.cfcProxyTest.getDynamicProxy(local.bar);
		
		StructClear(session);
		
		local.check = false;
		
		try
		{
			AssertEquals("yadda :: Hello", local.proxy.foo("Hello"));
		}
		catch(Expression exc)
		{
			AssertEquals("Element FOO is undefined in SESSION.", exc.message);
			local.check = true;
		}
		
		AssertTrue(local.check, "Exception should have fired");
    </cfscript>
</cffunction>


<!------------------------------------------- PACKAGE ------------------------------------------->

<!------------------------------------------- PRIVATE ------------------------------------------->

</cfcomponent>