package org.zikula.modulestudio.generator.cartridges.zclassic

import com.google.inject.Inject
import de.guite.modulestudio.metamodel.modulestudio.Application
import org.eclipse.core.runtime.IProgressMonitor
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.emf.mwe.core.monitor.ProgressMonitor
import org.eclipse.xtext.generator.IFileSystemAccess
import org.eclipse.xtext.generator.IGenerator
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.ControllerLayer
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.FormHandler
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.Installer
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.Listeners
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.Uploads
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.Workflow
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.apis.Blocks
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.apis.ContentType
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.apis.Mailz
import org.zikula.modulestudio.generator.cartridges.zclassic.models.Entities
import org.zikula.modulestudio.generator.cartridges.zclassic.models.Repository
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.Bootstrap
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.Docs
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.Translations
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.VersionFile
import org.zikula.modulestudio.generator.cartridges.zclassic.tests.Tests
import org.zikula.modulestudio.generator.cartridges.zclassic.view.Forms
import org.zikula.modulestudio.generator.cartridges.zclassic.view.Images
import org.zikula.modulestudio.generator.cartridges.zclassic.view.Plugins
import org.zikula.modulestudio.generator.cartridges.zclassic.view.Styles
import org.zikula.modulestudio.generator.cartridges.zclassic.view.Views
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.workflow.components.ManualProgressMonitor

class ZclassicGenerator implements IGenerator {

    @Inject extension ModelExtensions = new ModelExtensions()

    override doGenerate(Resource resource, IFileSystemAccess fsa) {
        generate(resource.contents.head as Application, fsa)
    }

    def generate(Application it, IFileSystemAccess fsa) {
        compile(fsa, null)
    }

    def compile(Application it, IFileSystemAccess fsa, Object monitor) {
        var ManualProgressMonitor pm
        /*if (monitor != null)
            pm = monitor
        else*/
            pm = new ManualProgressMonitor()
println('TODO: progress monitor')

        pm.newTask('Basic information')
        println('Generating basic information')
    	new VersionFile().generate(it, fsa)

	    pm.newTask('Model: Entity classes')
        println('Generating entity classes')
	    new Entities().generate(it, fsa)

        pm.newTask('Model: Repository classes')
        println('Generating repository classes')
        new Repository().generate(it, fsa)

	    pm.newTask('Controller: Application installer')
        println('Generating application installer')
	    new Installer().generate(it, fsa)
        pm.newTask('Controller: Controller classes')
        println('Generating controller classes')
    	new ControllerLayer().generate(it, fsa)
	    pm.newTask('Controller: Action handler classes')
        println('Generating action handler classes')
	    new FormHandler().generate(it, fsa)
        pm.newTask('Controller: Persistent event handlers')
        println('Generating persistent event handlers')
        new Listeners().generate(it, fsa)
        pm.newTask('Controller: Bootstrapping')
        println('Generating bootstrapping')
        new Bootstrap().generate(it, fsa)
        pm.newTask('Controller: Workflows')
        println('Generating workflows')
        new Workflow().generate(it, fsa)

	    pm.newTask('View: Rendering templates')
        println('Generating view templates')
	    new Views().generate(it, fsa)
	    pm.newTask('View: Form templates')
        println('Generating form templates')
	    new Forms().generate(it, fsa)
    	pm.newTask('View: Module-specific plugins')
        println('Generating application-specific plugins')
    	new Plugins().generate(it, fsa)
	    pm.newTask('View: CSS definitions')
        println('Generating css definitions')
	    new Styles().generate(it, fsa)
        pm.newTask('View: Images')
        println('Generating images')
        new Images().generate(it, fsa)

        pm.newTask('Additions: Blocks')
        println('Generating blocks')
        new Blocks().generate(it, fsa)
    if (hasUploads) {
        pm.newTask('Additions: Upload handlers')
        println('Generating upload handlers')
        new Uploads().generate(it, fsa)
    }
        pm.newTask('Additions: Content type api')
        println('Generating content type api')
        new ContentType().generate(it, fsa)
        pm.newTask('Additions: Mailz api')
        println('Generating mailz api')
        new Mailz().generate(it, fsa)
        pm.newTask('Additions: Translations')
        println('Generating translations')
        new Translations().generate(it, fsa)
        pm.newTask('Additions: Documentation')
        println('Generating documentation')
        new Docs().generate(it, fsa)

        pm.newTask('Additions: Tests')
        println('Generating unit tests')
        new Tests().generate(it, fsa)
    }

    def private newTask(Object it, String msg) {
        switch (it) {
            IProgressMonitor: it.subTask(msg)
            ProgressMonitor: it.subTask(msg)
            ManualProgressMonitor: ''
        }
    }
}
