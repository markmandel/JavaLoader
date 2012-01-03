/**
 * 
 */
package ut3;

/**
 * A bean for some Foo goodness
 * 
 * @author Mark Mandel
 *
 */
public class Bar implements IBar
{
	public Bar()
	{
		System.out.println("Creating Bar! v2?");
	}
	
	/* (non-Javadoc)
	 * @see ut3.IBar#getValue()
	 */
	public String getValue()
	{
		return "Foo!";
	}
}