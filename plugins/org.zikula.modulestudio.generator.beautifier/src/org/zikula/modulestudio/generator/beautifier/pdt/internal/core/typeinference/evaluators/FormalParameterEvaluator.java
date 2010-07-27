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

import org.eclipse.dltk.ast.references.SimpleReference;
import org.eclipse.dltk.ti.GoalState;
import org.eclipse.dltk.ti.IContext;
import org.eclipse.dltk.ti.goals.ExpressionTypeGoal;
import org.eclipse.dltk.ti.goals.GoalEvaluator;
import org.eclipse.dltk.ti.goals.IGoal;
import org.eclipse.dltk.ti.types.IEvaluatedType;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.compiler.ast.nodes.FormalParameter;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.compiler.ast.nodes.PHPDocBlock;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.compiler.ast.nodes.PHPDocTag;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.compiler.ast.nodes.PHPMethodDeclaration;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.typeinference.PHPClassType;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.typeinference.context.MethodContext;

public class FormalParameterEvaluator extends GoalEvaluator {

    private IEvaluatedType result;

    public FormalParameterEvaluator(IGoal goal) {
        super(goal);
    }

    @Override
    public IGoal[] init() {
        final ExpressionTypeGoal typedGoal = (ExpressionTypeGoal) goal;
        final FormalParameter parameter = (FormalParameter) typedGoal
                .getExpression();

        final SimpleReference type = parameter.getParameterType();
        if (type != null) {
            result = PHPClassType.fromSimpleReference(type);
        }
        else {
            final IContext context = typedGoal.getContext();
            if (context instanceof MethodContext) {
                final MethodContext methodContext = (MethodContext) context;
                final PHPMethodDeclaration methodDeclaration = (PHPMethodDeclaration) methodContext
                        .getMethodNode();
                final PHPDocBlock docBlock = methodDeclaration.getPHPDoc();
                if (docBlock != null) {
                    for (final PHPDocTag tag : docBlock.getTags()) {
                        if (tag.getTagKind() == PHPDocTag.PARAM) {
                            final SimpleReference[] references = tag
                                    .getReferences();
                            if (references.length == 2) {
                                if (references[0].getName().equals(
                                        parameter.getName())) {
                                    result = PHPClassType
                                            .fromSimpleReference(references[1]);
                                }
                            }
                        }
                    }
                }
            }
        }
        return IGoal.NO_GOALS;
    }

    @Override
    public Object produceResult() {
        return result;
    }

    @Override
    public IGoal[] subGoalDone(IGoal subgoal, Object result, GoalState state) {
        return IGoal.NO_GOALS;
    }

}
