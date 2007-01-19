JavaLoader v0.3
Author: Mark Mandel
Date: 3rd January 2007

Installation
----------------
To install the javaloader, either put the javaloader in the 
root of your web application, or make a mapping called
'javaloader' to the javaloader folder.


Utilisation
----------------
To access the JavaLoader CFC, you call createObject on it like so:

createObject("component", "javaloader.JavaLoader").init(loadPaths, 
														[loadColdFusionClassPath,] 
														[loadedClassPathBias,] 
														[parentClassLoader]);

There are four arguments that possible to configure how and what the JavaLoader loads.

* param: loadPaths
An array of directories of classes, or paths to .jar files to load.

An example would be:
loadPaths = ArrayNew(1);
loadPaths[1] = expandPath("icu4j.jar");
loadPaths[2] = expandPath("log4j.jar");

* param: loadColdFusionClassPath (default: false)
Loads the ColdFusion libraries with the loaded libraries.
This used to be on by default, however now you must implicitly set it to be true if 
you wish to access any of the libraries that ColdFusion loads at application startup.

* param: loadedClassPathBias (default: true)
If loading classes on top of a parent classpath, search the loaded classes before searching 
the parent ClassPath

This means that if this is set to 'true', if you load the ColdFusion libraries, and
you load in, log4j for example, when retrieving log4j from JavaLoader, you will
recieve the version that was loaded, not the ColdFusion library version.

* parentClassLoader (null)
(Expert use only) The parent java.lang.ClassLoader to set when creating the URLClassLoader.
Note - when setting loadColdFusionClassPath to 'true', this value is overwritten with the
ColdFusion classloader.


To create an instance of a Java Class, you then only need to call:

javaloader.create(className).init(arg1, arg2...);

* param className
The name of the Java Class to create.

This works exactly the same as createObject("java", className), such that simply calling create(className)
gives you access to the static properties of the class, but to get an instance through calling the
Constructor you are required to call create(className).init();

Example:
javaloader.create("org.apache.log4j.Logger").init("my log");

Integration
----------------
Previously JavaLoader was a simple CFC that was very portable, and while JavaLoader
now has dependencies, it can still be integrated into existing applications quite easily.

The only dependency that much be maintained is that the /lib/ folder and its contents
must sit in the same directory as JavaLoader.cfc  Other than that, JavaLoader can be
integrated into existing applications and frameworks quite easily.