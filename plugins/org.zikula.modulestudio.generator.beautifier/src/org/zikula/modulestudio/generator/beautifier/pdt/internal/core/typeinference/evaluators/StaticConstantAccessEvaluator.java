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

import org.eclipse.dltk.ast.expressions.Expression;
import org.eclipse.dltk.ast.references.TypeReference;
import org.eclipse.dltk.evaluation.types.SimpleType;
import org.eclipse.dltk.evaluation.types.UnknownType;
import org.eclipse.dltk.ti.GoalState;
import org.eclipse.dltk.ti.goals.ExpressionTypeGoal;
import org.eclipse.dltk.ti.goals.GoalEvaluator;
import org.eclipse.dltk.ti.goals.IGoal;
import org.eclipse.dltk.ti.types.IEvaluatedType;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.compiler.ast.nodes.StaticConstantAccess;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.typeinference.goals.ConstantDeclarationGoal;

public class StaticConstantAccessEvaluator extends GoalEvaluator {

    private IEvaluatedType evaluatedType;

    public StaticConstantAccessEvaluator(IGoal goal) {
        super(goal);
    }

    @Override
    public IGoal[] init() {
        final ExpressionTypeGoal typedGoal = (ExpressionTypeGoal) goal;
        final StaticConstantAccess expr = (StaticConstantAccess) typedGoal
                .getExpression();

        final Expression dispatcher = expr.getDispatcher();
        if (dispatcher instanceof TypeReference) {
            final TypeReference typeReference = (TypeReference) dispatcher;
            return new IGoal[] { new ConstantDeclarationGoal(goal.getContext(),
                    expr.getConstant().getName(), typeReference.getName()) };
        }
        return IGoal.NO_GOALS;
    }

    @Override
    public Object produceResult() {
        return evaluatedType;
    }

    @Override
    public IGoal[] subGoalDone(IGoal subgoal, Object result, GoalState state) {
        if (state == GoalState.PRUNED || result == null
                || result == UnknownType.INSTANCE) {
            evaluatedType = new SimpleType(SimpleType.TYPE_STRING);
        }
        else {
            evaluatedType = (IEvaluatedType) result;
        }
        return IGoal.NO_GOALS;
    }

}
