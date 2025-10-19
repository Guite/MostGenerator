package org.zikula.modulestudio.generator.cartridges.symfony.controller.bundle

import de.guite.modulestudio.metamodel.Application
import de.guite.modulestudio.metamodel.Entity
import org.zikula.modulestudio.generator.application.IMostFileSystemAccess
import org.zikula.modulestudio.generator.extensions.ControllerExtensions
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.Utils

/**
 * Service definitions in YAML format.
 */
class ServiceDefinitions {

    extension ControllerExtensions = new ControllerExtensions
    extension FormattingExtensions = new FormattingExtensions
    extension ModelBehaviourExtensions = new ModelBehaviourExtensions
    extension ModelExtensions = new ModelExtensions
    extension Utils = new Utils

    /**
     * Entry point for service definitions.
     * This generates YAML files describing DI configuration.
     */
    def generate(Application it, IMostFileSystemAccess fsa) {
        val definitionFilePath = 'config/services.yaml'
        fsa.generateFile(definitionFilePath, serviceFile)
    }

    def private serviceFile(Application it) '''
        services:
            _defaults:
                autowire: true
                autoconfigure: true
                public: false

            «appNamespace»\:
                resource: '../src/*'
            «IF hasUploads»

                «appNamespace»\Bundle\Initializer\«appName»Initializer:
                    public: true
            «ENDIF»

            «appNamespace»\Bundle\MetaData\«appName»MetaData:
                public: true

            «appNamespace»\Helper\:
                resource: '../src/Helper/*'
                lazy: true

            «specificServices»

            «repositoryBindings»
    '''

    def private specificServices(Application it) '''
        «appNamespace»\Menu\MenuBuilder:
            tags:
                - { name: knp_menu.menu_builder, method: createItemActionsMenu, alias: «vendorAndName.toFirstLower»MenuItemActions }
                «IF hasIndexActions»
                - { name: knp_menu.menu_builder, method: createViewActionsMenu, alias: «vendorAndName.toFirstLower»MenuViewActions }
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
        «FOR entity : entities»
            «entity.repoPath('')»Interface: '@«entity.repoPath('')»'
            «IF entity.loggable»
                «entity.repoPath('logEntry')»Interface: '@«entity.repoPath('logEntry')»'
            «ENDIF»
            «IF entity.hasTranslatableFields»
                «entity.repoPath('translation')»Interface: '@«entity.repoPath('translation')»'
            «ENDIF»
        «ENDFOR»«/*FOR relation : relations.filter(ManyToManyRelationship)»
            «relation.repoPath»Interface: '@«relation.repoPath»'
        «ENDFOR*/»
    '''

    def private repoPath(Entity it, String extensionName) '''«application.appNamespace»\Repository\«name.formatForCodeCapital»«extensionName.formatForCodeCapital»Repository'''
    //def private repoPath(ManyToManyRelationship it) '''«application.appNamespace»\Repository\«refClass.formatForCodeCapital»Repository'''
}
