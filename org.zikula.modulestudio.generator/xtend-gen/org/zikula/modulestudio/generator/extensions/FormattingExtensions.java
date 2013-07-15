package org.zikula.modulestudio.generator.extensions;

import org.eclipse.xtext.xbase.lib.StringExtensions;

/**
 * Various helper functions for formatting names and qualifiers.
 */
@SuppressWarnings("all")
public class FormattingExtensions {
  /**
   * Replaces special chars, like German umlauts, by international version.
   * 
   * @param s given input string
   * @return String without special characters.
   */
  public String replaceSpecialChars(final String s) {
    String _replace = s.replace("\u00C4", "Ae");
    String _replace_1 = _replace.replace("\u00E4", "ae");
    String _replace_2 = _replace_1.replace("\u00D6", "Oe");
    String _replace_3 = _replace_2.replace("\u00F6", "oe");
    String _replace_4 = _replace_3.replace("\u00DC", "Ue");
    String _replace_5 = _replace_4.replace("\u00FC", "ue");
    String _replace_6 = _replace_5.replace("\u00DF", "ss");
    String _replaceAll = _replace_6.replaceAll("[\\W]", "");
    return _replaceAll;
  }
  
  /**
   * Formats a string for usage in generated source code starting not with capital.
   * 
   * @param s given input string
   * @return String formatted for source code usage.
   */
  public String formatForCode(final String s) {
    String _replaceSpecialChars = this.replaceSpecialChars(s);
    String _firstLower = StringExtensions.toFirstLower(_replaceSpecialChars);
    return _firstLower;
  }
  
  /**
   * Formats a string for usage in generated source code starting with capital.
   * 
   * @param s given input string
   * @return String formatted for source code usage.
   */
  public String formatForCodeCapital(final String s) {
    String _formatForCode = this.formatForCode(s);
    String _firstUpper = StringExtensions.toFirstUpper(_formatForCode);
    return _firstUpper;
  }
  
  /**
   * Formats a string for usage in generated source code in lower case.
   * 
   * @param s given input string
   * @return String formatted for database usage.
   */
  public String formatForDB(final String s) {
    String _replaceSpecialChars = this.replaceSpecialChars(s);
    String _lowerCase = _replaceSpecialChars.toLowerCase();
    return _lowerCase;
  }
  
  /**
   * Formats a string for improved output readability starting not with capital.
   * For example FederalStateName becomes federal state name.
   * 
   * @param s given input string
   * @return String formatted for display.
   */
  public String formatForDisplay(final String s) {
    String _xblockexpression = null;
    {
      String result = "";
      final String helpString = this.replaceSpecialChars(s);
      final char[] helpChars = helpString.toCharArray();
      for (final char c : helpChars) {
        {
          final String sc = Character.valueOf(c).toString();
          boolean _matches = sc.matches("[A-Z]");
          if (_matches) {
            String _plus = (result + " ");
            result = _plus;
          }
          String _lowerCase = sc.toLowerCase();
          String _plus_1 = (result + _lowerCase);
          result = _plus_1;
        }
      }
      String _trim = result.trim();
      String _firstLower = StringExtensions.toFirstLower(_trim);
      _xblockexpression = (_firstLower);
    }
    return _xblockexpression;
  }
  
  /**
   * Formats a string for improved output readability starting with capital.
   * For example federalStateName becomes Federal state name.
   * 
   * @param s given input string
   * @return String formatted for display.
   */
  public String formatForDisplayCapital(final String s) {
    String _formatForDisplay = this.formatForDisplay(s);
    String _firstUpper = StringExtensions.toFirstUpper(_formatForDisplay);
    return _firstUpper;
  }
  
  /**
   * Displays a boolean value as string ("true" or "false").
   * 
   * @param b given input boolean
   * @return String value of given boolean.
   */
  public String displayBool(final Boolean b) {
    String _xifexpression = null;
    if ((b).booleanValue()) {
      _xifexpression = "true";
    } else {
      _xifexpression = "false";
    }
    return _xifexpression;
  }
}
