package org.zikula.modulestudio.generator.beautifier.sdk;

import java.io.IOException;
import java.io.InputStream;
import java.util.ArrayList;

import org.eclipse.core.filesystem.EFS;
import org.eclipse.core.filesystem.IFileStore;
import org.eclipse.core.resources.IFile;
import org.eclipse.core.resources.IWorkspaceRoot;
import org.eclipse.core.resources.ResourcesPlugin;
import org.eclipse.core.runtime.CoreException;
import org.eclipse.core.runtime.Platform;
import org.eclipse.core.runtime.content.IContentType;
import org.eclipse.ui.IEditorDescriptor;
import org.eclipse.ui.IEditorInput;
import org.eclipse.ui.IEditorPart;
import org.eclipse.ui.IEditorRegistry;
import org.eclipse.ui.IWorkbenchPage;
import org.eclipse.ui.PartInitException;
import org.eclipse.ui.PlatformUI;

/*******************************************************************************
 * Copyright (c) 2003, 2010 IBM Corporation and others. All rights reserved.
 * This program and the accompanying materials are made available under the
 * terms of the Eclipse Public License v1.0 which accompanies this distribution,
 * and is available at http://www.eclipse.org/legal/epl-v10.html
 * 
 * Contributors: IBM Corporation - initial API and implementation
 * 
 * 
 * 
 * Based on package org.eclipse.ui.ide;
 * 
 *******************************************************************************/

/**
 * Collection of IDE-specific APIs factored out of existing workbench. This
 * class cannot be instantiated; all functionality is provided by static methods
 * and fields.
 * 
 * @since 3.0
 */
public final class IDE {

    /**
     * Create the Editor Input appropriate for the given <code>IFileStore</code>
     * . The result is a normal file editor input if the file exists in the
     * workspace and, if not, we create a wrapper capable of managing an
     * 'external' file using its <code>IFileStore</code>.
     * 
     * @param fileStore
     *            The file store to provide the editor input for
     * @return The editor input associated with the given file store
     * @since 3.3
     */
    private static IEditorInput getEditorInput(IFileStore fileStore) {
        final IFile workspaceFile = getWorkspaceFile(fileStore);
        if (workspaceFile != null) {
            return new FileEditorInput(workspaceFile);
        }
        return new FileStoreEditorInput(fileStore);
    }

    /**
     * Determine whether or not the <code>IFileStore</code> represents a file
     * currently in the workspace.
     * 
     * @param fileStore
     *            The <code>IFileStore</code> to test
     * @return The workspace's <code>IFile</code> if it exists or
     *         <code>null</code> if not
     */
    public static IFile getWorkspaceFile(IFileStore fileStore) {
        final IWorkspaceRoot root = ResourcesPlugin.getWorkspace().getRoot();
        IFile[] files = root.findFilesForLocationURI(fileStore.toURI());
        files = filterNonExistentFiles(files);
        if (files == null || files.length == 0) {
            return null;
        }

        // for now only return the first file
        return files[0];
    }

    /**
     * Filter the incoming array of <code>IFile</code> elements by removing any
     * that do not currently exist in the workspace.
     * 
     * @param files
     *            The array of <code>IFile</code> elements
     * @return The filtered array
     */
    private static IFile[] filterNonExistentFiles(IFile[] files) {
        if (files == null) {
            return null;
        }

        final int length = files.length;
        final ArrayList existentFiles = new ArrayList(length);
        for (int i = 0; i < length; i++) {
            if (files[i].exists()) {
                existentFiles.add(files[i]);
            }
        }
        return (IFile[]) existentFiles.toArray(new IFile[existentFiles.size()]);
    }

    /**
     * Returns an editor id appropriate for opening the given file store.
     * <p>
     * The editor descriptor is determined using a multi-step process. This
     * method will attempt to resolve the editor based on content-type bindings
     * as well as traditional name/extension bindings.
     * </p>
     * <ol>
     * <li>The workbench editor registry is consulted to determine if an editor
     * extension has been registered for the file type. If so, an instance of
     * the editor extension is opened on the file. See
     * <code>IEditorRegistry.getDefaultEditor(String)</code>.</li>
     * <li>The operating system is consulted to determine if an in-place
     * component editor is available (e.g. OLE editor on Win32 platforms).</li>
     * <li>The operating system is consulted to determine if an external editor
     * is available.</li>
     * <li>The workbench editor registry is consulted to determine if the
     * default text editor is available.</li>
     * </ol>
     * </p>
     * 
     * @param fileStore
     *            the file store
     * @return the id of an editor, appropriate for opening the file
     * @throws PartInitException
     *             if no editor can be found
     */
    private static String getEditorId(IFileStore fileStore)
            throws PartInitException {
        final String name = fileStore.fetchInfo().getName();
        if (name == null) {
            throw new IllegalArgumentException();
        }

        IContentType contentType = null;
        try {
            InputStream is = null;
            try {
                is = fileStore.openInputStream(EFS.NONE, null);
                contentType = Platform.getContentTypeManager()
                        .findContentTypeFor(is, name);
            } finally {
                if (is != null) {
                    is.close();
                }
            }
        } catch (final CoreException ex) {
            // continue without content type
        } catch (final IOException ex) {
            // continue without content type
        }

        final IEditorRegistry editorReg = PlatformUI.getWorkbench()
                .getEditorRegistry();

        return getEditorDescriptor(name, editorReg,
                editorReg.getDefaultEditor(name, contentType)).getId();
    }

    /**
     * Get the editor descriptor for a given name using the editorDescriptor
     * passed in as a default as a starting point.
     * 
     * @param name
     *            The name of the element to open.
     * @param editorReg
     *            The editor registry to do the lookups from.
     * @param defaultDescriptor
     *            IEditorDescriptor or <code>null</code>
     * @return IEditorDescriptor
     * @throws PartInitException
     *             if no valid editor can be found
     * 
     * @since 3.1
     */
    private static IEditorDescriptor getEditorDescriptor(String name,
            IEditorRegistry editorReg, IEditorDescriptor defaultDescriptor)
            throws PartInitException {

        if (defaultDescriptor != null) {
            return defaultDescriptor;
        }

        IEditorDescriptor editorDesc = defaultDescriptor;

        // next check the OS for in-place editor (OLE on Win32)
        if (editorReg.isSystemInPlaceEditorAvailable(name)) {
            editorDesc = editorReg
                    .findEditor(IEditorRegistry.SYSTEM_INPLACE_EDITOR_ID);
        }

        // next check with the OS for an external editor
        if (editorDesc == null
                && editorReg.isSystemExternalEditorAvailable(name)) {
            editorDesc = editorReg
                    .findEditor(IEditorRegistry.SYSTEM_EXTERNAL_EDITOR_ID);
        }

        // next lookup the default text editor
        if (editorDesc == null) {
            editorDesc = editorReg
                    .findEditor(IDEWorkbenchPlugin.DEFAULT_TEXT_EDITOR_ID);
        }

        // if no valid editor found, bail out
        if (editorDesc == null) {
            throw new PartInitException("No file editor found");
        }

        return editorDesc;
    }

    /**
     * Opens an editor on the given IFileStore object.
     * <p>
     * Unlike the other <code>openEditor</code> methods, this one can be used to
     * open files that reside outside the workspace resource set.
     * </p>
     * <p>
     * If the page already has an editor open on the target object then that
     * editor is brought to front; otherwise, a new editor is opened.
     * </p>
     * 
     * @param page
     *            the page in which the editor will be opened
     * @param fileStore
     *            the IFileStore representing the file to open
     * @return an open editor or <code>null</code> if an external editor was
     *         opened
     * @exception PartInitException
     *                if the editor could not be initialized
     * @see org.eclipse.ui.IWorkbenchPage#openEditor(IEditorInput, String)
     * @since 3.3
     */
    public static IEditorPart openEditorOnFileStore(IWorkbenchPage page,
            IFileStore fileStore) throws PartInitException {
        // sanity checks
        if (page == null) {
            throw new IllegalArgumentException();
        }

        final IEditorInput input = getEditorInput(fileStore);
        final String editorId = "org.zikula.modulestudio.generator.beautifier.pdt.editor";// "org.eclipse.ui.DefaultTextEditor";//
        // getEditorId(fileStore);

        // open the editor on the file
        return page.openEditor(input, editorId);
    }
}
