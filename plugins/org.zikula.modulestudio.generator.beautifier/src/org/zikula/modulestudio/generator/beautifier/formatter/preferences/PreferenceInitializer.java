package org.zikula.modulestudio.generator.beautifier.formatter.preferences;

import org.eclipse.core.runtime.preferences.AbstractPreferenceInitializer;
import org.eclipse.core.runtime.preferences.InstanceScope;
import org.eclipse.jface.preference.IPreferenceStore;
import org.eclipse.ui.preferences.ScopedPreferenceStore;
import org.zikula.modulestudio.generator.beautifier.GeneratorBeautifierPlugin;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.PHPCoreConstants;

/**
 * Class used to initialize default preference values.
 *
 * Based on http://de.sourceforge.jp/projects/pdt-tools/
 *
 * Rules based on http://code.zikula.org/phpcs/browser/trunk/Eclipse/PHPFormatter/ZFormat.xml?format=txt (named reference below)
 */
public class PreferenceInitializer extends AbstractPreferenceInitializer {

	@Override
	public void initializeDefaultPreferences() {
		IPreferenceStore store = new ScopedPreferenceStore(new InstanceScope(), GeneratorBeautifierPlugin.PLUGIN_ID);

		/** INDENTATION */
		// Use spaces instead of tabs (reference: indentationChar)
		store.setDefault(PreferenceConstants.INDENT_WITH_TAB, false);
		store.setDefault(PHPCoreConstants.FORMATTER_USE_TABS, false);
		// Base indent and base line length
		store.setDefault(PreferenceConstants.INDENT_BASE, 0);
		store.setDefault(PreferenceConstants.LINE_LENGTH, 0);
		// Amount of used spaces (reference: indentation.size=4)
		store.setDefault(PreferenceConstants.INDENT_SPACES, 4);
		store.setDefault(PHPCoreConstants.FORMATTER_INDENTATION_SIZE, 4);


		/** SETTINGS ABOUT NEWLINE */
		// Put beginning '{' of class in new line (reference: none)
		store.setDefault(PreferenceConstants.NEW_LINE_FOR_CLASS, true);
		// Put beginning '{' of function in new line (reference: none)
		store.setDefault(PreferenceConstants.NEW_LINE_FOR_FUNCTION, true);
		// Put beginning '{' of try/catch in new line (reference: none)
		store.setDefault(PreferenceConstants.NEW_LINE_FOR_TRY_CATCH, false);
		// Put 'catch' in new line (reference: insert_new_line_before_catch_in_try_statement=false)
		store.setDefault(PreferenceConstants.NEW_LINE_FOR_CATCH, false);
		// Put 'else/elseif' in new line (reference: insert_new_line_before_else_in_if_statement=false)
		store.setDefault(PreferenceConstants.NEW_LINE_FOR_ELSE, false);
		// Put beginning '{' of if/for/foreach/while/switch/do in new line (reference: insert_new_line_before_while_in_do_statement=false)
		store.setDefault(PreferenceConstants.NEW_LINE_FOR_BLOCK, false);

		// Leave new line in 'array' (reference: insert_new_line_after_opening_brace_in_array_initializer=false)
		//     we decide AGAINST Zikula here for better formatting of arrays
		store.setDefault(PreferenceConstants.LEAVE_NEWLINE_IN_ARRAY, true);
		// Leave new line after ',' (reference: none)
		store.setDefault(PreferenceConstants.LEAVE_NEWLINE_AFTER_COMMA, true);
		// Leave new line with concatenation operator ('.') (reference: none)
		store.setDefault(PreferenceConstants.LEAVE_NEWLINE_WITH_CONCAT_OP, true);
		//     Join '.' to previous line (only none or one of previous or post) (reference: none)
		store.setDefault(PreferenceConstants.JOIN_CONCAT_OP_TO_PREV_LINE, false);
		//     Join '.' to post line (only none or one of previous or post) (reference: none)
		store.setDefault(PreferenceConstants.JOIN_CONCAT_OP_TO_POST_LINE, true);
		// Leave new line with object operator ('->') (reference: none)
		store.setDefault(PreferenceConstants.LEAVE_NEWLINE_FOR_ARROW, true);
		//     Indent each line (reference: none)
		store.setDefault(PreferenceConstants.LEAVE_NEWLINE_FOR_ARROW_NEST, false);
		// Equate 'else if' to 'elseif' (reference: none)
		store.setDefault(PreferenceConstants.EQUATE_ELSE_IF_TO_ELSEIF, true);
		// Simple statement in one line (reference: keep_imple_if_on_one_line=false)
		store.setDefault(PreferenceConstants.SIMPLE_STATEMENT_IN_ONE_LINE, false);
		// No new line in empty block ('{}') (reference: insert_new_line_in_empty_block=true)
		store.setDefault(PreferenceConstants.COMPACT_EMPTY_BLOCK, false);


		/** SETTINGS ABOUT SPACE */
		// Insert spacer for concatenation operator ('.') (reference: none)
		store.setDefault(PreferenceConstants.SPACER_FOR_CONCAT, true);
		// Insert spacer for => operator in array (reference: insert_space_after_arrow_in_array_creation=true)
		store.setDefault(PreferenceConstants.SPACER_FOR_ARRAY_ARROW, true);
		// Insert spacer for function definition (reference: insert_space_before_opening_brace_in_method_declaration=false)
		store.setDefault(PreferenceConstants.SPACER_FOR_FUNCTION_DEF, false);
		// Insert spacer for comment (reference: none)
		store.setDefault(PreferenceConstants.SPACER_FOR_COMMENT, true);
		// Insert spacer for shortcut ('<?=') (reference: none)
		store.setDefault(PreferenceConstants.SPACER_FOR_SHORTCUT, true);
		// Insert spacer for closing tag of shortcut (reference: none)
		store.setDefault(PreferenceConstants.SPACER_FOR_SHORTCUT_CLOSE, true);
		// Insert spacer for casting (reference: insert_space_after_closing_paren_in_cast=false)
		store.setDefault(PreferenceConstants.SPACER_FOR_CAST, false);


		/** MISCELLANEOUS */
		// Indent case block (reference: indent_switchstatements_compare_to_cases=true, indent_switchstatements_compare_to_switch=true, indent_breaks_compare_to_cases=true)
		store.setDefault(PreferenceConstants.INDENT_CASE_BLOCK, true);
		// Leave blank lines after '<?php' (reference: blank_lines_*=0)
		store.setDefault(PreferenceConstants.LEAVE_BLANK_LINES1, true);
		// Shrink blank lines to single blank line (reference: none)
		store.setDefault(PreferenceConstants.SHRINK_BLANK_LINES1, true);
		// Leave blank lines in script body (reference: blank_lines_*=0)
		store.setDefault(PreferenceConstants.LEAVE_BLANK_LINES2, true);
		// Shrink blank lines to single blank line (reference: none)
		store.setDefault(PreferenceConstants.SHRINK_BLANK_LINES2, true);
		// Leave blank lines in before '?>' (reference: blank_lines_*=0)
		store.setDefault(PreferenceConstants.LEAVE_BLANK_LINES3, true);
		// Shrink blank lines to single blank line (reference: none)
		store.setDefault(PreferenceConstants.SHRINK_BLANK_LINES3, true);
		// Align '=>' column position in array (reference: none)
		store.setDefault(PreferenceConstants.ALIGN_DOUBLE_ARROW, true);
		//     Align with space or Tab code (reference: indentationChar)
		store.setDefault(PreferenceConstants.ALIGN_DOUBLE_ARROW_WITH_TAB, false);
	}

	public void resetPreference(IPreferenceStore store) {
		store.setToDefault(PreferenceConstants.INDENT_WITH_TAB);
		store.setToDefault(PreferenceConstants.INDENT_SPACES);
		store.setToDefault(PreferenceConstants.INDENT_BASE);
		store.setToDefault(PreferenceConstants.LINE_LENGTH);
		store.setToDefault(PreferenceConstants.NEW_LINE_FOR_CLASS);
		store.setToDefault(PreferenceConstants.NEW_LINE_FOR_FUNCTION);
		store.setToDefault(PreferenceConstants.NEW_LINE_FOR_TRY_CATCH);
		store.setToDefault(PreferenceConstants.NEW_LINE_FOR_CATCH);
		store.setToDefault(PreferenceConstants.NEW_LINE_FOR_ELSE);
		store.setToDefault(PreferenceConstants.NEW_LINE_FOR_BLOCK);
		store.setToDefault(PreferenceConstants.INDENT_CASE_BLOCK);
		store.setToDefault(PreferenceConstants.SPACER_FOR_CONCAT);
		store.setToDefault(PreferenceConstants.SPACER_FOR_ARRAY_ARROW);
		store.setToDefault(PreferenceConstants.SPACER_FOR_FUNCTION_DEF);
		store.setToDefault(PreferenceConstants.SPACER_FOR_COMMENT);
		store.setToDefault(PreferenceConstants.SPACER_FOR_SHORTCUT);
		store.setToDefault(PreferenceConstants.SPACER_FOR_SHORTCUT_CLOSE);
		store.setToDefault(PreferenceConstants.SPACER_FOR_CAST);
		store.setToDefault(PreferenceConstants.LEAVE_BLANK_LINES1);
		store.setToDefault(PreferenceConstants.LEAVE_BLANK_LINES2);
		store.setToDefault(PreferenceConstants.LEAVE_BLANK_LINES3);
		store.setToDefault(PreferenceConstants.SHRINK_BLANK_LINES1);
		store.setToDefault(PreferenceConstants.SHRINK_BLANK_LINES2);
		store.setToDefault(PreferenceConstants.SHRINK_BLANK_LINES3);
		store.setToDefault(PreferenceConstants.LEAVE_NEWLINE_IN_ARRAY);
		store.setToDefault(PreferenceConstants.LEAVE_NEWLINE_AFTER_COMMA);
		store.setToDefault(PreferenceConstants.LEAVE_NEWLINE_WITH_CONCAT_OP);
		store.setToDefault(PreferenceConstants.LEAVE_NEWLINE_FOR_ARROW);
		store.setToDefault(PreferenceConstants.LEAVE_NEWLINE_FOR_ARROW_NEST);
		store.setToDefault(PreferenceConstants.JOIN_CONCAT_OP_TO_PREV_LINE);
		store.setToDefault(PreferenceConstants.JOIN_CONCAT_OP_TO_POST_LINE);
		store.setToDefault(PreferenceConstants.ALIGN_DOUBLE_ARROW);
		store.setToDefault(PreferenceConstants.ALIGN_DOUBLE_ARROW_WITH_TAB);
		store.setToDefault(PreferenceConstants.EQUATE_ELSE_IF_TO_ELSEIF);
		store.setToDefault(PreferenceConstants.SIMPLE_STATEMENT_IN_ONE_LINE);
		store.setToDefault(PreferenceConstants.COMPACT_EMPTY_BLOCK);

		store.setToDefault(PHPCoreConstants.FORMATTER_USE_TABS);
		store.setToDefault(PHPCoreConstants.FORMATTER_INDENTATION_SIZE);
	}

	public void copyPreference(IPreferenceStore master, IPreferenceStore slave) {
		copyBooleanValue(master, slave, PreferenceConstants.INDENT_WITH_TAB);
		copyIntValue    (master, slave, PreferenceConstants.INDENT_SPACES);
		copyIntValue    (master, slave, PreferenceConstants.INDENT_BASE);
		copyIntValue    (master, slave, PreferenceConstants.LINE_LENGTH);
		copyBooleanValue(master, slave, PreferenceConstants.NEW_LINE_FOR_CLASS);
		copyBooleanValue(master, slave, PreferenceConstants.NEW_LINE_FOR_FUNCTION);
		copyBooleanValue(master, slave, PreferenceConstants.NEW_LINE_FOR_TRY_CATCH);
		copyBooleanValue(master, slave, PreferenceConstants.NEW_LINE_FOR_CATCH);
		copyBooleanValue(master, slave, PreferenceConstants.NEW_LINE_FOR_ELSE);
		copyBooleanValue(master, slave, PreferenceConstants.NEW_LINE_FOR_BLOCK);
		copyBooleanValue(master, slave, PreferenceConstants.INDENT_CASE_BLOCK);
		copyBooleanValue(master, slave, PreferenceConstants.SPACER_FOR_CONCAT);
		copyBooleanValue(master, slave, PreferenceConstants.SPACER_FOR_ARRAY_ARROW);
		copyBooleanValue(master, slave, PreferenceConstants.SPACER_FOR_FUNCTION_DEF);
		copyBooleanValue(master, slave, PreferenceConstants.SPACER_FOR_COMMENT);
		copyBooleanValue(master, slave, PreferenceConstants.SPACER_FOR_SHORTCUT);
		copyBooleanValue(master, slave, PreferenceConstants.SPACER_FOR_SHORTCUT_CLOSE);
		copyBooleanValue(master, slave, PreferenceConstants.SPACER_FOR_CAST);
		copyBooleanValue(master, slave, PreferenceConstants.LEAVE_BLANK_LINES1);
		copyBooleanValue(master, slave, PreferenceConstants.LEAVE_BLANK_LINES2);
		copyBooleanValue(master, slave, PreferenceConstants.LEAVE_BLANK_LINES3);
		copyBooleanValue(master, slave, PreferenceConstants.SHRINK_BLANK_LINES1);
		copyBooleanValue(master, slave, PreferenceConstants.SHRINK_BLANK_LINES2);
		copyBooleanValue(master, slave, PreferenceConstants.SHRINK_BLANK_LINES3);
		copyBooleanValue(master, slave, PreferenceConstants.LEAVE_NEWLINE_IN_ARRAY);
		copyBooleanValue(master, slave, PreferenceConstants.LEAVE_NEWLINE_AFTER_COMMA);
		copyBooleanValue(master, slave, PreferenceConstants.LEAVE_NEWLINE_WITH_CONCAT_OP);
		copyBooleanValue(master, slave, PreferenceConstants.LEAVE_NEWLINE_FOR_ARROW);
		copyBooleanValue(master, slave, PreferenceConstants.LEAVE_NEWLINE_FOR_ARROW_NEST);
		copyBooleanValue(master, slave, PreferenceConstants.JOIN_CONCAT_OP_TO_PREV_LINE);
		copyBooleanValue(master, slave, PreferenceConstants.JOIN_CONCAT_OP_TO_POST_LINE);
		copyBooleanValue(master, slave, PreferenceConstants.ALIGN_DOUBLE_ARROW);
		copyBooleanValue(master, slave, PreferenceConstants.ALIGN_DOUBLE_ARROW_WITH_TAB);
		copyBooleanValue(master, slave, PreferenceConstants.EQUATE_ELSE_IF_TO_ELSEIF);
		copyBooleanValue(master, slave, PreferenceConstants.SIMPLE_STATEMENT_IN_ONE_LINE);
		copyBooleanValue(master, slave, PreferenceConstants.COMPACT_EMPTY_BLOCK);

		copyBooleanValue(master, slave, PHPCoreConstants.FORMATTER_USE_TABS);
		copyIntValue    (master, slave, PHPCoreConstants.FORMATTER_INDENTATION_SIZE);
	}

	private void copyBooleanValue(IPreferenceStore master, IPreferenceStore slave, String name) {
		slave.setValue(name, master.getBoolean(name));
	}

	private void copyIntValue(IPreferenceStore master, IPreferenceStore slave, String name) {
		slave.setValue(name, master.getInt(name));
	}
}
