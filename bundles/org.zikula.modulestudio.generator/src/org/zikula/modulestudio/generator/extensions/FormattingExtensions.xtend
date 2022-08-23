package org.zikula.modulestudio.generator.extensions

import java.util.regex.Pattern

/**
 * Various helper functions for formatting names and qualifiers.
 */
class FormattingExtensions {

    /**
     * Replaces special chars, like German umlauts, by international version.
     *
     * @param s given input string
     * @return String without special characters
     */
    def replaceSpecialChars(String s) {
        s.replace('Ä', 'Ae').replace('ä', 'ae').replace('Ö', 'Oe')
         .replace('ö', 'oe').replace('Ü', 'Ue').replace('ü', 'ue')
         .replace('ß', 'ss').replaceAll('[\\W]', '')
    }

    /**
     * Formats a string for usage in generated source code starting not with capital.
     *
     * @param s given input string
     * @return String formatted for source code usage
     */
    def formatForCode(String s) {
        s.replaceSpecialChars.toFirstLower
    }

    /**
     * Formats a string for usage in generated source code starting with capital.
     *
     * @param s given input string
     * @return String formatted for source code usage
     */
    def formatForCodeCapital(String s) {
        s.formatForCode.toFirstUpper
    }

    /**
     * Formats a string for usage in generated source code in lower case.
     *
     * @param s given input string
     * @return String formatted for database usage.
     */
    def formatForDB(String s) {
        s.replaceSpecialChars.toLowerCase
    }

    /**
     * Formats a string for improved output readability starting not with capital.
     * For example FederalStateName becomes federal state name.
     *
     * @param s given input string
     * @return String formatted for display
     */
    def formatForDisplay(String s) {
        var result = ''
        val helpString = replaceSpecialChars(s)

        val helpChars = helpString.toCharArray

        for (c : helpChars) {
            val sc = c.toString
            if (sc.matches("[A-Z0-9]")) {
                result = result + ' '
            }
            result = result + sc.toLowerCase
        }

        result.trim.toFirstLower
    }

    def formatForSnakeCase(String s) {
        s.formatForDisplay.replace(' ', '_')
    }

    /**
     * Formats a string for improved output readability starting with capital.
     * For example federalStateName becomes Federal state name.
     *
     * @param s given input string
     * @return String formatted for display
     */
    def formatForDisplayCapital(String s) {
        s.formatForDisplay.toFirstUpper
    }

    /**
     * Displays a boolean value as string ("true" or "false").
     *
     * @param b given input boolean
     * @return String value of given boolean
     */
    def displayBool(Boolean b) {
        if (b) 'true'
        else 'false'
    }

    /**
     * Returns a list of all variables (Twig syntax) contained in a given string.
     *
     * @param string input string
     * @return List of variable names
     */
    def containedTwigVariables(String it) {
        var vars = newArrayList

        // matches {{foo}}, {{ bar}} or {{      foobar123            }}
        val pattern = Pattern.compile("\\{\\{\\s*(\\w+)\\s*\\}\\}")
        val matcher = pattern.matcher(it)

        while (matcher.find) {
            vars += matcher.group(1)
        }

        vars
    }

    /**
     * Replaces all variables (Twig syntax) contained in a given string for
     * using it within a Gettext call.
     *
     * @param string input string
     * @return updated string
     */
    def replaceTwigVariablesForTranslation(String it) {
        var output = it

        output = Pattern.compile("\\{\\{\\s*").matcher(output).replaceAll('%')
        output = Pattern.compile("\\s*\\}\\}").matcher(output).replaceAll('%')

        output
    }
}
