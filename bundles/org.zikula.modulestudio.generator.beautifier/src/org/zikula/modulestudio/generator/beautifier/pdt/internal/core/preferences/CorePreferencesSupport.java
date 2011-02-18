package org.zikula.modulestudio.generator.beautifier.pdt.internal.core.preferences;

/*******************************************************************************
 * Copyright (c) 2009 IBM Corporation and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 * 
 * Contributors:
 *     IBM Corporation - initial API and implementation
 *     Zend Technologies
 *
 *
 *
 * Based on package org.eclipse.php.internal.core.preferences;
 *
 *******************************************************************************/

import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.PHPCorePlugin;

public class CorePreferencesSupport extends PreferencesSupport {

	private static CorePreferencesSupport corePreferencesSupport;

	@SuppressWarnings("deprecation")
	private CorePreferencesSupport() {
		super(PHPCorePlugin.ID, PHPCorePlugin.getDefault() == null ? null
				: PHPCorePlugin.getDefault().getPluginPreferences());
	}

	public static CorePreferencesSupport getInstance() {
		if (corePreferencesSupport == null) {
			corePreferencesSupport = new CorePreferencesSupport();
		}

		return corePreferencesSupport;
	}
}
