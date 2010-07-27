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

import java.util.Comparator;
import java.util.HashMap;
import java.util.Iterator;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;
import java.util.SortedSet;
import java.util.TreeSet;

import org.eclipse.dltk.ast.ASTNode;
import org.eclipse.dltk.ast.Modifiers;
import org.eclipse.dltk.ast.declarations.ModuleDeclaration;
import org.eclipse.dltk.ast.expressions.Expression;
import org.eclipse.dltk.ast.references.VariableReference;
import org.eclipse.dltk.core.DLTKCore;
import org.eclipse.dltk.core.IField;
import org.eclipse.dltk.core.IModelElement;
import org.eclipse.dltk.core.IScriptProject;
import org.eclipse.dltk.core.ISourceModule;
import org.eclipse.dltk.core.ISourceRange;
import org.eclipse.dltk.core.ModelException;
import org.eclipse.dltk.core.SourceParserUtil;
import org.eclipse.dltk.core.index2.search.ISearchEngine.MatchRule;
import org.eclipse.dltk.core.search.IDLTKSearchScope;
import org.eclipse.dltk.core.search.SearchEngine;
import org.eclipse.dltk.internal.core.SourceField;
import org.eclipse.dltk.ti.GoalState;
import org.eclipse.dltk.ti.IContext;
import org.eclipse.dltk.ti.ISourceModuleContext;
import org.eclipse.dltk.ti.goals.ExpressionTypeGoal;
import org.eclipse.dltk.ti.goals.GoalEvaluator;
import org.eclipse.dltk.ti.goals.IGoal;
import org.eclipse.dltk.ti.types.IEvaluatedType;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.compiler.ast.nodes.Assignment;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.model.PhpModelAccess;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.typeinference.PHPTypeInferenceUtils;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.typeinference.VariableDeclarationSearcher;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.typeinference.VariableDeclarationSearcher.Declaration;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.typeinference.VariableDeclarationSearcher.DeclarationScope;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.typeinference.goals.GlobalVariableReferencesGoal;

/**
 * This evaluator finds all global declarations of the variable and produces
 * {@link VariableDeclarationGoal} as a subgoal.
 */
public class GlobalVariableReferencesEvaluator extends GoalEvaluator {

    private final List<IEvaluatedType> evaluated = new LinkedList<IEvaluatedType>();

    public GlobalVariableReferencesEvaluator(IGoal goal) {
        super(goal);
    }

    @SuppressWarnings("unused")
    @Override
    public IGoal[] init() {
        final GlobalVariableReferencesGoal typedGoal = (GlobalVariableReferencesGoal) goal;

        final IContext context = goal.getContext();
        ISourceModuleContext sourceModuleContext = null;
        if (context instanceof ISourceModuleContext) {
            sourceModuleContext = (ISourceModuleContext) context;
        }

        final String variableName = typedGoal.getVariableName();

        final boolean exploreOtherFiles = true;

        // Find all global variables from mixin
        final IScriptProject scriptProject = sourceModuleContext
                .getSourceModule().getScriptProject();
        final IDLTKSearchScope scope = SearchEngine
                .createSearchScope(scriptProject);

        final IField[] elements = PhpModelAccess.getDefault().findFields(
                variableName, MatchRule.EXACT, Modifiers.AccGlobal,
                Modifiers.AccConstant, scope, null);

        // if no element found, return empty array.
        if (elements == null) {
            return new IGoal[] {};
        }

        final Map<ISourceModule, SortedSet<ISourceRange>> offsets = new HashMap<ISourceModule, SortedSet<ISourceRange>>();

        final Comparator<ISourceRange> sourceRangeComparator = new Comparator<ISourceRange>() {
            @Override
            public int compare(ISourceRange o1, ISourceRange o2) {
                return o1.getOffset() - o2.getOffset();
            }
        };

        for (final IModelElement element : elements) {
            if (element instanceof SourceField) {
                final SourceField sourceField = (SourceField) element;
                final ISourceModule sourceModule = sourceField
                        .getSourceModule();
                if (!offsets.containsKey(sourceModule)) {
                    offsets.put(sourceModule, new TreeSet<ISourceRange>(
                            sourceRangeComparator));
                }
                try {
                    offsets.get(sourceModule).add(sourceField.getSourceRange());
                } catch (final ModelException e) {
                    if (DLTKCore.DEBUG) {
                        e.printStackTrace();
                    }
                }
            }
        }

        final List<IGoal> subGoals = new LinkedList<IGoal>();
        final Iterator<ISourceModule> sourceModuleIt = offsets.keySet()
                .iterator();
        while (sourceModuleIt.hasNext()) {
            final ISourceModule sourceModule = sourceModuleIt.next();
            if (exploreOtherFiles
                    || (sourceModuleContext != null && sourceModuleContext
                            .getSourceModule().equals(sourceModule))) {

                final ModuleDeclaration moduleDeclaration = SourceParserUtil
                        .getModuleDeclaration(sourceModule);
                final SortedSet<ISourceRange> fileOffsets = offsets
                        .get(sourceModule);

                if (!fileOffsets.isEmpty()) {
                    final GlobalReferenceDeclSearcher varSearcher = new GlobalReferenceDeclSearcher(
                            sourceModule, fileOffsets, variableName);
                    try {
                        moduleDeclaration.traverse(varSearcher);

                        final DeclarationScope[] scopes = varSearcher
                                .getScopes();
                        for (final DeclarationScope s : scopes) {
                            for (final Declaration decl : s
                                    .getDeclarations(variableName)) {
                                subGoals.add(new ExpressionTypeGoal(s
                                        .getContext(), decl.getNode()));
                            }
                        }
                    } catch (final Exception e) {
                        if (DLTKCore.DEBUG) {
                            e.printStackTrace();
                        }
                    }
                }
            }
        }

        return subGoals.toArray(new IGoal[subGoals.size()]);
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

    class GlobalReferenceDeclSearcher extends VariableDeclarationSearcher {

        private final String variableName;
        private final Iterator<ISourceRange> offsetsIt;
        private int currentStart;
        private int currentEnd;
        private boolean stopProcessing;

        public GlobalReferenceDeclSearcher(ISourceModule sourceModule,
                SortedSet<ISourceRange> offsets, String variableName) {
            super(sourceModule);
            this.variableName = variableName;
            offsetsIt = offsets.iterator();
            setNextRange();
        }

        private void setNextRange() {
            if (offsetsIt.hasNext()) {
                final ISourceRange range = offsetsIt.next();
                currentStart = range.getOffset();
                currentEnd = currentStart + range.getLength();
            }
            else {
                stopProcessing = true;
            }
        }

        @Override
        protected void postProcess(Expression node) {
            if (node instanceof Assignment) {
                final Expression variable = ((Assignment) node).getVariable();
                if (variable instanceof VariableReference) {
                    final VariableReference variableReference = (VariableReference) variable;
                    if (variableName.equals(variableReference.getName())) {
                        setNextRange();
                    }
                }
            }
        }

        @Override
        protected boolean isInteresting(ASTNode node) {
            return !stopProcessing && node.sourceStart() <= currentStart
                    && node.sourceEnd() >= currentEnd;
        }
    }
}
