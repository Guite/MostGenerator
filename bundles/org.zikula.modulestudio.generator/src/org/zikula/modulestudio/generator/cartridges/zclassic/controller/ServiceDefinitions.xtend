package org.zikula.modulestudio.generator.cartridges.zclassic.controller

import de.guite.modulestudio.metamodel.Application
import de.guite.modulestudio.metamodel.Entity
import de.guite.modulestudio.metamodel.EntityTreeType
import de.guite.modulestudio.metamodel.UploadField
import org.zikula.modulestudio.generator.application.IMostFileSystemAccess
import org.zikula.modulestudio.generator.extensions.ControllerExtensions
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

/**
 * Service definitions in YAML format.
 */
class ServiceDefinitions {

    extension ControllerExtensions = new ControllerExtensions
    extension FormattingExtensions = new FormattingExtensions
    extension ModelBehaviourExtensions = new ModelBehaviourExtensions
    extension ModelExtensions = new ModelExtensions
    extension NamingExtensions = new NamingExtensions
    extension Utils = new Utils

    IMostFileSystemAccess fsa

    def private generateServiceFile(Application it, String fileName, CharSequence content) {
        val definitionFilePath = getResourcesPath + 'config/' + fileName + '.yaml'
        fsa.generateFile(definitionFilePath, content)
    }

    /**
     * Entry point for service definitions.
     * This generates YAML files describing DI configuration.
     */
    def generate(Application it, IMostFileSystemAccess fsa) {
        this.fsa = fsa

        generateServiceFile('services', mainServiceFile)
    }

    def private mainServiceFile(Application it) '''
        services:
            _defaults:
                autowire: true
                autoconfigure: true
                public: false

            «appNamespace»\:
                resource: '../../*'
                exclude: '../../{bootstrap.php,Base/bootstrap.php,Tests,vendor}'

            «appNamespace»\Bundle\MetaData\«name.formatForCodeCapital»BundleMetaData:
                public: true

            «appNamespace»\Helper\:
                resource: '../../Helper/*'
                lazy: true

            «specificServices»
            «IF hasImageFields || !getAllVariables.filter(UploadField).filter[isImageField].empty»

                liip_imagine.cache.signer:
                    class: «appNamespace»\Imagine\Cache\DummySigner
            «ENDIF»

            «repositoryBindings»
    '''

    def private specificServices(Application it) '''
        # public because EntityLifecycleListener accesses this using container
        «appNamespace»\Entity\Factory\EntityFactory:
            public: true

        «IF hasUploads»

            # public because EntityLifecycleListener accesses this using container
            «appNamespace»\Helper\UploadHelper:
                public: true
        «ENDIF»

        «appNamespace»\EventListener\EntityLifecycleListener:
            tags: ['doctrine.event_subscriber']
            calls:
                - [ setContainer, [ '@service_container' ]]
        «IF hasLoggable»

            # public because EntityLifecycleListener accesses this using container
            «appNamespace»\EventListener\LoggableListener:
                public: true
        «ENDIF»

        «appNamespace»\Menu\MenuBuilder:
            tags:
                - { name: knp_menu.menu_builder, method: createItemActionsMenu, alias: «vendorAndName.toFirstLower»MenuItemActions }
                «IF hasIndexActions»
                - { name: knp_menu.menu_builder, method: createViewActionsMenu, alias: «vendorAndName.toFirstLower»MenuViewActions }
                «ENDIF»
        «IF !getAllEntities.filter[hasIpTraceableFields].empty»

            gedmo_doctrine_extensions.listener.ip_traceable:
                class: Gedmo\IpTraceable\IpTraceableListener
                public: false
                calls:
                    - setAnnotationReader: ['@annotation_reader']
                tags:
                    - { name: doctrine.event_subscriber, connection: default }
        «ENDIF»
        «IF hasSluggable»

            stof_doctrine_extensions.listener.sluggable:
                class: '%stof_doctrine_extensions.listener.sluggable.class%'
                calls:
                    - setAnnotationReader: ['@annotation_reader']
                    - setTransliterator: [[«appNamespace»\Helper\SlugTransliterator, 'transliterate']]
                tags:
                    - { name: doctrine.event_subscriber, connection: default }
        «ENDIF»
    '''

    def private repositoryBindings(Application it) '''
        «FOR entity : getAllEntities»
            «entity.repoPath('')»Interface: '@«entity.repoPath('')»'
            «IF entity.categorisable»
                «entity.repoPath('category')»Interface: '@«entity.repoPath('category')»'
            «ENDIF»
            «IF entity.tree == EntityTreeType.CLOSURE»
                «entity.repoPath('closure')»Interface: '@«entity.repoPath('closure')»'
            «ENDIF»
            «IF entity.loggable»
                «entity.repoPath('logEntry')»Interface: '@«entity.repoPath('logEntry')»'
            «ENDIF»
            «IF entity.hasTranslatableFields»
                «entity.repoPath('translation')»Interface: '@«entity.repoPath('translation')»'
            «ENDIF»
        «ENDFOR»«/*FOR relation : getJoinRelations.filter(ManyToManyRelationship)»
            «relation.repoPath»Interface: '@«relation.repoPath»'
        «ENDFOR*/»
    '''

    def private repoPath(Entity it, String extensionName) '''«application.appNamespace»\Repository\«name.formatForCodeCapital»«extensionName.formatForCodeCapital»Repository'''
    //def private repoPath(ManyToManyRelationship it) '''«application.appNamespace»\Repository\«refClass.formatForCodeCapital»Repository'''
}
