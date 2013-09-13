package org.zikula.modulestudio.generator.cartridges

import com.google.inject.Inject
import de.guite.modulestudio.metamodel.modulestudio.Application
import org.eclipse.core.runtime.IProgressMonitor
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.xtext.generator.IFileSystemAccess
import org.eclipse.xtext.generator.IGenerator
import org.zikula.modulestudio.generator.cartridges.zclassic.ZclassicGenerator
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.transformation.PersistenceTransformer

class MostGenerator implements IGenerator {
    @Inject extension ModelExtensions = new ModelExtensions

    String cartridge = ''

    IProgressMonitor monitor = null

    override void doGenerate(Resource resource, IFileSystemAccess fsa) {
        val app = resource.contents.head as Application

        val firstEntity = app.getAllEntities.head
        val pkFields = firstEntity.fields.filter[name == 'id']

        if (pkFields.empty)
            app.transform

        if (cartridge == 'zclassic')
            new ZclassicGenerator().generate(app, fsa, monitor)
        //else if (cartridge == 'something')
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
}
