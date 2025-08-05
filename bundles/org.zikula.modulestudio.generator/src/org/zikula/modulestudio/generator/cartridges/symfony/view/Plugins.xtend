package org.zikula.modulestudio.generator.cartridges.symfony.view

import de.guite.modulestudio.metamodel.Application
import de.guite.modulestudio.metamodel.StringField
import de.guite.modulestudio.metamodel.StringRole
import org.zikula.modulestudio.generator.application.IMostFileSystemAccess
import org.zikula.modulestudio.generator.application.ImportList
import org.zikula.modulestudio.generator.cartridges.symfony.view.plugin.FormatGeoData
import org.zikula.modulestudio.generator.cartridges.symfony.view.plugin.GetFileSize
import org.zikula.modulestudio.generator.cartridges.symfony.view.plugin.GetFormattedDateInterval
import org.zikula.modulestudio.generator.cartridges.symfony.view.plugin.GetFormattedEntityTitle
import org.zikula.modulestudio.generator.cartridges.symfony.view.plugin.GetListEntry
import org.zikula.modulestudio.generator.cartridges.symfony.view.plugin.GetLogDescription
import org.zikula.modulestudio.generator.cartridges.symfony.view.plugin.GetRelativePath
import org.zikula.modulestudio.generator.cartridges.symfony.view.plugin.ObjectState
import org.zikula.modulestudio.generator.cartridges.symfony.view.plugin.TreeData
import org.zikula.modulestudio.generator.cartridges.symfony.view.plugin.TreeSelection
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class Plugins {

    extension ModelExtensions = new ModelExtensions
    extension ModelBehaviourExtensions = new ModelBehaviourExtensions
    extension Utils = new Utils

    def generate(Application it, IMostFileSystemAccess fsa) {
        'Generating Twig extension class'.printIfNotTesting(fsa)
        val twigFolder = 'Twig'
        fsa.generateClassPair(twigFolder + '/TwigExtension.php', twigExtensionBaseImpl, twigExtensionImpl)
    }

    def private collectExtensionBaseImports(Application it) {
        val imports = new ImportList
        imports.addAll(#[
            'Twig\\Attribute\\AsTwigFilter',
            'Twig\\Attribute\\AsTwigFunction'
        ])
        if (hasLoggable) {
            imports.add('Twig\\Attribute\\AsTwigTest')
        }
        imports.addAll(#[
            'Symfony\\Contracts\\Translation\\TranslatorInterface',
            appNamespace + '\\Entity\\EntityInterface',
            appNamespace + '\\Helper\\EntityDisplayHelper',
            appNamespace + '\\Helper\\WorkflowHelper'
        ])
        if (!entities.filter[!fields.filter(StringField).filter[role == StringRole.DATE_INTERVAL].empty].empty) {
            imports.add('DateInterval')
        }
        if (hasLoggable) {
            imports.addAll(#[
                'Gedmo\\Loggable\\Entity\\MappedSuperclass\\AbstractLogEntry',
                appNamespace + '\\Helper\\LoggableHelper'
            ])
        }
        if (hasTrees) {
            imports.addAll(#[
                'Knp\\Menu\\Matcher\\Matcher',
                'Knp\\Menu\\Renderer\\ListRenderer',
                'Symfony\\Component\\Routing\\RouterInterface',
                appNamespace + '\\Entity\\Factory\\EntityFactory',
                appNamespace + '\\Menu\\MenuBuilder'
            ])
        }
        if (hasListFields) {
            imports.add(appNamespace + '\\Helper\\ListEntriesHelper')
        }
        if (hasUploads) {
            imports.add('Symfony\\Component\\DependencyInjection\\Attribute\\Autowire')
        }
        imports
    }

    def private twigExtensionBaseImpl(Application it) '''
        namespace «appNamespace»\Twig\Base;

        «collectExtensionBaseImports.print»

        /**
         * Twig extension base class.
         */
        abstract class AbstractTwigExtension extends AbstractExtension
        {
            «twigExtensionBody»
        }
    '''

    def private twigExtensionBody(Application it) '''
        public function __construct(
            protected readonly TranslatorInterface $translator«IF hasTrees»,
            protected readonly RouterInterface $router«ENDIF»,
            «IF hasTrees»
                protected readonly EntityFactory $entityFactory,
            «ENDIF»
            protected readonly EntityDisplayHelper $entityDisplayHelper,
            protected readonly WorkflowHelper $workflowHelper«IF hasListFields»,
            protected readonly ListEntriesHelper $listHelper«ENDIF»«IF hasLoggable»,
            protected readonly LoggableHelper $loggableHelper«ENDIF»«IF hasTrees»,
            protected readonly MenuBuilder $menuBuilder«ENDIF»«IF hasUploads»,
            #[Autowire(param: 'kernel.project_dir')]
            protected readonly string $projectDir«ENDIF»
        ) {
        }

        «extensionMethods»
        «IF hasLoggable»

            #[AsTwigTest('«appName.toLowerCase»_instanceOf')]
            public function testInstanceOf($var, $instance)
            {
                return $var instanceof $instance;
            }
        «ENDIF»
    '''

    def private twigExtensionImpl(Application it) '''
        namespace «appNamespace»\Twig;

        use «appNamespace»\Twig\Base\AbstractTwigExtension;

        /**
         * Twig extension implementation class.
         */
        class TwigExtension extends AbstractTwigExtension
        {
            // feel free to add your own Twig extension methods here
        }
    '''

    def private extensionMethods(Application it) {
        val result = newArrayList
        result += new ObjectState().generate(it)
        if (hasUploads) {
            result += new GetFileSize().generate(it)
            result += new GetRelativePath().generate(it)
        }
        if (hasListFields) {
            result += new GetListEntry().generate(it)
        }
        if (hasGeographical) {
            result += new FormatGeoData().generate(it)
        }
        if (hasTrees) {
            result += new TreeData().generate(it)
            result += new TreeSelection().generate(it)
        }
        if (!entities.filter[!fields.filter(StringField).filter[role == StringRole.DATE_INTERVAL].empty].empty) {
            result += new GetFormattedDateInterval().generate(it)
        }
        result += new GetFormattedEntityTitle().generate(it)
        if (hasLoggable) {
            result += new GetLogDescription().generate(it)
        }

        result.join("\n")
    }
}
