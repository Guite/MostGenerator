package org.zikula.modulestudio.generator.cartridges.zclassic.controller.listener

import de.guite.modulestudio.metamodel.Application
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class LoggableListener {

    extension FormattingExtensions = new FormattingExtensions
    extension ModelBehaviourExtensions = new ModelBehaviourExtensions
    extension ModelExtensions = new ModelExtensions
    extension NamingExtensions = new NamingExtensions
    extension Utils = new Utils

    /**
     * Entry point for loggable listener class creation.
     */
    def generate(Application it, IFileSystemAccess fsa) {
        if (!hasLoggable) {
            return
        }
        println('Generating custom loggable listener')
        val fh = new FileHelper
        generateClassPair(fsa, 'Listener/LoggableListener.php',
            fh.phpFileContent(it, listenerBaseImpl), fh.phpFileContent(it, listenerImpl)
        )
    }

    def private listenerBaseImpl(Application it) '''
        namespace «appNamespace»\Listener\Base;

        use Gedmo\Loggable\LoggableListener as BaseListener;

        /**
         * Custom loggable listener for proper undeletion.
         */
        abstract class AbstractLoggableListener extends BaseListener
        {
            protected function prePersistLogEntry($logEntry, $object)
            {
                parent::prePersistLogEntry($logEntry, $object);

                // check if a supported object has been undeleted
                if ('create' != $logEntry->getAction() || !method_exists($object, 'get_objectType')) {
                    return;
                }

                // set correct version after undeletion
                $logVersion = $logEntry->getVersion();
                «FOR entity : getLoggableEntities»
                    if ($object->get_objectType() == '«entity.name.formatForCode»' && method_exists($object, 'get«entity.getVersionField.name.formatForCodeCapital»')) {
                        if ($logVersion < $object->get«entity.getVersionField.name.formatForCodeCapital»()) {
                            $logEntry->setVersion($object->get«entity.getVersionField.name.formatForCodeCapital»());
                        }
                    }
                «ENDFOR»
            }
        }
    '''

    def private listenerImpl(Application it) '''
        namespace «appNamespace»\Listener;

        use «appNamespace»\Listener\Base\AbstractLoggableListener;

        /**
         * Custom loggable listener for proper undeletion.
         */
        class LoggableListener extends AbstractLoggableListener
        {
            // feel free to add your own convenience methods here
        }
    '''
}
