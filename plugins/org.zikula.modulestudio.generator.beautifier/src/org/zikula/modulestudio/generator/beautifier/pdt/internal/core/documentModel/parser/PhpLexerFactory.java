package org.zikula.modulestudio.generator.beautifier.pdt.internal.core.documentModel.parser;

/**
 * Based on package org.eclipse.php.internal.core.documentModel.parser;
 */

import java.io.InputStream;
import java.io.Reader;

public class PhpLexerFactory {

    public static AbstractPhpLexer createLexer(Reader reader) {
        return new org.zikula.modulestudio.generator.beautifier.pdt.internal.core.documentModel.parser.php53.PhpLexer(
                reader);
    }

    public static AbstractPhpLexer createLexer(InputStream stream) {
        return new org.zikula.modulestudio.generator.beautifier.pdt.internal.core.documentModel.parser.php53.PhpLexer(
                stream);
    }
}
