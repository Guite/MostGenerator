package org.zikula.modulestudio.generator.beautifier.pdt.internal.core.compiler.ast.parser;

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
 * Based on package org.eclipse.php.internal.core.compiler.ast.parser;
 * 
 *******************************************************************************/

import org.eclipse.dltk.ast.parser.AbstractSourceParser;
import org.eclipse.dltk.ast.parser.IModuleDeclaration;
import org.eclipse.dltk.ast.parser.ISourceParser;
import org.eclipse.dltk.ast.parser.ISourceParserFactory;
import org.eclipse.dltk.compiler.env.IModuleSource;
import org.eclipse.dltk.compiler.problem.IProblemReporter;

public class PHPSourceParserFactory extends AbstractSourceParser implements
        ISourceParserFactory, ISourceParser {

    @Override
    public ISourceParser createSourceParser() {
        return this;
    }

    /*
     * (non-Javadoc)
     * @see
     * org.eclipse.dltk.ast.parser.ISourceParser#parse(org.eclipse.dltk.compiler
     * .env.IModuleSource, org.eclipse.dltk.compiler.problem.IProblemReporter)
     */
    @Override
    public IModuleDeclaration parse(IModuleSource module,
            IProblemReporter reporter) {
        final String fileName = module.getFileName();
        final AbstractPHPSourceParser parser = createParser(fileName);
        return parser.parse(module, reporter);
    }

    protected AbstractPHPSourceParser createParser(String fileName) {
        return new org.zikula.modulestudio.generator.beautifier.pdt.internal.core.compiler.ast.parser.php53.PhpSourceParser(
                fileName);
    }

    /**
     * Create source parser for the PHP version
     * 
     * @return source parser instance
     */
    public static AbstractPHPSourceParser createParser() {
        return new org.zikula.modulestudio.generator.beautifier.pdt.internal.core.compiler.ast.parser.php53.PhpSourceParser();
    }
}
