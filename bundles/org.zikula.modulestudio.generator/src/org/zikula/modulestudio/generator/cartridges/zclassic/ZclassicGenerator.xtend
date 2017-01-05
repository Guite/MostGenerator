package org.zikula.modulestudio.generator.cartridges.zclassic

import de.guite.modulestudio.metamodel.Application
import org.eclipse.core.runtime.IProgressMonitor
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.xtext.generator.IFileSystemAccess
import org.eclipse.xtext.generator.IGenerator
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.ControllerLayer
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.Events
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.FormHandler
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.HelperServices
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.Installer
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.Listeners
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.ServiceDefinitions
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.Uploads
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.Workflow
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.additions.BlockList
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.additions.BlockModeration
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.additions.ContentTypeList
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.additions.ContentTypeSingle
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.additions.Mailz
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.additions.MultiHook
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.additions.Newsletter
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.additions.Tag
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.javascript.DisplayFunctions
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.javascript.EditFunctions
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.javascript.Finder
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.javascript.TreeFunctions
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.javascript.Validation
import org.zikula.modulestudio.generator.cartridges.zclassic.models.Entities
import org.zikula.modulestudio.generator.cartridges.zclassic.models.Factory
import org.zikula.modulestudio.generator.cartridges.zclassic.models.Repository
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.Bootstrap
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.ComposerFile
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.DependencyInjection
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.Docs
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.GitIgnore
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.ModuleFile
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.PhpUnitXmlDist
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.Translations
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.TravisFile
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.ZikulaManifest
import org.zikula.modulestudio.generator.cartridges.zclassic.tests.Tests
import org.zikula.modulestudio.generator.cartridges.zclassic.view.Forms
import org.zikula.modulestudio.generator.cartridges.zclassic.view.Images
import org.zikula.modulestudio.generator.cartridges.zclassic.view.Plugins
import org.zikula.modulestudio.generator.cartridges.zclassic.view.Styles
import org.zikula.modulestudio.generator.cartridges.zclassic.view.Views
import org.zikula.modulestudio.generator.extensions.ControllerExtensions
import org.zikula.modulestudio.generator.extensions.GeneratorSettingsExtensions
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.WorkflowExtensions

class ZclassicGenerator implements IGenerator {

    extension ControllerExtensions = new ControllerExtensions
    extension GeneratorSettingsExtensions = new GeneratorSettingsExtensions
    extension ModelBehaviourExtensions = new ModelBehaviourExtensions
    extension ModelExtensions = new ModelExtensions
    extension WorkflowExtensions = new WorkflowExtensions

    IFileSystemAccess fsa
    IProgressMonitor pm

    override doGenerate(Resource resource, IFileSystemAccess fsa) {
        this.fsa = fsa
        this.pm = null
        generateApp(resource.contents.head as Application)
    }

    def generate(Application it, IFileSystemAccess fsa, IProgressMonitor pm) {
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
        println('Generating basic information')
        new ModuleFile().generate(it, fsa)
        new DependencyInjection().generate(it, fsa)
        new ComposerFile().generate(it, fsa)
        new ZikulaManifest().generate(it, fsa)
        new GitIgnore().generate(it, fsa)
        new TravisFile().generate(it, fsa)
        new PhpUnitXmlDist().generate(it, fsa)
    }

    def private generateModel(Application it) {
        pm?.subTask('Model: Entity classes')
        println('Generating entity classes')
        new Entities().generate(it, fsa)

        pm?.subTask('Model: Repository classes')
        println('Generating repository classes')
        new Repository().generate(it, fsa)

        pm?.subTask('Model: Factory classes')
        println('Generating factory classes')
        new Factory().generate(it, fsa)
    }

    def private generateController(Application it) {
        pm?.subTask('Controller: Application installer')
        println('Generating application installer')
        new Installer().generate(it, fsa)
        pm?.subTask('Controller: Controller classes')
        println('Generating controller classes')
        new ControllerLayer().generate(it, fsa)
        pm?.subTask('Controller: Helper service classes')
        println('Generating helper service classes')
        new HelperServices().generate(it, fsa)
        pm?.subTask('Controller: Action handler classes')
        println('Generating action handler classes')
        new FormHandler().generate(it, fsa)
        pm?.subTask('Controller: Event listeners')
        println('Generating Event listeners')
        new Listeners().generate(it, fsa)
        pm?.subTask('Controller: Service definitions')
        println('Generating service definitions')
        new ServiceDefinitions().generate(it, fsa)
        pm?.subTask('Controller: Custom event definitions')
        println('Generating custom event definitions')
        new Events().generate(it, fsa)
        pm?.subTask('Controller: Bootstrapping')
        println('Generating bootstrapping')
        new Bootstrap().generate(it, fsa)
        pm?.subTask('Controller: Workflows')
        println('Generating workflows')
        new Workflow().generate(it, fsa)
        if (hasUploads) {
            pm?.subTask('Controller: Upload handlers')
            println('Generating upload handlers')
            new Uploads().generate(it, fsa)
        }
        pm?.subTask('Controller: JavaScript files')
        println('Generating JavaScript files')
        if (generateExternalControllerAndFinder) {
            new Finder().generate(it, fsa)
        }
        if (hasEditActions) {
            new EditFunctions().generate(it, fsa)
        }
        new DisplayFunctions().generate(it, fsa)
        if (hasTrees) {
            new TreeFunctions().generate(it, fsa)
        }
        new Validation().generate(it, fsa)
    }

    def private generateView(Application it) {
        pm?.subTask('View: Rendering templates')
        println('Generating view templates')
        new Views().generate(it, fsa)
        pm?.subTask('View: Form templates')
        println('Generating form templates')
        new Forms().generate(it, fsa)
        pm?.subTask('View: Module-specific plugins')
        println('Generating application-specific plugins')
        new Plugins().generate(it, fsa)
        pm?.subTask('View: CSS definitions')
        println('Generating css definitions')
        new Styles().generate(it, fsa)
        pm?.subTask('View: Images')
        println('Generating images')
        new Images().generate(it, fsa)
    }

    def private generateIntegration(Application it) {
        generateIntegrationBlocks
        generateIntegrationContentTypes
        generateIntegrationThirdParty
    }

    def private generateIntegrationBlocks(Application it) {
        val needsModerationBlock = generateModerationBlock && needsApproval
        if (generateListBlock || needsModerationBlock) {
            pm?.subTask('Integration: Blocks')
            println('Generating blocks')
            if (generateListBlock) {
                new BlockList().generate(it, fsa)
            }
            if (needsModerationBlock) {
                new BlockModeration().generate(it, fsa)
            }
        }
    }

    def private generateIntegrationContentTypes(Application it) {
        val needsDetailContentType = generateDetailContentType && hasDisplayActions
        if (generateListContentType || needsDetailContentType) {
            pm?.subTask('Integration: Content types')
            println('Generating content types')
            if (generateListContentType) {
                new ContentTypeList().generate(it, fsa)
            }
            if (needsDetailContentType) {
                new ContentTypeSingle().generate(it, fsa)
            }
        }
    }

    def private generateIntegrationThirdParty(Application it) {
        if (generateNewsletterPlugin) {
            pm?.subTask('Integration: Newsletter plugin')
            println('Generating newsletter plugin')
            new Newsletter().generate(it, fsa)
        }
        if (generateMailzApi) {
            pm?.subTask('Integration: Mailz api')
            println('Generating mailz api')
            new Mailz().generate(it, fsa)
        }
        if (generateMultiHookNeedles) {
            pm?.subTask('Integration: MultiHook needles')
            println('Generating MultiHook needles')
            new MultiHook().generate(it, fsa)
        }
        if (generateTagSupport && hasDisplayActions) {
            pm?.subTask('Integration: Tag support')
            println('Generating tag support')
            new Tag().generate(it, fsa)
        }
    }

    def private generateAdditions(Application it) {
        pm?.subTask('Additions: Translations')
        println('Generating translations')
        new Translations().generate(it, fsa)
        pm?.subTask('Additions: Documentation')
        println('Generating documentation')
        new Docs().generate(it, fsa)

        if (generateTests) {
            pm?.subTask('Additions: Tests')
            println('Generating unit tests')
            new Tests().generate(it, fsa)
        }
    }
}
