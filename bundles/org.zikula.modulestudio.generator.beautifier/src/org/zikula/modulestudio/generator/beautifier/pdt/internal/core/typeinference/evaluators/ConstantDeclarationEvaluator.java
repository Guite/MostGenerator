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
import java.util.HashSet;
import java.util.Iterator;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.SortedSet;
import java.util.TreeSet;

import org.eclipse.dltk.ast.ASTNode;
import org.eclipse.dltk.ast.ASTVisitor;
import org.eclipse.dltk.ast.Modifiers;
import org.eclipse.dltk.ast.declarations.ModuleDeclaration;
import org.eclipse.dltk.ast.expressions.CallExpression;
import org.eclipse.dltk.ast.expressions.Expression;
import org.eclipse.dltk.ast.statements.Statement;
import org.eclipse.dltk.core.DLTKCore;
import org.eclipse.dltk.core.IField;
import org.eclipse.dltk.core.IModelElement;
import org.eclipse.dltk.core.IScriptProject;
import org.eclipse.dltk.core.ISourceModule;
import org.eclipse.dltk.core.ISourceRange;
import org.eclipse.dltk.core.IType;
import org.eclipse.dltk.core.ModelException;
import org.eclipse.dltk.core.SourceParserUtil;
import org.eclipse.dltk.core.index2.search.ISearchEngine.MatchRule;
import org.eclipse.dltk.core.search.IDLTKSearchScope;
import org.eclipse.dltk.core.search.SearchEngine;
import org.eclipse.dltk.ti.GoalState;
import org.eclipse.dltk.ti.ISourceModuleContext;
import org.eclipse.dltk.ti.goals.ExpressionTypeGoal;
import org.eclipse.dltk.ti.goals.GoalEvaluator;
import org.eclipse.dltk.ti.goals.IGoal;
import org.eclipse.dltk.ti.types.IEvaluatedType;
import org.zikula.modulestudio.generator.beautifier.pdt.core.compiler.PHPFlags;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.PHPLanguageToolkit;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.compiler.ast.nodes.ConstantDeclaration;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.compiler.ast.nodes.Scalar;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.model.PhpModelAccess;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.typeinference.PHPTypeInferenceUtils;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.typeinference.goals.ConstantDeclarationGoal;

public class ConstantDeclarationEvaluator extends GoalEvaluator {

    private final List<IEvaluatedType> evaluatedTypes = new LinkedList<IEvaluatedType>();

    public ConstantDeclarationEvaluator(IGoal goal) {
        super(goal);
    }

    @Override
    public IGoal[] init() {
        final ConstantDeclarationGoal typedGoal = (ConstantDeclarationGoal) goal;
        final String constantName = typedGoal.getConstantName();
        final String typeName = typedGoal.getTypeName();

        IDLTKSearchScope scope = null;
        IScriptProject scriptProject = null;
        final ISourceModuleContext sourceModuleContext = (ISourceModuleContext) goal
                .getContext();
        if (sourceModuleContext != null) {
            scriptProject = sourceModuleContext.getSourceModule()
                    .getScriptProject();
            scope = SearchEngine.createSearchScope(scriptProject);
        }

        if (scope == null) {
            scope = SearchEngine.createWorkspaceScope(PHPLanguageToolkit
                    .getDefault());
        }
        final IType[] types = PhpModelAccess.getDefault().findTypes(typeName,
                MatchRule.EXACT, 0, Modifiers.AccNameSpace, scope, null);
        final Set<IModelElement> elements = new HashSet<IModelElement>();
        for (final IType type : types) {
            try {
                final IField field = type.getField(constantName);
                if (field.exists() && PHPFlags.isConstant(field.getFlags())) {
                    elements.add(field);
                }
            } catch (final ModelException e) {
                if (DLTKCore.DEBUG) {
                    e.printStackTrace();
                }
            }
        }

        final Map<ISourceModule, SortedSet<ISourceRange>> offsets = new HashMap<ISourceModule, SortedSet<ISourceRange>>();

        final Comparator<ISourceRange> sourceRangeComparator = new Comparator<ISourceRange>() {
            @Override
            public int compare(ISourceRange o1, ISourceRange o2) {
                return o1.getOffset() - o2.getOffset();
            }
        };

        for (final IModelElement element : elements) {
            if (element instanceof IField) {
                final IField field = (IField) element;
                final ISourceModule sourceModule = field.getSourceModule();
                if (!offsets.containsKey(sourceModule)) {
                    offsets.put(sourceModule, new TreeSet<ISourceRange>(
                            sourceRangeComparator));
                }
                try {
                    offsets.get(sourceModule).add(field.getSourceRange());
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
            final ModuleDeclaration moduleDeclaration = SourceParserUtil
                    .getModuleDeclaration(sourceModule);
            final SortedSet<ISourceRange> fileOffsets = offsets
                    .get(sourceModule);

            if (!fileOffsets.isEmpty()) {
                final ConstantDeclarationSearcher searcher = new ConstantDeclarationSearcher(
                        fileOffsets, constantName);
                try {
                    moduleDeclaration.traverse(searcher);
                    for (final Scalar scalar : searcher.getDeclarations()) {
                        subGoals.add(new ExpressionTypeGoal(goal.getContext(),
                                scalar));
                    }
                } catch (final Exception e) {
                    if (DLTKCore.DEBUG) {
                        e.printStackTrace();
                    }
                }
            }
        }

        return subGoals.toArray(new IGoal[subGoals.size()]);
    }

    @Override
    public Object produceResult() {
        return PHPTypeInferenceUtils.combineTypes(evaluatedTypes);
    }

    @Override
    public IGoal[] subGoalDone(IGoal subgoal, Object result, GoalState state) {
        if (state != GoalState.RECURSIVE && result != null) {
            evaluatedTypes.add((IEvaluatedType) result);
        }
        return IGoal.NO_GOALS;
    }

    class ConstantDeclarationSearcher extends ASTVisitor {

        private final String constantName;
        private final Iterator<ISourceRange> offsetsIt;
        private int currentStart;
        private int currentEnd;
        private boolean stopProcessing;
        private final List<Scalar> declarations = new LinkedList<Scalar>();

        public ConstantDeclarationSearcher(SortedSet<ISourceRange> offsets,
                String constantName) {
            this.constantName = constantName;
            offsetsIt = offsets.iterator();
            setNextRange();
        }

        public List<Scalar> getDeclarations() {
            return declarations;
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

        private boolean interesting(ASTNode node) {
            return !stopProcessing && node.sourceStart() <= currentStart
                    && node.sourceEnd() >= currentEnd;
        }

        @SuppressWarnings("unchecked")
        public boolean visit(CallExpression node) throws Exception {
            if (!interesting(node)) {
                return false;
            }
            if ("define".equalsIgnoreCase(node.getName())) { //$NON-NLS-1$
                // report global constant:
                final List args = node.getArgs().getChilds();
                if (args.size() == 2) {
                    final ASTNode firstArg = (ASTNode) args.get(0);
                    final ASTNode secondArg = (ASTNode) args.get(0);
                    if (firstArg instanceof Scalar
                            && secondArg instanceof Scalar) {
                        final Scalar constantName = (Scalar) firstArg;
                        final Scalar constantValue = (Scalar) secondArg;
                        if (this.constantName.equals(stripQuotes(constantName
                                .getValue()))) {
                            declarations.add(constantValue);
                        }
                    }
                }
            }
            return visitGeneral(node);
        }

        public boolean visit(ConstantDeclaration node) throws Exception {
            if (!interesting(node)) {
                return false;
            }
            final Expression value = node.getConstantValue();
            if (value instanceof Scalar) {
                declarations.add((Scalar) value);
            }
            return visitGeneral(node);
        }

        @Override
        public boolean visit(Expression node) throws Exception {
            if (!interesting(node)) {
                return false;
            }
            if (node instanceof CallExpression) {
                return visit((CallExpression) node);
            }
            return visitGeneral(node);
        }

        @Override
        public boolean endvisit(Statement s) throws Exception {
            if (s instanceof ConstantDeclaration) {
                return visit((ConstantDeclaration) s);
            }
            return visitGeneral(s);
        }

        @Override
        public boolean visitGeneral(ASTNode node) throws Exception {
            return interesting(node);
        }
    }

    /**
     * Strips single or double quotes from the start and from the end of the
     * given string
     * 
     * @param name
     *            String
     * @return
     */
    private static String stripQuotes(String name) {
        final int len = name.length();
        if (len > 1
                && (name.charAt(0) == '\'' && name.charAt(len - 1) == '\'' || name
                        .charAt(0) == '"' && name.charAt(len - 1) == '"')) {
            name = name.substring(1, len - 1);
        }
        return name;
    }
}
