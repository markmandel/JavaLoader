package ut2;

import coldfusion.runtime.TemplateProxy;

import com.compoundtheory.coldfusion.cfc.CFCDynamicProxy;

/**
 * Test cfc proxy
 * @author Mark Mandel
 *
 */
public class CFCProxyTest
{
	public CFCProxyTest()
	{
	}
	
	public IFoo getDynamicProxy(TemplateProxy cfc)
	{
		Class<?>[] interfaces = { IFoo.class };
		
		IFoo foo = (IFoo)CFCDynamicProxy.createInstance(cfc, interfaces);
		
		return foo;
	}
	
	public Object runDynamicProxyFoo(TemplateProxy cfc)
	{
		IFoo foo = getDynamicProxy(cfc);
		
		return foo.foo("Hello from dyanmic proxy");
	}
}
