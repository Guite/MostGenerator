package org.zikula.modulestudio.generator.cartridges.zclassic.controller

import de.guite.modulestudio.metamodel.Application
import org.zikula.modulestudio.generator.application.IMostFileSystemAccess
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper
import org.zikula.modulestudio.generator.extensions.ControllerExtensions
import org.zikula.modulestudio.generator.extensions.Utils

/**
 * Generates a class for defining custom events.
 */
class Events {

    extension ControllerExtensions = new ControllerExtensions
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
        if (hasIndexActions) {
            fsa.generateClassPair('Event/IndexActionsMenuPreConfigurationEvent.php', menuEventBaseClass('index', 'pre'), menuEventImpl('index', 'pre'))
            fsa.generateClassPair('Event/IndexActionsMenuPostConfigurationEvent.php', menuEventBaseClass('index', 'post'), menuEventImpl('index', 'post'))
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
}
