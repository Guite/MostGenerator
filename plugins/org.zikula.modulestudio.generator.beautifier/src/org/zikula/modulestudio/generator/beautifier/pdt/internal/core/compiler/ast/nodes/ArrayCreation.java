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

import java.util.Collection;
import java.util.List;

import org.eclipse.dltk.ast.ASTVisitor;
import org.eclipse.dltk.ast.expressions.Expression;
import org.eclipse.dltk.utils.CorePrinter;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.compiler.ast.visitor.ASTPrintVisitor;

/**
 * Represents array creation
 * 
 * <pre>e.g.
 * 
 * <pre>
 * array(1,2,3,),
 * array('Dodo'=>'Golo','Dafna'=>'Dodidu')
 * array($a, $b=>foo(), 1=>$myClass->getFirst())
 */
public class ArrayCreation extends Expression {

    private final List<ArrayElement> elements;

    public ArrayCreation(int start, int end, List<ArrayElement> elements) {
        super(start, end);

        assert elements != null;
        this.elements = elements;
    }

    @Override
    public void traverse(ASTVisitor visitor) throws Exception {
        final boolean visit = visitor.visit(this);
        if (visit) {
            for (final ArrayElement element : elements) {
                element.traverse(visitor);
            }
        }
        visitor.endvisit(this);
    }

    @Override
    public int getKind() {
        return ASTNodeKinds.ARRAY_CREATION;
    }

    public Collection<ArrayElement> getElements() {
        return elements;
    }

    /**
     * We don't print anything - we use {@link ASTPrintVisitor} instead
     */
    @Override
    public final void printNode(CorePrinter output) {
    }

    @Override
    public String toString() {
        return ASTPrintVisitor.toXMLString(this);
    }
}
