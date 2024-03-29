package org.zikula.modulestudio.generator.cartridges.symfony.controller.bundle

import de.guite.modulestudio.metamodel.Application
import org.zikula.modulestudio.generator.application.IMostFileSystemAccess
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.Utils
import org.zikula.modulestudio.generator.application.ImportList

class Initializer {

    extension FormattingExtensions = new FormattingExtensions
    extension ModelExtensions = new ModelExtensions
    extension ModelBehaviourExtensions = new ModelBehaviourExtensions
    extension Utils = new Utils

    /**
     * Entry point for application initializer.
     */
    def generate(Application it, IMostFileSystemAccess fsa) {
        if (!hasUploads && !hasCategorisableEntities) {
            return
        }
        fsa.generateClassPair('Bundle/Initializer/' + name.formatForCodeCapital + 'Initializer.php', initializerBaseClass, initializerImpl)
    }

    def private collectBaseImports(Application it) {
        val imports = new ImportList
        imports.addAll(#[
            'Exception',
            'Psr\\Log\\LoggerInterface',
            'Zikula\\CoreBundle\\Bundle\\Initializer\\BundleInitializerInterface'
        ])
        if (hasCategorisableEntities) {
            imports.addAll(#[
                'Zikula\\CategoriesBundle\\Entity\\CategoryRegistry',
                'Zikula\\CategoriesBundle\\Repository\\CategoryRepositoryInterface',
                appNamespace + '\\Helper\\CategoryHelper'
            ])
        }
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
        abstract class Abstract«name.formatForCodeCapital»Initializer implements BundleInitializerInterface
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
            protected readonly LoggerInterface $logger«IF hasCategorisableEntities»,
            protected readonly CategoryHelper $categoryHelper,
            protected readonly CategoryRepositoryInterface $categoryRepository«ENDIF»«IF hasUploads»,
            protected readonly UploadHelper $uploadHelper«ENDIF»
        ) {
        }
    '''

    def private initialize(Application it) '''
        «processUploadFolders»

        «IF hasCategorisableEntities»

            // add default entry for category registry (property named Main)
            $categoryGlobal = $this->categoryRepository->findOneBy(['name' => 'Global']);
            if ($categoryGlobal) {
                «FOR entity : getCategorisableEntities»

                    $registry = (new CategoryRegistryEntity())
                        ->setBundleName('«appName»')
                        ->setEntityName('«entity.name.formatForCodeCapital»Entity')
                        ->setProperty($this->categoryHelper->getPrimaryProperty('«entity.name.formatForCodeCapital»'))
                        ->setCategory($categoryGlobal);

                    try {
                        $this->entityManager->persist($registry);
                        $this->entityManager->flush();
                    } catch (Exception $exception) {
                        $this->logger->warning(
                            '{app}: Could not create a category registry for the {entity} entity. If you want to use categorisation, register at least one registry in the Categories administration. Error details: {errorMessage}.',
                            ['app' => '«appName»', 'entity' => '«entity.name.formatForDisplay»', 'errorMessage' => $exception->getMessage()]
                        );
                    }
                «ENDFOR»
            } else {
                $this->logger->warning(
                    '{app}: Could not create category registries. If you want to use categorisation, register at least one registry in the Categories administration.',
                    ['app' => '«appName»']
                );
            }
        «ENDIF»
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

        use «appNamespace»\Bundle\Initializer\Base\Abstract«name.formatForCodeCapital»Initializer;

        /**
         * Initializer implementation class.
         */
        class «name.formatForCodeCapital»Initializer extends Abstract«name.formatForCodeCapital»Initializer
        {
            // feel free to extend the bundle initializer here
        }
    '''
}
