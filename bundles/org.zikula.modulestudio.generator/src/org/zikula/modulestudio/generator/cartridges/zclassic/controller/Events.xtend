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

        fsa.generateClassPair(name.formatForCodeCapital + 'Events.php', eventDefinitionsBaseClass, eventDefinitionsImpl)

        fsa.generateClassPair('Event/ConfigureItemActionsMenuEvent.php', menuEventBaseClass('item'), menuEventImpl('item'))
        if (hasViewActions) {
            fsa.generateClassPair('Event/ConfigureViewActionsMenuEvent.php', menuEventBaseClass('view'), menuEventImpl('view'))
        }

        for (entity : getAllEntities) {
            fsa.generateClassPair('Event/Filter' + entity.name.formatForCodeCapital + 'Event.php',
                filterEventBaseClass(entity), filterEventImpl(entity)
            )
        }
    }

    def private eventDefinitionsBaseClass(Application it) '''
        namespace «appNamespace»\Base;

        use «app.appNamespace»\Listener\EntityLifecycleListener;
        use «app.appNamespace»\Menu\MenuBuilder;

        /**
         * Events definition base class.
         */
        abstract class Abstract«name.formatForCodeCapital»Events
        {
            «menuEventDefinitions»
            «FOR entity : getAllEntities»
                «entity.eventDefinitions»
            «ENDFOR»
        }
    '''

    def private menuEventDefinitions(Application it) '''
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

    def private eventDefinitions(Entity it) '''
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

    def private eventDefinitionsImpl(Application it) '''
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

    def private menuEventBaseClass(Application it, String actionType) '''
        namespace «app.appNamespace»\Event\Base;

        use Knp\Menu\FactoryInterface;
        use Knp\Menu\ItemInterface;
        «IF targets('3.0')»
            use Symfony\Contracts\EventDispatcher\Event;
        «ELSE»
            use Symfony\Component\EventDispatcher\Event;
        «ENDIF»

        /**
         * Event base class for extending «actionType» actions menu.
         */
        class AbstractConfigure«actionType.toFirstUpper»ActionsMenuEvent extends Event
        {
            /**
             * @var FactoryInterface.
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

            /**
             * @return FactoryInterface
             */
            public function getFactory()«IF targets('3.0')»: FactoryInterface«ENDIF»
            {
                return $this->factory;
            }

            /**
             * @return ItemInterface
             */
            public function getMenu()«IF targets('3.0')»: ItemInterface«ENDIF»
            {
                return $this->menu;
            }

            /**
             * @return array
             */
            public function getOptions()«IF targets('3.0')»: array«ENDIF»
            {
                return $this->options;
            }
        }
    '''

    def private menuEventImpl(Application it, String actionType) '''
        namespace «app.appNamespace»\Event;

        use «app.appNamespace»\Event\Base\AbstractConfigure«actionType.toFirstUpper»ActionsMenuEvent;

        /**
         * Event implementation class for extending «actionType» actions menu.
         */
        class Configure«actionType.toFirstUpper»ActionsMenuEvent extends AbstractConfigure«actionType.toFirstUpper»ActionsMenuEvent
        {
            // feel free to extend the event class here
        }
    '''

    def private filterEventBaseClass(Entity it) '''
        namespace «app.appNamespace»\Event\Base;

        «IF app.targets('3.0')»
            use Symfony\Contracts\EventDispatcher\Event;
        «ELSE»
            use Symfony\Component\EventDispatcher\Event;
        «ENDIF»
        use «app.appNamespace»\Entity\«name.formatForCodeCapital»Entity;

        /**
         * Event base class for filtering «name.formatForDisplay» processing.
         */
        class AbstractFilter«name.formatForCodeCapital»Event extends Event
        {
            /**
             * @var «name.formatForCodeCapital»Entity Reference to treated entity instance.
             */
            protected $«name.formatForCode»;

            /**
             * @var array Entity change set for preUpdate events.
             */
            protected $entityChangeSet = [];

            public function __construct(«name.formatForCodeCapital»Entity $«name.formatForCode», array $entityChangeSet = [])
            {
                $this->«name.formatForCode» = $«name.formatForCode»;
                $this->entityChangeSet = $entityChangeSet;
            }

            /**
             * @return «name.formatForCodeCapital»Entity
             */
            public function get«name.formatForCodeCapital»()«IF app.targets('3.0')»: «name.formatForCodeCapital»Entity«ENDIF»
            {
                return $this->«name.formatForCode»;
            }

            /**
             * @return array Entity change set
             */
            public function getEntityChangeSet()«IF app.targets('3.0')»: array«ENDIF»
            {
                return $this->entityChangeSet;
            }
        }
    '''

    def private filterEventImpl(Entity it) '''
        namespace «app.appNamespace»\Event;

        use «app.appNamespace»\Event\Base\AbstractFilter«name.formatForCodeCapital»Event;

        /**
         * Event implementation class for filtering «name.formatForDisplay» processing.
         */
        class Filter«name.formatForCodeCapital»Event extends AbstractFilter«name.formatForCodeCapital»Event
        {
            // feel free to extend the event class here
        }
    '''
}
