package org.zikula.modulestudio.generator.beautifier.pdt.internal.core.codeassist;

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
 * Based on package org.eclipse.php.internal.core.codeassist;
 * 
 *******************************************************************************/

import java.util.Arrays;
import java.util.LinkedHashSet;
import java.util.Set;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import org.eclipse.core.runtime.CoreException;
import org.eclipse.dltk.ast.declarations.ModuleDeclaration;
import org.eclipse.dltk.ast.references.VariableReference;
import org.eclipse.dltk.core.IMethod;
import org.eclipse.dltk.core.ISourceModule;
import org.eclipse.dltk.core.IType;
import org.eclipse.dltk.core.ModelException;
import org.eclipse.dltk.core.SourceParserUtil;
import org.eclipse.dltk.ti.IContext;
import org.eclipse.dltk.ti.ISourceModuleContext;
import org.eclipse.dltk.ti.goals.ExpressionTypeGoal;
import org.eclipse.dltk.ti.types.IEvaluatedType;
import org.zikula.modulestudio.generator.beautifier.pdt.core.compiler.PHPFlags;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.PHPCorePlugin;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.PHPVersion;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.compiler.ast.parser.ASTUtils;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.typeinference.PHPClassType;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.typeinference.PHPModelUtils;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.typeinference.PHPTypeInferenceUtils;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.typeinference.PHPTypeInferencer;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.typeinference.context.FileContext;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.typeinference.context.TypeContext;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.typeinference.goals.ClassVariableDeclarationGoal;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.typeinference.goals.MethodElementReturnTypeGoal;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.typeinference.goals.phpdoc.PHPDocClassVariableGoal;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.typeinference.goals.phpdoc.PHPDocMethodReturnTypeGoal;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.util.text.PHPTextSequenceUtilities;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.util.text.TextSequence;

/**
 * This is a common utility used by completion and selection engines for PHP
 * elements retrieval.
 * 
 * @author michael
 */
public class CodeAssistUtils {

    /**
     * Whether to use PHPDoc in type inference
     */
    public static final int USE_PHPDOC = 1 << 5;

    private static final String DOLLAR = "$"; //$NON-NLS-1$
    private static final String PAAMAYIM_NEKUDOTAIM = "::"; //$NON-NLS-1$
    protected static final String OBJECT_FUNCTIONS_TRIGGER = "->"; //$NON-NLS-1$
    private static final Pattern globalPattern = Pattern
            .compile("\\$GLOBALS[\\s]*\\[[\\s]*[\\'\\\"][\\w]+[\\'\\\"][\\s]*\\]"); //$NON-NLS-1$

    private static final IType[] EMPTY_TYPES = new IType[0];

    public static boolean startsWithIgnoreCase(String word, String prefix) {
        return word.toLowerCase().startsWith(prefix.toLowerCase());
    }

    /**
     * Returns type of a class field defined by name.
     * 
     * @param types
     * @param propertyName
     * @param offset
     * @return
     */
    public static IType[] getVariableType(IType[] types, String propertyName,
            int offset) {
        if (types != null) {
            for (final IType type : types) {
                final PHPClassType classType = PHPClassType.fromIType(type);

                final ModuleDeclaration moduleDeclaration = SourceParserUtil
                        .getModuleDeclaration(type.getSourceModule(), null);
                final FileContext fileContext = new FileContext(
                        type.getSourceModule(), moduleDeclaration, offset);
                final TypeContext typeContext = new TypeContext(fileContext,
                        classType);
                final PHPTypeInferencer typeInferencer = new PHPTypeInferencer();

                if (!propertyName.startsWith(DOLLAR)) {
                    propertyName = DOLLAR + propertyName;
                }
                final PHPDocClassVariableGoal phpDocGoal = new PHPDocClassVariableGoal(
                        typeContext, propertyName);
                IEvaluatedType evaluatedType = typeInferencer
                        .evaluateTypePHPDoc(phpDocGoal, 3000);

                IType[] modelElements = PHPTypeInferenceUtils.getModelElements(
                        evaluatedType, fileContext, offset);
                if (modelElements != null) {
                    return modelElements;
                }

                final ClassVariableDeclarationGoal goal = new ClassVariableDeclarationGoal(
                        typeContext, types, propertyName);
                evaluatedType = typeInferencer.evaluateType(goal);

                modelElements = PHPTypeInferenceUtils.getModelElements(
                        evaluatedType, fileContext, offset);
                if (modelElements != null) {
                    return modelElements;
                }
            }
        }
        return EMPTY_TYPES;
    }

    /**
     * Returns type of a variable defined by name.
     * 
     * @param sourceModule
     * @param variableName
     * @param position
     * @return
     */
    public static IType[] getVariableType(ISourceModule sourceModule,
            String variableName, int position) {
        final ModuleDeclaration moduleDeclaration = SourceParserUtil
                .getModuleDeclaration(sourceModule, null);
        final IContext context = ASTUtils.findContext(sourceModule,
                moduleDeclaration, position);
        if (context != null) {
            final VariableReference varReference = new VariableReference(
                    position, position + variableName.length(), variableName);
            final ExpressionTypeGoal goal = new ExpressionTypeGoal(context,
                    varReference);
            final PHPTypeInferencer typeInferencer = new PHPTypeInferencer();
            final IEvaluatedType evaluatedType = typeInferencer
                    .evaluateType(goal);

            final IType[] modelElements = PHPTypeInferenceUtils
                    .getModelElements(evaluatedType,
                            (ISourceModuleContext) context, position);
            if (modelElements != null) {
                return modelElements;
            }
        }
        return EMPTY_TYPES;
    }

    /**
     * Determines the return type of the given method element.
     * 
     * @param method
     * @param function
     * @param offset
     * @return
     */
    public static IType[] getFunctionReturnType(IType[] types, String method,
            org.eclipse.dltk.core.ISourceModule sourceModule, int offset) {
        return getFunctionReturnType(types, method, USE_PHPDOC, sourceModule,
                offset);
    }

    /**
     * Determines the return type of the given method element.
     * 
     * @param method
     * @param mask
     * @param offset
     * @return
     */
    public static IType[] getFunctionReturnType(IType[] types, String method,
            int mask, org.eclipse.dltk.core.ISourceModule sourceModule,
            int offset) {
        final PHPTypeInferencer typeInferencer = new PHPTypeInferencer();
        final ModuleDeclaration moduleDeclaration = SourceParserUtil
                .getModuleDeclaration(sourceModule, null);
        final IContext context = ASTUtils.findContext(sourceModule,
                moduleDeclaration, offset);

        IEvaluatedType evaluatedType;
        IType[] modelElements;
        final boolean usePhpDoc = (mask & USE_PHPDOC) != 0;
        if (usePhpDoc) {
            final PHPDocMethodReturnTypeGoal phpDocGoal = new PHPDocMethodReturnTypeGoal(
                    context, types, method);
            evaluatedType = typeInferencer.evaluateTypePHPDoc(phpDocGoal);

            modelElements = PHPTypeInferenceUtils.getModelElements(
                    evaluatedType, (ISourceModuleContext) context, offset);
            if (modelElements != null) {
                return modelElements;
            }
        }

        final MethodElementReturnTypeGoal methodGoal = new MethodElementReturnTypeGoal(
                context, types, method);
        evaluatedType = typeInferencer.evaluateType(methodGoal);
        modelElements = PHPTypeInferenceUtils.getModelElements(evaluatedType,
                (ISourceModuleContext) context, offset);
        if (modelElements != null) {
            return modelElements;
        }
        return EMPTY_TYPES;
    }

    /**
     * this function searches the sequence from the right closing bracket ")"
     * and finding the position of the left "(" the offset has to be the offset
     * of the "("
     */
    public static int getFunctionNameEndOffset(TextSequence statementText,
            int offset) {
        if (statementText.charAt(offset) != ')') {
            return 0;
        }
        int currChar = offset;
        int bracketsNum = 1;
        char inStringMode = 0;
        while (bracketsNum != 0 && currChar >= 0) {
            currChar--;
            // get the current char
            final char charAt = statementText.charAt(currChar);
            // if it is string close / open - update state
            if (charAt == '\'' || charAt == '"') {
                inStringMode = inStringMode == 0 ? charAt
                        : inStringMode == charAt ? 0 : inStringMode;
            }

            if (inStringMode != 0) {
                continue;
            }

            if (charAt == ')') {
                bracketsNum++;
            }
            else if (charAt == '(') {
                bracketsNum--;
            }
        }
        return currChar;
    }

    /**
     * The "self" function needs to be added only if we are in a class method
     * and it is not an abstract class or an interface
     * 
     * @param fileData
     * @param offset
     * @return the self class data or null in case not found
     */
    public static IType getSelfClassData(ISourceModule sourceModule, int offset) {

        final IType type = PHPModelUtils.getCurrentType(sourceModule, offset);
        final IMethod method = PHPModelUtils.getCurrentMethod(sourceModule,
                offset);

        if (type != null && method != null) {
            try {
                final int flags = type.getFlags();
                if (!PHPFlags.isAbstract(flags) && !PHPFlags.isInterface(flags)
                        && !PHPFlags.isInterface(flags)) {
                    return type;
                }
            } catch (final ModelException e) {
                PHPCorePlugin.log(e);
            }
        }

        return null;
    }

    /**
     * This method finds types for the receiver in the statement text.
     * 
     * @param sourceModule
     * @param statementText
     * @param endPosition
     * @param offset
     * @return
     */
    public static IType[] getTypesFor(ISourceModule sourceModule,
            TextSequence statementText, int endPosition, int offset) {
        endPosition = PHPTextSequenceUtilities.readBackwardSpaces(
                statementText, endPosition); // read whitespace

        boolean isClassTriger = false;

        if (endPosition < 2) {
            return EMPTY_TYPES;
        }

        final String triggerText = statementText.subSequence(endPosition - 2,
                endPosition).toString();
        if (triggerText.equals(OBJECT_FUNCTIONS_TRIGGER)) {
        }
        else if (triggerText.equals(PAAMAYIM_NEKUDOTAIM)) {
            isClassTriger = true;
        }
        else {
            return EMPTY_TYPES;
        }

        final int propertyEndPosition = PHPTextSequenceUtilities
                .readBackwardSpaces(statementText,
                        endPosition - triggerText.length());
        final int lastObjectOperator = PHPTextSequenceUtilities
                .getPrivousTriggerIndex(statementText, propertyEndPosition);

        if (lastObjectOperator == -1) {
            // if there is no "->" or "::" in the left sequence then we need to
            // calc the object type
            return innerGetClassName(sourceModule, statementText,
                    propertyEndPosition, isClassTriger, offset);
        }

        final int propertyStartPosition = PHPTextSequenceUtilities
                .readForwardSpaces(statementText, lastObjectOperator
                        + triggerText.length());
        final String propertyName = statementText.subSequence(
                propertyStartPosition, propertyEndPosition).toString();
        final IType[] types = getTypesFor(sourceModule, statementText,
                propertyStartPosition, offset);

        final int bracketIndex = propertyName.indexOf('(');

        if (bracketIndex == -1) {
            // meaning its a class variable and not a function
            return getVariableType(types, propertyName, offset);
        }

        final String functionName = propertyName.substring(0, bracketIndex)
                .trim();
        final Set<IType> result = new LinkedHashSet<IType>();
        final IType[] returnTypes = getFunctionReturnType(types, functionName,
                sourceModule, offset);
        if (returnTypes != null) {
            result.addAll(Arrays.asList(returnTypes));
        }
        return result.toArray(new IType[result.size()]);
    }

    /**
     * Getting an instance and finding its type.
     */
    private static IType[] innerGetClassName(ISourceModule sourceModule,
            TextSequence statementText, int propertyEndPosition,
            boolean isClassTriger, int offset) {

        final PHPVersion phpVersion = PHPVersion.PHP5_3;

        final int classNameStart = PHPTextSequenceUtilities
                .readIdentifierStartIndex(phpVersion, statementText,
                        propertyEndPosition, true);
        String className = statementText.subSequence(classNameStart,
                propertyEndPosition).toString();
        if (isClassTriger && className != null && className.length() != 0) {
            if ("self".equals(className)
                    || "parent".equals(className)
                    || (phpVersion.isGreaterThan(PHPVersion.PHP5) && "static"
                            .equals(className))) {
                final IType classData = PHPModelUtils.getCurrentType(
                        sourceModule, offset - className.length() - 2); // the
                                                                        // offset
                                                                        // before
                // "self::",
                // "parent::" or
                // "static::"
                if (classData != null) {
                    return new IType[] { classData };
                }
            }
            if (className.length() > 0) {
                if (className.startsWith("$")
                        && phpVersion.isGreaterThan(PHPVersion.PHP5)) {
                    final int statementStart = offset - statementText.length();
                    return getVariableType(sourceModule, className,
                            statementStart);
                }
                final ModuleDeclaration moduleDeclaration = SourceParserUtil
                        .getModuleDeclaration(sourceModule, null);
                final FileContext context = new FileContext(sourceModule,
                        moduleDeclaration, offset);
                final IEvaluatedType type = PHPClassType.fromTypeName(
                        className, sourceModule, offset);
                final IType[] modelElements = PHPTypeInferenceUtils
                        .getModelElements(type, context, offset);
                if (modelElements != null) {
                    return modelElements;
                }
                return EMPTY_TYPES;
            }
        }
        // check for $GLOBALS['myVar'] scenario
        if (className.length() == 0) {
            // this can happen if the first char before the property is ']'
            final String testedVar = statementText
                    .subSequence(0, propertyEndPosition).toString().trim();
            if (testedVar != null && testedVar.length() != 0) {
                final Matcher m = globalPattern.matcher(testedVar);
                if (m.matches()) {
                    // $GLOBALS['myVar'] => 'myVar'
                    final String quotedVarName = testedVar.substring(
                            testedVar.indexOf('[') + 1, testedVar.indexOf(']'))
                            .trim();
                    // 'myVar' => $myVar
                    className = DOLLAR
                            + quotedVarName.substring(1,
                                    quotedVarName.length() - 1);
                }
            }
        }
        // if its object call calc the object type.
        if (className.length() > 0 && className.charAt(0) == '$') {
            final int statementStart = offset - statementText.length();
            return getVariableType(sourceModule, className, statementStart);
        }
        // if its function call calc the return type.
        if (propertyEndPosition > 0
                && statementText.charAt(propertyEndPosition - 1) == ')') {
            final int functionNameEnd = getFunctionNameEndOffset(statementText,
                    propertyEndPosition - 1);
            final int functionNameStart = PHPTextSequenceUtilities
                    .readIdentifierStartIndex(phpVersion, statementText,
                            functionNameEnd, false);

            final String functionName = statementText.subSequence(
                    functionNameStart, functionNameEnd).toString();
            // if its a non class function
            final Set<IType> returnTypes = new LinkedHashSet<IType>();
            final IType[] types = getFunctionReturnType(null, functionName,
                    sourceModule, offset);
            if (types != null) {
                returnTypes.addAll(Arrays.asList(types));
            }
            return returnTypes.toArray(new IType[returnTypes.size()]);
        }
        return EMPTY_TYPES;
    }

    /**
     * This method checks whether the specified function name refers to existing
     * method in the given list of classes.
     * 
     * @param sourceModule
     * @param className
     * @param functionName
     * @return
     */
    public static boolean isClassFunctionCall(ISourceModule sourceModule,
            IType[] className, String functionName) {
        for (final IType type : className) {
            IMethod[] classMethod;
            try {
                classMethod = PHPModelUtils.getTypeHierarchyMethod(type,
                        functionName, true, null);
                if (classMethod != null) {
                    return true;
                }
            } catch (final CoreException e) {
                PHPCorePlugin.log(e);
            }
        }
        return false;
    }
}
