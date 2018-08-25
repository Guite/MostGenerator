package org.zikula.modulestudio.generator.cartridges.zclassic.controller.helper

import de.guite.modulestudio.metamodel.Application
import de.guite.modulestudio.metamodel.Entity
import org.zikula.modulestudio.generator.application.IMostFileSystemAccess
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class TranslatableHelper {

    extension FormattingExtensions = new FormattingExtensions
    extension ModelBehaviourExtensions = new ModelBehaviourExtensions
    extension ModelExtensions = new ModelExtensions
    extension Utils = new Utils

    Boolean needsDynamicLoggableEnablement

    /**
     * Entry point for the helper class creation.
     */
    def generate(Application it, IMostFileSystemAccess fsa) {
        'Generating helper class for translatable entities'.printIfNotTesting(fsa)
        needsDynamicLoggableEnablement = if (!getAllEntities.filter[loggable && hasTranslatableFields].empty) true else false
        fsa.generateClassPair('Helper/TranslatableHelper.php', translatableFunctionsBaseImpl, translatableFunctionsImpl)
    }

    def private translatableFunctionsBaseImpl(Application it) '''
        namespace «appNamespace»\Helper\Base;

        «IF needsDynamicLoggableEnablement»
            use Gedmo\Loggable\LoggableListener;
        «ENDIF»
        use Symfony\Component\Form\FormInterface;
        use Symfony\Component\HttpFoundation\RequestStack;
        use Zikula\Common\Translator\TranslatorInterface;
        use Zikula\Core\Doctrine\EntityAccess;
        use Zikula\ExtensionsModule\Api\ApiInterface\VariableApiInterface;
        use Zikula\SettingsModule\Api\ApiInterface\LocaleApiInterface;
        use «appNamespace»\Entity\Factory\EntityFactory;

        /**
         * Helper base class for translatable methods.
         */
        abstract class AbstractTranslatableHelper
        {
            «helperBaseImpl»
        }
    '''

    def private helperBaseImpl(Application it) '''
        /**
         * @var TranslatorInterface
         */
        protected $translator;

        /**
         * @var RequestStack
         */
        protected $requestStack;

        /**
         * @var VariableApiInterface
         */
        protected $variableApi;

        /**
         * @var LocaleApiInterface
         */
        protected $localeApi;

        /**
         * @var EntityFactory
         */
        protected $entityFactory;
        «IF needsDynamicLoggableEnablement»

            /**
             * @var LoggableListener
             */
            protected $loggableListener;
        «ENDIF»

        /**
         * TranslatableHelper constructor.
         *
         * @param TranslatorInterface  $translator    Translator service instance
         * @param RequestStack         $requestStack  RequestStack service instance
         * @param VariableApiInterface $variableApi   VariableApi service instance
         * @param LocaleApiInterface   $localeApi     LocaleApi service instance
         * @param EntityFactory        $entityFactory EntityFactory service instance
         */
        public function __construct(
            TranslatorInterface $translator,
            RequestStack $requestStack,
            VariableApiInterface $variableApi,
            LocaleApiInterface $localeApi,
            EntityFactory $entityFactory
        ) {
            $this->translator = $translator;
            $this->requestStack = $requestStack;
            $this->variableApi = $variableApi;
            $this->localeApi = $localeApi;
            $this->entityFactory = $entityFactory;
            «IF needsDynamicLoggableEnablement»
                $this->loggableListener = null;
            «ENDIF»
        }

        «getTranslatableFieldsImpl»

        «getCurrentLanguage»

        «getSupportedLanguages»

        «getMandatoryFields»

        «prepareEntityForEditing»

        «processEntityAfterEditing»
    '''

    def private getTranslatableFieldsImpl(Application it) '''
        /**
         * Return list of translatable fields per entity.
         * These are required to be determined to recognise
         * that they have to be selected from according translation tables.
         *
         * @param string $objectType The currently treated object type
         *
         * @return array List of translatable fields
         */
        public function getTranslatableFields($objectType)
        {
            $fields = [];
            switch ($objectType) {
                «FOR entity : getTranslatableEntities»
                    «entity.translatableFieldList»
                «ENDFOR»
            }

            return $fields;
        }
    '''

    def private translatableFieldList(Entity it) '''
            case '«name.formatForCode»':
                $fields = ['«getTranslatableFields.map[name.formatForCode].join('\', \'')»'«IF hasTranslatableSlug», 'slug'«ENDIF»];
                break;
    '''

    def private getCurrentLanguage(Application it) '''
        /**
         * Return the current language code.
         *
         * @return string code of current language
         */
        public function getCurrentLanguage()
        {
            return $this->requestStack->getCurrentRequest()->getLocale();
        }
    '''

    def private getSupportedLanguages(Application it) '''
        /**
         * Return list of supported languages on the current system.
         *
         * @param string $objectType The currently treated object type
         *
         * @return array List of language codes
         */
        public function getSupportedLanguages($objectType)
        {
            if ($this->variableApi->getSystemVar('multilingual')) {
                return $this->localeApi->getSupportedLocales();
            }

            // if multi language is disabled use only the current language
            return [$this->getCurrentLanguage()];
        }
    '''

    def private getMandatoryFields(Application it) '''
        /**
         * Returns a list of mandatory fields for each supported language.
         *
         * @param string $objectType The currently treated object type
         *
         * @return array List of mandatory fields for each language code
         */
        public function getMandatoryFields($objectType)
        {
            $mandatoryFields = [];
            foreach ($this->getSupportedLanguages($objectType) as $language) {
                $mandatoryFields[$language] = [];
            }

            return $mandatoryFields;
        }
    '''

    def private prepareEntityForEditing(Application it) '''
        /**
         * Collects translated fields for editing.
         *
         * @param EntityAccess $entity The entity being edited
         *
         * @return array Collected translations for each language code
         */
        public function prepareEntityForEditing($entity)
        {
            $translations = [];
            $objectType = $entity->get_objectType();

            if ($this->variableApi->getSystemVar('multilingual') != 1) {
                return $translations;
            }

            // check if there are any translated fields registered for the given object type
            $fields = $this->getTranslatableFields($objectType);
            if (!count($fields)) {
                return $translations;
            }

            // get translations
            $repository = $this->entityFactory->getObjectManager()->getRepository('Gedmo\Translatable\Entity\Translation');
            $entityTranslations = $repository->findTranslations($entity);

            $supportedLanguages = $this->getSupportedLanguages($objectType);
            $currentLanguage = $this->getCurrentLanguage();
            foreach ($supportedLanguages as $language) {
                if ($language == $currentLanguage) {
                    foreach ($fields as $fieldName) {«/* fix for #980 */»
                        if (null === $entity[$fieldName]) {
                            $entity[$fieldName] = '';
                        }
                    }
                    // skip current language as this is not treated as translation on controller level
                    continue;
                }
                $translationData = [];
                foreach ($fields as $fieldName) {
                    $translationData[$fieldName] = isset($entityTranslations[$language][$fieldName]) ? $entityTranslations[$language][$fieldName] : '';
                }
                «IF !getAllEntities.filter[slugUnique && hasTranslatableSlug && needsSlugHandler].empty»
                    if (in_array($objectType, ['«getAllEntities.filter[slugUnique && hasTranslatableSlug && needsSlugHandler].map[name.formatForCode].join('\', \'')»']) && isset($translationData['slug'])) {
                        $slugParts = explode('/', $translationData['slug']);
                        $translationData['slug'] = end($slugParts);
                    }
                «ENDIF»
                // add data to collected translations
                $translations[$language] = $translationData;
            }

            return $translations;
        }
    '''

    def private processEntityAfterEditing(Application it) '''
        /**
         * Post-editing method persisting translated fields.
         *
         * @param EntityAccess  $entity The entity being edited
         * @param FormInterface $form   Form containing translations
         */
        public function processEntityAfterEditing($entity, $form)
        {
            «IF needsDynamicLoggableEnablement»
                $this->toggleLoggable(false);
            «ENDIF»
            $objectType = $entity->get_objectType();
            $supportedLanguages = $this->getSupportedLanguages($objectType);
            foreach ($supportedLanguages as $language) {
                if (!isset($form['translations' . $language])) {
                    continue;
                }
                $translatedFields = $form['translations' . $language];
                foreach ($translatedFields as $fieldName => $formField) {
                    $fieldData = $formField->getData();
                    if (!$fieldData && isset($form[$fieldName])) {
                        $fieldData = $form[$fieldName]->getData();
                    }
                    $entity[$fieldName] = $fieldData;
                }
                $entity['locale'] = $language;
                $this->entityFactory->getObjectManager()->flush();
            }
            «IF needsDynamicLoggableEnablement»
                $this->toggleLoggable(true);
            «ENDIF»
        }
        «IF needsDynamicLoggableEnablement»

            /**
             * Enables or disables the loggable listener to avoid log entries
             * for translation changes.
             *
             * @param boolean $enable True for enable, false for disable
             */
            public function toggleLoggable($enable = true)
            {
                $eventManager = $this->entityFactory->getObjectManager()->getEventManager();
                if (null === $this->loggableListener) {
                    foreach ($eventManager->getListeners() as $event => $listeners) {
                        foreach ($listeners as $hash => $listener) {
                            if ($listener instanceof loggableListener) {
                                $this->loggableListener = $listener;
                                break 2;
                            }
                        }
                    }
                }
                if (null === $this->loggableListener) {
                    return;
                }

                if (true === $enable) {
                    $eventManager->addEventSubscriber($this->loggableListener);
                } else {
                    $eventManager->removeEventSubscriber($this->loggableListener);
                }
            }
        «ENDIF»
    '''

    def private translatableFunctionsImpl(Application it) '''
        namespace «appNamespace»\Helper;

        use «appNamespace»\Helper\Base\AbstractTranslatableHelper;

        /**
         * Helper implementation class for translatable methods.
         */
        class TranslatableHelper extends AbstractTranslatableHelper
        {
            // feel free to add your own convenience methods here
        }
    '''
}
