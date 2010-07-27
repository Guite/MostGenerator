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
import org.eclipse.dltk.ast.references.TypeReference;
import org.eclipse.dltk.ast.references.VariableReference;
import org.eclipse.dltk.ast.statements.Block;
import org.eclipse.dltk.ast.statements.Statement;
import org.eclipse.dltk.utils.CorePrinter;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.compiler.ast.visitor.ASTPrintVisitor;

/**
 * Represents a catch clause (as part of a try statement)
 * 
 * <pre>e.g.
 * 
 * <pre> catch (ClassName $e) { },
 * 
 */
public class CatchClause extends Statement {

    private final TypeReference className;
    private final VariableReference variable;
    private final Block statement;

    public CatchClause(int start, int end, TypeReference className,
            VariableReference variable, Block statement) {
        super(start, end);

        assert className != null && variable != null && statement != null;
        this.className = className;
        this.variable = variable;
        this.statement = statement;
    }

    @Override
    public void traverse(ASTVisitor visitor) throws Exception {
        final boolean visit = visitor.visit(this);
        if (visit) {
            className.traverse(visitor);
            variable.traverse(visitor);
            statement.traverse(visitor);
        }
        visitor.endvisit(this);
    }

    @Override
    public int getKind() {
        return ASTNodeKinds.CATCH_CLAUSE;
    }

    public TypeReference getClassName() {
        return className;
    }

    public Block getStatement() {
        return statement;
    }

    public VariableReference getVariable() {
        return variable;
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
