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

import org.eclipse.dltk.ast.declarations.MethodDeclaration;
import org.eclipse.dltk.evaluation.types.SimpleType;
import org.eclipse.dltk.ti.IContext;
import org.eclipse.dltk.ti.goals.FixedAnswerEvaluator;
import org.eclipse.dltk.ti.goals.IGoal;
import org.eclipse.dltk.ti.types.IEvaluatedType;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.compiler.ast.nodes.Scalar;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.typeinference.PHPClassType;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.typeinference.PHPSimpleTypes;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.typeinference.context.MethodContext;

public class ScalarEvaluator extends FixedAnswerEvaluator {

    public ScalarEvaluator(IGoal goal, Scalar scalar) {
        super(goal, evaluateScalar(goal, scalar));
    }

    @SuppressWarnings("fallthrough")
    private static Object evaluateScalar(IGoal goal, Scalar scalar) {
        final int scalarType = scalar.getScalarType();

        int simpleType = SimpleType.TYPE_NONE;
        switch (scalarType) {
            case Scalar.TYPE_INT:
            case Scalar.TYPE_REAL:
                simpleType = SimpleType.TYPE_NUMBER;
                break;
            case Scalar.TYPE_STRING:
                if ("null".equalsIgnoreCase(scalar.getValue())) { //$NON-NLS-1$
                    simpleType = SimpleType.TYPE_NULL;
                    break;
                }
                // checking specific case for "return $this;" statement
                if ("this".equalsIgnoreCase(scalar.getValue())) { //$NON-NLS-1$
                    final IContext context = goal.getContext();
                    if (context instanceof MethodContext) {
                        final MethodDeclaration methodNode = ((MethodContext) context)
                                .getMethodNode();
                        if (methodNode != null) {
                            final String declaringTypeName = methodNode
                                    .getDeclaringTypeName();
                            if (declaringTypeName != null) {
                                final IEvaluatedType resolved = PHPSimpleTypes
                                        .fromString(declaringTypeName);
                                if (resolved == null) {
                                    return new PHPClassType(declaringTypeName);
                                }
                            }
                        }
                    }
                }

            case Scalar.TYPE_SYSTEM:
                final String value = scalar.getValue();
                if ("true".equalsIgnoreCase(value) //$NON-NLS-1$
                        || "false".equalsIgnoreCase(value)) { //$NON-NLS-1$
                    simpleType = SimpleType.TYPE_BOOLEAN;
                }
                else {
                    simpleType = SimpleType.TYPE_STRING;
                }
                break;
        }
        return new SimpleType(simpleType);
    }
}
