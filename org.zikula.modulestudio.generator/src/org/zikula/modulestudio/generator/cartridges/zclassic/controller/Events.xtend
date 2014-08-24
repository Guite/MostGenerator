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
        if (targets('1.3.5')) {
            return
        }

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
        class «name.formatForCodeCapital»Events
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
         * «application.appNamespace»\Event\Filter«name.formatForCodeCapital»Event instance.
         *
         * @see «entityClassName('', false)»::postLoadCallback()
         * @var string
         */
        const «constPrefix»_POST_LOAD = '«entityEventPrefix»_post_load';

        /**
         * The «entityEventPrefix»_pre_persist event is thrown before a new «name.formatForDisplay»
         * is created in the system.
         *
         * The event listener receives an
         * «application.appNamespace»\Event\Filter«name.formatForCodeCapital»Event instance.
         *
         * @see «entityClassName('', false)»::prePersistCallback()
         * @var string
         */
        const «constPrefix»_PRE_PERSIST = '«entityEventPrefix»_pre_persist';

        /**
         * The «entityEventPrefix»_post_persist event is thrown after a new «name.formatForDisplay»
         * has been created in the system.
         *
         * The event listener receives an
         * «application.appNamespace»\Event\Filter«name.formatForCodeCapital»Event instance.
         *
         * @see «entityClassName('', false)»::postPersistCallback()
         * @var string
         */
        const «constPrefix»_POST_PERSIST = '«entityEventPrefix»_post_persist';

        /**
         * The «entityEventPrefix»_pre_remove event is thrown before an existing «name.formatForDisplay»
         * is removed from the system.
         *
         * The event listener receives an
         * «application.appNamespace»\Event\Filter«name.formatForCodeCapital»Event instance.
         *
         * @see «entityClassName('', false)»::preRemoveCallback()
         * @var string
         */
        const «constPrefix»_PRE_REMOVE = '«entityEventPrefix»_pre_remove';

        /**
         * The «entityEventPrefix»_post_remove event is thrown after an existing «name.formatForDisplay»
         * has been removed from the system.
         *
         * The event listener receives an
         * «application.appNamespace»\Event\Filter«name.formatForCodeCapital»Event instance.
         *
         * @see «entityClassName('', false)»::postRemoveCallback()
         * @var string
         */
        const «constPrefix»_POST_REMOVE = '«entityEventPrefix»_post_remove';

        /**
         * The «entityEventPrefix»_pre_update event is thrown before an existing «name.formatForDisplay»
         * is updated in the system.
         *
         * The event listener receives an
         * «application.appNamespace»\Event\Filter«name.formatForCodeCapital»Event instance.
         *
         * @see «entityClassName('', false)»::preUpdateCallback()
         * @var string
         */
        const «constPrefix»_PRE_UPDATE = '«entityEventPrefix»_pre_update';

        /**
         * The «entityEventPrefix»_post_update event is thrown after an existing new «name.formatForDisplay»
         * has been updated in the system.
         *
         * The event listener receives an
         * «application.appNamespace»\Event\Filter«name.formatForCodeCapital»Event instance.
         *
         * @see «entityClassName('', false)»::postUpdateCallback()
         * @var string
         */
        const «constPrefix»_POST_UPDATE = '«entityEventPrefix»_post_update';

        /**
         * The «entityEventPrefix»_pre_save event is thrown before a new «name.formatForDisplay»
         * is created or an existing «name.formatForDisplay» is updated in the system.
         *
         * The event listener receives an
         * «application.appNamespace»\Event\Filter«name.formatForCodeCapital»Event instance.
         *
         * @see «entityClassName('', false)»::preSaveCallback()
         * @var string
         */
        const «constPrefix»_PRE_SAVE = '«entityEventPrefix»_pre_save';

        /**
         * The «entityEventPrefix»_post_save event is thrown after a new «name.formatForDisplay»
         * has been created or an existing «name.formatForDisplay» has been updated in the system.
         *
         * The event listener receives an
         * «application.appNamespace»\Event\Filter«name.formatForCodeCapital»Event instance.
         *
         * @see «entityClassName('', false)»::postSaveCallback()
         * @var string
         */
        const «constPrefix»_POST_SAVE = '«entityEventPrefix»_post_save';

    '''

    def private eventDefinitionsImpl(Application it) '''
        namespace «appNamespace»;

        use «appNamespace»\Base\«name.formatForCodeCapital»Events as Base«name.formatForCodeCapital»Events;

        /**
         * Events definition implementation class.
         */
        class «name.formatForCodeCapital»Events extends Base«name.formatForCodeCapital»Events
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
        class Filter«name.formatForCodeCapital»Event extends Event
        {
            /**
             * @var «name.formatForCodeCapital»Entity Reference to treated entity instance.
             */
            protected $«name.formatForCode»;

            public function __construct(«name.formatForCodeCapital»Entity $«name.formatForCode»)
            {
                $this->«name.formatForCode» = $«name.formatForCode»;
            }

            public function get«name.formatForCodeCapital»()
            {
                return $this->«name.formatForCode»;
            }
        }
    '''

    def private filterEventImpl(Entity it) '''
        namespace «app.appNamespace»\Event;

        use «app.appNamespace»\Event\Base\Filter«name.formatForCodeCapital»Event as BaseFilter«name.formatForCodeCapital»Event;

        /**
         * Event implementation class for filtering «name.formatForDisplay» processing.
         */
        class Filter«name.formatForCodeCapital»Event extends BaseFilter«name.formatForCodeCapital»Event
        {
            // feel free to extend the event class here
        }
    '''
}
