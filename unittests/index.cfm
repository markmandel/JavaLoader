
<cfinvoke component="mxunit.runner.DirectoryTestSuite"
			method="run"
			directory="#expandPath('/unittests')#"
			componentPath="ut.unittests"
			recurse="true"
			excludes=""
			returnvariable="results" />

 <cfoutput> #results.getResultsOutput('html')# </cfoutput>