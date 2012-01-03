/**
 * 
 */
package com.compoundtheory.coldfusion.cfc;

import java.io.File;
import java.lang.reflect.InvocationHandler;
import java.lang.reflect.Method;
import java.lang.reflect.Proxy;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.servlet.ServletRequest;
import javax.servlet.ServletResponse;
import javax.servlet.jsp.PageContext;

import coldfusion.cfc.DummyHttpServletRequest;
import coldfusion.cfc.DummyHttpServletResponse;
import coldfusion.filter.FusionContext;
import coldfusion.runtime.NeoPageContext;
import coldfusion.runtime.TemplateProxy;
import coldfusion.runtime.TemplateProxyFactory;
import coldfusion.xml.rpc.CFCServlet;

/**
 * This is a dynamic proxy for ColdFusion components, for complete
 * interoperability between CFCs and Java objects,.
 * 
 * Creation of the Proxy is done through one of the several createInstance() methods.
 * 
 * @author Mark Mandel
 *
 */
public class CFCDynamicProxy implements InvocationHandler
{
	private TemplateProxy cfc;
	private FusionContext backupFusionContext; 
	
	private static enum ObjectMethod {
		
		HASHCODE("hashCode");
		
		public final String name;
		private ObjectMethod(String name)
		{
			this.name = name;
		}
	}
	
	private static final Map<String, ObjectMethod> METHOD_MAP = new HashMap<String, ObjectMethod>();
	static {
		for(ObjectMethod method : ObjectMethod.values())
		{
			METHOD_MAP.put(method.name, method);
		}
	}
	
	/**
	 * Private constructor
	 * @param cfc the CFC that this Proxy wraps
	 */
	private CFCDynamicProxy(TemplateProxy cfc)
	{
		configure(cfc);
	}
	
	/**
	 * Private constructor
	 * @param path the path to the CFC that this proxy wraps.
	 * @throws Throwable
	 */
	private CFCDynamicProxy(String path) throws Throwable
	{
		TemplateProxy cfc = TemplateProxyFactory.resolveFile(FusionContext.getCurrent().pageContext, new File(path), null);
		
		configure(cfc);
	}
	
	/**
	 * Private constructor
	 * @param file A file that points to the CFC this proxy will wrap.
	 * @throws Throwable
	 */
	private CFCDynamicProxy(File file) throws Throwable
	{
		TemplateProxy cfc = TemplateProxyFactory.resolveFile(FusionContext.getCurrent().pageContext, file, null);
		
		configure(cfc);
	}
	
	private void configure(TemplateProxy cfc)
	{
		setCFC(cfc);
		
		//we will make the assumption that when creating the proxy, we are on a CF Context
		
		FusionContext currentContext = FusionContext.getCurrent();

		FusionContext backupContext = new FusionContext();
		
		backupContext.setSecureCredentials(currentContext.getSecureUsername(), currentContext.getSecurePassword());
		backupContext.setUseMappings(currentContext.getUseMappings());
		
		ServletRequest request = new DummyHttpServletRequest(backupContext.getPagePath());
		ServletResponse response = new DummyHttpServletResponse(System.out);
		
		backupContext.setServletObjects(CFCServlet.getCFCServlet(), request, response);
		
		backupContext.setPagePath(currentContext.getPagePath());
		
		backupContext.setApplicationName(currentContext.getApplicationName());
		
		try
		{
			backupContext.SymTab_initForRequest(true);
		}
		catch (Throwable e)
		{
			e.printStackTrace();
		}
		
		setBackupFusionContext(backupContext);		
	}
	
	/**
	 * Create a proxy instance
	 * @param path The File that points to the CFC
	 * @param interfaces the proxy will implement
	 * @return the proxy that implements the interfaces given
	 * @throws Throwable if there is an error in the CFC
	 */
	public static Object createInstance(File path, Class<?>[] interfaces) throws Throwable
	{
		CFCDynamicProxy proxy = new CFCDynamicProxy(path);
		
		return createInstance(proxy, interfaces);
	}
	
	/**
	 * Create a proxy instance
	 * @param path Absolute path to the CFC we want to proxy
	 * @param interfaces the proxy will implement
	 * @return the proxy that implements the interfaces given
	 * @throws Throwable if there is an error in the CFC
	 */
	public static Object createInstance(String path, Class<?>[] interfaces) throws Throwable
	{
		CFCDynamicProxy proxy = new CFCDynamicProxy(path);
		
		return createInstance(proxy, interfaces);
	}

	/**
	 * Create a proxy instance
	 * @param path The File that points to the CFC
	 * @param interfaces An array of the names of the classes that this proxy will implement.
	 * @return the proxy that implements the interfaces given
	 * @throws Throwable if there is an error in the CFC
	 */
	public static Object createInstance(File path, String[] interfaces) throws Throwable
	{
		Class<?>[] resolvedInterfaces = resolveInterfaces(interfaces);
		
		CFCDynamicProxy proxy = new CFCDynamicProxy(path);
		
		return createInstance(proxy, resolvedInterfaces);
	}
	
	/**
	 * Create a proxy instance
	 * @param path Absolute path to the CFC we want to proxy
	 * @param interfaces An array of the names of the classes that this proxy will implement.
	 * @return the proxy that implements the interfaces given
	 * @throws Throwable if there is an error in the CFC
	 */
	public static Object createInstance(String path, String[] interfaces) throws Throwable
	{
		Class<?>[] resolvedInterfaces = resolveInterfaces(interfaces);
		
		CFCDynamicProxy proxy = new CFCDynamicProxy(path);
		
		return createInstance(proxy, resolvedInterfaces);
	}

	/**
	 * Create a proxy instance
	 * @param path Absolute path to the CFC we want to proxy
	 * @param interfaces A List of the names of the classes that this proxy will implement.
	 * @return the proxy that implements the interfaces given
	 * @throws Throwable if there is an error in the CFC
	 */
	public static Object createInstance(String path, List<String> interfaces) throws Throwable
	{
		Class<?>[] resolvedInterfaces = resolveInterfaces(interfaces.toArray(new String[0]));
		
		CFCDynamicProxy proxy = new CFCDynamicProxy(path);
		
		return createInstance(proxy, resolvedInterfaces);
	}	
	
	/**
	 * Create a proxy instance
	 * @param cfc An actual CFC to pass in to the proxy.
	 * @param interfaces the proxy will implement
	 * @return the proxy that implements the interfaces given
	 */
	public static Object createInstance(TemplateProxy cfc, Class<?>[] interfaces)
	{
		CFCDynamicProxy proxy = new CFCDynamicProxy(cfc);
		
		return createInstance(proxy, interfaces);
	}

	/**
	 * Create a proxy instance
	 * @param cfc An actual CFC to pass in to the proxy.
	 * @param interfaces An array of the names of the classes that this proxy will implement.
	 * @return the proxy that implements the interfaces given
	 * @throws Throwable if there is an error in the CFC
	 */
	public static Object createInstance(TemplateProxy cfc, String[] interfaces) throws Throwable
	{
		Class<?>[] resolvedInterfaces = resolveInterfaces(interfaces);
		
		CFCDynamicProxy proxy = new CFCDynamicProxy(cfc);
		
		return createInstance(proxy, resolvedInterfaces);
	}	

	/**
	 * Create a proxy instance
	 * @param cfc An actual CFC to pass in to the proxy.
	 * @param interfaces A List of the names of the classes that this proxy will implement.
	 * @return the proxy that implements the interfaces given
	 * @throws Throwable if there is an error in the CFC
	 */
	public static Object createInstance(TemplateProxy cfc, List<String> interfaces) throws Throwable
	{
		Class<?>[] resolvedInterfaces = resolveInterfaces(interfaces.toArray(new String[0]));
		
		CFCDynamicProxy proxy = new CFCDynamicProxy(cfc);
		
		return createInstance(proxy, resolvedInterfaces);
	}
	

	/**
	 * utility method to create the actual dynamic proxy instance
	 * @param proxy An instance of this class to use as the InvocationHandler
	 * @param interfaces class array for the dynamic proxy
	 * @return
	 */
	private static Object createInstance(CFCDynamicProxy proxy, Class<?>[] interfaces)
	{
		return Proxy.newProxyInstance(proxy.getClass().getClassLoader(), interfaces, proxy);
	}
	
	/**
	 * Turns an array of string class names into an array of classes.
	 * @param interfaces the array of class names 
	 * @return an actual class array
	 * @throws ClassNotFoundException if the Class cannot be found
	 */
	private static Class<?>[] resolveInterfaces(String[] interfaces) throws ClassNotFoundException
	{
		Class<?>[] resolvedInterfaces = new Class<?>[interfaces.length];
		
		ClassLoader classLoader = CFCDynamicProxy.class.getClassLoader();
		
		for(int counter = 0; counter < interfaces.length; counter++)
		{
			resolvedInterfaces[counter] = classLoader.loadClass(interfaces[counter]);
		}
		
		return resolvedInterfaces;
	}	
	
	/* (non-Javadoc)
	 * @see java.lang.reflect.InvocationHandler#invoke(java.lang.Object, java.lang.reflect.Method, java.lang.Object[])
	 */
	@Override
	public Object invoke(Object proxy, Method method, Object[] args) throws Throwable
	{
		if(args == null)
		{
			args = new Object[0];
		}
		
		try
		{
			return getCFC().invoke(method.getName(), args, getCurrentFusionContext());
		}
		catch(TemplateProxy.InvalidMethodNameException exc)
		{
			/**
			 * This is here because when reporting exceptions, CF will ask for the
			 * hashCode of the object, so we will have a backup for certain methods
			 * if need be.
			 */
			String name = method.getName();
			if(METHOD_MAP.containsKey(name))
			{
				ObjectMethod objectMethod = METHOD_MAP.get(name);
				
				switch(objectMethod)
				{
					case HASHCODE:
						return getCFC().hashCode();
					
				}
			}
			
			throw exc;
		}
	}

	/**
	 * Returns the current FusionContext for the given Thread.
	 * If there isn't one, clone's the backup context and uses that instead.
	 * @throws Throwable 
	 * @throws CloneNotSupportedException 
	 */
	private PageContext getCurrentFusionContext() throws Throwable
	{
		FusionContext currentContext = FusionContext.getCurrent();
		
		if(currentContext == null)
		{
			try
			{
				currentContext = (FusionContext)getBackupFusionContext().clone();
				currentContext.SymTab_initForRequest(true);
				
				FusionContext.setCurrent(currentContext);
			}
			catch (CloneNotSupportedException e)
			{
				System.out.println("Really?");
				e.printStackTrace();
			}
		}
		
		//System.out.println("Returning page context (5): ");
		//System.out.println(currentContext.pageContext == null ? "false" : "true");
		
		return currentContext.pageContext;
	}
	
	
	private TemplateProxy getCFC()
	{
		return cfc;
	}

	private void setCFC(TemplateProxy cfc)
	{
		this.cfc = cfc;
	}
	
	private FusionContext getBackupFusionContext()
	{
		return backupFusionContext;
	}

	private void setBackupFusionContext(FusionContext backupFusionContext)
	{
		this.backupFusionContext = backupFusionContext;
	}
	
	
}
