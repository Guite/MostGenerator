package org.zikula.modulestudio.generator.cartridges.zclassic.controller

import de.guite.modulestudio.metamodel.Application
import de.guite.modulestudio.metamodel.Entity
import org.zikula.modulestudio.generator.application.IMostFileSystemAccess
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.Utils

/**
 * Generates a class for defining custom events.
 */
class Events {

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

        fsa.generateClassPair('Event/ConfigureItemActionsMenuEvent.php', menuEventBaseClass, menuEventImpl)

        for (entity : getAllEntities) {
            fsa.generateClassPair('Event/Filter' + entity.name.formatForCodeCapital + 'Event.php',
                filterEventBaseClass(entity), filterEventImpl(entity)
            )
        }
    }

    def private eventDefinitionsBaseClass(Application it) '''
        namespace «appNamespace»\Base;

        use «app.appNamespace»\Listener\EntityLifecycleListener;

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
         * @see «app.appNamespace»\Menu\MenuBuilder::createItemActionsMenu()
         * @var string
         */
        const MENU_ITEMACTIONS_PRE_CONFIGURE = '«appName.formatForDB».itemactionsmenu_pre_configure';

        /**
         * The «appName.formatForDB».itemactionsmenu_post_configure event is thrown after the item actions
         * menu has been built in the menu builder.
         *
         * The event listener receives an
         * «app.appNamespace»\Event\ConfigureItemActionsMenuEvent instance.
         *
         * @see «app.appNamespace»\Menu\MenuBuilder::createItemActionsMenu()
         * @var string
         */
        const MENU_ITEMACTIONS_POST_CONFIGURE = '«appName.formatForDB».itemactionsmenu_post_configure';
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
        const «constPrefix»_POST_LOAD = '«entityEventPrefix»_post_load';

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
        const «constPrefix»_PRE_PERSIST = '«entityEventPrefix»_pre_persist';

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
        const «constPrefix»_POST_PERSIST = '«entityEventPrefix»_post_persist';

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
        const «constPrefix»_PRE_REMOVE = '«entityEventPrefix»_pre_remove';

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
        const «constPrefix»_POST_REMOVE = '«entityEventPrefix»_post_remove';

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
        const «constPrefix»_PRE_UPDATE = '«entityEventPrefix»_pre_update';

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
        const «constPrefix»_POST_UPDATE = '«entityEventPrefix»_post_update';

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

    def private menuEventBaseClass(Application it) '''
        namespace «app.appNamespace»\Event\Base;

        use Knp\Menu\FactoryInterface;
        use Knp\Menu\ItemInterface;
        use Symfony\Component\EventDispatcher\Event;

        /**
         * Event base class for extending item actions menu.
         */
        class AbstractConfigureItemActionsMenuEvent extends Event
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

            /**
             * ConfigureItemActionsMenuEvent constructor.
             *
             * @param FactoryInterface $factory
             * @param ItemInterface $menu
             * @param array $options
             */
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
             * Returns the factory.
             *
             * @return FactoryInterface
             */
            public function getFactory()
            {
                return $this->factory;
            }

            /**
             * Returns the menu.
             *
             * @return ItemInterface
             */
            public function getMenu()
            {
                return $this->menu;
            }

            /**
             * Returns the options.
             *
             * @return array
             */
            public function getOptions()
            {
                return $this->options;
            }
        }
    '''

    def private menuEventImpl(Application it) '''
        namespace «app.appNamespace»\Event;

        use «app.appNamespace»\Event\Base\AbstractConfigureItemActionsMenuEvent;

        /**
         * Event implementation class for extending item actions menu.
         */
        class ConfigureItemActionsMenuEvent extends AbstractConfigureItemActionsMenuEvent
        {
            // feel free to extend the event class here
        }
    '''

    def private filterEventBaseClass(Entity it) '''
        namespace «app.appNamespace»\Event\Base;

        use Symfony\Component\EventDispatcher\Event;
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

            /**
             * Filter«name.formatForCodeCapital»Event constructor.
             *
             * @param «name.formatForCodeCapital»Entity $«name.formatForCode» Processed entity
             * @param array $entityChangeSet Change set for preUpdate events
             */
            public function __construct(«name.formatForCodeCapital»Entity $«name.formatForCode», array $entityChangeSet = [])
            {
                $this->«name.formatForCode» = $«name.formatForCode»;
                $this->entityChangeSet = $entityChangeSet;
            }

            /**
             * Returns the entity.
             *
             * @return «name.formatForCodeCapital»Entity
             */
            public function get«name.formatForCodeCapital»()
            {
                return $this->«name.formatForCode»;
            }

            /**
             * Returns the change set.
             *
             * @return array Entity change set
             */
            public function getEntityChangeSet()
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
