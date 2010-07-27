package org.zikula.modulestudio.generator.beautifier.pdt.internal.ui.editor.adapter;

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
 * Based on package org.eclipse.php.internal.ui.editor.adapter;
 * 
 *******************************************************************************/

import org.eclipse.wst.sse.core.internal.PropagatingAdapter;
import org.eclipse.wst.sse.core.internal.ltk.modelhandler.IDocumentTypeHandler;
import org.eclipse.wst.sse.core.internal.model.FactoryRegistry;
import org.eclipse.wst.sse.core.internal.provisional.INodeAdapterFactory;
import org.eclipse.wst.sse.core.internal.provisional.IStructuredModel;
import org.eclipse.wst.sse.ui.internal.contentoutline.IJFaceNodeAdapter;
import org.eclipse.wst.sse.ui.internal.provisional.registry.AdapterFactoryProvider;
import org.eclipse.wst.sse.ui.internal.util.Assert;
import org.eclipse.wst.xml.core.internal.provisional.document.IDOMDocument;
import org.eclipse.wst.xml.core.internal.provisional.document.IDOMModel;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.documentModel.handler.PHPModelHandler;

public class AdapterFactoryProviderForPhp implements AdapterFactoryProvider {

    /*
     * @see AdapterFactoryProvider#addAdapterFactories(IStructuredModel)
     */
    @Override
    public void addAdapterFactories(IStructuredModel structuredModel) {
        // these are the main factories, on model's factory registry
        addContentBasedFactories(structuredModel);
        // -------
        // Must update/add to propagating adapters here too
        addPropagatingAdapters(structuredModel);
    }

    protected void addContentBasedFactories(IStructuredModel structuredModel) {
        final FactoryRegistry factoryRegistry = structuredModel
                .getFactoryRegistry();
        Assert.isNotNull(factoryRegistry,
                "Program Error: client caller must ensure model has factory registry"); //$NON-NLS-1$
        INodeAdapterFactory factory = null;
        factory = factoryRegistry.getFactoryFor(IJFaceNodeAdapter.class);
        if (factory == null) {
            System.out.println("Could not instantiate adapter factory");
            /*
             * factory = new JFaceNodeAdapterFactoryForHTML(
             * IJFaceNodeAdapter.class, true);
             * factoryRegistry.addFactory(factory);
             */
        }
    }

    protected void addPropagatingAdapters(IStructuredModel structuredModel) {

        if (structuredModel instanceof IDOMModel) {
            final IDOMModel xmlModel = (IDOMModel) structuredModel;
            final IDOMDocument document = xmlModel.getDocument();
            final PropagatingAdapter propagatingAdapter = (PropagatingAdapter) document
                    .getAdapterFor(PropagatingAdapter.class);
            if (propagatingAdapter != null) {
                // what to do?
            }
        }
    }

    /*
     * @see AdapterFactoryProvider#isFor(ContentTypeDescription)
     */
    @Override
    public boolean isFor(IDocumentTypeHandler contentTypeDescription) {
        return (contentTypeDescription instanceof PHPModelHandler);
    }

    @Override
    public void reinitializeFactories(IStructuredModel structuredModel) {
    }
}
