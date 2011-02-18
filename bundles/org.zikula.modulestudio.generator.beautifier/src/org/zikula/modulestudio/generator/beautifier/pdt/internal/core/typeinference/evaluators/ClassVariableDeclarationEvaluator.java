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

import java.util.HashMap;
import java.util.HashSet;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;
import java.util.Set;

import org.eclipse.core.runtime.CoreException;
import org.eclipse.dltk.ast.ASTNode;
import org.eclipse.dltk.ast.declarations.ModuleDeclaration;
import org.eclipse.dltk.ast.declarations.TypeDeclaration;
import org.eclipse.dltk.ast.expressions.Expression;
import org.eclipse.dltk.ast.references.SimpleReference;
import org.eclipse.dltk.ast.references.TypeReference;
import org.eclipse.dltk.ast.references.VariableReference;
import org.eclipse.dltk.ast.statements.Statement;
import org.eclipse.dltk.core.DLTKCore;
import org.eclipse.dltk.core.IField;
import org.eclipse.dltk.core.ISourceModule;
import org.eclipse.dltk.core.ISourceRange;
import org.eclipse.dltk.core.IType;
import org.eclipse.dltk.core.ModelException;
import org.eclipse.dltk.core.SourceParserUtil;
import org.eclipse.dltk.internal.core.SourceRefElement;
import org.eclipse.dltk.ti.GoalState;
import org.eclipse.dltk.ti.IContext;
import org.eclipse.dltk.ti.goals.ExpressionTypeGoal;
import org.eclipse.dltk.ti.goals.IGoal;
import org.eclipse.dltk.ti.types.IEvaluatedType;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.compiler.ast.nodes.Assignment;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.compiler.ast.nodes.FieldAccess;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.compiler.ast.nodes.PHPDocBlock;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.compiler.ast.nodes.PHPDocTag;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.compiler.ast.nodes.PHPFieldDeclaration;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.compiler.ast.nodes.StaticFieldAccess;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.typeinference.PHPClassType;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.typeinference.PHPModelUtils;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.typeinference.PHPSimpleTypes;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.typeinference.PHPTypeInferenceUtils;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.typeinference.context.ContextFinder;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.typeinference.context.TypeContext;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.typeinference.goals.ClassVariableDeclarationGoal;

/**
 * This evaluator finds class field declaration either using : 1. @var hint 2.
 * in method body using field access. 3. magic declaration using the @property,
 * 
 * @property-read, @property-write
 */
public class ClassVariableDeclarationEvaluator extends AbstractPHPGoalEvaluator {

    private final List<IEvaluatedType> evaluated = new LinkedList<IEvaluatedType>();

    public ClassVariableDeclarationEvaluator(IGoal goal) {
        super(goal);
    }

    @Override
    public IGoal[] init() {
        final ClassVariableDeclarationGoal typedGoal = (ClassVariableDeclarationGoal) goal;
        IType[] types = typedGoal.getTypes();

        if (types == null) {
            final TypeContext context = (TypeContext) typedGoal.getContext();
            types = PHPTypeInferenceUtils.getModelElements(
                    context.getInstanceType(), context);
        }
        if (types == null) {
            return null;
        }

        final String variableName = typedGoal.getVariableName();

        final List<IGoal> subGoals = new LinkedList<IGoal>();
        for (final IType type : types) {
            try {
                final IField[] fields = PHPModelUtils.getTypeHierarchyField(
                        type, variableName, true, null);
                final Set<IType> fieldDeclaringTypeSet = new HashSet<IType>();
                for (final IField field : fields) {
                    final IType declaringType = field.getDeclaringType();
                    if (declaringType != null) {
                        fieldDeclaringTypeSet.add(declaringType);
                        final ISourceModule sourceModule = declaringType
                                .getSourceModule();
                        final ModuleDeclaration moduleDeclaration = SourceParserUtil
                                .getModuleDeclaration(sourceModule);
                        final TypeDeclaration typeDeclaration = PHPModelUtils
                                .getNodeByClass(moduleDeclaration,
                                        declaringType);

                        if (typeDeclaration != null
                                && field instanceof SourceRefElement) {
                            final SourceRefElement sourceRefElement = (SourceRefElement) field;
                            final ISourceRange sourceRange = sourceRefElement
                                    .getSourceRange();

                            final ClassDeclarationSearcher searcher = new ClassDeclarationSearcher(
                                    sourceModule, typeDeclaration,
                                    sourceRange.getOffset(),
                                    sourceRange.getLength(), null);
                            try {
                                moduleDeclaration.traverse(searcher);
                                if (searcher.getResult() != null) {
                                    subGoals.add(new ExpressionTypeGoal(
                                            searcher.getContext(), searcher
                                                    .getResult()));
                                }
                            } catch (final Exception e) {
                                if (DLTKCore.DEBUG) {
                                    e.printStackTrace();
                                }
                            }
                        }
                    }
                }

                if (subGoals.size() == 0) {
                    getGoalFromStaticDeclaration(variableName, subGoals, type);
                }
                fieldDeclaringTypeSet.remove(type);
                if (subGoals.size() == 0 && !fieldDeclaringTypeSet.isEmpty()) {
                    for (final Object element : fieldDeclaringTypeSet) {
                        final IType fieldDeclaringType = (IType) element;
                        getGoalFromStaticDeclaration(variableName, subGoals,
                                fieldDeclaringType);
                    }
                }
            } catch (final CoreException e) {
                if (DLTKCore.DEBUG) {
                    e.printStackTrace();
                }
            }
        }

        resolveMagicClassVariableDeclaration(types, variableName);

        return subGoals.toArray(new IGoal[subGoals.size()]);
    }

    protected void getGoalFromStaticDeclaration(String variableName,
            final List<IGoal> subGoals, final IType type) throws ModelException {
        final ISourceModule sourceModule = type.getSourceModule();
        final ModuleDeclaration moduleDeclaration = SourceParserUtil
                .getModuleDeclaration(sourceModule);
        final TypeDeclaration typeDeclaration = PHPModelUtils.getNodeByClass(
                moduleDeclaration, type);

        // try to search declarations of type "self::$var =" or
        // "$this->var ="
        final ClassDeclarationSearcher searcher = new ClassDeclarationSearcher(
                sourceModule, typeDeclaration, 0, 0, variableName);
        try {
            moduleDeclaration.traverse(searcher);
            final Map<ASTNode, IContext> staticDeclarations = searcher
                    .getStaticDeclarations();
            for (final ASTNode node : staticDeclarations.keySet()) {
                subGoals.add(new ExpressionTypeGoal(staticDeclarations
                        .get(node), node));
            }
        } catch (final Exception e) {
            if (DLTKCore.DEBUG) {
                e.printStackTrace();
            }
        }
    }

    /**
     * Search for magic variables using the @property tag
     * 
     * @param types
     * @param variableName
     */
    private void resolveMagicClassVariableDeclaration(IType[] types,
            String variableName) {
        for (final IType type : types) {
            resolveMagicClassVariableDeclaration(variableName, type);
            try {
                if (evaluated.isEmpty() && type.getSuperClasses() != null
                        && type.getSuperClasses().length > 0) {
                    final IType[] superClasses = PHPModelUtils.getSuperClasses(
                            type, null);
                    for (final IType superClass : superClasses) {
                        resolveMagicClassVariableDeclaration(variableName,
                                superClass);
                    }
                }
            } catch (final ModelException e) {
                e.printStackTrace();
            }
        }
    }

    protected void resolveMagicClassVariableDeclaration(String variableName,
            IType type) {
        final PHPDocBlock docBlock = PHPModelUtils.getDocBlock(type);
        if (docBlock != null) {
            for (final PHPDocTag tag : docBlock.getTags()) {
                final int tagKind = tag.getTagKind();
                if (tagKind == PHPDocTag.PROPERTY
                        || tagKind == PHPDocTag.PROPERTY_READ
                        || tagKind == PHPDocTag.PROPERTY_WRITE) {
                    final String typeName = getTypeBinding(variableName, tag);
                    if (typeName != null) {
                        IEvaluatedType resolved = PHPSimpleTypes
                                .fromString(typeName);
                        if (resolved == null) {
                            resolved = new PHPClassType(typeName);
                        }
                        evaluated.add(resolved);
                    }
                }
            }
        }
    }

    /**
     * Resolves the type from the @property tag
     * 
     * @param variableName
     * @param docTag
     * @return the type of the given variable
     */
    private String getTypeBinding(String variableName, PHPDocTag docTag) {
        final String[] split = docTag.getValue().trim().split("\\s+");
        if (split.length < 2) {
            return null;
        }
        return split[1].equals(variableName) ? split[0] : null;
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

    /**
     * Searches for all class variable declarations using offset and length
     * which is hold by model element
     * 
     * @author michael
     */
    class ClassDeclarationSearcher extends ContextFinder {

        private final TypeDeclaration typeDeclaration;
        private ASTNode result;
        private IContext context;
        private final int offset;
        private final int length;
        private final String variableName;
        private final Map<ASTNode, IContext> staticDeclarations;

        public ClassDeclarationSearcher(ISourceModule sourceModule,
                TypeDeclaration typeDeclaration, int offset, int length,
                String variableName) {
            super(sourceModule);
            this.typeDeclaration = typeDeclaration;
            this.offset = offset;
            this.length = length;
            this.variableName = variableName;
            this.staticDeclarations = new HashMap<ASTNode, IContext>();
        }

        public ASTNode getResult() {
            return result;
        }

        public Map<ASTNode, IContext> getStaticDeclarations() {
            return staticDeclarations;
        }

        @Override
        public IContext getContext() {
            return context;
        }

        @Override
        public boolean visit(Statement e) throws Exception {
            if (typeDeclaration.sourceStart() < e.sourceStart()
                    && typeDeclaration.sourceEnd() > e.sourceEnd()) {
                if (e instanceof PHPFieldDeclaration) {
                    final PHPFieldDeclaration phpFieldDecl = (PHPFieldDeclaration) e;
                    if (phpFieldDecl.getDeclarationStart() == offset
                            && phpFieldDecl.sourceEnd()
                                    - phpFieldDecl.getDeclarationStart() == length) {
                        result = ((PHPFieldDeclaration) e).getVariableValue();
                        context = contextStack.peek();
                    }
                }
            }
            return visitGeneral(e);
        }

        @Override
        public boolean visit(Expression e) throws Exception {
            if (typeDeclaration.sourceStart() < e.sourceStart()
                    && typeDeclaration.sourceEnd() > e.sourceEnd()) {
                if (e instanceof Assignment) {
                    if (e.sourceStart() == offset
                            && e.sourceEnd() - e.sourceStart() == length) {
                        result = ((Assignment) e).getValue();
                        context = contextStack.peek();
                    }
                    else if (variableName != null) {
                        final Assignment assignment = (Assignment) e;
                        final Expression left = assignment.getVariable();
                        final Expression right = assignment.getValue();

                        if (left instanceof StaticFieldAccess) {
                            final StaticFieldAccess fieldAccess = (StaticFieldAccess) left;
                            final Expression dispatcher = fieldAccess
                                    .getDispatcher();
                            if (dispatcher instanceof TypeReference
                                    && "self".equals(((TypeReference) dispatcher).getName())) { //$NON-NLS-1$
                                final Expression field = fieldAccess.getField();
                                if (field instanceof VariableReference
                                        && variableName
                                                .equals(((VariableReference) field)
                                                        .getName())) {
                                    staticDeclarations.put(right,
                                            contextStack.peek());
                                }
                            }
                        }
                        else if (left instanceof FieldAccess) {
                            final FieldAccess fieldAccess = (FieldAccess) left;
                            final Expression dispatcher = fieldAccess
                                    .getDispatcher();
                            if (dispatcher instanceof VariableReference
                                    && "$this".equals(((VariableReference) dispatcher).getName())) { //$NON-NLS-1$
                                final Expression field = fieldAccess.getField();
                                if (field instanceof SimpleReference
                                        && variableName
                                                .equals('$' + ((SimpleReference) field)
                                                        .getName())) {
                                    staticDeclarations.put(right,
                                            contextStack.peek());
                                }
                            }
                        }
                    }
                }
            }
            return visitGeneral(e);
        }

        @Override
        public boolean visitGeneral(ASTNode e) throws Exception {
            return e.sourceStart() <= offset || variableName != null;
        }
    }
}
