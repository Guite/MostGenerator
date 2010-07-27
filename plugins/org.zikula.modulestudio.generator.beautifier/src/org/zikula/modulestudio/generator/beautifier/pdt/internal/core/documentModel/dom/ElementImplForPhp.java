package org.zikula.modulestudio.generator.beautifier.pdt.internal.core.documentModel.dom;

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
 * Based on package org.eclipse.php.internal.core.documentModel.dom;
 * 
 *******************************************************************************/

import org.eclipse.core.runtime.IAdaptable;
import org.eclipse.core.runtime.Platform;
import org.eclipse.dltk.core.IModelElement;
import org.eclipse.wst.html.core.internal.document.ElementStyleImpl;
import org.eclipse.wst.sse.core.internal.provisional.INodeAdapter;
import org.eclipse.wst.sse.core.internal.validate.ValidationAdapter;
import org.eclipse.wst.xml.core.internal.document.ElementImpl;
import org.eclipse.wst.xml.core.internal.validate.ValidationComponent;
import org.w3c.dom.Document;
import org.w3c.dom.Node;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.documentModel.DOMModelForPHP;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.documentModel.parser.PHPRegionContext;

/**
 * Represents elements in the dom model {@link DOMModelForPHP}
 * 
 * @author Roy, 2007
 */
public class ElementImplForPhp extends ElementStyleImpl implements IAdaptable,
        IImplForPhp {

    private IModelElement modelElement;

    public ElementImplForPhp() {
        super();
    }

    @Override
    public Object getAdapter(Class adapter) {
        return Platform.getAdapterManager().getAdapter(this, adapter);
    }

    public ElementImplForPhp(ElementStyleImpl that) {
        super(that);
    }

    @Override
    protected boolean isNestedClosed(String regionType) {
        return regionType == PHPRegionContext.PHP_CLOSE;
    }

    @Override
    public Node cloneNode(boolean deep) {
        final ElementImpl cloned = new ElementImplForPhp(this);
        if (deep) {
            cloneChildNodes(cloned, deep);
        }
        return cloned;
    }

    /**
     * @see ElementStyleImpl#setOwnerDocument(Document) make this method package
     *      visible
     */
    @Override
    protected void setOwnerDocument(Document ownerDocument) {
        super.setOwnerDocument(ownerDocument);
    }

    /**
     * @see setTagName(String) make this method package visible
     */
    @Override
    protected void setTagName(String tagName) {
        super.setTagName(tagName);
    }

    @Override
    public boolean isGlobalTag() {
        return isPhpTag() ? false : super.isGlobalTag();
    }

    /**
     * @return true if it is a php element
     */
    public boolean isPhpTag() {
        return PHPDOMModelParser.PHP_TAG_NAME.equals(getNodeName());
    }

    @Override
    public synchronized INodeAdapter getExistingAdapter(Object type) {

        // no validation or validation propagation for PHP tags
        if (isPhpTag()
                && ValidationAdapter.class.isAssignableFrom((Class) type)) {
            return nullValidator;
        }
        return super.getExistingAdapter(type);
    }

    private final static ValidationComponent nullValidator = new NullValidator();

    @Override
    public String getPrefix() {
        final String prefix = super.getPrefix();
        if (prefix == null && isPhpTag()) {
            return ""; //$NON-NLS-1$
        }
        return prefix;
    }

    @Override
    public IModelElement getModelElement() {
        return modelElement;
    }

    @Override
    public void setModelElement(IModelElement modelElement) {
        this.modelElement = modelElement;
    }

    @Override
    public boolean isStartTagClosed() {
        return isPhpTag() ? true : super.isStartTagClosed();
    }
}
