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

import java.util.LinkedList;
import java.util.List;
import java.util.regex.Pattern;

import org.eclipse.dltk.ast.references.SimpleReference;
import org.eclipse.dltk.core.IMethod;
import org.eclipse.dltk.core.IType;
import org.eclipse.dltk.ti.GoalState;
import org.eclipse.dltk.ti.goals.IGoal;
import org.eclipse.dltk.ti.types.IEvaluatedType;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.compiler.ast.nodes.NamespaceReference;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.compiler.ast.nodes.PHPDocBlock;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.compiler.ast.nodes.PHPDocTag;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.typeinference.PHPClassType;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.typeinference.PHPModelUtils;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.typeinference.PHPSimpleTypes;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.typeinference.PHPTypeInferenceUtils;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.typeinference.evaluators.AbstractMethodReturnTypeEvaluator;

/**
 * This Evaluator process the phpdoc of a method to determine its returned
 * type(s)
 * 
 * @see the PHPCodumentor spec at {@link http
 *      ://manual.phpdoc.org/HTMLSmartyConverter
 *      /HandS/phpDocumentor/tutorial_tags.return.pkg.html}
 */
public class PHPDocMethodReturnTypeEvaluator extends
        AbstractMethodReturnTypeEvaluator {

    /**
     * Used for splitting the data types list of the returned tag
     */
    private final static Pattern PIPE_PATTERN = Pattern.compile("\\|");

    /**
     * Holds the result of evaluated types that this evaluator resolved
     */
    private final List<IEvaluatedType> evaluated = new LinkedList<IEvaluatedType>();

    public PHPDocMethodReturnTypeEvaluator(IGoal goal) {
        super(goal);
    }

    @SuppressWarnings("null")
    @Override
    public IGoal[] init() {
        for (final IMethod method : getMethods()) {
            final PHPDocBlock docBlock = PHPModelUtils.getDocBlock(method);
            if (docBlock != null) {
                final IType currentNamespace = PHPModelUtils
                        .getCurrentNamespace(method);
                for (final PHPDocTag tag : docBlock.getTags()) {
                    if (tag.getTagKind() == PHPDocTag.RETURN) {
                        // @return datatype1|datatype2|...
                        for (final SimpleReference reference : tag
                                .getReferences()) {
                            final String[] typesNames = PIPE_PATTERN
                                    .split(reference.getName());
                            for (final String typeName : typesNames) {
                                IEvaluatedType type = PHPSimpleTypes
                                        .fromString(typeName);
                                if (type == null) {
                                    if (typeName
                                            .indexOf(NamespaceReference.NAMESPACE_SEPARATOR) != -1
                                            || currentNamespace == null) {
                                        type = new PHPClassType(typeName);
                                    }
                                    else if (currentNamespace != null) {
                                        type = new PHPClassType(
                                                currentNamespace
                                                        .getElementName(),
                                                typeName);
                                    }
                                }
                                if (type != null) {
                                    evaluated.add(type);
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
        return PHPTypeInferenceUtils.combineTypes(evaluated);
    }

    @Override
    public IGoal[] subGoalDone(IGoal subgoal, Object result, GoalState state) {
        return IGoal.NO_GOALS;
    }

}
