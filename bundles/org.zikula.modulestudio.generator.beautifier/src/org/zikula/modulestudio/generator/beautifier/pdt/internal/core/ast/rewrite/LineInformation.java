package org.zikula.modulestudio.generator.beautifier.pdt.internal.core.ast.rewrite;

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
 * Based on package org.eclipse.php.internal.core.ast.rewrite;
 * 
 *******************************************************************************/

import org.eclipse.jface.text.BadLocationException;
import org.eclipse.jface.text.IDocument;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.ast.nodes.Program;

/**
 * 
 */
public abstract class LineInformation {

    public static LineInformation create(final IDocument doc) {
        return new LineInformation() {
            @Override
            public int getLineOfOffset(int offset) {
                try {
                    return doc.getLineOfOffset(offset);
                } catch (final BadLocationException e) {
                    return -1;
                }
            }

            @Override
            public int getLineOffset(int line) {
                try {
                    return doc.getLineOffset(line);
                } catch (final BadLocationException e) {
                    return -1;
                }
            }
        };
    }

    public static LineInformation create(final Program astRoot) {
        return new LineInformation() {
            @Override
            public int getLineOfOffset(int offset) {
                return astRoot.getLineNumber(offset) - 1;
            }

            @Override
            public int getLineOffset(int line) {
                return astRoot.getPosition(line + 1, 0);
            }
        };
    }

    public abstract int getLineOfOffset(int offset);

    public abstract int getLineOffset(int line);

}
