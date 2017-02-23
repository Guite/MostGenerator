package org.zikula.modulestudio.generator.cartridges.zclassic.models.event

import de.guite.modulestudio.metamodel.Application
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class LoggableListener {

    extension ModelBehaviourExtensions = new ModelBehaviourExtensions
    extension ModelExtensions = new ModelExtensions
    extension NamingExtensions = new NamingExtensions
    extension Utils = new Utils

    FileHelper fh = new FileHelper

    def generate(Application it, IFileSystemAccess fsa) {
        if (getLoggableEntities.filter[hasUploadFieldsEntity].empty) {
            return
        }
        generateClassPair(fsa, getAppSourceLibPath + 'Listener/LoggableListener.php',
            fh.phpFileContent(it, loggableListenerBaseImpl), fh.phpFileContent(it, loggableListenerImpl)
        )
    }

    def private loggableListenerBaseImpl(Application it) '''
        namespace «appNamespace»\Listener\Base;

        use Gedmo\Loggable\LoggableListener as GedmoLoggableListener;
        use Symfony\Component\HttpFoundation\File\File;

        /**
         * Custom loggable listener extension.
         */
        class AbstractLoggableListener extends GedmoLoggableListener
        {
            /**
             * @inheritDoc
             */
            protected function prePersistLogEntry($logEntry, $object)
            {
                $data = $logEntry->getData();
                $filteredData = [];
                if (!is_array($data)) {
                    // entity has been deleted
                    return;
                }
                foreach ($data as $key => $value) {
                    $filteredData[$key] = $value;
                    if ($value instanceof File) {
                        $filteredData[$key] = $value->getFilename();
                    }
                }
                $logEntry->setData($filteredData);
            }
        }
    '''

    def private loggableListenerImpl(Application it) '''
        namespace «appNamespace»\Listener;

        use «appNamespace»\Listener\Base\AbstractLoggableListener;

        /**
         * Custom loggable listener extension.
         */
        class LoggableListener extends AbstractLoggableListener
        {
            // feel free to enhance this listener by custom actions
        }
    '''
}
