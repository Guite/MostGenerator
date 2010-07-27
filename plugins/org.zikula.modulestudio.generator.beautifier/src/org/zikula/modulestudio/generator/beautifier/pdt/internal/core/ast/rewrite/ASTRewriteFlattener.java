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

import java.util.Collection;
import java.util.Collections;
import java.util.Iterator;
import java.util.List;

import org.zikula.modulestudio.generator.beautifier.pdt.core.compiler.PHPFlags;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.PHPVersion;
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
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.ast.nodes.StructuralPropertyDescriptor;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.ast.nodes.SwitchCase;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.ast.nodes.SwitchStatement;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.ast.nodes.ThrowStatement;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.ast.nodes.TryStatement;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.ast.nodes.UnaryOperation;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.ast.nodes.UseStatement;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.ast.nodes.UseStatementPart;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.ast.nodes.Variable;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.ast.nodes.VariableBase;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.ast.nodes.WhileStatement;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.ast.visitor.AbstractVisitor;

public class ASTRewriteFlattener extends AbstractVisitor {

    public static String asString(ASTNode node, RewriteEventStore store) {
        final ASTRewriteFlattener flattener = new ASTRewriteFlattener(store);
        node.accept(flattener);
        return flattener.getResult();
    }

    protected StringBuffer result;
    private final RewriteEventStore store;

    public ASTRewriteFlattener(RewriteEventStore store) {
        this.store = store;
        this.result = new StringBuffer();
    }

    /**
     * Returns the string accumulated in the visit.
     * 
     * @return the serialized
     */
    public String getResult() {
        // convert to a string, but lose any extra space in the string buffer by
        // copying
        return new String(this.result.toString());
    }

    /**
     * Resets this printer so that it can be used again.
     */
    public void reset() {
        this.result.setLength(0);
    }

    /**
     * Appends the text representation of the given modifier flags, followed by
     * a single space.
     * 
     * @param modifiers
     *            the modifiers
     * @param buf
     *            The <code>StringBuffer</code> to write the result to.
     */
    public static void printModifiers(int modifiers, StringBuffer buf) {
        if (PHPFlags.isPublic(modifiers)) {
            buf.append("public "); //$NON-NLS-1$
        }
        if (PHPFlags.isProtected(modifiers)) {
            buf.append("protected "); //$NON-NLS-1$
        }
        if (PHPFlags.isPrivate(modifiers)) {
            buf.append("private "); //$NON-NLS-1$
        }
        if (PHPFlags.isStatic(modifiers)) {
            buf.append("static "); //$NON-NLS-1$
        }
        if (PHPFlags.isAbstract(modifiers)) {
            buf.append("abstract "); //$NON-NLS-1$
        }
        if (PHPFlags.isFinal(modifiers)) {
            buf.append("final "); //$NON-NLS-1$
        }
    }

    protected List getChildList(ASTNode parent,
            StructuralPropertyDescriptor childProperty) {
        final Object ret = getAttribute(parent, childProperty);
        if (ret instanceof List) {
            return (List) ret;
        }
        return Collections.EMPTY_LIST;
    }

    protected ASTNode getChildNode(ASTNode parent,
            StructuralPropertyDescriptor childProperty) {
        return (ASTNode) getAttribute(parent, childProperty);
    }

    protected int getIntAttribute(ASTNode parent,
            StructuralPropertyDescriptor childProperty) {
        return ((Integer) getAttribute(parent, childProperty)).intValue();
    }

    protected boolean getBooleanAttribute(ASTNode parent,
            StructuralPropertyDescriptor childProperty) {
        return ((Boolean) getAttribute(parent, childProperty)).booleanValue();
    }

    protected Object getAttribute(ASTNode parent,
            StructuralPropertyDescriptor childProperty) {
        if (store != null) {
            return this.store.getNewValue(parent, childProperty);
        }

        return null;
    }

    protected void visitList(ASTNode parent,
            StructuralPropertyDescriptor childProperty, String separator) {
        final List list = getChildList(parent, childProperty);
        for (int i = 0; i < list.size(); i++) {
            if (separator != null && i > 0) {
                this.result.append(separator);
            }
            ((ASTNode) list.get(i)).accept(this);
        }
    }

    protected void visitList(ASTNode parent,
            StructuralPropertyDescriptor childProperty, String separator,
            String lead, String post) {
        final List list = getChildList(parent, childProperty);
        if (!list.isEmpty()) {
            this.result.append(lead);
            for (int i = 0; i < list.size(); i++) {
                if (separator != null && i > 0) {
                    this.result.append(separator);
                }
                ((ASTNode) list.get(i)).accept(this);
            }
            this.result.append(post);
        }
    }

    /*
     * (non-Javadoc)
     * @see
     * org.eclipse.php.internal.core.ast.visitor.AbstractVisitor#visit(org.eclipse
     * .php.internal.core.ast.nodes.ArrayAccess)
     */
    @Override
    public boolean visit(ArrayAccess arrayAccess) {
        if (arrayAccess.getName() != null) {
            arrayAccess.getName().accept(this);
        }
        final boolean isVariableHashtable = arrayAccess.getArrayType() == ArrayAccess.VARIABLE_HASHTABLE;
        if (isVariableHashtable) {
            result.append('{');
        }
        else {
            result.append('[');
        }
        if (arrayAccess.getIndex() != null) {
            arrayAccess.getIndex().accept(this);
        }
        if (isVariableHashtable) {
            result.append('}');
        }
        else {
            result.append(']');
        }
        return false;
    }

    @Override
    public boolean visit(ArrayCreation arrayCreation) {
        result.append("array("); //$NON-NLS-1$
        @SuppressWarnings("deprecation")
        final ArrayElement[] elements = arrayCreation.getElements();
        for (final ArrayElement element : elements) {
            element.accept(this);
            result.append(","); //$NON-NLS-1$
        }
        result.append(")"); //$NON-NLS-1$
        return false;
    }

    @Override
    public boolean visit(ArrayElement arrayElement) {
        if (arrayElement.getKey() != null) {
            arrayElement.getKey().accept(this);
            result.append("=>"); //$NON-NLS-1$
        }
        arrayElement.getValue().accept(this);
        return false;
    }

    @Override
    public boolean visit(Assignment assignment) {
        assignment.getLeftHandSide().accept(this);
        result.append(Assignment.getOperator(assignment.getOperator()));
        assignment.getRightHandSide().accept(this);
        return false;
    }

    @Override
    public boolean visit(ASTError astError) {
        // cant flatten, needs source
        return false;
    }

    @Override
    public boolean visit(BackTickExpression backTickExpression) {
        result.append("`"); //$NON-NLS-1$
        @SuppressWarnings("deprecation")
        final Expression[] expressions = backTickExpression.getExpressions();
        for (final Expression expression : expressions) {
            expression.accept(this);
        }
        result.append("`"); //$NON-NLS-1$
        return false;
    }

    @Override
    public boolean visit(Block block) {
        if (block.isCurly()) {
            result.append("{\n"); //$NON-NLS-1$
        }
        else {
            result.append(":\n"); //$NON-NLS-1$
        }

        visitList(block, Block.STATEMENTS_PROPERTY, null);

        if (block.isCurly()) {
            result.append("}\n"); //$NON-NLS-1$
        }
        else {
            final StructuralPropertyDescriptor locationInParent = block
                    .getLocationInParent();
            if (locationInParent == IfStatement.TRUE_STATEMENT_PROPERTY) {
                if (((IfStatement) block.getParent()).getFalseStatement() == null) {
                    // End the if statement
                    result.append("endif;\n"); //$NON-NLS-1$
                }
                else {
                    // Just add a new line char
                    result.append("\n"); //$NON-NLS-1$
                }
            }
            else if (locationInParent == IfStatement.FALSE_STATEMENT_PROPERTY) {
                result.append("endif;\n"); //$NON-NLS-1$
            }
            else if (locationInParent == WhileStatement.BODY_PROPERTY) {
                result.append("endwhile;\n"); //$NON-NLS-1$
            }
            else if (locationInParent == ForStatement.BODY_PROPERTY) {
                result.append("endfor;\n"); //$NON-NLS-1$
            }
            else if (locationInParent == ForEachStatement.STATEMENT_PROPERTY) {
                result.append("endforeach;\n"); //$NON-NLS-1$
            }
            else if (locationInParent == SwitchStatement.BODY_PROPERTY) {
                result.append("endswitch;\n"); //$NON-NLS-1$
            }
        }
        return false;
    }

    @SuppressWarnings("deprecation")
    @Override
    public boolean visit(BreakStatement breakStatement) {
        result.append("break"); //$NON-NLS-1$
        if (breakStatement.getExpr() != null) {
            result.append(' ');
            breakStatement.getExpr().accept(this);
        }
        result.append(";\n"); //$NON-NLS-1$
        return false;
    }

    @SuppressWarnings("deprecation")
    @Override
    public boolean visit(CastExpression castExpression) {
        result.append("("); //$NON-NLS-1$
        result.append(CastExpression.getCastType(castExpression.getCastType()));
        result.append(")"); //$NON-NLS-1$
        castExpression.getExpr().accept(this);
        return false;
    }

    @SuppressWarnings("deprecation")
    @Override
    public boolean visit(CatchClause catchClause) {
        result.append("catch ("); //$NON-NLS-1$
        catchClause.getClassName().accept(this);
        result.append(" "); //$NON-NLS-1$
        catchClause.getVariable().accept(this);
        result.append(") "); //$NON-NLS-1$
        catchClause.getStatement().accept(this);
        return false;
    }

    @SuppressWarnings("deprecation")
    @Override
    public boolean visit(ConstantDeclaration classConstantDeclaration) {
        result.append("const "); //$NON-NLS-1$
        boolean isFirst = true;
        final Identifier[] variableNames = classConstantDeclaration
                .getVariableNames();
        final Expression[] constantValues = classConstantDeclaration
                .getConstantValues();
        for (int i = 0; i < variableNames.length; i++) {
            if (!isFirst) {
                result.append(", "); //$NON-NLS-1$
            }
            variableNames[i].accept(this);
            result.append(" = "); //$NON-NLS-1$
            constantValues[i].accept(this);
            isFirst = false;
        }
        result.append(";\n"); //$NON-NLS-1$
        return false;
    }

    @Override
    public boolean visit(ClassDeclaration classDeclaration) {
        final int modifier = classDeclaration.getModifier();
        if (modifier != ClassDeclaration.MODIFIER_NONE) {
            result.append(ClassDeclaration.getModifier(modifier));
            result.append(' ');
        }
        result.append("class "); //$NON-NLS-1$
        classDeclaration.getName().accept(this);
        if (classDeclaration.getSuperClass() != null) {
            result.append(" extends "); //$NON-NLS-1$
            classDeclaration.getSuperClass().accept(this);
        }
        @SuppressWarnings("deprecation")
        final Identifier[] interfaces = classDeclaration.getInterfaces();
        if (interfaces != null && interfaces.length != 0) {
            result.append(" implements "); //$NON-NLS-1$
            interfaces[0].accept(this);
            for (int i = 1; i < interfaces.length; i++) {
                result.append(" , "); //$NON-NLS-1$
                interfaces[i].accept(this);
            }
        }
        classDeclaration.getBody().accept(this);
        return false;
    }

    @Override
    public boolean visit(ClassInstanceCreation classInstanceCreation) {
        result.append("new "); //$NON-NLS-1$
        classInstanceCreation.getClassName().accept(this);
        @SuppressWarnings("deprecation")
        final Expression[] ctorParams = classInstanceCreation.getCtorParams();
        if (ctorParams.length != 0) {
            result.append("("); //$NON-NLS-1$
            ctorParams[0].accept(this);
            for (int i = 1; i < ctorParams.length; i++) {
                result.append(","); //$NON-NLS-1$
                ctorParams[i].accept(this);
            }
            result.append(")"); //$NON-NLS-1$
        }
        return false;
    }

    @SuppressWarnings("deprecation")
    @Override
    public boolean visit(ClassName className) {
        className.getClassName().accept(this);
        return false;
    }

    @SuppressWarnings("deprecation")
    @Override
    public boolean visit(CloneExpression cloneExpression) {
        result.append("clone "); //$NON-NLS-1$
        cloneExpression.getExpr().accept(this);
        return false;
    }

    @Override
    public boolean visit(Comment comment) {
        result.append(getComment(comment));
        result.append("\n");
        return false;
    }

    public String getComment(Comment comment) {
        if (comment.getCommentType() == Comment.TYPE_SINGLE_LINE) {
            return "//";
        }
        if (comment.getCommentType() == Comment.TYPE_MULTILINE) {
            return "/* */";
        }
        if (comment.getCommentType() == Comment.TYPE_PHPDOC) {
            return "/** */"; //$NON-NLS-1$"
        }
        return null;
    }

    @Override
    public boolean visit(ConditionalExpression conditionalExpression) {
        conditionalExpression.getCondition().accept(this);
        result.append(" ? "); //$NON-NLS-1$
        conditionalExpression.getIfTrue().accept(this);
        result.append(" : "); //$NON-NLS-1$
        conditionalExpression.getIfFalse().accept(this);
        return false;
    }

    @SuppressWarnings("deprecation")
    @Override
    public boolean visit(ContinueStatement continueStatement) {
        result.append("continue "); //$NON-NLS-1$
        if (continueStatement.getExpr() != null) {
            continueStatement.getExpr().accept(this);
        }
        result.append(";\n"); //$NON-NLS-1$
        return false;
    }

    @SuppressWarnings("deprecation")
    @Override
    public boolean visit(DeclareStatement declareStatement) {
        result.append("declare ("); //$NON-NLS-1$
        boolean isFirst = true;
        final Identifier[] directiveNames = declareStatement
                .getDirectiveNames();
        final Expression[] directiveValues = declareStatement
                .getDirectiveValues();
        for (int i = 0; i < directiveNames.length; i++) {
            if (!isFirst) {
                result.append(", "); //$NON-NLS-1$
            }
            directiveNames[i].accept(this);
            result.append(" = "); //$NON-NLS-1$
            directiveValues[i].accept(this);
            isFirst = false;
        }
        result.append(")"); //$NON-NLS-1$
        declareStatement.getAction().accept(this);
        return false;
    }

    @Override
    public boolean visit(DoStatement doStatement) {
        result.append("do "); //$NON-NLS-1$
        final Statement body = doStatement.getBody();

        if (body != null) {
            body.accept(this);
        }
        result.append("while ("); //$NON-NLS-1$
        final Expression cond = doStatement.getCondition();
        if (cond != null) {
            cond.accept(this);
        }
        result.append(");\n"); //$NON-NLS-1$
        return false;
    }

    @Override
    public boolean visit(EchoStatement echoStatement) {
        result.append("echo "); //$NON-NLS-1$
        final List<Expression> expressions = echoStatement.expressions();
        for (int i = 0; i < expressions.size(); i++) {
            expressions.get(i).accept(this);
            if (i + 1 < expressions.size()) {
                result.append(", ");
            }
        }
        result.append(";\n"); //$NON-NLS-1$
        return false;
    }

    @Override
    public boolean visit(EmptyStatement emptyStatement) {
        result.append(";\n"); //$NON-NLS-1$
        return false;
    }

    @Override
    public boolean visit(ExpressionStatement expressionStatement) {
        if (expressionStatement.getExpression() != null) {
            expressionStatement.getExpression().accept(this);
            result.append(";\n"); //$NON-NLS-1$
        }
        else {
            result.append("Missing();");
        }
        return false;
    }

    @Override
    public boolean visit(FieldAccess fieldAccess) {
        fieldAccess.getDispatcher().accept(this);
        result.append("->"); //$NON-NLS-1$
        fieldAccess.getField().accept(this);
        return false;
    }

    @Override
    public boolean visit(FieldsDeclaration fieldsDeclaration) {
        final Variable[] variableNames = fieldsDeclaration.getVariableNames();
        final Expression[] initialValues = fieldsDeclaration.getInitialValues();
        for (int i = 0; i < variableNames.length; i++) {
            result.append(fieldsDeclaration.getModifierString() + " "); //$NON-NLS-1$
            variableNames[i].accept(this);
            if (initialValues[i] != null) {
                result.append(" = "); //$NON-NLS-1$
                initialValues[i].accept(this);
            }
            result.append(";\n"); //$NON-NLS-1$
        }
        return false;
    }

    @Override
    public boolean visit(ForEachStatement forEachStatement) {
        result.append("foreach ("); //$NON-NLS-1$
        final Expression express = forEachStatement.getExpression();
        if (express != null) {
            express.accept(this);
        }
        result.append(" as "); //$NON-NLS-1$
        if (forEachStatement.getKey() != null) {
            forEachStatement.getKey().accept(this);
            result.append(" => "); //$NON-NLS-1$
        }
        final Expression value = forEachStatement.getValue();
        if (value != null) {
            value.accept(this);
        }
        result.append(")"); //$NON-NLS-1$
        forEachStatement.getStatement().accept(this);
        return false;
    }

    @Override
    public boolean visit(NamespaceDeclaration namespaceDeclaration) {
        result.append("namespace ");
        namespaceDeclaration.childrenAccept(this);
        if (namespaceDeclaration.getBody() == null) {
            result.append(";\n"); //$NON-NLS-1$
        }
        return false;
    }

    @Override
    public boolean visit(NamespaceName namespaceName) {
        if (namespaceName.isGlobal()) {
            result.append("\\");
        }
        if (namespaceName.isCurrent()) {
            result.append("namespace\\");
        }
        final List<Identifier> segments = namespaceName.segments();
        final Iterator<Identifier> it = segments.iterator();
        while (it.hasNext()) {
            it.next().accept(this);
            if (it.hasNext()) {
                result.append("\\");
            }
        }
        return false;
    }

    @Override
    public boolean visit(UseStatement useStatement) {
        result.append("use ");
        final Iterator<UseStatementPart> it = useStatement.parts().iterator();
        while (it.hasNext()) {
            it.next().accept(this);
            if (it.hasNext()) {
                result.append(", ");
            }
        }
        result.append(";\n");
        return false;
    }

    @Override
    public boolean visit(UseStatementPart useStatementPart) {
        useStatementPart.getName().accept(this);
        final Identifier alias = useStatementPart.getAlias();
        if (alias != null) {
            result.append(" as ");
            alias.accept(this);
        }
        return false;
    }

    @Override
    public boolean visit(FormalParameter formalParameter) {
        if (formalParameter.isMandatory()) {
            if (formalParameter.getAST().apiLevel() == PHPVersion.PHP4) {
                result.append("const "); // only for PHP 4
            }
        }
        final Expression paramType = formalParameter.getParameterType();
        if (paramType != null /* && paramType.getLength() > 0 */) {
            paramType.accept(this);
            result.append(' ');
        }

        formalParameter.getParameterName().accept(this);
        final Expression defaultValue = formalParameter.getDefaultValue();
        if (defaultValue != null /* && defaultValue.getLength() > 0 */) {
            result.append(" = ");
            defaultValue.accept(this);
        }
        return false;
    }

    @SuppressWarnings("deprecation")
    @Override
    public boolean visit(ForStatement forStatement) {
        boolean isFirst = true;
        result.append("for ("); //$NON-NLS-1$
        final Expression[] initializations = forStatement.getInitializations();
        final Expression[] conditions = forStatement.getConditions();
        final Expression[] increasements = forStatement.getIncreasements();
        for (final Expression initialization : initializations) {
            if (!isFirst) {
                result.append(", "); //$NON-NLS-1$
            }
            initialization.accept(this);
            isFirst = false;
        }
        isFirst = true;
        result.append(" ; "); //$NON-NLS-1$
        for (final Expression condition : conditions) {
            if (!isFirst) {
                result.append(", "); //$NON-NLS-1$
            }
            condition.accept(this);
            isFirst = false;
        }
        isFirst = true;
        result.append(" ; "); //$NON-NLS-1$
        for (final Expression increasement : increasements) {
            if (!isFirst) {
                result.append(", "); //$NON-NLS-1$
            }
            increasement.accept(this);
            isFirst = false;
        }
        result.append(" ) "); //$NON-NLS-1$
        final Statement body = forStatement.getBody();
        if (body != null) {
            body.accept(this);
        }
        return false;
    }

    @Override
    public boolean visit(FunctionDeclaration functionDeclaration) {
        result.append(" function ");
        if (functionDeclaration.isReference()) {
            result.append('&');
        }
        functionDeclaration.getFunctionName().accept(this);
        result.append('(');
        final List<FormalParameter> formalParametersList = functionDeclaration
                .formalParameters();
        final FormalParameter[] formalParameters = formalParametersList
                .toArray(new FormalParameter[formalParametersList.size()]);
        if (formalParameters.length != 0) {
            formalParameters[0].accept(this);
            for (int i = 1; i < formalParameters.length; i++) {
                result.append(", "); //$NON-NLS-1$
                formalParameters[i].accept(this);
            }

        }
        result.append(')');
        final Block body = functionDeclaration.getBody();
        if (body != null) {
            body.accept(this);
        }
        return false;
    }

    @Override
    public boolean visit(FunctionInvocation functionInvocation) {
        functionInvocation.getFunctionName().accept(this);
        result.append('(');
        @SuppressWarnings("deprecation")
        final Expression[] parameters = functionInvocation.getParameters();
        if (parameters.length != 0) {
            parameters[0].accept(this);
            for (int i = 1; i < parameters.length; i++) {
                result.append(',');
                parameters[i].accept(this);
            }
        }
        result.append(')');
        return false;
    }

    @SuppressWarnings("deprecation")
    @Override
    public boolean visit(FunctionName functionName) {
        functionName.getFunctionName().accept(this);
        return false;
    }

    @Override
    public boolean visit(GlobalStatement globalStatement) {
        result.append("global "); //$NON-NLS-1$
        boolean isFirst = true;
        @SuppressWarnings("deprecation")
        final Variable[] variables = globalStatement.getVariables();
        for (final Variable variable : variables) {
            if (!isFirst) {
                result.append(", "); //$NON-NLS-1$
            }
            variable.accept(this);
            isFirst = false;
        }
        result.append(";\n "); //$NON-NLS-1$
        return false;
    }

    @Override
    public boolean visit(GotoLabel gotoLabel) {
        gotoLabel.getName().accept(this);
        result.append(":\n "); //$NON-NLS-1$
        return false;
    }

    @Override
    public boolean visit(GotoStatement gotoStatement) {
        result.append("goto "); //$NON-NLS-1$
        gotoStatement.getLabel().accept(this);
        result.append(";\n "); //$NON-NLS-1$
        return false;
    }

    @Override
    public boolean visit(Identifier identifier) {
        result.append(identifier.getName());
        return false;
    }

    @Override
    public boolean visit(IfStatement ifStatement) {
        result.append("if("); //$NON-NLS-1$
        final Expression cond = ifStatement.getCondition();
        if (cond != null) {
            cond.accept(this);
        }
        result.append(")"); //$NON-NLS-1$
        final Statement trueStatement = ifStatement.getTrueStatement();
        if (trueStatement != null) {
            trueStatement.accept(this);
        }
        if (ifStatement.getFalseStatement() != null) {
            result.append("else"); //$NON-NLS-1$
            ifStatement.getFalseStatement().accept(this);
        }
        return false;
    }

    @SuppressWarnings("deprecation")
    @Override
    public boolean visit(IgnoreError ignoreError) {
        result.append("@"); //$NON-NLS-1$
        ignoreError.getExpr().accept(this);
        return false;
    }

    @SuppressWarnings("deprecation")
    @Override
    public boolean visit(Include include) {
        result.append(Include.getType(include.getIncludeType()));
        result.append(" ("); //$NON-NLS-1$
        include.getExpr().accept(this);
        result.append(")"); //$NON-NLS-1$
        return false;
    }

    @Override
    public boolean visit(InfixExpression infixExpression) {
        infixExpression.getLeft().accept(this);
        result.append(' ');
        result.append(InfixExpression.getOperator(infixExpression.getOperator()));
        result.append(' ');
        infixExpression.getRight().accept(this);
        return false;
    }

    @Override
    public boolean visit(InLineHtml inLineHtml) {
        // cant flatten, needs source
        return false;
    }

    @SuppressWarnings("deprecation")
    @Override
    public boolean visit(InstanceOfExpression instanceOfExpression) {
        instanceOfExpression.getExpr().accept(this);
        result.append(" instanceof "); //$NON-NLS-1$
        instanceOfExpression.getClassName().accept(this);
        return false;
    }

    @Override
    public boolean visit(InterfaceDeclaration interfaceDeclaration) {
        result.append("interface "); //$NON-NLS-1$
        interfaceDeclaration.getName().accept(this);
        result.append(" extends "); //$NON-NLS-1$
        boolean isFirst = true;
        @SuppressWarnings("deprecation")
        final Identifier[] interfaces = interfaceDeclaration.getInterfaces();
        for (int i = 0; interfaces != null && i < interfaces.length; i++) {
            if (!isFirst) {
                result.append(", "); //$NON-NLS-1$
            }
            interfaces[i].accept(this);
            isFirst = false;
        }
        interfaceDeclaration.getBody().accept(this);
        return false;
    }

    @Override
    public boolean visit(ListVariable listVariable) {
        result.append("list("); //$NON-NLS-1$
        boolean isFirst = true;
        @SuppressWarnings("deprecation")
        final VariableBase[] variables = listVariable.getVariables();
        for (final VariableBase variable : variables) {
            if (!isFirst) {
                result.append(", "); //$NON-NLS-1$
            }
            variable.accept(this);
            isFirst = false;
        }
        result.append(")"); //$NON-NLS-1$
        return false;
    }

    @Override
    public boolean visit(LambdaFunctionDeclaration functionDeclaration) {
        result.append(" function ");
        if (functionDeclaration.isReference()) {
            result.append('&');
        }
        result.append('(');
        final List<FormalParameter> formalParametersList = functionDeclaration
                .formalParameters();
        final Iterator<FormalParameter> paramIt = formalParametersList
                .iterator();
        while (paramIt.hasNext()) {
            paramIt.next().accept(this);
            if (paramIt.hasNext()) {
                result.append(", ");
            }
        }
        result.append(')');

        final List<Expression> lexicalVariables = functionDeclaration
                .lexicalVariables();
        if (lexicalVariables.size() > 0) {
            result.append(" use (");
            final Iterator<Expression> it = lexicalVariables.iterator();
            while (it.hasNext()) {
                it.next().accept(this);
                if (it.hasNext()) {
                    result.append(", "); //$NON-NLS-1$
                }
            }
            result.append(')');
        }

        if (functionDeclaration.getBody() != null) {
            functionDeclaration.getBody().accept(this);
        }
        return false;
    }

    @Override
    public boolean visit(MethodDeclaration methodDeclaration) {
        final Comment comment = methodDeclaration.getComment();
        if (comment != null) {
            comment.accept(this);
        }
        result.append(methodDeclaration.getModifierString());
        methodDeclaration.getFunction().accept(this);
        return false;
    }

    @Override
    public boolean visit(MethodInvocation methodInvocation) {
        methodInvocation.getDispatcher().accept(this);
        result.append("->"); //$NON-NLS-1$
        methodInvocation.getMethod().accept(this);
        return false;
    }

    @SuppressWarnings("deprecation")
    @Override
    public boolean visit(ParenthesisExpression parenthesisExpression) {
        result.append("("); //$NON-NLS-1$
        if (parenthesisExpression.getExpr() != null) {
            parenthesisExpression.getExpr().accept(this);
        }
        result.append(")"); //$NON-NLS-1$

        return false;
    }

    @Override
    public boolean visit(PostfixExpression postfixExpressions) {
        postfixExpressions.getVariable().accept(this);
        result.append(PostfixExpression.getOperator(postfixExpressions
                .getOperator()));
        return false;
    }

    @Override
    public boolean visit(PrefixExpression prefixExpression) {
        prefixExpression.getVariable().accept(this);
        result.append(PrefixExpression.getOperator(prefixExpression
                .getOperator()));
        return false;
    }

    @Override
    public boolean visit(Program program) {
        boolean isPhpState = false;
        @SuppressWarnings("deprecation")
        final Statement[] statements = program.getStatements();
        for (final Statement statement : statements) {
            final boolean isHtml = statement instanceof InLineHtml;

            if (!isHtml && !isPhpState) {
                // html -> php
                result.append("<?php\n"); //$NON-NLS-1$
                statement.accept(this);
                isPhpState = true;
            }
            else if (!isHtml && isPhpState) {
                // php -> php
                statement.accept(this);
                result.append("\n"); //$NON-NLS-1$
            }
            else if (isHtml && isPhpState) {
                // php -> html
                result.append("?>\n"); //$NON-NLS-1$
                statement.accept(this);
                result.append("\n"); //$NON-NLS-1$
                isPhpState = false;
            }
            else {
                // html first
                statement.accept(this);
                result.append("\n"); //$NON-NLS-1$
            }
        }

        if (isPhpState) {
            result.append("?>\n"); //$NON-NLS-1$
        }

        @SuppressWarnings("deprecation")
        final Collection comments = program.getComments();
        for (final Iterator iter = comments.iterator(); iter.hasNext();) {
            final Comment comment = (Comment) iter.next();
            comment.accept(this);
        }
        return false;
    }

    @Override
    @SuppressWarnings("deprecation")
    public boolean visit(Quote quote) {
        switch (quote.getQuoteType()) {
            case 0:
                result.append("\""); //$NON-NLS-1$
                acceptQuoteExpression(quote.getExpressions());
                result.append("\""); //$NON-NLS-1$
                break;
            case 1:
                result.append("\'"); //$NON-NLS-1$
                acceptQuoteExpression(quote.getExpressions());
                result.append("\'"); //$NON-NLS-1$
                break;
            case 2:
                result.append("<<<Heredoc\n"); //$NON-NLS-1$
                acceptQuoteExpression(quote.getExpressions());
                result.append("\nHeredoc"); //$NON-NLS-1$
        }
        return false;
    }

    @Override
    public boolean visit(Reference reference) {
        result.append("&"); //$NON-NLS-1$
        reference.getExpression().accept(this);
        return false;
    }

    @SuppressWarnings("deprecation")
    @Override
    public boolean visit(ReflectionVariable reflectionVariable) {
        result.append("$"); //$NON-NLS-1$
        reflectionVariable.getVariableName().accept(this);
        return false;
    }

    @SuppressWarnings("deprecation")
    @Override
    public boolean visit(ReturnStatement returnStatement) {
        result.append("return "); //$NON-NLS-1$
        if (returnStatement.getExpr() != null) {
            returnStatement.getExpr().accept(this);
        }
        result.append(";\n"); //$NON-NLS-1$
        return false;
    }

    @Override
    public boolean visit(Scalar scalar) {
        if (scalar.getScalarType() == Scalar.TYPE_UNKNOWN) {
            // cant flatten, needs source
        }
        else {
            result.append(scalar.getStringValue());
        }
        return false;
    }

    @Override
    public boolean visit(StaticConstantAccess staticFieldAccess) {
        staticFieldAccess.getClassName().accept(this);
        result.append("::"); //$NON-NLS-1$
        staticFieldAccess.getConstant().accept(this);
        return false;
    }

    @Override
    public boolean visit(StaticFieldAccess staticFieldAccess) {
        staticFieldAccess.getClassName().accept(this);
        result.append("::"); //$NON-NLS-1$
        staticFieldAccess.getField().accept(this);
        return false;
    }

    @Override
    public boolean visit(StaticMethodInvocation staticMethodInvocation) {
        staticMethodInvocation.getClassName().accept(this);
        result.append("::"); //$NON-NLS-1$
        staticMethodInvocation.getMethod().accept(this);
        return false;
    }

    @Override
    public boolean visit(StaticStatement staticStatement) {
        result.append("static "); //$NON-NLS-1$
        boolean isFirst = true;
        @SuppressWarnings("deprecation")
        final Expression[] expressions = staticStatement.getExpressions();
        for (final Expression expression : expressions) {
            if (!isFirst) {
                result.append(", "); //$NON-NLS-1$
            }
            expression.accept(this);
            isFirst = false;
        }
        result.append(";\n"); //$NON-NLS-1$
        return false;
    }

    @Override
    public boolean visit(SwitchCase switchCase) {
        if (switchCase.isDefault()) {
            result.append("default:\n");
        }
        else {
            result.append("case ");
            if (switchCase.getValue() != null) {
                switchCase.getValue().accept(this);
                result.append(":\n"); //$NON-NLS-1$
            }
        }
        @SuppressWarnings("deprecation")
        final Statement[] actions = switchCase.getActions();
        for (final Statement action : actions) {
            action.accept(this);
        }
        return false;
    }

    @Override
    public boolean visit(SwitchStatement switchStatement) {
        result.append("switch ("); //$NON-NLS-1$

        final Expression express = switchStatement.getExpression();
        if (express != null) {
            express.accept(this);
        }
        result.append(")"); //$NON-NLS-1$
        final Block statment = switchStatement.getBody();
        if (statment != null) {
            statment.accept(this);
        }
        return false;
    }

    @Override
    public boolean visit(ThrowStatement throwStatement) {
        throwStatement.getExpression().accept(this);
        return false;
    }

    @Override
    public boolean visit(TryStatement tryStatement) {
        result.append("try "); //$NON-NLS-1$

        final Block body = tryStatement.getBody();
        if (body != null) {
            body.accept(this);
        }
        final List<CatchClause> catchClauses = tryStatement.catchClauses();
        for (int i = 0; i < catchClauses.size(); i++) {
            catchClauses.get(i).accept(this);
        }
        return false;
    }

    @Override
    public boolean visit(UnaryOperation unaryOperation) {
        result.append(UnaryOperation.getOperator(unaryOperation.getOperator()));
        unaryOperation.getExpression().accept(this);
        return false;
    }

    @Override
    public boolean visit(Variable variable) {
        if (variable.isDollared()) {
            result.append("$");
        }
        variable.getName().accept(this);
        return false;
    }

    @Override
    public boolean visit(WhileStatement whileStatement) {
        result.append("while ("); //$NON-NLS-1$
        final Expression condition = whileStatement.getCondition();

        if (condition != null) {
            whileStatement.getCondition().accept(this);
        }
        result.append(")\n"); //$NON-NLS-1$
        final Statement body = whileStatement.getBody();
        if (body != null) {
            body.accept(this);
        }
        return false;
    }

    @Override
    public boolean visit(SingleFieldDeclaration singleFieldDeclaration) {
        singleFieldDeclaration.getName().accept(this);
        final Expression value = singleFieldDeclaration.getValue();
        if (value != null) {
            result.append(" = ");//$NON-NLS-1$
            value.accept(this);
        }
        return false;
    }

    private void acceptQuoteExpression(Expression[] expressions) {
        for (final Expression expression : expressions) {
            expression.accept(this);
        }
    }

}
