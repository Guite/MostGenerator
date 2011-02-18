package org.zikula.modulestudio.generator.beautifier.pdt.internal.ui;

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
 * Based on package org.eclipse.php.internal.ui;
 * 
 *******************************************************************************/

import java.util.MissingResourceException;
import java.util.ResourceBundle;

public class PHPUIMessages {
    private static final String BUNDLE_NAME = "org.eclipse.php.internal.ui.PHPUIMessages"; //$NON-NLS-1$
    private static final ResourceBundle RESOURCE_BUNDLE = ResourceBundle
            .getBundle(BUNDLE_NAME);
    private static ResourceBundle fResourceBundle;

    private PHPUIMessages() {
    }

    public static ResourceBundle getResourceBundle() {
        try {
            if (fResourceBundle == null) {
                fResourceBundle = ResourceBundle.getBundle(BUNDLE_NAME);
            }
        } catch (final MissingResourceException x) {
            fResourceBundle = null;
        }
        return fResourceBundle;
    }

    public static String getString(String key) {
        try {
            return RESOURCE_BUNDLE.getString(key);
        } catch (final MissingResourceException e) {
            return ""; //$NON-NLS-1$
        }
    }
}
