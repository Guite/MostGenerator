package org.zikula.modulestudio.generator.beautifier.pdt.internal.ui.editor;

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
 * Based on package org.eclipse.php.internal.ui.editor;
 * 
 *******************************************************************************/

import java.net.URI;

import org.eclipse.core.resources.IFile;
import org.eclipse.core.resources.IStorage;
import org.eclipse.core.runtime.CoreException;
import org.eclipse.core.runtime.IPath;
import org.eclipse.jface.resource.ImageDescriptor;
import org.eclipse.ui.IFileEditorInput;
import org.eclipse.ui.IMemento;
import org.eclipse.ui.IPathEditorInput;
import org.eclipse.ui.IPersistableElement;
import org.eclipse.ui.IURIEditorInput;
import org.zikula.modulestudio.generator.beautifier.sdk.FileEditorInput;
import org.zikula.modulestudio.generator.beautifier.sdk.FileEditorInputFactory;

public class RefactorableFileEditorInput implements IFileEditorInput,
        IPathEditorInput, IURIEditorInput, IPersistableElement {
    private boolean isRefactor = false;
    private FileEditorInput innerEidtorInput;

    public RefactorableFileEditorInput(IFile file) {
        this.innerEidtorInput = new FileEditorInput(file);
    }

    /*
     * (non-Javadoc) Method declared on IPersistableElement.
     */
    @Override
    public String getFactoryId() {
        return FileEditorInputFactory.getFactoryId();
    }

    /*
     * (non-Javadoc)
     * @see org.eclipse.ui.IPathEditorInput#getPath()
     */
    @Override
    public IPath getPath() {
        return innerEidtorInput.getPath();
    }

    /*
     * (non-Javadoc)
     * @see org.eclipse.ui.IURIEditorInput#getURI()
     */
    @Override
    public URI getURI() {
        return innerEidtorInput.getURI();
    }

    /*
     * (non-Javadoc) Method declared on Object.
     */
    @Override
    public int hashCode() {
        return innerEidtorInput.hashCode();
    }

    /*
     * (non-Javadoc) Method declared on IPersistableElement.
     */
    @Override
    public void saveState(IMemento memento) {
        FileEditorInputFactory.saveState(memento, innerEidtorInput);
    }

    /*
     * (non-Javadoc)
     * @see java.lang.Object#toString()
     */
    @Override
    public String toString() {
        return innerEidtorInput.toString();
    }

    public void setFile(IFile file) {
        this.innerEidtorInput = new FileEditorInput(file);
    }

    public boolean isRefactor() {
        return isRefactor;
    }

    public void setRefactor(boolean isRefactor) {
        this.isRefactor = isRefactor;
    }

    @Override
    public boolean equals(Object obj) {
        if (this == obj) {
            return true;
        }
        if (!(obj instanceof IFileEditorInput)) {
            return false;
        }
        return innerEidtorInput.equals(obj);
    }

    @Override
    public IFile getFile() {
        return innerEidtorInput.getFile();
    }

    @Override
    public IStorage getStorage() throws CoreException {
        return innerEidtorInput.getStorage();
    }

    @Override
    public boolean exists() {
        return innerEidtorInput.exists();
    }

    @Override
    public ImageDescriptor getImageDescriptor() {
        return innerEidtorInput.getImageDescriptor();
    }

    @Override
    public String getName() {
        return innerEidtorInput.getName();
    }

    @Override
    public IPersistableElement getPersistable() {
        // if the file has been deleted,return null will make this EidtorInput
        // be removed from NavigationHistory
        if (!innerEidtorInput.getFile().exists()) {
            return null;
        }
        return innerEidtorInput.getPersistable();
    }

    @Override
    public String getToolTipText() {
        return innerEidtorInput.getToolTipText();
    }

    @Override
    public Object getAdapter(Class adapter) {
        return innerEidtorInput.getAdapter(adapter);
    }
}
