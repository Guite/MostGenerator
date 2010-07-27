package org.zikula.modulestudio.generator.beautifier.pdt.internal.core.typeinference.goals.phpdoc;

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
 * Based on package org.eclipse.php.internal.core.typeinference.goals.phpdoc;
 * 
 *******************************************************************************/

import org.eclipse.dltk.core.IType;
import org.eclipse.dltk.ti.IContext;
import org.eclipse.dltk.ti.types.IEvaluatedType;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.typeinference.goals.AbstractMethodReturnTypeGoal;

public class PHPDocMethodReturnTypeGoal extends AbstractMethodReturnTypeGoal {

    public PHPDocMethodReturnTypeGoal(IContext context,
            IEvaluatedType evaluatedType, String methodName) {
        super(context, evaluatedType, methodName);
    }

    public PHPDocMethodReturnTypeGoal(IContext context, IType[] types,
            String methodName) {
        super(context, types, methodName);
    }

    @Override
    public boolean equals(Object obj) {
        if (!(obj instanceof PHPDocMethodReturnTypeGoal)) {
            return false;
        }
        return super.equals(obj);
    }
}
