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
        «IF targets('3.0')»
            use Symfony\Contracts\Translation\TranslatorInterface;
            use Zikula\Bundle\CoreBundle\Doctrine\EntityAccess;
        «ELSE»
            use Zikula\Common\Translator\TranslatorInterface;
            use Zikula\Core\Doctrine\EntityAccess;
        «ENDIF»
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
        «IF hasLoggableTranslatable»

            «setEntityFieldsFromLogData»

            «refreshTranslationsFromLogData»
        «ENDIF»
    '''

    def private getTranslatableFieldsImpl(Application it) '''
        /**
         * Return list of translatable fields per entity.
         * These are required to be determined to recognise
         * that they have to be selected from according translation tables.
         «IF !targets('3.0')»
         *
         * @param string $objectType The currently treated object type
         *
         * @return string[] List of translatable fields
         «ENDIF»
         */
        public function getTranslatableFields(«IF targets('3.0')»string «ENDIF»$objectType)«IF targets('3.0')»: array«ENDIF»
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
         «IF !targets('3.0')»
         *
         * @return string code of current language
         «ENDIF»
         */
        public function getCurrentLanguage()«IF targets('3.0')»: string«ENDIF»
        {
            $request = $this->requestStack->getCurrentRequest();

            return null !== $request ? $request->getLocale() : 'en';
        }
    '''

    def private getSupportedLanguages(Application it) '''
        /**
         * Return list of supported languages on the current system.
         «IF !targets('3.0')»
         *
         * @param string $objectType The currently treated object type
         *
         * @return string[] List of language codes
         «ENDIF»
         */
        public function getSupportedLanguages(«IF targets('3.0')»string «ENDIF»$objectType)«IF targets('3.0')»: array«ENDIF»
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
         «IF !targets('3.0')»
         *
         * @param string $objectType The currently treated object type
         *
         * @return array List of mandatory fields for each language code
         «ENDIF»
         */
        public function getMandatoryFields(«IF targets('3.0')»string «ENDIF»$objectType)«IF targets('3.0')»: array«ENDIF»
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
         * @return array Collected translations for each language code
         */
        public function prepareEntityForEditing(EntityAccess $entity)«IF targets('3.0')»: array«ENDIF»
        {
            $translations = [];
            $objectType = $entity->get_objectType();

            if (!$this->variableApi->getSystemVar('multilingual')) {
                return $translations;
            }

            // check if there are any translated fields registered for the given object type
            $fields = $this->getTranslatableFields($objectType);
            if (!count($fields)) {
                return $translations;
            }

            // get translations
            $entityManager = $this->entityFactory->getEntityManager();
            $repository = $entityManager->getRepository(
                '«appNamespace»\Entity\\' . ucfirst($objectType) . 'TranslationEntity'
            );
            $entityTranslations = $repository->findTranslations($entity);

            $supportedLanguages = $this->getSupportedLanguages($objectType);
            $currentLanguage = $this->getCurrentLanguage();
            foreach ($supportedLanguages as $language) {
                if ($language === $currentLanguage) {
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
                    «IF targets('3.0')»
                        $translationData[$fieldName] = $entityTranslations[$language][$fieldName] ?? '';
                    «ELSE»
                        $translationData[$fieldName] = isset($entityTranslations[$language][$fieldName])
                            ? $entityTranslations[$language][$fieldName]
                            : ''
                        ;
                    «ENDIF»
                }
                «IF !getAllEntities.filter[slugUnique && hasTranslatableSlug && needsSlugHandler].empty»
                    if (isset($translationData['slug']) && in_array($objectType, ['«getAllEntities.filter[slugUnique && hasTranslatableSlug && needsSlugHandler].map[name.formatForCode].join('\', \'')»'])) {
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
         «IF !targets('3.0')»
         *
         * @param EntityAccess $entity The entity being edited
         * @param FormInterface $form Form containing translations
         «ENDIF»
         */
        public function processEntityAfterEditing(EntityAccess $entity, FormInterface $form)«IF targets('3.0')»: void«ENDIF»
        {
            «IF needsDynamicLoggableEnablement»
                $this->toggleLoggable(false);

            «ENDIF»
            $objectType = $entity->get_objectType();
            $entityManager = $this->entityFactory->getEntityManager();
            $supportedLanguages = $this->getSupportedLanguages($objectType);
            foreach ($supportedLanguages as $language) {
                $translationInput = $this->readTranslationInput($form, $language);
                if (!count($translationInput)) {
                    continue;
                }

                foreach ($translationInput as $fieldName => $fieldData) {
                    $setter = 'set' . ucfirst($fieldName);
                    $entity->$setter($fieldData);
                }

                $entity->setLocale($language);
                $entityManager->flush();
            }
            «IF needsDynamicLoggableEnablement»

                $this->toggleLoggable(true);
            «ENDIF»
        }

        /**
         * Collects translated fields from given form for a specific language.
         «IF !targets('3.0')»
         *
         * @param FormInterface $form Form containing translations
         * @param string $language The desired language
         *
         * @return array
         «ENDIF»
         */
        public function readTranslationInput(FormInterface $form, «IF targets('3.0')»string «ENDIF»$language = 'en')«IF targets('3.0')»: array«ENDIF»
        {
            $data = [];
            $translationKey = 'translations' . $language;
            if (!isset($form[$translationKey])) {
                return $data;
            }
            $translatedFields = $form[$translationKey];
            foreach ($translatedFields as $fieldName => $formField) {
                $fieldData = $formField->getData();
                if (!$fieldData && isset($form[$fieldName])) {
                    $fieldData = $form[$fieldName]->getData();
                }
                $data[$fieldName] = $fieldData;
            }

            return $data;
        }
        «IF needsDynamicLoggableEnablement»

            /**
             * Enables or disables the loggable listener to avoid log entries
             * for translation changes.
             «IF !targets('3.0')»
             *
             * @param bool $enable True for enable, false for disable
             «ENDIF»
             */
            public function toggleLoggable(«IF targets('3.0')»bool «ENDIF»$enable = true)«IF targets('3.0')»: void«ENDIF»
            {
                $eventManager = $this->entityFactory->getEntityManager()->getEventManager();
                if (null === $this->loggableListener) {
                    foreach ($eventManager->getListeners() as $event => $listeners) {
                        foreach ($listeners as $hash => $listener) {
                            if ($listener instanceof LoggableListener) {
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

    def private setEntityFieldsFromLogData(Application it) '''
        /**
         * Sets values for translatable fields of given entity from it's stored
         * translation data.
         «IF !targets('3.0')»
         *
         * @param EntityAccess $entity Currently treated entity instance
         *
         * @return EntityAccess The processed entity instance
         «ENDIF»
         */
        public function setEntityFieldsFromLogData(EntityAccess $entity)«IF targets('3.0')»: EntityAccess«ENDIF»
        {
            // check if this revision has translation data for current locale
            $translationData = $entity->getTranslationData();
            $language = $this->getCurrentLanguage();
            if (!isset($translationData[$language])) {
                return $entity;
            }

            $objectType = $entity->get_objectType();
            $translatableFields = $this->getTranslatableFields($objectType);
            foreach ($translatableFields as $fieldName) {
                if (!isset($translationData[$language][$fieldName])) {
                    continue;
                }
                $setter = 'set' . ucfirst($fieldName);
                $entity->$setter($translationData[$language][$fieldName]);
            }

            return $entity;
        }
    '''

    def private refreshTranslationsFromLogData(Application it) '''
        /**
         * Removes all translations and persists them again for all
         * translatable fields of given entity from it's stored
         * translation data.
         *
         * The logic of this method is similar to processEntityAfterEditing above.
         «IF !targets('3.0')»
         *
         * @param EntityAccess $entity Currently treated entity instance
         «ENDIF»
         */
        public function refreshTranslationsFromLogData(EntityAccess $entity)«IF targets('3.0')»: void«ENDIF»
        {
            «IF needsDynamicLoggableEnablement»
                $this->toggleLoggable(false);

            «ENDIF»
            $objectType = $entity->get_objectType();

            // remove all existing translations
            $entityManager = $this->entityFactory->getEntityManager();
            $translationClass = '«appNamespace»\Entity\\' . ucfirst($objectType) . 'TranslationEntity';
            $repository = $entityManager->getRepository($translationClass);
            $translationMeta = $entityManager->getClassMetadata($translationClass);
            $qb = $entityManager->createQueryBuilder();
            $qb->delete($translationMeta->rootEntityName, 'trans')
               ->where('trans.objectClass = :objectClass')
               ->andWhere('trans.foreignKey = :objectId')
               ->setParameter('objectClass', get_class($entity))
               ->setParameter('objectId', $entity->getKey())
            ;
            $query = $qb->getQuery();
            $query->execute();

            $translatableFields = $this->getTranslatableFields($objectType);
            $translationData = $entity->getTranslationData();
            $supportedLanguages = $this->getSupportedLanguages($objectType);
            foreach ($supportedLanguages as $language) {
                // check if this revision has translation data for current locale
                if (!isset($translationData[$language])) {
                    continue;
                }

                foreach ($translatableFields as $fieldName) {
                    if (!isset($translationData[$language][$fieldName])) {
                        continue;
                    }
                    $setter = 'set' . ucfirst($fieldName);
                    $entity->$setter($translationData[$language][$fieldName]);
                }

                $entity->setLocale($language);
                $entityManager->flush();
            }
            «IF needsDynamicLoggableEnablement»

                $this->toggleLoggable(true);
            «ENDIF»
        }
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
