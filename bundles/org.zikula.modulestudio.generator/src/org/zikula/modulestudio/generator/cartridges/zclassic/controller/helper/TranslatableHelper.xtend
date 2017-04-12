package org.zikula.modulestudio.generator.cartridges.zclassic.controller.helper

import de.guite.modulestudio.metamodel.Application
import de.guite.modulestudio.metamodel.Entity
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class TranslatableHelper {

    extension FormattingExtensions = new FormattingExtensions
    extension ModelBehaviourExtensions = new ModelBehaviourExtensions
    extension NamingExtensions = new NamingExtensions
    extension Utils = new Utils

    /**
     * Entry point for the helper class creation.
     */
    def generate(Application it, IFileSystemAccess fsa) {
        println('Generating helper class for translatable entities')
        val fh = new FileHelper
        generateClassPair(fsa, getAppSourceLibPath + 'Helper/TranslatableHelper.php',
            fh.phpFileContent(it, translatableFunctionsBaseImpl), fh.phpFileContent(it, translatableFunctionsImpl)
        )
    }

    def private translatableFunctionsBaseImpl(Application it) '''
        namespace «appNamespace»\Helper\Base;

        use Symfony\Component\Form\FormInterface;
        use Symfony\Component\HttpFoundation\Request;
        use Symfony\Component\HttpFoundation\RequestStack;
        use Zikula\Common\Translator\TranslatorInterface;
        use Zikula\Core\Doctrine\EntityAccess;
        use Zikula\ExtensionsModule\Api\«IF targets('1.5')»ApiInterface\VariableApiInterface«ELSE»VariableApi«ENDIF»;
        use Zikula\SettingsModule\Api\«IF targets('1.5')»ApiInterface\LocaleApiInterface«ELSE»LocaleApi«ENDIF»;
        use «appNamespace»\Entity\Factory\«name.formatForCodeCapital»Factory;

        /**
         * Helper base class for translatable methods.
         */
        abstract class AbstractTranslatableHelper
        {
            /**
             * @var TranslatorInterface
             */
            protected $translator;

            /**
             * @var Request
             */
            protected $request;

            /**
             * @var VariableApi«IF targets('1.5')»Interface«ENDIF»
             */
            protected $variableApi;

            /**
             * @var LocaleApi«IF targets('1.5')»Interface«ENDIF»
             */
            protected $localeApi;

            /**
             * @var «name.formatForCodeCapital»Factory
             */
            protected $entityFactory;

            /**
             * TranslatableHelper constructor.
             *
             * @param TranslatorInterface $translator   Translator service instance
             * @param RequestStack        $requestStack RequestStack service instance
             * @param VariableApi«IF targets('1.5')»Interface«ELSE»        «ENDIF» $variableApi  VariableApi service instance
             * @param LocaleApi«IF targets('1.5')»Interface«ELSE»         «ENDIF»  $localeApi    LocaleApi service instance
             * @param «name.formatForCodeCapital»Factory $entityFactory «name.formatForCodeCapital»Factory service instance
             */
            public function __construct(
                TranslatorInterface $translator,
                RequestStack $requestStack,
                VariableApi«IF targets('1.5')»Interface«ENDIF» $variableApi,
                LocaleApi«IF targets('1.5')»Interface«ENDIF» $localeApi,
                «name.formatForCodeCapital»Factory $entityFactory
            ) {
                $this->translator = $translator;
                $this->request = $requestStack->getCurrentRequest();
                $this->variableApi = $variableApi;
                $this->localeApi = $localeApi;
                $this->entityFactory = $entityFactory;
            }

            «getTranslatableFieldsImpl»

            «getCurrentLanguage»

            «getSupportedLanguages»

            «getMandatoryFields»

            «prepareEntityForEditing»

            «processEntityAfterEditing»
        }
    '''

    def private getTranslatableFieldsImpl(Application it) '''
        /**
         * Return list of translatable fields per entity.
         * These are required to be determined to recognise
         * that they have to be selected from according translation tables.
         *
         * @param string $objectType The currently treated object type
         *
         * @return array list of translatable fields
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
                $fields = ['«getTranslatableFields.map[name.formatForCode].join('\', \'')»'«IF application.supportsSlugInputFields && hasTranslatableSlug», 'slug'«ENDIF»];
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
            return $this->request->getLocale();
        }
    '''

    def private getSupportedLanguages(Application it) '''
        /**
         * Return list of supported languages on the current system.
         *
         * @param string $objectType The currently treated object type
         *
         * @return array list of language codes
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
         * @return array
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
         * @return array collected translations having the language codes as keys
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
                // add data to collected translations
                $translations[$language] = $translationData;
            }

            return $translations;
        }
    '''

    def private processEntityAfterEditing(Application it) '''
        /**
         * Post-editing method persisting translated fields.
         * This ensures easy compatibility to the Forms plugins where it
         * it is not possible yet to define sub arrays in the group attribute.
         *
         * @param EntityAccess  $entity        The entity being edited
         * @param FormInterface $form          Form containing translations
         * @param EntityManager $entityManager Entity manager
         */
        public function processEntityAfterEditing($entity, $form, $entityManager)
        {
            $objectType = $entity->get_objectType();
            $entityTransClass = '\\«vendor.formatForCodeCapital»\\«name.formatForCodeCapital»Module\\Entity\\' . ucfirst($objectType) . 'TranslationEntity';
            $repository = $entityManager->getRepository($entityTransClass);

            $supportedLanguages = $this->getSupportedLanguages($objectType);
            foreach ($supportedLanguages as $language) {
                if (!isset($form['translations' . $language])) {
                    continue;
                }
                $translatedFields = $form['translations' . $language];
                foreach ($translatedFields as $fieldName => $formField) {
                    if (!$formField->getData()) {
                        // avoid persisting unrequired translations
                        continue;
                    }
                    $repository->translate($entity, $fieldName, $language, $formField->getData());
                }
            }
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
