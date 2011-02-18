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

import org.eclipse.dltk.evaluation.types.SimpleType;
import org.eclipse.dltk.ti.GoalState;
import org.eclipse.dltk.ti.goals.ExpressionTypeGoal;
import org.eclipse.dltk.ti.goals.GoalEvaluator;
import org.eclipse.dltk.ti.goals.IGoal;
import org.eclipse.dltk.ti.types.IEvaluatedType;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.compiler.ast.nodes.CastExpression;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.typeinference.PHPClassType;

public class CastEvaluator extends GoalEvaluator {

    private IEvaluatedType result;

    public CastEvaluator(IGoal goal) {
        super(goal);
    }

    @Override
    public IGoal[] init() {
        final ExpressionTypeGoal typedGoal = (ExpressionTypeGoal) goal;
        final CastExpression castExpression = (CastExpression) typedGoal
                .getExpression();
        final int operator = castExpression.getCastType();
        switch (operator) {
            case CastExpression.TYPE_INT:
            case CastExpression.TYPE_REAL:
                result = new SimpleType(SimpleType.TYPE_NUMBER);
                break;
            case CastExpression.TYPE_STRING:
                result = new SimpleType(SimpleType.TYPE_STRING);
                break;
            case CastExpression.TYPE_ARRAY:
                result = new SimpleType(SimpleType.TYPE_ARRAY);
                break;
            case CastExpression.TYPE_OBJECT:
                return new IGoal[] { new ExpressionTypeGoal(
                        typedGoal.getContext(), castExpression.getExpr()) };
            case CastExpression.TYPE_BOOL:
                result = new SimpleType(SimpleType.TYPE_BOOLEAN);
                break;
            case CastExpression.TYPE_UNSET:
                result = new SimpleType(SimpleType.TYPE_NULL);
                break;
            default:
                throw new IllegalArgumentException();
        }
        return IGoal.NO_GOALS;
    }

    @Override
    public IGoal[] subGoalDone(IGoal subgoal, Object result, GoalState state) {
        if (result instanceof PHPClassType) {
            this.result = (PHPClassType) result;
        }
        else {
            this.result = new PHPClassType("StdClass");
        }
        return IGoal.NO_GOALS;
    }

    @Override
    public Object produceResult() {
        return result;
    }
}
