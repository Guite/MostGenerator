package org.zikula.modulestudio.generator.beautifier.pdt.internal.core.typeinference.context;

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
 * Based on package org.eclipse.php.internal.core.typeinference.context;
 * 
 *******************************************************************************/

import org.eclipse.dltk.ast.declarations.MethodDeclaration;
import org.eclipse.dltk.ast.declarations.ModuleDeclaration;
import org.eclipse.dltk.core.DLTKLanguageManager;
import org.eclipse.dltk.core.IDLTKLanguageToolkit;
import org.eclipse.dltk.core.ISourceModule;
import org.eclipse.dltk.ti.IContext;
import org.eclipse.dltk.ti.IInstanceContext;
import org.eclipse.dltk.ti.ISourceModuleContext;
import org.eclipse.dltk.ti.types.IEvaluatedType;

/**
 * This is a PHP method or function context.
 * 
 * @author michael
 */
public class MethodContext implements IContext, INamespaceContext,
        IArgumentsContext, IInstanceContext, ISourceModuleContext {

    private final ISourceModule sourceModule;
    private final ModuleDeclaration rootNode;
    private final MethodDeclaration methodNode;
    private final String[] argNames;
    private final IEvaluatedType[] argTypes;
    private IEvaluatedType instanceType;
    private String namespaceName;

    public MethodContext(IContext parent, ISourceModule sourceModule,
            ModuleDeclaration rootNode, MethodDeclaration methodNode,
            String[] argNames, IEvaluatedType[] argTypes) {
        this.sourceModule = sourceModule;
        this.rootNode = rootNode;
        this.methodNode = methodNode;
        this.argNames = argNames;
        this.argTypes = argTypes;

        if (parent instanceof IInstanceContext) {
            instanceType = ((IInstanceContext) parent).getInstanceType();
        }
        if (parent instanceof INamespaceContext) {
            namespaceName = ((INamespaceContext) parent).getNamespace();
        }
    }

    @Override
    public IEvaluatedType getArgumentType(String name) {
        for (int i = 0; i < argNames.length; i++) {
            final String argName = argNames[i];
            if (name.equals(argName)) {
                if (i < argTypes.length) {
                    return argTypes[i];
                }
                return null;
            }
        }
        return null;
    }

    /**
     * Returns {@link IEvaluatedType} for the declaring type or
     * <code>null</code> if this is a function context
     */
    @Override
    public IEvaluatedType getInstanceType() {
        return instanceType;
    }

    /**
     * Returns namespace where the method was declared or <code>null</code> if
     * this is a global scope method/function
     */
    @Override
    public String getNamespace() {
        return namespaceName;
    }

    /**
     * Returns root AST node of the file where the method is declared
     */
    @Override
    public ModuleDeclaration getRootNode() {
        return rootNode;
    }

    /**
     * Returns the file {@link ISourceModule} where the method is declared
     */
    @Override
    public ISourceModule getSourceModule() {
        return sourceModule;
    }

    /**
     * Returns AST node of the method declaration
     */
    public MethodDeclaration getMethodNode() {
        return methodNode;
    }

    @Override
    public String getLangNature() {
        if (sourceModule != null) {
            final IDLTKLanguageToolkit languageToolkit = DLTKLanguageManager
                    .getLanguageToolkit(sourceModule);
            if (languageToolkit != null) {
                return languageToolkit.getNatureId();
            }
        }
        return null;
    }

    @Override
    public int hashCode() {
        final int prime = 31;
        int result = 1;
        result = prime * result
                + ((instanceType == null) ? 0 : instanceType.hashCode());
        result = prime * result
                + ((methodNode == null) ? 0 : methodNode.hashCode());
        result = prime * result
                + ((namespaceName == null) ? 0 : namespaceName.hashCode());
        result = prime * result
                + ((sourceModule == null) ? 0 : sourceModule.hashCode());
        return result;
    }

    @Override
    public boolean equals(Object obj) {
        if (this == obj) {
            return true;
        }
        if (obj == null) {
            return false;
        }
        if (getClass() != obj.getClass()) {
            return false;
        }
        final MethodContext other = (MethodContext) obj;
        if (instanceType == null) {
            if (other.instanceType != null) {
                return false;
            }
        }
        else if (!instanceType.equals(other.instanceType)) {
            return false;
        }
        if (methodNode == null) {
            if (other.methodNode != null) {
                return false;
            }
        }
        else if (!methodNode.equals(other.methodNode)) {
            return false;
        }
        if (namespaceName == null) {
            if (other.namespaceName != null) {
                return false;
            }
        }
        else if (!namespaceName.equals(other.namespaceName)) {
            return false;
        }
        if (sourceModule == null) {
            if (other.sourceModule != null) {
                return false;
            }
        }
        else if (!sourceModule.equals(other.sourceModule)) {
            return false;
        }
        return true;
    }
}
