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
        use Symfony\Contracts\Translation\TranslatorInterface;
        use Zikula\ExtensionsModule\Api\ApiInterface\VariableApiInterface;
        use Zikula\SettingsModule\Api\ApiInterface\LocaleApiInterface;
        use «appNamespace»\Entity\EntityInterface;
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
        «IF needsDynamicLoggableEnablement»
            protected LoggableListener $loggableListener;

        «ENDIF»
        public function __construct(
            protected TranslatorInterface $translator,
            protected RequestStack $requestStack,
            protected VariableApiInterface $variableApi,
            protected LocaleApiInterface $localeApi,
            protected EntityFactory $entityFactory
        ) {
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
         */
        public function getTranslatableFields(string $objectType): array
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
         */
        public function getCurrentLanguage(): string
        {
            $request = $this->requestStack->getCurrentRequest();

            return null !== $request ? $request->getLocale() : 'en';
        }
    '''

    def private getSupportedLanguages(Application it) '''
        /**
         * Return list of supported languages on the current system.
         */
        public function getSupportedLanguages(string $objectType): array
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
         */
        public function getMandatoryFields(string $objectType): array
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
        public function prepareEntityForEditing(EntityInterface $entity): array
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
                '«appName»:' . ucfirst($objectType) . 'TranslationEntity'
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
                    $translationData[$fieldName] = $entityTranslations[$language][$fieldName] ?? '';
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
         */
        public function processEntityAfterEditing(EntityInterface $entity, FormInterface $form): void
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
         */
        public function readTranslationInput(FormInterface $form, string $language = 'en'): array
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
             */
            public function toggleLoggable(bool $enable = true): void
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
         */
        public function setEntityFieldsFromLogData(EntityInterface $entity): EntityInterface
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
         */
        public function refreshTranslationsFromLogData(EntityInterface $entity): void
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
               ->setParameter('objectClass', $entity::class)
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
