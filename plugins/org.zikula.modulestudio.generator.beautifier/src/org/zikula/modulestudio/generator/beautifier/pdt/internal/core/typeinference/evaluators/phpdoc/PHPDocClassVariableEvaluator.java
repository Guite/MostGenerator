package org.zikula.modulestudio.generator.beautifier.pdt.internal.core.typeinference.evaluators.phpdoc;

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
 * Based on package
 * org.eclipse.php.internal.core.typeinference.evaluators.phpdoc;
 * 
 *******************************************************************************/

import java.util.HashSet;
import java.util.LinkedList;
import java.util.List;
import java.util.Set;

import org.eclipse.dltk.ast.references.SimpleReference;
import org.eclipse.dltk.core.DLTKCore;
import org.eclipse.dltk.core.IField;
import org.eclipse.dltk.core.IType;
import org.eclipse.dltk.core.ITypeHierarchy;
import org.eclipse.dltk.core.ModelException;
import org.eclipse.dltk.ti.GoalState;
import org.eclipse.dltk.ti.goals.IGoal;
import org.eclipse.dltk.ti.types.IEvaluatedType;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.compiler.ast.nodes.PHPDocBlock;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.compiler.ast.nodes.PHPDocTag;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.typeinference.PHPClassType;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.typeinference.PHPModelUtils;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.typeinference.PHPTypeInferenceUtils;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.typeinference.context.TypeContext;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.typeinference.evaluators.AbstractPHPGoalEvaluator;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.typeinference.goals.phpdoc.PHPDocClassVariableGoal;

/**
 * This evaluator finds class field declartion either using "var" or in method
 * body using field access.
 */
public class PHPDocClassVariableEvaluator extends AbstractPHPGoalEvaluator {

    private final List<IEvaluatedType> evaluated = new LinkedList<IEvaluatedType>();

    public PHPDocClassVariableEvaluator(IGoal goal) {
        super(goal);
    }

    @Override
    public IGoal[] init() {
        final PHPDocClassVariableGoal typedGoal = (PHPDocClassVariableGoal) goal;
        final TypeContext context = (TypeContext) typedGoal.getContext();
        final String variableName = typedGoal.getVariableName();

        final IType[] types = PHPTypeInferenceUtils.getModelElements(
                context.getInstanceType(), context);
        final Set<PHPDocBlock> docs = new HashSet<PHPDocBlock>();

        if (types != null) {
            for (final IType type : types) {
                try {
                    // we look in whole hiearchy
                    final ITypeHierarchy superHierarchy = type
                            .newSupertypeHierarchy(null);
                    final IType[] superTypes = superHierarchy.getAllTypes();
                    for (final IType superType : superTypes) {
                        final IField[] typeField = PHPModelUtils.getTypeField(
                                superType, variableName, true);
                        if (typeField.length > 0) {
                            final PHPDocBlock docBlock = PHPModelUtils
                                    .getDocBlock(typeField[0]);
                            if (docBlock != null) {
                                docs.add(docBlock);
                            }
                        }
                    }
                } catch (final ModelException e) {
                    if (DLTKCore.DEBUG) {
                        e.printStackTrace();
                    }
                }
            }
        }

        for (final PHPDocBlock doc : docs) {
            for (final PHPDocTag tag : doc.getTags()) {
                if (tag.getTagKind() == PHPDocTag.VAR) {
                    final SimpleReference[] references = tag.getReferences();
                    for (final SimpleReference ref : references) {
                        final IEvaluatedType type = PHPClassType
                                .fromSimpleReference(ref);
                        evaluated.add(type);
                    }
                }
            }
        }

        return IGoal.NO_GOALS;
    }

    @Override
    public Object produceResult() {
        return PHPTypeInferenceUtils.combineTypes(evaluated);
    }

    @Override
    public IGoal[] subGoalDone(IGoal subgoal, Object result, GoalState state) {
        if (state != GoalState.RECURSIVE && result != null) {
            evaluated.add((IEvaluatedType) result);
        }
        return IGoal.NO_GOALS;
    }
}
