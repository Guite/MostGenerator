package org.zikula.modulestudio.generator.beautifier.pdt.internal.core.ast.nodes;

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
 * Based on package org.eclipse.php.internal.core.ast.nodes;
 * 
 *******************************************************************************/

import java.util.ArrayList;
import java.util.List;

import org.eclipse.dltk.ast.Modifiers;
import org.eclipse.dltk.ast.references.SimpleReference;
import org.eclipse.dltk.core.DLTKCore;
import org.eclipse.dltk.core.IMethod;
import org.eclipse.dltk.core.IModelElement;
import org.eclipse.dltk.core.ISourceModule;
import org.eclipse.dltk.core.ModelException;
import org.eclipse.dltk.ti.types.IEvaluatedType;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.compiler.ast.nodes.PHPDocBlock;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.compiler.ast.nodes.PHPDocTag;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.typeinference.BindingUtility;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.typeinference.PHPModelUtils;

/**
 * A PHP function binding. This class is also the base class for the
 * {@link MethodBinding} implementation.
 * 
 * @author shalom
 */
public class FunctionBinding implements IFunctionBinding {

    protected static final int VALID_MODIFIERS = Modifiers.AccPublic
            | Modifiers.AccProtected | Modifiers.AccPrivate
            | Modifiers.AccDefault | Modifiers.AccStatic | Modifiers.AccFinal
            | Modifiers.AccAbstract;
    protected BindingResolver resolver;
    protected IMethod modelElement;

    /**
     * Constructs a new FunctionBinding.
     * 
     * @param resolver
     *            A {@link BindingResolver}.
     * @param modelElement
     *            An {@link IMethod}.
     */
    public FunctionBinding(BindingResolver resolver, IMethod modelElement) {
        this.resolver = resolver;
        this.modelElement = modelElement;
    }

    /*
     * (non-Javadoc)
     * @see
     * org.eclipse.php.internal.core.ast.nodes.IFunctionBinding#getExceptionTypes
     * ()
     */
    @Override
    public ITypeBinding[] getExceptionTypes() {
        // Get an array of PHPDocFields
        final ArrayList<ITypeBinding> exeptions = new ArrayList<ITypeBinding>();
        final PHPDocBlock docBlock = PHPModelUtils.getDocBlock(modelElement);
        final PHPDocTag[] docTags = docBlock.getTags();
        for (final PHPDocTag tag : docTags) {
            if (tag.getTagKind() == PHPDocTag.THROWS) {
                final SimpleReference[] references = tag.getReferences();
                // TODO - create ITypeBinding array from this SimpleReference
                // array
            }
        }
        return null;
    }

    /*
     * (non-Javadoc)
     * @see org.eclipse.php.internal.core.ast.nodes.IFunctionBinding#getName()
     */
    @Override
    public String getName() {
        return modelElement.getElementName();
    }

    /*
     * (non-Javadoc)
     * @see
     * org.eclipse.php.internal.core.ast.nodes.IFunctionBinding#getParameterTypes
     * ()
     */
    @Override
    public ITypeBinding[] getParameterTypes() {
        // TODO - Create the parameters types according to the defined types in
        // the function declaration
        // and in its DocBlock.
        return null;
    }

    /*
     * (non-Javadoc)
     * @see
     * org.eclipse.php.internal.core.ast.nodes.IFunctionBinding#getReturnType()
     */
    @Override
    public ITypeBinding[] getReturnType() {
        final List<ITypeBinding> result = new ArrayList<ITypeBinding>();
        final ISourceModule sourceModule = modelElement.getSourceModule();

        final BindingUtility bindingUtility = new BindingUtility(sourceModule);
        final IEvaluatedType[] evaluatedFunctionReturnTypes = bindingUtility
                .getFunctionReturnType(modelElement);
        for (final IEvaluatedType currentEvaluatedType : evaluatedFunctionReturnTypes) {
            final ITypeBinding typeBinding = this.resolver.getTypeBinding(
                    currentEvaluatedType, sourceModule);
            result.add(typeBinding);
        }
        return result.toArray(new ITypeBinding[result.size()]);
    }

    /*
     * (non-Javadoc)
     * @see org.eclipse.php.internal.core.ast.nodes.IFunctionBinding#isVarargs()
     */
    @Override
    public boolean isVarargs() {
        // TODO
        return false;
    }

    /*
     * (non-Javadoc)
     * @see org.eclipse.php.internal.core.ast.nodes.IBinding#getKey()
     */
    @Override
    public String getKey() {
        return modelElement.getHandleIdentifier();
    }

    /*
     * (non-Javadoc)
     * @see org.eclipse.php.internal.core.ast.nodes.IBinding#getKind()
     */
    @Override
    public int getKind() {
        return IBinding.METHOD;
    }

    /*
     * (non-Javadoc)
     * @see org.eclipse.php.internal.core.ast.nodes.IBinding#getModifiers()
     */
    @Override
    public int getModifiers() {
        try {
            return modelElement.getFlags() & VALID_MODIFIERS;
        } catch (final ModelException e) {
            if (DLTKCore.DEBUG) {
                e.printStackTrace();
            }
        }
        return 0;
    }

    /*
     * (non-Javadoc)
     * @see org.eclipse.php.internal.core.ast.nodes.IBinding#getPHPElement()
     */
    @Override
    public IModelElement getPHPElement() {
        return modelElement;
    }

    /*
     * (non-Javadoc)
     * @see org.eclipse.php.internal.core.ast.nodes.IBinding#isDeprecated()
     */
    @Override
    public boolean isDeprecated() {
        return false;
    }
}
