package org.zikula.modulestudio.generator.cartridges.zclassic.controller.util

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
     * Entry point for the utility class creation.
     */
    def generate(Application it, IFileSystemAccess fsa) {
        println('Generating utility class for translatable entities')
        val helperFolder = if (targets('1.3.x')) 'Util' else 'Helper'
        generateClassPair(fsa, getAppSourceLibPath + helperFolder + '/Translatable' + (if (targets('1.3.x')) '' else 'Helper') + '.php',
            fh.phpFileContent(it, translatableFunctionsBaseImpl), fh.phpFileContent(it, translatableFunctionsImpl)
        )
    }

    def private translatableFunctionsBaseImpl(Application it) '''
        «IF !targets('1.3.x')»
            namespace «appNamespace»\Helper\Base;

            use ServiceUtil;
            use System;
            use Symfony\Component\DependencyInjection\ContainerBuilder;
            use Zikula_ServiceManager;
            use ZLanguage;

        «ENDIF»
        /**
         * Utility base class for translatable helper methods.
         */
        class «IF targets('1.3.x')»«appName»_Util_Base_Translatable extends Zikula_AbstractBase«ELSE»TranslatableHelper«ENDIF»
        {
            «IF !targets('1.3.x')»
                /**
                 * @var ContainerBuilder
                 */
                private $container;

                /**
                 * Constructor.
                 * Initialises member vars.
                 *
                 * @param \Zikula_ServiceManager $serviceManager ServiceManager instance.
                 */
                public function __construct(\Zikula_ServiceManager $serviceManager)
                {
                    $this->container = $serviceManager;
                }

            «ENDIF»
            «getTranslatableFieldsImpl»

            «prepareEntityForEdit»

            «processEntityAfterEdit»
        }
    '''

    def private getTranslatableFieldsImpl(Application it) '''
        /**
         * Return list of translatable fields per entity.
         * These are required to be determined to recognize
         * that they have to be selected from according translation tables.
         *
         * @param string $objectType The currently treated object type.
         *
         * @return array list of translatable fields
         */
        public function getTranslatableFields($objectType)
        {
            $fields = «IF targets('1.3.x')»array()«ELSE»[]«ENDIF»;
            switch ($objectType) {
                «FOR entity : getTranslatableEntities»
                    «entity.translatableFieldList»
                «ENDFOR»
            }

            return $fields;
        }
    '''

    def private prepareEntityForEdit(Application it) '''
        /**
         * Post-processing method copying all translations to corresponding arrays.
         * This ensures easy compatibility to the Forms plugins where it
         * it is not possible yet to define sub arrays in the group attribute.
         *
         * @param string              $objectType The currently treated object type.
         * @param Zikula_EntityAccess $entity     The entity being edited.
         *
         * @return array collected translations having the locales as keys
         */
        public function prepareEntityForEdit($objectType, $entity)
        {
            $translations = «IF targets('1.3.x')»array()«ELSE»[]«ENDIF»;

            // check arguments
            if (!$objectType || !$entity) {
                return $translations;
            }

            // check if we have translated fields registered for the given object type
            $fields = $this->getTranslatableFields($objectType);
            if (!count($fields)) {
                return $translations;
            }

            if (System::getVar('multilingual') != 1) {
                // Translatable extension did already fetch current translation
                return $translations;
            }

            // prepare form data to edit multiple translations at once
            «IF targets('1.3.x')»
                $entityManager = $this->serviceManager->get«IF targets('1.3.x')»Service«ENDIF»('doctrine.entitymanager');
            «ENDIF»

            // get translations
            «IF targets('1.3.x')»
                $entityClass = '«appName»_Entity_' . ucfirst($objectType) . 'Translation';
                $repository = $entityManager->getRepository($entityClass);
            «ELSE»
                $repository = $this->container->get('«appName.formatForDB».' . $objectType . '_factory')->getRepository();
            «ENDIF»
            $entityTranslations = $repository->findTranslations($entity);

            $supportedLocales = ZLanguage::getInstalledLanguages();
            $currentLanguage = ZLanguage::getLanguageCode();
            foreach ($supportedLocales as $locale) {
                if ($locale == $currentLanguage) {
                    // Translatable extension did already fetch current translation
                    continue;
                }
                $translationData = «IF targets('1.3.x')»array()«ELSE»[]«ENDIF»;
                foreach ($fields as $field) {
                    $translationData[$field['name'] . $locale] = isset($entityTranslations[$locale]) ? $entityTranslations[$locale][$field['name']] : '';
                }
                // add data to collected translations
                $translations[$locale] = $translationData;
            }

            return $translations;
        }
    '''

    def private processEntityAfterEdit(Application it) '''
        /**
         * Post-editing method copying all translated fields back to their subarrays.
         * This ensures easy compatibility to the Forms plugins where it
         * it is not possible yet to define sub arrays in the group attribute.
         *
         * @param string $objectType The currently treated object type.
         * @param array  $formData   Form data containing translations.
         *
         * @return array collected translations having the locales as keys
         */
        public function processEntityAfterEdit($objectType, $formData)
        {
            $translations = «IF targets('1.3.x')»array()«ELSE»[]«ENDIF»;
            // check arguments
            if (!$objectType || !is_array($formData)) {
                return $translations;
            }

            $fields = $this->getTranslatableFields($objectType);
            if (!count($fields)) {
                return $translations;
            }

            $supportedLocales = ZLanguage::getInstalledLanguages();
            $useOnlyCurrentLocale = true;
            if (System::getVar('multilingual') == 1) {
                $useOnlyCurrentLocale = false;
                $currentLanguage = ZLanguage::getLanguageCode();
                foreach ($supportedLocales as $locale) {
                    if ($locale == $currentLanguage) {
                        // skip current language as this is not treated as translation on controller level
                        continue;
                    }
                    $translations[$locale] = «IF targets('1.3.x')»array(«ELSE»[«ENDIF»'locale' => $locale, 'fields' => «IF targets('1.3.x')»array())«ELSE»[]]«ENDIF»;
                    $translationData = $formData[strtolower($objectType) . $locale];
                    foreach ($fields as $field) {
                        $translations[$locale]['fields'][$field['name']] = isset($translationData[$field['name'] . $locale]) ? $translationData[$field['name'] . $locale] : '';
                        unset($formData[$field['name'] . $locale]);
                    }
                }
            }
            if ($useOnlyCurrentLocale === true) {
                $locale = ZLanguage::getLanguageCode();
                $translations[$locale] = «IF targets('1.3.x')»array(«ELSE»[«ENDIF»'locale' => $locale, 'fields' => «IF targets('1.3.x')»array())«ELSE»[]]«ENDIF»;
                $translationData = $formData[strtolower($objectType) . $locale];
                foreach ($fields as $field) {
                    $translations[$locale]['fields'][$field['name']] = isset($translationData[$field['name'] . $locale]) ? $translationData[$field['name'] . $locale] : '';
                    unset($formData[$field['name'] . $locale]);
                }
            }

            return $translations;
        }
    '''

    def private translatableFieldList(Entity it) '''
            case '«name.formatForCode»':
                $fields = «IF application.targets('1.3.x')»array(«ELSE»[«ENDIF»
                    «translatableFieldDefinition»
                «IF application.targets('1.3.x')»)«ELSE»]«ENDIF»;
                break;
    '''

    def private translatableFieldDefinition(Entity it) '''
        «FOR field : getTranslatableFields SEPARATOR ','»«field.translatableFieldDefinition»«ENDFOR»
«/* TODO no slug input element yet, see https://github.com/Atlantic18/DoctrineExtensions/issues/140
«IF hasTranslatableSlug»,
                    «IF application.targets('1.3.x')»array(«ELSE»[«ENDIF»
                        'name' => 'slug',
                        'default' => ''
                    «IF application.targets('1.3.x')»)«ELSE»]«ENDIF»
«ENDIF»*/»
    '''

    def private translatableFieldDefinition(EntityField it) {
        switch it {
            BooleanField: '''
                    «IF entity.application.targets('1.3.x')»array(«ELSE»[«ENDIF»
                        'name' => '«name»',
                        'default' => «IF it.defaultValue !== null && it.defaultValue != ''»«(it.defaultValue == 'true').displayBool»«ELSE»false«ENDIF»
                    «IF entity.application.targets('1.3.x')»)«ELSE»]«ENDIF»'''
            AbstractIntegerField: translatableFieldDefinitionNumeric
            DecimalField: translatableFieldDefinitionNumeric
            FloatField: translatableFieldDefinitionNumeric
            UploadField: translatableFieldDefinitionNoDefault
            ArrayField: translatableFieldDefinitionNoDefault
            ObjectField: translatableFieldDefinitionNoDefault
            AbstractDateField: '''
                    «IF entity.application.targets('1.3.x')»array(«ELSE»[«ENDIF»
                        'name' => '«name»',
                        'default' => '«IF it.defaultValue !== null && it.defaultValue != ''»«it.defaultValue»«ENDIF»'
                    «IF entity.application.targets('1.3.x')»)«ELSE»]«ENDIF»'''
            DerivedField: '''
                    «IF entity.application.targets('1.3.x')»array(«ELSE»[«ENDIF»
                        'name' => '«name»',
                        'default' => $this->__('«IF it.defaultValue !== null && it.defaultValue != ''»«it.defaultValue»«ELSE»«name.formatForDisplayCapital»«ENDIF»')
                    «IF entity.application.targets('1.3.x')»)«ELSE»]«ENDIF»'''
            CalculatedField: '''
                    «IF entity.application.targets('1.3.x')»array(«ELSE»[«ENDIF»
                        'name' => '«name»',
                        'default' => $this->__('«name.formatForDisplayCapital»')
                    «IF entity.application.targets('1.3.x')»)«ELSE»]«ENDIF»'''
        }
    }

    def private translatableFieldDefinitionNumeric(DerivedField it) '''
                    «IF entity.application.targets('1.3.x')»array(«ELSE»[«ENDIF»
                        'name' => '«name»',
                        'default' => 0
                    «IF entity.application.targets('1.3.x')»)«ELSE»]«ENDIF»'''

    def private translatableFieldDefinitionNoDefault(DerivedField it) '''
                    «IF entity.application.targets('1.3.x')»array(«ELSE»[«ENDIF»
                        'name' => '«name»',
                        'default' => ''
                    «IF entity.application.targets('1.3.x')»)«ELSE»]«ENDIF»'''

    def private translatableFunctionsImpl(Application it) '''
        «IF !targets('1.3.x')»
            namespace «appNamespace»\Helper;

            use «appNamespace»\Helper\Base\TranslatableHelper as BaseTranslatableHelper;

        «ENDIF»
        /**
         * Utility implementation class for translatable helper methods.
         */
        «IF targets('1.3.x')»
        class «appName»_Util_Translatable extends «appName»_Util_Base_Translatable
        «ELSE»
        class TranslatableHelper extends BaseTranslatableHelper
        «ENDIF»
        {
            // feel free to add your own convenience methods here
        }
    '''
}
