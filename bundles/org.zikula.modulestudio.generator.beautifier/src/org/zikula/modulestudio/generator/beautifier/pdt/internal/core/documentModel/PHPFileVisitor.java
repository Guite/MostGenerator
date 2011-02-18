package org.zikula.modulestudio.generator.beautifier.pdt.internal.core.documentModel;

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
 * Based on package org.eclipse.php.internal.core.documentModel;
 * 
 *******************************************************************************/

import java.util.ArrayList;
import java.util.List;

import org.eclipse.core.resources.IFile;
import org.eclipse.core.resources.IResource;
import org.eclipse.core.resources.IResourceProxy;
import org.eclipse.core.resources.IResourceProxyVisitor;
import org.eclipse.core.runtime.CoreException;
import org.eclipse.core.runtime.Platform;
import org.eclipse.core.runtime.content.IContentDescription;
import org.eclipse.core.runtime.content.IContentType;
import org.eclipse.core.runtime.content.IContentTypeManager;
import org.eclipse.wst.validation.internal.provisional.core.IReporter;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.documentModel.provisional.contenttype.ContentTypeIdForPHP;

public class PHPFileVisitor implements IResourceProxyVisitor {

    protected List fFiles = new ArrayList();
    // private IContentType fContentTypeJSP = null;
    protected IReporter fReporter = null;

    public PHPFileVisitor(IReporter reporter) {
        fReporter = reporter;
    }

    @Override
    public boolean visit(IResourceProxy proxy) throws CoreException {

        // check validation
        if (fReporter.isCancelled()) {
            return false;
        }

        if (proxy.getType() == IResource.FILE) {
            final IFile file = (IFile) proxy.requestResource();
            if (file.exists()) {
                if (canHandle(file)) {
                    fFiles.add(file);
                    // don't search deeper for files
                    return false;
                }
            }
        }
        return true;
    }

    // Simple check for php file. When create PHP file wizard exist should be
    // able
    // to do a context check on file.

    protected boolean canHandle(IFile file) {
        boolean result = false;
        if (file != null) {
            try {
                final IContentTypeManager contentTypeManager = Platform
                        .getContentTypeManager();

                final IContentDescription contentDescription = file
                        .getContentDescription();
                final IContentType phpContentType = contentTypeManager
                        .getContentType(ContentTypeIdForPHP.ContentTypeID_PHP);
                if (contentDescription != null) {
                    final IContentType fileContentType = contentDescription
                            .getContentType();

                    if (phpContentType != null) {
                        if (fileContentType.isKindOf(phpContentType)) {
                            result = true;
                        }
                    }
                }
                else if (phpContentType != null) {
                    result = phpContentType.isAssociatedWith(file.getName());
                }
            } catch (final CoreException e) {
                // should be rare, but will ignore to avoid logging "encoding
                // exceptions" and the like here.
                // Logger.logException(e);
            }
        }
        return result;
    }

    public final IFile[] getFiles() {
        return (IFile[]) fFiles.toArray(new IFile[fFiles.size()]);
    }
}
