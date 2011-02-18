package org.zikula.modulestudio.generator.beautifier.pdt.internal.core.format.htmlFormatters;

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
 * Based on package org.eclipse.php.internal.core.format.htmlFormatters;
 * 
 *******************************************************************************/

import org.eclipse.wst.html.core.internal.format.HTMLElementFormatter;
import org.eclipse.wst.html.core.internal.format.HTMLTextFormatter;
import org.eclipse.wst.html.core.internal.provisional.HTMLFormatContraints;
import org.eclipse.wst.sse.core.internal.format.IStructuredFormatter;
import org.eclipse.wst.sse.core.internal.provisional.text.IStructuredDocumentRegion;
import org.eclipse.wst.sse.core.internal.provisional.text.ITextRegionContainer;
import org.eclipse.wst.xml.core.internal.provisional.document.IDOMNode;
import org.w3c.dom.Attr;
import org.w3c.dom.Element;
import org.w3c.dom.NamedNodeMap;
import org.w3c.dom.Node;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.documentModel.dom.AttrImplForPhp;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.documentModel.parser.PHPRegionContext;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.format.PhpFormatter;

/**
 * Look for documentation at HTMLFormatterNoPHP
 * 
 * @author guy.g
 * 
 */
@SuppressWarnings("deprecation")
public class HTMLElementFormatterNoPHP extends HTMLElementFormatter {

    /**
	 */
    @Override
    protected void formatChildNodes(IDOMNode node,
            HTMLFormatContraints contraints) {
        if (node == null) {
            return;
        }
        if (!node.hasChildNodes()) {
            return;
        }

        // concat adjacent texts
        node.normalize();

        // disable sibling indent during formatting all the children
        boolean indent = false;
        if (contraints != null) {
            indent = contraints.getFormatWithSiblingIndent();
            contraints.setFormatWithSiblingIndent(false);
        }

        boolean insertBreak = true;
        IDOMNode child = (IDOMNode) node.getFirstChild();
        while (child != null) {
            if (child.getParentNode() != node) {
                break;
            }
            final IDOMNode next = (IDOMNode) child.getNextSibling();

            if (insertBreak && canInsertBreakBefore(child)) {
                insertBreakBefore(child, contraints);
            }

            final IStructuredFormatter formatter = HTMLFormatterNoPHPFactory
                    .getInstance().createFormatter(child,
                            getFormatPreferences());
            if (formatter != null) {
                if (formatter instanceof HTMLFormatterNoPHP) {
                    final HTMLFormatterNoPHP htmlFormatter = (HTMLFormatterNoPHP) formatter;
                    htmlFormatter.formatNode(child, contraints);
                }
                else {
                    formatter.format(child);
                }
            }

            if (canInsertBreakAfter(child)) {
                insertBreakAfter(child, contraints);
                insertBreak = false; // not to insert twice
            }
            else {
                insertBreak = true;
            }

            child = next;
        }

        if (contraints != null) {
            contraints.setFormatWithSiblingIndent(indent);
        }
    }

    /**
	 */
    @Override
    protected void insertBreakAfter(IDOMNode node,
            HTMLFormatContraints contraints) {
        if (node == null) {
            return;
        }
        if (node.getNodeType() == Node.TEXT_NODE) {
            return;
        }
        final Node parent = node.getParentNode();
        if (parent == null) {
            return;
        }
        final Node next = node.getNextSibling();

        String spaces = null;
        if (next == null) { // last spaces
            // use parent indent for the end tag
            spaces = getBreakSpaces(parent);
        }
        else if (next.getNodeType() == Node.TEXT_NODE) {
            if (contraints != null && contraints.getFormatWithSiblingIndent()) {
                final IDOMNode text = (IDOMNode) next;
                final IStructuredFormatter formatter = HTMLFormatterNoPHPFactory
                        .getInstance().createFormatter(text,
                                getFormatPreferences());
                if (formatter instanceof HTMLTextFormatter) {
                    final HTMLTextFormatterNoPHP textFormatter = (HTMLTextFormatterNoPHP) formatter;
                    textFormatter.formatText(text, contraints,
                            HTMLTextFormatter.FORMAT_HEAD);
                }
            }
            return;
        }
        else {
            spaces = getBreakSpaces(node);
        }
        if (spaces == null || spaces.length() == 0) {
            return;
        }

        replaceSource(node.getModel(), node.getEndOffset(), 0, spaces);
        setWidth(contraints, spaces);
    }

    /**
	 */
    @Override
    protected void insertBreakBefore(IDOMNode node,
            HTMLFormatContraints contraints) {
        if (node == null) {
            return;
        }
        if (node.getNodeType() == Node.TEXT_NODE) {
            return;
        }
        final Node parent = node.getParentNode();
        if (parent == null) {
            return;
        }
        final Node prev = node.getPreviousSibling();

        String spaces = null;
        if (prev != null && prev.getNodeType() == Node.TEXT_NODE) {
            if (contraints != null && contraints.getFormatWithSiblingIndent()) {
                final IDOMNode text = (IDOMNode) prev;
                final IStructuredFormatter formatter = HTMLFormatterNoPHPFactory
                        .getInstance().createFormatter(text,
                                getFormatPreferences());
                if (formatter instanceof HTMLTextFormatter) {
                    final HTMLTextFormatterNoPHP textFormatter = (HTMLTextFormatterNoPHP) formatter;
                    textFormatter.formatText(text, contraints,
                            HTMLTextFormatter.FORMAT_TAIL);

                    // if (node == null) {
                    // return;
                    // }

                    if (node.hasChildNodes()) { // container
                        formatChildNodes(node, contraints);
                    }
                    else { // leaf
                        final IStructuredDocumentRegion flatNode = node
                                .getStartStructuredDocumentRegion();
                        if (flatNode != null) {
                            final String source = flatNode.getText();
                            if (source != null && source.length() > 0) {
                                setWidth(contraints, source);
                            }
                        }
                    }

                }
            }
            return;
        }
        spaces = getBreakSpaces(node);
        if (spaces == null || spaces.length() == 0) {
            return;
        }

        replaceSource(node.getModel(), node.getStartOffset(), 0, spaces);
        setWidth(contraints, spaces);
    }

    @Override
    protected void formatNode(IDOMNode node, HTMLFormatContraints contraints) {
        // fixed bug 198901 - prevent the HTML formatter to format the value of
        // style attribute
        // skip the format start tag and end tag
        Attr attr = null;
        if (node instanceof Element) {
            attr = ((Element) node).getAttributeNode("style");//$NON-NLS-1$
        }
        if (attr == null || attr.getValue().indexOf("<?") == -1) { //$NON-NLS-1$
            super.formatNode(node, contraints);
        }
        else {
            formatChildNodes(node, contraints);
        }

        // get over the attribute and look for php attributes

        final NamedNodeMap attributes = node.getAttributes();
        for (int i = 0; i < attributes.getLength(); i++) {
            final AttrImplForPhp attribute = (AttrImplForPhp) attributes
                    .item(i);
            ITextRegionContainer container = null;
            if (attribute.getNameRegion() instanceof ITextRegionContainer) {
                container = (ITextRegionContainer) attribute.getNameRegion();
            }

            if (attribute.getValueRegion() instanceof ITextRegionContainer) {
                container = (ITextRegionContainer) attribute.getValueRegion();
            }

            if (container != null
                    && container.getFirstRegion().getType()
                            .equals(PHPRegionContext.PHP_OPEN)) {
                final PhpFormatter phpFormatter = new PhpFormatter(
                        attribute.getStartOffset(), attribute.getEndOffset());
                phpFormatter.format(attribute, contraints);
            }
        }

    }

}
