<cfcomponent hint="Class that impleements Runnable" output="false">

<!------------------------------------------- PUBLIC ------------------------------------------->

<cffunction name="init" hint="Constructor" access="public" returntype="Runnable" output="false">
	<cfscript>
		setValue("Foo");

		return this;
	</cfscript>
</cffunction>

<cffunction name="run" hint="When an object implementing interface Runnable is used to create a thread, starting the thread causes the object's run method to be called in that separately executing thread."
		access="public" returntype="void" output="false">
	<cfscript>
		setValue("Bar");
    </cfscript>
</cffunction>

<!------------------------------------------- PACKAGE ------------------------------------------->

<!------------------------------------------- PRIVATE ------------------------------------------->

<cffunction name="getValue" access="public" returntype="any" output="false">
	<cfreturn instance.Value />
</cffunction>

<cffunction name="setValue" access="private" returntype="void" output="false">
	<cfargument name="Value" type="any" required="true">
	<cfset instance.Value = arguments.Value />
</cffunction>

</cfcomponent>