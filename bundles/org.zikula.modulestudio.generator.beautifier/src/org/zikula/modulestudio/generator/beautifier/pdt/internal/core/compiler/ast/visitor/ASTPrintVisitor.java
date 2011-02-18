package org.zikula.modulestudio.generator.beautifier.pdt.internal.core.compiler.ast.visitor;

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
 * Based on package org.eclipse.php.internal.core.compiler.ast.visitor;
 * 
 *******************************************************************************/

import java.io.ByteArrayOutputStream;
import java.io.OutputStream;
import java.util.Collection;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

import org.eclipse.dltk.ast.ASTNode;
import org.eclipse.dltk.ast.declarations.Declaration;
import org.eclipse.dltk.ast.declarations.ModuleDeclaration;
import org.eclipse.dltk.ast.expressions.Expression;
import org.eclipse.dltk.ast.references.ConstantReference;
import org.eclipse.dltk.ast.references.SimpleReference;
import org.eclipse.dltk.ast.references.TypeReference;
import org.eclipse.dltk.ast.references.VariableReference;
import org.eclipse.dltk.ast.statements.Statement;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.compiler.ast.nodes.ASTError;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.compiler.ast.nodes.ArrayCreation;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.compiler.ast.nodes.ArrayElement;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.compiler.ast.nodes.ArrayVariableReference;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.compiler.ast.nodes.Assignment;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.compiler.ast.nodes.BackTickExpression;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.compiler.ast.nodes.BreakStatement;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.compiler.ast.nodes.CastExpression;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.compiler.ast.nodes.CatchClause;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.compiler.ast.nodes.ClassDeclaration;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.compiler.ast.nodes.ClassInstanceCreation;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.compiler.ast.nodes.CloneExpression;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.compiler.ast.nodes.Comment;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.compiler.ast.nodes.ConditionalExpression;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.compiler.ast.nodes.ConstantDeclaration;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.compiler.ast.nodes.ContinueStatement;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.compiler.ast.nodes.DeclareStatement;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.compiler.ast.nodes.Dispatch;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.compiler.ast.nodes.DoStatement;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.compiler.ast.nodes.EchoStatement;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.compiler.ast.nodes.EmptyStatement;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.compiler.ast.nodes.ExpressionStatement;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.compiler.ast.nodes.FieldAccess;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.compiler.ast.nodes.ForEachStatement;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.compiler.ast.nodes.ForStatement;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.compiler.ast.nodes.FormalParameter;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.compiler.ast.nodes.FormalParameterByReference;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.compiler.ast.nodes.FullyQualifiedReference;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.compiler.ast.nodes.GlobalStatement;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.compiler.ast.nodes.GotoLabel;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.compiler.ast.nodes.GotoStatement;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.compiler.ast.nodes.IfStatement;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.compiler.ast.nodes.IgnoreError;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.compiler.ast.nodes.Include;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.compiler.ast.nodes.InfixExpression;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.compiler.ast.nodes.InstanceOfExpression;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.compiler.ast.nodes.InterfaceDeclaration;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.compiler.ast.nodes.LambdaFunctionDeclaration;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.compiler.ast.nodes.ListVariable;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.compiler.ast.nodes.NamespaceDeclaration;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.compiler.ast.nodes.NamespaceReference;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.compiler.ast.nodes.PHPCallArgumentsList;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.compiler.ast.nodes.PHPCallExpression;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.compiler.ast.nodes.PHPDocBlock;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.compiler.ast.nodes.PHPDocTag;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.compiler.ast.nodes.PHPFieldDeclaration;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.compiler.ast.nodes.PHPMethodDeclaration;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.compiler.ast.nodes.PHPModuleDeclaration;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.compiler.ast.nodes.PostfixExpression;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.compiler.ast.nodes.PrefixExpression;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.compiler.ast.nodes.Quote;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.compiler.ast.nodes.ReferenceExpression;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.compiler.ast.nodes.ReflectionArrayVariableReference;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.compiler.ast.nodes.ReflectionCallExpression;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.compiler.ast.nodes.ReflectionStaticMethodInvocation;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.compiler.ast.nodes.ReflectionVariableReference;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.compiler.ast.nodes.ReturnStatement;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.compiler.ast.nodes.Scalar;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.compiler.ast.nodes.StaticConstantAccess;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.compiler.ast.nodes.StaticDispatch;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.compiler.ast.nodes.StaticFieldAccess;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.compiler.ast.nodes.StaticMethodInvocation;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.compiler.ast.nodes.StaticStatement;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.compiler.ast.nodes.SwitchCase;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.compiler.ast.nodes.SwitchStatement;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.compiler.ast.nodes.ThrowStatement;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.compiler.ast.nodes.TryStatement;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.compiler.ast.nodes.UnaryOperation;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.compiler.ast.nodes.UsePart;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.compiler.ast.nodes.UseStatement;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.compiler.ast.nodes.WhileStatement;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.util.XMLWriter;

/**
 * This visitor is used for printing AST nodes in an XML format
 * 
 * @author michael
 */
public class ASTPrintVisitor extends PHPASTVisitor {

    private final XMLWriter xmlWriter;

    /**
     * Constructs new {@link ASTPrintVisitor}
     * 
     * @param out
     *            Output stream to print the XML to
     * @throws Exception
     */
    private ASTPrintVisitor(OutputStream out) throws Exception {
        xmlWriter = new XMLWriter(out, false);
    }

    private void close() {
        xmlWriter.flush();
        xmlWriter.close();
    }

    public static String toXMLString(ASTNode node) {
        try {
            final ByteArrayOutputStream out = new ByteArrayOutputStream();
            final ASTPrintVisitor printVisitor = new ASTPrintVisitor(out);
            node.traverse(printVisitor);
            printVisitor.close();
            return out.toString("UTF-8");

        } catch (final Exception e) {
            return e.toString();
        }
    }

    protected Map<String, String> createInitialParameters(ASTNode s)
            throws Exception {
        final Map<String, String> parameters = new LinkedHashMap<String, String>();

        // Print offset information:
        parameters.put("start", Integer.toString(s.sourceStart()));
        parameters.put("end", Integer.toString(s.sourceEnd()));

        // Print modifiers:
        if (s instanceof Declaration) {
            final Declaration declaration = (Declaration) s;
            final StringBuilder buf = new StringBuilder();
            if (declaration.isAbstract()) {
                buf.append(",abstract");
            }
            if (declaration.isFinal()) {
                buf.append(",final");
            }
            if (declaration.isPrivate()) {
                buf.append(",private");
            }
            if (declaration.isProtected()) {
                buf.append(",protected");
            }
            if (declaration.isPublic()) {
                buf.append(",public");
            }
            if (declaration.isStatic()) {
                buf.append(",static");
            }
            final String modifiers = buf.toString();
            parameters
                    .put("modifiers",
                            modifiers.length() > 0 ? modifiers.substring(1)
                                    : modifiers);
        }

        return parameters;
    }

    @Override
    public boolean endvisit(ArrayCreation s) throws Exception {
        xmlWriter.endTag("ArrayCreation");
        return true;
    }

    @Override
    public boolean endvisit(ArrayElement s) throws Exception {
        xmlWriter.endTag("ArrayElement");
        return true;
    }

    @Override
    public boolean endvisit(ArrayVariableReference s) throws Exception {
        xmlWriter.endTag("ArrayVariableReference");
        return true;
    }

    @Override
    public boolean endvisit(Assignment s) throws Exception {
        xmlWriter.endTag("Assignment");
        return true;
    }

    @Override
    public boolean endvisit(ASTError s) throws Exception {
        xmlWriter.endTag("ASTError");
        return true;
    }

    @Override
    public boolean endvisit(BackTickExpression s) throws Exception {
        xmlWriter.endTag("BackTickExpression");
        return true;
    }

    @Override
    public boolean endvisit(BreakStatement s) throws Exception {
        xmlWriter.endTag("BreakStatement");
        return true;
    }

    @Override
    public boolean endvisit(CastExpression s) throws Exception {
        xmlWriter.endTag("CastExpression");
        return true;
    }

    @Override
    public boolean endvisit(CatchClause s) throws Exception {
        xmlWriter.endTag("CatchClause");
        return true;
    }

    @Override
    public boolean endvisit(ConstantDeclaration s) throws Exception {
        xmlWriter.endTag("ConstantDeclaration");
        return true;
    }

    @Override
    public boolean endvisit(ClassDeclaration s) throws Exception {
        xmlWriter.endTag("ClassDeclaration");
        return true;
    }

    @Override
    public boolean endvisit(ClassInstanceCreation s) throws Exception {
        xmlWriter.endTag("ClassInstanceCreation");
        return true;
    }

    @Override
    public boolean endvisit(CloneExpression s) throws Exception {
        xmlWriter.endTag("CloneExpression");
        return true;
    }

    @Override
    public boolean endvisit(Comment s) throws Exception {
        xmlWriter.endTag("Comment");
        return true;
    }

    @Override
    public boolean endvisit(ConditionalExpression s) throws Exception {
        xmlWriter.endTag("ConditionalExpression");
        return true;
    }

    @Override
    public boolean endvisit(ConstantReference s) throws Exception {
        xmlWriter.endTag("ConstantReference");
        return true;
    }

    @Override
    public boolean endvisit(ContinueStatement s) throws Exception {
        xmlWriter.endTag("ContinueStatement");
        return true;
    }

    @Override
    public boolean endvisit(DeclareStatement s) throws Exception {
        xmlWriter.endTag("DeclareStatement");
        return true;
    }

    @Override
    public boolean endvisit(Dispatch s) throws Exception {
        xmlWriter.endTag("Dispatch");
        return true;
    }

    @Override
    public boolean endvisit(DoStatement s) throws Exception {
        xmlWriter.endTag("DoStatement");
        return true;
    }

    @Override
    public boolean endvisit(EchoStatement s) throws Exception {
        xmlWriter.endTag("EchoStatement");
        return true;
    }

    @Override
    public boolean endvisit(EmptyStatement s) throws Exception {
        xmlWriter.endTag("EmptyStatement");
        return true;
    }

    @Override
    public boolean endvisit(ExpressionStatement s) throws Exception {
        xmlWriter.endTag("ExpressionStatement");
        return true;
    }

    @Override
    public boolean endvisit(FieldAccess s) throws Exception {
        xmlWriter.endTag("FieldAccess");
        return true;
    }

    @Override
    public boolean endvisit(ForEachStatement s) throws Exception {
        xmlWriter.endTag("ForEachStatement");
        return true;
    }

    @Override
    public boolean endvisit(FormalParameter s) throws Exception {
        xmlWriter.endTag("FormalParameter");
        return true;
    }

    @Override
    public boolean endvisit(FormalParameterByReference s) throws Exception {
        xmlWriter.endTag("FormalParameterByReference");
        return true;
    }

    @Override
    public boolean endvisit(ForStatement s) throws Exception {
        xmlWriter.endTag("ForStatement");
        return true;
    }

    @Override
    public boolean endvisit(GlobalStatement s) throws Exception {
        xmlWriter.endTag("GlobalStatement");
        return true;
    }

    @Override
    public boolean endvisit(IfStatement s) throws Exception {
        xmlWriter.endTag("IfStatement");
        return true;
    }

    @Override
    public boolean endvisit(IgnoreError s) throws Exception {
        xmlWriter.endTag("IgnoreError");
        return true;
    }

    @Override
    public boolean endvisit(Include s) throws Exception {
        xmlWriter.endTag("Include");
        return true;
    }

    @Override
    public boolean endvisit(InfixExpression s) throws Exception {
        xmlWriter.endTag("InfixExpression");
        return true;
    }

    @Override
    public boolean endvisit(InstanceOfExpression s) throws Exception {
        xmlWriter.endTag("InstanceOfExpression");
        return true;
    }

    @Override
    public boolean endvisit(InterfaceDeclaration s) throws Exception {
        xmlWriter.endTag("InterfaceDeclaration");
        return true;
    }

    @Override
    public boolean endvisit(ListVariable s) throws Exception {
        xmlWriter.endTag("ListVariable");
        return true;
    }

    @Override
    public boolean endvisit(PHPCallArgumentsList s) throws Exception {
        xmlWriter.endTag("PHPCallArgumentsList");
        return true;
    }

    @Override
    public boolean endvisit(PHPCallExpression s) throws Exception {
        xmlWriter.endTag("PHPCallExpression");
        return true;
    }

    @Override
    public boolean endvisit(PHPDocBlock s) throws Exception {
        xmlWriter.endTag("PHPDocBlock");
        return true;
    }

    @Override
    public boolean endvisit(PHPDocTag s) throws Exception {
        xmlWriter.endTag("PHPDocTag");
        return true;
    }

    @Override
    public boolean endvisit(PHPFieldDeclaration s) throws Exception {
        xmlWriter.endTag("PHPFieldDeclaration");
        return true;
    }

    @Override
    public boolean endvisit(PHPMethodDeclaration s) throws Exception {
        xmlWriter.endTag("PHPMethodDeclaration");
        return true;
    }

    @Override
    public boolean endvisit(PostfixExpression s) throws Exception {
        xmlWriter.endTag("PostfixExpression");
        return true;
    }

    @Override
    public boolean endvisit(PrefixExpression s) throws Exception {
        xmlWriter.endTag("PrefixExpression");
        return true;
    }

    @Override
    public boolean endvisit(Quote s) throws Exception {
        xmlWriter.endTag("Quote");
        return true;
    }

    @Override
    public boolean endvisit(ReferenceExpression s) throws Exception {
        xmlWriter.endTag("ReferenceExpression");
        return true;
    }

    @Override
    public boolean endvisit(ReflectionArrayVariableReference s)
            throws Exception {
        xmlWriter.endTag("ReflectionArrayVariableReference");
        return true;
    }

    @Override
    public boolean endvisit(ReflectionCallExpression s) throws Exception {
        xmlWriter.endTag("ReflectionCallExpression");
        return true;
    }

    @Override
    public boolean endvisit(ReflectionStaticMethodInvocation s)
            throws Exception {
        xmlWriter.endTag("ReflectionStaticMethodInvocation");
        return true;
    }

    @Override
    public boolean endvisit(ReflectionVariableReference s) throws Exception {
        xmlWriter.endTag("ReflectionVariableReference");
        return true;
    }

    @Override
    public boolean endvisit(ReturnStatement s) throws Exception {
        xmlWriter.endTag("ReturnStatement");
        return true;
    }

    @Override
    public boolean endvisit(Scalar s) throws Exception {
        xmlWriter.endTag("Scalar");
        return true;
    }

    @Override
    public boolean endvisit(SimpleReference s) throws Exception {
        xmlWriter.endTag("SimpleReference");
        return true;
    }

    @Override
    public boolean endvisit(StaticConstantAccess s) throws Exception {
        xmlWriter.endTag("StaticConstantAccess");
        return true;
    }

    @Override
    public boolean endvisit(StaticDispatch s) throws Exception {
        xmlWriter.endTag("StaticDispatch");
        return true;
    }

    @Override
    public boolean endvisit(StaticFieldAccess s) throws Exception {
        xmlWriter.endTag("StaticFieldAccess");
        return true;
    }

    @Override
    public boolean endvisit(StaticMethodInvocation s) throws Exception {
        xmlWriter.endTag("StaticMethodInvocation");
        return true;
    }

    @Override
    public boolean endvisit(StaticStatement s) throws Exception {
        xmlWriter.endTag("StaticStatement");
        return true;
    }

    @Override
    public boolean endvisit(SwitchCase s) throws Exception {
        xmlWriter.endTag("SwitchCase");
        return true;
    }

    @Override
    public boolean endvisit(SwitchStatement s) throws Exception {
        xmlWriter.endTag("SwitchStatement");
        return true;
    }

    @Override
    public boolean endvisit(ThrowStatement s) throws Exception {
        xmlWriter.endTag("ThrowStatement");
        return true;
    }

    @Override
    public boolean endvisit(TryStatement s) throws Exception {
        xmlWriter.endTag("TryStatement");
        return true;
    }

    @Override
    public boolean endvisit(TypeReference s) throws Exception {
        xmlWriter.endTag("TypeReference");
        return true;
    }

    @Override
    public boolean endvisit(FullyQualifiedReference s) throws Exception {
        xmlWriter.endTag("FullyQualifiedReference");
        return true;
    }

    @Override
    public boolean endvisit(NamespaceReference s) throws Exception {
        xmlWriter.endTag("NamespaceReference");
        return true;
    }

    @Override
    public boolean endvisit(UnaryOperation s) throws Exception {
        xmlWriter.endTag("UnaryOperation");
        return true;
    }

    @Override
    public boolean endvisit(VariableReference s) throws Exception {
        xmlWriter.endTag("VariableReference");
        return true;
    }

    @Override
    public boolean endvisit(WhileStatement s) throws Exception {
        xmlWriter.endTag("WhileStatement");
        return true;
    }

    @Override
    public boolean endvisit(ModuleDeclaration s) throws Exception {
        final List<ASTError> errors = ((PHPModuleDeclaration) s).getErrors();
        if (!errors.isEmpty()) {
            xmlWriter.startTag("Errors", null);
            for (final ASTError error : errors) {
                error.traverse(this);
            }
            xmlWriter.endTag("Errors");
        }
        xmlWriter.endTag("ModuleDeclaration");
        return true;
    }

    @Override
    public boolean endvisit(NamespaceDeclaration s) throws Exception {
        xmlWriter.endTag("NamespaceDeclaration");
        return true;
    }

    @Override
    public boolean endvisit(GotoLabel s) throws Exception {
        xmlWriter.endTag("GotoLabel");
        return true;
    }

    @Override
    public boolean endvisit(GotoStatement s) throws Exception {
        xmlWriter.endTag("GotoStatement");
        return true;
    }

    @Override
    public boolean endvisit(LambdaFunctionDeclaration s) throws Exception {
        xmlWriter.endTag("LambdaFunctionDeclaration");
        return true;
    }

    @Override
    public boolean visit(ArrayCreation s) throws Exception {
        final Map<String, String> parameters = createInitialParameters(s);
        xmlWriter.startTag("ArrayCreation", parameters);
        return true;
    }

    @Override
    public boolean visit(ArrayElement s) throws Exception {
        final Map<String, String> parameters = createInitialParameters(s);
        xmlWriter.startTag("ArrayElement", parameters);
        return true;
    }

    @Override
    public boolean visit(ArrayVariableReference s) throws Exception {
        final Map<String, String> parameters = createInitialParameters(s);
        parameters.put("type",
                ArrayVariableReference.getArrayType(s.getArrayType()));
        parameters.put("name", s.getName());
        xmlWriter.startTag("ArrayVariableReference", parameters);
        return true;
    }

    @Override
    public boolean visit(Assignment s) throws Exception {
        final Map<String, String> parameters = createInitialParameters(s);
        parameters.put("operator", s.getOperator());
        xmlWriter.startTag("Assignment", parameters);
        return true;
    }

    @Override
    public boolean visit(ASTError s) throws Exception {
        final Map<String, String> parameters = createInitialParameters(s);
        xmlWriter.startTag("ASTError", parameters);
        return true;
    }

    @Override
    public boolean visit(BackTickExpression s) throws Exception {
        final Map<String, String> parameters = createInitialParameters(s);
        xmlWriter.startTag("BackTickExpression", parameters);
        return true;
    }

    @Override
    public boolean visit(BreakStatement s) throws Exception {
        final Map<String, String> parameters = createInitialParameters(s);
        xmlWriter.startTag("BreakStatement", parameters);
        return true;
    }

    @Override
    public boolean visit(CastExpression s) throws Exception {
        final Map<String, String> parameters = createInitialParameters(s);
        parameters.put("type", CastExpression.getCastType(s.getCastType()));
        xmlWriter.startTag("CastExpression", parameters);
        return true;
    }

    @Override
    public boolean visit(CatchClause s) throws Exception {
        final Map<String, String> parameters = createInitialParameters(s);
        xmlWriter.startTag("CatchClause", parameters);
        return true;
    }

    @Override
    public boolean visit(ConstantDeclaration s) throws Exception {
        final Map<String, String> parameters = createInitialParameters(s);
        xmlWriter.startTag("ConstantDeclaration", parameters);
        return true;
    }

    @Override
    public boolean visit(ClassDeclaration s) throws Exception {
        final Map<String, String> parameters = createInitialParameters(s);
        parameters.put("name", s.getName());
        xmlWriter.startTag("ClassDeclaration", parameters);
        return true;
    }

    @Override
    public boolean visit(ClassInstanceCreation s) throws Exception {
        final Map<String, String> parameters = createInitialParameters(s);
        xmlWriter.startTag("ClassInstanceCreation", parameters);
        return true;
    }

    @Override
    public boolean visit(CloneExpression s) throws Exception {
        final Map<String, String> parameters = createInitialParameters(s);
        xmlWriter.startTag("CloneExpression", parameters);
        return true;
    }

    @Override
    public boolean visit(Comment s) throws Exception {
        final Map<String, String> parameters = createInitialParameters(s);
        parameters.put("type", Comment.getCommentType(s.getCommentType()));
        xmlWriter.startTag("Comment", parameters);
        return true;
    }

    @Override
    public boolean visit(ConditionalExpression s) throws Exception {
        final Map<String, String> parameters = createInitialParameters(s);
        xmlWriter.startTag("ConditionalExpression", parameters);

        xmlWriter.startTag("Condition", new HashMap<String, String>());
        s.getCondition().traverse(this);
        xmlWriter.endTag("Condition");

        final Expression ifTrue = s.getIfTrue();
        if (ifTrue != null) {
            xmlWriter.startTag("IfTrue", new HashMap<String, String>());
            ifTrue.traverse(this);
            xmlWriter.endTag("IfTrue");
        }

        final Expression falseExp = s.getIfFalse();
        if (falseExp != null) {
            xmlWriter.startTag("IfFalse", new HashMap<String, String>());
            falseExp.traverse(this);
            xmlWriter.endTag("IfFalse");
        }

        return false;
    }

    @Override
    public boolean visit(ConstantReference s) throws Exception {
        final Map<String, String> parameters = createInitialParameters(s);
        parameters.put("name", s.getName());
        xmlWriter.startTag("ConstantReference", parameters);
        return true;
    }

    @Override
    public boolean visit(ContinueStatement s) throws Exception {
        final Map<String, String> parameters = createInitialParameters(s);
        xmlWriter.startTag("ContinueStatement", parameters);
        return true;
    }

    @Override
    public boolean visit(DeclareStatement s) throws Exception {
        final Map<String, String> parameters = createInitialParameters(s);
        xmlWriter.startTag("DeclareStatement", parameters);
        return true;
    }

    @Override
    public boolean visit(Dispatch s) throws Exception {
        final Map<String, String> parameters = createInitialParameters(s);
        xmlWriter.startTag("Dispatch", parameters);
        return true;
    }

    @Override
    public boolean visit(DoStatement s) throws Exception {
        final Map<String, String> parameters = createInitialParameters(s);
        xmlWriter.startTag("DoStatement", parameters);
        return true;
    }

    @Override
    public boolean visit(EchoStatement s) throws Exception {
        final Map<String, String> parameters = createInitialParameters(s);
        xmlWriter.startTag("EchoStatement", parameters);
        return true;
    }

    @Override
    public boolean visit(EmptyStatement s) throws Exception {
        final Map<String, String> parameters = createInitialParameters(s);
        xmlWriter.startTag("EmptyStatement", parameters);
        return true;
    }

    @Override
    public boolean visit(ExpressionStatement s) throws Exception {
        final Map<String, String> parameters = createInitialParameters(s);
        xmlWriter.startTag("ExpressionStatement", parameters);
        return true;
    }

    @Override
    public boolean visit(FieldAccess s) throws Exception {
        final Map<String, String> parameters = createInitialParameters(s);
        xmlWriter.startTag("FieldAccess", parameters);
        return true;
    }

    @Override
    public boolean visit(ForEachStatement s) throws Exception {
        final Map<String, String> parameters = createInitialParameters(s);
        xmlWriter.startTag("ForEachStatement", parameters);
        return true;
    }

    @Override
    public boolean visit(FormalParameter s) throws Exception {
        final Map<String, String> parameters = createInitialParameters(s);
        parameters.put("isMandatory", Boolean.toString(s.isMandatory()));
        xmlWriter.startTag("FormalParameter", parameters);
        return true;
    }

    @Override
    public boolean visit(FormalParameterByReference s) throws Exception {
        final Map<String, String> parameters = createInitialParameters(s);
        xmlWriter.startTag("FormalParameterByReference", parameters);
        return true;
    }

    @Override
    public boolean visit(ForStatement s) throws Exception {
        final Map<String, String> parameters = createInitialParameters(s);
        xmlWriter.startTag("ForStatement", parameters);

        xmlWriter.startTag("Initializations", new HashMap<String, String>());
        for (final Expression initialization : s.getInitializations()) {
            initialization.traverse(this);
        }
        xmlWriter.endTag("Initializations");

        xmlWriter.startTag("Conditions", new HashMap<String, String>());
        for (final Expression condition : s.getConditions()) {
            condition.traverse(this);
        }
        xmlWriter.endTag("Conditions");

        xmlWriter.startTag("Increasements", new HashMap<String, String>());
        for (final Expression increasement : s.getIncreasements()) {
            increasement.traverse(this);
        }
        xmlWriter.endTag("Increasements");

        s.getAction().traverse(this);

        return false;
    }

    @Override
    public boolean visit(GlobalStatement s) throws Exception {
        final Map<String, String> parameters = createInitialParameters(s);
        xmlWriter.startTag("GlobalStatement", parameters);
        return true;
    }

    @Override
    public boolean visit(IfStatement s) throws Exception {
        final Map<String, String> parameters = createInitialParameters(s);
        xmlWriter.startTag("IfStatement", parameters);

        xmlWriter.startTag("Condition", new HashMap<String, String>());
        s.getCondition().traverse(this);
        xmlWriter.endTag("Condition");

        xmlWriter.startTag("TrueStatement", new HashMap<String, String>());
        s.getTrueStatement().traverse(this);
        xmlWriter.endTag("TrueStatement");

        final Statement falseStatement = s.getFalseStatement();
        if (falseStatement != null) {
            xmlWriter.startTag("FalseStatement", new HashMap<String, String>());
            falseStatement.traverse(this);
            xmlWriter.endTag("FalseStatement");
        }

        return false;
    }

    @Override
    public boolean visit(IgnoreError s) throws Exception {
        final Map<String, String> parameters = createInitialParameters(s);
        xmlWriter.startTag("IgnoreError", parameters);
        return true;
    }

    @Override
    public boolean visit(Include s) throws Exception {
        final Map<String, String> parameters = createInitialParameters(s);
        parameters.put("type", s.getType());
        xmlWriter.startTag("Include", parameters);
        return true;
    }

    @Override
    public boolean visit(InfixExpression s) throws Exception {
        final Map<String, String> parameters = createInitialParameters(s);
        parameters.put("operator", s.getOperator());
        xmlWriter.startTag("InfixExpression", parameters);
        return true;
    }

    @Override
    public boolean visit(InstanceOfExpression s) throws Exception {
        final Map<String, String> parameters = createInitialParameters(s);
        xmlWriter.startTag("InstanceOfExpression", parameters);
        return true;
    }

    @Override
    public boolean visit(InterfaceDeclaration s) throws Exception {
        final Map<String, String> parameters = createInitialParameters(s);
        parameters.put("name", s.getName());
        xmlWriter.startTag("InterfaceDeclaration", parameters);
        return true;
    }

    @Override
    public boolean visit(ListVariable s) throws Exception {
        final Map<String, String> parameters = createInitialParameters(s);
        xmlWriter.startTag("ListVariable", parameters);
        return true;
    }

    @Override
    public boolean visit(PHPCallArgumentsList s) throws Exception {
        final Map<String, String> parameters = createInitialParameters(s);
        xmlWriter.startTag("PHPCallArgumentsList", parameters);
        return true;
    }

    @Override
    public boolean visit(PHPCallExpression s) throws Exception {
        final Map<String, String> parameters = createInitialParameters(s);
        xmlWriter.startTag("PHPCallExpression", parameters);
        return true;
    }

    @Override
    public boolean visit(PHPDocBlock s) throws Exception {
        final Map<String, String> parameters = createInitialParameters(s);
        parameters.put("shortDescription", s.getShortDescription());
        xmlWriter.startTag("PHPDocBlock", parameters);
        return true;
    }

    @Override
    public boolean visit(PHPDocTag s) throws Exception {
        final Map<String, String> parameters = createInitialParameters(s);
        parameters.put("tagKind", PHPDocTag.getTagKind(s.getTagKind()));
        parameters.put("value", s.getValue());
        xmlWriter.startTag("PHPDocTag", parameters);
        return true;
    }

    @Override
    public boolean visit(PHPFieldDeclaration s) throws Exception {
        final Map<String, String> parameters = createInitialParameters(s);
        xmlWriter.startTag("PHPFieldDeclaration", parameters);
        return true;
    }

    @Override
    public boolean visit(PHPMethodDeclaration s) throws Exception {
        final Map<String, String> parameters = createInitialParameters(s);
        parameters.put("name", s.getName());
        xmlWriter.startTag("PHPMethodDeclaration", parameters);
        return true;
    }

    @Override
    public boolean visit(PostfixExpression s) throws Exception {
        final Map<String, String> parameters = createInitialParameters(s);
        parameters.put("operator", s.getOperator());
        xmlWriter.startTag("PostfixExpression", parameters);
        return true;
    }

    @Override
    public boolean visit(PrefixExpression s) throws Exception {
        final Map<String, String> parameters = createInitialParameters(s);
        parameters.put("operator", s.getOperator());
        xmlWriter.startTag("PrefixExpression", parameters);
        return true;
    }

    @Override
    public boolean visit(Quote s) throws Exception {
        final Map<String, String> parameters = createInitialParameters(s);
        parameters.put("type", Quote.getType(s.getQuoteType()));
        xmlWriter.startTag("Quote", parameters);
        return true;
    }

    @Override
    public boolean visit(ReferenceExpression s) throws Exception {
        final Map<String, String> parameters = createInitialParameters(s);
        xmlWriter.startTag("ReferenceExpression", parameters);
        return true;
    }

    @Override
    public boolean visit(ReflectionArrayVariableReference s) throws Exception {
        final Map<String, String> parameters = createInitialParameters(s);
        xmlWriter.startTag("ReflectionArrayVariableReference", parameters);
        return true;
    }

    @Override
    public boolean visit(ReflectionCallExpression s) throws Exception {
        final Map<String, String> parameters = createInitialParameters(s);
        xmlWriter.startTag("ReflectionCallExpression", parameters);
        return true;
    }

    @Override
    public boolean visit(ReflectionStaticMethodInvocation s) throws Exception {
        final Map<String, String> parameters = createInitialParameters(s);
        xmlWriter.startTag("ReflectionStaticMethodInvocation", parameters);
        return true;
    }

    @Override
    public boolean visit(ReflectionVariableReference s) throws Exception {
        final Map<String, String> parameters = createInitialParameters(s);
        xmlWriter.startTag("ReflectionVariableReference", parameters);
        return true;
    }

    @Override
    public boolean visit(ReturnStatement s) throws Exception {
        final Map<String, String> parameters = createInitialParameters(s);
        xmlWriter.startTag("ReturnStatement", parameters);
        return true;
    }

    @Override
    public boolean visit(Scalar s) throws Exception {
        final Map<String, String> parameters = createInitialParameters(s);
        parameters.put("type", s.getType());
        parameters.put("value", s.getValue());
        xmlWriter.startTag("Scalar", parameters);
        return true;
    }

    @Override
    public boolean visit(SimpleReference s) throws Exception {
        final Map<String, String> parameters = createInitialParameters(s);
        parameters.put("name", s.getName());
        xmlWriter.startTag("SimpleReference", parameters);
        return true;
    }

    @Override
    public boolean visit(StaticConstantAccess s) throws Exception {
        final Map<String, String> parameters = createInitialParameters(s);
        xmlWriter.startTag("StaticConstantAccess", parameters);
        return true;
    }

    @Override
    public boolean visit(StaticDispatch s) throws Exception {
        final Map<String, String> parameters = createInitialParameters(s);
        xmlWriter.startTag("StaticDispatch", parameters);
        return true;
    }

    @Override
    public boolean visit(StaticFieldAccess s) throws Exception {
        final Map<String, String> parameters = createInitialParameters(s);
        xmlWriter.startTag("StaticFieldAccess", parameters);
        return true;
    }

    @Override
    public boolean visit(StaticMethodInvocation s) throws Exception {
        final Map<String, String> parameters = createInitialParameters(s);
        xmlWriter.startTag("StaticMethodInvocation", parameters);
        return true;
    }

    @Override
    public boolean visit(StaticStatement s) throws Exception {
        final Map<String, String> parameters = createInitialParameters(s);
        xmlWriter.startTag("StaticStatement", parameters);
        return true;
    }

    @Override
    public boolean visit(SwitchCase s) throws Exception {
        final Map<String, String> parameters = createInitialParameters(s);
        xmlWriter.startTag("SwitchCase", parameters);
        return true;
    }

    @Override
    public boolean visit(SwitchStatement s) throws Exception {
        final Map<String, String> parameters = createInitialParameters(s);
        xmlWriter.startTag("SwitchStatement", parameters);
        return true;
    }

    @Override
    public boolean visit(ThrowStatement s) throws Exception {
        final Map<String, String> parameters = createInitialParameters(s);
        xmlWriter.startTag("ThrowStatement", parameters);
        return true;
    }

    @Override
    public boolean visit(TryStatement s) throws Exception {
        final Map<String, String> parameters = createInitialParameters(s);
        xmlWriter.startTag("TryStatement", parameters);
        return true;
    }

    @Override
    public boolean visit(TypeReference s) throws Exception {
        final Map<String, String> parameters = createInitialParameters(s);
        parameters.put("name", s.getName());
        xmlWriter.startTag("TypeReference", parameters);
        return true;
    }

    @Override
    public boolean visit(FullyQualifiedReference s) throws Exception {
        final Map<String, String> parameters = createInitialParameters(s);
        parameters.put("name", s.getFullyQualifiedName());
        xmlWriter.startTag("FullyQualifiedReference", parameters);
        return true;
    }

    @Override
    public boolean visit(NamespaceReference s) throws Exception {
        final Map<String, String> parameters = createInitialParameters(s);
        parameters.put("name", s.getName());
        parameters.put("global", Boolean.toString(s.isGlobal()));
        parameters.put("local", Boolean.toString(s.isLocal()));
        xmlWriter.startTag("NamespaceReference", parameters);
        return true;
    }

    @Override
    public boolean visit(UnaryOperation s) throws Exception {
        final Map<String, String> parameters = createInitialParameters(s);
        parameters.put("operator", s.getOperator());
        xmlWriter.startTag("UnaryOperation", parameters);
        return true;
    }

    @Override
    public boolean visit(VariableReference s) throws Exception {
        final Map<String, String> parameters = createInitialParameters(s);
        parameters.put("name", s.getName());
        xmlWriter.startTag("VariableReference", parameters);
        return true;
    }

    @Override
    public boolean visit(WhileStatement s) throws Exception {
        final Map<String, String> parameters = createInitialParameters(s);
        xmlWriter.startTag("WhileStatement", parameters);
        return true;
    }

    @Override
    public boolean visit(ModuleDeclaration s) throws Exception {
        final Map<String, String> parameters = createInitialParameters(s);
        xmlWriter.startTag("ModuleDeclaration", parameters);
        return true;
    }

    @Override
    public boolean visit(NamespaceDeclaration s) throws Exception {
        final Map<String, String> parameters = createInitialParameters(s);
        parameters.put("name", s.getName());
        xmlWriter.startTag("NamespaceDeclaration", parameters);
        return true;
    }

    @Override
    public boolean visit(UseStatement s) throws Exception {
        final Map<String, String> parameters = createInitialParameters(s);
        xmlWriter.startTag("UseStatement", parameters);

        xmlWriter.startTag("Parts", new HashMap<String, String>());
        for (final UsePart p : s.getParts()) {
            p.traverse(this);
        }
        xmlWriter.endTag("Parts");
        xmlWriter.endTag("UseStatement");
        return false;
    }

    @Override
    public boolean visit(UsePart s) throws Exception {
        final Map<String, String> parameters = createInitialParameters(s);
        xmlWriter.startTag("UsePart", parameters);
        s.getNamespace().traverse(this);
        if (s.getAlias() != null) {
            s.getAlias().traverse(this);
        }
        xmlWriter.endTag("UsePart");
        return false;
    }

    @Override
    public boolean visit(GotoLabel s) throws Exception {
        final Map<String, String> parameters = createInitialParameters(s);
        parameters.put("label", s.getLabel());
        xmlWriter.startTag("GotoLabel", parameters);
        return true;
    }

    @Override
    public boolean visit(GotoStatement s) throws Exception {
        final Map<String, String> parameters = createInitialParameters(s);
        parameters.put("label", s.getLabel());
        xmlWriter.startTag("GotoStatement", parameters);
        return true;
    }

    @Override
    public boolean visit(LambdaFunctionDeclaration s) throws Exception {
        final Map<String, String> parameters = createInitialParameters(s);
        parameters.put("isReference", Boolean.toString(s.isReference()));
        xmlWriter.startTag("LambdaFunctionDeclaration", parameters);

        xmlWriter.startTag("Arguments", new HashMap<String, String>());
        for (final FormalParameter p : s.getArguments()) {
            p.traverse(this);
        }
        xmlWriter.endTag("Arguments");

        final Collection<? extends Expression> lexicalVars = s.getLexicalVars();
        if (lexicalVars != null) {
            xmlWriter.startTag("LexicalVars", new HashMap<String, String>());
            for (final Expression var : lexicalVars) {
                var.traverse(this);
            }
            xmlWriter.endTag("LexicalVars");
        }

        s.getBody().traverse(this);

        return false;
    }
}
