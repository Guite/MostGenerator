package org.zikula.modulestudio.generator.beautifier.pdt.internal.core.language;

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
 * Based on package org.eclipse.php.internal.core.language;
 * 
 *******************************************************************************/

import org.eclipse.core.runtime.IPath;
import org.eclipse.core.runtime.Path;
import org.eclipse.core.runtime.Plugin;
import org.eclipse.dltk.core.IScriptProject;
import org.zikula.modulestudio.generator.beautifier.GeneratorBeautifierPlugin;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.PHPCorePlugin;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.PHPVersion;

/**
 * Default initializer for standard PHP functions/classes
 * 
 * @author michael
 * 
 */
class DefaultLanguageModelProvider implements ILanguageModelProvider {

    private static final String LANGUAGE_LIBRARY_PATH = "$nl$/Resources/language/php"; //$NON-NLS-1$

    @Override
    public IPath getPath(IScriptProject project) {
        try {
            return new Path(getLanguageLibraryPath(project, PHPVersion.PHP5_3));
        } catch (final Exception e) {
            GeneratorBeautifierPlugin.log(e);
            return null;
        }
    }

    @Override
    public String getName() {
        return "Core API";
    }

    private String getLanguageLibraryPath(IScriptProject project,
            PHPVersion phpVersion) {
        if (phpVersion == PHPVersion.PHP4) {
            return LANGUAGE_LIBRARY_PATH + "4";
        }
        if (phpVersion == PHPVersion.PHP5) {
            return LANGUAGE_LIBRARY_PATH + "5";
        }
        return LANGUAGE_LIBRARY_PATH + "5.3";
    }

    @Override
    public Plugin getPlugin() {
        return PHPCorePlugin.getDefault();
    }
}
