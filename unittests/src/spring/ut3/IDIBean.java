package ut3;

import ut2.IFoo;

/**
 * Interface for DI testing
 * @author Mark Mandel
 *
 */
public interface IDIBean
{
	public void init();
	public String getInitValue();
	public String getStringValue();
	public void setStringValue(String value);

	public IBar getBar();
	public void setBar(IBar bar);
}