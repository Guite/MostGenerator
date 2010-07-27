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

import java.util.LinkedList;
import java.util.List;
import java.util.Stack;

import org.eclipse.dltk.ast.ASTVisitor;
import org.eclipse.dltk.ast.declarations.Argument;
import org.eclipse.dltk.ast.declarations.MethodDeclaration;
import org.eclipse.dltk.ast.declarations.ModuleDeclaration;
import org.eclipse.dltk.ast.declarations.TypeDeclaration;
import org.eclipse.dltk.core.ISourceModule;
import org.eclipse.dltk.evaluation.types.UnknownType;
import org.eclipse.dltk.ti.IContext;
import org.eclipse.dltk.ti.ISourceModuleContext;
import org.eclipse.dltk.ti.types.IEvaluatedType;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.compiler.ast.nodes.NamespaceDeclaration;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.typeinference.PHPClassType;

/**
 * This abstract AST visitor finds type inference context
 * 
 * @author michael
 */
public abstract class ContextFinder extends ASTVisitor {

    protected Stack<IContext> contextStack = new Stack<IContext>();
    private final ISourceModule sourceModule;

    public ContextFinder(ISourceModule sourceModule) {
        this.sourceModule = sourceModule;
    }

    /**
     * This method must return found context
     * 
     * @return
     */
    public IContext getContext() {
        return null;
    }

    @Override
    public boolean visit(ModuleDeclaration node) throws Exception {
        contextStack.push(new FileContext(sourceModule, node));

        final boolean visitGeneral = visitGeneral(node);
        if (!visitGeneral) {
            contextStack.pop();
        }
        return visitGeneral;
    }

    @Override
    public boolean visit(TypeDeclaration node) throws Exception {
        if (node instanceof NamespaceDeclaration) {
            if (!((NamespaceDeclaration) node).isGlobal()) {
                final FileContext fileContext = (FileContext) contextStack
                        .peek();
                fileContext.setNamespace(node.getName());
            }
        }
        else {
            final ISourceModuleContext parentContext = (ISourceModuleContext) contextStack
                    .peek();
            PHPClassType instanceType;
            if (parentContext instanceof INamespaceContext
                    && ((INamespaceContext) parentContext).getNamespace() != null) {
                instanceType = new PHPClassType(
                        ((INamespaceContext) parentContext).getNamespace(),
                        node.getName());
            }
            else {
                instanceType = new PHPClassType(node.getName());
            }

            contextStack.push(new TypeContext(parentContext, instanceType));

            final boolean visitGeneral = visitGeneral(node);
            if (!visitGeneral) {
                contextStack.pop();
            }
            return visitGeneral;
        }

        return visitGeneral(node);
    }

    @Override
    @SuppressWarnings("unchecked")
    public boolean visit(MethodDeclaration node) throws Exception {
        final List<String> argumentsList = new LinkedList<String>();
        final List<IEvaluatedType> argTypes = new LinkedList<IEvaluatedType>();
        final List<Argument> args = node.getArguments();
        for (final Argument a : args) {
            argumentsList.add(a.getName());
            argTypes.add(UnknownType.INSTANCE);
        }
        final IContext parent = contextStack.peek();
        final ModuleDeclaration rootNode = ((ISourceModuleContext) parent)
                .getRootNode();

        contextStack.push(new MethodContext(parent, sourceModule, rootNode,
                node, argumentsList.toArray(new String[argumentsList.size()]),
                argTypes.toArray(new IEvaluatedType[argTypes.size()])));

        final boolean visitGeneral = visitGeneral(node);
        if (!visitGeneral) {
            contextStack.pop();
        }
        return visitGeneral;
    }

    @Override
    public boolean endvisit(ModuleDeclaration node) throws Exception {
        contextStack.pop();
        endvisitGeneral(node);
        return true;
    }

    @Override
    public boolean endvisit(TypeDeclaration node) throws Exception {
        if (!(node instanceof NamespaceDeclaration)) {
            contextStack.pop();
        }
        endvisitGeneral(node);
        return true;
    }

    @Override
    public boolean endvisit(MethodDeclaration node) throws Exception {
        contextStack.pop();
        endvisitGeneral(node);
        return true;
    }
}
