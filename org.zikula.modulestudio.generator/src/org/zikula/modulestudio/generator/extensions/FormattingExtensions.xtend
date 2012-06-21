package org.zikula.modulestudio.generator.extensions

/**
 * Various helper functions for formatting names and qualifiers.
 */
class FormattingExtensions {

    /**
     * Replaces special chars, like German umlauts, by international version.
     *
     * @param s given input string
     * @return String without special characters.
     */
    def replaceSpecialChars(String s) {
        s.replace("Ä", "Ae").replace("ä", "ae").replace("Ö", "Oe")
         .replace("ö", "oe").replace("Ü", "Ue").replace("ü", "ue")
         .replace("ß", "ss").replaceAll("[\\W]", "")
    }

    /**
     * Formats a string for usage in generated source code.
     *
     * @param s given input string
     * @return String formatted for source code usage.
     */
    def formatForCode(String s) {
        s.replaceSpecialChars
    }

    /**
     * Formats a string for usage in generated source code starting with capital.
     *
     * @param s given input string
     * @return String formatted for source code usage.
     */
    def formatForCodeCapital(String s) {
	    s.formatForCode.toFirstUpper
    }

    /**
     * Formats a string for usage in generated source code in lowercase.
     *
     * @param s given input string
     * @return String formatted for database usage.
     */
    def formatForDB(String s) {
        s.replaceSpecialChars.toLowerCase
    }

    /**
     * Formats a string for improved output readability.
     * For example federalStateName becomes federal state name.
     *
     * @param s given input string
     * @return String formatted for display.
     */
    def formatForDisplay(String s) {
        var result = ""
        val helpString = replaceSpecialChars(s)

        val helpChars = helpString.toCharArray

        for (c : helpChars) {
            val sc = c.toString
            if (sc.matches("[A-Z]")) {
                result = result + " "
            }
            result = result + sc.toLowerCase
        }

        result.trim
    }

    /**
     * Formats a string for improved output readability starting with capital.
     * For example federalStateName becomes Federal state name.
     *
     * @param s given input string
     * @return String formatted for display.
     */
    def formatForDisplayCapital(String s) {
        var result = ""
        val helpString = replaceSpecialChars(s)

        val helpChars = helpString.toCharArray

        var i = 0
        for (c : helpChars) {
            val sc = c.toString
            if (sc.matches("[A-Z]")) {
                result = result + " "
            }
            if (i == 0) {
                result = result + sc.toUpperCase
            } else {
                result = result + sc.toLowerCase
            }
            i = i + 1
        }

        result.trim
    }

    /**
     * Displays a boolean value as string ("true" or "false").
     *
     * @param b given input boolean
     * @return String value of given boolean.
     */
    def displayBool(Boolean b) {
    	if (b) "true"
    	else "false"
    }
}
