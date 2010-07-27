package org.zikula.modulestudio.generator.beautifier.pdt.internal.core.util.text;

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
 * Based on package org.eclipse.php.internal.core.util.text;
 * 
 *******************************************************************************/

import org.eclipse.wst.sse.core.internal.provisional.text.IStructuredDocumentRegion;

public interface TextSequence extends CharSequence {

    public IStructuredDocumentRegion getSource();

    public int getOriginalOffset(int index);

    public TextSequence subTextSequence(int start, int end);

    public TextSequence cutTextSequence(int start, int end);

}
