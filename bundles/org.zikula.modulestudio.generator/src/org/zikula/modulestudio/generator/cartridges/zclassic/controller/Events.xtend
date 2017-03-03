package org.zikula.modulestudio.generator.cartridges.zclassic.controller

import de.guite.modulestudio.metamodel.Application
import de.guite.modulestudio.metamodel.Entity
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

/**
 * Generates a class for defining custom events.
 */
class Events {

    extension FormattingExtensions = new FormattingExtensions
    extension ModelExtensions = new ModelExtensions
    extension NamingExtensions = new NamingExtensions
    extension Utils = new Utils

    FileHelper fh = new FileHelper
    Application app

    /**
     * Entry point for event definition class.
     */
    def generate(Application it, IFileSystemAccess fsa) {
        app = it

        generateClassPair(fsa, getAppSourceLibPath + name.formatForCodeCapital + 'Events.php',
            fh.phpFileContent(it, eventDefinitionsBaseClass), fh.phpFileContent(it, eventDefinitionsImpl)
        )

        for (entity : getAllEntities) {
            generateClassPair(fsa, getAppSourceLibPath + 'Event/Filter' + entity.name.formatForCodeCapital + 'Event.php',
                fh.phpFileContent(it, filterEventBaseClass(entity)), fh.phpFileContent(it, filterEventImpl(entity))
            )
        }
    }

    def private eventDefinitionsBaseClass(Application it) '''
        namespace «appNamespace»\Base;

        /**
         * Events definition base class.
         */
        abstract class Abstract«name.formatForCodeCapital»Events
        {
            «FOR entity : getAllEntities»
                «entity.eventDefinitions»
            «ENDFOR»
        }
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
         * @see «app.appNamespace»\Listener\EntityLifecycleListener::postLoad()
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
         * @see «app.appNamespace»\Listener\EntityLifecycleListener::prePersist()
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
         * @see «app.appNamespace»\Listener\EntityLifecycleListener::postPersist()
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
         * @see «app.appNamespace»\Listener\EntityLifecycleListener::preRemove()
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
         * @see «app.appNamespace»\Listener\EntityLifecycleListener::postRemove()
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
         * @see «app.appNamespace»\Listener\EntityLifecycleListener::preUpdate()
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
         * @see «app.appNamespace»\Listener\EntityLifecycleListener::postUpdate()
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
             * Filter«name.formatForCodeCapital»Event constructor.
             *
             * @param «name.formatForCodeCapital»Entity $«name.formatForCode» Processed entity
             */
            public function __construct(«name.formatForCodeCapital»Entity $«name.formatForCode»)
            {
                $this->«name.formatForCode» = $«name.formatForCode»;
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
