package org.zikula.modulestudio.generator.beautifier.pdt.internal.core.typeinference.evaluators;

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
 * Based on package org.eclipse.php.internal.core.typeinference.evaluators;
 * 
 *******************************************************************************/

import org.eclipse.dltk.ast.ASTNode;
import org.eclipse.dltk.ast.declarations.TypeDeclaration;
import org.eclipse.dltk.ast.references.TypeReference;
import org.eclipse.dltk.ast.references.VariableReference;
import org.eclipse.dltk.evaluation.types.SimpleType;
import org.eclipse.dltk.ti.IGoalEvaluatorFactory;
import org.eclipse.dltk.ti.goals.ExpressionTypeGoal;
import org.eclipse.dltk.ti.goals.FixedAnswerEvaluator;
import org.eclipse.dltk.ti.goals.GoalEvaluator;
import org.eclipse.dltk.ti.goals.IGoal;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.compiler.ast.nodes.ArrayCreation;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.compiler.ast.nodes.ArrayVariableReference;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.compiler.ast.nodes.Assignment;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.compiler.ast.nodes.BackTickExpression;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.compiler.ast.nodes.CastExpression;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.compiler.ast.nodes.CatchClause;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.compiler.ast.nodes.ClassDeclaration;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.compiler.ast.nodes.ClassInstanceCreation;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.compiler.ast.nodes.CloneExpression;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.compiler.ast.nodes.ConditionalExpression;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.compiler.ast.nodes.FieldAccess;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.compiler.ast.nodes.FormalParameter;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.compiler.ast.nodes.FormalParameterByReference;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.compiler.ast.nodes.FullyQualifiedReference;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.compiler.ast.nodes.InfixExpression;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.compiler.ast.nodes.InstanceOfExpression;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.compiler.ast.nodes.InterfaceDeclaration;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.compiler.ast.nodes.PHPCallExpression;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.compiler.ast.nodes.PostfixExpression;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.compiler.ast.nodes.PrefixExpression;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.compiler.ast.nodes.Quote;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.compiler.ast.nodes.Scalar;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.compiler.ast.nodes.StaticConstantAccess;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.compiler.ast.nodes.StaticFieldAccess;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.compiler.ast.nodes.StaticMethodInvocation;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.compiler.ast.nodes.UnaryOperation;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.typeinference.evaluators.phpdoc.PHPDocClassVariableEvaluator;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.typeinference.evaluators.phpdoc.PHPDocMethodReturnTypeEvaluator;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.typeinference.goals.ClassVariableDeclarationGoal;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.typeinference.goals.ConstantDeclarationGoal;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.typeinference.goals.ForeachStatementGoal;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.typeinference.goals.GlobalVariableReferencesGoal;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.typeinference.goals.MethodElementReturnTypeGoal;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.typeinference.goals.phpdoc.PHPDocClassVariableGoal;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.typeinference.goals.phpdoc.PHPDocMethodReturnTypeGoal;

public class DefaultPHPGoalEvaluatorFactory implements IGoalEvaluatorFactory {

    @Override
    public GoalEvaluator createEvaluator(IGoal goal) {

        final Class<?> goalClass = goal.getClass();

        if (goalClass == ExpressionTypeGoal.class) {
            final ExpressionTypeGoal exprGoal = (ExpressionTypeGoal) goal;
            return createExpressionEvaluator(exprGoal);
        }
        if (goalClass == MethodElementReturnTypeGoal.class) {
            return new MethodReturnTypeEvaluator(goal);
        }
        if (goalClass == PHPDocMethodReturnTypeGoal.class) {
            return new PHPDocMethodReturnTypeEvaluator(goal);
        }
        if (goalClass == GlobalVariableReferencesGoal.class) {
            return new GlobalVariableReferencesEvaluator(goal);
        }
        if (goalClass == ClassVariableDeclarationGoal.class) {
            return new ClassVariableDeclarationEvaluator(goal);
        }
        if (goalClass == PHPDocClassVariableGoal.class) {
            return new PHPDocClassVariableEvaluator(goal);
        }
        if (goalClass == ConstantDeclarationGoal.class) {
            return new ConstantDeclarationEvaluator(goal);
        }
        if (goalClass == ForeachStatementGoal.class) {
            return new ForeachStatementEvaluator(goal);
        }
        return null;
    }

    private GoalEvaluator createExpressionEvaluator(ExpressionTypeGoal exprGoal) {

        final ASTNode expression = exprGoal.getExpression();
        final Class<?> expressionClass = expression.getClass();

        if (expressionClass == InterfaceDeclaration.class
                || expressionClass == ClassDeclaration.class) {
            return new PHPClassEvaluator(exprGoal, (TypeDeclaration) expression);
        }
        if (expressionClass == Assignment.class) {
            return new AssignmentEvaluator(exprGoal);
        }
        if (expressionClass == Scalar.class) {
            final Scalar scalar = (Scalar) expression;
            return new ScalarEvaluator(exprGoal, scalar);
        }
        if (expressionClass == TypeReference.class
                || expressionClass == FullyQualifiedReference.class) {
            final TypeReference type = (TypeReference) expression;
            return new TypeReferenceEvaluator(exprGoal, type);
        }
        if (expressionClass == PHPCallExpression.class
                || expressionClass == StaticMethodInvocation.class) {
            return new MethodCallTypeEvaluator(exprGoal);
        }
        if (expressionClass == ClassInstanceCreation.class) {
            return new InstanceCreationEvaluator(exprGoal);
        }
        if (expressionClass == InfixExpression.class) {
            return new InfixExpressionEvaluator(exprGoal);
        }
        if (expressionClass == PrefixExpression.class) {
            return new PrefixExpressionEvaluator(exprGoal);
        }
        if (expressionClass == PostfixExpression.class) {
            return new PostfixExpressionEvaluator(exprGoal);
        }
        if (expressionClass == UnaryOperation.class) {
            return new UnaryOperationEvaluator(exprGoal);
        }
        if (expressionClass == CastExpression.class) {
            return new CastEvaluator(exprGoal);
        }
        if (expressionClass == VariableReference.class) {
            return new VariableReferenceEvaluator(exprGoal);
        }
        if (expressionClass == BackTickExpression.class
                || expressionClass == Quote.class) {
            return new FixedAnswerEvaluator(exprGoal, new SimpleType(
                    SimpleType.TYPE_STRING));
        }
        if (expressionClass == CloneExpression.class) {
            return new CloneEvaluator(exprGoal);
        }
        if (expressionClass == InstanceOfExpression.class) {
            return new FixedAnswerEvaluator(exprGoal, new SimpleType(
                    SimpleType.TYPE_BOOLEAN));
        }
        if (expressionClass == ConditionalExpression.class) {
            return new ConditionalExpressionEvaluator(exprGoal);
        }
        if (expressionClass == ArrayCreation.class) {
            return new ArrayCreationEvaluator(exprGoal);
        }
        if (expressionClass == ArrayVariableReference.class) {
            return new ArrayVariableReferenceEvaluator(exprGoal);
        }
        if (expressionClass == FieldAccess.class
                || expressionClass == StaticFieldAccess.class) {
            return new FieldAccessEvaluator(exprGoal);
        }
        if (expressionClass == StaticConstantAccess.class) {
            return new StaticConstantAccessEvaluator(exprGoal);
        }
        if (expressionClass == FormalParameter.class
                || expressionClass == FormalParameterByReference.class) {
            return new FormalParameterEvaluator(exprGoal);
        }
        if (expressionClass == CatchClause.class) {
            return new CatchClauseEvaluator(exprGoal);
        }

        return null;
    }

}
