package org.zikula.modulestudio.generator.beautifier.pdt.internal.core.ast.nodes;

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
 * Based on package
 * org.zikula.modulestudio.generator.beautifier.pdt.internal.core.ast.nodes;
 * 
 *******************************************************************************/

import java.io.IOException;
import java.io.Reader;
import java.lang.reflect.Constructor;
import java.lang.reflect.InvocationTargetException;
import java.util.Collection;
import java.util.List;
import java.util.Map;

import java_cup.runtime.Scanner;
import java_cup.runtime.lr_parser;

import org.eclipse.jface.text.IDocument;
import org.eclipse.text.edits.TextEdit;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.PHPVersion;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.ast.rewrite.ASTRewrite;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.ast.scanner.AstLexer;

/**
 * Umbrella owner and abstract syntax tree node factory. An <code>AST</code>
 * instance serves as the common owner of any number of AST nodes, and as the
 * factory for creating new AST nodes owned by that instance.
 * <p>
 * Abstract syntax trees may be hand constructed by clients, using the
 * <code>new<i>TYPE</i></code> factory methods to create new nodes, and the
 * various <code>set<i>CHILD</i></code> methods (see
 * {@link org.zikula.modulestudio.generator.beautifier.pdt.internal.core.ast.nodes.ASTNode}
 * and its subclasses) to connect them together.
 * </p>
 * <p>
 * Each AST node belongs to a unique AST instance, called the owning AST. The
 * children of an AST node always have the same owner as their parent node. If a
 * node from one AST is to be added to a different AST, the subtree must be
 * cloned first to ensures that the added nodes have the correct owning AST.
 * </p>
 * <p>
 * There can be any number of AST nodes owned by a single AST instance that are
 * unparented. Each of these nodes is the root of a separate little tree of
 * nodes. The method <code>ASTNode.getProgramRoot()</code> navigates from any
 * node to the root of the tree that it is contained in. Ordinarily, an AST
 * instance has one main tree (rooted at a <code>Program</code>), with
 * newly-created nodes appearing as additional roots until they are parented
 * somewhere under the main tree. One can navigate from any node to its AST
 * instance, but not conversely.
 * </p>
 * <p>
 * The class {@link ASTParser} parses a string containing a PHP source code and
 * returns an abstract syntax tree for it. The resulting nodes carry source
 * ranges relating the node back to the original source characters.
 * </p>
 * <p>
 * Programs created by <code>ASTParser</code> from a source document can be
 * serialized after arbitrary modifications with minimal loss of original
 * formatting. Here is an example:
 * 
 * <pre>
 * 
 * Document doc = new Document("<?\n class X {} \n echo 'hello world';\n  ?>");
 * ASTParser parser = ASTParser.newParser(AST.PHP5);
 * parser.setSource(doc.get().toCharArray());
 * Program program = parser.createAST(null);
 * program.recordModifications();
 * AST ast = program.getAST();
 * EchoStatement echo = ast.newEchoStatement();
 * echo.setExpression(ast.newScalar("hello world");
 * program.statements().add(echo);
 * TextEdit edits = program.rewrite(document, null);
 * UndoEdit undo = edits.apply(document);
 * 
 * </pre>
 * 
 * See also {@link ASTRewrite} for an alternative way to describe and serialize
 * changes to a read-only AST.
 * </p>
 * <p>
 * Clients may create instances of this class using {@link #newAST(int)}, but
 * this class is not intended to be subclassed.
 * </p>
 * 
 * @see ASTParser
 * @see ASTNode
 * @since 2.0
 */
public class AST {

    /**
     * The scanner capabilities to the AST - all has package access to enable
     * ASTParser access
     */
    final AstLexer lexer;
    final lr_parser parser;
    final PHPVersion apiLevel;
    final boolean useASPTags;

    /**
     * The event handler for this AST. Initially an event handler that does not
     * nothing.
     * 
     * @since 3.0
     */
    private NodeEventHandler eventHandler = new NodeEventHandler();

    /**
     * Internal modification count; initially 0; increases monotonically <b>by
     * one or more</b> as the AST is successively modified.
     */
    private long modificationCount = 0;

    /**
     * Internal original modification count; value is equals to <code>
     * modificationCount</code> at the end of the parse (<code>ASTParser
     * </code>). If this ast is not created with a parser then value is 0.
     * 
     * @since 3.0
     */
    private long originalModificationCount = 0;

    /**
     * When disableEvents > 0, events are not reported and the modification
     * count stays fixed.
     * <p>
     * This mechanism is used in lazy initialization of a node to prevent events
     * from being reported for the modification of the node as well as for the
     * creation of the missing child.
     * </p>
     * 
     * @since 3.0
     */
    private int disableEvents = 0;

    /**
     * Internal object unique to the AST instance. Readers must synchronize on
     * this object when the modifying instance fields.
     * 
     * @since 3.0
     */
    private final Object internalASTLock = new Object();

    /**
     * Default value of <code>flag<code> when a new node is created.
     */
    private int defaultNodeFlag = 0;

    /**
     * Internal ast rewriter used to record ast modification when record mode is
     * enabled.
     */
    InternalASTRewrite rewriter;

    /**
     * The binding resolver for this AST. Initially a binding resolver that does
     * not resolve names at all.
     */
    private BindingResolver resolver = new BindingResolver();

    public AST(Reader reader, PHPVersion apiLevel, boolean aspTagsAsPhp)
            throws IOException {
        this.useASPTags = aspTagsAsPhp;
        this.apiLevel = apiLevel;
        this.lexer = getLexerInstance(reader, apiLevel, aspTagsAsPhp);
        this.parser = getParserInstance(apiLevel, this.lexer);
    }

    /**
     * Constructs a scanner from a given reader
     * 
     * @param reader
     * @param phpVersion
     * @param aspTagsAsPhp
     * @return
     * @throws IOException
     */
    private AstLexer getLexerInstance(Reader reader, PHPVersion phpVersion,
            boolean aspTagsAsPhp) throws IOException {
        final AstLexer lexer53 = getLexer53(reader);
        return lexer53;
    }

    private AstLexer getLexer53(Reader reader) throws IOException {
        final org.zikula.modulestudio.generator.beautifier.pdt.internal.core.ast.scanner.php53.PhpAstLexer phpAstLexer5 = new org.zikula.modulestudio.generator.beautifier.pdt.internal.core.ast.scanner.php53.PhpAstLexer(
                reader);
        phpAstLexer5.setAST(this);
        return phpAstLexer5;
    }

    private lr_parser getParserInstance(PHPVersion phpVersion, Scanner lexer) {
        final org.zikula.modulestudio.generator.beautifier.pdt.internal.core.ast.scanner.php53.PhpAstParser parser = new org.zikula.modulestudio.generator.beautifier.pdt.internal.core.ast.scanner.php53.PhpAstParser(
                lexer);
        parser.setAST(this);
        return parser;
    }

    /**
     * Returns the modification count for this AST. The modification count is a
     * non-negative value that increases (by 1 or perhaps by more) as this AST
     * or its nodes are changed. The initial value is unspecified.
     * <p>
     * The following things count as modifying an AST:
     * <ul>
     * <li>creating a new node owned by this AST,</li>
     * <li>adding a child to a node owned by this AST,</li>
     * <li>removing a child from a node owned by this AST,</li>
     * <li>setting a non-node attribute of a node owned by this AST.</li>
     * </ul>
     * </p>
     * Operations which do not entail creating or modifying existing nodes do
     * not increase the modification count.
     * <p>
     * N.B. This method may be called several times in the course of a single
     * client operation. The only promise is that the modification count
     * increases monotonically as the AST or its nodes change; there is no
     * promise that a modifying operation increases the count by exactly 1.
     * </p>
     * 
     * @return the current value (non-negative) of the modification counter of
     *         this AST
     */
    public long modificationCount() {
        return this.modificationCount;
    }

    /**
     * Indicates that this AST is about to be modified.
     * <p>
     * The following things count as modifying an AST:
     * <ul>
     * <li>creating a new node owned by this AST</li>
     * <li>adding a child to a node owned by this AST</li>
     * <li>removing a child from a node owned by this AST</li>
     * <li>setting a non-node attribute of a node owned by this AST</li>.
     * </ul>
     * </p>
     * <p>
     * N.B. This method may be called several times in the course of a single
     * client operation.
     * </p>
     */
    void modifying() {
        // when this method is called during lazy init, events are disabled
        // and the modification count will not be increased
        if (this.disableEvents > 0) {
            return;
        }
        // increase the modification count
        this.modificationCount++;
    }

    /**
     * Disable events. This method is thread-safe for AST readers.
     * 
     * @see #reenableEvents()
     * @since 3.0
     */
    final void disableEvents() {
        synchronized (this.internalASTLock) {
            // guard against concurrent access by another reader
            this.disableEvents++;
        }
        // while disableEvents > 0 no events will be reported, and mod count
        // will stay fixed
    }

    /**
     * Reenable events. This method is thread-safe for AST readers.
     * 
     * @see #disableEvents()
     * @since 3.0
     */
    final void reenableEvents() {
        synchronized (this.internalASTLock) {
            // guard against concurrent access by another reader
            this.disableEvents--;
        }
    }

    /**
     * Reports that the given node is about to lose a child.
     * 
     * @param node
     *            the node about to be modified
     * @param child
     *            the node about to be removed
     * @param property
     *            the child or child list property descriptor
     * @since 3.0
     */
    void preRemoveChildEvent(ASTNode node, ASTNode child,
            StructuralPropertyDescriptor property) {
        // IMPORTANT: this method is called by readers during lazy init
        synchronized (this.internalASTLock) {
            // guard against concurrent access by a reader doing lazy init
            if (this.disableEvents > 0) {
                // doing lazy init OR already processing an event
                // System.out.println("[BOUNCE DEL]");
                return;
            }
            disableEvents();
        }
        try {
            this.eventHandler.preRemoveChildEvent(node, child, property);
            // N.B. even if event handler blows up, the AST is not
            // corrupted since node has not been changed yet
        } finally {
            reenableEvents();
        }
    }

    /**
     * Reports that the given node jsut lost a child.
     * 
     * @param node
     *            the node that was modified
     * @param child
     *            the child node that was removed
     * @param property
     *            the child or child list property descriptor
     * @since 3.0
     */
    void postRemoveChildEvent(ASTNode node, ASTNode child,
            StructuralPropertyDescriptor property) {
        // IMPORTANT: this method is called by readers during lazy init
        synchronized (this.internalASTLock) {
            // guard against concurrent access by a reader doing lazy init
            if (this.disableEvents > 0) {
                // doing lazy init OR already processing an event
                // System.out.println("[BOUNCE DEL]");
                return;
            }
            disableEvents();
        }
        try {
            this.eventHandler.postRemoveChildEvent(node, child, property);
            // N.B. even if event handler blows up, the AST is not
            // corrupted since node has not been changed yet
        } finally {
            reenableEvents();
        }
    }

    /**
     * Reports that the given node is about have a child replaced.
     * 
     * @param node
     *            the node about to be modified
     * @param child
     *            the child node about to be removed
     * @param newChild
     *            the replacement child
     * @param property
     *            the child or child list property descriptor
     * @since 3.0
     */
    void preReplaceChildEvent(ASTNode node, ASTNode child, ASTNode newChild,
            StructuralPropertyDescriptor property) {
        // IMPORTANT: this method is called by readers during lazy init
        synchronized (this.internalASTLock) {
            // guard against concurrent access by a reader doing lazy init
            if (this.disableEvents > 0) {
                // doing lazy init OR already processing an event
                // System.out.println("[BOUNCE REP]");
                return;
            }
            disableEvents();
        }
        try {
            this.eventHandler.preReplaceChildEvent(node, child, newChild,
                    property);
            // N.B. even if event handler blows up, the AST is not
            // corrupted since node has not been changed yet
        } finally {
            reenableEvents();
        }
    }

    /**
     * Reports that the given node has just had a child replaced.
     * 
     * @param node
     *            the node modified
     * @param child
     *            the child removed
     * @param newChild
     *            the replacement child
     * @param property
     *            the child or child list property descriptor
     * @since 3.0
     */
    void postReplaceChildEvent(ASTNode node, ASTNode child, ASTNode newChild,
            StructuralPropertyDescriptor property) {
        // IMPORTANT: this method is called by readers during lazy init
        synchronized (this.internalASTLock) {
            // guard against concurrent access by a reader doing lazy init
            if (this.disableEvents > 0) {
                // doing lazy init OR already processing an event
                // System.out.println("[BOUNCE REP]");
                return;
            }
            disableEvents();
        }
        try {
            this.eventHandler.postReplaceChildEvent(node, child, newChild,
                    property);
            // N.B. even if event handler blows up, the AST is not
            // corrupted since node has not been changed yet
        } finally {
            reenableEvents();
        }
    }

    /**
     * Reports that the given node is about to gain a child.
     * 
     * @param node
     *            the node that to be modified
     * @param child
     *            the node that to be added as a child
     * @param property
     *            the child or child list property descriptor
     * @since 3.0
     */
    void preAddChildEvent(ASTNode node, ASTNode child,
            StructuralPropertyDescriptor property) {
        // IMPORTANT: this method is called by readers during lazy init
        synchronized (this.internalASTLock) {
            // guard against concurrent access by a reader doing lazy init
            if (this.disableEvents > 0) {
                // doing lazy init OR already processing an event
                // System.out.println("[BOUNCE ADD]");
                return;
            }
            disableEvents();
        }
        try {
            this.eventHandler.preAddChildEvent(node, child, property);
            // N.B. even if event handler blows up, the AST is not
            // corrupted since node has already been changed
        } finally {
            reenableEvents();
        }
    }

    /**
     * Reports that the given node has just gained a child.
     * 
     * @param node
     *            the node that was modified
     * @param child
     *            the node that was added as a child
     * @param property
     *            the child or child list property descriptor
     * @since 3.0
     */
    void postAddChildEvent(ASTNode node, ASTNode child,
            StructuralPropertyDescriptor property) {
        // IMPORTANT: this method is called by readers during lazy init
        synchronized (this.internalASTLock) {
            // guard against concurrent access by a reader doing lazy init
            if (this.disableEvents > 0) {
                // doing lazy init OR already processing an event
                // System.out.println("[BOUNCE ADD]");
                return;
            }
            disableEvents();
        }
        try {
            this.eventHandler.postAddChildEvent(node, child, property);
            // N.B. even if event handler blows up, the AST is not
            // corrupted since node has already been changed
        } finally {
            reenableEvents();
        }
    }

    /**
     * Reports that the given node is about to change the value of a non-child
     * property.
     * 
     * @param node
     *            the node to be modified
     * @param property
     *            the property descriptor
     * @since 3.0
     */
    void preValueChangeEvent(ASTNode node, SimplePropertyDescriptor property) {
        // IMPORTANT: this method is called by readers during lazy init
        synchronized (this.internalASTLock) {
            // guard against concurrent access by a reader doing lazy init
            if (this.disableEvents > 0) {
                // doing lazy init OR already processing an event
                // System.out.println("[BOUNCE CHANGE]");
                return;
            }
            disableEvents();
        }
        try {
            this.eventHandler.preValueChangeEvent(node, property);
            // N.B. even if event handler blows up, the AST is not
            // corrupted since node has already been changed
        } finally {
            reenableEvents();
        }
    }

    /**
     * Reports that the given node has just changed the value of a non-child
     * property.
     * 
     * @param node
     *            the node that was modified
     * @param property
     *            the property descriptor
     * @since 3.0
     */
    void postValueChangeEvent(ASTNode node, SimplePropertyDescriptor property) {
        // IMPORTANT: this method is called by readers during lazy init
        synchronized (this.internalASTLock) {
            // guard against concurrent access by a reader doing lazy init
            if (this.disableEvents > 0) {
                // doing lazy init OR already processing an event
                // System.out.println("[BOUNCE CHANGE]");
                return;
            }
            disableEvents();
        }
        try {
            this.eventHandler.postValueChangeEvent(node, property);
            // N.B. even if event handler blows up, the AST is not
            // corrupted since node has already been changed
        } finally {
            reenableEvents();
        }
    }

    /**
     * Reports that the given node is about to be cloned.
     * 
     * @param node
     *            the node to be cloned
     * @since 3.0
     */
    void preCloneNodeEvent(ASTNode node) {
        synchronized (this.internalASTLock) {
            // guard against concurrent access by a reader doing lazy init
            if (this.disableEvents > 0) {
                // doing lazy init OR already processing an event
                // System.out.println("[BOUNCE CLONE]");
                return;
            }
            disableEvents();
        }
        try {
            this.eventHandler.preCloneNodeEvent(node);
            // N.B. even if event handler blows up, the AST is not
            // corrupted since node has already been changed
        } finally {
            reenableEvents();
        }
    }

    /**
     * Reports that the given node has just been cloned.
     * 
     * @param node
     *            the node that was cloned
     * @param clone
     *            the clone of <code>node</code>
     * @since 3.0
     */
    void postCloneNodeEvent(ASTNode node, ASTNode clone) {
        synchronized (this.internalASTLock) {
            // guard against concurrent access by a reader doing lazy init
            if (this.disableEvents > 0) {
                // doing lazy init OR already processing an event
                // System.out.println("[BOUNCE CLONE]");
                return;
            }
            disableEvents();
        }
        try {
            this.eventHandler.postCloneNodeEvent(node, clone);
            // N.B. even if event handler blows up, the AST is not
            // corrupted since node has already been changed
        } finally {
            reenableEvents();
        }
    }

    public BindingResolver getBindingResolver() {
        return this.resolver;
    }

    /**
     * Returns the event handler for this AST.
     * 
     * @return the event handler for this AST
     * @since 3.0
     */
    NodeEventHandler getEventHandler() {
        return this.eventHandler;
    }

    /**
     * Sets the event handler for this AST.
     * 
     * @param eventHandler
     *            the event handler for this AST
     * @since 3.0
     */
    void setEventHandler(NodeEventHandler eventHandler) {
        if (this.eventHandler == null) {
            throw new IllegalArgumentException();
        }
        this.eventHandler = eventHandler;
    }

    /**
     * Returns default node flags of new nodes of this AST.
     * 
     * @return the default node flags of new nodes of this AST
     * @since 3.0
     */
    int getDefaultNodeFlag() {
        return this.defaultNodeFlag;
    }

    /**
     * Sets default node flags of new nodes of this AST.
     * 
     * @param flag
     *            node flags of new nodes of this AST
     * @since 3.0
     */
    void setDefaultNodeFlag(int flag) {
        this.defaultNodeFlag = flag;
    }

    /**
     * Set <code>originalModificationCount</code> to the current modification
     * count
     * 
     * @since 3.0
     */
    void setOriginalModificationCount(long count) {
        this.originalModificationCount = count;
    }

    /**
     * Returns the type binding for a "well known" type.
     * <p>
     * Note that bindings are generally unavailable unless requested when the
     * AST is being built.
     * </p>
     * <p>
     * The following type names are supported:
     * <ul>
     * <li><code>"boolean"</code></li>
     * <li><code>"byte"</code></li>
     * <li><code>"char"</code></li>
     * <li><code>"double"</code></li>
     * <li><code>"float"</code></li>
     * <li><code>"int"</code></li>
     * <li><code>"long"</code></li>
     * <li><code>"short"</code></li>
     * <li><code>"void"</code></li>
     * </ul>
     * </p>
     * 
     * @param name
     *            the name of a well known type
     * @return the corresponding type binding, or <code>null</code> if the named
     *         type is not considered well known or if no binding can be found
     *         for it
     */
    public ITypeBinding resolveWellKnownType(String name) {
        if (name == null) {
            return null;
        }
        return getBindingResolver().resolveWellKnownType(name);
    }

    /**
     * Sets the binding resolver for this AST.
     * 
     * @param resolver
     *            the new binding resolver for this AST
     */
    void setBindingResolver(BindingResolver resolver) {
        if (resolver == null) {
            throw new IllegalArgumentException();
        }
        this.resolver = resolver;
    }

    /**
     * Checks that this AST operation is not used when building level JLS2 ASTs.
     * 
     * @exception UnsupportedOperationException
     * @since 3.0
     */
    void unsupportedIn2() {
        if (this.apiLevel == PHPVersion.PHP4) {
            throw new UnsupportedOperationException(
                    "Operation not supported in JLS2 AST"); //$NON-NLS-1$
        }
    }

    /**
     * Checks that this AST operation is only used when building level JLS2
     * ASTs.
     * 
     * @exception UnsupportedOperationException
     * @since 3.0
     */
    void supportedOnlyIn2() {
        if (this.apiLevel != PHPVersion.PHP4) {
            throw new UnsupportedOperationException(
                    "Operation not supported in JLS2 AST"); //$NON-NLS-1$
        }
    }

    /**
     * new Class[] {AST.class}
     * 
     * @since 3.0
     */
    private static final Class[] AST_CLASS = new Class[] { AST.class };

    /**
     * new Object[] {this}
     * 
     * @since 3.0
     */
    private final Object[] THIS_AST = new Object[] { this };

    /*
     * Must not collide with a value for IProgram constants
     */
    static final int RESOLVED_BINDINGS = 0x80000000;

    /**
     * Tag bit value. This represents internal state of the tree.
     */
    private int bits;

    /**
     * Creates an unparented node of the given node class (non-abstract subclass
     * of {@link ASTNode}).
     * 
     * @param nodeClass
     *            AST node class
     * @return a new unparented node owned by this AST
     * @exception IllegalArgumentException
     *                if <code>nodeClass</code> is <code>null</code> or is not a
     *                concrete node type class
     * @since 3.0
     */
    public ASTNode createInstance(Class nodeClass) {
        if (nodeClass == null) {
            throw new IllegalArgumentException();
        }
        try {
            // invoke constructor with signature Foo(AST)
            final Constructor c = nodeClass.getDeclaredConstructor(AST_CLASS);
            final Object result = c.newInstance(this.THIS_AST);
            return (ASTNode) result;
        } catch (final NoSuchMethodException e) {
            // all AST node classes have a Foo(AST) constructor
            // therefore nodeClass is not legit
            throw new IllegalArgumentException();
        } catch (final InstantiationException e) {
            // all concrete AST node classes can be instantiated
            // therefore nodeClass is not legit
            throw new IllegalArgumentException();
        } catch (final IllegalAccessException e) {
            // all AST node classes have an accessible Foo(AST) constructor
            // therefore nodeClass is not legit
            throw new IllegalArgumentException();
        } catch (final InvocationTargetException e) {
            // concrete AST node classes do not die in the constructor
            // therefore nodeClass is not legit
            throw new IllegalArgumentException();
        }
    }

    /**
     * Creates an unparented node of the given node type. This convenience
     * method is equivalent to:
     * 
     * <pre>
     * createInstance(ASTNode.nodeClassForType(nodeType))
     * </pre>
     * 
     * @param nodeType
     *            AST node type, one of the node type constants declared on
     *            {@link ASTNode}
     * @return a new unparented node owned by this AST
     * @exception IllegalArgumentException
     *                if <code>nodeType</code> is not a legal AST node type
     * @since 3.0
     */
    public ASTNode createInstance(int nodeType) {
        // nodeClassForType throws IllegalArgumentException if nodeType is bogus
        final Class nodeClass = ASTNode.nodeClassForType(nodeType);
        return createInstance(nodeClass);
    }

    // =============================== TYPES ===========================

    /**
     * Enables the recording of changes to the given compilation unit and its
     * descendents. The compilation unit must have been created by
     * <code>ASTParser</code> and still be in its original state. Once recording
     * is on, arbitrary changes to the subtree rooted at the compilation unit
     * are recorded internally. Once the modification has been completed, call
     * <code>rewrite</code> to get an object representing the corresponding
     * edits to the original source code string.
     * 
     * @exception IllegalArgumentException
     *                if this compilation unit is marked as unmodifiable, or if
     *                this compilation unit has already been tampered with, or
     *                if recording has already been enabled, or if
     *                <code>root</code> is not owned by this AST
     * @see Program#recordModifications()
     * @since 3.0
     */
    void recordModifications(Program root) {
        if (this.modificationCount != this.originalModificationCount) {
            throw new IllegalArgumentException("AST is already modified"); //$NON-NLS-1$
        }
        else if (this.rewriter != null) {
            throw new IllegalArgumentException(
                    "AST modifications are already recorded"); //$NON-NLS-1$
        }
        else if ((root.getFlags() & ASTNode.PROTECT) != 0) {
            throw new IllegalArgumentException("Root node is unmodifiable"); //$NON-NLS-1$
        }
        else if (root.getAST() != this) {
            throw new IllegalArgumentException(
                    "Root node is not owned by this ast"); //$NON-NLS-1$
        }

        this.rewriter = new InternalASTRewrite(root);
        this.setEventHandler(this.rewriter);
    }

    /**
     * Converts all modifications recorded into an object representing the
     * corresponding text edits to the given document containing the original
     * source code for the compilation unit that gave rise to this AST.
     * 
     * @param document
     *            original document containing source code for the compilation
     *            unit
     * @param options
     *            the table of formatter options (key type: <code>String</code>;
     *            value type: <code>String</code>); or <code>null</code> to use
     *            the standard global options {@link PHPCore#getOptions()
     *            PHPCore.getOptions()}.
     * @return text edit object describing the changes to the document
     *         corresponding to the recorded AST modifications
     * @exception IllegalArgumentException
     *                if the document passed is <code>null</code> or does not
     *                correspond to this AST
     * @exception IllegalStateException
     *                if <code>recordModifications</code> was not called to
     *                enable recording
     * @see Program#rewrite(IDocument, Map)
     * @since 3.0
     */
    TextEdit rewrite(IDocument document, Map options) {
        if (document == null) {
            throw new IllegalArgumentException();
        }
        if (this.rewriter == null) {
            throw new IllegalStateException(
                    "Modifications record is not enabled"); //$NON-NLS-1$
        }
        return this.rewriter.rewriteAST(document, options);
    }

    /**
     * Returns true if the ast tree was created with bindings, false otherwise
     * 
     * @return true if the ast tree was created with bindings, false otherwise
     * @since 3.3
     */
    public boolean hasResolvedBindings() {
        return (this.bits & RESOLVED_BINDINGS) != 0;
    }

    /**
     * Returns true if the ast tree was created with statements recovery, false
     * otherwise
     * 
     * @return true if the ast tree was created with statements recovery, false
     *         otherwise
     * @since 3.3
     */
    /*
     * public boolean hasStatementsRecovery() { return (this.bits &
     * IProgram.ENABLE_STATEMENTS_RECOVERY) != 0; }
     */
    /**
     * Returns true if the ast tree was created with bindings recovery, false
     * otherwise
     * 
     * @return true if the ast tree was created with bindings recovery, false
     *         otherwise
     * @since 3.3
     */
    /*
     * public boolean hasBindingsRecovery() { return (this.bits &
     * IProgram.ENABLE_BINDINGS_RECOVERY) != 0; }
     */
    void setFlag(int newValue) {
        this.bits |= newValue;
    }

    /**
     * @return The lexer used by this AST
     */
    public AstLexer lexer() {
        return lexer;
    }

    /**
     * @return The parser used by this AST
     */
    public lr_parser parser() {
        return parser;
    }

    /**
     * @return The API level used by this AST
     */
    public PHPVersion apiLevel() {
        return apiLevel;
    }

    /**
     * @return true if this AST "permits" ASP tags
     */
    public boolean useASPTags() {
        return useASPTags;
    }

    /**
     * @return true if this AST "permits" ASP tags
     * @throws IOException
     */
    public void setSource(Reader reader) throws IOException {
        if (reader == null) {
            throw new IllegalArgumentException();
        }
        this.lexer.yyreset(reader);
        this.lexer.resetCommentList();
        this.parser.setScanner(this.lexer);
    }

    /**
     * Creates a new {@link ArrayAccess}.
     * 
     * @return a new ArrayAccess.
     */
    public ArrayAccess newArrayAccess() {
        final ArrayAccess arrayAccess = new ArrayAccess(this);
        return arrayAccess;
    }

    /**
     * Creates a new {@link ArrayAccess}.
     * 
     * @param variableName
     * @param index
     * @param arrayType
     * @return a new ArrayAccess
     */
    public ArrayAccess newArrayAccess(VariableBase variableName,
            Expression index, int arrayType) {
        final ArrayAccess arrayAccess = new ArrayAccess(this);
        arrayAccess.setName(variableName);
        arrayAccess.setIndex(index);
        arrayAccess.setArrayType(arrayType);
        return arrayAccess;
    }

    /**
     * Creates a new {@link ArrayAccess}. Default array type is VARIABLE_ARRAY
     * 
     * @param variableName
     * @param index
     * @return a new ArrayAccess
     */
    public ArrayAccess newArrayAccess(VariableBase variableName,
            Expression index) {
        final ArrayAccess arrayAccess = new ArrayAccess(this);
        arrayAccess.setName(variableName);
        arrayAccess.setIndex(index);
        arrayAccess.setArrayType(ArrayAccess.VARIABLE_ARRAY);
        return arrayAccess;
    }

    /**
     * Creates a new {@link ArrayCreation}.
     * 
     * @return a new ArrayCreation.
     */
    public ArrayCreation newArrayCreation() {
        final ArrayCreation arrayCreation = new ArrayCreation(this);
        return arrayCreation;
    }

    /**
     * Creates a new {@link ArrayCreation}.
     * 
     * @param elements
     *            - List of {@link ArrayElement}
     * @return a new ArrayCreation.
     */
    public ArrayCreation newArrayCreation(List<ArrayElement> elements) {
        final ArrayCreation arrayCreation = new ArrayCreation(this);
        arrayCreation.elements().addAll(elements);
        return arrayCreation;
    }

    /**
     * Creates a new {@link ArrayElement}.
     * 
     * @return a new ArrayElement.
     */
    public ArrayElement newArrayElement() {
        final ArrayElement arrayElement = new ArrayElement(this);
        return arrayElement;
    }

    /**
     * Creates a new {@link ArrayElement}.
     * 
     * @param key
     *            - an {@link Expression} rapresenting the element key
     * @param value
     *            - an {@link Expression} rapresenting the element value
     * @return a new ArrayElement.
     */
    public ArrayElement newArrayElement(Expression key, Expression value) {
        final ArrayElement arrayElement = new ArrayElement(this);
        arrayElement.setKey(key);
        arrayElement.setValue(value);
        return arrayElement;
    }

    /**
     * Creates a new {@link Assignment}.
     * 
     * @return A new Assignment.
     */
    public Assignment newAssignment() {
        final Assignment assignment = new Assignment(this);
        return assignment;
    }

    /**
     * Creates a new {@link Assignment}.
     * 
     * @param leftHandSide
     *            A {@link VariableBase}
     * @param operator
     *            The assignment operator
     * @param rightHandSide
     *            An {@link Expression}
     * @return A new Assignment.
     */
    public Assignment newAssignment(VariableBase leftHandSide, int operator,
            Expression rightHandSide) {
        final Assignment assignment = new Assignment(this);
        assignment.setLeftHandSide(leftHandSide);
        assignment.setOperator(operator);
        assignment.setRightHandSide(rightHandSide);
        return assignment;
    }

    /**
     * Creates a new {@link ASTError}.
     * 
     * @return A new ASTError.
     */
    public ASTError newASTError() {
        final ASTError astError = new ASTError(this);
        return astError;
    }

    /**
     * Creates a new {@link BackTickExpression}.
     * 
     * @return A new BackTickExpression.
     */
    public BackTickExpression newBackTickExpression() {
        final BackTickExpression backTickExpression = new BackTickExpression(
                this);
        return backTickExpression;
    }

    /**
     * Creates a new {@link BackTickExpression}.
     * 
     * @param expressions
     *            - List of {@link Expression}
     * @return A new BackTickExpression.
     */
    public BackTickExpression newBackTickExpression(List<Expression> expressions) {
        final BackTickExpression backTickExpression = new BackTickExpression(
                this);
        backTickExpression.expressions().addAll(expressions);
        return backTickExpression;
    }

    /**
     * Creates an unparented block node owned by this AST, for an empty list of
     * statements.
     * 
     * @return a new unparented, empty curly block node
     */
    public Block newBlock() {
        final Block block = new Block(this);
        block.setIsCurly(true);
        return block;
    }

    /**
     * Creates an unparented block node owned by this AST, for an empty list of
     * statements.
     * 
     * @param statements
     *            - List of {@link Statement}
     * @return a new unparented, empty block node
     */
    public Block newBlock(List<Statement> statements) {
        final Block block = new Block(this);
        block.statements().addAll(statements);
        block.setIsCurly(true);
        return block;

    }

    /**
     * Creates a new {@link BreakStatement}.
     * 
     * @return A new BreakStatement.
     */
    public BreakStatement newBreakStatement() {
        final BreakStatement breakStatement = new BreakStatement(this);
        return breakStatement;
    }

    /**
     * Creates a new {@link BreakStatement}.
     * 
     * @param expression
     *            .
     * @return A new BreakStatement.
     */
    public BreakStatement newBreakStatement(Expression expression) {
        final BreakStatement breakStatement = new BreakStatement(this);
        breakStatement.setExpression(expression);
        return breakStatement;
    }

    /**
     * Creates a new {@link CastExpression}.
     * 
     * @return A new CastExpression.
     */
    public CastExpression newCastExpression() {
        final CastExpression castExpression = new CastExpression(this);
        return castExpression;
    }

    /**
     * Creates a new {@link CastExpression}.
     * 
     * @param expression
     * @param castType
     * @return A new CastExpression.
     */
    public CastExpression newCastExpression(Expression expression, int castType) {
        final CastExpression castExpression = new CastExpression(this);
        castExpression.setExpression(expression);
        castExpression.setCastingType(castType);
        return castExpression;
    }

    /**
     * Creates a new {@link CatchClause}.
     * 
     * @return A new CatchClause.
     */
    public CatchClause newCatchClause() {
        final CatchClause catchClause = new CatchClause(this);
        return catchClause;
    }

    /**
     * Creates a new {@link CatchClause}.
     * 
     * @param className
     * @param variable
     * @param statement
     * @return A new CatchClause.
     */
    public CatchClause newCatchClause(Identifier className, Variable variable,
            Block statement) {
        final CatchClause catchClause = new CatchClause(this);
        catchClause.setClassName(className);
        catchClause.setVariable(variable);
        catchClause.setBody(statement);
        return catchClause;
    }

    /**
     * Creates a new {@link ConstantDeclaration}.
     * 
     * @return A new ClassConstantDeclaration.
     */
    public ConstantDeclaration newClassConstantDeclaration() {
        final ConstantDeclaration classConstantDeclaration = new ConstantDeclaration(
                this);
        return classConstantDeclaration;
    }

    /**
     * Creates a new {@link ConstantDeclaration}.
     * 
     * @param names
     * @param initializers
     * @return A new ClassConstantDeclaration.
     */
    public ConstantDeclaration newClassConstantDeclaration(
            List<Identifier> names, List<Expression> initializers) {
        final ConstantDeclaration classConstantDeclaration = new ConstantDeclaration(
                this);
        classConstantDeclaration.initializers().addAll(initializers);
        classConstantDeclaration.names().addAll(names);
        return classConstantDeclaration;
    }

    /**
     * Creates a new {@link ClassDeclaration}.
     * 
     * @return A new ClassDeclaration.
     */
    public ClassDeclaration newClassDeclaration() {
        final ClassDeclaration classDeclaration = new ClassDeclaration(this);
        return classDeclaration;
    }

    /**
     * Creates a new {@link ClassDeclaration}.
     * 
     * @param modifier
     * @param className
     * @param superClass
     * @param interfaces
     * @param body
     * @return A new ClassDeclaration.
     */
    public ClassDeclaration newClassDeclaration(int modifier, String className,
            String superClass, List<Identifier> interfaces, Block body) {
        final ClassDeclaration classDeclaration = new ClassDeclaration(this);
        classDeclaration.setModifier(modifier);
        classDeclaration.setName(newIdentifier(className));
        if (superClass != null) {
            classDeclaration.setSuperClass(newIdentifier(superClass));
        }
        else {
            classDeclaration.setSuperClass(null);
        }
        classDeclaration.interfaces().addAll(interfaces);
        classDeclaration.setBody(body);
        return classDeclaration;
    }

    /**
     * Creates a new {@link ClassInstanceCreation}.
     * 
     * @return A new ClassInstanceCreation.
     */
    public ClassInstanceCreation newClassInstanceCreation() {
        final ClassInstanceCreation classInstanceCreation = new ClassInstanceCreation(
                this);
        return classInstanceCreation;
    }

    /**
     * Creates a new {@link ClassInstanceCreation}.
     * 
     * @param className
     * @param ctorParams
     * @return A new ClassInstanceCreation.
     */
    public ClassInstanceCreation newClassInstanceCreation(ClassName className,
            List<Expression> ctorParams) {
        final ClassInstanceCreation classInstanceCreation = new ClassInstanceCreation(
                this);
        classInstanceCreation.setClassName(className);
        classInstanceCreation.ctorParams().addAll(ctorParams);
        return classInstanceCreation;
    }

    /**
     * Creates a new {@link ClassName}.
     * 
     * @return A new ClassName.
     */
    public ClassName newClassName() {
        final ClassName className = new ClassName(this);
        return className;
    }

    /**
     * Creates a new {@link ClassName}.
     * 
     * @param name
     * @return A new ClassName.
     */
    public ClassName newClassName(Expression name) {
        final ClassName className = new ClassName(this);
        className.setClassName(name);
        return className;
    }

    /**
     * Creates a new {@link CloneExpression}.
     * 
     * @return A new CloneExpression.
     */
    public CloneExpression newCloneExpression() {
        final CloneExpression cloneExpression = new CloneExpression(this);
        return cloneExpression;
    }

    /**
     * Creates a new {@link CloneExpression}.
     * 
     * @param expr
     * @return A new CloneExpression.
     */
    public CloneExpression newCloneExpression(Expression expr) {
        final CloneExpression cloneExpression = new CloneExpression(this);
        cloneExpression.setExpression(expr);
        return cloneExpression;
    }

    /**
     * Creates a new {@link Comment}.
     * 
     * @return A new Comment.
     */
    public Comment newComment() {
        final Comment comment = new Comment(this);
        return comment;
    }

    /**
     * Creates a new {@link Comment}.
     * 
     * @param commentType
     * @return A new Comment.
     */
    public Comment newComment(int commentType) {
        final Comment comment = new Comment(this);
        comment.setCommentType(commentType);
        return comment;
    }

    /**
     * Creates a new {@link ConditionalExpression}.
     * 
     * @return A new ConditionalExpression.
     */
    public ConditionalExpression newConditionalExpression() {
        final ConditionalExpression conditionalExpression = new ConditionalExpression(
                this);
        return conditionalExpression;
    }

    /**
     * Creates a new {@link ConditionalExpression}.
     * 
     * @param condition
     * @param ifTrue
     * @param ifFalse
     * @return A new ConditionalExpression.
     */
    public ConditionalExpression newConditionalExpression(Expression condition,
            Expression ifTrue, Expression ifFalse) {
        final ConditionalExpression conditionalExpression = new ConditionalExpression(
                this);
        conditionalExpression.setCondition(condition);
        conditionalExpression.setIfTrue(ifTrue);
        conditionalExpression.setIfFalse(ifFalse);
        return conditionalExpression;
    }

    /**
     * Creates a new {@link ContinueStatement}.
     * 
     * @return A new ContinueStatement.
     */
    public ContinueStatement newContinueStatement() {
        final ContinueStatement continueStatement = new ContinueStatement(this);
        return continueStatement;
    }

    /**
     * Creates a new {@link ContinueStatement}.
     * 
     * @param expr
     * @return A new ContinueStatement.
     */
    public ContinueStatement newContinueStatement(Expression expr) {
        final ContinueStatement continueStatement = new ContinueStatement(this);
        continueStatement.setExpression(expr);
        return continueStatement;
    }

    /**
     * Creates a new {@link DeclareStatement}.
     * 
     * @param directiveNames
     * @param directiveValues
     * @param body
     * @return A new DeclareStatement.
     */
    public DeclareStatement newDeclareStatement(
            List<Identifier> directiveNames, List<Expression> directiveValues,
            Statement body) {
        final DeclareStatement declareStatement = new DeclareStatement(this);
        declareStatement.directiveNames().addAll(directiveNames);
        declareStatement.directiveValues().addAll(directiveValues);
        declareStatement.setBody(body);
        return declareStatement;
    }

    /**
     * Creates a new {@link DoStatement}.
     * 
     * @return A new DoStatement.
     */
    public DoStatement newDoStatement() {
        final DoStatement doStatement = new DoStatement(this);
        return doStatement;
    }

    /**
     * Creates a new {@link DoStatement}.
     * 
     * @param condition
     * @param body
     * @return A new DoStatement.
     */
    public DoStatement newDoStatement(Expression condition, Statement body) {
        final DoStatement doStatement = new DoStatement(this);
        doStatement.setCondition(condition);
        doStatement.setBody(body);
        return doStatement;
    }

    /**
     * Creates a new {@link EchoStatement}.
     * 
     * @return A new EchoStatement.
     */
    public EchoStatement newEchoStatement() {
        final EchoStatement echoStatement = new EchoStatement(this);
        return echoStatement;
    }

    /**
     * Creates a new {@link EchoStatement}.
     * 
     * @param expressions
     * @return A new EchoStatement.
     */
    public EchoStatement newEchoStatement(List<Expression> expressions) {
        final EchoStatement echoStatement = new EchoStatement(this);
        echoStatement.expressions().addAll(expressions);
        return echoStatement;
    }

    /**
     * Creates a new {@link EchoStatement} with a given {@link Expression}.
     * 
     * @param expression
     *            An {@link Expression} to set into the returned
     *            {@link EchoStatement}.
     * @return A new EchoStatement with the given Expression.
     */
    public EchoStatement newEchoStatement(Expression expression) {
        final EchoStatement echoStatement = new EchoStatement(this);
        echoStatement.expressions().add(expression);
        return echoStatement;
    }

    /**
     * Creates a new {@link EmptyStatement}.
     * 
     * @return A new EmptyStatement.
     */
    public EmptyStatement newEmptyStatement() {
        final EmptyStatement emptyStatement = new EmptyStatement(this);
        return emptyStatement;
    }

    /**
     * Creates a new {@link ExpressionStatement}.
     * 
     * @return A new ExpressionStatement.
     */
    public ExpressionStatement newExpressionStatement() {
        final ExpressionStatement expressionStatement = new ExpressionStatement(
                this);
        return expressionStatement;
    }

    /**
     * Creates a new {@link ExpressionStatement} with a given {@link Expression}
     * as an expression.
     * 
     * @param identifier
     *            The {@link Expression} that is the expression of the
     *            statement.
     * @return A new ExpressionStatement
     */
    public ExpressionStatement newExpressionStatement(Expression expression) {
        final ExpressionStatement statement = newExpressionStatement();
        statement.setExpression(expression);
        return statement;
    }

    /**
     * Creates a new {@link FieldAccess}.
     * 
     * @return A new FieldAccess.
     */
    public FieldAccess newFieldAccess() {
        final FieldAccess fieldAccess = new FieldAccess(this);
        return fieldAccess;
    }

    /**
     * Creates a new {@link FieldAccess}.
     * 
     * @param dispatcher
     * @param field
     * @return A new FieldAccess.
     */
    public FieldAccess newFieldAccess(VariableBase dispatcher, Variable field) {
        final FieldAccess fieldAccess = new FieldAccess(this);
        fieldAccess.setDispatcher(dispatcher);
        fieldAccess.setField(field);
        return fieldAccess;
    }

    /**
     * Creates a new {@link FieldsDeclaration}.
     * 
     * @return A new FieldsDeclaration.
     */
    public FieldsDeclaration newFieldsDeclaration() {
        final FieldsDeclaration fieldsDeclaration = new FieldsDeclaration(this);
        return fieldsDeclaration;
    }

    /**
     * Creates a new {@link FieldsDeclaration}.
     * 
     * @param modifier
     * @param variablesAndDefaults
     * @return A new FieldsDeclaration.
     */
    public FieldsDeclaration newFieldsDeclaration(int modifier,
            List<SingleFieldDeclaration> variablesAndDefaults) {
        final FieldsDeclaration fieldsDeclaration = new FieldsDeclaration(this);
        fieldsDeclaration.setModifier(modifier);
        final List<SingleFieldDeclaration> fields = fieldsDeclaration.fields();
        fields.addAll(variablesAndDefaults);
        return fieldsDeclaration;
    }

    /**
     * Creates a new {@link ForEachStatement}.
     * 
     * @return A new ForEachStatement.
     */
    public ForEachStatement newForEachStatement() {
        final ForEachStatement forEachStatement = new ForEachStatement(this);
        return forEachStatement;
    }

    /**
     * Creates a new {@link ForEachStatement}.
     * 
     * @param expression
     * @param key
     * @param value
     * @param statement
     * @return A new ForEachStatement.
     */
    public ForEachStatement newForEachStatement(Expression expression,
            Expression key, Expression value, Statement statement) {
        final ForEachStatement forEachStatement = new ForEachStatement(this);
        forEachStatement.setExpression(expression);
        forEachStatement.setKey(key);
        forEachStatement.setValue(value);
        forEachStatement.setStatement(statement);
        return forEachStatement;
    }

    /**
     * Creates a new {@link FormalParameter}.
     * 
     * @return A new FormalParameter.
     */
    public FormalParameter newFormalParameter() {
        final FormalParameter formalParameter = new FormalParameter(this);
        return formalParameter;
    }

    /**
     * Creates a new {@link FormalParameter}.
     * 
     * @param type
     * @param parameterName
     * @param defaultValue
     * @param isMandatory
     *            The mandatory field is only effective when the API level is
     *            AST.PHP4
     * @return A new FormalParameter.
     */
    public FormalParameter newFormalParameter(Identifier type,
            Expression parameterName, Expression defaultValue,
            boolean isMandatory) {
        final FormalParameter formalParameter = new FormalParameter(this);
        formalParameter.setParameterType(type);
        formalParameter.setParameterName(parameterName);
        formalParameter.setDefaultValue(defaultValue);
        if (apiLevel() == PHPVersion.PHP4) {
            formalParameter.setIsMandatory(isMandatory);
        }
        return formalParameter;
    }

    /**
     * Creates a new {@link ForStatement}.
     * 
     * @return A new ForStatement.
     */
    public ForStatement newForStatement() {
        final ForStatement forStatement = new ForStatement(this);
        return forStatement;
    }

    /**
     * Creates a new {@link ForStatement}.
     * 
     * @param initializers
     * @param conditions
     * @param updaters
     * @param body
     * @return A new ForStatement.
     */
    public ForStatement newForStatement(List<Expression> initializers,
            List<Expression> conditions, List<Expression> updaters,
            Statement body) {
        final ForStatement forStatement = new ForStatement(this);
        forStatement.initializers().addAll(initializers);
        forStatement.updaters().addAll(updaters);
        forStatement.conditions().addAll(conditions);
        forStatement.setBody(body);
        return forStatement;
    }

    /**
     * Creates a new {@link FunctionDeclaration}.
     * 
     * @return A new FunctionDeclaration.
     */
    public FunctionDeclaration newFunctionDeclaration() {
        final FunctionDeclaration functionDeclaration = new FunctionDeclaration(
                this);
        return functionDeclaration;
    }

    /**
     * Creates a new {@link FunctionDeclaration}.
     * 
     * @param functionName
     * @param formalParameters
     * @param body
     * @param isReference
     * @return A new FunctionDeclaration.
     */
    public FunctionDeclaration newFunctionDeclaration(Identifier functionName,
            List<FormalParameter> formalParameters, Block body,
            final boolean isReference) {
        final FunctionDeclaration functionDeclaration = new FunctionDeclaration(
                this);
        functionDeclaration.setFunctionName(functionName);
        functionDeclaration.formalParameters().addAll(formalParameters);
        functionDeclaration.setBody(body);
        functionDeclaration.setIsReference(isReference);
        return functionDeclaration;
    }

    /**
     * Creates a new {@link FunctionInvocation}.
     * 
     * @return A new FunctionInvocation.
     */
    public FunctionInvocation newFunctionInvocation() {
        final FunctionInvocation functionInvocation = new FunctionInvocation(
                this);
        return functionInvocation;
    }

    /**
     * Creates a new {@link FunctionInvocation}.
     * 
     * @param functionName
     * @param parameters
     *            (can be null to indicate no parameters)
     * @return A new FunctionInvocation.
     */
    public FunctionInvocation newFunctionInvocation(FunctionName functionName,
            List<Expression> parameters) {
        final FunctionInvocation functionInvocation = new FunctionInvocation(
                this);
        functionInvocation.setFunctionName(functionName);
        if (parameters != null) {
            functionInvocation.parameters().addAll(parameters);
        }
        return functionInvocation;
    }

    /**
     * Creates a new {@link FunctionName}.
     * 
     * @return A new FunctionName.
     */
    public FunctionName newFunctionName() {
        final FunctionName functionName = new FunctionName(this);
        return functionName;
    }

    /**
     * Creates a new {@link FunctionName}.
     * 
     * @param functionName
     * @return A new FunctionName.
     */
    public FunctionName newFunctionName(Expression name) {
        final FunctionName functionName = new FunctionName(this);
        functionName.setName(name);
        return functionName;
    }

    /**
     * Creates a new {@link FieldsDeclaration}.
     * 
     * @return A new FieldsDeclaration.
     */
    public GlobalStatement newGlobalStatement() {
        final GlobalStatement globalStatement = new GlobalStatement(this);
        return globalStatement;
    }

    /**
     * Creates a new {@link FieldsDeclaration}.
     * 
     * @param variables
     * @return A new FieldsDeclaration.
     */
    public GlobalStatement newGlobalStatement(List<Variable> variables) {
        final GlobalStatement globalStatement = new GlobalStatement(this);
        globalStatement.variables().addAll(variables);
        return globalStatement;
    }

    /**
     * Creates a new {@link Identifier}.
     * 
     * @return A new Identifier.
     */
    public Identifier newIdentifier() {
        final Identifier identifier = new Identifier(this);
        return identifier;
    }

    /**
     * Creates and returns a new unparented simple name node for the given
     * identifier. The identifier should be a legal PHP identifier.
     * 
     * @param identifier
     *            the identifier
     * @return a new unparented simple name node
     * @exception IllegalArgumentException
     *                if the identifier is invalid
     */
    public Identifier newIdentifier(String identifier) {

        if (identifier == null) {
            throw new IllegalArgumentException();
        }
        final Identifier result = new Identifier(this);
        result.setName(identifier);
        return result;
    }

    /**
     * Creates a new {@link IfStatement}.
     * 
     * @return A new IfStatement.
     */
    public IfStatement newIfStatement() {
        final IfStatement ifStatement = new IfStatement(this);
        return ifStatement;
    }

    /**
     * Creates a new {@link IfStatement}.
     * 
     * @param condition
     * @param trueStatement
     * @param falseStatement
     * @return A new IfStatement.
     */
    public IfStatement newIfStatement(Expression condition,
            Statement trueStatement, Statement falseStatement) {
        final IfStatement ifStatement = new IfStatement(this);
        ifStatement.setCondition(condition);
        ifStatement.setTrueStatement(trueStatement);
        ifStatement.setFalseStatement(falseStatement);
        return ifStatement;
    }

    /**
     * Creates a new {@link IgnoreError}.
     * 
     * @return A new IgnoreError.
     */
    public IgnoreError newIgnoreError() {
        final IgnoreError ignoreError = new IgnoreError(this);
        return ignoreError;
    }

    /**
     * Creates a new {@link IgnoreError}.
     * 
     * @param expression
     * @return A new IgnoreError.
     */
    public IgnoreError newIgnoreError(Expression expression) {
        final IgnoreError ignoreError = new IgnoreError(this);
        ignoreError.setExpression(expression);
        return ignoreError;
    }

    /**
     * Creates a new {@link Include}.
     * 
     * @return A new Include.
     */
    public Include newInclude() {
        final Include include = new Include(this);
        return include;
    }

    /**
     * Creates a new {@link Include}.
     * 
     * @param expression
     * @param type
     * @return A new Include.
     */
    public Include newInclude(Expression expr, int type) {
        final Include include = new Include(this);
        include.setExpression(expr);
        include.setIncludetype(type);
        return include;
    }

    /**
     * Creates a new {@link InfixExpression}.
     * 
     * @return A new InfixExpression.
     */
    public InfixExpression newInfixExpression() {
        final InfixExpression infixExpression = new InfixExpression(this);
        return infixExpression;
    }

    /**
     * Creates a new {@link InfixExpression}.
     * 
     * @param left
     * @param operator
     * @param right
     * @return A new InfixExpression.
     */
    public InfixExpression newInfixExpression(Expression left, int operator,
            Expression right) {
        final InfixExpression infixExpression = new InfixExpression(this);
        infixExpression.setLeft(left);
        infixExpression.setOperator(operator);
        infixExpression.setRight(right);
        return infixExpression;
    }

    /**
     * Creates a new {@link InLineHtml}.
     * 
     * @return A new InLineHtml.
     */
    public InLineHtml newInLineHtml() {
        final InLineHtml inLineHtml = new InLineHtml(this);
        return inLineHtml;
    }

    /**
     * Creates a new {@link InstanceOfExpression}.
     * 
     * @return A new InstanceOfExpression.
     */
    public InstanceOfExpression newInstanceOfExpression() {
        final InstanceOfExpression instanceOfExpression = new InstanceOfExpression(
                this);

        return instanceOfExpression;
    }

    /**
     * Creates a new {@link InstanceOfExpression}.
     * 
     * @param expr
     * @param className
     * @return A new InstanceOfExpression.
     */
    public InstanceOfExpression newInstanceOfExpression(Expression expr,
            ClassName className) {
        final InstanceOfExpression instanceOfExpression = new InstanceOfExpression(
                this);
        instanceOfExpression.setClassName(className);
        instanceOfExpression.setExpression(expr);
        return instanceOfExpression;
    }

    /**
     * Creates a new {@link InterfaceDeclaration}.
     * 
     * @return A new InterfaceDeclaration.
     */
    public InterfaceDeclaration newInterfaceDeclaration() {
        final InterfaceDeclaration interfaceDeclaration = new InterfaceDeclaration(
                this);
        return interfaceDeclaration;
    }

    /**
     * Creates a new {@link InterfaceDeclaration}.
     * 
     * @param interfaceName
     * @param interfaces
     * @param body
     * @return A new InterfaceDeclaration.
     */
    public InterfaceDeclaration newInterfaceDeclaration(
            Identifier interfaceName, List<Identifier> interfaces, Block body) {
        final InterfaceDeclaration interfaceDeclaration = new InterfaceDeclaration(
                this);
        interfaceDeclaration.setName(interfaceName);
        interfaceDeclaration.interfaces().addAll(interfaces);
        interfaceDeclaration.setBody(body);
        return interfaceDeclaration;
    }

    /**
     * Creates a new {@link ListVariable}.
     * 
     * @return A new ListVariable.
     */
    public ListVariable newListVariable() {
        final ListVariable listVariable = new ListVariable(this);
        return listVariable;
    }

    /**
     * Creates a new {@link ListVariable}.
     * 
     * @param variables
     * @return A new ListVariable.
     */
    public ListVariable newListVariable(List<VariableBase> variables) {
        final ListVariable listVariable = new ListVariable(this);
        listVariable.variables().addAll(variables);
        return listVariable;
    }

    /**
     * Creates a new {@link MethodDeclaration}.
     * 
     * @return A new MethodDeclaration.
     */
    public MethodDeclaration newMethodDeclaration() {
        final MethodDeclaration methodDeclaration = new MethodDeclaration(this);
        return methodDeclaration;
    }

    /**
     * Creates a new {@link MethodDeclaration}.
     * 
     * @param modifier
     * @param function
     * @return A new MethodDeclaration.
     */
    public MethodDeclaration newMethodDeclaration(int modifier,
            FunctionDeclaration function) {
        final MethodDeclaration methodDeclaration = new MethodDeclaration(this);
        methodDeclaration.setModifier(modifier);
        methodDeclaration.setFunction(function);
        return methodDeclaration;
    }

    /**
     * Creates a new {@link MethodInvocation}.
     * 
     * @return A new MethodInvocation.
     */
    public MethodInvocation newMethodInvocation() {
        final MethodInvocation methodInvocation = new MethodInvocation(this);
        return methodInvocation;
    }

    /**
     * Creates a new {@link MethodInvocation}.
     * 
     * @param dispatcher
     * @param method
     * 
     * @return A new MethodInvocation.
     */
    public MethodInvocation newMethodInvocation(VariableBase dispatcher,
            FunctionInvocation method) {
        final MethodInvocation methodInvocation = new MethodInvocation(this);
        methodInvocation.setDispatcher(dispatcher);
        methodInvocation.setMethod(method);
        return methodInvocation;
    }

    /**
     * Creates a new {@link ParenthesisExpression}.
     * 
     * @return A new ParenthesisExpression.
     */
    public ParenthesisExpression newParenthesisExpression() {
        final ParenthesisExpression parenthesisExpression = new ParenthesisExpression(
                this);
        return parenthesisExpression;
    }

    /**
     * Creates a new {@link ParenthesisExpression}.
     * 
     * @param expression
     * @return A new ParenthesisExpression.
     */
    public ParenthesisExpression newParenthesisExpression(Expression expression) {
        final ParenthesisExpression parenthesisExpression = new ParenthesisExpression(
                this);
        parenthesisExpression.setExpression(expression);
        return parenthesisExpression;
    }

    /**
     * Creates a new {@link PostfixExpression}.
     * 
     * @return A new PostfixExpression.
     */
    public PostfixExpression newPostfixExpression() {
        final PostfixExpression postfixExpression = new PostfixExpression(this);
        return postfixExpression;
    }

    /**
     * Creates a new {@link PostfixExpression}.
     * 
     * @param variable
     * @param operator
     * @return A new PostfixExpression.
     */
    public PostfixExpression newPostfixExpression(VariableBase variable,
            int operator) {
        final PostfixExpression postfixExpression = new PostfixExpression(this);
        postfixExpression.setVariable(variable);
        postfixExpression.setOperator(operator);
        return postfixExpression;
    }

    /**
     * Creates a new {@link PrefixExpression}.
     * 
     * @return A new PrefixExpression.
     */
    public PrefixExpression newPrefixExpression() {
        final PrefixExpression prefixExpression = new PrefixExpression(this);
        return prefixExpression;
    }

    /**
     * Creates a new {@link PrefixExpression}.
     * 
     * @param variable
     * @param operator
     * @return A new PrefixExpression.
     */
    public PrefixExpression newPrefixExpression(VariableBase variable,
            int operator) {
        final PrefixExpression prefixExpression = new PrefixExpression(this);
        prefixExpression.setVariable(variable);
        prefixExpression.setOperator(operator);
        return prefixExpression;
    }

    /**
     * Creates a new {@link Program}.
     * 
     * @return A new Program.
     */
    public Program newProgram() {
        final Program program = new Program(this);
        return program;
    }

    /**
     * Creates a new {@link Program}.
     * 
     * @return A new Program.
     */
    public Program newProgram(List<Statement> statements,
            List<Comment> commentList) {
        final Program program = new Program(this);
        program.statements().addAll(statements);
        program.comments().addAll(commentList);
        return program;
    }

    /**
     * Creates a new {@link Quote}.
     * 
     * @return A new Quote.
     */
    public Quote newQuote() {
        final Quote quote = new Quote(this);
        return quote;
    }

    /**
     * Creates a new {@link Quote}.
     * 
     * @param expressions
     * @param type
     * @return A new Quote.
     */
    public Quote newQuote(List<Expression> expressions, int type) {
        final Quote quote = new Quote(this);
        quote.expressions().addAll(expressions);
        quote.setQuoteType(type);
        return quote;
    }

    /**
     * Creates a new {@link Reference}.
     * 
     * @return A new Reference.
     */
    public Reference newReference() {
        final Reference reference = new Reference(this);
        return reference;
    }

    /**
     * Creates a new {@link Reference}.
     * 
     * @param expression
     * @return A new Reference.
     */
    public Reference newReference(Expression expression) {
        final Reference reference = new Reference(this);
        reference.setExpression(expression);
        return reference;
    }

    /**
     * Creates a new {@link ReflectionVariable}.
     * 
     * @return A new ReflectionVariable.
     */
    public ReflectionVariable newReflectionVariable() {
        final ReflectionVariable reflectionVariable = new ReflectionVariable(
                this);
        return reflectionVariable;
    }

    /**
     * Creates a new {@link ReflectionVariable}.
     * 
     * @param expression
     * @return A new ReflectionVariable.
     */
    public ReflectionVariable newReflectionVariable(Expression expression) {
        final ReflectionVariable reflectionVariable = new ReflectionVariable(
                this);
        reflectionVariable.setName(expression);
        return reflectionVariable;
    }

    /**
     * Creates a new {@link ReturnStatement}.
     * 
     * @return A new ReturnStatement.
     */
    public ReturnStatement newReturnStatement() {
        final ReturnStatement returnStatement = new ReturnStatement(this);
        return returnStatement;
    }

    /**
     * Creates a new {@link ReturnStatement}.
     * 
     * @param expression
     * @return A new ReturnStatement.
     */
    public ReturnStatement newReturnStatement(Expression expression) {
        final ReturnStatement returnStatement = new ReturnStatement(this);
        returnStatement.setExpression(expression);
        return returnStatement;
    }

    /**
     * Creates a new {@link Scalar}.
     * 
     * @return A new Scalar.
     */
    public Scalar newScalar() {
        final Scalar scalar = new Scalar(this);
        return scalar;
    }

    /**
     * Creates a new scalar with a given type.
     * 
     * @param string
     *            The scalar's value.
     * @param scalarType
     *            The scalar's type (e.g. Scalar.TYPE_STRING, Scalar.TYPE_INT
     *            etc.).
     * @return A new {@link Scalar}.
     */
    public Scalar newScalar(String string, int scalarType) {
        final Scalar scalar = newScalar(string);
        scalar.setScalarType(scalarType);
        return scalar;
    }

    /**
     * Creates a new scalar with a default Scalar.TYPE_INT type.
     * 
     * @param string
     *            The scalar's value.
     * @return A new {@link Scalar}.
     */
    public Scalar newScalar(String string) {
        final Scalar scalar = new Scalar(this);
        scalar.setStringValue(string);
        return scalar;
    }

    /**
     * Creates a new {@link SingleFieldDeclaration}.
     * 
     * @return A new SingleFieldDeclaration.
     */
    public SingleFieldDeclaration newSingleFieldDeclaration() {
        final SingleFieldDeclaration singleFieldDeclaration = new SingleFieldDeclaration(
                this);
        return singleFieldDeclaration;
    }

    /**
     * Creates a new {@link SingleFieldDeclaration}.
     * 
     * @param name
     * @param value
     * @return A new SingleFieldDeclaration.
     */
    public SingleFieldDeclaration newSingleFieldDeclaration(Variable name,
            Expression value) {
        final SingleFieldDeclaration singleFieldDeclaration = new SingleFieldDeclaration(
                this);
        singleFieldDeclaration.setName(name);
        singleFieldDeclaration.setValue(value);
        return singleFieldDeclaration;
    }

    /**
     * Creates a new {@link StaticConstantAccess}.
     * 
     * @return A new StaticConstantAccess.
     */
    public StaticConstantAccess newStaticConstantAccess() {
        final StaticConstantAccess staticConstantAccess = new StaticConstantAccess(
                this);
        return staticConstantAccess;
    }

    /**
     * Creates a new {@link StaticConstantAccess}.
     * 
     * @param className
     * @param constant
     * @return A new StaticConstantAccess.
     */
    public StaticConstantAccess newStaticConstantAccess(Identifier className,
            Identifier constant) {
        final StaticConstantAccess staticConstantAccess = new StaticConstantAccess(
                this);
        staticConstantAccess.setClassName(className);
        staticConstantAccess.setConstant(constant);
        return staticConstantAccess;
    }

    /**
     * Creates a new {@link StaticFieldAccess}.
     * 
     * @return A new StaticFieldAccess.
     */
    public StaticFieldAccess newStaticFieldAccess() {
        final StaticFieldAccess staticFieldAccess = new StaticFieldAccess(this);
        return staticFieldAccess;
    }

    /**
     * Creates a new {@link StaticFieldAccess}.
     * 
     * @param className
     * @param field
     * @return A new StaticFieldAccess.
     */
    public StaticFieldAccess newStaticFieldAccess(Identifier className,
            Variable field) {
        final StaticFieldAccess staticFieldAccess = new StaticFieldAccess(this);
        staticFieldAccess.setClassName(className);
        staticFieldAccess.setField(field);
        return staticFieldAccess;
    }

    /**
     * Creates a new {@link StaticMethodInvocation}.
     * 
     * @return A new StaticMethodInvocation.
     */
    public StaticMethodInvocation newStaticMethodInvocation() {
        final StaticMethodInvocation staticMethodInvocation = new StaticMethodInvocation(
                this);
        return staticMethodInvocation;
    }

    /**
     * Creates a new {@link StaticMethodInvocation}.
     * 
     * @param className
     * @param method
     * @return A new StaticMethodInvocation.
     */
    public StaticMethodInvocation newStaticMethodInvocation(
            Identifier className, FunctionInvocation method) {
        final StaticMethodInvocation staticMethodInvocation = new StaticMethodInvocation(
                this);
        staticMethodInvocation.setClassName(className);
        staticMethodInvocation.setMethod(method);
        return staticMethodInvocation;
    }

    /**
     * Creates a new {@link StaticStatement}.
     * 
     * @return A new StaticStatement.
     */
    public StaticStatement newStaticStatement() {
        final StaticStatement staticStatement = new StaticStatement(this);
        return staticStatement;
    }

    /**
     * Creates a new {@link StaticStatement}.
     * 
     * @param expressions
     * @return A new StaticStatement.
     */
    public StaticStatement newStaticStatement(List<Expression> expressions) {
        final StaticStatement staticStatement = new StaticStatement(this);
        staticStatement.expressions().addAll(expressions);
        return staticStatement;
    }

    /**
     * Creates a new {@link SwitchCase}.
     * 
     * @return A new SwitchCase.
     */
    public SwitchCase newSwitchCase() {
        final SwitchCase switchCase = new SwitchCase(this);
        return switchCase;
    }

    /**
     * Creates a new {@link SwitchCase}.
     * 
     * @param value
     * @param actions
     * @param isDefault
     * @return A new SwitchCase.
     */
    public SwitchCase newSwitchCase(Expression value, List<Statement> actions,
            boolean isDefault) {
        final SwitchCase switchCase = new SwitchCase(this);
        switchCase.setValue(value);
        switchCase.actions().addAll(actions);
        switchCase.setIsDefault(isDefault);
        return switchCase;
    }

    /**
     * Creates a new {@link SwitchStatement}.
     * 
     * @return A new SwitchStatement.
     */
    public SwitchStatement newSwitchStatement() {
        final SwitchStatement switchStatement = new SwitchStatement(this);
        return switchStatement;
    }

    /**
     * Creates a new {@link SwitchStatement}.
     * 
     * @param expression
     * @param body
     * @return A new SwitchStatement.
     */
    public SwitchStatement newSwitchStatement(Expression expression, Block body) {
        final SwitchStatement switchStatement = new SwitchStatement(this);
        switchStatement.setExpression(expression);
        switchStatement.setBody(body);
        return switchStatement;
    }

    /**
     * Creates a new {@link ThrowStatement}.
     * 
     * @return A new ThrowStatement.
     */
    public ThrowStatement newThrowStatement() {
        final ThrowStatement throwStatement = new ThrowStatement(this);
        return throwStatement;
    }

    /**
     * Creates a new {@link ThrowStatement}.
     * 
     * @param expression
     * @return A new ThrowStatement.
     */
    public ThrowStatement newThrowStatement(Expression expression) {
        final ThrowStatement throwStatement = new ThrowStatement(this);
        throwStatement.setExpression(expression);
        return throwStatement;
    }

    /**
     * Creates a new {@link TryStatement}.
     * 
     * @return A new TryStatement.
     */
    public TryStatement newTryStatement() {
        final TryStatement tryStatement = new TryStatement(this);
        return tryStatement;
    }

    /**
     * Creates a new {@link TryStatement}.
     * 
     * @param tryStatement
     * @param catchClauses
     * @return A new TryStatement.
     */
    public TryStatement newTryStatement(Block block,
            List<CatchClause> catchClauses) {
        final TryStatement tryStatement = new TryStatement(this);
        tryStatement.setBody(block);
        tryStatement.catchClauses().addAll(catchClauses);
        return tryStatement;
    }

    /**
     * Creates a new {@link UnaryOperation}.
     * 
     * @return A new UnaryOperation.
     */
    public UnaryOperation newUnaryOperation() {
        final UnaryOperation unaryOperation = new UnaryOperation(this);
        return unaryOperation;
    }

    /**
     * Creates a new {@link UnaryOperation}.
     * 
     * @param expression
     * @param operator
     * @return A new UnaryOperation.
     */
    public UnaryOperation newUnaryOperation(Expression expression, int operator) {
        final UnaryOperation unaryOperation = new UnaryOperation(this);
        unaryOperation.setExpression(expression);
        unaryOperation.setOperator(operator);
        return unaryOperation;
    }

    /**
     * Creates a new {@link Variable}.
     * 
     * The returned Variable is not dollared and does not have any name
     * {@link Expression}.
     * 
     * @return A new {@link Variable}.
     */
    public Variable newVariable() {
        final Variable variable = new Variable(this);
        return variable;
    }

    /**
     * Creates a new {@link Variable} with a given name expression.
     * 
     * @param name
     *            A name {@link Expression}
     * @param isDollared
     *            Indicate that this variable is dollared.
     * @return A new {@link Variable}.
     */
    public Variable newVariable(Expression name, boolean isDollared) {
        final Variable variable = newVariable();
        variable.setIsDollared(isDollared);
        variable.setName(name);
        return variable;
    }

    /**
     * Creates a new dollared {@link Variable} with a given name .
     * 
     * @param name
     *            A name {@link String}
     * @return A new {@link Variable}.
     */
    public Variable newVariable(String name) {
        final Variable variable = newVariable();
        variable.setIsDollared(true);
        variable.setName(newIdentifier(name));
        return variable;
    }

    /**
     * Creates a new {@link WhileStatement}.
     * 
     * @return A new WhileStatement.
     */
    public WhileStatement newWhileStatement() {
        final WhileStatement whileStatement = new WhileStatement(this);
        return whileStatement;
    }

    /**
     * Creates a new {@link WhileStatement}.
     * 
     * @param condition
     * @param body
     * @return A new WhileStatement.
     */
    public WhileStatement newWhileStatement(Expression condition, Statement body) {
        final WhileStatement whileStatement = new WhileStatement(this);
        whileStatement.setCondition(condition);
        whileStatement.setBody(body);
        return whileStatement;
    }

    /**
     * Creates a new {@link NamespaceName}.
     * 
     * @param name
     * @param isglobal
     *            - Whether the namespace has a '\' prefix
     * @param iscurrent
     *            - Whether the namespace has a 'namespace' prefix
     * @return A new NamespaceName.
     */
    public NamespaceName newNamespaceName(
            final Collection<Identifier> segments, final boolean isglobal,
            final boolean iscurrent) {
        final NamespaceName namespaceName = new NamespaceName(this);
        namespaceName.segments().addAll(segments);
        namespaceName.setGlobal(isglobal);
        namespaceName.setCurrent(iscurrent);
        return namespaceName;
    }

    /**
     * Creates a new {@link NamespaceDeclaration}.
     * 
     * @param name
     * @param body
     * @return A new NamespaceDeclaration.
     */
    public NamespaceDeclaration newNamespaceDeclaration(NamespaceName name,
            Block body) {
        final NamespaceDeclaration namespaceDeclaration = new NamespaceDeclaration(
                this);
        namespaceDeclaration.setName(name);
        namespaceDeclaration.setBody(body);
        return namespaceDeclaration;
    }

    /**
     * Creates a new {@link UseStatementPart}.
     * 
     * @param name
     * @param alias
     * @return A new UseStatementPart.
     */
    public UseStatementPart newUseStatementPart(NamespaceName name,
            Identifier alias) {
        final UseStatementPart usePart = new UseStatementPart(this);
        usePart.setName(name);
        usePart.setAlias(alias);
        return usePart;
    }

    /**
     * Creates a new {@link UseStatement}.
     * 
     * @param parts
     * @return A new UseStatement.
     */
    public UseStatement newUseStatement(Collection<UseStatementPart> parts) {
        final UseStatement useStatement = new UseStatement(this);
        useStatement.parts().addAll(parts);
        return useStatement;
    }

    /**
     * Creates a new {@link GotoLabel}.
     * 
     * @param label
     * @return A new GotoLabel.
     */
    public GotoLabel newGotoLabel(Identifier label) {
        final GotoLabel gotoLabel = new GotoLabel(this);
        gotoLabel.setName(label);
        return gotoLabel;
    }

    /**
     * Creates a new {@link GotoStatement}.
     * 
     * @param label
     * @return A new GotoStatement.
     */
    public GotoStatement newGotoStatement(Identifier label) {
        final GotoStatement gotoStatement = new GotoStatement(this);
        gotoStatement.setLabel(label);
        return gotoStatement;
    }

    /**
     * Creates a new {@link LambdaFunctionDeclaration}.
     * 
     * @param label
     * @return A new LambdaFunctionDeclaration.
     */
    public LambdaFunctionDeclaration newLambdaFunctionDeclaration(
            final Collection<FormalParameter> formalParameters,
            final Collection<Variable> lexicalVars, final Block body,
            final boolean isReference, final boolean isStatic) {
        final LambdaFunctionDeclaration lfDeclaration = new LambdaFunctionDeclaration(
                this);
        lfDeclaration.setBody(body);
        lfDeclaration.setIsReference(isReference);
        lfDeclaration.formalParameters().addAll(formalParameters);
        lfDeclaration.lexicalVariables().addAll(lexicalVars);
        return lfDeclaration;
    }
}
