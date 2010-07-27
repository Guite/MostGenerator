package org.zikula.modulestudio.generator.beautifier.pdt.internal.core.ast.nodes;

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
 * Based on package org.eclipse.php.internal.core.ast.nodes;
 * 
 *******************************************************************************/

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.PHPVersion;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.ast.match.ASTMatcher;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.ast.visitor.Visitor;

/**
 * Represents a list expression. The list contains variables and/or other lists.
 * 
 * <pre>e.g.
 * 
 * <pre>
 * list($a,$b) = array (1,2),
 * list($a, list($b, $c))
 */
public class ListVariable extends VariableBase {

    private final ASTNode.NodeList<VariableBase> variables = new ASTNode.NodeList<VariableBase>(
            VARIABLES_PROPERTY);

    /**
     * The structural property of this node type.
     */
    public static final ChildListPropertyDescriptor VARIABLES_PROPERTY = new ChildListPropertyDescriptor(
            ListVariable.class, "variables", VariableBase.class, CYCLE_RISK); //$NON-NLS-1$

    /**
     * A list of property descriptors (element type:
     * {@link StructuralPropertyDescriptor}), or null if uninitialized.
     */
    private static final List<StructuralPropertyDescriptor> PROPERTY_DESCRIPTORS;
    static {
        final List<StructuralPropertyDescriptor> properyList = new ArrayList<StructuralPropertyDescriptor>(
                2);
        properyList.add(VARIABLES_PROPERTY);
        PROPERTY_DESCRIPTORS = Collections.unmodifiableList(properyList);
    }

    private ListVariable(int start, int end, AST ast, VariableBase[] variables) {
        super(start, end, ast);

        if (variables == null) {
            throw new IllegalArgumentException();
        }
        for (final VariableBase variableBase : variables) {
            this.variables.add(variableBase);
        }
    }

    public ListVariable(AST ast) {
        super(ast);
    }

    public ListVariable(int start, int end, AST ast, List variables) {
        this(start, end, ast, variables == null ? null
                : (VariableBase[]) variables.toArray(new VariableBase[variables
                        .size()]));
    }

    @Override
    public void accept0(Visitor visitor) {
        final boolean visit = visitor.visit(this);
        if (visit) {
            childrenAccept(visitor);
        }
        visitor.endVisit(this);
    }

    @Override
    public void childrenAccept(Visitor visitor) {
        for (final ASTNode node : this.variables) {
            node.accept(visitor);
        }
    }

    @Override
    public void traverseTopDown(Visitor visitor) {
        accept(visitor);
        for (final ASTNode node : this.variables) {
            node.traverseTopDown(visitor);
        }
    }

    @Override
    public void traverseBottomUp(Visitor visitor) {
        for (final ASTNode node : this.variables) {
            node.traverseBottomUp(visitor);
        }
        accept(visitor);
    }

    @Override
    public void toString(StringBuffer buffer, String tab) {
        buffer.append(tab).append("<List"); //$NON-NLS-1$
        appendInterval(buffer);
        buffer.append(">\n"); //$NON-NLS-1$
        for (final ASTNode node : this.variables) {
            node.toString(buffer, TAB + tab);
            buffer.append("\n"); //$NON-NLS-1$
        }
        buffer.append(tab).append("</List>"); //$NON-NLS-1$
    }

    @Override
    public int getType() {
        return ASTNode.LIST_VARIABLE;
    }

    /**
     * @deprecated use {@link #variables()}
     */
    @Deprecated
    public VariableBase[] getVariables() {
        return variables.toArray(new VariableBase[this.variables.size()]);
    }

    /**
     * @return the list of variables
     */
    public List<VariableBase> variables() {
        return variables;
    }

    /*
     * Method declared on ASTNode.
     */
    @Override
    public boolean subtreeMatch(ASTMatcher matcher, Object other) {
        // dispatch to correct overloaded match method
        return matcher.match(this, other);
    }

    @Override
    final List internalGetChildListProperty(ChildListPropertyDescriptor property) {
        if (property == VARIABLES_PROPERTY) {
            return variables();
        }
        // allow default implementation to flag the error
        return super.internalGetChildListProperty(property);
    }

    @Override
    ASTNode clone0(AST target) {
        final List variables = ASTNode.copySubtrees(target, variables());
        final ListVariable result = new ListVariable(getStart(), getEnd(),
                target, variables);
        return result;
    }

    @Override
    List<StructuralPropertyDescriptor> internalStructuralPropertiesForType(
            PHPVersion apiLevel) {
        return PROPERTY_DESCRIPTORS;
    }
}
