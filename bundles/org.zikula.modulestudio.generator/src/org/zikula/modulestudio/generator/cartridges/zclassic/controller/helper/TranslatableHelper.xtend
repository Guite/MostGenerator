package org.zikula.modulestudio.generator.cartridges.zclassic.controller.helper

import de.guite.modulestudio.metamodel.AbstractDateField
import de.guite.modulestudio.metamodel.AbstractIntegerField
import de.guite.modulestudio.metamodel.Application
import de.guite.modulestudio.metamodel.ArrayField
import de.guite.modulestudio.metamodel.BooleanField
import de.guite.modulestudio.metamodel.CalculatedField
import de.guite.modulestudio.metamodel.DecimalField
import de.guite.modulestudio.metamodel.DerivedField
import de.guite.modulestudio.metamodel.Entity
import de.guite.modulestudio.metamodel.EntityField
import de.guite.modulestudio.metamodel.FloatField
import de.guite.modulestudio.metamodel.ObjectField
import de.guite.modulestudio.metamodel.UploadField
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

    FileHelper fh = new FileHelper

    /**
     * Entry point for the helper class creation.
     */
    def generate(Application it, IFileSystemAccess fsa) {
        println('Generating helper class for translatable entities')
        generateClassPair(fsa, getAppSourceLibPath + 'Helper/TranslatableHelper.php',
            fh.phpFileContent(it, translatableFunctionsBaseImpl), fh.phpFileContent(it, translatableFunctionsImpl)
        )
    }

    def private translatableFunctionsBaseImpl(Application it) '''
        namespace «appNamespace»\Helper\Base;

        use Symfony\Component\DependencyInjection\ContainerBuilder;
        use Symfony\Component\Form\FormInterface;
        use Symfony\Component\HttpFoundation\Request;
        use Symfony\Component\HttpFoundation\RequestStack;
        use Zikula\Common\Translator\TranslatorInterface;
        use Zikula\Core\Doctrine\EntityAccess;
        use Zikula\ExtensionsModule\Api\VariableApi;
        use ZLanguage;

        /**
         * Helper base class for translatable methods.
         */
        abstract class AbstractTranslatableHelper
        {
            /**
             * @var ContainerBuilder
             */
            protected $container;

            /**
             * @var TranslatorInterface
             */
            protected $translator;

            /**
             * @var Request
             */
            protected $request;

            /**
             * @var VariableApi
             */
            protected $variableApi;

            /**
             * TranslatableHelper constructor.
             *
             * @param ContainerBuilder    $container    ContainerBuilder service instance
             * @param TranslatorInterface $translator   Translator service instance
             * @param RequestStack        $requestStack RequestStack service instance
             * @param VariableApi         $variableApi  VariableApi service instance
             */
            public function __construct(ContainerBuilder $container, TranslatorInterface $translator, RequestStack $requestStack, VariableApi $variableApi)
            {
                $this->container = $container;
                $this->translator = $translator;
                $this->request = $requestStack->getMasterRequest();
                $this->variableApi = $variableApi;
            }

            «getTranslatableFieldsImpl»

            «getCurrentLanguage»

            «getSupportedLanguages»

            «prepareEntityForEditing»

            «processEntityAfterEditing»
        }
    '''

    def private getTranslatableFieldsImpl(Application it) '''
        /**
         * Return list of translatable fields per entity.
         * These are required to be determined to recognize
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
                return ZLanguage::getInstalledLanguages();
            }

            // if multi language is disabled use only the current language
            return [$this->getCurrentLanguage()];
        }
    '''

    def private prepareEntityForEditing(Application it) '''
        /**
         * Post-processing method copying all translations to corresponding arrays.
         * This ensures easy compatibility to the Forms plugins where it
         * it is not possible yet to define sub arrays in the group attribute.
         *
         * @param string       $objectType The currently treated object type
         * @param EntityAccess $entity     The entity being edited
         *
         * @return array collected translations having the language codes as keys
         */
        public function prepareEntityForEditing($objectType, $entity)
        {
            $translations = [];

            // check arguments
            if (!$objectType || !$entity) {
                return $translations;
            }

            // check if we have translated fields registered for the given object type
            $fields = $this->getTranslatableFields($objectType);
            if (!count($fields)) {
                return $translations;
            }

            if ($this->variableApi->getSystemVar('multilingual') != 1) {
                // Translatable extension did already fetch current translation
                return $translations;
            }

            // prepare form data to edit multiple translations at once

            // get translations
            $repository = $this->container->get('«appService».' . $objectType . '_factory')->getRepository();
            $entityTranslations = $repository->findTranslations($entity);

            $supportedLanguages = $this->getSupportedLanguages($objectType);
            $currentLanguage = $this->getCurrentLanguage();
            foreach ($supportedLanguages as $language) {
                if ($language == $currentLanguage) {
                    // Translatable extension did already fetch current translation
                    continue;
                }
                $translationData = [];
                foreach ($fields as $field) {
                    $translationData[$field['name'] . $language] = isset($entityTranslations[$language]) ? $entityTranslations[$language][$field['name']] : $field['default'];
                }
                // add data to collected translations
                $translations[$language] = $translationData;
            }

            return $translations;
        }
    '''

    def private processEntityAfterEditing(Application it) '''
        /**
         * Post-editing method copying all translated fields back to their subarrays.
         * This ensures easy compatibility to the Forms plugins where it
         * it is not possible yet to define sub arrays in the group attribute.
         *
         * @param string        $objectType The currently treated object type
         * @param EntityAccess  $entity     The entity being edited
         * @param FormInterface $form       Form containing translations
         *
         * @return array collected translations having the language codes as keys
         */
        public function processEntityAfterEditing($objectType, $entity, $form)
        {
            $translations = [];
            // check arguments
            if (!$objectType) {
                return $translations;
            }

            $fields = $this->getTranslatableFields($objectType);
            if (!count($fields)) {
                return $translations;
            }

            $useOnlyCurrentLanguage = true;
            if ($this->variableApi->getSystemVar('multilingual') == 1) {
                $useOnlyCurrentLanguage = false;
                $supportedLanguages = $this->getSupportedLanguages($objectType);
                $currentLanguage = $this->getCurrentLanguage();
                foreach ($supportedLanguages as $language) {
                    if ($language == $currentLanguage) {
                        // skip current language as this is not treated as translation on controller level
                        continue;
                    }
                    $translations[$language] = [];
                    $translationKey = strtolower($objectType) . $language;
                    $translationData = isset($form[$translationKey]) && $form[$translationKey]->getData();
                    foreach ($fields as $field) {
                        $translations[$language][$field['name']] = isset($translationData[$field['name'] . $language]) ? $translationData[$field['name'] . $language] : '';
                        unset($formData[$field['name'] . $language]);
                    }
                }
            }
            if (true === $useOnlyCurrentLanguage) {
                $language = $this->getCurrentLanguage();
                $translations[$language] = [];
                foreach ($fields as $field) {
                    $translations[$language][$field['name']] = isset($entity[$field['name']]) ? $entity[$field['name']] : '';
                }
            }

            return $translations;
        }
    '''

    def private translatableFieldList(Entity it) '''
            case '«name.formatForCode»':
                $fields = [
                    «translatableFieldDefinition»
                ];
                break;
    '''

    def private translatableFieldDefinition(Entity it) '''
        «FOR field : getTranslatableFields SEPARATOR ','»«field.translatableFieldDefinition»«ENDFOR»
«/* TODO no slug input element yet, see https://github.com/Atlantic18/DoctrineExtensions/issues/140
«IF hasTranslatableSlug»,
                    [
                        'name' => 'slug',
                        'default' => ''
                    ]
«ENDIF»*/»
    '''

    def private translatableFieldDefinition(EntityField it) {
        switch it {
            BooleanField: '''
                    [
                        'name' => '«name»',
                        'default' => «IF null !== it.defaultValue && it.defaultValue != ''»«(it.defaultValue == 'true').displayBool»«ELSE»false«ENDIF»
                    ]'''
            AbstractIntegerField: translatableFieldDefinitionNumeric
            DecimalField: translatableFieldDefinitionNumeric
            FloatField: translatableFieldDefinitionNumeric
            UploadField: translatableFieldDefinitionNoDefault
            ArrayField: translatableFieldDefinitionNoDefault
            ObjectField: translatableFieldDefinitionNoDefault
            AbstractDateField: '''
                    [
                        'name' => '«name»',
                        'default' => '«IF null !== it.defaultValue && it.defaultValue != ''»«it.defaultValue»«ENDIF»'
                    ]'''
            DerivedField: '''
                    [
                        'name' => '«name»',
                        'default' => $this->translator->__('«IF null !== it.defaultValue && it.defaultValue != ''»«it.defaultValue»«ELSE»«name.formatForDisplayCapital»«ENDIF»')
                    ]'''
            CalculatedField: '''
                    [
                        'name' => '«name»',
                        'default' => $this->translator->__('«name.formatForDisplayCapital»')
                    ]'''
        }
    }

    def private translatableFieldDefinitionNumeric(DerivedField it) '''
                    [
                        'name' => '«name»',
                        'default' => 0
                    ]'''

    def private translatableFieldDefinitionNoDefault(DerivedField it) '''
                    [
                        'name' => '«name»',
                        'default' => ''
                    ]'''

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
