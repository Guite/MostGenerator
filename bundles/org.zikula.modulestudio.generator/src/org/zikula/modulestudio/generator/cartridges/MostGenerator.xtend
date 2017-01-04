package org.zikula.modulestudio.generator.cartridges

import de.guite.modulestudio.metamodel.Application
import org.eclipse.core.runtime.IProgressMonitor
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.xtext.generator.GeneratorDelegate
import org.eclipse.xtext.generator.IFileSystemAccess2
import org.eclipse.xtext.generator.IGenerator
import org.eclipse.xtext.generator.IGenerator2
import org.eclipse.xtext.generator.IGeneratorContext
import org.zikula.modulestudio.generator.cartridges.zclassic.ZclassicGenerator
import org.zikula.modulestudio.generator.extensions.transformation.PersistenceTransformer

class MostGenerator extends GeneratorDelegate implements IGenerator, IGenerator2 {

    String cartridge = ''

    IProgressMonitor monitor = null

    override void doGenerate(Resource input, IFileSystemAccess2 fsa, IGeneratorContext context) {
        val app = input.contents.head as Application

        val firstEntity = app.entities.head
        val pkFields = firstEntity.fields.filter['id'.equals(name)] //$NON-NLS-1$

        if (pkFields.empty) {
            app.transform
        }

        if ('zclassic'.equals(cartridge)) { //$NON-NLS-1$
            new ZclassicGenerator().generate(app, fsa, monitor)
        }
        //else if ('something'.equals(cartridge)) //$NON-NLS-1$
        //    new SomethingGenerator().generate(app, fsa, monitor)
    }

    def private transform(Application it) {
        new PersistenceTransformer().modify(it)
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
