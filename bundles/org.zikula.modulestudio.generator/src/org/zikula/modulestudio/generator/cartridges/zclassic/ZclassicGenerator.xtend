package org.zikula.modulestudio.generator.cartridges.zclassic

import de.guite.modulestudio.metamodel.Application
import de.guite.modulestudio.metamodel.AuthMethodType
import org.eclipse.core.runtime.IProgressMonitor
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.xtext.generator.IFileSystemAccess
import org.eclipse.xtext.generator.IGenerator
import org.zikula.modulestudio.generator.application.IMostFileSystemAccess
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.ControllerLayer
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.Events
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.FormHandler
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.HelperServices
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.Installer
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.Listeners
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.ServiceDefinitions
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.Uploads
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.Workflow
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.additions.AuthenticationMethod
import org.zikula.modulestudio.generator.cartridges.zclassic.models.AppSettings
import org.zikula.modulestudio.generator.cartridges.zclassic.models.Entities
import org.zikula.modulestudio.generator.cartridges.zclassic.models.Factory
import org.zikula.modulestudio.generator.cartridges.zclassic.models.Repository
import org.zikula.modulestudio.generator.cartridges.zclassic.models.business.ListEntryValidator
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.BundleFile
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.ComposerFile
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.DependencyInjection
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.Docs
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.GitIgnore
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.PhpUnitXmlDist
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.Translations
import org.zikula.modulestudio.generator.cartridges.zclassic.tests.Tests
import org.zikula.modulestudio.generator.cartridges.zclassic.view.Forms
import org.zikula.modulestudio.generator.cartridges.zclassic.view.Images
import org.zikula.modulestudio.generator.cartridges.zclassic.view.Plugins
import org.zikula.modulestudio.generator.cartridges.zclassic.view.Styles
import org.zikula.modulestudio.generator.cartridges.zclassic.view.Views
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class ZclassicGenerator implements IGenerator {

    extension ModelExtensions = new ModelExtensions
    extension Utils = new Utils

    IMostFileSystemAccess fsa
    IProgressMonitor pm

    override doGenerate(Resource resource, IFileSystemAccess fsa) {
        this.fsa = fsa as IMostFileSystemAccess
        this.pm = null
        generateApp(resource.contents.head as Application)
    }

    def generate(Application it, IMostFileSystemAccess fsa, IProgressMonitor pm) {
        this.fsa = fsa
        this.pm = pm
        generateApp
    }

    def private generateApp(Application it) {
        generateBasicFiles

        generateModel
        generateController
        generateView

        generateIntegration
        generateAdditions
    }

    def private generateBasicFiles(Application it) {
        pm?.subTask('Basic information')
        'Generating basic information'.printIfNotTesting(fsa)
        new BundleFile().generate(it, fsa)
        new DependencyInjection().generate(it, fsa)
        new ComposerFile().generate(it, fsa)
        new GitIgnore().generate(it, fsa)
        if (generateTests) {
            new PhpUnitXmlDist().generate(it, fsa)
        }
    }

    def private generateModel(Application it) {
        pm?.subTask('Model: Entity classes')
        'Generating entity classes'.printIfNotTesting(fsa)
        new Entities().generate(it, fsa)

        pm?.subTask('Model: Repository classes')
        'Generating repository classes'.printIfNotTesting(fsa)
        new Repository().generate(it, fsa)

        pm?.subTask('Model: Factory class')
        'Generating factory class'.printIfNotTesting(fsa)
        new Factory().generate(it, fsa)

        if (!variables.empty) {
            pm?.subTask('Model: Application settings class')
            'Generating application settings class'.printIfNotTesting(fsa)
            new AppSettings().generate(it, fsa)
        }

        if (hasListFields) {
            new ListEntryValidator().generate(it, fsa)
        }
    }

    def private generateController(Application it) {
        pm?.subTask('Controller: Application installer')
        'Generating application installer'.printIfNotTesting(fsa)
        new Installer().generate(it, fsa)
        pm?.subTask('Controller: Controller classes')
        'Generating controller classes'.printIfNotTesting(fsa)
        new ControllerLayer().generate(it, fsa)
        pm?.subTask('Controller: Helper service classes')
        'Generating helper service classes'.printIfNotTesting(fsa)
        new HelperServices().generate(it, fsa)
        pm?.subTask('Controller: Action handler classes')
        'Generating action handler classes'.printIfNotTesting(fsa)
        new FormHandler().generate(it, fsa)
        pm?.subTask('Controller: Event listeners')
        'Generating Event listeners'.printIfNotTesting(fsa)
        new Listeners().generate(it, fsa)
        pm?.subTask('Controller: Service definitions')
        'Generating service definitions'.printIfNotTesting(fsa)
        new ServiceDefinitions().generate(it, fsa)
        pm?.subTask('Controller: Custom event definitions')
        'Generating custom event definitions'.printIfNotTesting(fsa)
        new Events().generate(it, fsa)
        pm?.subTask('Controller: Workflows')
        'Generating workflows'.printIfNotTesting(fsa)
        new Workflow().generate(it, fsa)
        if (hasUploads) {
            pm?.subTask('Controller: Upload handlers')
            'Generating upload handlers'.printIfNotTesting(fsa)
            new Uploads().generate(it, fsa)
        }
        pm?.subTask('Controller: JavaScript files')
        'Generating JavaScript files'.printIfNotTesting(fsa)
        new JavaScriptFiles().generate(it, fsa)
    }

    def private generateView(Application it) {
        pm?.subTask('View: Rendering templates')
        'Generating view templates'.printIfNotTesting(fsa)
        new Views().generate(it, fsa)
        pm?.subTask('View: Form templates')
        'Generating form templates'.printIfNotTesting(fsa)
        new Forms().generate(it, fsa)
        pm?.subTask('View: Module-specific plugins')
        'Generating application-specific plugins'.printIfNotTesting(fsa)
        new Plugins().generate(it, fsa)
        pm?.subTask('View: CSS definitions')
        'Generating css definitions'.printIfNotTesting(fsa)
        new Styles().generate(it, fsa)
        pm?.subTask('View: Images')
        'Generating images'.printIfNotTesting(fsa)
        new Images().generate(it, fsa)
    }

    def private generateIntegration(Application it) {
        if (authenticationMethod != AuthMethodType.NONE) {
            new AuthenticationMethod().generate(it, fsa)
        }
    }

    def private generateAdditions(Application it) {
        pm?.subTask('Additions: Translations')
        'Generating translations'.printIfNotTesting(fsa)
        new Translations().generate(it, fsa)
        pm?.subTask('Additions: Documentation')
        'Generating documentation'.printIfNotTesting(fsa)
        new Docs().generate(it, fsa)

        if (generateTests) {
            pm?.subTask('Additions: Tests')
            'Generating unit tests'.printIfNotTesting(fsa)
            new Tests().generate(it, fsa)
        }
    }
}
