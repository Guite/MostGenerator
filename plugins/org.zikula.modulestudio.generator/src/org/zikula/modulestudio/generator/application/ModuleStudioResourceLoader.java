
package org.zikula.modulestudio.generator.application;

import java.io.IOException;
import java.io.InputStream;
import java.net.URL;

import org.eclipse.core.runtime.CoreException;
import org.eclipse.emf.mwe.core.resources.ResourceLoaderDefaultImpl;

import de.guite.modulestudio.metamodel.modulestudio.ModulestudioPackage;

/**
* This ResourceLoader is capable of loading resources from another plugin.
* Typical use is when invoking a workflow from within a plugin.
*  
* @author Axel Terfloth (axel.terfloth@itemis.de)
* @author Karsten Thoms (karsten.thoms@itemis.de)
*/
public class ModuleStudioResourceLoader extends ResourceLoaderDefaultImpl {
	private ClassLoader pluginCL;

	public ModuleStudioResourceLoader() throws CoreException {
		super();
		pluginCL = createClassLoader();
	}

	/**
	* Returns classloader for the meta model project 
	* @throws CoreException
	*/
	public ClassLoader createClassLoader() throws CoreException {
		return ModulestudioPackage.class.getClassLoader();
	}

//	@Override
	protected URL internalGetResource(String path) {
		URL resource = pluginCL.getResource(path);
		if (resource == null) {
			resource = super.getResource(path);
		}
		return resource;
	}

//	@Override
	protected InputStream internalGetResourceAsStream(String path) {
		URL url = internalGetResource(path);
		try {
			return url != null ? url.openStream() : null;
		} catch (IOException e) {
			e.printStackTrace();
			return super.getResourceAsStream(path);
		}
	}
}
