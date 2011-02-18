package org.zikula.modulestudio.generator.beautifier.formatter;

import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.documentModel.parser.regions.PHPRegionTypes;

/**
 * Based on http://de.sourceforge.jp/projects/pdt-tools/
 */
public class PHPToken {

	public static final int PHP__CLASS__ = 1;
	public static final int PHP__FILE__ = 2;
	public static final int PHP__FUNCTION__ = 3;
	public static final int PHP__LINE__ = 4;
	public static final int PHP__METHOD__ = 5;
	public static final int PHP_ABSTRACT = 6;
	public static final int PHP_ARRAY = 7;
	public static final int PHP_AS = 8;
	public static final int PHP_BREAK = 9;
	public static final int PHP_CASE = 10;
	public static final int PHP_CASTING = 11;
	public static final int PHP_CATCH = 12;
	public static final int PHP_CLASS = 13;
	public static final int PHP_CLONE = 14;
	public static final int PHP_CLOSETAG = 15;
	public static final int PHP_COMMENT = 16;
	public static final int PHP_COMMENT_END = 17;
	public static final int PHP_COMMENT_START = 18;
	public static final int PHP_CONST = 19;
	public static final int PHP_CONSTANT_ENCAPSED_STRING = 20;
	public static final int PHP_CONTENT = 21;
	public static final int PHP_CONTINUE = 22;
	public static final int PHP_CURLY_CLOSE = 23;
	public static final int PHP_CURLY_OPEN = 24;
	public static final int PHP_DECLARE = 25;
	public static final int PHP_DEFAULT = 26;
	public static final int PHP_DIE = 27;
	public static final int PHP_DO = 28;
	public static final int PHP_ECHO = 29;
	public static final int PHP_ELSE = 30;
	public static final int PHP_ELSEIF = 31;
	public static final int PHP_EMPTY = 32;
	public static final int PHP_ENCAPSED_AND_WHITESPACE = 33;
	public static final int PHP_ENDDECLARE = 34;
	public static final int PHP_ENDFOR = 35;
	public static final int PHP_ENDFOREACH = 36;
	public static final int PHP_ENDIF = 37;
	public static final int PHP_ENDSWITCH = 38;
	public static final int PHP_ENDWHILE = 39;
	public static final int PHP_EVAL = 40;
	public static final int PHP_EXIT = 41;
	public static final int PHP_EXTENDS = 42;
	public static final int PHP_FALSE = 43;
	public static final int PHP_FINAL = 44;
	public static final int PHP_FOR = 45;
	public static final int PHP_FOREACH = 46;
	public static final int PHP_FROM = 47;
	public static final int PHP_FUNCTION = 48;
	public static final int PHP_GLOBAL = 49;
	public static final int PHP_HALT_COMPILER = 50;
	public static final int PHP_HEREDOC_TAG = 51;
	public static final int PHP_IF = 52;
	public static final int PHP_IMPLEMENTS = 53;
	public static final int PHP_INCLUDE = 54;
	public static final int PHP_INCLUDE_ONCE = 55;
	public static final int PHP_INSTANCEOF = 56;
	public static final int PHP_INTERFACE = 57;
	public static final int PHP_ISSET = 58;
	public static final int PHP_LINE_COMMENT = 59;
	public static final int PHP_LIST = 60;
	public static final int PHP_LOGICAL_AND = 61;
	public static final int PHP_LOGICAL_OR = 62;
	public static final int PHP_LOGICAL_XOR = 63;
	public static final int PHP_NEW = 64;
	public static final int PHP_NOT = 65;
	public static final int PHP_NUMBER = 66;
	public static final int PHP_OBJECT_OPERATOR = 67;
	public static final int PHP_OPENTAG = 68;
	public static final int PHP_OPERATOR = 69;
	public static final int PHP_PAAMAYIM_NEKUDOTAYIM = 70;
	public static final int PHP_PARENT = 71;
	public static final int PHP_PRINT = 72;
	public static final int PHP_PRIVATE = 73;
	public static final int PHP_PROTECTED = 74;
	public static final int PHP_PUBLIC = 75;
	public static final int PHP_REQUIRE = 76;
	public static final int PHP_REQUIRE_ONCE = 77;
	public static final int PHP_RETURN = 78;
	public static final int PHP_SELF = 79;
	public static final int PHP_SEMICOLON = 80;
	public static final int PHP_STATIC = 81;
	public static final int PHP_STRING = 82;
	public static final int PHP_SWITCH = 83;
	public static final int PHP_THROW = 84;
	public static final int PHP_TOKEN = 85;
	public static final int PHP_TRUE = 86;
	public static final int PHP_TRY = 87;
	public static final int PHP_UNSET = 88;
	public static final int PHP_USE = 89;
	public static final int PHP_VAR = 90;
	public static final int PHP_VAR_COMMENT = 91;
	public static final int PHP_VARIABLE = 92;
	public static final int PHP_WHILE = 93;
	public static final int PHPDOC_ABSTRACT = 94;
	public static final int PHPDOC_ACCESS = 95;
	public static final int PHPDOC_AUTHOR = 96;
	public static final int PHPDOC_CATEGORY = 97;
	public static final int PHPDOC_COMMENT = 98;
	public static final int PHPDOC_COMMENT_END = 99;
	public static final int PHPDOC_COMMENT_START = 100;
	public static final int PHPDOC_COPYRIGHT = 101;
	public static final int PHPDOC_DEPRECATED = 102;
	public static final int PHPDOC_DESC = 103;
	public static final int PHPDOC_EXAMPLE = 104;
	public static final int PHPDOC_EXCEPTION = 105;
	public static final int PHPDOC_FILESOURCE = 106;
	public static final int PHPDOC_FINAL = 107;
	public static final int PHPDOC_GLOBAL = 108;
	public static final int PHPDOC_IGNORE = 109;
	public static final int PHPDOC_INTERNAL = 110;
	public static final int PHPDOC_LICENSE = 111;
	public static final int PHPDOC_LINK = 112;
	public static final int PHPDOC_MAGIC = 113;
	public static final int PHPDOC_NAME = 114;
	public static final int PHPDOC_PACKAGE = 115;
	public static final int PHPDOC_PARAM = 116;
	public static final int PHPDOC_RETURN = 117;
	public static final int PHPDOC_SEE = 118;
	public static final int PHPDOC_SINCE = 119;
	public static final int PHPDOC_STATIC = 120;
	public static final int PHPDOC_STATICVAR = 121;
	public static final int PHPDOC_SUBPACKAGE = 122;
	public static final int PHPDOC_THROWS = 123;
	public static final int PHPDOC_TODO = 124;
	public static final int PHPDOC_TUTORIAL = 125;
	public static final int PHPDOC_USES = 126;
	public static final int PHPDOC_VAR = 127;
	public static final int PHPDOC_VERSION = 128;
	public static final int TASK = 129;
	public static final int UNKNOWN_TOKEN = 130;
	public static final int WHITESPACE = 131;
	public static final int NAMELESS_BLOCK = 1025;

	private static final Object[] TokenMap = {
		PHPRegionTypes.PHP_OPENTAG, PHP_OPENTAG,
		PHPRegionTypes.PHP_CLOSETAG, PHP_CLOSETAG,
		PHPRegionTypes.PHP_CONTENT, PHP_CONTENT,
		PHPRegionTypes.PHP_DIE, PHP_DIE,
		PHPRegionTypes.PHP_SEMICOLON, PHP_SEMICOLON,
		PHPRegionTypes.PHP_CASE, PHP_CASE,
		PHPRegionTypes.PHP_NUMBER, PHP_NUMBER,
		PHPRegionTypes.PHP_GLOBAL, PHP_GLOBAL,
		PHPRegionTypes.PHP_ARRAY, PHP_ARRAY,
		PHPRegionTypes.PHP_FINAL, PHP_FINAL,
		PHPRegionTypes.PHP_PAAMAYIM_NEKUDOTAYIM, PHP_PAAMAYIM_NEKUDOTAYIM,
		PHPRegionTypes.PHP_EXTENDS, PHP_EXTENDS,
		PHPRegionTypes.PHP_VAR_COMMENT, PHP_VAR_COMMENT,
		PHPRegionTypes.PHP_USE, PHP_USE,
		PHPRegionTypes.PHP_INCLUDE, PHP_INCLUDE,
		PHPRegionTypes.PHP_EMPTY, PHP_EMPTY,
		PHPRegionTypes.PHP_CLASS, PHP_CLASS,
		PHPRegionTypes.PHP_FOR, PHP_FOR,
		PHPRegionTypes.PHP_STRING, PHP_STRING,
		PHPRegionTypes.PHP_AS, PHP_AS,
		PHPRegionTypes.PHP_TRY, PHP_TRY,
		PHPRegionTypes.PHP_STATIC, PHP_STATIC,
		PHPRegionTypes.PHP_WHILE, PHP_WHILE,
		PHPRegionTypes.PHP_ENDFOREACH, PHP_ENDFOREACH,
		PHPRegionTypes.PHP_EVAL, PHP_EVAL,
		PHPRegionTypes.PHP_INSTANCEOF, PHP_INSTANCEOF,
		PHPRegionTypes.PHP_ENDWHILE, PHP_ENDWHILE,
		PHPRegionTypes.PHP_BREAK, PHP_BREAK,
		PHPRegionTypes.PHP_DEFAULT, PHP_DEFAULT,
		PHPRegionTypes.PHP_VARIABLE, PHP_VARIABLE,
		PHPRegionTypes.PHP_ABSTRACT, PHP_ABSTRACT,
		PHPRegionTypes.PHP_PRINT, PHP_PRINT,
		PHPRegionTypes.PHP_CURLY_OPEN, PHP_CURLY_OPEN,
		PHPRegionTypes.PHP_ENDIF, PHP_ENDIF,
		PHPRegionTypes.PHP_ELSEIF, PHP_ELSEIF,
		PHPRegionTypes.PHP_HALT_COMPILER, PHP_HALT_COMPILER,
		PHPRegionTypes.PHP_INCLUDE_ONCE, PHP_INCLUDE_ONCE,
		PHPRegionTypes.PHP_NEW, PHP_NEW,
		PHPRegionTypes.PHP_UNSET, PHP_UNSET,
		PHPRegionTypes.PHP_ENDSWITCH, PHP_ENDSWITCH,
		PHPRegionTypes.PHP_FOREACH, PHP_FOREACH,
		PHPRegionTypes.PHP_IMPLEMENTS, PHP_IMPLEMENTS,
		PHPRegionTypes.PHP_CLONE, PHP_CLONE,
		PHPRegionTypes.PHP_ENDFOR, PHP_ENDFOR,
		PHPRegionTypes.PHP_REQUIRE_ONCE, PHP_REQUIRE_ONCE,
		PHPRegionTypes.PHP_FUNCTION, PHP_FUNCTION,
		PHPRegionTypes.PHP_PROTECTED, PHP_PROTECTED,
		PHPRegionTypes.PHP_PRIVATE, PHP_PRIVATE,
		PHPRegionTypes.PHP_ENDDECLARE, PHP_ENDDECLARE,
		PHPRegionTypes.PHP_CURLY_CLOSE, PHP_CURLY_CLOSE,
		PHPRegionTypes.PHP_ELSE, PHP_ELSE,
		PHPRegionTypes.PHP_DO, PHP_DO,
		PHPRegionTypes.PHP_CONTINUE, PHP_CONTINUE,
		PHPRegionTypes.PHP_ECHO, PHP_ECHO,
		PHPRegionTypes.PHP_REQUIRE, PHP_REQUIRE,
		PHPRegionTypes.PHP_CONSTANT_ENCAPSED_STRING, PHP_CONSTANT_ENCAPSED_STRING,
		PHPRegionTypes.PHP_ENCAPSED_AND_WHITESPACE, PHP_ENCAPSED_AND_WHITESPACE,
		PHPRegionTypes.WHITESPACE, WHITESPACE,
		PHPRegionTypes.PHP_SWITCH, PHP_SWITCH,
		PHPRegionTypes.PHP_CONST, PHP_CONST,
		PHPRegionTypes.PHP_PUBLIC, PHP_PUBLIC,
		PHPRegionTypes.PHP_RETURN, PHP_RETURN,
		PHPRegionTypes.PHP_LOGICAL_AND, PHP_LOGICAL_AND,
		PHPRegionTypes.PHP_INTERFACE, PHP_INTERFACE,
		PHPRegionTypes.PHP_EXIT, PHP_EXIT,
		PHPRegionTypes.PHP_LOGICAL_OR, PHP_LOGICAL_OR,
		PHPRegionTypes.PHP_NOT, PHP_NOT,
		PHPRegionTypes.PHP_LOGICAL_XOR, PHP_LOGICAL_XOR,
		PHPRegionTypes.PHP_ISSET, PHP_ISSET,
		PHPRegionTypes.PHP_LIST, PHP_LIST,
		PHPRegionTypes.PHP_CATCH, PHP_CATCH,
		PHPRegionTypes.PHP_VAR, PHP_VAR,
		PHPRegionTypes.PHP_THROW, PHP_THROW,
		PHPRegionTypes.PHP_IF, PHP_IF,
		PHPRegionTypes.PHP_DECLARE, PHP_DECLARE,
		PHPRegionTypes.PHP_OBJECT_OPERATOR, PHP_OBJECT_OPERATOR,
		PHPRegionTypes.PHP_SELF, PHP_SELF,
		PHPRegionTypes.PHPDOC_VAR, PHPDOC_VAR,
		PHPRegionTypes.PHPDOC_SEE, PHPDOC_SEE,
		PHPRegionTypes.PHP_COMMENT, PHP_COMMENT,
		PHPRegionTypes.PHP_COMMENT_START, PHP_COMMENT_START,
		PHPRegionTypes.PHP_COMMENT_END, PHP_COMMENT_END,
		PHPRegionTypes.PHP_LINE_COMMENT, PHP_LINE_COMMENT,
		PHPRegionTypes.PHPDOC_COMMENT, PHPDOC_COMMENT,
		PHPRegionTypes.PHPDOC_COMMENT_START, PHPDOC_COMMENT_START,
		PHPRegionTypes.PHPDOC_COMMENT_END, PHPDOC_COMMENT_END,
		PHPRegionTypes.PHPDOC_NAME, PHPDOC_NAME,
		PHPRegionTypes.PHPDOC_DESC, PHPDOC_DESC,
		PHPRegionTypes.PHPDOC_TODO, PHPDOC_TODO,
		PHPRegionTypes.PHPDOC_LINK, PHPDOC_LINK,
		PHPRegionTypes.PHPDOC_EXAMPLE, PHPDOC_EXAMPLE,
		PHPRegionTypes.PHPDOC_LICENSE, PHPDOC_LICENSE,
		PHPRegionTypes.PHPDOC_PACKAGE, PHPDOC_PACKAGE,
		PHPRegionTypes.PHPDOC_VERSION, PHPDOC_VERSION,
		PHPRegionTypes.PHPDOC_ABSTRACT, PHPDOC_ABSTRACT,
		PHPRegionTypes.PHPDOC_INTERNAL, PHPDOC_INTERNAL,
		PHPRegionTypes.PHPDOC_TUTORIAL, PHPDOC_TUTORIAL,
		PHPRegionTypes.PHPDOC_USES, PHPDOC_USES,
		PHPRegionTypes.PHPDOC_CATEGORY, PHPDOC_CATEGORY,
		PHPRegionTypes.UNKNOWN_TOKEN, UNKNOWN_TOKEN,
		PHPRegionTypes.PHPDOC_FINAL, PHPDOC_FINAL,
		PHPRegionTypes.PHPDOC_SINCE, PHPDOC_SINCE,
		PHPRegionTypes.PHPDOC_PARAM, PHPDOC_PARAM,
		PHPRegionTypes.PHPDOC_MAGIC, PHPDOC_MAGIC,
		PHPRegionTypes.PHPDOC_RETURN, PHPDOC_RETURN,
		PHPRegionTypes.PHPDOC_AUTHOR, PHPDOC_AUTHOR,
		PHPRegionTypes.PHPDOC_ACCESS, PHPDOC_ACCESS,
		PHPRegionTypes.PHPDOC_IGNORE, PHPDOC_IGNORE,
		PHPRegionTypes.PHPDOC_THROWS, PHPDOC_THROWS,
		PHPRegionTypes.PHPDOC_STATIC, PHPDOC_STATIC,
		PHPRegionTypes.PHPDOC_GLOBAL, PHPDOC_GLOBAL,
		PHPRegionTypes.PHPDOC_SUBPACKAGE, PHPDOC_SUBPACKAGE,
		PHPRegionTypes.PHPDOC_FILESOURCE, PHPDOC_FILESOURCE,
		PHPRegionTypes.PHPDOC_EXCEPTION, PHPDOC_EXCEPTION,
		PHPRegionTypes.PHPDOC_COPYRIGHT, PHPDOC_COPYRIGHT,
		PHPRegionTypes.PHPDOC_STATICVAR, PHPDOC_STATICVAR,
		PHPRegionTypes.PHPDOC_DEPRECATED, PHPDOC_DEPRECATED,
		PHPRegionTypes.PHP_HEREDOC_TAG, PHP_HEREDOC_TAG,
		PHPRegionTypes.PHP_TOKEN, PHP_TOKEN,
		PHPRegionTypes.PHP__FUNCTION__, PHP__FUNCTION__,
		PHPRegionTypes.PHP_CASTING, PHP_CASTING,
		PHPRegionTypes.PHP__FILE__, PHP__FILE__,
		PHPRegionTypes.PHP__LINE__, PHP__LINE__,
		PHPRegionTypes.PHP_OPERATOR, PHP_OPERATOR,
		PHPRegionTypes.PHP_PARENT, PHP_PARENT,
		PHPRegionTypes.PHP__CLASS__, PHP__CLASS__,
		PHPRegionTypes.PHP__METHOD__, PHP__METHOD__,
		PHPRegionTypes.PHP_FROM, PHP_FROM,
		PHPRegionTypes.PHP_TRUE, PHP_TRUE,
		PHPRegionTypes.PHP_FALSE, PHP_FALSE/*,
		PHPRegionTypes.TASK, TASK, "NAMELESS_BLOCK", NAMELESS_BLOCK*/ //$NON-NLS-1$
	};

	public static int getTokenNumber(String type) {
		for (int i = 0; i < TokenMap.length; i+=2) {
			if (type.equals(TokenMap[i])) {
				return ((Integer) TokenMap[i + 1]).intValue();
			}
		}
		return 0;
	}

	public static String getTokenString(int number) {
		for (int i = 1; i < TokenMap.length; i+=2) {
			if (((Integer) TokenMap[i]).intValue() == number) {
				return (String) TokenMap[i - 1];
			}
		}
		return "";
	}
}
