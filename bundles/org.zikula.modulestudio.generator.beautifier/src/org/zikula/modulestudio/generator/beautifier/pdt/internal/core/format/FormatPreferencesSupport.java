package org.zikula.modulestudio.generator.beautifier.pdt.internal.core.format;

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
 * Based on package org.eclipse.php.internal.core.format;
 * 
 *******************************************************************************/

import org.eclipse.core.resources.IFile;
import org.eclipse.core.resources.IProject;
import org.eclipse.core.resources.ResourcesPlugin;
import org.eclipse.core.runtime.IPath;
import org.eclipse.core.runtime.Path;
import org.eclipse.core.runtime.Preferences;
import org.eclipse.jface.text.IDocument;
import org.eclipse.wst.sse.core.StructuredModelManager;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.PHPCoreConstants;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.PHPCorePlugin;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.documentModel.DOMModelForPHP;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.preferences.IPreferencesPropagatorListener;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.preferences.PreferencePropagatorFactory;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.preferences.PreferencesPropagator;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.preferences.PreferencesPropagatorEvent;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.preferences.PreferencesSupport;

/**
 * 
 * @author guy.g
 * 
 */
@SuppressWarnings("deprecation")
public class FormatPreferencesSupport {

    private IDocument fLastDocument = null;
    private IProject fLastProject = null;

    private char indentationChar;
    private int indentationSize;

    private PreferencesSupport preferencesSupport = null;
    private PreferencesPropagatorListener listener = null;

    private boolean preferencesChanged = false;

    private final PreferencesPropagator preferencesPropagator;

    private static final String NODES_QUALIFIER = PHPCorePlugin.ID;
    private static final Preferences store = PHPCorePlugin.getDefault()
            .getPluginPreferences();

    private FormatPreferencesSupport() {

        preferencesPropagator = PreferencePropagatorFactory
                .getPreferencePropagator(NODES_QUALIFIER, store);
        preferencesSupport = new PreferencesSupport(PHPCorePlugin.ID, store);
    }

    private static FormatPreferencesSupport instance = null;

    public static FormatPreferencesSupport getInstance() {
        if (instance == null) {
            instance = new FormatPreferencesSupport();
        }
        return instance;
    }

    public int getIndentationSize(IDocument document) {
        if (document == null) {
            final String indentSize = preferencesSupport
                    .getWorkspacePreferencesValue(PHPCoreConstants.FORMATTER_INDENTATION_SIZE);
            if (indentSize == null) {
                return 1;
            }
            return Integer.valueOf(indentSize).intValue();
        }
        verifyValidity(document);
        return indentationSize;
    }

    public char getIndentationChar(IDocument document) {
        if (document == null) {
            final String useTab = preferencesSupport
                    .getWorkspacePreferencesValue(PHPCoreConstants.FORMATTER_USE_TABS);
            if (useTab == null) {
                return '\t';
            }
            return (Boolean.valueOf(useTab).booleanValue()) ? '\t' : ' ';
        }
        verifyValidity(document);
        return indentationChar;
    }

    private void verifyValidity(IDocument document) {
        if (fLastDocument != document) {
            DOMModelForPHP editorModel = null;
            try {
                editorModel = (DOMModelForPHP) StructuredModelManager
                        .getModelManager().getExistingModelForRead(document);
                if (editorModel == null) {
                    return;
                }
                final String baseLocation = editorModel.getBaseLocation();
                // The baseLocation may be a path on disk or relative to the
                // workspace root. Don't translate on-disk paths to
                // in-workspace resources.
                final IPath basePath = new Path(baseLocation);
                IFile file = null;
                if (basePath.segmentCount() > 1) {
                    file = ResourcesPlugin.getWorkspace().getRoot()
                            .getFile(basePath);
                    if (!file.exists()) {
                        file = null;
                    }
                }
                if (file == null) {
                    return;
                }

                final IProject project = file.getProject();
                if (fLastProject != project) {
                    fLastProject = project;
                    verifyListening();
                }
            } finally {
                if (editorModel != null) {
                    editorModel.releaseFromRead();
                }
            }
        }

        if (fLastDocument != document || preferencesChanged) {
            final String useTab = preferencesSupport.getPreferencesValue(
                    PHPCoreConstants.FORMATTER_USE_TABS, null, fLastProject);
            final String indentSize = preferencesSupport.getPreferencesValue(
                    PHPCoreConstants.FORMATTER_INDENTATION_SIZE, null,
                    fLastProject);

            indentationChar = (Boolean.valueOf(useTab).booleanValue()) ? '\t'
                    : ' ';
            indentationSize = Integer.valueOf(indentSize).intValue();

            preferencesChanged = false;
            fLastDocument = document;
        }
    }

    private void verifyListening() {
        if (listener != null) {
            preferencesPropagator.removePropagatorListener(listener,
                    PHPCoreConstants.FORMATTER_USE_TABS);
            preferencesPropagator.removePropagatorListener(listener,
                    PHPCoreConstants.FORMATTER_INDENTATION_SIZE);
        }

        listener = new PreferencesPropagatorListener(fLastProject);
        preferencesPropagator.addPropagatorListener(listener,
                PHPCoreConstants.FORMATTER_USE_TABS);
        preferencesPropagator.addPropagatorListener(listener,
                PHPCoreConstants.FORMATTER_INDENTATION_SIZE);
    }

    private class PreferencesPropagatorListener implements
            IPreferencesPropagatorListener {

        private final IProject project;

        public PreferencesPropagatorListener(IProject project) {
            this.project = project;
        }

        @Override
        public void preferencesEventOccured(PreferencesPropagatorEvent event) {
            preferencesChanged = true;
        }

        @Override
        public IProject getProject() {
            return project;
        }

    }

}
