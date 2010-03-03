package extensions;

import java.util.Date;

import org.eclipse.core.runtime.IProgressMonitor;

/*
 * various helper functions sharing common naming conventions and so on
 */

public class Utils {


	/**
	 * @params    String    given input string
	 * @return              string formatted for source code usage
	 */
	public static String moduleName(String string) {
		return replaceSpecialChars(string);
	}

	/**
	 * @params    String    given input string
	 * @return              string formatted for database usage
	 */
	public static String dbName(String string) {
		return replaceSpecialChars(string).toLowerCase();
	}

	/**
	 * @params    String    given input string
	 * @return              string formatted (e.g. federalStateName becomes federal state names)
	 */
	public static String formattedName(String string) {
		String result = "";
		String helpString = replaceSpecialChars(string);

		char[] helpChars = helpString.toCharArray();

		for (char c : helpChars) {
			String sc = String.valueOf(c);
			if (sc.matches("[A-Z]")) result += " ";
			result += sc.toLowerCase();
		}

		return result;
	}

	/**
	 * @params    String    given input string
	 * @return              string formatted (e.g. federalStateName becomes Federal state names)
	 */
	public static String formattedNameCapitalized(String string) {
		String result = "";
		String helpString = replaceSpecialChars(string);

		char[] helpChars = helpString.toCharArray();

		int i = 0;
		for (char c : helpChars) {
			String sc = String.valueOf(c);
			if (sc.matches("[A-Z]")) result += " ";
			if (i == 0) {
				result += sc.toUpperCase();				
			}
			else {
				result += sc.toLowerCase();				
			}
			i++;
		}

		return result;
	}

	/**
	 * @params    String    given input string
	 * @return              string without special characters
	 */
	public static String replaceSpecialChars(String string) {
		return string.replace("Ã¤", "ae").replace("Ã¶", "oe").replace("Ã¼", "ue").replace("ÃŸ", "ss").replaceAll("[\\W]", "");
	}




	/**
	 * @return        the current timestamp to mark the generation time
	 */
	public static String timestamp() {
		return String.valueOf(new Date(System.currentTimeMillis()));
	}



	/**
	 * @params    IProgressMonitor  progress monitor instance
	 * @params    String    given input string
	 */
	public static String subTask(IProgressMonitor pm, String newTitle) {
		pm.subTask(newTitle);
		return "";
	}
}
