package org.zikula.modulestudio.generator.beautifier.sdk;

/*******************************************************************************
 * Copyright (c) 2000, 2008 IBM Corporation and others. All rights reserved.
 * This program and the accompanying materials are made available under the
 * terms of the Eclipse Public License v1.0 which accompanies this distribution,
 * and is available at http://www.eclipse.org/legal/epl-v10.html
 * 
 * Contributors: IBM Corporation - initial API and implementation
 * 
 * 
 * 
 * Based on package org.eclipse.ui.internal.ide;
 * 
 *******************************************************************************/

import org.eclipse.ui.plugin.AbstractUIPlugin;

/**
 * This internal class represents the top of the IDE workbench.
 * 
 * This class is responsible for tracking various registries font, preference,
 * graphics, dialog store.
 * 
 * This class is explicitly referenced by the IDE workbench plug-in's
 * "plugin.xml"
 * 
 * @since 3.0
 */
public class IDEWorkbenchPlugin extends AbstractUIPlugin {

    /**
     * The ID of the default text editor. This must correspond to
     * EditorsUI.DEFAULT_TEXT_EDITOR_ID.
     */
    public static final String DEFAULT_TEXT_EDITOR_ID = "org.eclipse.ui.DefaultTextEditor"; //$NON-NLS-1$
}
