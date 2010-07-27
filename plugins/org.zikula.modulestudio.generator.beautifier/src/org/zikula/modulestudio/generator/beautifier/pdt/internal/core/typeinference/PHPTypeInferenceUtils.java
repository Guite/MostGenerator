package org.zikula.modulestudio.generator.beautifier.pdt.internal.core.typeinference;

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
 * Based on package org.eclipse.php.internal.core.typeinference;
 * 
 *******************************************************************************/

import java.util.Arrays;
import java.util.Collection;
import java.util.LinkedHashSet;
import java.util.LinkedList;
import java.util.List;
import java.util.Set;

import org.eclipse.dltk.ast.ASTNode;
import org.eclipse.dltk.ast.declarations.ModuleDeclaration;
import org.eclipse.dltk.core.DLTKCore;
import org.eclipse.dltk.core.IScriptProject;
import org.eclipse.dltk.core.ISourceModule;
import org.eclipse.dltk.core.IType;
import org.eclipse.dltk.core.ModelException;
import org.eclipse.dltk.core.SourceParserUtil;
import org.eclipse.dltk.evaluation.types.AmbiguousType;
import org.eclipse.dltk.evaluation.types.ModelClassType;
import org.eclipse.dltk.evaluation.types.MultiTypeType;
import org.eclipse.dltk.evaluation.types.UnknownType;
import org.eclipse.dltk.internal.core.ScriptProject;
import org.eclipse.dltk.ti.IContext;
import org.eclipse.dltk.ti.ISourceModuleContext;
import org.eclipse.dltk.ti.goals.ExpressionTypeGoal;
import org.eclipse.dltk.ti.types.IEvaluatedType;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.compiler.ast.parser.ASTUtils;

public class PHPTypeInferenceUtils {

    public static IEvaluatedType combineMultiType(
            Collection<IEvaluatedType> evaluatedTypes) {
        final MultiTypeType multiTypeType = new MultiTypeType();
        for (IEvaluatedType type : evaluatedTypes) {
            if (type == null) {
                type = PHPSimpleTypes.NULL;
            }
            multiTypeType.addType(type);
        }
        return multiTypeType;
    }

    private static Collection<IEvaluatedType> resolveAmbiguousTypes(
            Collection<IEvaluatedType> evaluatedTypes) {
        final List<IEvaluatedType> resolved = new LinkedList<IEvaluatedType>();
        for (final IEvaluatedType type : evaluatedTypes) {
            if (type instanceof AmbiguousType) {
                final AmbiguousType ambType = (AmbiguousType) type;
                resolved.addAll(resolveAmbiguousTypes(Arrays.asList(ambType
                        .getPossibleTypes())));
            }
            else {
                resolved.add(type);
            }
        }
        return resolved;
    }

    public static IEvaluatedType combineTypes(
            Collection<IEvaluatedType> evaluatedTypes) {
        final Set<IEvaluatedType> types = new LinkedHashSet<IEvaluatedType>(
                resolveAmbiguousTypes(evaluatedTypes));
        if (types.contains(null)) {
            types.remove(null);
            types.add(PHPSimpleTypes.NULL);
        }
        if (types.size() == 0) {
            return UnknownType.INSTANCE;
        }
        if (types.size() == 1) {
            return types.iterator().next();
        }
        return new AmbiguousType(
                types.toArray(new IEvaluatedType[types.size()]));
    }

    public static IEvaluatedType resolveExpression(ISourceModule sourceModule,
            ASTNode expression) {
        final ModuleDeclaration moduleDeclaration = SourceParserUtil
                .getModuleDeclaration(sourceModule);
        final IContext context = ASTUtils.findContext(sourceModule,
                moduleDeclaration, expression);
        return resolveExpression(sourceModule, moduleDeclaration, context,
                expression);
    }

    public static IEvaluatedType resolveExpression(ISourceModule sourceModule,
            ModuleDeclaration moduleDeclaration, IContext context,
            ASTNode expression) {
        if (context != null) {
            final PHPTypeInferencer typeInferencer = new PHPTypeInferencer();
            return typeInferencer.evaluateType(new ExpressionTypeGoal(context,
                    expression));
        }
        return null;
    }

    /**
     * Converts IEvaluatedType to IType, if found. This method filters elements
     * using file network dependencies.
     * 
     * @param evaluatedType
     *            Evaluated type
     * @param context
     * @return model elements or <code>null</code> in case no element could be
     *         found
     */
    public static IType[] getModelElements(IEvaluatedType evaluatedType,
            ISourceModuleContext context) {
        return PHPTypeInferenceUtils.getModelElements(evaluatedType, context,
                0, null);
    }

    /**
     * Converts IEvaluatedType to IType, if found. This method filters elements
     * using file network dependencies.
     * 
     * @param evaluatedType
     *            Evaluated type
     * @param context
     * @param cache
     * @return model elements or <code>null</code> in case no element could be
     *         found
     */
    public static IType[] getModelElements(IEvaluatedType evaluatedType,
            ISourceModuleContext context, IModelAccessCache cache) {
        return PHPTypeInferenceUtils.getModelElements(evaluatedType, context,
                0, cache);
    }

    /**
     * Converts IEvaluatedType to IType, if found. This method filters elements
     * using file network dependencies.
     * 
     * @param evaluatedType
     *            Evaluated type
     * @param context
     * @param offset
     * @return model elements or <code>null</code> in case no element could be
     *         found
     */
    public static IType[] getModelElements(IEvaluatedType evaluatedType,
            ISourceModuleContext context, int offset) {
        return internalGetModelElements(evaluatedType, context, offset, null);
    }

    /**
     * Converts IEvaluatedType to IType, if found. This method filters elements
     * using file network dependencies.
     * 
     * @param evaluatedType
     *            Evaluated type
     * @param context
     * @param offset
     * @param cache
     * @return model elements or <code>null</code> in case no element could be
     *         found
     */
    public static IType[] getModelElements(IEvaluatedType evaluatedType,
            ISourceModuleContext context, int offset, IModelAccessCache cache) {
        return internalGetModelElements(evaluatedType, context, offset, cache);
    }

    private static IType[] internalGetModelElements(
            IEvaluatedType evaluatedType, ISourceModuleContext context,
            int offset, IModelAccessCache cache) {
        final ISourceModule sourceModule = context.getSourceModule();

        if (evaluatedType instanceof ModelClassType) {
            return new IType[] { ((ModelClassType) evaluatedType)
                    .getTypeDeclaration() };
        }
        if (evaluatedType instanceof PHPClassType) {
            final IScriptProject scriptProject = sourceModule
                    .getScriptProject();
            if (!ScriptProject.hasScriptNature(scriptProject.getProject())) {
                final List<IType> result = new LinkedList<IType>();
                try {
                    final IType[] types = sourceModule.getTypes();
                    for (final IType t : types) {
                        if (t.getElementName().equalsIgnoreCase(
                                evaluatedType.getTypeName())) {
                            result.add(t);
                            break;
                        }
                    }
                } catch (final ModelException e) {
                    if (DLTKCore.DEBUG) {
                        e.printStackTrace();
                    }
                }
                return result.toArray(new IType[result.size()]);
            }
            try {
                return PHPModelUtils.getTypes(evaluatedType.getTypeName(),
                        sourceModule, offset, cache, null);
            } catch (final ModelException e) {
                if (DLTKCore.DEBUG) {
                    e.printStackTrace();
                }
            }
        }
        else if (evaluatedType instanceof AmbiguousType) {
            final List<IType> tmpList = new LinkedList<IType>();
            final IEvaluatedType[] possibleTypes = ((AmbiguousType) evaluatedType)
                    .getPossibleTypes();
            for (final IEvaluatedType possibleType : possibleTypes) {
                final IType[] tmpArray = internalGetModelElements(possibleType,
                        context, offset, cache);
                if (tmpArray != null) {
                    tmpList.addAll(Arrays.asList(tmpArray));
                }
            }
            // the elements are filtered already
            return tmpList.toArray(new IType[tmpList.size()]);
        }

        return null;
    }
}
