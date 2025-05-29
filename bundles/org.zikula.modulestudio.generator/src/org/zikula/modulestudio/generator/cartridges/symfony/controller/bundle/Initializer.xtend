package org.zikula.modulestudio.generator.cartridges.symfony.controller.bundle

import de.guite.modulestudio.metamodel.Application
import org.zikula.modulestudio.generator.application.IMostFileSystemAccess
import org.zikula.modulestudio.generator.application.ImportList
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class Initializer {

    extension ModelExtensions = new ModelExtensions
    extension Utils = new Utils

    /**
     * Entry point for application initializer.
     */
    def generate(Application it, IMostFileSystemAccess fsa) {
        if (!hasUploads) {
            return
        }
        fsa.generateClassPair('Bundle/Initializer/' + appName + 'Initializer.php', initializerBaseClass, initializerImpl)
    }

    def private collectBaseImports(Application it) {
        val imports = new ImportList
        imports.addAll(#[
            'Exception',
            'Psr\\Log\\LoggerInterface',
            'Zikula\\CoreBundle\\Bundle\\Initializer\\BundleInitializerInterface'
        ])
        if (hasUploads) {
            imports.add(appNamespace + '\\Helper\\UploadHelper')
        }
        imports
    }

    def private initializerBaseClass(Application it) '''
        namespace «appNamespace»\Bundle\Initializer\Base;

        «collectBaseImports.print»

        /**
         * Initializer base class.
         */
        abstract class Abstract«appName»Initializer implements BundleInitializerInterface
        {
            «constructor»

            public function init(): void
            {
                «initialize»
            }
        }
    '''

    def private constructor(Application it) '''
        public function __construct(
            protected readonly LoggerInterface $logger«IF hasUploads»,
            protected readonly UploadHelper $uploadHelper«ENDIF»
        ) {
        }
    '''

    def private initialize(Application it) '''
        «processUploadFolders»
    '''

    def private processUploadFolders(Application it) '''
        «IF hasUploads»
            // check if upload directories exist and if needed create them
            try {
                $this->uploadHelper->checkAndCreateAllUploadFolders();
            } catch (Exception $exception) {
                $this->logger->error(
                    '{app}: Could not create upload folders. Error details: {errorMessage}.',
                    ['app' => '«appName»', 'errorMessage' => $exception->getMessage()]
                );
            }
        «ENDIF»
    '''

    def private initializerImpl(Application it) '''
        namespace «appNamespace»\Bundle\Initializer;

        use «appNamespace»\Bundle\Initializer\Base\Abstract«appName»Initializer;

        /**
         * Initializer implementation class.
         */
        class «appName»Initializer extends Abstract«appName»Initializer
        {
            // feel free to extend the bundle initializer here
        }
    '''
}
