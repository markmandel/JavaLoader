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

		local.bar = createObject("component", "cfc.SimpleBean");

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

		debug(local.proxy);

		local.interfaces = local.proxy.getClass().getInterfaces();
		for(local.i = 1; local.i lte arraylen(local.interfaces); local.i++)
		{
			local.class = local.interfaces[local.i];
			debug(local.class.toString());

			assertEquals(local.class.getName(), "ut2.IFoo");
		}

		AssertEquals(local.cfcProxyTest.runDynamicProxyFoo(local.bar), "Hello from dyanmic proxy");
    </cfscript>
</cffunction>

<cffunction name="simpleCFCPathTest" hint="test to create a CFC dynamic proxy, and call it from within CF" access="public" returntype="void" output="false">
	<cfscript>
		var local = {};

		local.cfcProxyTest = instance.loader.create("ut2.CFCProxyTest").init();

		local.path = expandPath("/unittests/dynamicproxy/cfc/SimpleBean.cfc");

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
		local.bar = createObject("component", "cfc.RequestBean");

		local.cfcProxyTest = instance.loader.create("ut2.CFCProxyTest").init();

		local.proxy = local.cfcProxyTest.getDynamicProxy(local.bar);

		request.foo = "yadda";

		AssertEquals("yadda :: Hello", local.proxy.foo("Hello"));

		local.path = expandPath("/unittests/dynamicproxy/cfc/RequestBean.cfc");

		local.proxy = local.cfcProxyTest.getDynamicProxy(local.path);

		request.foo = "yadda";

		AssertEquals("yadda :: Hello", local.proxy.foo("Hello"));
    </cfscript>
</cffunction>

<cffunction name="applicationScopeTest" hint="test if the app scope passes through" access="public" returntype="void" output="false">
	<cfscript>
		local.bar = createObject("component", "cfc.ApplicationBean");

		local.cfcProxyTest = instance.loader.create("ut2.CFCProxyTest").init();

		local.proxy = local.cfcProxyTest.getDynamicProxy(local.bar);

		application.foo = "yadda";

		AssertEquals("yadda :: Hello", local.proxy.foo("Hello"));

		local.path = expandPath("/unittests/dynamicproxy/cfc/ApplicationBean.cfc");

		local.proxy = local.cfcProxyTest.getDynamicProxy(local.path);

		request.foo = "yadda";

		AssertEquals("yadda :: Hello", local.proxy.foo("Hello"));
    </cfscript>
</cffunction>

<cffunction name="sessionScopeTest" hint="test if the session scope passes through" access="public" returntype="void" output="false">
	<cfscript>
		local.bar = createObject("component", "cfc.SessionBean");

		local.cfcProxyTest = instance.loader.create("ut2.CFCProxyTest").init();

		local.proxy = local.cfcProxyTest.getDynamicProxy(local.bar);

		session.foo = "yadda";

		AssertEquals("yadda :: Hello", local.proxy.foo("Hello"));

		local.path = expandPath("/unittests/dynamicproxy/cfc/SessionBean.cfc");

		local.proxy = local.cfcProxyTest.getDynamicProxy(local.path);

		session.foo = "yadda";

		AssertEquals("yadda :: Hello", local.proxy.foo("Hello"));
    </cfscript>
</cffunction>

<cffunction name="errorInCodeTest" hint="test if the session scope passes through" access="public" returntype="void" output="false">
	<cfscript>
		local.bar = createObject("component", "cfc.SessionBean");

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

<cffunction name="testDynamicProxyInAnotherThread" hint="testing a dynamic proxy executing in another thread" access="public" returntype="void" output="false">
	<cfscript>
		var local = {};
		local.CFCDynamicProxy = instance.loader.create("com.compoundtheory.coldfusion.cfc.CFCDynamicProxy");

		local.runnable = createObject("component", "cfc.Runnable").init();
		local.interfaces = ["java.lang.Runnable"];
		local.proxy = local.CFCDynamicProxy.createInstance(local.runnable, local.interfaces);

		assertEquals("Foo", local.runnable.getValue());

		local.thread = createObject("java", "java.lang.Thread").init(local.proxy);

		local.thread.start();

		local.thread.join();

		assertEquals("Bar", local.runnable.getValue());
    </cfscript>
</cffunction>

<cffunction name="executorServiceTest" hint="test the executor service with the Dynamic proxy" access="public" returntype="any" output="false">
	<cfscript>
		var local = {};

		local.completionQueue = createObject("java", "java.util.concurrent.LinkedBlockingQueue").init(1000000);
		local.executor = createObject("java", "java.util.concurrent.Executors").newFixedThreadPool(4);
		local.completionService = createObject("java", "java.util.concurrent.ExecutorCompletionService").init(local.executor, local.completionQueue);
		local.timeUnit = createObject("java", "java.util.concurrent.TimeUnit");
		local.CFCDynamicProxy = instance.loader.create("com.compoundtheory.coldfusion.cfc.CFCDynamicProxy");


		//guard... ensure the object works correctly when called directly
		local.sanity = createObject("component", "cfc.ThingieDoer").init(1, "normal old thingiedoer");
		local.result = local.sanity.call();
		assertTrue( local.result.success );
		assertFalse( structKeyExists(local.result, "error") );

		//now move on to the real test
		local.interfaces = ["java.util.concurrent.Callable"];
		local.thingieDoer = createObject("component", "cfc.ThingieDoer").init(1 , "name 1" );
		local.thingieProxy = local.CFCDynamicProxy.createInstance(local.thingieDoer, local.interfaces);

		//submit the proxy. This should cause the completionService to run it immediately;
		local.completionService.submit( local.thingieProxy ); //this doesn't error, but the call() method never gets run

		//ensure what we've submitted gets run, then shut down the service
		local.executor.awaitTermination( javacast("int",1), local.timeUnit.SECONDS );

		//get the "future" object, which is the result of completionService running the proxy's call() method
		local.futureResult = local.completionService.poll();

		//boom
		local.callResult = local.futureResult.get();
		assertTrue( local.callResult.success );
		assertFalse( structKeyExists( local.callResult, "error" ) );

    </cfscript>
</cffunction>

<!------------------------------------------- PACKAGE ------------------------------------------->

<!------------------------------------------- PRIVATE ------------------------------------------->

</cfcomponent>