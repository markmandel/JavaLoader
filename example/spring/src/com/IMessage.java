package com;

/**
 * A simple interface for storing a message
 * @author Mark Mandel
 */
public interface IMessage
{
	/**
	 * Initialisation
	 */
	public void init();
	
	/**
	 * Returns the message held by this object
	 */
	public String getMessage();
}