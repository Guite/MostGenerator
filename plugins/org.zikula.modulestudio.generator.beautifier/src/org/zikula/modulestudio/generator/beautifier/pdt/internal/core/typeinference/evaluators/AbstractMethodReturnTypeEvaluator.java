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

import java.util.Arrays;
import java.util.LinkedList;
import java.util.List;

import org.eclipse.core.runtime.CoreException;
import org.eclipse.dltk.core.DLTKCore;
import org.eclipse.dltk.core.IMethod;
import org.eclipse.dltk.core.ISourceModule;
import org.eclipse.dltk.core.IType;
import org.eclipse.dltk.core.ModelException;
import org.eclipse.dltk.ti.ISourceModuleContext;
import org.eclipse.dltk.ti.goals.IGoal;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.typeinference.PHPModelUtils;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.typeinference.goals.AbstractMethodReturnTypeGoal;

public abstract class AbstractMethodReturnTypeEvaluator extends
        AbstractPHPGoalEvaluator {

    public AbstractMethodReturnTypeEvaluator(IGoal goal) {
        super(goal);
    }

    protected IMethod[] getMethods() {
        final AbstractMethodReturnTypeGoal typedGoal = (AbstractMethodReturnTypeGoal) goal;
        final ISourceModule sourceModule = ((ISourceModuleContext) goal
                .getContext()).getSourceModule();
        final IType[] types = typedGoal.getTypes();
        final String methodName = typedGoal.getMethodName();

        final List<IMethod> methods = new LinkedList<IMethod>();
        if (types == null) {
            try {
                methods.addAll(Arrays.asList(PHPModelUtils.getFunctions(
                        methodName, sourceModule, 0, null, null)));
            } catch (final ModelException e) {
                if (DLTKCore.DEBUG) {
                    e.printStackTrace();
                }
            }
        }
        else {
            try {
                for (final IType type : types) {
                    IMethod[] typeMethods = PHPModelUtils.getTypeMethod(type,
                            methodName, true);
                    if (typeMethods.length == 0) {
                        typeMethods = PHPModelUtils
                                .getSuperTypeHierarchyMethod(type, methodName,
                                        true, null);
                    }
                    if (typeMethods.length > 0) {
                        methods.add(typeMethods[0]);
                    }
                }
            } catch (final CoreException e) {
                if (DLTKCore.DEBUG) {
                    e.printStackTrace();
                }
            }
        }

        return methods.toArray(new IMethod[methods.size()]);
    }
}
