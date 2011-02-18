package org.zikula.modulestudio.generator.beautifier.pdt.internal.core.project;

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
 * Based on package org.eclipse.php.internal.core.project;
 * 
 *******************************************************************************/

import org.eclipse.core.resources.IProject;
import org.eclipse.dltk.core.IModelElement;
import org.eclipse.dltk.core.IScriptProject;

public class ProjectOptions {

    private ProjectOptions() {
    }

    private static IProject getProject(IModelElement modelElement) {
        final IScriptProject scriptProject = modelElement.getScriptProject();
        if (scriptProject != null) {
            return scriptProject.getProject();
        }
        return null;
    }
}
