package org.zikula.modulestudio.generator.cartridges.zoo

import com.google.inject.Inject
import de.guite.modulestudio.metamodel.modulestudio.Application
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.xtext.generator.IFileSystemAccess
import org.eclipse.xtext.generator.IGenerator
import org.zikula.modulestudio.generator.extensions.Utils

class ZooGenerator implements IGenerator {

    @Inject extension Utils = new Utils()

    override void doGenerate(Resource resource, IFileSystemAccess fsa) {
        generate(resource.contents.head as Application, fsa)
    }

    def generate(Application it, IFileSystemAccess fsa) {
        fsa.generateFile('zoo.txt', greeting)
    }

    def private greeting(Application it) '''
        Hello «author» :-)

        This becomes the zOO application generator.
        It is going to create a zOO application out of your «appName» application.
  	'''
}
