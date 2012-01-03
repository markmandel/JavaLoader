/**
* created by javaloader. implements the java.util.concurrent.Callable interface
*/
component{

	variables.id = 0;
	variables.name = "";
	status = "pending";
	result = { status = status, createts = now() };

	function init(numeric id, string name){
		structAppend(variables, arguments);
		return this;
	}

	public any function call(){
		try{
			writeLog("inside call for id #id#");
			result.status = "complete";
			result.success = true;

		}catch( any ex ){
			result.status = "error";
			result.error = ex;
			writeLog("Call errored!");
		}
		result.completets = now();
		return result;
	}

	function toString(){
		return name;
	}

}
