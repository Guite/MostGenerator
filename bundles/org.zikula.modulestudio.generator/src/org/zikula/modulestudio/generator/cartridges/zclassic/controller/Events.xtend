package org.zikula.modulestudio.generator.cartridges.zclassic.controller

import de.guite.modulestudio.metamodel.Application
import de.guite.modulestudio.metamodel.Entity
import org.zikula.modulestudio.generator.application.IMostFileSystemAccess
import org.zikula.modulestudio.generator.extensions.ControllerExtensions
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.Utils

/**
 * Generates a class for defining custom events.
 */
class Events {

    extension ControllerExtensions = new ControllerExtensions
    extension FormattingExtensions = new FormattingExtensions
    extension ModelExtensions = new ModelExtensions
    extension Utils = new Utils

    Application app

    /**
     * Entry point for event definition class.
     */
    def generate(Application it, IMostFileSystemAccess fsa) {
        app = it

        if (!app.targets('3.0')) {
            fsa.generateClassPair(name.formatForCodeCapital + 'Events.php', eventDefinitionsBaseClassLegacy, eventDefinitionsImplLegacy)
        }

        if (app.targets('3.0')) {
            fsa.generateClassPair('Event/ItemActionsMenuPreConfigurationEvent.php', menuEventBaseClass('item', 'pre'), menuEventImpl('item', 'pre'))
            fsa.generateClassPair('Event/ItemActionsMenuPostConfigurationEvent.php', menuEventBaseClass('item', 'post'), menuEventImpl('item', 'post'))
            if (hasViewActions) {
                fsa.generateClassPair('Event/ViewActionsMenuPreConfigurationEvent.php', menuEventBaseClass('view', 'pre'), menuEventImpl('view', 'pre'))
                fsa.generateClassPair('Event/ViewActionsMenuPostConfigurationEvent.php', menuEventBaseClass('view', 'post'), menuEventImpl('view', 'post'))
            }
        } else {
            fsa.generateClassPair('Event/ConfigureItemActionsMenuEvent.php', menuEventBaseClass('item', ''), menuEventImpl('item', ''))
            if (hasViewActions) {
                fsa.generateClassPair('Event/ConfigureViewActionsMenuEvent.php', menuEventBaseClass('view', ''), menuEventImpl('view', ''))
            }
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
            if (targets('3.0')) {
                for (suffix : suffixes) {
                    fsa.generateClassPair('Event/' + entity.name.formatForCodeCapital + suffix + 'Event.php',
                        entity.filterEventBaseClass(suffix), entity.filterEventImpl(suffix)
                    )
                }
            } else {
                fsa.generateClassPair('Event/Filter' + entity.name.formatForCodeCapital + 'Event.php',
                    entity.filterEventBaseClass(''), entity.filterEventImpl('')
                )
            }
        }
    }

    def private eventDefinitionsBaseClassLegacy(Application it) '''
        namespace «appNamespace»\Base;

        use «app.appNamespace»\Listener\EntityLifecycleListener;
        use «app.appNamespace»\Menu\MenuBuilder;

        /**
         * Events definition base class.
         */
        abstract class Abstract«name.formatForCodeCapital»Events
        {
            «IF !app.targets('3.0')»
                «menuEventDefinitionsLegacy»
            «ENDIF»
            «FOR entity : getAllEntities»
                «entity.eventDefinitionsLegacy»
            «ENDFOR»
        }
    '''

    def private menuEventDefinitionsLegacy(Application it) '''
        /**
         * The «appName.formatForDB».itemactionsmenu_pre_configure event is thrown before the item actions
         * menu is built in the menu builder.
         *
         * The event listener receives an
         * «app.appNamespace»\Event\ConfigureItemActionsMenuEvent instance.
         *
         * @see MenuBuilder::createItemActionsMenu()
         * @var string
         */
        «IF targets('3.0')»public «ENDIF»const MENU_ITEMACTIONS_PRE_CONFIGURE = '«appName.formatForDB».itemactionsmenu_pre_configure';

        /**
         * The «appName.formatForDB».itemactionsmenu_post_configure event is thrown after the item actions
         * menu has been built in the menu builder.
         *
         * The event listener receives an
         * «app.appNamespace»\Event\ConfigureItemActionsMenuEvent instance.
         *
         * @see MenuBuilder::createItemActionsMenu()
         * @var string
         */
        «IF targets('3.0')»public «ENDIF»const MENU_ITEMACTIONS_POST_CONFIGURE = '«appName.formatForDB».itemactionsmenu_post_configure';
        «IF hasViewActions»

            /**
             * The «appName.formatForDB».viewactionsmenu_pre_configure event is thrown before the view actions
             * menu is built in the menu builder.
             *
             * The event listener receives an
             * «app.appNamespace»\Event\ConfigureViewActionsMenuEvent instance.
             *
             * @see MenuBuilder::createViewActionsMenu()
             * @var string
             */
            «IF targets('3.0')»public «ENDIF»const MENU_VIEWACTIONS_PRE_CONFIGURE = '«appName.formatForDB».viewactionsmenu_pre_configure';

            /**
             * The «appName.formatForDB».viewactionsmenu_post_configure event is thrown after the view actions
             * menu has been built in the menu builder.
             *
             * The event listener receives an
             * «app.appNamespace»\Event\ConfigureViewActionsMenuEvent instance.
             *
             * @see MenuBuilder::createViewActionsMenu()
             * @var string
             */
            «IF targets('3.0')»public «ENDIF»const MENU_VIEWACTIONS_POST_CONFIGURE = '«appName.formatForDB».viewactionsmenu_post_configure';
        «ENDIF»
    '''

    def private eventDefinitionsLegacy(Entity it) '''
        «val constPrefix = name.formatForDB.toUpperCase»
        «val entityEventPrefix = app.appName.formatForDB + '.' + name.formatForDB»

        /**
         * The «entityEventPrefix»_post_load event is thrown when «nameMultiple.formatForDisplay»
         * are loaded from the database.
         *
         * The event listener receives an
         * «app.appNamespace»\Event\Filter«name.formatForCodeCapital»Event instance.
         *
         * @see EntityLifecycleListener::postLoad()
         * @var string
         */
        «IF app.targets('3.0')»public «ENDIF»const «constPrefix»_POST_LOAD = '«entityEventPrefix»_post_load';

        /**
         * The «entityEventPrefix»_pre_persist event is thrown before a new «name.formatForDisplay»
         * is created in the system.
         *
         * The event listener receives an
         * «app.appNamespace»\Event\Filter«name.formatForCodeCapital»Event instance.
         *
         * @see EntityLifecycleListener::prePersist()
         * @var string
         */
        «IF app.targets('3.0')»public «ENDIF»const «constPrefix»_PRE_PERSIST = '«entityEventPrefix»_pre_persist';

        /**
         * The «entityEventPrefix»_post_persist event is thrown after a new «name.formatForDisplay»
         * has been created in the system.
         *
         * The event listener receives an
         * «app.appNamespace»\Event\Filter«name.formatForCodeCapital»Event instance.
         *
         * @see EntityLifecycleListener::postPersist()
         * @var string
         */
        «IF app.targets('3.0')»public «ENDIF»const «constPrefix»_POST_PERSIST = '«entityEventPrefix»_post_persist';

        /**
         * The «entityEventPrefix»_pre_remove event is thrown before an existing «name.formatForDisplay»
         * is removed from the system.
         *
         * The event listener receives an
         * «app.appNamespace»\Event\Filter«name.formatForCodeCapital»Event instance.
         *
         * @see EntityLifecycleListener::preRemove()
         * @var string
         */
        «IF app.targets('3.0')»public «ENDIF»const «constPrefix»_PRE_REMOVE = '«entityEventPrefix»_pre_remove';

        /**
         * The «entityEventPrefix»_post_remove event is thrown after an existing «name.formatForDisplay»
         * has been removed from the system.
         *
         * The event listener receives an
         * «app.appNamespace»\Event\Filter«name.formatForCodeCapital»Event instance.
         *
         * @see EntityLifecycleListener::postRemove()
         * @var string
         */
        «IF app.targets('3.0')»public «ENDIF»const «constPrefix»_POST_REMOVE = '«entityEventPrefix»_post_remove';

        /**
         * The «entityEventPrefix»_pre_update event is thrown before an existing «name.formatForDisplay»
         * is updated in the system.
         *
         * The event listener receives an
         * «app.appNamespace»\Event\Filter«name.formatForCodeCapital»Event instance.
         *
         * @see EntityLifecycleListener::preUpdate()
         * @var string
         */
        «IF app.targets('3.0')»public «ENDIF»const «constPrefix»_PRE_UPDATE = '«entityEventPrefix»_pre_update';

        /**
         * The «entityEventPrefix»_post_update event is thrown after an existing new «name.formatForDisplay»
         * has been updated in the system.
         *
         * The event listener receives an
         * «app.appNamespace»\Event\Filter«name.formatForCodeCapital»Event instance.
         *
         * @see EntityLifecycleListener::postUpdate()
         * @var string
         */
        «IF app.targets('3.0')»public «ENDIF»const «constPrefix»_POST_UPDATE = '«entityEventPrefix»_post_update';
    '''

    def private eventDefinitionsImplLegacy(Application it) '''
        namespace «appNamespace»;

        use «appNamespace»\Base\Abstract«name.formatForCodeCapital»Events;

        /**
         * Events definition implementation class.
         */
        class «name.formatForCodeCapital»Events extends Abstract«name.formatForCodeCapital»Events
        {
            // feel free to extend the events definition here
        }
    '''

    def private menuEventBaseClass(Application it, String actionType, String eventTimeType) '''
        namespace «app.appNamespace»\Event\Base;

        use Knp\Menu\FactoryInterface;
        use Knp\Menu\ItemInterface;
        «IF !targets('3.0')»
            use Symfony\Component\EventDispatcher\Event;
        «ENDIF»

        /**
         * Event base class for extending «actionType» actions menu.
         */
        «IF app.targets('3.0')»
            abstract class Abstract«actionType.toFirstUpper»ActionsMenu«eventTimeType.toFirstUpper»ConfigurationEvent
        «ELSE»
            class AbstractConfigure«actionType.toFirstUpper»ActionsMenuEvent extends Event
        «ENDIF»
        {
            /**
             * @var FactoryInterface
             */
            protected $factory;

            /**
             * @var ItemInterface
             */
            protected $menu;

            /**
             * @var array
             */
            protected $options;

            public function __construct(
                FactoryInterface $factory,
                ItemInterface $menu,
                array $options = []
            ) {
                $this->factory = $factory;
                $this->menu = $menu;
                $this->options = $options;
            }

            «IF !targets('3.0')»
            /**
             * @return FactoryInterface
             */
            «ENDIF»
            public function getFactory()«IF targets('3.0')»: FactoryInterface«ENDIF»
            {
                return $this->factory;
            }

            «IF !targets('3.0')»
            /**
             * @return ItemInterface
             */
            «ENDIF»
            public function getMenu()«IF targets('3.0')»: ItemInterface«ENDIF»
            {
                return $this->menu;
            }

            «IF !targets('3.0')»
            /**
             * @return array
             */
            «ENDIF»
            public function getOptions()«IF targets('3.0')»: array«ENDIF»
            {
                return $this->options;
            }
        }
    '''

    def private menuEventImpl(Application it, String actionType, String eventTimeType) '''
        namespace «app.appNamespace»\Event;

        use «app.appNamespace»\Event\Base\«IF app.targets('3.0')»Abstract«actionType.toFirstUpper»ActionsMenu«eventTimeType.toFirstUpper»ConfigurationEvent«ELSE»AbstractConfigure«actionType.toFirstUpper»ActionsMenuEvent«ENDIF»;

        /**
         * Event implementation class for extending «actionType» actions menu.
         */
        «IF app.targets('3.0')»
            class «actionType.toFirstUpper»ActionsMenu«eventTimeType.toFirstUpper»ConfigurationEvent extends Abstract«actionType.toFirstUpper»ActionsMenu«eventTimeType.toFirstUpper»ConfigurationEvent
        «ELSE»
            class Configure«actionType.toFirstUpper»ActionsMenuEvent extends AbstractConfigure«actionType.toFirstUpper»ActionsMenuEvent
        «ENDIF»
        {
            // feel free to extend the event class here
        }
    '''

    def private filterEventBaseClass(Entity it, String classSuffix) '''
        namespace «app.appNamespace»\Event\Base;

        use «app.appNamespace»\Entity\«name.formatForCodeCapital»Entity;
        «IF !application.targets('3.0')»
            use Symfony\Component\EventDispatcher\Event;
        «ENDIF»

        /**
         * Event base class for filtering «name.formatForDisplay» processing.
         */
        «IF application.targets('3.0')»abstract «ENDIF»class Abstract«IF !app.targets('3.0')»Filter«ENDIF»«name.formatForCodeCapital»«classSuffix»Event«IF !application.targets('3.0')» extends Event«ENDIF»
        {
            /**
             * @var «name.formatForCodeCapital»Entity Reference to treated entity instance
             */
            protected $«name.formatForCode»;
            «IF !app.targets('3.0') || classSuffix == 'PreUpdate'»

                /**
                 * @var array Entity change set for preUpdate events
                 */
                protected $entityChangeSet = [];
            «ENDIF»

            public function __construct(«name.formatForCodeCapital»Entity $«name.formatForCode»«IF !app.targets('3.0') || classSuffix == 'PreUpdate'», array $entityChangeSet = []«ENDIF»)
            {
                $this->«name.formatForCode» = $«name.formatForCode»;
                «IF !app.targets('3.0') || classSuffix == 'PreUpdate'»
                    $this->entityChangeSet = $entityChangeSet;
                «ENDIF»
            }

            public function get«name.formatForCodeCapital»()«IF app.targets('3.0')»: «name.formatForCodeCapital»Entity«ENDIF»
            {
                return $this->«name.formatForCode»;
            }
            «IF !app.targets('3.0') || classSuffix == 'PreUpdate'»

                /**
                 * @return array Entity change set
                 */
                public function getEntityChangeSet()«IF app.targets('3.0')»: array«ENDIF»
                {
                    return $this->entityChangeSet;
                }

                /**
                 * @param array $changeSet Entity change set
                 */
                public function setEntityChangeSet(array $changeSet = [])«IF app.targets('3.0')»: void«ENDIF»
                {
                    $this->entityChangeSet = $changeSet;
                }
            «ENDIF»
        }
    '''

    def private filterEventImpl(Entity it, String classSuffix) '''
        namespace «app.appNamespace»\Event;

        use «app.appNamespace»\Event\Base\Abstract«IF !app.targets('3.0')»Filter«ENDIF»«name.formatForCodeCapital»«classSuffix»Event;

        /**
         * Event implementation class for filtering «name.formatForDisplay» processing.
         */
        class «IF !app.targets('3.0')»Filter«ENDIF»«name.formatForCodeCapital»«classSuffix»Event extends Abstract«IF !app.targets('3.0')»Filter«ENDIF»«name.formatForCodeCapital»«classSuffix»Event
        {
            // feel free to extend the event class here
        }
    '''
}
