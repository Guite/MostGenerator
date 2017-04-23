package org.zikula.modulestudio.generator.application;

import org.eclipse.core.runtime.ILog;
import org.eclipse.core.runtime.Status;
import org.eclipse.ui.plugin.AbstractUIPlugin;
import org.osgi.framework.BundleContext;

/**
 * The activator class for this bundle.
 */
@SuppressWarnings("PMD.UseSingleton")
public class ModuleStudioGeneratorActivator extends AbstractUIPlugin {
  /**
   * The plug-in ID.
   */
  public final static String PLUGIN_ID = "org.zikula.modulestudio.generator";
  
  /**
   * The shared instance.
   */
  private static ModuleStudioGeneratorActivator plugin;
  
  /**
   * The constructor.
   */
  public ModuleStudioGeneratorActivator() {
  }
  
  /**
   * (non-Javadoc)
   * @see
   * org.eclipse.ui.plugin.AbstractUIPlugin#start(org.osgi.framework.BundleContext
   * )
   */
  @SuppressWarnings("PMD.SignatureDeclareThrowsException")
  @Override
  public void start(final BundleContext context) throws Exception {
    super.start(context);
    ModuleStudioGeneratorActivator.plugin = this;
  }
  
  /**
   * (non-Javadoc)
   * @see
   * org.eclipse.ui.plugin.AbstractUIPlugin#stop(org.osgi.framework.BundleContext
   * )
   */
  @SuppressWarnings({ "PMD.SignatureDeclareThrowsException", "PMD.NullAssignment" })
  @Override
  public void stop(final BundleContext context) throws Exception {
    ModuleStudioGeneratorActivator.plugin = null;
    super.stop(context);
  }
  
  /**
   * Returns the shared instance.
   * 
   * @return the shared instance
   */
  public static ModuleStudioGeneratorActivator getDefault() {
    return ModuleStudioGeneratorActivator.plugin;
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
  public static void log(final int severity, final String message, final Throwable exception) {
    ILog _log = ModuleStudioGeneratorActivator.getDefault().getLog();
    Status _status = new Status(severity, ModuleStudioGeneratorActivator.PLUGIN_ID, message, exception);
    _log.log(_status);
  }
}
