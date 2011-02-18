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

import java.util.List;

import org.eclipse.dltk.evaluation.types.AmbiguousType;
import org.eclipse.dltk.evaluation.types.MultiTypeType;
import org.eclipse.dltk.ti.GoalState;
import org.eclipse.dltk.ti.goals.ExpressionTypeGoal;
import org.eclipse.dltk.ti.goals.GoalEvaluator;
import org.eclipse.dltk.ti.goals.IGoal;
import org.eclipse.dltk.ti.types.IEvaluatedType;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.typeinference.goals.ForeachStatementGoal;

/**
 * This evaluator determines types that array expression in foreach statement
 * holds
 */
public class ForeachStatementEvaluator extends GoalEvaluator {

    private IEvaluatedType result;

    public ForeachStatementEvaluator(IGoal goal) {
        super(goal);
    }

    @Override
    public IGoal[] init() {
        final ForeachStatementGoal typedGoal = (ForeachStatementGoal) goal;
        return new IGoal[] { new ExpressionTypeGoal(goal.getContext(),
                typedGoal.getExpression()) };
    }

    @Override
    @SuppressWarnings("unchecked")
    public IGoal[] subGoalDone(IGoal subgoal, Object result, GoalState state) {
        if (result instanceof MultiTypeType) {
            final List types = ((MultiTypeType) result).getTypes();
            this.result = new AmbiguousType(
                    (IEvaluatedType[]) types.toArray(new IEvaluatedType[types
                            .size()]));
        }
        return IGoal.NO_GOALS;
    }

    @Override
    public Object produceResult() {
        return result;
    }
}
