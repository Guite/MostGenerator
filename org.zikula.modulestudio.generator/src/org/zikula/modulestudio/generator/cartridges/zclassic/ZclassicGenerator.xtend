package org.zikula.modulestudio.generator.cartridges.zclassic

import com.google.inject.Inject
import de.guite.modulestudio.metamodel.modulestudio.Application
import org.eclipse.core.runtime.IProgressMonitor
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.xtext.generator.IFileSystemAccess
import org.eclipse.xtext.generator.IGenerator
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.ControllerLayer
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.FormHandler
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.Installer
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.Listeners
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.ServiceDefinitions
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.Uploads
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.Workflow
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.additions.Newsletter
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.additions.Tag
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.apis.Account
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.apis.BlockList
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.apis.BlockModeration
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.apis.Cache
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.apis.Category
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.apis.ContentTypeList
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.apis.ContentTypeSingle
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.apis.Mailz
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.apis.Search
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.apis.Selection
import org.zikula.modulestudio.generator.cartridges.zclassic.models.Entities
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
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.VersionFile
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

    @Inject extension ControllerExtensions = new ControllerExtensions
    @Inject extension GeneratorSettingsExtensions = new GeneratorSettingsExtensions
    @Inject extension ModelExtensions = new ModelExtensions
    @Inject extension ModelBehaviourExtensions = new ModelBehaviourExtensions
    @Inject extension WorkflowExtensions = new WorkflowExtensions

    override doGenerate(Resource resource, IFileSystemAccess fsa) {
        generate(resource.contents.head as Application, fsa)
    }

    def generate(Application it, IFileSystemAccess fsa) {
        generate(fsa, null)
    }

    def generate(Application it, IFileSystemAccess fsa, IProgressMonitor pm) {
        pm?.subTask('Basic information')
        println('Generating basic information')
        new ModuleFile().generate(it, fsa)
        new VersionFile().generate(it, fsa)
        new DependencyInjection().generate(it, fsa)
        new ComposerFile().generate(it, fsa)
        new GitIgnore().generate(it, fsa)
        new TravisFile().generate(it, fsa)
        new PhpUnitXmlDist().generate(it, fsa)

        pm?.subTask('Model: Entity classes')
        println('Generating entity classes')
        new Entities().generate(it, fsa)

        pm?.subTask('Model: Repository classes')
        println('Generating repository classes')
        new Repository().generate(it, fsa)

        pm?.subTask('Controller: Application installer')
        println('Generating application installer')
        new Installer().generate(it, fsa)
        pm?.subTask('Controller: Controller classes')
        println('Generating controller classes')
        new ControllerLayer().generate(it, fsa)
        pm?.subTask('Controller: Action handler classes')
        println('Generating action handler classes')
        new FormHandler().generate(it, fsa)
        pm?.subTask('Controller: Persistent event handlers')
        println('Generating persistent event handlers')
        new Listeners().generate(it, fsa)
        pm?.subTask('Controller: Service definitions')
        println('Generating service definitions')
        new ServiceDefinitions().generate(it, fsa)
        pm?.subTask('Controller: Bootstrapping')
        println('Generating bootstrapping')
        new Bootstrap().generate(it, fsa)
        pm?.subTask('Controller: Workflows')
        println('Generating workflows')
        new Workflow().generate(it, fsa)

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

        val needsModerationBlock = generateModerationBlock && needsApproval
        if (generateListBlock || needsModerationBlock) {
            pm?.subTask('Additions: Blocks')
            println('Generating blocks')
            if (generateListBlock) {
                new BlockList().generate(it, fsa)
            }
            if (needsModerationBlock) {
                new BlockModeration().generate(it, fsa)
            }
        }
        val needsDetailContentType = generateDetailContentType && hasUserController && getMainUserController.hasActions('display')
        if (generateListContentType || needsDetailContentType) {
            pm?.subTask('Additions: Content types')
            println('Generating content types')
            if (generateListContentType) {
                new ContentTypeList().generate(it, fsa)
            }
            if (needsDetailContentType) {
                new ContentTypeSingle().generate(it, fsa)
            }
        }
        if (generateAccountApi) {
            pm?.subTask('Additions: Account api')
            println('Generating account api')
            new Account().generate(it, fsa)
        }

        pm?.subTask('Additions: Cache api')
        println('Generating cache api')
        new Cache().generate(it, fsa)

        pm?.subTask('Additions: Selection api')
        println('Generating selection api')
        new Selection().generate(it, fsa)

        if (hasCategorisableEntities) {
            pm?.subTask('Additions: Category api')
            println('Generating category api')
            new Category().generate(it, fsa)
        }
        if (generateSearchApi && !getAllEntities.filter[hasAbstractStringFieldsEntity].empty) {
            pm?.subTask('Additions: Search api')
            println('Generating search api')
            new Search().generate(it, fsa)
        }
        if (hasUploads) {
            pm?.subTask('Additions: Upload handlers')
            println('Generating upload handlers')
            new Uploads().generate(it, fsa)
        }
        if (generateNewsletterPlugin) {
            pm?.subTask('Additions: Newsletter plugin')
            println('Generating newsletter plugin')
            new Newsletter().generate(it, fsa)
        }
        if (generateMailzApi) {
            pm?.subTask('Additions: Mailz api')
            println('Generating mailz api')
            new Mailz().generate(it, fsa)
        }
        if (generateTagSupport &&
            ((hasUserController && getMainUserController.hasActions('display'))
            || (!getAllAdminControllers.empty && getAllAdminControllers.head.hasActions('display')))) {
            pm?.subTask('Additions: Tag support')
            println('Generating tag support')
            new Tag().generate(it, fsa)
        }

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
