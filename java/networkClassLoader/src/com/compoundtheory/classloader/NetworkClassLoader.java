/*
 * ====================================================================
 *
 * The Apache Software License, Version 1.1
 *
 * Copyright (c) 1999 The Apache Software Foundation.  All rights 
 * reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 *
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer. 
 *
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in
 *    the documentation and/or other materials provided with the
 *    distribution.
 *
 * 3. The end-user documentation included with the redistribution, if
 *    any, must include the following acknowlegement:  
 *       "This product includes software developed by the 
 *        Apache Software Foundation (http://www.apache.org/)."
 *    Alternately, this acknowlegement may appear in the software itself,
 *    if and wherever such third-party acknowlegements normally appear.
 *
 * 4. The names "The Jakarta Project", "Tomcat", and "Apache Software
 *    Foundation" must not be used to endorse or promote products derived
 *    from this software without prior written permission. For written 
 *    permission, please contact apache@apache.org.
 *
 * 5. Products derived from this software may not be called "Apache"
 *    nor may "Apache" appear in their names without prior written
 *    permission of the Apache Group.
 *
 * THIS SOFTWARE IS PROVIDED ``AS IS'' AND ANY EXPRESSED OR IMPLIED
 * WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
 * OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED.  IN NO EVENT SHALL THE APACHE SOFTWARE FOUNDATION OR
 * ITS CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 * SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
 * LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF
 * USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 * OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT
 * OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
 * SUCH DAMAGE.
 * ====================================================================
 */

package com.compoundtheory.classloader;

import java.net.*;
import java.util.*;
import java.io.*;

/**
 * <p>
 * The correct name for this class should be URLClassLoader. But there is
 * already a class by that name in JDK1.2.
 * 
 * I have had quite a few problems with URLClassLoader in past, so I ended up
 * writing this ClassLoader. I found that the Java 2's URLClassLoader, does not
 * close the Jar file once opened. It is a pretty good optimization step, but if
 * you modify the class in the jar file, it does not pick it up. Some operating
 * systems may not let you modify the jar file while it is still open. IMHO, it
 * does make sense to close the jar file after you are done reading the class
 * data. But this approach may not get you the performance of the
 * URLClassLoader, but it works in all cases and also runs on JDK1.1. I have
 * enhanced this class loader to read all the zip/jar entries once & cache the
 * data, so that there is no overhead of opening/closing jar file to pick up
 * each entry.
 * </p>
 * 
 * <p>
 * Modified and enhanced by Mark Mandel to work specifically with ColdFusion, in
 * specific contexts.
 * </p>
 * 
 * @author Harish Prabandham
 */
public class NetworkClassLoader extends ClassLoader
{
	private ClassLoader parent = null; // parent classloader
	private Map classCache = new Hashtable();
	private Hashtable urlset = new Hashtable();
	private Set unfoundResources = new HashSet();

	public NetworkClassLoader()
	{
		super(null);
		// debug("creating network class loader...");
	}

	/**
	 * Creates a new instance of the class loader.
	 * 
	 * @param delegate
	 *            /parent class loader.
	 */
	public NetworkClassLoader(ClassLoader parent)
	{
		super(parent);
		// debug("creating network class loader... with a parent");
		setParent(parent);
	}

	/**
	 * Sets the parent/delegate class loader.
	 * 
	 * @param delegate
	 *            /parent class loader.
	 */
	protected final void setParent(ClassLoader parent)
	{
		this.parent = parent;
	}

	/**
	 * Adds the given URL to this class loader. If the URL ends with "/", then
	 * it is assumed to be a directory otherwise, it is assumed to be a zip/jar
	 * file. If the same URL is added again, the URL is re-opened and this
	 * zip/jar file is used for serving any future class requests.
	 * 
	 * @param URL
	 *            where to look for the classes.
	 */
	public synchronized void addURL(URL url)
	{
		// System.out.println("Adding url: " + url);
		if (!urlset.containsKey(url))
		{
			try
			{
				urlset.put(url, new URLResourceReader(url));
			}
			catch (IOException ioe)
			{
				// Probably a bad url...
			}
		}
		else
		{
			// remove the old one & add a new one...
			try
			{
				URLResourceReader newu = new URLResourceReader(url);
				URLResourceReader oldu = (URLResourceReader) urlset.get(url);
				oldu.close();
				urlset.remove(url);
				urlset.put(url, newu);
			}
			catch (IOException ioe)
			{
			}
		}
		/*
		 * May get new resources from new URL so have to forget what has not
		 * been found
		 */
		unfoundResources.clear();
	}

	/**
	 * @return An enumeration of URLs where this class loader looks for classes.
	 */
	public URL[] getURLs()
	{

		Object[] keys = urlset.keySet().toArray();
		URL[] urls = new URL[keys.length];

		System.arraycopy(keys, 0, urls, 0, keys.length);
		return urls;
	}

	/**
	 * Call this to bypass the implementation of loadClass.
	 */
	public Class findClass(String name) throws ClassNotFoundException
	{
		byte[] b = loadClassData(name);
		if (b != null)
		{
			// debug("findClass found " + name);
			return defineClass(name, b, 0, b.length);
		}
		else
		{
			// debug("findClass didn't find " + name);
			throw new ClassNotFoundException(name);
		}
	}

	protected byte[] loadResource(URL url, String resourceName) throws IOException
	{
		URLResourceReader urr = (URLResourceReader) urlset.get(url);
		// debug("Loading from " + urr + " " + resourceName);
		if (urr != null)
		{
			return urr.getResource(resourceName);
		}

		return null;
	}

	protected byte[] loadResource(String resource)
	{
		byte[] barray = null;

		// Don't bother searching if we know it's not there
		if (unfoundResources.contains(resource))
		{
			return null;
		}

		for (Enumeration e = urlset.keys(); e.hasMoreElements();)
		{
			URL url = (URL) e.nextElement();

			try
			{
				barray = loadResource(url, resource);
			}
			catch (Exception ex)
			{
			}
			finally
			{
				if (barray != null)
					break;
			}
		}

		// Remember resources we couldn't find
		if (barray == null)
		{
			unfoundResources.add(resource);
		}

		return barray;
	}

	protected byte[] loadClassData(String classname)
	{
		String resourceName = classname.replace('.', '/') + ".class";
		return loadResource(resourceName);
	}

	/**
	 * Overridden to search for a resource and return a "jar"-style URL or
	 * normal "file" URL as necessary.
	 */
	protected URL findResource(String name)
	{ // System.out.println( "findResource: " + name );
		URL url;
		byte[] barray = null;

		// Don't bother searching if we know it's not there
		if (unfoundResources.contains(name))
		{
			return null;
		}

		for (Enumeration e = urlset.keys(); e.hasMoreElements();)
		{
			url = (URL) e.nextElement();
			try
			{
				barray = loadResource(url, name); // loads fully: wasteful
			}
			catch (Exception ex)
			{
				// do nothing
			}
			if (barray != null)
			{
				try
				{
					String ref = url.toString();
					if (ref.endsWith(".jar"))
					{
						// System.out.println( "jar:" + ref + "!/" + name );
						return new URL("jar:" + ref + "!/" + name);
					}
					else
					{
						// System.out.println( new URL( url, name ).toString()
						// );
						return new URL(url, name);
					}
				}
				catch (Throwable t)
				{
					t.printStackTrace();
				}
			}
		}

		// Remember resources we couldn't find
		unfoundResources.add(name);
		return null;
	}

	/**
	 * Find all resources for a given name
	 * 
	 * @return an enumeration of all the resources found.
	 */
	protected Enumeration findResources(String name) throws IOException
	{

		// Don't bother searching if we know it's not there
		if (unfoundResources.contains(name))
		{
			return new Enumeration()
			{
				public Object nextElement()
				{
					return null;
				}

				public boolean hasMoreElements()
				{
					return false;
				}
			};
		}

		ArrayList urls = new ArrayList();

		URL url;
		byte[] barray = null;

		for (Enumeration e = urlset.keys(); e.hasMoreElements();)
		{
			url = (URL) e.nextElement();
			try
			{
				barray = loadResource(url, name); // loads fully: wasteful
			}
			catch (Exception ex)
			{
				// do nothing
			}
			if (barray != null)
			{
				try
				{
					String ref = url.toString();
					if (ref.endsWith(".jar"))
					{
						URL resource = new URL("jar:" + ref + "!/" + name);
						urls.add(resource);

					}
					else
					{
						URL resource = new URL(url, name);
						urls.add(resource);
					}
				}
				catch (Throwable t)
				{
					t.printStackTrace();
				}
			}
		}

		// Remember resources we couldn't find
		if (urls.isEmpty())
		{
			unfoundResources.add(name);
		}

		Enumeration enumerator = new EnumerationIteratorWrapper(urls.iterator());

		return enumerator;
	}

	/**
	 * @return The resource as the input stream if such a resource exists,
	 *         otherwise returns null.
	 */
	public InputStream getResourceAsStream(String name)
	{
		// System.out.println( "getResourceAsStream: " + name );
		InputStream istream = null;

		// Algorithm:
		//
		// 1. first attempt to get the resource from the url set.
		// 2. next  check the delegate/parent class loader for the resource
		// 3. then  check the system path for the resource
		//

		// Lets load it ourselves.
		byte[] data = loadResource(name);
		if (data != null)
		{
			return new ByteArrayInputStream(data);
		}

		// Lets check the parent/delegate class loader for the resource.
		if (parent != null)
		{
			istream = parent.getResourceAsStream(name);
			if (istream != null)
				return istream;
		}

		// Lets check the system path for the resource.
		return getSystemResourceAsStream(name);
	}

	/**
	 * Load a class for given name
	 */
	public synchronized Class loadClass(String name, boolean resolve) throws ClassNotFoundException
	{
		Class c = null;

		// Algorithm: (Please do not change the order; unless you
		// have a good reason to do so).
		//
		// 1. check the class cache
		// 2. next then attempt to load classes from the URL set.
		// 3. next check the delegate/parent class loader.
		// 4. next check the system class loader.
		//

		// Lets see if the class is in the cache..

		// debug("load class:: " + name + " resolve: " + resolve);

		// debug(classCache.toString());

		c = (Class) classCache.get(name);

		if (c == null)
		{
			// Lets see if we find the class all by ourselves.
			byte[] data = loadClassData(name);

			if (data != null)
			{
				// found class data so define it and place in cache
				// debug("found data, attempting to define " + name);
				c = defineClass(name, data, 0, data.length);
				// debug("placing " + name + " in cache");
				classCache.put(name, c);
			}
		}

		// Lets see if the class is in parent class loader if there is one
		// or the system class loader if there isn't.
		if (c == null)
		{
			if (parent != null)
			{
				// debug("check parent class loader for " + name);
				c = parent.loadClass(name);
			}
			else
			{
				// debug("check system class loader for " + name);
				/*
				 * no matter what, we always at least end up here,
				 * so we don't need to throw a ClassNotFoundException
				 * as this will do it for us.
				 */
				c = findSystemClass(name);
			}
		}
		
		// debug("found class " + name);
		if (resolve)
		{
			resolveClass(c);
		}

		return c;
	}

	/**
	 * This method resets this ClassLoader's state. It completely removes all
	 * the URLs and classes in this class loader cache.
	 */
	public final void clear()
	{
		urlset.clear();
		classCache.clear();
		unfoundResources.clear();
	}

	/**
	 * This method resets this ClassLoader's state and resets the references for
	 * garbage collection.
	 */
	protected void finalize() throws Throwable
	{
		// Cleanup real well. Otherwise, this can be
		// a major source of memory leaks...

		// remove all the urls & class entries.
		clear();

		parent = null;
		urlset = null;
		classCache = null;
		unfoundResources = null;
	}

	private class EnumerationIteratorWrapper implements Enumeration
	{
		private Iterator iterator;

		public EnumerationIteratorWrapper(Iterator iterator)
		{
			this.iterator = iterator;
		}

		public boolean hasMoreElements()
		{
			return iterator.hasNext();
		}

		public Object nextElement()
		{
			return iterator.next();
		}

	}
}