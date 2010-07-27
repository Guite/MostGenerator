package org.zikula.modulestudio.generator.beautifier.sdk;

/*******************************************************************************
 * Copyright (c) 2007 IBM Corporation and others. All rights reserved. This
 * program and the accompanying materials are made available under the terms of
 * the Eclipse Public License v1.0 which accompanies this distribution, and is
 * available at http://www.eclipse.org/legal/epl-v10.html
 * 
 * Contributors: IBM Corporation - initial API and implementation
 * 
 * 
 * 
 * Based on package org.eclipse.ui.ide;
 * 
 *******************************************************************************/

import java.net.URI;

import org.eclipse.core.filesystem.IFileStore;
import org.eclipse.core.runtime.Assert;
import org.eclipse.core.runtime.Platform;
import org.eclipse.jface.resource.ImageDescriptor;
import org.eclipse.ui.IMemento;
import org.eclipse.ui.IPersistableElement;
import org.eclipse.ui.IURIEditorInput;
import org.eclipse.ui.model.IWorkbenchAdapter;

/**
 * Implements an IEditorInput instance appropriate for <code>IFileStore</code>
 * elements that represent files that are not part of the current workspace.
 * 
 * @since 3.3
 * 
 */
public class FileStoreEditorInput implements IURIEditorInput,
        IPersistableElement {

    /**
     * The workbench adapter which simply provides the label.
     * 
     * @since 3.3
     */
    private static class WorkbenchAdapter implements IWorkbenchAdapter {
        /*
         * @see
         * org.eclipse.ui.model.IWorkbenchAdapter#getChildren(java.lang.Object)
         */
        @Override
        public Object[] getChildren(Object o) {
            return null;
        }

        /*
         * @see
         * org.eclipse.ui.model.IWorkbenchAdapter#getImageDescriptor(java.lang
         * .Object)
         */
        @Override
        public ImageDescriptor getImageDescriptor(Object object) {
            return null;
        }

        /*
         * @see
         * org.eclipse.ui.model.IWorkbenchAdapter#getLabel(java.lang.Object)
         */
        @Override
        public String getLabel(Object o) {
            return ((FileStoreEditorInput) o).getName();
        }

        /*
         * @see
         * org.eclipse.ui.model.IWorkbenchAdapter#getParent(java.lang.Object)
         */
        @Override
        public Object getParent(Object o) {
            return null;
        }
    }

    private final IFileStore fileStore;
    private WorkbenchAdapter workbenchAdapter = new WorkbenchAdapter();

    /**
     * @param fileStore
     */
    public FileStoreEditorInput(IFileStore fileStore) {
        Assert.isNotNull(fileStore);
        this.fileStore = fileStore;
        workbenchAdapter = new WorkbenchAdapter();
    }

    /*
     * @see org.eclipse.ui.IEditorInput#exists()
     */
    @Override
    public boolean exists() {
        return fileStore.fetchInfo().exists();
    }

    /*
     * @see org.eclipse.ui.IEditorInput#getImageDescriptor()
     */
    @Override
    public ImageDescriptor getImageDescriptor() {
        return null;
    }

    /*
     * @see org.eclipse.ui.IEditorInput#getName()
     */
    @Override
    public String getName() {
        return fileStore.getName();
    }

    /*
     * @see org.eclipse.ui.IEditorInput#getPersistable()
     */
    @Override
    public IPersistableElement getPersistable() {
        return this;
    }

    /*
     * @see org.eclipse.ui.IEditorInput#getToolTipText()
     */
    @Override
    public String getToolTipText() {
        return fileStore.toString();
    }

    /*
     * @see org.eclipse.core.runtime.IAdaptable#getAdapter(java.lang.Class)
     */
    @Override
    public Object getAdapter(Class adapter) {
        if (IWorkbenchAdapter.class.equals(adapter)) {
            return workbenchAdapter;
        }
        return Platform.getAdapterManager().getAdapter(this, adapter);
    }

    /*
     * @see java.lang.Object#equals(java.lang.Object)
     */
    @Override
    public boolean equals(Object o) {
        if (o == this) {
            return true;
        }

        if (o instanceof FileStoreEditorInput) {
            final FileStoreEditorInput input = (FileStoreEditorInput) o;
            return fileStore.equals(input.fileStore);
        }

        return false;
    }

    /*
     * @see java.lang.Object#hashCode()
     */
    @Override
    public int hashCode() {
        return fileStore.hashCode();
    }

    /*
     * (non-Javadoc)
     * @see org.eclipse.ui.IURIEditorInput#getURI()
     */
    @Override
    public URI getURI() {
        return fileStore.toURI();
    }

    /*
     * (non-Javadoc)
     * @see org.eclipse.ui.IPersistableElement#getFactoryId()
     */
    @Override
    public String getFactoryId() {
        return FileStoreEditorInputFactory.ID;
    }

    /*
     * (non-Javadoc)
     * @see org.eclipse.ui.IPersistable#saveState(org.eclipse.ui.IMemento)
     */
    @Override
    public void saveState(IMemento memento) {
        FileStoreEditorInputFactory.saveState(memento, this);

    }

}
