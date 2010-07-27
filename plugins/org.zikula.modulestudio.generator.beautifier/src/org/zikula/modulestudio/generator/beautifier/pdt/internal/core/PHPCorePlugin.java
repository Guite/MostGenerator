package org.zikula.modulestudio.generator.beautifier.pdt.internal.core;

/*******************************************************************************
 * Copyright (c) 2009 IBM Corporation and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 * 
 * Contributors:
 *     IBM Corporation - initial API and implementation
 *     Zend Technologies
 *
 *
 *
 * Based on package org.eclipse.php.internal.core;
 *
 *******************************************************************************/

import java.util.Hashtable;

import org.eclipse.core.resources.IProject;
import org.eclipse.core.resources.IResourceChangeEvent;
import org.eclipse.core.resources.IResourceChangeListener;
import org.eclipse.core.resources.IWorkspace;
import org.eclipse.core.resources.IncrementalProjectBuilder;
import org.eclipse.core.resources.ResourcesPlugin;
import org.eclipse.core.runtime.CoreException;
import org.eclipse.core.runtime.IProgressMonitor;
import org.eclipse.core.runtime.IStatus;
import org.eclipse.core.runtime.ListenerList;
import org.eclipse.core.runtime.OperationCanceledException;
import org.eclipse.core.runtime.Plugin;
import org.eclipse.core.runtime.Status;
import org.eclipse.dltk.ast.Modifiers;
import org.eclipse.dltk.core.DLTKCore;
import org.eclipse.dltk.core.IProjectFragment;
import org.eclipse.dltk.core.IScriptProject;
import org.eclipse.dltk.core.IShutdownListener;
import org.eclipse.dltk.core.index2.search.ISearchEngine.MatchRule;
import org.eclipse.dltk.core.search.IDLTKSearchScope;
import org.eclipse.dltk.core.search.SearchEngine;
import org.eclipse.dltk.internal.core.ModelManager;
import org.eclipse.dltk.internal.core.search.ProjectIndexerManager;
import org.osgi.framework.BundleContext;
import org.zikula.modulestudio.generator.beautifier.GeneratorBeautifierPlugin;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.model.PhpModelAccess;

/**
 * The main plugin class to be used in the desktop.
 */
public class PHPCorePlugin extends Plugin {

	public static final String ID = "org.zikula.generator.beautifier.pdt"; //$NON-NLS-1$

	public static final int INTERNAL_ERROR = 10001;

	// The shared instance.
	private static PHPCorePlugin plugin;

	/** Whether the "PHP Toolkit" is initialized */
	public static transient boolean toolkitInitialized;
	private final ListenerList shutdownListeners = new ListenerList();
	private ReindexOperationListener reindexOperationListener = new ReindexOperationListener();

	/**
	 * The constructor.
	 */
	public PHPCorePlugin() {
		super();
		plugin = this;
	}

	/**
	 * This method is called upon plug-in activation
	 */
	@Override
	public void start(BundleContext context) throws Exception {
		super.start(context);
	}

	/**
	 * This listener used for invoking re-index opeartion before project clean
	 */
	private class ReindexOperationListener implements IResourceChangeListener {

		@Override
		public void resourceChanged(IResourceChangeEvent event) {
			if (event.getBuildKind() == IncrementalProjectBuilder.CLEAN_BUILD) {
				Object source = event.getSource();
				try {
					if (source instanceof IProject) {
						IProject project = (IProject) source;
						ProjectIndexerManager.removeProject(project
								.getFullPath());
						ProjectIndexerManager.indexProject(project);

					} else if (source instanceof IWorkspace) {
						IWorkspace workspace = (IWorkspace) source;
						IProject[] projects = workspace.getRoot().getProjects();

						// remove from index:
						for (IProject project : projects) {
							if (!project.isAccessible()) {
								continue;
							}
							IScriptProject scriptProject = DLTKCore
									.create(project);
							IProjectFragment[] projectFragments = scriptProject
									.getProjectFragments();
							for (IProjectFragment projectFragment : projectFragments) {
								ProjectIndexerManager.removeProjectFragment(
										scriptProject, projectFragment
												.getPath());
							}
							ProjectIndexerManager.removeProject(project
									.getFullPath());
						}

						// add to index:
						for (IProject project : projects) {
							if (!project.isAccessible()) {
								continue;
							}
							ProjectIndexerManager.indexProject(project);
						}
					}
				} catch (CoreException e) {
					GeneratorBeautifierPlugin.log(e);
				}
			}
		}
	}

	/**
	 * Add listener that will be notified when this plug-in is going to shutdown
	 * 
	 * @param listener
	 */
	public void addShutdownListener(IShutdownListener listener) {
		shutdownListeners.add(listener);
	}

	/**
	 * This method is called when the plug-in is stopped
	 */
	@Override
	public void stop(BundleContext context) throws Exception {

		Object[] listeners = shutdownListeners.getListeners();
		for (int i = 0; i < listeners.length; ++i) {
			((IShutdownListener) listeners[i]).shutdown();
		}
		shutdownListeners.clear();

		super.stop(context);

		ResourcesPlugin.getWorkspace().removeResourceChangeListener(
				reindexOperationListener);

		plugin = null;
	}

	/**
	 * Returns the shared instance.
	 */
	public static PHPCorePlugin getDefault() {
		return plugin;
	}

	public static void log(IStatus status) {
		getDefault().getLog().log(status);
	}

	public static void log(Throwable e) {
		log(new Status(IStatus.ERROR, ID, INTERNAL_ERROR,
				"PHPCore plugin internal error", e)); //$NON-NLS-1$
	}

	public static void logErrorMessage(String message) {
		log(new Status(IStatus.ERROR, ID, INTERNAL_ERROR, message, null));
	}

	public static String getPluginId() {
		return ID;
	}

	/**
	 * Helper method for returning one option value only. Equivalent to
	 * <code>(String)PhpCore.getOptions().get(optionName)</code> Note that it
	 * may answer <code>null</code> if this option does not exist.
	 * <p>
	 * For a complete description of the configurable options, see
	 * <code>getDefaultOptions</code>.
	 * </p>
	 * 
	 * @param optionName
	 *            the name of an option
	 * @return the String value of a given option
	 * @see PhpCore#getDefaultOptions()
	 * @see PhpCorePreferenceInitializer for changing default settings
	 * @since 2.0
	 */
	public static String getOption(String optionName) {
		return ModelManager.getModelManager().getOption(optionName);
	}

	/**
	 * Returns the table of the current options. Initially, all options have
	 * their default values, and this method returns a table that includes all
	 * known options.
	 * <p>
	 * For a complete description of the configurable options, see
	 * <code>getDefaultOptions</code>.
	 * </p>
	 * <p>
	 * Returns a default set of options even if the platform is not running.
	 * </p>
	 * 
	 * @return table of current settings of all options (key type:
	 *         <code>String</code>; value type: <code>String</code>)
	 * @see #getDefaultOptions()
	 * @see JavaCorePreferenceInitializer for changing default settings
	 */
	public static Hashtable getOptions() {
		return ModelManager.getModelManager().getOptions();
	}

	/**
	 * Initializes DLTKCore internal structures to allow subsequent operations
	 * (such as the ones that need a resolved classpath) to run full speed. A
	 * client may choose to call this method in a background thread early after
	 * the workspace has started so that the initialization is transparent to
	 * the user.
	 * <p>
	 * However calling this method is optional. Services will lazily perform
	 * initialization when invoked. This is only a way to reduce initialization
	 * overhead on user actions, if it can be performed before at some
	 * appropriate moment.
	 * </p>
	 * <p>
	 * This initialization runs accross all Java projects in the workspace. Thus
	 * the workspace root scheduling rule is used during this operation.
	 * </p>
	 * <p>
	 * This method may return before the initialization is complete. The
	 * initialization will then continue in a background thread.
	 * </p>
	 * <p>
	 * This method can be called concurrently.
	 * </p>
	 * 
	 * @param monitor
	 *            a progress monitor, or <code>null</code> if progress reporting
	 *            and cancellation are not desired
	 * @exception CoreException
	 *                if the initialization fails, the status of the exception
	 *                indicates the reason of the failure
	 * @since 3.1
	 */
	public static void initializeAfterLoad(IProgressMonitor monitor)
			throws CoreException {
		try {
			if (monitor != null) {
				monitor.beginTask(
						CoreMessages.PHPCorePlugin_initializingPHPToolkit, 125);
			}
			// dummy query for waiting until the indexes are ready
			IDLTKSearchScope scope = SearchEngine
					.createWorkspaceScope(PHPLanguageToolkit.getDefault());
			try {
				if (monitor != null) {
					monitor
							.subTask(CoreMessages.PHPCorePlugin_initializingSearchEngine);
					monitor.worked(25);
				}

				PhpModelAccess.getDefault().findMethods("", MatchRule.PREFIX,
						Modifiers.AccGlobal, 0, scope, monitor);
				if (monitor != null) {
					monitor.worked(25);
				}

				PhpModelAccess.getDefault().findTypes("", MatchRule.PREFIX,
						Modifiers.AccGlobal, 0, scope, monitor);
				if (monitor != null) {
					monitor.worked(25);
				}

				PhpModelAccess.getDefault().findFields("", MatchRule.PREFIX,
						Modifiers.AccGlobal, 0, scope, monitor);
				if (monitor != null) {
					monitor.worked(25);
				}

				PhpModelAccess.getDefault().findIncludes("", MatchRule.PREFIX,
						scope, monitor);
				if (monitor != null) {
					monitor.worked(25);
				}

			} catch (OperationCanceledException e) {
				if (monitor != null && monitor.isCanceled()) {
					throw e;
				}
				// else indexes were not ready: catch the exception so that jars
				// are still refreshed
			}
		} finally {
			if (monitor != null) {
				monitor.done();
			}
			toolkitInitialized = true;
		}
	}
}
