package org.zikula.modulestudio.generator.beautifier.pdt.internal.ui.preferences;

/*******************************************************************************
 * Copyright (c) 2009 IBM Corporation and others. All rights reserved. This
 * program and the accompanying materials are made available under the terms of
 * the Eclipse Public License v1.0 which accompanies this distribution, and is
 * available at http://www.eclipse.org/legal/epl-v10.html
 * 
 * Contributors: Zend Technologies - initial API and implementation
 * 
 * 
 * 
 * Based on package org.eclipse.php.internal.ui.preferences;
 * 
 *******************************************************************************/

import java.util.Locale;

import org.eclipse.jface.action.Action;
import org.eclipse.jface.dialogs.MessageDialogWithToggle;
import org.eclipse.jface.preference.IPreferenceStore;
import org.eclipse.swt.SWT;
import org.eclipse.ui.internal.editors.text.EditorsPlugin;
import org.eclipse.ui.texteditor.AbstractDecoratedTextEditorPreferenceConstants;
import org.eclipse.ui.texteditor.spelling.SpellingService;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.PHPCoreConstants;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.PHPVersion;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.ui.editor.PHPUiPlugin;

public class PreferenceConstants {

    /**
     * A named preference that controls whether blank lines are cleared during
     * formatting.
     * <p>
     * Value is of type <code>Boolean</code>.
     * </p>
     * 
     */
    public final static String FORMATTER_COMMENT_CLEARBLANKLINES = "commentClearBlankLines"; //$NON-NLS-1$

    /**
     * A named preference that controls whether HTML tags are formatted.
     * <p>
     * Value is of type <code>Boolean</code>.
     * </p>
     * 
     */
    public final static String FORMATTER_COMMENT_FORMATHTML = "commentFormatHtml"; //$NON-NLS-1$

    /**
     * A named preference that controls the line length of comments.
     * <p>
     * Value is of type <code>Integer</code>. The value must be at least 4 for
     * reasonable formatting.
     * </p>
     * 
     */
    public final static String FORMATTER_COMMENT_LINELENGTH = "commentLineLength"; //$NON-NLS-1$

    /**
     * A named preference that controls which profile is used by the code
     * formatter.
     * <p>
     * Value is of type <code>String</code>.
     * </p>
     * 
     */
    public static final String FORMATTER_PROFILE = "formatterProfile"; //$NON-NLS-1$

    /**
     * A named preference that controls if templates are formatted when applied.
     * <p>
     * Value is of type <code>Boolean</code>.
     * </p>
     */
    public static final String TEMPLATES_USE_CODEFORMATTER = "templateFormat"; //$NON-NLS-1$

    /**
     * A named preference that stores the configured folding provider.
     * <p>
     * Value is of type <code>String</code>.
     * </p>
     * 
     * @since 3.1
     */

    public static final String TEMPLATES_KEY = "org.eclipse.php.ui.editor.templates"; //$NON-NLS-1$

    public static final String CODE_TEMPLATES_KEY = "org.eclipse.php.ui.text.custom_code_templates"; //$NON-NLS-1$

    public static final String ALLOW_MULTIPLE_LAUNCHES = "allowMultipleLaunches"; //$NON-NLS-1$

    /**
     * A named preference that controls a reduced search menu is used in the php
     * editors.
     * <p>
     * Value is of type <code>Boolean</code>.
     * </p>
     * 
     * @since 3.0
     */
    public static final String SEARCH_USE_REDUCED_MENU = "Search.usereducemenu"; //$NON-NLS-1$

    /**
     * some constants for auto-ident Smart Tab
     */
    public static final String TAB = "tab"; //$NON-NLS-1$
    public static final String FORMATTER_TAB_CHAR = PHPUiPlugin.ID
            + ".smart_tab.char"; //$NON-NLS-1$

    public static final String FORMAT_REMOVE_TRAILING_WHITESPACES = "cleanup.remove_trailing_whitespaces"; //$NON-NLS-1$
    public static final String FORMAT_REMOVE_TRAILING_WHITESPACES_ALL = "cleanup.remove_trailing_whitespaces_all"; //$NON-NLS-1$
    public static final String FORMAT_REMOVE_TRAILING_WHITESPACES_IGNORE_EMPTY = "cleanup.remove_trailing_whitespaces_ignore_empty"; //$NON-NLS-1$

    /**
     * A named preference that controls whether the 'smart paste' feature is
     * enabled.
     * <p>
     * Value is of type <code>Boolean</code>.
     * </p>
     * 
     * @since 2.1
     */
    public final static String EDITOR_SMART_PASTE = "smartPaste"; //$NON-NLS-1$

    public static IPreferenceStore getPreferenceStore() {
        return PHPUiPlugin.getDefault().getPreferenceStore();
    }

    /**
     * Initializes the given preference store with the default values.
     */
    public static void initializeDefaultValues() {

        // Override Editor Preference defaults:
        final IPreferenceStore editorStore = EditorsPlugin.getDefault()
                .getPreferenceStore();

        // Show current line:
        editorStore
                .setDefault(
                        AbstractDecoratedTextEditorPreferenceConstants.EDITOR_CURRENT_LINE,
                        true);

        // Show line numbers:
        editorStore
                .setDefault(
                        AbstractDecoratedTextEditorPreferenceConstants.EDITOR_LINE_NUMBER_RULER,
                        true);

        // disabling the spelling detection till we find a way to refine it the
        // run only on strings and comments.
        editorStore.setDefault(SpellingService.PREFERENCE_SPELLING_ENABLED,
                false);

        final IPreferenceStore store = getPreferenceStore();

        store.setDefault(FORMATTER_COMMENT_CLEARBLANKLINES, false);
        store.setDefault(FORMATTER_COMMENT_FORMATHTML, true);
        store.setDefault(FORMATTER_COMMENT_LINELENGTH, 80);

        // TemplatePreferencePage
        store.setDefault(TEMPLATES_USE_CODEFORMATTER, true);

        store.setDefault(
                org.eclipse.dltk.ui.PreferenceConstants.EDITOR_CORRECTION_INDICATION,
                true);

        // PHP options
        store.setDefault(PHPCoreConstants.PHP_OPTIONS_PHP_VERSION,
                PHPVersion.PHP5.toString());
        store.setDefault(PHPCoreConstants.PHP_OPTIONS_PHP_ROOT_CONTEXT, ""); //$NON-NLS-1$

        store.setDefault(ALLOW_MULTIPLE_LAUNCHES,
                MessageDialogWithToggle.PROMPT);

        final String mod1Name = Action.findModifierString(SWT.MOD1); // SWT.COMMAND
                                                                     // on
        // Mac;
        // SWT.CONTROL
        // elsewhere

        store.setDefault(PreferenceConstants.SEARCH_USE_REDUCED_MENU, true);

        // default locale
        if (store.getString(PHPCoreConstants.WORKSPACE_DEFAULT_LOCALE).equals(
                "")) { //$NON-NLS-1$
            store.setValue(PHPCoreConstants.WORKSPACE_DEFAULT_LOCALE, Locale
                    .getDefault().toString());
            store.setDefault(PHPCoreConstants.WORKSPACE_LOCALE, Locale
                    .getDefault().toString());
        }

        // save actions
        store.setDefault(FORMAT_REMOVE_TRAILING_WHITESPACES, false);
        store.setDefault(FORMAT_REMOVE_TRAILING_WHITESPACES_ALL, true);
        store.setDefault(FORMAT_REMOVE_TRAILING_WHITESPACES_IGNORE_EMPTY, false);
    }

    // Don't instantiate
    private PreferenceConstants() {
    }
}
