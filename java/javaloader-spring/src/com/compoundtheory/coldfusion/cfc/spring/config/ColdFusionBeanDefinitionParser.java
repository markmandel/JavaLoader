/**
 * 
 */
package com.compoundtheory.coldfusion.cfc.spring.config;

import org.springframework.beans.factory.config.ConstructorArgumentValues;
import org.springframework.beans.factory.support.AbstractBeanDefinition;
import org.springframework.beans.factory.support.BeanDefinitionDefaults;
import org.springframework.beans.factory.support.GenericBeanDefinition;
import org.springframework.beans.factory.xml.AbstractBeanDefinitionParser;
import org.springframework.beans.factory.xml.ParserContext;
import org.springframework.scripting.config.LangNamespaceUtils;
import org.springframework.util.StringUtils;
import org.w3c.dom.Element;

import coldfusion.filter.FusionContext;
import coldfusion.util.Utils;

import com.compoundtheory.coldfusion.cfc.spring.ColdFusionComponentFactory;

/**
 * Bean definition parser for the <coldfusion:> Spring namespace
 * 
 * @author Mark Mandel
 *
 */
public class ColdFusionBeanDefinitionParser extends AbstractBeanDefinitionParser
{
	
	private static final String SCRIPT_SOURCE_ATTRIBUTE = "script-source";
	private static final String SCRIPT_SOURCE_RELATIVE_ATTRIBUTE = "script-source-relative";
	private static final String SCRIPT_INTERFACES_ATTRIBUTE = "script-interfaces";
	private static final String SCOPE_ATTRIBUTE = "scope";
	private static final String AUTOWIRE_ATTRIBUTE = "autowire";
	private static final String DEPENDENCY_CHECK_ATTRIBUTE = "dependency-check";
	private static final String INIT_METHOD_ATTRIBUTE = "init-method";
	private static final String DESTROY_METHOD_ATTRIBUTE = "destroy-method";

	/**
	 * Constructor
	 */
	public ColdFusionBeanDefinitionParser()
	{
		super();
	}

	/* (non-Javadoc)
	 * @see org.springframework.beans.factory.xml.AbstractBeanDefinitionParser#parseInternal(org.w3c.dom.Element, org.springframework.beans.factory.xml.ParserContext)
	 */
	@Override
	protected AbstractBeanDefinition parseInternal(Element element, ParserContext parserContext)
	{
		//leverage the Scripting post processor
		LangNamespaceUtils.registerScriptFactoryPostProcessorIfNecessary(parserContext.getRegistry());
		
		//do a bean definition
		GenericBeanDefinition beanDef = new GenericBeanDefinition();
		
		beanDef.setSource(parserContext.extractSource(element));
		beanDef.setBeanClass(ColdFusionComponentFactory.class);
		
		// Determine bean scope.
		String scope = element.getAttribute(SCOPE_ATTRIBUTE);
		if (StringUtils.hasLength(scope))
		{
			beanDef.setScope(scope);
		}
		
		// Determine autowire mode.
		String autowire = element.getAttribute(AUTOWIRE_ATTRIBUTE);
		
		int autowireMode = parserContext.getDelegate().getAutowireMode(autowire);
		// Only "byType" and "byName" supported, but maybe other default
		// inherited...
		
		if (autowireMode == GenericBeanDefinition.AUTOWIRE_AUTODETECT)
		{
			autowireMode = GenericBeanDefinition.AUTOWIRE_BY_TYPE;
		}
		else if (autowireMode == GenericBeanDefinition.AUTOWIRE_CONSTRUCTOR)
		{
			autowireMode = GenericBeanDefinition.AUTOWIRE_NO;
		}
		beanDef.setAutowireMode(autowireMode);

		// Determine dependency check setting.
		String dependencyCheck = element.getAttribute(DEPENDENCY_CHECK_ATTRIBUTE);
		beanDef.setDependencyCheck(parserContext.getDelegate().getDependencyCheck(dependencyCheck));

		// Retrieve the defaults for bean definitions within this parser context
		BeanDefinitionDefaults beanDefinitionDefaults = parserContext.getDelegate().getBeanDefinitionDefaults();

		// Determine init method and destroy method.
		String initMethod = element.getAttribute(INIT_METHOD_ATTRIBUTE);
		if (StringUtils.hasLength(initMethod))
		{
			beanDef.setInitMethodName(initMethod);
		}
		else if (beanDefinitionDefaults.getInitMethodName() != null)
		{
			beanDef.setInitMethodName(beanDefinitionDefaults.getInitMethodName());
		}

		String destroyMethod = element.getAttribute(DESTROY_METHOD_ATTRIBUTE);
		if (StringUtils.hasLength(destroyMethod))
		{
			beanDef.setDestroyMethodName(destroyMethod);
		}
		else if (beanDefinitionDefaults.getDestroyMethodName() != null)
		{
			beanDef.setDestroyMethodName(beanDefinitionDefaults.getDestroyMethodName());
		}
		
		ConstructorArgumentValues constructorArgs = beanDef.getConstructorArgumentValues();
		
		String scriptSource = element.getAttribute(SCRIPT_SOURCE_ATTRIBUTE);
		
		//have to do this here, as otherwise the Script post processor will take over
		if(!element.hasAttribute(SCRIPT_SOURCE_RELATIVE_ATTRIBUTE) || element.getAttribute(SCRIPT_SOURCE_RELATIVE_ATTRIBUTE).equals("true"))
		{
			//strip off the file://
			scriptSource = scriptSource.substring(7);
			
			scriptSource = Utils.expandPath(scriptSource, FusionContext.getCurrent().pageContext);
			
			scriptSource = "file://" + scriptSource;
		}
		
		String[] interfaces = element.getAttribute(SCRIPT_INTERFACES_ATTRIBUTE).split(",");
		
		constructorArgs.addIndexedArgumentValue(0, scriptSource);
		constructorArgs.addIndexedArgumentValue(1, interfaces);

		// Add any property definitions that need adding.
		parserContext.getDelegate().parsePropertyElements(element, beanDef);
		
		return beanDef;
	}
}
