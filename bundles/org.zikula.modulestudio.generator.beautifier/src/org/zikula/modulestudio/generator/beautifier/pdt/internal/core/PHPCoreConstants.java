package org.zikula.modulestudio.generator.beautifier.pdt.internal.core;

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
 * Based on package org.eclipse.php.internal.core;
 * 
 *******************************************************************************/

public interface PHPCoreConstants {

    public static final String PLUGIN_ID = PHPCorePlugin.ID;
    public static final String IP_VARIABLE_INITIALIZER_EXTPOINT_ID = "includePathVariables"; //$NON-NLS-1$

    //
    // Project default folders names
    //
    public static final String PROJECT_DEFAULT_SOURCE_FOLDER = "src"; //$NON-NLS-1$
    public static final String PROJECT_DEFAULT_RESOURCES_FOLDER = "resources"; //$NON-NLS-1$

    //
    // Project Option names
    //
    public static final String PHPOPTION_DEFAULT_ENCODING = PLUGIN_ID
            + ".defaultEncoding"; //$NON-NLS-1$
    public static final String PHPOPTION_CONTEXT_ROOT = PLUGIN_ID
            + ".contextRoot"; //$NON-NLS-1$
    public static final String PHPOPTION_INCLUDE_PATH = PLUGIN_ID
            + ".includePath"; //$NON-NLS-1$

    public static final String ADD_JS_NATURE = PLUGIN_ID + ".addJsNature"; //$NON-NLS-1$
    public static final String TASK_PRIORITIES = PLUGIN_ID + ".taskPriorities"; //$NON-NLS-1$
    public static final String TASK_PRIORITY_HIGH = "HIGH"; //$NON-NLS-1$
    public static final String TASK_PRIORITY_LOW = "LOW"; //$NON-NLS-1$
    public static final String TASK_PRIORITY_NORMAL = "NORMAL"; //$NON-NLS-1$
    public static final String TASK_TAGS = PLUGIN_ID + ".taskTags"; //$NON-NLS-1$
    public static final String TASK_CASE_SENSITIVE = PLUGIN_ID
            + ".taskCaseSensitive"; //$NON-NLS-1$
    public static final String DEFAULT_TASK_TAGS = "TODO,FIXME,XXX,@todo"; //$NON-NLS-1$
    public static final String DEFAULT_TASK_PRIORITIES = "NORMAL,HIGH,NORMAL,NORMAL"; //$NON-NLS-1$
    public static final String ENABLED = "enabled"; //$NON-NLS-1$
    public static final String DISABLED = "disabled"; //$NON-NLS-1$
    public static final String DEFAULT_INDENTATION_SIZE = "1"; //$NON-NLS-1$

    public static final String INCLUDE_PATH_VARIABLE_NAMES = PLUGIN_ID
            + ".includePathVariableNames"; //$NON-NLS-1$
    public static final String INCLUDE_PATH_VARIABLE_PATHS = PLUGIN_ID
            + ".includePathVariablePaths"; //$NON-NLS-1$

    public static final String RESERVED_INCLUDE_PATH_VARIABLE_NAMES = PLUGIN_ID
            + ".includePathReservedVariableNames"; //$NON-NLS-1$
    public static final String RESERVED_INCLUDE_PATH_VARIABLE_PATHS = PLUGIN_ID
            + ".includePathReservedVariablePaths"; //$NON-NLS-1$

    public static final String PHP_OPTIONS_PHP_VERSION = "phpVersion"; //$NON-NLS-1$
    public static final String PHP_OPTIONS_PHP_ROOT_CONTEXT = "phpRootContext"; //$NON-NLS-1$

    public static final String FORMATTER_USE_TABS = PLUGIN_ID
            + ".phpForamtterUseTabs"; //$NON-NLS-1$
    public static final String FORMATTER_INDENTATION_SIZE = PLUGIN_ID
            + ".phpForamtterIndentationSize"; //$NON-NLS-1$

    public static final String CODEGEN_ADD_COMMENTS = PLUGIN_ID + ".phpDoc"; //$NON-NLS-1$

    // workspace locale and default local preferences identifiers
    public final static String WORKSPACE_LOCALE = PLUGIN_ID
            + ".workspaceLocale"; //$NON-NLS-1$
    public final static String WORKSPACE_DEFAULT_LOCALE = PLUGIN_ID
            + ".workspaceDefaultLocale"; //$NON-NLS-1$

    public static final String RSE_TEMP_PROJECT_NATURE_ID = "org.eclipse.rse.ui.remoteSystemsTempNature"; //$NON-NLS-1$

    public static final int AccClassField = (1 << 10);

    public static final String ANONYMOUS = "__anonymous";

}
