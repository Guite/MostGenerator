package org.zikula.modulestudio.generator.beautifier;

import org.eclipse.core.runtime.IStatus;
import org.eclipse.core.runtime.Status;
import org.eclipse.ui.plugin.AbstractUIPlugin;
import org.osgi.framework.BundleContext;

/**
 * The activator class controls the plug-in life cycle
 * 
 * Based on http://de.sourceforge.jp/projects/pdt-tools/
 */
public class GeneratorBeautifierPlugin extends AbstractUIPlugin {

    // The plug-in ID
    public static final String PLUGIN_ID = "org.zikula.modulestudio.generator.beautifier"; //$NON-NLS-1$

    // The shared instance
    private static GeneratorBeautifierPlugin plugin;

    /**
     * The constructor
     */
    public GeneratorBeautifierPlugin() {
    }

    /*
     * (non-Javadoc)
     * @see
     * org.eclipse.ui.plugin.AbstractUIPlugin#start(org.osgi.framework.BundleContext
     * )
     */
    @Override
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
    public void stop(BundleContext context) throws Exception {
        plugin = null;
        super.stop(context);
    }

    /**
     * Returns the shared instance
     * 
     * @return the shared instance
     */
    public static GeneratorBeautifierPlugin getDefault() {
        return plugin;
    }

    public static void log(Throwable e) {
        getDefault().getLog().log(
                new Status(IStatus.ERROR, PLUGIN_ID, e.getLocalizedMessage()));
    }

    public static void logMessage(int severity, String message) {
        getDefault().getLog().log(new Status(severity, PLUGIN_ID, message));
    }
}
