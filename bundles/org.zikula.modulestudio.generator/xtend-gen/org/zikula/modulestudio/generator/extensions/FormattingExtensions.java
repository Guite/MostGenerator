package org.zikula.modulestudio.generator.extensions;

import java.util.ArrayList;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import org.eclipse.xtext.xbase.lib.CollectionLiterals;
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
   * @return String without special characters
   */
  public String replaceSpecialChars(final String s) {
    return s.replace("Ä", "Ae").replace("ä", "ae").replace("Ö", "Oe").replace("ö", "oe").replace("Ü", "Ue").replace("ü", "ue").replace("ß", "ss").replaceAll("[\\W]", "");
  }
  
  /**
   * Formats a string for usage in generated source code starting not with capital.
   * 
   * @param s given input string
   * @return String formatted for source code usage
   */
  public String formatForCode(final String s) {
    return StringExtensions.toFirstLower(this.replaceSpecialChars(s));
  }
  
  /**
   * Formats a string for usage in generated source code starting with capital.
   * 
   * @param s given input string
   * @return String formatted for source code usage
   */
  public String formatForCodeCapital(final String s) {
    return StringExtensions.toFirstUpper(this.formatForCode(s));
  }
  
  /**
   * Formats a string for usage in generated source code in lower case.
   * 
   * @param s given input string
   * @return String formatted for database usage.
   */
  public String formatForDB(final String s) {
    return this.replaceSpecialChars(s).toLowerCase();
  }
  
  /**
   * Formats a string for improved output readability starting not with capital.
   * For example FederalStateName becomes federal state name.
   * 
   * @param s given input string
   * @return String formatted for display
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
          boolean _matches = sc.matches("[A-Z0-9]");
          if (_matches) {
            result = (result + " ");
          }
          String _lowerCase = sc.toLowerCase();
          String _plus = (result + _lowerCase);
          result = _plus;
        }
      }
      _xblockexpression = StringExtensions.toFirstLower(result.trim());
    }
    return _xblockexpression;
  }
  
  /**
   * Formats a string for improved output readability starting with capital.
   * For example federalStateName becomes Federal state name.
   * 
   * @param s given input string
   * @return String formatted for display
   */
  public String formatForDisplayCapital(final String s) {
    return StringExtensions.toFirstUpper(this.formatForDisplay(s));
  }
  
  /**
   * Displays a boolean value as string ("true" or "false").
   * 
   * @param b given input boolean
   * @return String value of given boolean
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
  
  /**
   * Returns a list of all variables (Twig syntax) contained in a given string.
   * 
   * @param string input string
   * @return List of variable names
   */
  public ArrayList<String> containedTwigVariables(final String it) {
    ArrayList<String> _xblockexpression = null;
    {
      ArrayList<String> vars = CollectionLiterals.<String>newArrayList();
      final Pattern pattern = Pattern.compile("\\{\\{\\s*(\\w)\\s*\\}\\}");
      final Matcher matcher = pattern.matcher(it);
      while (matcher.find()) {
        String _group = matcher.group(1);
        vars.add(_group);
      }
      _xblockexpression = vars;
    }
    return _xblockexpression;
  }
  
  /**
   * Replaces all variables (Twig syntax) contained in a given string for
   * using it within a Gettext call.
   * 
   * @param string input string
   * @return updated string
   */
  public String replaceTwigVariablesForTranslation(final String it) {
    String _xblockexpression = null;
    {
      String output = it;
      output = Pattern.compile("\\{\\{\\s*").matcher(output).replaceAll("%");
      output = Pattern.compile("\\s*\\}\\}").matcher(output).replaceAll("%");
      _xblockexpression = output;
    }
    return _xblockexpression;
  }
}
