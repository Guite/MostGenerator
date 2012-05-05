package org.zikula.modulestudio.generator.cartridges

import com.google.inject.Inject
import de.guite.modulestudio.metamodel.modulestudio.Application
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.xtext.generator.IFileSystemAccess
import org.eclipse.xtext.generator.IGenerator
import org.zikula.modulestudio.generator.cartridges.zclassic.ZclassicGenerator
import org.zikula.modulestudio.generator.cartridges.zoo.ZooGenerator
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.transformation.PersistenceTransformer

class MostGenerator implements IGenerator {
    @Inject extension ModelExtensions

    String cartridge = ''

    override void doGenerate(Resource resource, IFileSystemAccess fsa) {
        val app = resource.contents.head as Application

        val firstEntity = app.getAllEntities.head
        val pkFields = firstEntity.fields.filter(e|e.name == 'id')

        if (pkFields.isEmpty)
            app.transform

    	if (cartridge == 'zclassic')
    	    new ZclassicGenerator().generate(app, fsa)
    	else if (cartridge == 'zoo')
    	    new ZooGenerator().generate(app, fsa)
    }

    def private transform(Application it) {
        new PersistenceTransformer().modify(it)
    }

    def setCartridge(String cartridgeName) {
        cartridge = cartridgeName
    }
}
