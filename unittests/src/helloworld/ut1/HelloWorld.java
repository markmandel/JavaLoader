package ut1;

public class HelloWorld
{
	private String msg = "Hello World";
	
	public HelloWorld()
	{
		//this is just here to see if dependent objects get added
		new Dependency();
	}
	
	public HelloWorld(String msg)
	{
		this.msg = msg;
	}
	
	public String hello()
	{
		return msg;
	}
}
