package com;

/**
 * A class that should recieve a message
 * @author Mark Mandel
 *
 */
public class MessageReceiver
{
	private IMessage message;
	
	public MessageReceiver()
	{
		//we don't do much here
	}
	
	//get/set methods for Spring to fill
	public IMessage getMessage()
	{
		return message;
	}
	
	public void setMessage(IMessage message)
	{
		this.message = message;
	}
}