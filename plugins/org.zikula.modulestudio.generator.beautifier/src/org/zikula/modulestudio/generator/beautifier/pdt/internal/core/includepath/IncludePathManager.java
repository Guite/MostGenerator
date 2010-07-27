package org.zikula.modulestudio.generator.beautifier.pdt.internal.core.includepath;

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
 * Based on package org.eclipse.php.internal.core.includepath;
 * 
 *******************************************************************************/

import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashSet;
import java.util.LinkedList;
import java.util.List;
import java.util.Set;

import org.eclipse.core.resources.IProject;
import org.eclipse.core.resources.IResource;
import org.eclipse.core.resources.ResourcesPlugin;
import org.eclipse.core.resources.WorkspaceJob;
import org.eclipse.core.runtime.CoreException;
import org.eclipse.core.runtime.IPath;
import org.eclipse.core.runtime.IProgressMonitor;
import org.eclipse.core.runtime.IStatus;
import org.eclipse.core.runtime.Path;
import org.eclipse.core.runtime.Status;
import org.eclipse.dltk.core.DLTKCore;
import org.eclipse.dltk.core.ElementChangedEvent;
import org.eclipse.dltk.core.IBuildpathEntry;
import org.eclipse.dltk.core.IElementChangedListener;
import org.eclipse.dltk.core.IModelElement;
import org.eclipse.dltk.core.IModelElementDelta;
import org.eclipse.dltk.core.IScriptProject;
import org.eclipse.dltk.core.ModelException;
import org.eclipse.dltk.core.environment.EnvironmentPathUtils;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.language.LanguageModelInitializer;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.preferences.CorePreferencesSupport;

public class IncludePathManager {

    private static final String PREF_KEY = "include_path"; //$NON-NLS-1$
    private static final char PREF_SEP = (char) 5;
    private static IncludePathManager instance = new IncludePathManager();

    private boolean modifyingIncludePath;
    private final Set<IIncludepathListener> listeners = new HashSet<IIncludepathListener>(
            4);

    private IncludePathManager() {
        DLTKCore.addElementChangedListener(new IElementChangedListener() {

            @Override
            public void elementChanged(ElementChangedEvent event) {
                processChildren(event.getDelta());
            }

            private void processChildren(IModelElementDelta delta) {
                if (modifyingIncludePath) {
                    return;
                }

                final IModelElement element = delta.getElement();
                try {
                    if ((delta.getFlags() & IModelElementDelta.F_BUILDPATH_CHANGED) != 0) {
                        final IScriptProject scriptProject = element
                                .getScriptProject();
                        final IProject project = scriptProject.getProject();
                        final IncludePath[] includePathEntries = getIncludePaths(project);
                        final List<IncludePath> newEntries = new LinkedList<IncludePath>(
                                Arrays.asList(includePathEntries));

                        final IBuildpathEntry[] rawBuildpath = scriptProject
                                .getRawBuildpath();

                        // This is a workaround to the lack of information about
                        // buildpath changes in delta:
                        boolean changed = false;

                        // Calculate added entries:
                        final Set<IPath> addedModels = new HashSet<IPath>();
                        getAddedModels(delta, addedModels);
                        for (final IBuildpathEntry entry : rawBuildpath) {
                            boolean added = false;
                            for (final IncludePath includePath : includePathEntries) {
                                if (includePath.isBuildpath()
                                        && entry.equals(includePath.getEntry())
                                        || !addedModels.contains(entry
                                                .getPath())) {
                                    added = false;
                                    break;
                                }
                            }
                            if (added && isBuildpathAllowed(entry)) {
                                newEntries.add(new IncludePath(entry,
                                        scriptProject));
                                changed = true;
                            }
                        }

                        // Calculate removed entries:
                        final List<IncludePath> entriesToRemove = new LinkedList<IncludePath>();
                        for (final IncludePath includePath : includePathEntries) {
                            boolean removed = true;
                            for (final IBuildpathEntry entry : rawBuildpath) {
                                if (includePath.isBuildpath()) {
                                    if (entry.equals(includePath.getEntry())) {
                                        removed = false;
                                        break;
                                    }
                                }
                                else {
                                    removed = false;
                                }
                                /*
                                 * else { if
                                 * (entry.getPath().isPrefixOf(((IResource)
                                 * includePath.getEntry()).getFullPath())) {
                                 * removed = false; break; } }
                                 */
                            }
                            if (removed) {
                                entriesToRemove.add(includePath);
                            }
                        }
                        for (final IncludePath includePath : entriesToRemove) {
                            newEntries.remove(includePath);
                            changed = true;
                        }

                        if (changed) {
                            setIncludePath(project,
                                    newEntries
                                            .toArray(new IncludePath[newEntries
                                                    .size()]));
                        }

                    }
                    else {
                        final IModelElementDelta[] children = delta
                                .getAffectedChildren();
                        for (final IModelElementDelta child : children) {
                            processChildren(child);
                        }
                    }
                } catch (final ModelException e) {
                    if (DLTKCore.DEBUG) {
                        e.printStackTrace();
                    }
                }
            }

            private void getAddedModels(IModelElementDelta delta,
                    Set<IPath> addedModels) {
                for (int i = 0; i < delta.getAddedChildren().length; i++) {
                    addedModels.add(delta.getAddedChildren()[i].getElement()
                            .getPath());
                }
                for (int i = 0; i < delta.getAffectedChildren().length; i++) {
                    getAddedModels(delta.getAffectedChildren()[i], addedModels);
                }
            }
        });
    }

    public static IncludePathManager getInstance() {
        return instance;
    }

    /**
     * Read project's include path
     * 
     * @param project
     * @return ordered include path
     */
    public IncludePath[] getIncludePaths(IProject project) {
        final List<IncludePath> includePathEntries = new LinkedList<IncludePath>();
        IBuildpathEntry[] buildpath = null;
        try {
            buildpath = DLTKCore.create(project).getRawBuildpath();
        } catch (final ModelException e) {
            if (DLTKCore.DEBUG) {
                e.printStackTrace();
            }
        }

        String includePath = CorePreferencesSupport.getInstance()
                .getProjectSpecificPreferencesValue(PREF_KEY, null, project);
        if (includePath != null) {
            while (includePath != null) {
                String path;
                int i = includePath.indexOf(PREF_SEP);
                if (i == -1) {
                    path = includePath;
                    includePath = null;
                }
                else {
                    path = includePath.substring(0, i);
                    includePath = includePath.substring(i + 1);
                }

                if ((i = path.indexOf(';')) != -1) {
                    final int kind = Integer.parseInt(path.substring(0, i));
                    path = path.substring(i + 1);

                    if (kind == 0) {
                        final IResource resource = ResourcesPlugin
                                .getWorkspace().getRoot().findMember(path);
                        if (resource != null) {
                            includePathEntries.add(new IncludePath(resource,
                                    project));
                        }
                    }
                    else if (buildpath != null) {
                        for (final IBuildpathEntry entry : buildpath) {
                            if (entry.getEntryKind() == kind) {
                                final IPath localPath = EnvironmentPathUtils
                                        .getLocalPath(entry.getPath());
                                if (localPath.equals(new Path(path))) {
                                    includePathEntries.add(new IncludePath(
                                            entry, project));
                                    break;
                                }
                            }
                        }

                    }
                }
            }
        }
        else if (buildpath != null) { // by default include path equals to the
                                      // build path
            for (final IBuildpathEntry entry : buildpath) {
                if (isBuildpathAllowed(entry)) {
                    includePathEntries.add(new IncludePath(entry, project));
                }
            }
        }
        return includePathEntries.toArray(new IncludePath[includePathEntries
                .size()]);
    }

    /**
     * Sets project's include path
     * 
     * @param project
     * @param includePathEntries
     *            Ordered include path entries
     */
    public void setIncludePath(final IProject project,
            IncludePath[] includePathEntries) {
        final StringBuilder buf = new StringBuilder();
        if (null == project || includePathEntries == null) {
            return;
        }
        for (int i = 0; i < includePathEntries.length; ++i) {
            final IncludePath includePath = includePathEntries[i];
            if (includePath.isBuildpath()) {
                final IBuildpathEntry entry = (IBuildpathEntry) includePath
                        .getEntry();
                final IPath localPath = EnvironmentPathUtils.getLocalPath(entry
                        .getPath());
                buf.append(entry.getEntryKind()).append(';')
                        .append(localPath.toString());
            }
            else {
                final IResource entry = (IResource) includePath.getEntry();
                buf.append("0;").append(entry.getFullPath().toString());
            }
            if (i < includePathEntries.length - 1) {
                buf.append(PREF_SEP);
            }
        }
        modifyingIncludePath = true;
        final WorkspaceJob job = new WorkspaceJob("Modifying Include Path") {
            @Override
            public IStatus runInWorkspace(IProgressMonitor monitor)
                    throws CoreException {
                CorePreferencesSupport.getInstance()
                        .setProjectSpecificPreferencesValue(PREF_KEY,
                                buf.toString(), project);
                modifyingIncludePath = false;

                // TODO - should not be part of the current job
                refresh(project);
                return Status.OK_STATUS;
            }
        };
        job.setRule(project.getWorkspace().getRoot());
        job.setPriority(WorkspaceJob.INTERACTIVE);
        job.schedule();
    }

    public static boolean isBuildpathAllowed(IBuildpathEntry entry) {
        return ((entry.getEntryKind() == IBuildpathEntry.BPE_CONTAINER && !entry
                .getPath().toString()
                .equals(LanguageModelInitializer.CONTAINER_PATH))
                || entry.getEntryKind() == IBuildpathEntry.BPE_LIBRARY || entry
                .getEntryKind() == IBuildpathEntry.BPE_PROJECT);
    }

    /**
     * Removes the given entry from the include path (according to the path)
     * 
     * @param scriptProject
     * @param buildpathEntry
     * @throws ModelException
     */
    public void removeEntryFromIncludePath(IProject project,
            IBuildpathEntry buildpathEntry) throws ModelException {

        final IncludePath[] includePathEntries = getIncludePaths(project);
        final List<IncludePath> newIncludePathEntries = new ArrayList<IncludePath>();

        // go over the entries and compare the path.
        // if it is the same as the given entry, it won't be added to the list.
        for (final IncludePath entry : includePathEntries) {
            final Object includePathEntry = entry.getEntry();
            IPath resourcePath = null;
            if (includePathEntry instanceof IBuildpathEntry) {
                final IBuildpathEntry bpEntry = (IBuildpathEntry) includePathEntry;
                resourcePath = bpEntry.getPath();
            }
            else {
                final IResource resource = (IResource) includePathEntry;
                resourcePath = resource.getFullPath();
            }

            if (resourcePath != null
                    && !resourcePath.toString().equals(
                            buildpathEntry.getPath().toString())) {
                newIncludePathEntries.add(entry);
            }

        }
        // update the include path for this project
        setIncludePath(project,
                newIncludePathEntries
                        .toArray(new IncludePath[newIncludePathEntries.size()]));
    }

    /**
     * Adds the given entries to Include Path
     * 
     * @param scriptProject
     * @param entries
     * @throws ModelException
     */
    public void addEntriesToIncludePath(IProject project,
            List<IBuildpathEntry> entries) {

        final List<IncludePath> includePathEntries = new ArrayList<IncludePath>();
        for (final IBuildpathEntry buildpathEntry : entries) {
            if (buildpathEntry.getEntryKind() == IBuildpathEntry.BPE_SOURCE) {
                final IResource resource = ResourcesPlugin.getWorkspace()
                        .getRoot().findMember(buildpathEntry.getPath());
                if (resource != null) {
                    includePathEntries.add(new IncludePath(resource, project));
                }
            }
            else {
                includePathEntries
                        .add(new IncludePath(buildpathEntry, project));
            }
        }
        // update the include path for this project
        setIncludePath(project,
                includePathEntries.toArray(new IncludePath[includePathEntries
                        .size()]));
    }

    /**
     * Returns whether the given path is in the include definitions Meaning if
     * one of the entries in the include path has the same path of this resource
     * 
     * @param project
     * @param resourcePath
     * @return
     */
    public static IPath isInIncludePath(IProject project, IPath entryPath) {
        if (entryPath == null) {
            return null;
        }

        final IncludePathManager includepathManager = IncludePathManager
                .getInstance();
        final IncludePath[] includePathEntries = includepathManager
                .getIncludePaths(project);

        // go over the entries and compare the path.
        // checks if the path for one of the entries equals to the given one
        for (final IncludePath entry : includePathEntries) {
            final Object includePathEntry = entry.getEntry();
            IPath resourcePath = null;
            if (includePathEntry instanceof IBuildpathEntry) {
                final IBuildpathEntry bpEntry = (IBuildpathEntry) includePathEntry;
                resourcePath = bpEntry.getPath();
            }
            else {
                final IResource resource = (IResource) includePathEntry;
                resourcePath = resource.getFullPath();
            }

            if (resourcePath != null && resourcePath.isPrefixOf(entryPath)) {
                return resourcePath;
            }
        }
        return null;
    }

    /**
     * Adds the given listener to the list of Include path listeners
     * 
     * @param listener
     */
    public void registerIncludepathListener(IIncludepathListener listener) {
        if (listener == null) {
            throw new IllegalArgumentException(
                    "Error adding listener in IncludepathManager"); //$//$NON-NLS-1$
        }

        synchronized (this) {
            listeners.add(listener);
        }
    }

    /**
     * Removes the given listener to the list of Include path listeners
     * 
     * @param listener
     */
    public void unregisterIncludepathListener(IIncludepathListener listener) {
        if (listener == null) {
            throw new IllegalArgumentException(
                    "Error adding listener in IncludepathManager"); //$//$NON-NLS-1$
        }

        synchronized (this) {
            listeners.remove(listener);
        }
    }

    /**
     * Operates the refresh callback of the registered listeners
     * 
     * @param project
     */
    public synchronized void refresh(IProject project) {
        IIncludepathListener[] array = null;

        synchronized (this) {
            array = listeners
                    .toArray(new IIncludepathListener[listeners.size()]);
        }

        for (final IIncludepathListener includepathListener : array) {
            includepathListener.refresh(project);
        }
    }
}
