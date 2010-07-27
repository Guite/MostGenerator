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

import org.eclipse.wst.sse.core.internal.format.IStructuredFormatPreferences;
import org.eclipse.wst.sse.core.internal.format.IStructuredFormatter;
import org.w3c.dom.Node;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.documentModel.dom.ElementImplForPhp;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.format.PhpFormatter;

/**
 * Look for documentation at HTMLFormatterNoPHP
 * 
 * @author guy.g
 * 
 */
public class HTMLFormatterNoPHPFactory {

    private static HTMLFormatterNoPHPFactory fInstance = null;

    public int start;
    public int length;

    public static synchronized HTMLFormatterNoPHPFactory getInstance() {
        if (fInstance == null) {
            fInstance = new HTMLFormatterNoPHPFactory();
        }
        return fInstance;
    }

    public IStructuredFormatter createFormatter(Node node,
            IStructuredFormatPreferences formatPreferences) {
        IStructuredFormatter formatter = null;

        switch (node.getNodeType()) {
            case Node.ELEMENT_NODE:
                if (node instanceof ElementImplForPhp
                        && ((ElementImplForPhp) node).isPhpTag()) {
                    formatter = new PhpFormatter(start, length);

                }
                else {
                    formatter = new HTMLElementFormatterNoPHP();
                }

                break;
            case Node.TEXT_NODE:
                if (isEmbeddedCSS(node)) {
                    formatter = new EmbeddedCSSFormatterNoPHP();
                }
                else {
                    formatter = new HTMLTextFormatterNoPHP();
                }
                break;
            default:
                formatter = new HTMLFormatterNoPHP();
                break;
        }

        // init FormatPreferences
        formatter.setFormatPreferences(formatPreferences);

        return formatter;
    }

    /**
	 */
    private boolean isEmbeddedCSS(Node node) {
        if (node == null) {
            return false;
        }
        final Node parent = node.getParentNode();
        if (parent == null) {
            return false;
        }
        if (parent.getNodeType() != Node.ELEMENT_NODE) {
            return false;
        }
        final String name = parent.getNodeName();
        if (name == null) {
            return false;
        }
        return name.equalsIgnoreCase("STYLE");//$NON-NLS-1$
    }
}
