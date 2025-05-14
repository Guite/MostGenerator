package org.zikula.modulestudio.generator.cartridges.symfony

import de.guite.modulestudio.metamodel.Application
import org.eclipse.core.runtime.IProgressMonitor
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.xtext.generator.IFileSystemAccess
import org.eclipse.xtext.generator.IGenerator
import org.zikula.modulestudio.generator.application.IMostFileSystemAccess
import org.zikula.modulestudio.generator.cartridges.symfony.controller.ControllerLayer
import org.zikula.modulestudio.generator.cartridges.symfony.controller.EventSubscribers
import org.zikula.modulestudio.generator.cartridges.symfony.controller.Events
import org.zikula.modulestudio.generator.cartridges.symfony.controller.FormHandler
import org.zikula.modulestudio.generator.cartridges.symfony.controller.HelperServices
import org.zikula.modulestudio.generator.cartridges.symfony.controller.Workflow
import org.zikula.modulestudio.generator.cartridges.symfony.controller.bundle.Configuration
import org.zikula.modulestudio.generator.cartridges.symfony.controller.bundle.Initializer
import org.zikula.modulestudio.generator.cartridges.symfony.controller.bundle.MetaData
import org.zikula.modulestudio.generator.cartridges.symfony.controller.bundle.ServiceDefinitions
import org.zikula.modulestudio.generator.cartridges.symfony.models.Entities
import org.zikula.modulestudio.generator.cartridges.symfony.models.Factory
import org.zikula.modulestudio.generator.cartridges.symfony.models.Repository
import org.zikula.modulestudio.generator.cartridges.symfony.models.business.ListEntryValidator
import org.zikula.modulestudio.generator.cartridges.symfony.smallstuff.BundleFile
import org.zikula.modulestudio.generator.cartridges.symfony.smallstuff.ComposerFile
import org.zikula.modulestudio.generator.cartridges.symfony.smallstuff.Docs
import org.zikula.modulestudio.generator.cartridges.symfony.smallstuff.GitIgnore
import org.zikula.modulestudio.generator.cartridges.symfony.smallstuff.PhpCsFixer
import org.zikula.modulestudio.generator.cartridges.symfony.smallstuff.PhpUnitXml
import org.zikula.modulestudio.generator.cartridges.symfony.smallstuff.Phpstan
import org.zikula.modulestudio.generator.cartridges.symfony.smallstuff.Recipe
import org.zikula.modulestudio.generator.cartridges.symfony.smallstuff.Translations
import org.zikula.modulestudio.generator.cartridges.symfony.tests.Tests
import org.zikula.modulestudio.generator.cartridges.symfony.view.Forms
import org.zikula.modulestudio.generator.cartridges.symfony.view.Images
import org.zikula.modulestudio.generator.cartridges.symfony.view.Plugins
import org.zikula.modulestudio.generator.cartridges.symfony.view.Styles
import org.zikula.modulestudio.generator.cartridges.symfony.view.Views
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class SymfonyBundleGenerator implements IGenerator {

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

        generateAdditions
    }

    def private generateBasicFiles(Application it) {
        pm?.subTask('Basic information')
        'Generating basic information'.printIfNotTesting(fsa)
        new BundleFile().generate(it, fsa)
        new ComposerFile().generate(it, fsa)
        new GitIgnore().generate(it, fsa)
        new PhpCsFixer().generate(it, fsa)
        new Phpstan().generate(it, fsa)
        new PhpUnitXml().generate(it, fsa)
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

        if (hasListFields) {
            new ListEntryValidator().generate(it, fsa)
        }
    }

    def private generateController(Application it) {
        pm?.subTask('Controller: Bundle initializer')
        'Generating bundle initializer'.printIfNotTesting(fsa)
        new Initializer().generate(it, fsa)
        pm?.subTask('Controller: Bundle meta data')
        'Generating bundle meta data'.printIfNotTesting(fsa)
        new MetaData().generate(it, fsa)
        if (needsConfig) {
            pm?.subTask('Controller: Bundle configuration definition')
            'Generating bundle configuration definition'.printIfNotTesting(fsa)
            new Configuration().generate(it, fsa)
        }
        pm?.subTask('Controller: Bundle service definitions')
        'Generating bundle service definitions'.printIfNotTesting(fsa)
        new ServiceDefinitions().generate(it, fsa)
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
        new EventSubscribers().generate(it, fsa)
        pm?.subTask('Controller: Custom event definitions')
        'Generating custom event definitions'.printIfNotTesting(fsa)
        new Events().generate(it, fsa)
        pm?.subTask('Controller: Workflows')
        'Generating workflows'.printIfNotTesting(fsa)
        new Workflow().generate(it, fsa)
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

    def private generateAdditions(Application it) {
        pm?.subTask('Additions: Translations')
        'Generating translations'.printIfNotTesting(fsa)
        new Translations().generate(it, fsa)
        pm?.subTask('Additions: Documentation')
        'Generating documentation'.printIfNotTesting(fsa)
        new Docs().generate(it, fsa)
        pm?.subTask('Additions: Flex recipe')
        'Generating Flex recipe'.printIfNotTesting(fsa)
        new Recipe().generate(it, fsa)
        pm?.subTask('Additions: Tests')
        'Generating unit tests'.printIfNotTesting(fsa)
        new Tests().generate(it, fsa)
    }
}
