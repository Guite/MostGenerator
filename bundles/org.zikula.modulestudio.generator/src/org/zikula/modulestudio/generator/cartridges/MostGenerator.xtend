package org.zikula.modulestudio.generator.cartridges

import de.guite.modulestudio.metamodel.Application
import org.eclipse.core.runtime.IProgressMonitor
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.xtext.generator.GeneratorDelegate
import org.eclipse.xtext.generator.IFileSystemAccess2
import org.eclipse.xtext.generator.IGenerator
import org.eclipse.xtext.generator.IGenerator2
import org.eclipse.xtext.generator.IGeneratorContext
import org.zikula.modulestudio.generator.application.IMostFileSystemAccess
import org.zikula.modulestudio.generator.cartridges.symfony.SymfonyBundleGenerator
import org.zikula.modulestudio.generator.extensions.transformation.PersistenceTransformer

class MostGenerator extends GeneratorDelegate implements IGenerator, IGenerator2 {

    String cartridge = ''

    IProgressMonitor monitor = null

    override void doGenerate(Resource input, IFileSystemAccess2 fsa, IGeneratorContext context) {
        val app = input.contents.head as Application

        val mostFsa = fsa as IMostFileSystemAccess

        val firstEntity = app.entities.head
        val pkFields = firstEntity.fields.filter['id'.equals(name)] //$NON-NLS-1$
        if (pkFields.empty) {
            app.transform(mostFsa)
        }

        if ('symfony'.equals(cartridge)) { //$NON-NLS-1$
            new SymfonyBundleGenerator().generate(app, mostFsa, monitor)
        }
        //else if ('something'.equals(cartridge)) //$NON-NLS-1$
        //    new SomethingGenerator().generate(app, mostFsa, monitor)
    }

    def private transform(Application it, IMostFileSystemAccess fsa) {
        new PersistenceTransformer().modify(it, fsa)
    }

    def setCartridge(String cartridgeName) {
        cartridge = cartridgeName
    }

    def setMonitor(IProgressMonitor pm) {
        monitor = pm
    }

    override beforeGenerate(Resource input, IFileSystemAccess2 fsa, IGeneratorContext context) {
        // nothing
    }

    override afterGenerate(Resource input, IFileSystemAccess2 fsa, IGeneratorContext context) {
        // nothing
    }
}
