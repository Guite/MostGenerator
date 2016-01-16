package org.zikula.modulestudio.generator.application

import org.eclipse.core.runtime.Status
import org.eclipse.ui.plugin.AbstractUIPlugin
import org.osgi.framework.BundleContext

/** 
 * The activator class for this bundle.
 */
@SuppressWarnings("PMD.UseSingleton")
class ModuleStudioGeneratorActivator extends AbstractUIPlugin {

    /**
     * The plug-in ID.
     */
    public static final String PLUGIN_ID = 'org.zikula.modulestudio.generator' // $NON-NLS-1$

    /**
     * The shared instance.
     */
    static ModuleStudioGeneratorActivator plugin

    /**
     * The constructor.
     */
    new() { // nothing to do here
    }

    /*
     * (non-Javadoc)
     * @see
     * org.eclipse.ui.plugin.AbstractUIPlugin#start(org.osgi.framework.BundleContext
     * )
     */
    @SuppressWarnings("PMD.SignatureDeclareThrowsException")
    override void start(BundleContext context) throws Exception {
        super.start(context)
        plugin = this
    }

    /*
     * (non-Javadoc)
     * @see
     * org.eclipse.ui.plugin.AbstractUIPlugin#stop(org.osgi.framework.BundleContext
     * )
     */
    @SuppressWarnings(#["PMD.SignatureDeclareThrowsException", "PMD.NullAssignment"])
    override void stop(BundleContext context) throws Exception {
        plugin = null
        super.stop(context)
    }

    /**
     * Returns the shared instance.
     *
     * @return the shared instance
     */
    def static getDefault() {
        plugin
    }

    /**
     * A helper to log plugin errors.
     *
     * @param severity
     *            the error severity.
     * @param message
     *            the error message.
     * @param exception
     *            the error exception.
     */
    def static log(int severity, String message, Throwable exception) {
        getDefault.log.log(new Status(severity, PLUGIN_ID, message, exception))
    }
}
