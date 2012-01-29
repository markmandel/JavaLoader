<cfcomponent hint="Implements the java.util.concurrent.Callable interface">

<cfscript>
	variables.id = 0;
	variables.name = "";
	status = "pending";
	result = { status = status, createts = now() };
</cfscript>

<!------------------------------------------- PUBLIC ------------------------------------------->

<cffunction name="init" hint="Constructor" access="public" returntype="ThingieDoer" output="false">
	<<cfscript>
		structAppend(variables, arguments);
		return this;
	</cfscript>
</cffunction>

<cffunction name="call" hint="call function" access="public" returntype="any" output="false">
	<cfscript>
		try
		{
			//writeLog("inside call for id #id#");
			result.status ="complete";
			result.success = true;
		}
		catch( any ex )
		{
			result.status ="error";
			result.error = ex;
			//writeLog("Call errored!");
		}

		result.completets = now();

		return result;
	</cfscript>
</cffunction>

<cffunction name="$toString" hint="to a string" access="public" returntype="string" output="false">
	<cfreturn variables.name />
</cffunction>

<!------------------------------------------- PACKAGE ------------------------------------------->

<!------------------------------------------- PRIVATE ------------------------------------------->
</cfcomponent>