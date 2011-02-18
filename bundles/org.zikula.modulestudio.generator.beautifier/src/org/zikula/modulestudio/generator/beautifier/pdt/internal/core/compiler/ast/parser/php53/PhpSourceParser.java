package org.zikula.modulestudio.generator.beautifier.pdt.internal.core.compiler.ast.parser.php53;

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
 * Based on package org.eclipse.php.internal.core.compiler.ast.parser.php53;
 * 
 *******************************************************************************/

import java.io.Reader;

import org.eclipse.dltk.ast.parser.IModuleDeclaration;
import org.eclipse.dltk.compiler.problem.IProblemReporter;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.compiler.ast.parser.AbstractPHPSourceParser;

public class PhpSourceParser extends AbstractPHPSourceParser {

    public PhpSourceParser() {
        super();
    }

    public PhpSourceParser(String fileName) {
        super(fileName);
    }

    @Override
    public IModuleDeclaration parse(Reader in, IProblemReporter reporter)
            throws Exception {
        final CompilerAstLexer lexer = new CompilerAstLexer(in);
        final CompilerAstParser parser = new CompilerAstParser(lexer);
        parser.setProblemReporter(reporter);

        return parse(parser);
    }
}
