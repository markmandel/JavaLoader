package ut3;

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
}
