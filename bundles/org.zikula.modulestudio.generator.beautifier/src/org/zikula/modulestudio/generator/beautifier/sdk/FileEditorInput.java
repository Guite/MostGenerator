package org.zikula.modulestudio.generator.beautifier.sdk;

/*******************************************************************************
 * Copyright (c) 2000, 2008 IBM Corporation and others. All rights reserved.
 * This program and the accompanying materials are made available under the
 * terms of the Eclipse Public License v1.0 which accompanies this distribution,
 * and is available at http://www.eclipse.org/legal/epl-v10.html
 * 
 * Contributors: IBM Corporation - initial API and implementation
 * 
 * 
 * Based on package org.eclipse.ui.part;
 * 
 *******************************************************************************/

import java.net.URI;

import org.eclipse.core.filesystem.EFS;
import org.eclipse.core.filesystem.IFileStore;
import org.eclipse.core.resources.IFile;
import org.eclipse.core.resources.IResourceStatus;
import org.eclipse.core.resources.IStorage;
import org.eclipse.core.runtime.CoreException;
import org.eclipse.core.runtime.IPath;
import org.eclipse.core.runtime.Path;
import org.eclipse.core.runtime.Platform;
import org.eclipse.core.runtime.PlatformObject;
import org.eclipse.core.runtime.content.IContentDescription;
import org.eclipse.core.runtime.content.IContentType;
import org.eclipse.jface.resource.ImageDescriptor;
import org.eclipse.ui.IFileEditorInput;
import org.eclipse.ui.IMemento;
import org.eclipse.ui.IPathEditorInput;
import org.eclipse.ui.IPersistableElement;
import org.eclipse.ui.IURIEditorInput;
import org.eclipse.ui.PlatformUI;
import org.eclipse.ui.internal.misc.UIStats;
import org.zikula.modulestudio.generator.beautifier.GeneratorBeautifierPlugin;

/**
 * Adapter for making a file resource a suitable input for an editor.
 * <p>
 * This class may be instantiated; it is not intended to be subclassed.
 * </p>
 * 
 * @noextend This class is not intended to be subclassed by clients.
 */
public class FileEditorInput extends PlatformObject implements
        IFileEditorInput, IPathEditorInput, IURIEditorInput,
        IPersistableElement {
    private final IFile file;

    /**
     * Creates an editor input based of the given file resource.
     * 
     * @param file
     *            the file resource
     */
    public FileEditorInput(IFile file) {
        if (file == null) {
            throw new IllegalArgumentException();
        }
        this.file = file;
    }

    /*
     * (non-Javadoc) Method declared on IEditorInput.
     */
    @Override
    public boolean exists() {
        return file.exists();
    }

    /*
     * (non-Javadoc) Method declared on IPersistableElement.
     */
    @Override
    public String getFactoryId() {
        return FileEditorInputFactory.getFactoryId();
    }

    /*
     * (non-Javadoc) Method declared on IFileEditorInput.
     */
    @Override
    public IFile getFile() {
        return file;
    }

    /*
     * (non-Javadoc) Method declared on IEditorInput.
     */
    @Override
    public ImageDescriptor getImageDescriptor() {
        final IContentType contentType = getContentType(file);
        return PlatformUI.getWorkbench().getEditorRegistry()
                .getImageDescriptor(file.getName(), contentType);
    }

    /**
     * Return the content type for the given file.
     * 
     * @param file
     *            the file to test
     * @return the content type, or <code>null</code> if it cannot be
     *         determined.
     * @since 3.1
     * @see package org.eclipse.ui.ide.IDE
     */
    public static IContentType getContentType(IFile file) {
        try {
            UIStats.start(UIStats.CONTENT_TYPE_LOOKUP, file.getName());
            final IContentDescription contentDescription = file
                    .getContentDescription();
            if (contentDescription == null) {
                return null;
            }
            return contentDescription.getContentType();
        } catch (final CoreException e) {
            if (e.getStatus().getCode() == IResourceStatus.OUT_OF_SYNC_LOCAL) {
                // Determine the content type from the file name.
                return Platform.getContentTypeManager().findContentTypeFor(
                        file.getName());
            }
            return null;
        } finally {
            UIStats.end(UIStats.CONTENT_TYPE_LOOKUP, file, file.getName());
        }
    }

    /*
     * (non-Javadoc) Method declared on IEditorInput.
     */
    @Override
    public String getName() {
        return file.getName();
    }

    /*
     * (non-Javadoc) Method declared on IEditorInput.
     */
    @Override
    public IPersistableElement getPersistable() {
        return this;
    }

    /*
     * (non-Javadoc) Method declared on IStorageEditorInput.
     */
    @Override
    public IStorage getStorage() {
        return file;
    }

    /*
     * (non-Javadoc) Method declared on IEditorInput.
     */
    @Override
    public String getToolTipText() {
        return file.getFullPath().makeRelative().toString();
    }

    /*
     * (non-Javadoc) Method declared on IPersistableElement.
     */
    @Override
    public void saveState(IMemento memento) {
        FileEditorInputFactory.saveState(memento, this);
    }

    /*
     * (non-Javadoc)
     * @see org.eclipse.ui.IURIEditorInput#getURI()
     */
    @Override
    public URI getURI() {
        return file.getLocationURI();
    }

    /*
     * (non-Javadoc)
     * @see org.eclipse.ui.IPathEditorInput#getPath()
     */
    @Override
    public IPath getPath() {
        final IPath location = file.getLocation();
        if (location != null) {
            return location;
        }
        // this is not a local file, so try to obtain a local file
        try {
            final URI locationURI = file.getLocationURI();
            if (locationURI == null) {
                throw new IllegalArgumentException();
            }
            final IFileStore store = EFS.getStore(locationURI);
            // first try to obtain a local file directly fo1r this store
            java.io.File localFile = store.toLocalFile(EFS.NONE, null);
            // if no local file is available, obtain a cached file
            if (localFile == null) {
                localFile = store.toLocalFile(EFS.CACHE, null);
            }
            if (localFile == null) {
                throw new IllegalArgumentException();
            }
            return Path.fromOSString(localFile.getAbsolutePath());
        } catch (final CoreException e) {
            // this can only happen if the file system is not available for this
            // scheme
            GeneratorBeautifierPlugin.log(e);
            throw new RuntimeException(e);
        }
    }
}
