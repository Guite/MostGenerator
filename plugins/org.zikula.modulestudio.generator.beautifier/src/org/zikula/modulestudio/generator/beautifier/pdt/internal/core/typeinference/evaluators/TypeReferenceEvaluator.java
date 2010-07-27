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

import java.util.Iterator;
import java.util.LinkedList;
import java.util.List;

import org.eclipse.dltk.ast.ASTListNode;
import org.eclipse.dltk.ast.ASTNode;
import org.eclipse.dltk.ast.ASTVisitor;
import org.eclipse.dltk.ast.declarations.MethodDeclaration;
import org.eclipse.dltk.ast.declarations.ModuleDeclaration;
import org.eclipse.dltk.ast.declarations.TypeDeclaration;
import org.eclipse.dltk.ast.references.SimpleReference;
import org.eclipse.dltk.ast.references.TypeReference;
import org.eclipse.dltk.core.DLTKCore;
import org.eclipse.dltk.core.ISourceModule;
import org.eclipse.dltk.evaluation.types.AmbiguousType;
import org.eclipse.dltk.ti.GoalState;
import org.eclipse.dltk.ti.IContext;
import org.eclipse.dltk.ti.ISourceModuleContext;
import org.eclipse.dltk.ti.goals.GoalEvaluator;
import org.eclipse.dltk.ti.goals.IGoal;
import org.eclipse.dltk.ti.types.IEvaluatedType;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.compiler.ast.nodes.ClassDeclaration;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.compiler.ast.nodes.FullyQualifiedReference;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.compiler.ast.nodes.NamespaceReference;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.typeinference.PHPClassType;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.typeinference.PHPModelUtils;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.typeinference.context.INamespaceContext;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.typeinference.context.MethodContext;

public class TypeReferenceEvaluator extends GoalEvaluator {

    private final TypeReference typeReference;
    private IEvaluatedType result;

    public TypeReferenceEvaluator(IGoal goal, TypeReference typeReference) {
        super(goal);
        this.typeReference = typeReference;
    }

    @Override
    public IGoal[] init() {
        final IContext context = goal.getContext();
        String className = typeReference.getName();

        if ("self".equals(className)) { //$NON-NLS-1$
            if (context instanceof MethodContext) {
                final MethodContext methodContext = (MethodContext) context;
                final IEvaluatedType instanceType = methodContext
                        .getInstanceType();
                if (instanceType instanceof PHPClassType) {
                    result = instanceType;
                }
            }
        }
        else if ("parent".equals(className)) { //$NON-NLS-1$
            if (context instanceof MethodContext) {
                final MethodContext methodContext = (MethodContext) context;
                final ModuleDeclaration rootNode = methodContext.getRootNode();
                final MethodDeclaration methodDecl = methodContext
                        .getMethodNode();

                // Look for parent class types:
                final List<IEvaluatedType> types = new LinkedList<IEvaluatedType>();
                try {
                    rootNode.traverse(new ASTVisitor() {
                        private TypeDeclaration currentType;
                        private boolean found;

                        @Override
                        public boolean visit(MethodDeclaration s)
                                throws Exception {
                            if (s == methodDecl
                                    && currentType instanceof ClassDeclaration) {
                                final ClassDeclaration classDecl = (ClassDeclaration) currentType;

                                final ASTListNode superClasses = classDecl
                                        .getSuperClasses();
                                final List childs = superClasses.getChilds();
                                for (final Iterator iterator = childs
                                        .iterator(); iterator.hasNext();) {
                                    final ASTNode node = (ASTNode) iterator
                                            .next();
                                    NamespaceReference namespace = null;
                                    SimpleReference reference = null;
                                    if (node instanceof SimpleReference) {
                                        reference = (SimpleReference) node;
                                        if (reference instanceof FullyQualifiedReference) {
                                            final FullyQualifiedReference ref = (FullyQualifiedReference) node;
                                            namespace = ref.getNamespace();
                                        }
                                    }
                                    if (namespace == null
                                            || namespace.getName().equals("")) {
                                        types.add(new PHPClassType(reference
                                                .getName()));
                                    }
                                    else {
                                        types.add(new PHPClassType(namespace
                                                .getName(), reference.getName()));
                                    }

                                }
                                found = true;
                            }
                            return !found;
                        }

                        @Override
                        public boolean visit(TypeDeclaration s)
                                throws Exception {
                            this.currentType = s;
                            return !found;
                        }

                        @Override
                        public boolean endvisit(TypeDeclaration s)
                                throws Exception {
                            this.currentType = null;
                            return super.endvisit(s);
                        }

                        @Override
                        public boolean visit(ASTNode n) throws Exception {
                            return !found;
                        }
                    });
                } catch (final Exception e) {
                    if (DLTKCore.DEBUG) {
                        e.printStackTrace();
                    }
                }

                if (types.size() == 1) {
                    result = types.get(0);
                }
                else if (types.size() > 1) {
                    result = new AmbiguousType(
                            types.toArray(new IEvaluatedType[types.size()]));
                }
            }
        }
        else {
            String parentNamespace = null;

            // Check current context - if we are under some namespace:
            if (context instanceof INamespaceContext) {
                parentNamespace = ((INamespaceContext) context).getNamespace();
            }

            // If the namespace was prefixed explicitly - use it:
            if (typeReference instanceof FullyQualifiedReference) {
                final String fullyQualifiedName = ((FullyQualifiedReference) typeReference)
                        .getFullyQualifiedName();
                final ISourceModule sourceModule = ((ISourceModuleContext) context)
                        .getSourceModule();
                final int offset = typeReference.sourceStart();
                final String extractedNamespace = PHPModelUtils
                        .extractNamespaceName(fullyQualifiedName, sourceModule,
                                offset);
                if (extractedNamespace != null) {
                    parentNamespace = extractedNamespace;
                    className = PHPModelUtils.getRealName(fullyQualifiedName,
                            sourceModule, offset, className);
                }
            }

            if (parentNamespace != null) {
                result = new PHPClassType(parentNamespace, className);
            }
            else {
                result = new PHPClassType(className);
            }
        }

        return IGoal.NO_GOALS;
    }

    @Override
    public Object produceResult() {
        return result;
    }

    @Override
    public IGoal[] subGoalDone(IGoal subgoal, Object result, GoalState state) {
        return IGoal.NO_GOALS;
    }

}
