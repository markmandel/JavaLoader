/**
 * 
 */
package com.compoundtheory.coldfusion.cfc.spring;

import java.io.File;
import java.io.IOException;

import org.springframework.scripting.ScriptCompilationException;
import org.springframework.scripting.ScriptFactory;
import org.springframework.scripting.ScriptSource;
import org.springframework.util.Assert;
import org.springframework.util.ResourceUtils;

import com.compoundtheory.coldfusion.cfc.CFCDynamicProxy;

/**
 * ScriptFactory for creating a CFC Dynamic Proxy to pass back to Spring
 * A lot of this was lifted from {@link org.springframework.scripting.config.ScriptBeanDefinitionParser}, so big
 * credit to that crew.
 * 
 * @author Mark Mandel
 *
 */
public class ColdFusionComponentFactory implements ScriptFactory
{
	private Class<?>[] interfaces;
	private String scriptSourceLocator;
	
	public ColdFusionComponentFactory(String scriptSourceLocator, Class<?>[] interfaces)
	{
		Assert.hasText(scriptSourceLocator, "'scriptSourceLocator' must not be empty");
		Assert.notEmpty(interfaces, "'scriptInterfaces' must not be empty");
		
		setScriptInterfaces(interfaces);
		setScriptSourceLocator(scriptSourceLocator);
	}
	
	/* (non-Javadoc)
	 * @see org.springframework.scripting.ScriptFactory#getScriptedObject(org.springframework.scripting.ScriptSource, java.lang.Class[])
	 */
	@SuppressWarnings("unchecked")
	@Override
	public Object getScriptedObject(ScriptSource scriptSource, Class[] actualInterfaces) throws IOException, ScriptCompilationException
	{
		try
		{
			File file = ResourceUtils.getFile(getScriptSourceLocator());
			
			return CFCDynamicProxy.createInstance(file, actualInterfaces);
		}
		catch (Throwable e)
		{
			ScriptCompilationException sce = new ScriptCompilationException(scriptSource, e);
			
			throw sce;
		}
	}

	/**
	 * returns null, as we are actually returning a proxy.
	 */
	@Override
	public Class<?> getScriptedObjectType(ScriptSource scriptSource) throws IOException, ScriptCompilationException
	{
		return null;
	}

	/* (non-Javadoc)
	 * @see org.springframework.scripting.ScriptFactory#getScriptSourceLocator()
	 */
	@Override
	public String getScriptSourceLocator()
	{
		return this.scriptSourceLocator;
	}

	/**
	 * @param scriptSourceLocator the scriptSourceLocator to set
	 */
	private void setScriptSourceLocator(String scriptSourceLocator)
	{
		this.scriptSourceLocator = scriptSourceLocator;
	}

	/**
	 * ColdFusion proxies require a config interface
	 */
	@Override
	public boolean requiresConfigInterface()
	{
		return true;
	}

	/* (non-Javadoc)
	 * @see org.springframework.scripting.ScriptFactory#requiresScriptedObjectRefresh(org.springframework.scripting.ScriptSource)
	 */
	@Override
	public boolean requiresScriptedObjectRefresh(ScriptSource scriptSource)
	{
		return scriptSource.isModified();
	}

	/* (non-Javadoc)
	 * @see org.springframework.scripting.ScriptFactory#getScriptInterfaces()
	 */
	@Override
	public Class<?>[] getScriptInterfaces()
	{
		return this.interfaces;
	}

	/**
	 * @param interfaces the interfaces to set
	 */
	private void setScriptInterfaces(Class<?>[] interfaces)
	{
		this.interfaces = interfaces;
	}

	public String toString() 
	{
		return "ColdFusionComponentFactory: script source locator [" + this.scriptSourceLocator + "]";
	}
}
