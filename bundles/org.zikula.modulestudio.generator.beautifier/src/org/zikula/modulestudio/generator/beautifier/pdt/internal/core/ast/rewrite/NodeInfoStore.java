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

import java.util.HashSet;
import java.util.IdentityHashMap;
import java.util.Map;
import java.util.Set;

import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.ast.nodes.AST;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.ast.nodes.ASTNode;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.ast.nodes.Assignment;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.ast.nodes.Block;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.ast.nodes.ForStatement;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.ast.nodes.InfixExpression;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.ast.nodes.PostfixExpression;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.ast.nodes.Variable;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.ast.rewrite.RewriteEventStore.CopySourceInfo;

/**
 *
 */
public final class NodeInfoStore {
    private final AST ast;

    private Map placeholderNodes;
    private Set collapsedNodes;

    public NodeInfoStore(AST ast) {
        super();
        this.ast = ast;
        this.placeholderNodes = null;
        this.collapsedNodes = null;
    }

    /**
     * Marks a node as a placehoder for a plain string content. The type of the
     * node should correspond to the code's code content.
     * 
     * @param placeholder
     *            The placeholder node that acts for the string content.
     * @param code
     *            The string content.
     */
    public final void markAsStringPlaceholder(ASTNode placeholder, String code) {
        final StringPlaceholderData data = new StringPlaceholderData();
        data.code = code;
        setPlaceholderData(placeholder, data);
    }

    /**
     * Marks a node as a copy or move target. The copy target represents a
     * copied node at the target (copied) site.
     * 
     * @param target
     *            The node at the target site. Can be a placeholder node but
     *            also the source node itself.
     * @param copySource
     *            The info at the source site.
     */
    public final void markAsCopyTarget(ASTNode target, CopySourceInfo copySource) {
        final CopyPlaceholderData data = new CopyPlaceholderData();
        data.copySource = copySource;
        setPlaceholderData(target, data);
    }

    /**
     * Creates a placeholder node of the given type. <code>null</code> if the
     * type is not supported
     * 
     * @param nodeType
     *            Type of the node to create. Use the type constants in
     *            {@link NodeInfoStore}.
     * @return Returns a place holder node.
     */
    public final ASTNode newPlaceholderNode(int nodeType) {
        try {
            final ASTNode node = this.ast.createInstance(nodeType);

            switch (node.getType()) {
                case ASTNode.ASSIGNMENT:
                    final Assignment assignment = (Assignment) node;
                    assignment.setLeftHandSide(this.ast.newVariable("a"));
                    assignment.setOperator(Assignment.OP_EQUAL);
                    assignment.setRightHandSide(this.ast.newVariable("a"));
                    break;
                case ASTNode.INFIX_EXPRESSION:
                    final InfixExpression expression = (InfixExpression) node;
                    expression.setLeft(this.ast.newScalar("a"));
                    expression.setOperator(InfixExpression.OP_MINUS);
                    expression.setRight(this.ast.newVariable("a"));
                    break;
                case ASTNode.VARIABLE:
                    final Variable variable = (Variable) node;
                    variable.setName(this.ast.newIdentifier(""));
                    break;
                case ASTNode.FOR_STATEMENT:
                    final ForStatement forStatement = (ForStatement) node;
                    final Assignment assignment1 = this.ast.newAssignment();
                    assignment1.setLeftHandSide(this.ast.newVariable("a"));
                    assignment1.setOperator(Assignment.OP_EQUAL);
                    assignment1.setRightHandSide(this.ast.newVariable("a"));
                    forStatement.initializers().add(assignment1);

                    final InfixExpression expression1 = this.ast
                            .newInfixExpression();
                    expression1.setLeft(this.ast.newScalar("a"));
                    expression1.setOperator(InfixExpression.OP_IS_NOT_EQUAL);
                    expression1.setRight(this.ast.newVariable("a"));

                    forStatement.conditions().add(expression1);

                    final PostfixExpression pexp = this.ast
                            .newPostfixExpression();
                    pexp.setOperator(PostfixExpression.OP_INC);
                    pexp.setVariable(this.ast.newVariable("a"));

                    forStatement.updaters().add(pexp);
                    forStatement.setBody(this.ast.newBlock());

                    break;
            }
            return node;
        } catch (final IllegalArgumentException e) {
            return null;
        }
    }

    // collapsed nodes: in source: use one node that represents many; to be used
    // as
    // copy/move source or to replace at once.
    // in the target: one block node that is not flattened.

    public Block createCollapsePlaceholder() {
        final Block placeHolder = this.ast.newBlock();
        if (this.collapsedNodes == null) {
            this.collapsedNodes = new HashSet();
        }
        this.collapsedNodes.add(placeHolder);
        return placeHolder;
    }

    public boolean isCollapsed(ASTNode node) {
        if (this.collapsedNodes != null) {
            return this.collapsedNodes.contains(node);
        }
        return false;
    }

    public Object getPlaceholderData(ASTNode node) {
        if (this.placeholderNodes != null) {
            return this.placeholderNodes.get(node);
        }
        return null;
    }

    private void setPlaceholderData(ASTNode node, PlaceholderData data) {
        if (this.placeholderNodes == null) {
            this.placeholderNodes = new IdentityHashMap();
        }
        this.placeholderNodes.put(node, data);
    }

    static class PlaceholderData {
        // base class
    }

    protected static final class CopyPlaceholderData extends PlaceholderData {
        public CopySourceInfo copySource;

        @Override
        public String toString() {
            return "[placeholder " + this.copySource + "]"; //$NON-NLS-1$//$NON-NLS-2$
        }
    }

    protected static final class StringPlaceholderData extends PlaceholderData {
        public String code;

        @Override
        public String toString() {
            return "[placeholder string: " + this.code + "]"; //$NON-NLS-1$ //$NON-NLS-2$
        }
    }

    /**
	 * 
	 */
    public void clear() {
        this.placeholderNodes = null;
        this.collapsedNodes = null;
    }
}
