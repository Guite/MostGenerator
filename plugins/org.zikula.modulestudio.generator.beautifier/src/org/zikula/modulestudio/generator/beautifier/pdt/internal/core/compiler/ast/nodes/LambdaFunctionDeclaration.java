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
import java.util.LinkedList;
import java.util.List;

import org.eclipse.dltk.ast.ASTVisitor;
import org.eclipse.dltk.ast.expressions.Expression;
import org.eclipse.dltk.ast.statements.Block;
import org.eclipse.dltk.utils.CorePrinter;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.compiler.ast.visitor.ASTPrintVisitor;

/**
 * Represents a lambda function declaration e.g.
 * 
 * <pre>
 * function & (parameters) use (lexical vars) { body }
 * </pre>
 * 
 * @see http://wiki.php.net/rfc/closures
 */
public class LambdaFunctionDeclaration extends Expression {

    private final boolean isReference;
    private final List<? extends Expression> lexicalVars;
    protected List<FormalParameter> arguments = new LinkedList<FormalParameter>();
    private Block body = new Block();

    public LambdaFunctionDeclaration(int start, int end,
            List<FormalParameter> formalParameters,
            List<? extends Expression> lexicalVars, Block body,
            final boolean isReference) {
        super(start, end);

        if (formalParameters != null) {
            this.arguments = formalParameters;
        }
        this.body = body;

        this.lexicalVars = lexicalVars;
        this.isReference = isReference;
    }

    @Override
    public void traverse(ASTVisitor visitor) throws Exception {
        final boolean visit = visitor.visit(this);
        if (visit) {
            for (final FormalParameter param : arguments) {
                param.traverse(visitor);
            }

            if (lexicalVars != null) {
                for (final Expression var : lexicalVars) {
                    var.traverse(visitor);
                }
            }

            if (this.body != null) {
                this.body.traverse(visitor);
            }
        }
        visitor.endvisit(this);
    }

    public Collection<? extends Expression> getLexicalVars() {
        return lexicalVars;
    }

    public Collection<FormalParameter> getArguments() {
        return arguments;
    }

    public Block getBody() {
        return body;
    }

    public boolean isReference() {
        return isReference;
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

    @Override
    public int getKind() {
        return ASTNodeKinds.LAMBDA_FUNCTION;
    }
}
