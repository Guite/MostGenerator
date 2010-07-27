package org.zikula.modulestudio.generator.beautifier.pdt.internal.core.codeassist;

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
 * Based on package org.eclipse.php.internal.core.codeassist;
 * 
 *******************************************************************************/

import org.eclipse.jface.text.IDocument;

/**
 * PHP related completion requestor helps to understand how code assist was
 * invoked: explicitly by the user or using automatic triggering mechanism. In
 * addition, it passes all needed information from the code assist invoking part
 * in the UI plug-in to the completion engine in the Core plug-in.
 * 
 * @author michael
 */
public interface IPHPCompletionRequestor {

    /**
     * Returns document of the editor where code assist was invoked
     * 
     * @return editor document
     */
    public IDocument getDocument();

    /**
     * Returns <code>true</code> if code assist was invoked excplicitly by user,
     * otherwise <code>false</code>
     * 
     * @return whether code assist invoked explicitly
     */
    public boolean isExplicit();

    /**
     * Returns offset of the document where code assist was invoked
     * 
     * @return document offset
     */
    public int getOffset();

    /**
     * Returns offset of the document where code assist was invoked
     * 
     * @return document offset
     */
    public void setOffset(int offset);
}
