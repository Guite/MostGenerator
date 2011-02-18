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

import org.eclipse.dltk.ast.ASTVisitor;
import org.eclipse.dltk.ast.declarations.Declaration;
import org.eclipse.dltk.ast.expressions.Expression;
import org.eclipse.dltk.ast.references.ConstantReference;
import org.eclipse.dltk.utils.CorePrinter;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.compiler.ast.visitor.ASTPrintVisitor;

/**
 * Represents a class/namespace constant declaration
 * 
 * <pre>e.g.
 * 
 * <pre>
 * const MY_CONST = 5;
 * const MY_CONST = 5, YOUR_CONSTANT = 8;
 */
public class ConstantDeclaration extends Declaration implements
        IPHPDocAwareDeclaration {

    private final ConstantReference constant;
    private final Expression initializer;
    private final PHPDocBlock phpDoc;

    public ConstantDeclaration(ConstantReference constant,
            Expression initializer, int start, int end, PHPDocBlock phpDoc) {
        super(start, end);

        assert constant != null;
        assert initializer != null;

        this.constant = constant;
        this.initializer = initializer;
        this.phpDoc = phpDoc;

        setName(constant.getName());
    }

    @Override
    public PHPDocBlock getPHPDoc() {
        return phpDoc;
    }

    @Override
    public void traverse(ASTVisitor visitor) throws Exception {
        final boolean visit = visitor.visit(this);
        if (visit) {
            constant.traverse(visitor);
            initializer.traverse(visitor);
        }
        visitor.endvisit(this);
    }

    @Override
    public int getKind() {
        return ASTNodeKinds.CLASS_CONSTANT_DECLARATION;
    }

    public Expression getConstantValue() {
        return initializer;
    }

    public ConstantReference getConstantName() {
        return constant;
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
