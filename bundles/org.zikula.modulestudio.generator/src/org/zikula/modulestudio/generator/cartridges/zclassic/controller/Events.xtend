package org.zikula.modulestudio.generator.cartridges.zclassic.controller

import de.guite.modulestudio.metamodel.Application
import de.guite.modulestudio.metamodel.Entity
import org.zikula.modulestudio.generator.application.IMostFileSystemAccess
import org.zikula.modulestudio.generator.extensions.ControllerExtensions
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.Utils
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper

/**
 * Generates a class for defining custom events.
 */
class Events {

    extension ControllerExtensions = new ControllerExtensions
    extension FormattingExtensions = new FormattingExtensions
    extension ModelExtensions = new ModelExtensions
    extension Utils = new Utils

    Application app
    FileHelper fh

    /**
     * Entry point for event definition class.
     */
    def generate(Application it, IMostFileSystemAccess fsa) {
        app = it
        fh = new FileHelper(it)

        fsa.generateClassPair('Event/ItemActionsMenuPreConfigurationEvent.php', menuEventBaseClass('item', 'pre'), menuEventImpl('item', 'pre'))
        fsa.generateClassPair('Event/ItemActionsMenuPostConfigurationEvent.php', menuEventBaseClass('item', 'post'), menuEventImpl('item', 'post'))
        if (hasViewActions) {
            fsa.generateClassPair('Event/ViewActionsMenuPreConfigurationEvent.php', menuEventBaseClass('view', 'pre'), menuEventImpl('view', 'pre'))
            fsa.generateClassPair('Event/ViewActionsMenuPostConfigurationEvent.php', menuEventBaseClass('view', 'post'), menuEventImpl('view', 'post'))
        }

        val suffixes = #[
            'PostLoad',
            'PrePersist',
            'PostPersist',
            'PreRemove',
            'PostRemove',
            'PreUpdate',
            'PostUpdate'
        ]
        for (entity : getAllEntities) {
            for (suffix : suffixes) {
                fsa.generateClassPair('Event/' + entity.name.formatForCodeCapital + suffix + 'Event.php',
                    entity.filterEventBaseClass(suffix), entity.filterEventImpl(suffix)
                )
            }
        }
    }

    def private menuEventBaseClass(Application it, String actionType, String eventTimeType) '''
        namespace «app.appNamespace»\Event\Base;

        use Knp\Menu\FactoryInterface;
        use Knp\Menu\ItemInterface;

        /**
         * Event base class for extending «actionType» actions menu.
         */
        abstract class Abstract«actionType.toFirstUpper»ActionsMenu«eventTimeType.toFirstUpper»ConfigurationEvent
        {
            public function __construct(
                protected FactoryInterface $factory,
                protected ItemInterface $menu,
                protected array $options = []
            ) {
            }
            «fh.getterMethod(it, 'factory', 'FactoryInterface', false)»
            «fh.getterMethod(it, 'menu', 'ItemInterface', false)»
            «fh.getterMethod(it, 'options', 'array', false)»
        }
    '''

    def private menuEventImpl(Application it, String actionType, String eventTimeType) '''
        namespace «app.appNamespace»\Event;

        use «app.appNamespace»\Event\Base\Abstract«actionType.toFirstUpper»ActionsMenu«eventTimeType.toFirstUpper»ConfigurationEvent;

        /**
         * Event implementation class for extending «actionType» actions menu.
         */
        class «actionType.toFirstUpper»ActionsMenu«eventTimeType.toFirstUpper»ConfigurationEvent extends Abstract«actionType.toFirstUpper»ActionsMenu«eventTimeType.toFirstUpper»ConfigurationEvent
        {
            // feel free to extend the event class here
        }
    '''

    def private filterEventBaseClass(Entity it, String classSuffix) '''
        namespace «app.appNamespace»\Event\Base;

        use «app.appNamespace»\Entity\«name.formatForCodeCapital»Entity;

        /**
         * Event base class for filtering «name.formatForDisplay» processing.
         */
        abstract class Abstract«name.formatForCodeCapital»«classSuffix»Event
        {
            public function __construct(protected «name.formatForCodeCapital»Entity $«name.formatForCode»«IF classSuffix == 'PreUpdate'», protected array $entityChangeSet = []«ENDIF»)
            {
            }
            «fh.getterMethod(it, name.formatForCode, name.formatForCodeCapital + 'Entity', false)»
            «IF classSuffix == 'PreUpdate'»
                «fh.getterAndSetterMethods(it, 'entityChangeSet', 'array', false, '[]', '')»
            «ENDIF»
        }
    '''

    def private filterEventImpl(Entity it, String classSuffix) '''
        namespace «app.appNamespace»\Event;

        use «app.appNamespace»\Event\Base\Abstract«name.formatForCodeCapital»«classSuffix»Event;

        /**
         * Event implementation class for filtering «name.formatForDisplay» processing.
         */
        class «name.formatForCodeCapital»«classSuffix»Event extends Abstract«name.formatForCodeCapital»«classSuffix»Event
        {
            // feel free to extend the event class here
        }
    '''
}
