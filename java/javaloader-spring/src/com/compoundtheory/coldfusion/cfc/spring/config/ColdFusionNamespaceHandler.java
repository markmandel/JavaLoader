package com.compoundtheory.coldfusion.cfc.spring.config;

import org.springframework.beans.factory.xml.NamespaceHandlerSupport;

/**
 * Namespace handler for the <coldfusion:> Spring XML namespace
 * 
 * @author Mark Mandel
 *
 */
public class ColdFusionNamespaceHandler extends NamespaceHandlerSupport
{

	/* (non-Javadoc)
	 * @see org.springframework.beans.factory.xml.NamespaceHandler#init()
	 */
	@Override
	public void init()
	{
		registerBeanDefinitionParser("cfc", new ColdFusionBeanDefinitionParser());
	}
}