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

import java.util.HashMap;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;

import org.eclipse.core.runtime.IStatus;
import org.eclipse.dltk.ast.ASTNode;
import org.eclipse.dltk.ast.ASTVisitor;
import org.eclipse.dltk.ast.declarations.MethodDeclaration;
import org.eclipse.dltk.ast.declarations.ModuleDeclaration;
import org.eclipse.dltk.ast.expressions.Expression;
import org.eclipse.dltk.ast.references.VariableReference;
import org.eclipse.dltk.core.DLTKCore;
import org.eclipse.dltk.core.IMethod;
import org.eclipse.dltk.core.IModelElement;
import org.eclipse.dltk.core.ISourceModule;
import org.eclipse.dltk.core.ISourceRange;
import org.eclipse.dltk.core.ModelException;
import org.eclipse.dltk.core.SourceParserUtil;
import org.eclipse.dltk.internal.core.SourceRefElement;
import org.eclipse.dltk.ti.IContext;
import org.eclipse.dltk.ti.ISourceModuleContext;
import org.eclipse.dltk.ti.goals.ExpressionTypeGoal;
import org.eclipse.dltk.ti.types.IEvaluatedType;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.compiler.ast.nodes.ReturnStatement;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.typeinference.VariableDeclarationSearcher.Declaration;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.typeinference.context.FileContext;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.typeinference.context.MethodContext;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.typeinference.evaluators.VariableReferenceEvaluator;

/**
 * This utility allows to determine types of expressions represented in AST
 * tree. Results are cached until instance of this class is alive.
 */
public class BindingUtility {

    /** Default time limit for type inference evaluation */
    private static final int TIME_LIMIT = 500;

    private final ISourceModule sourceModule;
    private final ASTNode rootNode;
    private final Map<SourceRange, IEvaluatedType> evaluatedTypesCache = new HashMap<SourceRange, IEvaluatedType>();
    private int timeLimit = TIME_LIMIT;

    /**
     * Creates new instance of binding utility.
     * 
     * @param sourceModule
     *            Source module of the file.
     */
    public BindingUtility(ISourceModule sourceModule) {
        this.sourceModule = sourceModule;
        this.rootNode = SourceParserUtil.getModuleDeclaration(sourceModule);
    }

    /**
     * Creates new instance of binding utility
     * 
     * @param sourceModule
     *            Source module of the file.
     * @param rootNode
     *            AST tree of the the file represented by the given source
     *            module.
     */
    public BindingUtility(ISourceModule sourceModule, ASTNode rootNode) {
        this.sourceModule = sourceModule;
        this.rootNode = rootNode;
    }

    /**
     * Sets new time limit in milliseconds for the type inference evaluation.
     * Default value is 500ms.
     * 
     * @param timeLimit
     */
    public void setTimeLimit(int timeLimit) {
        this.timeLimit = timeLimit;
    }

    /**
     * This method returns evaluated type for the given AST expression node.
     * Returns cached type from previous evaluations (if exists).
     * 
     * @param node
     *            AST node that needs to be evaluated.
     * @return evaluated type.
     * @throws ModelException
     * 
     * @throws IllegalArgumentException
     *             in case if context cannot be found for the given node.
     * @throws NullPointerException
     *             if the given node is <code>null</code>.
     */
    public IEvaluatedType getType(ASTNode node) throws ModelException {
        if (node == null) {
            throw new NullPointerException();
        }
        return getType(new SourceRange(node));
    }

    /**
     * This method returns evaluated type for the given model element. Returns
     * cached type from previous evaluations (if exists).
     * 
     * @param element
     *            Model element.
     * @return evaluated type.
     * 
     * @throws IllegalArgumentException
     *             in case if context cannot be found for the given node.
     * @throws NullPointerException
     *             if the given element is <code>null</code>.
     * @throws ModelException
     */
    public IEvaluatedType getType(SourceRefElement element)
            throws ModelException {
        if (element == null) {
            throw new NullPointerException();
        }
        final ISourceModule elementModule = element.getSourceModule();
        if (!elementModule.equals(sourceModule)) {
            throw new IllegalArgumentException("Unknown model element");
        }
        return getType(new SourceRange(element.getSourceRange()));
    }

    /**
     * This method returns evaluated type for the expression under the given
     * offset and length. Returns cached type from previous evaluations (if
     * exists).
     * 
     * @param startOffset
     *            Starting offset of the expression.
     * @param length
     *            Length of the expression.
     * @return evaluated type.
     * 
     * @throws IllegalArgumentException
     *             in case if context cannot be found for the given node.
     */
    public IEvaluatedType getType(int startOffset, int length)
            throws ModelException {
        return getType(new SourceRange(startOffset, length));
    }

    protected IEvaluatedType getType(SourceRange sourceRange, IContext context,
            ASTNode node) {
        final PHPTypeInferencer typeInferencer = new PHPTypeInferencer();
        return typeInferencer.evaluateType(
                new ExpressionTypeGoal(context, node), timeLimit);
    }

    protected ContextFinder getContext(SourceRange sourceRange)
            throws ModelException {
        final ContextFinder contextFinder = new ContextFinder(sourceRange);
        try {
            rootNode.traverse(contextFinder);
        } catch (final Exception e) {
            throw new ModelException(e, IStatus.ERROR);
        }
        if (contextFinder.getNode() == null) {
            throw new ModelException(new IllegalArgumentException(
                    "AST node can not be found for the given source range: "
                            + sourceRange), IStatus.ERROR);
        }
        return contextFinder;
    }

    protected IEvaluatedType getType(SourceRange sourceRange)
            throws ModelException {
        if (!evaluatedTypesCache.containsKey(sourceRange)) {
            final ContextFinder contextFinder = getContext(sourceRange);
            evaluatedTypesCache.put(
                    sourceRange,
                    getType(sourceRange, contextFinder.getContext(),
                            contextFinder.getNode()));
        }
        return evaluatedTypesCache.get(sourceRange);
    }

    /**
     * This method returns model elements for the given AST expression node.
     * This method uses cached evaluated type from previous evaluations (if
     * exists).
     * 
     * @param node
     *            AST node that needs to be evaluated.
     * @return model element or <code>null</code> in case it couldn't be found
     * @throws ModelException
     * 
     * @throws IllegalArgumentException
     *             in case if context cannot be found for the given node.
     * @throws NullPointerException
     *             if the given node is <code>null</code>.
     */
    public IModelElement[] getModelElement(ASTNode node) throws ModelException {
        if (node == null) {
            throw new NullPointerException();
        }
        return getModelElement(new SourceRange(node), true);
    }

    /**
     * This method returns model elements for the given model element. This
     * method uses cached evaluated type from previous evaluations (if exists).
     * 
     * @param element
     *            Source Reference Model element.
     * @return model element or <code>null</code> in case it couldn't be found
     * 
     * @throws IllegalArgumentException
     *             in case if context cannot be found for the given node.
     * @throws NullPointerException
     *             if the given element is <code>null</code>.
     * @throws ModelException
     */
    public IModelElement[] getModelElement(SourceRefElement element)
            throws ModelException {
        if (element == null) {
            throw new NullPointerException();
        }
        final ISourceModule elementModule = element.getSourceModule();
        if (!elementModule.equals(sourceModule)) {
            throw new IllegalArgumentException("Unknown model element");
        }
        return getModelElement(new SourceRange(element.getSourceRange()), true);
    }

    /**
     * This method returns model elements for the expression under the given
     * offset and length, and will filter the results using the file-network.
     * This method uses cached evaluated type from previous evaluations (if
     * exists).
     * 
     * @param startOffset
     *            Starting offset of the expression.
     * @param length
     *            Length of the expression.
     * @return model element or <code>null</code> in case it couldn't be found
     * @throws ModelException
     * 
     * @throws IllegalArgumentException
     *             in case if context cannot be found for the given node.
     * @see #getModelElement(int, int, boolean)
     */
    public IModelElement[] getModelElement(int startOffset, int length)
            throws ModelException {
        return getModelElement(startOffset, length, true);
    }

    /**
     * This method returns model elements for the expression under the given
     * offset and length, and will filter the results using the file-network.
     * This method uses cached evaluated type from previous evaluations (if
     * exists).
     * 
     * @param startOffset
     *            Starting offset of the expression.
     * @param length
     *            Length of the expression.
     * @param cache
     *            Model access cache if available
     * @return model element or <code>null</code> in case it couldn't be found
     * @throws ModelException
     * 
     * @throws IllegalArgumentException
     *             in case if context cannot be found for the given node.
     * @see #getModelElement(int, int, boolean)
     */
    public IModelElement[] getModelElement(int startOffset, int length,
            IModelAccessCache cache) throws ModelException {
        return getModelElement(startOffset, length, true, cache);
    }

    /**
     * This method returns model elements for the expression under the given
     * offset and length. This method uses cached evaluated type from previous
     * evaluations (if exists).
     * 
     * @param startOffset
     *            Starting offset of the expression.
     * @param length
     *            Length of the expression.
     * @param filter
     *            Filter the results using the 'File-Network'.
     * @return model element or <code>null</code> in case it couldn't be found
     * @throws ModelException
     * 
     * @throws IllegalArgumentException
     *             in case if context cannot be found for the given node.
     */
    public IModelElement[] getModelElement(int startOffset, int length,
            boolean filter) throws ModelException {
        return getModelElement(new SourceRange(startOffset, length), filter);
    }

    /**
     * This method returns model elements for the expression under the given
     * offset and length. This method uses cached evaluated type from previous
     * evaluations (if exists).
     * 
     * @param startOffset
     *            Starting offset of the expression.
     * @param length
     *            Length of the expression.
     * @param filter
     *            Filter the results using the 'File-Network'.
     * @param cache
     *            Model access cache if available
     * @return model element or <code>null</code> in case it couldn't be found
     * @throws ModelException
     * 
     * @throws IllegalArgumentException
     *             in case if context cannot be found for the given node.
     */
    public IModelElement[] getModelElement(int startOffset, int length,
            boolean filter, IModelAccessCache cache) throws ModelException {
        return getModelElement(new SourceRange(startOffset, length), filter,
                cache);
    }

    protected IModelElement[] getModelElement(SourceRange sourceRange,
            boolean filter) throws ModelException {
        return getModelElement(sourceRange, filter, null);
    }

    protected IModelElement[] getModelElement(SourceRange sourceRange,
            boolean filter, IModelAccessCache cache) throws ModelException {
        final ContextFinder contextFinder = getContext(sourceRange);
        if (!evaluatedTypesCache.containsKey(sourceRange)) {
            evaluatedTypesCache.put(
                    sourceRange,
                    getType(sourceRange, contextFinder.getContext(),
                            contextFinder.getNode()));
        }
        final IEvaluatedType evaluatedType = evaluatedTypesCache
                .get(sourceRange);
        return PHPTypeInferenceUtils.getModelElements(evaluatedType,
                (ISourceModuleContext) contextFinder.getContext(),
                sourceRange.getOffset(), cache);
    }

    /**
     * get the IModelElement at the given position.
     * 
     * @param start
     * @param length
     * @return the IModelElement instance which represents a IField node, or
     *         null.
     * @throws Exception
     */
    public IModelElement getFieldByPosition(int start, int length)
            throws Exception {
        final SourceRange sourceRange = new SourceRange(start, length);
        final ContextFinder contextFinder = getContext(sourceRange);
        final ASTNode node = contextFinder.getNode();

        if (node instanceof VariableReference) {
            ASTNode localScopeNode = rootNode;
            final IContext context = contextFinder.getContext();
            if (context instanceof MethodContext) {
                localScopeNode = ((MethodContext) context).getMethodNode();
            }
            final VariableReferenceEvaluator.LocalReferenceDeclSearcher varDecSearcher = new VariableReferenceEvaluator.LocalReferenceDeclSearcher(
                    sourceModule, (VariableReference) node, localScopeNode);
            rootNode.traverse(varDecSearcher);

            final Declaration[] decls = varDecSearcher.getDeclarations();
            if (decls != null && decls.length > 0) {
                return this.sourceModule.getElementAt(decls[0].getNode()
                        .sourceStart());
            }
        }

        return null;
    }

    private class SourceRange {
        private final int offset;
        private final int length;

        public SourceRange(ISourceRange sourceRange) {
            offset = sourceRange.getOffset();
            length = sourceRange.getLength();
        }

        public SourceRange(int offset, int length) {
            this.length = length;
            this.offset = offset;
        }

        public SourceRange(ASTNode node) {
            this(node.sourceStart(), node.sourceEnd() - node.sourceStart());
        }

        public int getEnd() {
            return length + offset;
        }

        public int getLength() {
            return length;
        }

        public int getOffset() {
            return offset;
        }

        @Override
        public int hashCode() {
            final int prime = 31;
            int result = 1;
            result = prime * result + length;
            result = prime * result + offset;
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
            final SourceRange other = (SourceRange) obj;
            if (length != other.length) {
                return false;
            }
            if (offset != other.offset) {
                return false;
            }
            return true;
        }

        @Override
        public String toString() {
            return new StringBuilder("<offset=").append(offset)
                    .append(", length=").append(length).append(">").toString();
        }
    }

    /**
     * Finds binding context for the given AST node for internal usages only.
     */
    private class ContextFinder
            extends
            org.zikula.modulestudio.generator.beautifier.pdt.internal.core.typeinference.context.ContextFinder {

        private final SourceRange sourceRange;
        private IContext context;
        private ASTNode node;

        public ContextFinder(SourceRange sourceRange) {
            super(sourceModule);
            this.sourceRange = sourceRange;
        }

        @Override
        public IContext getContext() {
            return context;
        }

        /**
         * Returns found AST node
         * 
         * @return AST node
         */
        public ASTNode getNode() {
            return node;
        }

        @Override
        public boolean visitGeneral(ASTNode node) throws Exception {
            if (node.sourceStart() > sourceRange.getEnd()) {
                return false;
            }
            if (node.sourceEnd() < sourceRange.offset) {
                return false;
            }
            if (node.sourceStart() <= sourceRange.offset
                    && node.sourceEnd() >= sourceRange.getEnd()) {
                if (!contextStack.isEmpty()) {
                    this.context = contextStack.peek();
                    this.node = node;
                }
            }
            // search inside - we are looking for minimal node
            return true;
        }
    }

    public IEvaluatedType[] getFunctionReturnType(IMethod functionElement) {

        final ISourceModule sourceModule = functionElement.getSourceModule();
        final ModuleDeclaration sourceModuleDeclaration = SourceParserUtil
                .getModuleDeclaration(sourceModule);
        MethodDeclaration functionDeclaration = null;
        try {
            functionDeclaration = PHPModelUtils.getNodeByMethod(
                    sourceModuleDeclaration, functionElement);

        } catch (final ModelException e) {
            if (DLTKCore.DEBUG) {
                e.printStackTrace();
            }
        }
        final FileContext fileContext = new FileContext(sourceModule,
                sourceModuleDeclaration);

        final List<IEvaluatedType> evaluated = new LinkedList<IEvaluatedType>();
        final List<Expression> returnExpressions = new LinkedList<Expression>();

        if (functionDeclaration != null) {

            final ASTVisitor visitor = new ASTVisitor() {
                @Override
                public boolean visitGeneral(ASTNode node) throws Exception {
                    if (node instanceof ReturnStatement) {
                        final ReturnStatement statement = (ReturnStatement) node;
                        final Expression expr = statement.getExpr();
                        if (expr == null) {
                            evaluated.add(PHPSimpleTypes.VOID);
                        }
                        else {
                            returnExpressions.add(expr);
                        }
                    }
                    return super.visitGeneral(node);
                }
            };

            try {
                functionDeclaration.traverse(visitor);
            } catch (final Exception e) {
                if (DLTKCore.DEBUG) {
                    e.printStackTrace();
                }
            }
        }

        for (final Expression expr : returnExpressions) {
            final SourceRange sourceRange = new SourceRange(expr);
            try {
                final ContextFinder contextFinder = getContext(sourceRange);
                final IContext context = contextFinder.getContext();
                final IEvaluatedType resolvedExpression = PHPTypeInferenceUtils
                        .resolveExpression(sourceModule,
                                sourceModuleDeclaration, context, expr);
                if (resolvedExpression != null) {
                    evaluated.add(resolvedExpression);
                }
            } catch (final ModelException e) {
                if (DLTKCore.DEBUG) {
                    e.printStackTrace();
                }
                continue;
            }
        }
        return evaluated.toArray(new IEvaluatedType[evaluated.size()]);
    }
}
