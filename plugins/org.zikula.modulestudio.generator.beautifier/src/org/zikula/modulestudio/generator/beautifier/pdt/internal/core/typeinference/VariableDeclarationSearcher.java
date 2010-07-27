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

import java.util.Collection;
import java.util.HashMap;
import java.util.Iterator;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;
import java.util.Stack;

import org.eclipse.dltk.ast.ASTNode;
import org.eclipse.dltk.ast.declarations.MethodDeclaration;
import org.eclipse.dltk.ast.declarations.ModuleDeclaration;
import org.eclipse.dltk.ast.declarations.TypeDeclaration;
import org.eclipse.dltk.ast.expressions.Expression;
import org.eclipse.dltk.ast.references.SimpleReference;
import org.eclipse.dltk.ast.references.VariableReference;
import org.eclipse.dltk.ast.statements.Statement;
import org.eclipse.dltk.core.ISourceModule;
import org.eclipse.dltk.ti.IContext;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.compiler.ast.nodes.ASTNodeKinds;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.compiler.ast.nodes.Assignment;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.compiler.ast.nodes.CatchClause;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.compiler.ast.nodes.ForEachStatement;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.compiler.ast.nodes.FormalParameter;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.compiler.ast.nodes.GlobalStatement;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.compiler.ast.nodes.ListVariable;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.compiler.ast.nodes.ReferenceExpression;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.typeinference.VariableDeclarationSearcher.DeclarationScope;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.typeinference.context.ContextFinder;

/**
 * This visitor builds local variable declarations tree for specified file. The
 * resulting tree contains variable declarations list (one per
 * {@link DeclarationScope}), where the list entries are possible variable
 * declarations. Examples:
 * <p>
 * 1. Here are two possible declarations for "$a":<br/>
 * 
 * <pre>
 * $a = &quot;some&quot;;
 * if (someCondition()) {
 * 	$a = &quot;other&quot;;
 * }
 * list($a, list($b)) = array(...)
 * </pre>
 * 
 * <br/>
 * </p>
 * 
 * @author michael
 */
@SuppressWarnings("unused")
public class VariableDeclarationSearcher extends ContextFinder {

    /**
     * Scope variable declarations map
     */
    private final Map<IContext, DeclarationScope> scopes = new HashMap<IContext, DeclarationScope>();

    /**
     * Stack of processed AST nodes
     */
    protected Stack<ASTNode> nodesStack = new Stack<ASTNode>();

    public VariableDeclarationSearcher(ISourceModule sourceModule) {
        super(sourceModule);
    }

    /**
     * Override to invoke additional processing on this kind of node
     * 
     * @param node
     */
    protected void postProcess(ModuleDeclaration node) {
    }

    @Override
    public final boolean visit(ModuleDeclaration node) throws Exception {
        if (!isInteresting(node)) {
            visitGeneral(node);
            return false;
        }

        postProcess(node);

        return super.visit(node);
    }

    @Override
    public final boolean endvisit(ModuleDeclaration node) throws Exception {
        return super.endvisit(node);
    }

    /**
     * Override to invoke additional processing on this kind of node
     * 
     * @param node
     */
    protected void postProcess(TypeDeclaration node) {
    }

    @Override
    public final boolean visit(TypeDeclaration node) throws Exception {
        if (!isInteresting(node)) {
            visitGeneral(node);
            return false;
        }

        postProcess(node);

        return super.visit(node);
    }

    @Override
    public final boolean endvisit(TypeDeclaration node) throws Exception {
        return super.endvisit(node);
    }

    /**
     * Override to invoke additional processing on this kind of node
     * 
     * @param node
     */
    protected void postProcess(MethodDeclaration node) {
    }

    @Override
    public final boolean visit(MethodDeclaration node) throws Exception {
        if (!isInteresting(node)) {
            visitGeneral(node);
            return false;
        }

        postProcess(node);

        return super.visit(node);
    }

    @Override
    public final boolean endvisit(MethodDeclaration node) throws Exception {
        return super.endvisit(node);
    }

    /**
     * Override to invoke additional processing on this kind of node
     * 
     * @param node
     */
    protected void postProcess(Expression node) {
    }

    @Override
    public final boolean visit(Expression node) throws Exception {
        if (!isInteresting(node)) {
            visitGeneral(node);
            return false;
        }
        final ASTNode parent = nodesStack.peek();
        if (isConditional(parent)) {
            getScope().enterInnerBlock((Statement) parent);
        }

        if (node instanceof Assignment) {
            final Expression variable = ((Assignment) node).getVariable();
            addDeclaredVariables(variable, node);
        }

        postProcess(node);

        return super.visit(node);
    }

    private void addDeclaredVariables(Expression variable, Expression node) {
        if (variable instanceof VariableReference) {
            final VariableReference varReference = (VariableReference) variable;
            getScope().addDeclaration(varReference.getName(), node);
        }
        else if (variable instanceof ListVariable) {
            final ListVariable varReference = (ListVariable) variable;
            for (final Expression nestedVar : varReference.getVariables()) {
                addDeclaredVariables(nestedVar, node);
            }
        }
    }

    @Override
    public final boolean endvisit(Expression node) throws Exception {
        return super.endvisit(node);
    }

    /**
     * Override to invoke additional processing on this kind of node
     * 
     * @param node
     */
    protected void postProcess(Statement node) {
    }

    @Override
    public final boolean visit(Statement node) throws Exception {
        if (!isInteresting(node)) {
            visitGeneral(node);
            return false;
        }

        final ASTNode parent = nodesStack.peek();
        if (isConditional(parent)) {
            getScope().enterInnerBlock((Statement) parent);
        }

        if (node instanceof GlobalStatement) {
            final GlobalStatement globalStatement = (GlobalStatement) node;
            for (final Expression variable : globalStatement.getVariables()) {
                if (variable instanceof VariableReference) {
                    final VariableReference varReference = (VariableReference) variable;
                    getScope().addDeclaration(varReference.getName(),
                            globalStatement);
                }
            }
        }
        else if (node instanceof FormalParameter) {
            final FormalParameter parameter = (FormalParameter) node;
            getScope().addDeclaration(parameter.getName(), parameter);
        }
        else if (node instanceof CatchClause) {
            final CatchClause clause = (CatchClause) node;
            final VariableReference varReference = clause.getVariable();
            getScope().addDeclaration(varReference.getName(), clause);
        }
        else if (node instanceof ForEachStatement) {
            final ForEachStatement foreachStatement = (ForEachStatement) node;

            Expression value = foreachStatement.getValue();
            if (value instanceof ReferenceExpression) { // foreach ( $array as
                // &$value )
                value = ((ReferenceExpression) value).getVariable();
            }

            if (value instanceof SimpleReference) {
                final String variableName = ((SimpleReference) value).getName();
                getScope().addDeclaration(variableName, foreachStatement);
            }

            final Expression key = foreachStatement.getKey();
            if (key instanceof SimpleReference) {
                final String variableName = ((SimpleReference) key).getName();
                getScope().addDeclaration(variableName, foreachStatement);
            }
        }

        postProcess(node);

        return super.visit(node);
    }

    @Override
    public final boolean endvisit(Statement node) throws Exception {
        if (isConditional(node)) {
            getScope().exitInnerBlock();
        }
        return super.endvisit(node);
    }

    /**
     * Override to invoke additional processing on this kind of node
     * 
     * @param node
     */
    protected void postProcessGeneral(ASTNode node) {
    }

    @Override
    public final boolean visitGeneral(ASTNode node) throws Exception {
        nodesStack.push(node);
        postProcessGeneral(node);
        return super.visitGeneral(node);
    }

    @Override
    public final void endvisitGeneral(ASTNode node) throws Exception {
        nodesStack.pop();
        super.endvisitGeneral(node);
    }

    /**
     * Returns whether the sub-tree of the given node should be processed. By
     * default it well process all nodes.
     * 
     * @param node
     * @return
     */
    protected boolean isInteresting(ASTNode node) {
        return true;
    }

    /**
     * Checks whether the given AST node makes possible conditional branch in
     * variables declaration flow.
     * 
     * @param node
     * @return
     */
    protected boolean isConditional(ASTNode node) {
        if (node instanceof Statement) {
            final int kind = ((Statement) node).getKind();
            return kind == ASTNodeKinds.CATCH_CLAUSE
                    || kind == ASTNodeKinds.IF_STATEMENT
                    || kind == ASTNodeKinds.FOR_STATEMENT
                    || kind == ASTNodeKinds.FOR_EACH_STATEMENT
                    || kind == ASTNodeKinds.SWITCH_CASE
                    || kind == ASTNodeKinds.WHILE_STATEMENT;
        }
        return false;
    }

    /**
     * Returns declaration scope for current context
     * 
     * @return
     */
    protected DeclarationScope getScope() {
        return getScope(contextStack.peek());
    }

    /**
     * Returns declaration scope for given context
     * 
     * @param context
     * @return
     */
    protected DeclarationScope getScope(IContext context) {
        if (!scopes.containsKey(context)) {
            scopes.put(context, new DeclarationScope(context));
        }
        return scopes.get(context);
    }

    /**
     * Returns all declaration scopes
     * 
     * @return
     */
    public DeclarationScope[] getScopes() {
        final Collection<DeclarationScope> values = scopes.values();
        return values.toArray(new DeclarationScope[values.size()]);
    }

    /**
     * Returns all declarations for the specified variable in the given context
     */
    public Declaration[] getDeclarations(String varName, IContext context) {
        return getScope(context).getDeclarations(varName);
    }

    /**
     * This is a container for variable declaration
     * 
     * @author michael
     */
    public class Declaration {

        private boolean global;
        private ASTNode declNode;

        public Declaration(boolean global, ASTNode declNode) {
            this.global = global;
            this.declNode = declNode;
        }

        /**
         * Whether this declaration actually belongs to global scope - global
         * $var was specified earlier.
         */
        public boolean isGlobal() {
            return global;
        }

        /**
         * Sets whether this declaration actually belongs to global scope -
         * global $var was specified earlier.
         */
        public void setGlobal(boolean global) {
            this.global = global;
        }

        /**
         * Returns the declaration node itself.
         */
        public ASTNode getNode() {
            return declNode;
        }

        /**
         * Sets the declaration node itself.
         */
        public void setNode(ASTNode declNode) {
            this.declNode = declNode;
        }
    }

    /**
     * Variable declaration scope. Each scope contains mapping between variable
     * name and its possible declarations.
     * 
     * @author michael
     */
    public class DeclarationScope {

        private final Map<String, LinkedList<Declaration>> decls = new HashMap<String, LinkedList<Declaration>>();
        private final IContext context;
        private final Stack<Statement> innerBlocks = new Stack<Statement>();

        public DeclarationScope(IContext context) {
            this.context = context;
        }

        /**
         * Returns context associated with this scope
         * 
         * @return
         */
        public IContext getContext() {
            return context;
        }

        /**
         * This must be called when entering inner conditional block.
         */
        public void enterInnerBlock(Statement s) {
            if (!innerBlocks.isEmpty() && innerBlocks.peek() == s) {
                return;
            }
            innerBlocks.push(s);
        }

        /**
         * This must be called when exiting inner conditional block.
         */
        public void exitInnerBlock() {
            if (!innerBlocks.isEmpty()) {
                innerBlocks.pop();
            }
        }

        public int getInnerBlockLevel() {
            return innerBlocks.size();
        }

        /**
         * Returns all declarations for all variables
         * 
         * @return
         */
        public Map<String, LinkedList<Declaration>> getAllDeclarations() {
            return decls;
        }

        /**
         * Returns all possible variable declarations for the given variable
         * name in current scope.
         * 
         * @param varName
         */
        public Declaration[] getDeclarations(String varName) {
            final List<Declaration> result = new LinkedList<Declaration>();
            final LinkedList<Declaration> varDecls = decls.get(varName);
            if (varDecls != null) {
                for (final Declaration decl : varDecls) {
                    if (decl != null) {
                        result.add(decl);
                    }
                }
            }
            return result.toArray(new Declaration[result.size()]);
        }

        /**
         * Adds possible variable declaration
         * 
         * @param varName
         *            Variable name
         * @param declNode
         *            AST declaration statement node
         */
        public void addDeclaration(String varName, ASTNode declNode) {
            LinkedList<Declaration> varDecls = decls.get(varName);
            if (varDecls == null) {
                varDecls = new LinkedList<Declaration>();
                decls.put(varName, varDecls);
            }

            final int level = innerBlocks.size();

            // skip all inner conditional blocks statements, since we've reached
            // a re-declaration here
            while (varDecls.size() > level + 1) {
                varDecls.removeLast();
            }

            // preserve place for declarations in outer conditional blocks
            // in case we haven't reached any declaration untill now
            while (varDecls.size() < level) {
                varDecls.addLast(null);
            }

            if (varDecls.size() > level) {
                final Declaration decl = varDecls.get(level);
                if (decl != null) {
                    // replace existing declaration with a new one (leave
                    // 'isGlobal' flag the same)
                    decl.setNode(declNode);
                    return;
                }
            }
            // add new declaration
            varDecls.addLast(new Declaration(
                    declNode instanceof GlobalStatement, declNode));
        }

        @Override
        public String toString() {
            final StringBuilder buf = new StringBuilder(
                    "Variable Declarations (").append(context)
                    .append("): \n\n");
            final Iterator<String> i = decls.keySet().iterator();
            while (i.hasNext()) {
                final String varName = i.next();
                buf.append(varName).append(" => { \n\n");
                final LinkedList<Declaration> varDecls = decls.get(varName);
                if (varDecls != null) {
                    for (final Declaration declNode : varDecls) {
                        buf.append(declNode.toString()).append(", \n\n");
                    }
                }
                buf.append("}, \n\n");
            }
            return buf.toString();
        }
    }
}
