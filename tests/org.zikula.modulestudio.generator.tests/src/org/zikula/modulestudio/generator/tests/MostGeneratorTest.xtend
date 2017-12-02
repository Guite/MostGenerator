/**
 * Copyright (c) 2007-2017 Axel Guckelsberger
 */
package org.zikula.modulestudio.generator.tests

import org.eclipse.xtext.generator.GeneratorContext
import org.eclipse.xtext.generator.IGeneratorContext
import org.eclipse.xtext.generator.InMemoryFileSystemAccess
import org.eclipse.xtext.resource.XtextResource
import org.junit.runner.RunWith
import org.xpect.XpectImport
import org.xpect.expectation.IStringExpectation
import org.xpect.expectation.StringExpectation
import org.xpect.parameter.ParameterParser
import org.xpect.runner.LiveExecutionType
import org.xpect.runner.Xpect
import org.xpect.runner.XpectRunner
import org.xpect.runner.XpectTestFiles
import org.xpect.runner.XpectTestFiles.FileRoot
import org.xpect.xtext.lib.setup.ThisResource
import org.xpect.xtext.lib.setup.XtextStandaloneSetup
import org.xpect.xtext.lib.setup.XtextWorkspaceSetup
import org.xpect.xtext.lib.util.InMemoryFileSystemAccessFormatter
import org.zikula.modulestudio.generator.cartridges.MostGenerator

/**
 * Tests for the generator.
 */
@RunWith(XpectRunner)
@XpectImport(#[XtextStandaloneSetup, XtextWorkspaceSetup])
@XpectTestFiles(relativeTo = FileRoot.PROJECT, baseDir = "model/testcases", fileExtensions="xt")
class MostGeneratorTest {

	@Xpect(liveExecution = LiveExecutionType.FAST)
	@ParameterParser(syntax = "('file' arg2=TEXT)?")
	def static void generated(@StringExpectation IStringExpectation expectation, @ThisResource XtextResource resource, String arg2) {
		val fsa = new InMemoryFileSystemAccess
		val IGeneratorContext context = createGeneratorContext(resource)

        val generator = new MostGenerator
        generator.cartridge = 'zclassic'

		generator.beforeGenerate(resource, fsa, context)
		generator.doGenerate(resource, fsa, context)
		generator.afterGenerate(resource, fsa, context)

		val files = createInMemoryFileSystemAccessFormatter.includeOnlyFileNamesEndingWith(arg2).apply(fsa)
		expectation.assertEquals(files)
	}

	def static protected createGeneratorContext(XtextResource resource) {
		new GeneratorContext
	}

	def static protected createInMemoryFileSystemAccessFormatter() {
		new InMemoryFileSystemAccessFormatter
	}
}
