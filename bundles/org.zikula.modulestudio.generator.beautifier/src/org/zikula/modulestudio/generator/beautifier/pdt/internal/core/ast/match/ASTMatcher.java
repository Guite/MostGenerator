package org.zikula.modulestudio.generator.beautifier.pdt.internal.core.ast.match;

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
 * Based on package org.eclipse.php.internal.core.ast.match;
 * 
 *******************************************************************************/

import java.util.Arrays;
import java.util.Collection;
import java.util.Iterator;
import java.util.Map;

import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.ast.nodes.ASTError;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.ast.nodes.ASTNode;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.ast.nodes.ArrayAccess;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.ast.nodes.ArrayCreation;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.ast.nodes.ArrayElement;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.ast.nodes.Assignment;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.ast.nodes.BackTickExpression;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.ast.nodes.Block;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.ast.nodes.BreakStatement;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.ast.nodes.CastExpression;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.ast.nodes.CatchClause;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.ast.nodes.ClassDeclaration;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.ast.nodes.ClassInstanceCreation;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.ast.nodes.ClassName;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.ast.nodes.CloneExpression;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.ast.nodes.Comment;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.ast.nodes.ConditionalExpression;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.ast.nodes.ConstantDeclaration;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.ast.nodes.ContinueStatement;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.ast.nodes.DeclareStatement;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.ast.nodes.DoStatement;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.ast.nodes.EchoStatement;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.ast.nodes.EmptyStatement;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.ast.nodes.Expression;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.ast.nodes.ExpressionStatement;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.ast.nodes.FieldAccess;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.ast.nodes.FieldsDeclaration;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.ast.nodes.ForEachStatement;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.ast.nodes.ForStatement;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.ast.nodes.FormalParameter;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.ast.nodes.FunctionDeclaration;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.ast.nodes.FunctionInvocation;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.ast.nodes.FunctionName;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.ast.nodes.GlobalStatement;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.ast.nodes.GotoLabel;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.ast.nodes.GotoStatement;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.ast.nodes.Identifier;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.ast.nodes.IfStatement;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.ast.nodes.IgnoreError;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.ast.nodes.InLineHtml;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.ast.nodes.Include;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.ast.nodes.InfixExpression;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.ast.nodes.InstanceOfExpression;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.ast.nodes.InterfaceDeclaration;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.ast.nodes.LambdaFunctionDeclaration;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.ast.nodes.ListVariable;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.ast.nodes.MethodDeclaration;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.ast.nodes.MethodInvocation;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.ast.nodes.NamespaceDeclaration;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.ast.nodes.NamespaceName;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.ast.nodes.ParenthesisExpression;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.ast.nodes.PostfixExpression;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.ast.nodes.PrefixExpression;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.ast.nodes.Program;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.ast.nodes.Quote;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.ast.nodes.Reference;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.ast.nodes.ReflectionVariable;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.ast.nodes.ReturnStatement;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.ast.nodes.Scalar;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.ast.nodes.SingleFieldDeclaration;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.ast.nodes.Statement;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.ast.nodes.StaticConstantAccess;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.ast.nodes.StaticFieldAccess;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.ast.nodes.StaticMethodInvocation;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.ast.nodes.StaticStatement;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.ast.nodes.SwitchCase;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.ast.nodes.SwitchStatement;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.ast.nodes.ThrowStatement;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.ast.nodes.TryStatement;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.ast.nodes.TypeDeclaration;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.ast.nodes.UnaryOperation;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.ast.nodes.UseStatement;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.ast.nodes.UseStatementPart;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.ast.nodes.Variable;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.ast.nodes.WhileStatement;

/**
 * Concrete superclass and default implementation of an AST subtree matcher.
 * <p>
 * For example, to compute whether two ASTs subtrees are structurally
 * isomorphic, use <code>n1.subtreeMatch(new ASTMatcher(), n2)</code> where
 * <code>n1</code> and <code>n2</code> are the AST root nodes of the subtrees.
 * </p>
 * <p>
 * For each different concrete AST node type <i>T</i> there is a
 * <code>public boolean match(<i>T</i> node, Object other)</code> method that
 * matches the given node against another object (typically another AST node,
 * although this is not essential). The default implementations provided by this
 * class tests whether the other object is a node of the same type with
 * structurally isomorphic child subtrees. For nodes with list-valued
 * properties, the child nodes within the list are compared in order. For nodes
 * with multiple properties, the child nodes are compared in the order that most
 * closely corresponds to the lexical reading order of the source program. For
 * instance, for a type declaration node, the child ordering is: name,
 * superclass, superinterfaces, and body declarations.
 * </p>
 * <p>
 * Subclasses may override (extend or reimplement) some or all of the
 * <code>match</code> methods in order to define more specialized subtree
 * matchers.
 * </p>
 * 
 * @see ASTNode#subtreeMatch(ASTMatcher, Object)
 * @since 2.0
 */
public class ASTMatcher {

    /**
     * Indicates whether doc tags should be matched.
     * 
     * @since 3.0
     */
    private final boolean matchDocTags;

    /**
     * Creates a new AST matcher instance.
     * <p>
     * For backwards compatibility, the matcher ignores tag elements below doc
     * comments by default. Use {@link #ASTMatcher(boolean) ASTMatcher(true)}
     * for a matcher that compares doc tags by default.
     * </p>
     */
    public ASTMatcher() {
        this(false);
    }

    /**
     * Creates a new AST matcher instance.
     * 
     * @param matchDocTags
     *            <code>true</code> if doc comment tags are to be compared by
     *            default, and <code>false</code> otherwise
     * @see #match(Javadoc,Object)
     * @since 3.0
     */
    public ASTMatcher(boolean matchDocTags) {
        this.matchDocTags = matchDocTags;
    }

    /**
     * Returns whether the given lists of AST nodes match pair wise according to
     * <code>ASTNode.subtreeMatch</code>.
     * <p>
     * Note that this is a convenience method, useful for writing recursive
     * subtree matchers.
     * </p>
     * 
     * @param list1
     *            the first list of AST nodes (element type:
     *            <code>ASTNode</code>)
     * @param list2
     *            the second list of AST nodes (element type:
     *            <code>ASTNode</code>)
     * @return <code>true</code> if the lists have the same number of elements
     *         and match pair-wise according to
     *         <code>ASTNode.subtreeMatch</code>
     * @see ASTNode#subtreeMatch(ASTMatcher matcher, Object other)
     */
    public final boolean safeSubtreeListMatch(Collection list1, Collection list2) {
        final int size1 = list1.size();
        final int size2 = list2.size();
        if (size1 != size2) {
            return false;
        }
        for (Iterator it1 = list1.iterator(), it2 = list2.iterator(); it1
                .hasNext();) {
            final ASTNode n1 = (ASTNode) it1.next();
            final ASTNode n2 = (ASTNode) it2.next();
            if (n1 == null && n2 == null) {
                continue;
            }

            if (n1 == null || n2 == null) {
                return false;
            }

            if (!n1.subtreeMatch(this, n2)) {
                return false;
            }
        }
        return true;
    }

    /**
     * Returns whether the given lists of AST nodes match pair wise according to
     * <code>ASTNode.subtreeMatch</code>.
     * <p>
     * Note that this is a convenience method, useful for writing recursive
     * subtree matchers.
     * </p>
     * 
     * @param list1
     *            the first array of AST expressions (element type:
     *            <code>ASTNode</code>)
     * @param list2
     *            the second array of AST expressions (element type:
     *            <code>ASTNode</code>)
     * @return <code>true</code> if the arrays have the same number of elements
     *         and match pair-wise according to
     *         <code>ASTNode.subtreeMatch</code>
     * @see ASTNode#subtreeMatch(ASTMatcher matcher, Object other)
     */
    public final boolean safeSubtreeListMatch(Expression[] list1,
            Expression[] list2) {
        return safeSubtreeListMatch(Arrays.asList(list1), Arrays.asList(list2));
    }

    /**
     * Returns whether the given lists of AST nodes match pair wise according to
     * <code>ASTNode.subtreeMatch</code>.
     * <p>
     * Note that this is a convenience method, useful for writing recursive
     * subtree matchers.
     * </p>
     * 
     * @param list1
     *            the first array of AST statements (element type:
     *            <code>ASTNode</code>)
     * @param list2
     *            the second array of AST statements (element type:
     *            <code>ASTNode</code>)
     * @return <code>true</code> if the arrays have the same number of elements
     *         and match pair-wise according to
     *         <code>ASTNode.subtreeMatch</code>
     * @see ASTNode#subtreeMatch(ASTMatcher matcher, Object other)
     */
    public final boolean safeSubtreeListMatch(Statement[] list1,
            Statement[] list2) {
        return safeSubtreeListMatch(Arrays.asList(list1), Arrays.asList(list2));
    }

    /**
     * Returns whether the given lists of AST nodes match pair wise according to
     * <code>ASTNode.subtreeMatch</code>.
     * <p>
     * Note that this is a convenience method, useful for writing recursive
     * subtree matchers.
     * </p>
     * 
     * @param list1
     *            the first array of AST nodes (element type:
     *            <code>ASTNode</code>)
     * @param list2
     *            the second array of AST nodes (element type:
     *            <code>ASTNode</code>)
     * @return <code>true</code> if the arrays have the same number of elements
     *         and match pair-wise according to
     *         <code>ASTNode.subtreeMatch</code>
     * @see ASTNode#subtreeMatch(ASTMatcher matcher, Object other)
     */
    public final boolean safeSubtreeListMatch(ASTNode[] list1, ASTNode[] list2) {
        return safeSubtreeListMatch(Arrays.asList(list1), Arrays.asList(list2));
    }

    /**
     * Returns whether the given nodes match according to
     * <code>AST.subtreeMatch</code>. Returns <code>false</code> if one or the
     * other of the nodes are <code>null</code>. Returns <code>true</code> if
     * both nodes are <code>null</code>.
     * <p>
     * Note that this is a convenience method, useful for writing recursive
     * subtree matchers.
     * </p>
     * 
     * @param node1
     *            the first AST node, or <code>null</code>; must be an instance
     *            of <code>ASTNode</code>
     * @param node2
     *            the second AST node, or <code>null</code>; must be an instance
     *            of <code>ASTNode</code>
     * @return <code>true</code> if the nodes match according to
     *         <code>AST.subtreeMatch</code> or both are <code>null</code>, and
     *         <code>false</code> otherwise
     * @see ASTNode#subtreeMatch(ASTMatcher, Object)
     */
    public final boolean safeSubtreeMatch(Object node1, Object node2) {
        if (node1 == null && node2 == null) {
            return true;
        }
        if (node1 == null || node2 == null) {
            return false;
        }
        // N.B. call subtreeMatch even node1==node2!=null
        return ((ASTNode) node1).subtreeMatch(this, node2);
    }

    /**
     * Returns whether the given objects are equal according to
     * <code>equals</code>. Returns <code>false</code> if either node is
     * <code>null</code>.
     * 
     * @param o1
     *            the first object, or <code>null</code>
     * @param o2
     *            the second object, or <code>null</code>
     * @return <code>true</code> if the nodes are equal according to
     *         <code>equals</code> or both <code>null</code>, and
     *         <code>false</code> otherwise
     */
    public static boolean safeEquals(Object o1, Object o2) {
        if (o1 == o2) {
            return true;
        }
        if (o1 == null || o2 == null) {
            return false;
        }
        return o1.equals(o2);
    }

    /**
     * Returns whether the given node and the other object match.
     * <p>
     * The default implementation provided by this class tests whether the other
     * object is a node of the same type with structurally isomorphic child
     * subtrees. Subclasses may override this method as needed.
     * </p>
     * 
     * @param node
     *            the node
     * @param other
     *            the other object, or <code>null</code>
     * @return <code>true</code> if the subtree matches, or <code>false</code>
     *         if they do not match or the other object has a different node
     *         type or is <code>null</code>
     * @since 3.1
     */

    public boolean match(ArrayAccess node, Object other) {
        if (!(other instanceof ArrayAccess)) {
            return false;
        }
        final ArrayAccess o = (ArrayAccess) other;

        return (safeSubtreeMatch(node.getName(), o.getName())
                && safeSubtreeMatch(node.getIndex(), o.getIndex()) && safeEquals(
                node.getArrayType(), o.getArrayType()));
    }

    public boolean match(ArrayCreation node, Object other) {
        if (!(other instanceof ArrayCreation)) {
            return false;
        }
        final ArrayCreation o = (ArrayCreation) other;

        return safeSubtreeListMatch(node.elements(), o.elements());
    }

    public boolean match(ArrayElement node, Object other) {
        if (!(other instanceof ArrayElement)) {
            return false;
        }
        final ArrayElement o = (ArrayElement) other;

        return (safeSubtreeMatch(node.getKey(), o.getKey()) && safeSubtreeMatch(
                node.getValue(), o.getValue()));
    }

    public boolean match(Assignment node, Object other) {
        if (!(other instanceof Assignment)) {
            return false;
        }
        final Assignment o = (Assignment) other;

        return (safeEquals(node.getOperator(), o.getOperator())
                && safeSubtreeMatch(node.getRightHandSide(),
                        o.getRightHandSide()) && safeSubtreeMatch(
                node.getLeftHandSide(), o.getLeftHandSide()));
    }

    public boolean match(ASTError node, Object other) {
        // always return false since there is no comparison between 2 errors
        return false;
    }

    public boolean match(BackTickExpression node, Object other) {
        if (!(other instanceof BackTickExpression)) {
            return false;
        }
        final BackTickExpression o = (BackTickExpression) other;

        return safeSubtreeListMatch(node.expressions(), o.expressions());
    }

    public boolean match(Block node, Object other) {
        if (!(other instanceof Block)) {
            return false;
        }
        final Block o = (Block) other;

        return (safeEquals(node.isCurly(), o.isCurly()) && safeSubtreeListMatch(
                node.statements(), o.statements()));
    }

    public boolean match(BreakStatement node, Object other) {
        if (!(other instanceof BreakStatement)) {
            return false;
        }
        final BreakStatement o = (BreakStatement) other;

        return safeSubtreeMatch(node.getExpression(), o.getExpression());
    }

    public boolean match(CastExpression node, Object other) {
        if (!(other instanceof CastExpression)) {
            return false;
        }
        final CastExpression o = (CastExpression) other;

        return (safeEquals(node.getCastingType(), o.getCastingType()) && safeSubtreeMatch(
                node.getExpression(), o.getExpression()));
    }

    public boolean match(CatchClause node, Object other) {
        if (!(other instanceof CatchClause)) {
            return false;
        }
        final CatchClause o = (CatchClause) other;

        return (safeSubtreeMatch(node.getClassName(), o.getClassName())
                && safeSubtreeMatch(node.getVariable(), o.getVariable()) && safeSubtreeMatch(
                node.getBody(), o.getBody()));
    }

    public boolean match(ConstantDeclaration node, Object other) {
        if (!(other instanceof ConstantDeclaration)) {
            return false;
        }
        final ConstantDeclaration o = (ConstantDeclaration) other;

        return (safeSubtreeListMatch(node.initializers(), o.initializers()) && safeSubtreeListMatch(
                node.names(), o.names()));
    }

    public boolean match(ClassDeclaration node, Object other) {
        if (!(other instanceof ClassDeclaration)) {
            return false;
        }
        final ClassDeclaration o = (ClassDeclaration) other;

        return (safeEquals(node.getModifier(), o.getModifier())
                && safeSubtreeMatch(node.getSuperClass(), o.getSuperClass()) && match(
                (TypeDeclaration) node, (TypeDeclaration) o));
    }

    private boolean match(TypeDeclaration node, Object other) {
        if (!(other instanceof TypeDeclaration)) {
            return false;
        }
        final TypeDeclaration o = (TypeDeclaration) other;

        return (safeSubtreeMatch(node.getName(), o.getName())
                && safeSubtreeMatch(node.getBody(), o.getBody()) && safeSubtreeListMatch(
                node.interfaces(), o.interfaces()));
    }

    public boolean match(ClassInstanceCreation node, Object other) {
        if (!(other instanceof ClassInstanceCreation)) {
            return false;
        }
        final ClassInstanceCreation o = (ClassInstanceCreation) other;

        return (safeSubtreeMatch(node.getClassName(), o.getClassName()) && safeSubtreeListMatch(
                node.ctorParams(), o.ctorParams()));
    }

    public boolean match(ClassName node, Object other) {
        if (!(other instanceof ClassName)) {
            return false;
        }
        final ClassName o = (ClassName) other;

        return safeSubtreeMatch(node.getName(), o.getName());
    }

    public boolean match(CloneExpression node, Object other) {
        if (!(other instanceof CloneExpression)) {
            return false;
        }
        final CloneExpression o = (CloneExpression) other;

        return safeSubtreeMatch(node.getExpression(), o.getExpression());
    }

    // TODO - will implement in the future
    public boolean match(Comment node, Object other) {
        return true;
    }

    public boolean match(ConditionalExpression node, Object other) {
        if (!(other instanceof ConditionalExpression)) {
            return false;
        }
        final ConditionalExpression o = (ConditionalExpression) other;

        return (safeSubtreeMatch(node.getCondition(), o.getCondition())
                && safeSubtreeMatch(node.getIfTrue(), o.getIfTrue()) && safeSubtreeMatch(
                node.getIfFalse(), o.getIfFalse()));
    }

    public boolean match(ContinueStatement node, Object other) {
        if (!(other instanceof ContinueStatement)) {
            return false;
        }
        final ContinueStatement o = (ContinueStatement) other;

        return safeSubtreeMatch(node.getExpression(), o.getExpression());
    }

    public boolean match(DeclareStatement node, Object other) {
        if (!(other instanceof DeclareStatement)) {
            return false;
        }
        final DeclareStatement o = (DeclareStatement) other;

        return (safeSubtreeMatch(node.getBody(), o.getBody())
                && safeSubtreeListMatch(node.directiveNames(),
                        o.directiveNames()) && safeSubtreeListMatch(
                node.directiveValues(), o.directiveValues()));
    }

    public boolean match(DoStatement node, Object other) {
        if (!(other instanceof DoStatement)) {
            return false;
        }
        final DoStatement o = (DoStatement) other;

        return (safeSubtreeMatch(node.getCondition(), o.getCondition()) && safeSubtreeMatch(
                node.getBody(), o.getBody()));
    }

    public boolean match(EchoStatement node, Object other) {
        if (!(other instanceof EchoStatement)) {
            return false;
        }
        final EchoStatement o = (EchoStatement) other;

        return safeSubtreeListMatch(node.expressions(), o.expressions());
    }

    public boolean match(EmptyStatement node, Object other) {
        if (!(other instanceof EmptyStatement)) {
            return false;
        }

        // 2 empty statements are equal by definition
        return true;
    }

    public boolean match(ExpressionStatement node, Object other) {
        if (!(other instanceof ExpressionStatement)) {
            return false;
        }
        final ExpressionStatement o = (ExpressionStatement) other;

        return safeSubtreeMatch(node.getExpression(), o.getExpression());

    }

    public boolean match(FieldAccess node, Object other) {
        if (!(other instanceof FieldAccess)) {
            return false;
        }
        final FieldAccess o = (FieldAccess) other;

        return (safeSubtreeMatch(node.getDispatcher(), o.getDispatcher()) && safeSubtreeMatch(
                node.getField(), o.getField()));
    }

    public boolean match(FieldsDeclaration node, Object other) {
        if (!(other instanceof FieldsDeclaration)) {
            return false;
        }
        final FieldsDeclaration o = (FieldsDeclaration) other;

        return (safeEquals(node.getModifier(), o.getModifier())
                && safeSubtreeListMatch(node.getInitialValues(),
                        o.getInitialValues()) && safeSubtreeListMatch(
                node.getVariableNames(), o.getVariableNames()));
    }

    public boolean match(ForEachStatement node, Object other) {
        if (!(other instanceof ForEachStatement)) {
            return false;
        }
        final ForEachStatement o = (ForEachStatement) other;

        return (safeSubtreeMatch(node.getExpression(), o.getExpression())
                && safeSubtreeMatch(node.getKey(), o.getKey())
                && safeSubtreeMatch(node.getValue(), o.getValue()) && safeSubtreeMatch(
                node.getStatement(), o.getStatement()));
    }

    public boolean match(FormalParameter node, Object other) {
        if (!(other instanceof FormalParameter)) {
            return false;
        }
        final FormalParameter o = (FormalParameter) other;

        return (safeEquals(node.isMandatory(), o.isMandatory())
                && safeSubtreeMatch(node.getParameterType(),
                        o.getParameterType())
                && safeSubtreeMatch(node.getParameterName(),
                        o.getParameterName()) && safeSubtreeMatch(
                node.getDefaultValue(), o.getDefaultValue()));
    }

    public boolean match(ForStatement node, Object other) {
        if (!(other instanceof ForStatement)) {
            return false;
        }
        final ForStatement o = (ForStatement) other;

        return (safeSubtreeMatch(node.getBody(), o.getBody())
                && safeSubtreeListMatch(node.initializers(), o.initializers())
                && safeSubtreeListMatch(node.conditions(), o.conditions()) && safeSubtreeListMatch(
                node.updaters(), o.updaters()));
    }

    public boolean match(FunctionDeclaration node, Object other) {
        if (!(other instanceof FunctionDeclaration)) {
            return false;
        }
        final FunctionDeclaration o = (FunctionDeclaration) other;

        return (safeEquals(node.isReference(), o.isReference())
                && safeSubtreeMatch(node.getBody(), o.getBody())
                && safeSubtreeMatch(node.getFunctionName(), o.getFunctionName()) && safeSubtreeListMatch(
                node.formalParameters(), o.formalParameters()));
    }

    public boolean match(FunctionInvocation node, Object other) {
        if (!(other instanceof FunctionInvocation)) {
            return false;
        }
        final FunctionInvocation o = (FunctionInvocation) other;

        return (safeSubtreeMatch(node.getFunctionName(), o.getFunctionName()) && safeSubtreeListMatch(
                node.parameters(), o.parameters()));
    }

    public boolean match(FunctionName node, Object other) {
        if (!(other instanceof FunctionName)) {
            return false;
        }
        final FunctionName o = (FunctionName) other;

        return safeSubtreeMatch(node.getName(), o.getName());
    }

    public boolean match(GlobalStatement node, Object other) {
        if (!(other instanceof GlobalStatement)) {
            return false;
        }
        final GlobalStatement o = (GlobalStatement) other;

        return safeSubtreeListMatch(node.variables(), o.variables());
    }

    public boolean match(Identifier node, Object other) {
        if (!(other instanceof Identifier)) {
            return false;
        }
        final Identifier o = (Identifier) other;

        return safeEquals(node.getName(), o.getName());
    }

    public boolean match(IfStatement node, Object other) {
        if (!(other instanceof IfStatement)) {
            return false;
        }
        final IfStatement o = (IfStatement) other;

        return (safeSubtreeMatch(node.getCondition(), o.getCondition())
                && safeSubtreeMatch(node.getTrueStatement(),
                        o.getTrueStatement()) && safeSubtreeMatch(
                node.getFalseStatement(), o.getFalseStatement()));
    }

    public boolean match(IgnoreError node, Object other) {
        if (!(other instanceof IgnoreError)) {
            return false;
        }
        final IgnoreError o = (IgnoreError) other;

        return safeSubtreeMatch(node.getExpression(), o.getExpression());
    }

    public boolean match(Include node, Object other) {
        if (!(other instanceof Include)) {
            return false;
        }
        final Include o = (Include) other;

        return (safeEquals(node.getIncludeType(), o.getIncludeType()) && safeSubtreeMatch(
                node.getExpression(), o.getExpression()));
    }

    public boolean match(InfixExpression node, Object other) {
        if (!(other instanceof InfixExpression)) {
            return false;
        }
        final InfixExpression o = (InfixExpression) other;

        return (safeEquals(node.getOperator(), o.getOperator())
                && safeSubtreeMatch(node.getRight(), o.getRight()) && safeSubtreeMatch(
                node.getLeft(), o.getLeft()));
    }

    // TODO - need to check the contents of the html
    public boolean match(InLineHtml node, Object other) {
        if (!(other instanceof InLineHtml)) {
            return false;
        }
        final InLineHtml o = (InLineHtml) other;

        return false;
    }

    public boolean match(InstanceOfExpression node, Object other) {
        if (!(other instanceof InstanceOfExpression)) {
            return false;
        }
        final InstanceOfExpression o = (InstanceOfExpression) other;

        return (safeSubtreeMatch(node.getClassName(), o.getClassName()) && safeSubtreeMatch(
                node.getExpression(), o.getExpression()));
    }

    public boolean match(InterfaceDeclaration node, Object other) {
        if (!(other instanceof InterfaceDeclaration)) {
            return false;
        }
        final InterfaceDeclaration o = (InterfaceDeclaration) other;

        return match((TypeDeclaration) node, (TypeDeclaration) o);
    }

    public boolean match(ListVariable node, Object other) {
        if (!(other instanceof ListVariable)) {
            return false;
        }
        final ListVariable o = (ListVariable) other;

        return safeSubtreeListMatch(node.variables(), o.variables());
    }

    public boolean match(MethodDeclaration node, Object other) {
        if (!(other instanceof MethodDeclaration)) {
            return false;
        }
        final MethodDeclaration o = (MethodDeclaration) other;
        return (safeEquals(node.getModifier(), o.getModifier()) && safeSubtreeMatch(
                node.getFunction(), o.getFunction()));
    }

    public boolean match(MethodInvocation node, Object other) {
        if (!(other instanceof MethodInvocation)) {
            return false;
        }
        final MethodInvocation o = (MethodInvocation) other;

        return (safeSubtreeMatch(node.getDispatcher(), o.getDispatcher()) && safeSubtreeMatch(
                node.getMethod(), o.getMethod()));
    }

    public boolean match(ParenthesisExpression node, Object other) {
        if (!(other instanceof ParenthesisExpression)) {
            return false;
        }
        final ParenthesisExpression o = (ParenthesisExpression) other;

        return safeSubtreeMatch(node.getExpression(), o.getExpression());
    }

    public boolean match(PostfixExpression node, Object other) {
        if (!(other instanceof PostfixExpression)) {
            return false;
        }
        final PostfixExpression o = (PostfixExpression) other;

        return (safeEquals(node.getOperator(), o.getOperator()) && safeSubtreeMatch(
                node.getVariable(), o.getVariable()));
    }

    public boolean match(PrefixExpression node, Object other) {
        if (!(other instanceof PrefixExpression)) {
            return false;
        }
        final PrefixExpression o = (PrefixExpression) other;

        return (safeEquals(node.getOperator(), o.getOperator()) && safeSubtreeMatch(
                node.getVariable(), o.getVariable()));
    }

    public boolean match(Program node, Object other) {
        if (!(other instanceof Program)) {
            return false;
        }
        final Program o = (Program) other;

        return (safeSubtreeListMatch(node.statements(), o.statements()) && safeSubtreeListMatch(
                ((Map) node.comments()).values(), ((Map) o.comments()).values()));
    }

    public boolean match(Quote node, Object other) {
        if (!(other instanceof Quote)) {
            return false;
        }
        final Quote o = (Quote) other;

        return (safeEquals(node.getQuoteType(), o.getQuoteType()) && safeSubtreeListMatch(
                node.expressions(), o.expressions()));
    }

    public boolean match(Reference node, Object other) {
        if (!(other instanceof Reference)) {
            return false;
        }
        final Reference o = (Reference) other;

        return safeSubtreeMatch(node.getExpression(), o.getExpression());
    }

    public boolean match(ReflectionVariable node, Object other) {
        if (!(other instanceof ReflectionVariable)) {
            return false;
        }
        final ReflectionVariable o = (ReflectionVariable) other;

        return (match((Variable) node, (Variable) o));
    }

    public boolean match(ReturnStatement node, Object other) {
        if (!(other instanceof ReturnStatement)) {
            return false;
        }
        final ReturnStatement o = (ReturnStatement) other;

        return safeSubtreeMatch(node.getExpression(), o.getExpression());
    }

    public boolean match(Scalar node, Object other) {
        if (!(other instanceof Scalar)) {
            return false;
        }
        final Scalar o = (Scalar) other;

        return (safeEquals(node.getStringValue(), o.getStringValue()) && safeEquals(
                node.getScalarType(), o.getScalarType()));
    }

    public boolean match(SingleFieldDeclaration node, Object other) {
        if (!(other instanceof SingleFieldDeclaration)) {
            return false;
        }
        final SingleFieldDeclaration o = (SingleFieldDeclaration) other;

        return (safeSubtreeMatch(node.getName(), o.getName()) && safeSubtreeMatch(
                node.getValue(), o.getValue()));
    }

    public boolean match(StaticConstantAccess node, Object other) {
        if (!(other instanceof StaticConstantAccess)) {
            return false;
        }
        final StaticConstantAccess o = (StaticConstantAccess) other;

        return (safeSubtreeMatch(node.getClassName(), o.getClassName()) && safeSubtreeMatch(
                node.getConstant(), o.getConstant()));
    }

    public boolean match(StaticFieldAccess node, Object other) {

        if (!(other instanceof StaticFieldAccess)) {
            return false;
        }
        final StaticFieldAccess o = (StaticFieldAccess) other;

        return (safeSubtreeMatch(node.getClassName(), o.getClassName()) && safeSubtreeMatch(
                node.getField(), o.getField()));

    }

    public boolean match(StaticMethodInvocation node, Object other) {
        if (!(other instanceof StaticMethodInvocation)) {
            return false;
        }
        final StaticMethodInvocation o = (StaticMethodInvocation) other;

        return (safeSubtreeMatch(node.getClassName(), o.getClassName()) && safeSubtreeMatch(
                node.getMethod(), o.getMethod()));
    }

    @SuppressWarnings("deprecation")
    public boolean match(StaticStatement node, Object other) {
        if (!(other instanceof StaticStatement)) {
            return false;
        }
        final StaticStatement o = (StaticStatement) other;

        return safeSubtreeListMatch(node.getExpressions(), o.getExpressions());
    }

    @SuppressWarnings("deprecation")
    public boolean match(SwitchCase node, Object other) {
        if (!(other instanceof SwitchCase)) {
            return false;
        }
        final SwitchCase o = (SwitchCase) other;

        return (safeEquals(node.isDefault(), o.isDefault())
                && safeSubtreeMatch(node.getValue(), o.getValue()) && safeSubtreeListMatch(
                node.getActions(), o.getActions()));
    }

    @SuppressWarnings("deprecation")
    public boolean match(SwitchStatement node, Object other) {
        if (!(other instanceof SwitchStatement)) {
            return false;
        }
        final SwitchStatement o = (SwitchStatement) other;

        return (safeSubtreeMatch(node.getExpr(), o.getExpr()) && safeSubtreeMatch(
                node.getStatement(), o.getStatement()));
    }

    public boolean match(ThrowStatement node, Object other) {
        if (!(other instanceof ThrowStatement)) {
            return false;
        }
        final ThrowStatement o = (ThrowStatement) other;

        return false;
    }

    @SuppressWarnings("deprecation")
    public boolean match(TryStatement node, Object other) {
        if (!(other instanceof TryStatement)) {
            return false;
        }
        final TryStatement o = (TryStatement) other;

        return (safeSubtreeMatch(node.getTryStatement(), o.getTryStatement()) && safeSubtreeListMatch(
                node.getCatchClauses(), o.getCatchClauses()));
    }

    @SuppressWarnings("deprecation")
    public boolean match(UnaryOperation node, Object other) {
        if (!(other instanceof UnaryOperation)) {
            return false;
        }
        final UnaryOperation o = (UnaryOperation) other;

        return (safeEquals(node.getOperator(), o.getOperator()) && safeSubtreeMatch(
                node.getExpr(), o.getExpr()));
    }

    @SuppressWarnings("deprecation")
    public boolean match(Variable node, Object other) {
        if (!(other instanceof Variable)) {
            return false;
        }
        final Variable o = (Variable) other;

        return (safeSubtreeMatch(node.getVariableName(), o.getVariableName()) && safeEquals(
                node.isDollared(), o.isDollared()));
    }

    @SuppressWarnings("deprecation")
    public boolean match(WhileStatement node, Object other) {
        if (!(other instanceof WhileStatement)) {
            return false;
        }
        final WhileStatement o = (WhileStatement) other;

        return (safeSubtreeMatch(node.getCondition(), o.getCondition()) && safeSubtreeMatch(
                node.getAction(), o.getAction()));
    }

    public boolean match(NamespaceDeclaration node, Object other) {
        if (!(other instanceof NamespaceDeclaration)) {
            return false;
        }
        final NamespaceDeclaration o = (NamespaceDeclaration) other;
        return safeSubtreeMatch(node.getName(), o.getName())
                && safeSubtreeMatch(node.getBody(), o.getBody());
    }

    public boolean match(NamespaceName node, Object other) {
        if (!(other instanceof NamespaceName)) {
            return false;
        }
        final NamespaceName o = (NamespaceName) other;
        return safeEquals(node.isGlobal(), o.isGlobal())
                && safeEquals(node.isCurrent(), o.isCurrent())
                && safeSubtreeListMatch(node.segments(), o.segments());
    }

    public boolean match(UseStatementPart node, Object other) {
        if (!(other instanceof UseStatementPart)) {
            return false;
        }
        final UseStatementPart o = (UseStatementPart) other;
        return safeSubtreeMatch(node.getName(), o.getName())
                && safeSubtreeMatch(node.getAlias(), o.getAlias());
    }

    public boolean match(UseStatement node, Object other) {
        if (!(other instanceof UseStatement)) {
            return false;
        }
        final UseStatement o = (UseStatement) other;
        return safeSubtreeListMatch(node.parts(), o.parts());
    }

    public boolean match(GotoLabel node, Object other) {
        if (!(other instanceof GotoLabel)) {
            return false;
        }
        final GotoLabel o = (GotoLabel) other;
        return safeSubtreeMatch(node.getName(), o.getName());
    }

    public boolean match(GotoStatement node, Object other) {
        if (!(other instanceof GotoStatement)) {
            return false;
        }
        final GotoStatement o = (GotoStatement) other;
        return safeSubtreeMatch(node.getLabel(), o.getLabel());
    }

    public boolean match(LambdaFunctionDeclaration node, Object other) {
        if (!(other instanceof LambdaFunctionDeclaration)) {
            return false;
        }
        final LambdaFunctionDeclaration o = (LambdaFunctionDeclaration) other;

        return (safeEquals(node.isReference(), o.isReference())
                && safeSubtreeMatch(node.getBody(), o.getBody())
                && safeSubtreeListMatch(node.formalParameters(),
                        o.formalParameters()) && safeSubtreeListMatch(
                node.lexicalVariables(), o.lexicalVariables()));
    }
}
