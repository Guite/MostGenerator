/**
 * Copyright (c) 2007-2023 Axel Guckelsberger
 */
package org.zikula.modulestudio.generator.tests

import de.guite.modulestudio.metamodel.Application
import org.eclipse.xpect.XpectImport
import org.eclipse.xpect.expectation.ILinesExpectation
import org.eclipse.xpect.expectation.IStringExpectation
import org.eclipse.xpect.expectation.LinesExpectation
import org.eclipse.xpect.expectation.StringExpectation
import org.eclipse.xpect.expectation.impl.AbstractExpectation
import org.eclipse.xpect.parameter.ParameterParser
import org.eclipse.xpect.runner.LiveExecutionType
import org.eclipse.xpect.runner.Xpect
import org.eclipse.xpect.runner.XpectRunner
import org.eclipse.xpect.runner.XpectTestFiles
import org.eclipse.xpect.runner.XpectTestFiles.FileRoot
import org.eclipse.xpect.xtext.lib.setup.ThisResource
import org.eclipse.xpect.xtext.lib.setup.XtextStandaloneSetup
import org.eclipse.xpect.xtext.lib.setup.XtextWorkspaceSetup
import org.eclipse.xpect.xtext.lib.util.InMemoryFileSystemAccessFormatter
import org.eclipse.xtext.generator.GeneratorContext
import org.eclipse.xtext.generator.IGeneratorContext
import org.eclipse.xtext.resource.XtextResource
import org.junit.ComparisonFailure
import org.junit.runner.RunWith
import org.zikula.modulestudio.generator.application.MostInMemoryFileSystemAccess
import org.zikula.modulestudio.generator.cartridges.MostGenerator

/**
 * Tests for the generator.
 */
@RunWith(XpectRunner)
@XpectImport(#[XtextStandaloneSetup, XtextWorkspaceSetup])
@XpectTestFiles(relativeTo = FileRoot.PROJECT, baseDir = "model", fileExtensions="xt")
class MostGeneratorTest {

    static String negation = '!' //$NON-NLS-1$
    static Boolean debug = false

    @Xpect(liveExecution = LiveExecutionType.FAST)
    def static void files(
        @LinesExpectation ILinesExpectation expectation,
        @ThisResource XtextResource resource
    ) {
        val fsa = generate(resource)

        val expectedFilePathes = (expectation as AbstractExpectation).expectation.split('\n') //$NON-NLS-1$
        val fileList = fsa.textFiles.keySet.toList
        if (debug) {
            for (entry : fileList) {
                println("Generated: " + entry)
            }
        }
        for (filePathRaw : expectedFilePathes) {
            var filePath = filePathRaw.trim
            if (!filePath.empty) {
                if (debug) {
                    println("Expected: " + filePath)
                }
                if (filePath.isNegated) {
                    filePath = filePath.replaceFirst(negation, '') //$NON-NLS-1$
                    if (fileList.contains(filePath)) {
                        throw new ComparisonFailure('Unexpected file was found!', '', filePath)
                    }
                } else {
                    if (!fileList.contains(filePath)) {
                        throw new ComparisonFailure('Expected file was not found!', filePath, '')
                    }
                }
            }
        }
    }

    def static private isNegated(String filePath) {
        filePath.startsWith(negation)
    }

    @Xpect(liveExecution = LiveExecutionType.FAST)
    @ParameterParser(syntax = "('file' arg2=TEXT)?")
    def static void generated(@StringExpectation IStringExpectation expectation, @ThisResource XtextResource resource, String arg2) {
        val fsa = generate(resource)

        val files = createInMemoryFileSystemAccessFormatter.includeOnlyFileNamesEndingWith(arg2).apply(fsa)
        expectation.assertEquals(files)
    }

    def static private generate(XtextResource resource) {
        val fsa = new MostInMemoryFileSystemAccess
        fsa.app = resource.contents.head as Application

        val context = createGeneratorContext(resource)

        val generator = new MostGenerator
        generator.cartridge = 'zclassic' //$NON-NLS-1$

        generator.beforeGenerate(resource, fsa, context)
        generator.doGenerate(resource, fsa, context)
        generator.afterGenerate(resource, fsa, context)

        fsa
    }

    def static private IGeneratorContext createGeneratorContext(XtextResource resource) {
        new GeneratorContext
    }

    def static private createInMemoryFileSystemAccessFormatter() {
        new InMemoryFileSystemAccessFormatter
    }
}
