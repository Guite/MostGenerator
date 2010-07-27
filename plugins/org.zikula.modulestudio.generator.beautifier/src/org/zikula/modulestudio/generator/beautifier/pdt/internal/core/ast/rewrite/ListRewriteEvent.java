package org.zikula.modulestudio.generator.beautifier.pdt.internal.core.ast.rewrite;

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
 * Based on package org.eclipse.php.internal.core.ast.rewrite;
 * 
 *******************************************************************************/

import java.util.ArrayList;
import java.util.List;

import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.ast.nodes.ASTNode;

/**
 *
 */
public class ListRewriteEvent extends RewriteEvent {

    public final static int NEW = 1;
    public final static int OLD = 2;
    public final static int BOTH = NEW | OLD;

    /** original list of 'ASTNode' */
    private final List originalNodes;

    /** list of type 'RewriteEvent' */
    private List listEntries;

    /**
     * Creates a ListRewriteEvent from the original ASTNodes. The resulting
     * event represents the unmodified list.
     * 
     * @param originalNodes
     *            The original nodes (type ASTNode)
     */
    public ListRewriteEvent(List originalNodes) {
        this.originalNodes = new ArrayList(originalNodes);
    }

    /**
     * Creates a ListRewriteEvent from existing rewrite events.
     * 
     * @param children
     *            The rewrite events for this list.
     */
    public ListRewriteEvent(RewriteEvent[] children) {
        this.listEntries = new ArrayList(children.length * 2);
        this.originalNodes = new ArrayList(children.length * 2);
        for (final RewriteEvent curr : children) {
            this.listEntries.add(curr);
            if (curr.getOriginalValue() != null) {
                this.originalNodes.add(curr.getOriginalValue());
            }
        }
    }

    private List getEntries() {
        if (this.listEntries == null) {
            // create if not yet existing
            final int nNodes = this.originalNodes.size();
            this.listEntries = new ArrayList(nNodes * 2);
            for (int i = 0; i < nNodes; i++) {
                final ASTNode node = (ASTNode) this.originalNodes.get(i);
                // all nodes unchanged
                this.listEntries.add(new NodeRewriteEvent(node, node));
            }
        }
        return this.listEntries;
    }

    /*
     * (non-Javadoc)
     * @see org.eclipse.jdt.internal.corext.dom.ASTRewriteChange#getChangeKind()
     */
    @Override
    public int getChangeKind() {
        if (this.listEntries != null) {
            for (int i = 0; i < this.listEntries.size(); i++) {
                final RewriteEvent curr = (RewriteEvent) this.listEntries
                        .get(i);
                if (curr.getChangeKind() != UNCHANGED) {
                    return CHILDREN_CHANGED;
                }
            }
        }
        return UNCHANGED;
    }

    /*
     * (non-Javadoc)
     * @see org.eclipse.jdt.internal.corext.dom.ASTRewriteChange#isListChange()
     */
    @Override
    public boolean isListRewrite() {
        return true;
    }

    /*
     * (non-Javadoc)
     * @see org.eclipse.jdt.internal.corext.dom.RewriteEvent#getChildren()
     */
    @Override
    public RewriteEvent[] getChildren() {
        final List entries = getEntries();
        return (RewriteEvent[]) entries
                .toArray(new RewriteEvent[entries.size()]);
    }

    /*
     * (non-Javadoc)
     * @see org.eclipse.jdt.internal.corext.dom.RewriteEvent#getOriginalNode()
     */
    @Override
    public Object getOriginalValue() {
        return this.originalNodes;
    }

    /*
     * (non-Javadoc)
     * @see org.eclipse.jdt.internal.corext.dom.RewriteEvent#getNewValue()
     */
    @Override
    public Object getNewValue() {
        final List entries = getEntries();
        final ArrayList res = new ArrayList(entries.size());
        for (int i = 0; i < entries.size(); i++) {
            final RewriteEvent curr = (RewriteEvent) entries.get(i);
            final Object newVal = curr.getNewValue();
            if (newVal != null) {
                res.add(newVal);
            }
        }
        return res;
    }

    // API to modify the list nodes

    public RewriteEvent removeEntry(ASTNode originalEntry) {
        return replaceEntry(originalEntry, null);
    }

    public RewriteEvent replaceEntry(ASTNode originalEntry, ASTNode newEntry) {
        if (originalEntry == null) {
            throw new IllegalArgumentException();
        }

        final List entries = getEntries();
        final int nEntries = entries.size();
        for (int i = 0; i < nEntries; i++) {
            final NodeRewriteEvent curr = (NodeRewriteEvent) entries.get(i);
            if (curr.getOriginalValue() == originalEntry) {
                curr.setNewValue(newEntry);
                return curr;
            }
        }
        return null;
    }

    public void revertChange(NodeRewriteEvent event) {
        final Object originalValue = event.getOriginalValue();
        if (originalValue == null) {
            final List entries = getEntries();
            entries.remove(event);
        }
        else {
            event.setNewValue(originalValue);
        }
    }

    public int getIndex(ASTNode node, int kind) {
        final List entries = getEntries();
        for (int i = entries.size() - 1; i >= 0; i--) {
            final RewriteEvent curr = (RewriteEvent) entries.get(i);
            if (((kind & OLD) != 0) && (curr.getOriginalValue() == node)) {
                return i;
            }
            if (((kind & NEW) != 0) && (curr.getNewValue() == node)) {
                return i;
            }
        }
        return -1;
    }

    public RewriteEvent insert(ASTNode insertedNode, int insertIndex) {
        final NodeRewriteEvent change = new NodeRewriteEvent(null, insertedNode);
        if (insertIndex != -1) {
            getEntries().add(insertIndex, change);
        }
        else {
            getEntries().add(change);
        }
        return change;
    }

    public void setNewValue(ASTNode newValue, int insertIndex) {
        final NodeRewriteEvent curr = (NodeRewriteEvent) getEntries().get(
                insertIndex);
        curr.setNewValue(newValue);
    }

    public int getChangeKind(int index) {
        return ((NodeRewriteEvent) getEntries().get(index)).getChangeKind();
    }

    /*
     * (non-Javadoc)
     * @see java.lang.Object#toString()
     */
    @Override
    public String toString() {
        final StringBuffer buf = new StringBuffer();
        buf.append(" [list change\n\t"); //$NON-NLS-1$

        final RewriteEvent[] events = getChildren();
        for (int i = 0; i < events.length; i++) {
            if (i != 0) {
                buf.append("\n\t"); //$NON-NLS-1$
            }
            buf.append(events[i]);
        }
        buf.append("\n]"); //$NON-NLS-1$
        return buf.toString();
    }

}
