package org.zikula.modulestudio.generator.beautifier.pdt.internal.core.compiler.ast.nodes;

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
 * Based on package org.eclipse.php.internal.core.compiler.ast.nodes;
 * 
 *******************************************************************************/

import java.util.LinkedList;
import java.util.List;

import org.eclipse.dltk.ast.ASTVisitor;

public class PHPDocBlock extends Comment {

    private final String shortDescription;
    private final PHPDocTag[] tags;

    public PHPDocBlock(int start, int end, String shortDescription,
            PHPDocTag[] tags) {
        super(start, end, Comment.TYPE_PHPDOC);
        this.shortDescription = shortDescription;
        this.tags = tags;
    }

    @Override
    public void traverse(ASTVisitor visitor) throws Exception {
        final boolean visit = visitor.visit(this);
        if (visit) {
            for (final PHPDocTag tag : tags) {
                tag.traverse(visitor);
            }
        }
        visitor.endvisit(this);
    }

    public int getKind() {
        return ASTNodeKinds.PHP_DOC_BLOCK;
    }

    public String getShortDescription() {
        return shortDescription;
    }

    public PHPDocTag[] getTags() {
        return tags;
    }

    public PHPDocTag[] getTags(int kind) {
        final List<PHPDocTag> res = new LinkedList<PHPDocTag>();
        if (tags != null) {
            for (final PHPDocTag tag : tags) {
                if (tag.getTagKind() == kind) {
                    res.add(tag);
                }
            }
        }
        return res.toArray(new PHPDocTag[res.size()]);
    }

    public void adjustStart(int start) {
        setStart(sourceStart() + start);
        setEnd(sourceEnd() + start);

        for (final PHPDocTag tag : tags) {
            tag.adjustStart(start);
        }
    }

}
