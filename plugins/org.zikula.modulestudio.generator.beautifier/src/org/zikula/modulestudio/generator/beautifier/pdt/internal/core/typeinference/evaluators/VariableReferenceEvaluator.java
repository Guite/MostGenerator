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

import java.util.ArrayList;
import java.util.LinkedList;
import java.util.List;

import org.eclipse.dltk.ast.ASTNode;
import org.eclipse.dltk.ast.expressions.Expression;
import org.eclipse.dltk.ast.references.TypeReference;
import org.eclipse.dltk.ast.references.VariableReference;
import org.eclipse.dltk.ast.statements.Statement;
import org.eclipse.dltk.core.DLTKCore;
import org.eclipse.dltk.core.ISourceModule;
import org.eclipse.dltk.evaluation.types.SimpleType;
import org.eclipse.dltk.ti.GoalState;
import org.eclipse.dltk.ti.IContext;
import org.eclipse.dltk.ti.ISourceModuleContext;
import org.eclipse.dltk.ti.goals.ExpressionTypeGoal;
import org.eclipse.dltk.ti.goals.GoalEvaluator;
import org.eclipse.dltk.ti.goals.IGoal;
import org.eclipse.dltk.ti.types.IEvaluatedType;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.compiler.ast.nodes.ForEachStatement;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.compiler.ast.nodes.GlobalStatement;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.compiler.ast.nodes.InstanceOfExpression;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.compiler.ast.nodes.PHPModuleDeclaration;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.compiler.ast.nodes.VarComment;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.typeinference.PHPTypeInferenceUtils;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.typeinference.VariableDeclarationSearcher.Declaration;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.typeinference.context.FileContext;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.typeinference.context.MethodContext;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.typeinference.goals.ForeachStatementGoal;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.typeinference.goals.GlobalVariableReferencesGoal;

/**
 * This evaluator finds all local variable declarations and produces the
 * following sub-goals: {@link GlobalVariableReferencesGoal} or
 * {@link VariableDeclarationGoal}
 */
public class VariableReferenceEvaluator extends GoalEvaluator {

    private final List<IEvaluatedType> results = new ArrayList<IEvaluatedType>();

    public VariableReferenceEvaluator(IGoal goal) {
        super(goal);
    }

    @Override
    public IGoal[] init() {
        final VariableReference variableReference = (VariableReference) ((ExpressionTypeGoal) goal)
                .getExpression();
        final IContext context = goal.getContext();

        // Handle $this variable reference
        if (variableReference.getName().equals("$this")) {
            if (context instanceof MethodContext) {
                final MethodContext methodContext = (MethodContext) context;
                final IEvaluatedType instanceType = methodContext
                        .getInstanceType();
                if (instanceType != null) {
                    this.results.add(instanceType);
                }
                else {
                    this.results.add(new SimpleType(SimpleType.TYPE_NULL));
                }
                return IGoal.NO_GOALS;
            }
        }

        try {
            if (context instanceof ISourceModuleContext) {
                final ISourceModuleContext typedContext = (ISourceModuleContext) context;
                final ASTNode rootNode = typedContext.getRootNode();
                ASTNode localScopeNode = rootNode;
                if (context instanceof MethodContext) {
                    localScopeNode = ((MethodContext) context).getMethodNode();
                }
                final LocalReferenceDeclSearcher varDecSearcher = new LocalReferenceDeclSearcher(
                        typedContext.getSourceModule(), variableReference,
                        localScopeNode);
                rootNode.traverse(varDecSearcher);

                final List<IGoal> subGoals = new LinkedList<IGoal>();

                final List<VarComment> varComments = ((PHPModuleDeclaration) rootNode)
                        .getVarComments();
                for (final VarComment varComment : varComments) {
                    if (varComment.sourceStart() > variableReference
                            .sourceStart()) {
                        break;
                    }
                    if (varComment.getVariableReference().getName()
                            .equals(variableReference.getName())) {
                        final List<IGoal> goals = new LinkedList<IGoal>();
                        for (final TypeReference ref : varComment
                                .getTypeReferences()) {
                            goals.add(new ExpressionTypeGoal(context, ref));
                        }
                        return goals.toArray(new IGoal[goals.size()]);
                    }
                }

                final Declaration[] decls = varDecSearcher.getDeclarations();
                boolean mergeWithGlobalScope = false;
                for (int i = 0; i < decls.length; ++i) {
                    final Declaration decl = decls[i];
                    if (decl.getNode() instanceof GlobalStatement) {
                        mergeWithGlobalScope = true;
                    }
                    else {
                        final ASTNode declNode = decl.getNode();
                        if (declNode instanceof ForEachStatement) {
                            subGoals.add(new ForeachStatementGoal(context,
                                    ((ForEachStatement) declNode)
                                            .getExpression()));
                        }
                        else {
                            subGoals.add(new ExpressionTypeGoal(context,
                                    declNode));
                        }
                    }
                }
                if (mergeWithGlobalScope
                        || (decls.length == 0 && context.getClass() == FileContext.class)) {
                    // collect all global variables, and merge results with
                    // existing declarations
                    subGoals.add(new GlobalVariableReferencesGoal(context,
                            variableReference.getName()));
                }
                return subGoals.toArray(new IGoal[subGoals.size()]);
            }
        } catch (final Exception e) {
            if (DLTKCore.DEBUG) {
                e.printStackTrace();
            }
        }

        return IGoal.NO_GOALS;
    }

    @Override
    public Object produceResult() {
        return PHPTypeInferenceUtils.combineTypes(results);
    }

    @Override
    public IGoal[] subGoalDone(IGoal subgoal, Object result, GoalState state) {
        if (state != GoalState.RECURSIVE && result != null) {
            results.add((IEvaluatedType) result);
        }
        return IGoal.NO_GOALS;
    }

    public static class LocalReferenceDeclSearcher
            extends
            org.zikula.modulestudio.generator.beautifier.pdt.internal.core.typeinference.VariableDeclarationSearcher {

        private final String variableName;
        private final int variableOffset;
        private final ASTNode localScopeNode;
        private IContext variableContext;
        private int variableLevel;

        public LocalReferenceDeclSearcher(ISourceModule sourceModule,
                VariableReference variableReference, ASTNode localScopeNode) {
            super(sourceModule);
            variableName = variableReference.getName();
            variableOffset = variableReference.sourceStart();
            this.localScopeNode = localScopeNode;
        }

        public Declaration[] getDeclarations() {
            Declaration[] declarations = getScope(variableContext)
                    .getDeclarations(variableName);
            if (variableLevel > 0 && variableLevel < declarations.length) {
                final Declaration[] newDecls = new Declaration[declarations.length
                        - variableLevel];
                System.arraycopy(declarations, variableLevel, newDecls, 0,
                        newDecls.length);
                declarations = newDecls;
            }

            final List<Declaration> filteredDecls = new LinkedList<Declaration>();
            for (final Declaration decl : declarations) {
                if (decl.getNode().sourceStart() > localScopeNode.sourceStart()) {
                    filteredDecls.add(decl);
                }
            }
            return filteredDecls.toArray(new Declaration[filteredDecls.size()]);
        }

        @Override
        protected void postProcess(Expression node) {
            if (node instanceof InstanceOfExpression) {
                final InstanceOfExpression expr = (InstanceOfExpression) node;
                if (expr.getExpr() instanceof VariableReference) {
                    final VariableReference varReference = (VariableReference) expr
                            .getExpr();
                    if (variableName.equals(varReference.getName())) {
                        getScope().addDeclaration(variableName,
                                expr.getClassName());
                    }
                }
            }
        }

        @Override
        protected void postProcessGeneral(ASTNode node) {
            if (node.sourceStart() == variableOffset) {
                variableContext = contextStack.peek();
                variableLevel = getScope(variableContext).getInnerBlockLevel();
            }
        }

        @Override
        protected void postProcess(Statement node) {
        }

        @Override
        protected boolean isInteresting(ASTNode node) {
            return node.sourceStart() <= variableOffset;
        }
    }
}
