package org.zikula.modulestudio.generator.beautifier.pdt.internal.core.language;

/*******************************************************************************
 * Copyright (c) 2009 IBM Corporation and others. All rights reserved. This
 * program and the accompanying materials are made available under the terms of
 * the Eclipse Public License v1.0 which accompanies this distribution, and is
 * available at http://www.eclipse.org/legal/epl-v10.html
 * 
 * Contributors: IBM Corporation - initial API and implementation Zend
 * Technologies
 * 
 * 
 * 
 * Based on package org.eclipse.php.internal.core.language;
 * 
 *******************************************************************************/

import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.HashMap;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;

import org.eclipse.core.resources.IProject;
import org.eclipse.core.runtime.CoreException;
import org.eclipse.core.runtime.IConfigurationElement;
import org.eclipse.core.runtime.IPath;
import org.eclipse.core.runtime.Path;
import org.eclipse.core.runtime.Platform;
import org.eclipse.dltk.core.BuildpathContainerInitializer;
import org.eclipse.dltk.core.DLTKCore;
import org.eclipse.dltk.core.DLTKLanguageManager;
import org.eclipse.dltk.core.IBuildpathContainer;
import org.eclipse.dltk.core.IBuildpathEntry;
import org.eclipse.dltk.core.IDLTKLanguageToolkit;
import org.eclipse.dltk.core.IModelElement;
import org.eclipse.dltk.core.IProjectFragment;
import org.eclipse.dltk.core.IScriptProject;
import org.eclipse.dltk.core.ModelException;
import org.zikula.modulestudio.generator.beautifier.GeneratorBeautifierPlugin;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.PHPCorePlugin;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.preferences.IPreferencesPropagatorListener;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.project.PHPNature;

public class LanguageModelInitializer extends BuildpathContainerInitializer {

    public static final String PHP_LANGUAGE_LIBRARY = "PHP Language Library";

    /**
     * Path of the language model for php projects
     */
    public static final String CONTAINER_PATH = PHPCorePlugin.ID + ".LANGUAGE"; //$NON-NLS-1$
    public static final Path LANGUAGE_CONTAINER_PATH = new Path(
            LanguageModelInitializer.CONTAINER_PATH);

    /**
     * Listeners for PHP version change map (per project)
     */
    private final Map<IProject, IPreferencesPropagatorListener> project2PhpVerListener = new HashMap<IProject, IPreferencesPropagatorListener>();

    /**
     * Language model paths initializers
     */
    private static ILanguageModelProvider[] providers;

    /**
     * Holds nice names for the language model paths
     */
    private static Map<IPath, String> pathToName = Collections
            .synchronizedMap(new HashMap<IPath, String>());

    static void addPathName(IPath path, String name) {
        pathToName.put(path, name);
    }

    /**
     * Returns nice name for this language model path provided by the
     * {@link ILanguageModelProvider}. If the path doesn't refer to the language
     * model path - <code>null</code> is returned.
     * 
     * @return
     */
    public static String getPathName(IPath path) {
        return pathToName.get(path);
    }

    @Override
    public void initialize(IPath containerPath, IScriptProject scriptProject)
            throws CoreException {
        if (containerPath.segmentCount() > 0
                && containerPath.segment(0).equals(CONTAINER_PATH)) {
            try {
                if (isPHPProject(scriptProject)) {
                    DLTKCore.setBuildpathContainer(
                            containerPath,
                            new IScriptProject[] { scriptProject },
                            new IBuildpathContainer[] { new LanguageModelContainer(
                                    containerPath, scriptProject) }, null);
                }
            } catch (final Exception e) {
                GeneratorBeautifierPlugin.log(e);
            }
        }
    }

    private static boolean isPHPProject(IScriptProject project) {
        final String nature = getNatureFromProject(project);
        return PHPNature.ID.equals(nature);
    }

    private static String getNatureFromProject(IScriptProject project) {
        final IDLTKLanguageToolkit languageToolkit = DLTKLanguageManager
                .getLanguageToolkit(project);
        if (languageToolkit != null) {
            return languageToolkit.getNatureId();
        }
        return null;
    }

    public static boolean isLanguageModelElement(IModelElement element) {
        if (element != null) {
            final IProjectFragment fragment = (IProjectFragment) element
                    .getAncestor(IModelElement.PROJECT_FRAGMENT);
            if (fragment != null && fragment.isExternal()) {
                final IPath path = fragment.getPath();

                // see getTargetLocation() below for description:
                if (path.segmentCount() > 2) {
                    return "__language__".equals(path.segment(path
                            .segmentCount() - 2));
                }
            }
        }
        return false;
    }

    /**
     * Modifies PHP project buildpath so it will contain path to the language
     * model library
     * 
     * @param project
     *            Project handle
     * @throws ModelException
     */
    public static void enableLanguageModelFor(IScriptProject project)
            throws ModelException {
        if (!isPHPProject(project)) {
            return;
        }

        boolean found = false;
        final IBuildpathEntry[] rawBuildpath = project.getRawBuildpath();
        for (final IBuildpathEntry entry : rawBuildpath) {
            if (entry.isContainerEntry()
                    && entry.getPath().equals(LANGUAGE_CONTAINER_PATH)) {
                found = true;
                break;
            }
        }

        if (!found) {
            final IBuildpathEntry containerEntry = DLTKCore
                    .newContainerEntry(LANGUAGE_CONTAINER_PATH);
            final int newSize = rawBuildpath.length + 1;
            final List<IBuildpathEntry> newRawBuildpath = new ArrayList<IBuildpathEntry>(
                    newSize);
            newRawBuildpath.addAll(Arrays.asList(rawBuildpath));
            newRawBuildpath.add(containerEntry);
            project.setRawBuildpath(
                    newRawBuildpath.toArray(new IBuildpathEntry[newSize]), null);
        }
    }

    static ILanguageModelProvider[] getContributedProviders() {
        if (LanguageModelInitializer.providers == null) {
            final List<ILanguageModelProvider> providers = new LinkedList<ILanguageModelProvider>();
            providers.add(new DefaultLanguageModelProvider()); // add default

            final IConfigurationElement[] elements = Platform
                    .getExtensionRegistry()
                    .getConfigurationElementsFor(
                            "org.zikula.generator.beautifier.pdt.core.languageModelProviders");
            for (final IConfigurationElement element : elements) {
                if (element.getName().equals("provider")) {
                    try {
                        providers.add((ILanguageModelProvider) element
                                .createExecutableExtension("class"));
                    } catch (final CoreException e) {
                        PHPCorePlugin.log(e);
                    }
                }
            }
            LanguageModelInitializer.providers = providers
                    .toArray(new ILanguageModelProvider[providers.size()]);
        }
        return LanguageModelInitializer.providers;
    }

    static IPath getTargetLocation(ILanguageModelProvider provider,
            IPath sourcePath, IScriptProject project) {

        return provider
                .getPlugin()
                .getStateLocation()
                .append("__language__")
                .append(Integer.toHexString(sourcePath.toOSString().hashCode()));
    }
}
