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

    /**
     * The class loader.
     */
    private ClassLoader pluginCL;

    /**
     * The constructor.
     * 
     * @throws CoreException
     *             In case something goes wrong.
     */
    public ModuleStudioResourceLoader() throws CoreException {
        super();
        this.setPluginCL(createClassLoader());
    }

    /**
     * Returns the class loader for the meta model project
     * 
     * @return The {@link ClassLoader} instance.
     * @throws CoreException
     *             In case something goes wrong.
     */
    public ClassLoader createClassLoader() throws CoreException {
        return ModulestudioPackage.class.getClassLoader();
    }

    /**
     * Returns the internal resource for a given path.
     * 
     * @param path
     *            String with path to resource.
     * @return The {@link URL} instance for the resource.
     */
    protected URL internalGetResource(String path) {
        URL resource = getPluginCL().getResource(path);
        if (resource == null) {
            resource = super.getResource(path);
        }
        return resource;
    }

    /**
     * Returns the internal resource for a given path as stream.
     * 
     * @param path
     *            String with path to resource.
     * @return The {@link InputStream} instance for the resource.
     */
    protected InputStream internalGetResourceAsStream(String path) {
        final URL url = internalGetResource(path);
        try {
            return url != null ? url.openStream() : null;
        } catch (final IOException e) {
            e.printStackTrace();
            return super.getResourceAsStream(path);
        }
    }

    /**
     * Returns the plugin {@link ClassLoader}.
     * 
     * @return the {@link ClassLoader} instance.
     */
    public ClassLoader getPluginCL() {
        return this.pluginCL;
    }

    /**
     * Sets the plugin {@link ClassLoader}.
     * 
     * @param cl
     *            the {@link ClassLoader} instance.
     */
    public void setPluginCL(ClassLoader cl) {
        this.pluginCL = cl;
    }
}
