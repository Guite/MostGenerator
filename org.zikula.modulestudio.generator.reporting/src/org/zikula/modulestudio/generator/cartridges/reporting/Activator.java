package org.zikula.modulestudio.generator.cartridges.reporting;

import org.eclipse.ui.plugin.AbstractUIPlugin;
import org.osgi.framework.BundleContext;

/**
 * The activator class for this bundle.
 */
@SuppressWarnings("PMD.UseSingleton")
// @SuppressWarnings("PMD.UseSingleton") Eclipse plug-in activator.
public class Activator extends AbstractUIPlugin {

    /**
     * The plug-in ID.
     */
    public static final String PLUGIN_ID = "org.zikula.modulestudio.generator.reporting"; //$NON-NLS-1$

    /**
     * The shared instance.
     */
    private static Activator plugin;

    /**
     * The constructor.
     */
    public Activator() {
        // nothing to do here
    }

    /*
     * (non-Javadoc)
     * @see
     * org.eclipse.ui.plugin.AbstractUIPlugin#start(org.osgi.framework.BundleContext
     * )
     */
    @Override
    @SuppressWarnings("PMD.SignatureDeclareThrowsException")
    // @SuppressWarnings("PMD.SignatureDeclareThrowsException") We have to use
    // this signature because this is an override of an Eclipse framework's
    // method.
    public void start(BundleContext context) throws Exception {
        super.start(context);
        plugin = this;
    }

    /*
     * (non-Javadoc)
     * @see
     * org.eclipse.ui.plugin.AbstractUIPlugin#stop(org.osgi.framework.BundleContext
     * )
     */
    @Override
    @SuppressWarnings({ "PMD.SignatureDeclareThrowsException",
            "PMD.NullAssignment" })
    // @SuppressWarnings("PMD.SignatureDeclareThrowsException") Eclipse method
    // override.
    // @SuppressWarnings("PMD.NullAssignment") Eclipse pattern.
    public void stop(BundleContext context) throws Exception {
        plugin = null;
        super.stop(context);
    }

    /**
     * Returns the shared instance.
     * 
     * @return the shared instance
     */
    public static Activator getDefault() {
        return plugin;
    }
}
