package org.zikula.modulestudio.generator.beautifier.pdt.internal.core.preferences;

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
 * Based on package org.eclipse.php.internal.core.preferences;
 * 
 *******************************************************************************/

import org.eclipse.core.runtime.preferences.DefaultScope;
import org.eclipse.core.runtime.preferences.IEclipsePreferences;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.PHPCoreConstants;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.PHPCorePlugin;

import com.ibm.icu.util.ULocale;

public class CorePreferenceConstants {

    /**
     * Initializes the given preference store with the default values.
     * 
     * @param store
     *            the preference store to be initialized
     */
    public static void initializeDefaultValues() {
        @SuppressWarnings("deprecation")
        final IEclipsePreferences node = new DefaultScope()
                .getNode(PHPCorePlugin.ID);

        node.putBoolean(PHPCoreConstants.FORMATTER_USE_TABS, true);
        node.put(PHPCoreConstants.FORMATTER_INDENTATION_SIZE,
                PHPCoreConstants.DEFAULT_INDENTATION_SIZE);
        node.putBoolean(PHPCoreConstants.CODEGEN_ADD_COMMENTS, false);
        node.put(PHPCoreConstants.WORKSPACE_DEFAULT_LOCALE, ULocale
                .getDefault().toString());
        node.put(PHPCoreConstants.WORKSPACE_LOCALE, ULocale.getDefault()
                .toString());
    }

    // Don't instantiate
    private CorePreferenceConstants() {
    }
}
