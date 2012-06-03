package org.zikula.modulestudio.generator.cartridges.zclassic.controller.util

import com.google.inject.Inject
import de.guite.modulestudio.metamodel.modulestudio.Application
import de.guite.modulestudio.metamodel.modulestudio.Entity
import de.guite.modulestudio.metamodel.modulestudio.EntityField
import de.guite.modulestudio.metamodel.modulestudio.BooleanField
import de.guite.modulestudio.metamodel.modulestudio.AbstractIntegerField
import de.guite.modulestudio.metamodel.modulestudio.DecimalField
import de.guite.modulestudio.metamodel.modulestudio.FloatField
import de.guite.modulestudio.metamodel.modulestudio.UploadField
import de.guite.modulestudio.metamodel.modulestudio.ArrayField
import de.guite.modulestudio.metamodel.modulestudio.ObjectField
import de.guite.modulestudio.metamodel.modulestudio.DerivedField
import de.guite.modulestudio.metamodel.modulestudio.CalculatedField
import de.guite.modulestudio.metamodel.modulestudio.AbstractDateField
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class Translatable {
    @Inject extension FormattingExtensions = new FormattingExtensions()
    @Inject extension ModelBehaviourExtensions = new ModelBehaviourExtensions()
    @Inject extension NamingExtensions = new NamingExtensions()
    @Inject extension Utils = new Utils()

    FileHelper fh = new FileHelper()

    /**
     * Entry point for the Util class creation.
     */
    def generate(Application it, IFileSystemAccess fsa) {
        println('Generating utility class for translatable entities')
    	val utilPath = appName.getAppSourceLibPath + 'Util/'
        fsa.generateFile(utilPath + 'Base/Translatable.php', translatableFunctionsBaseFile)
        fsa.generateFile(utilPath + 'Translatable.php', translatableFunctionsFile)
    }

    def private translatableFunctionsBaseFile(Application it) '''
    	«fh.phpFileHeader(it)»
    	«translatableFunctionsBaseImpl»
    '''

    def private translatableFunctionsFile(Application it) '''
    	«fh.phpFileHeader(it)»
    	«translatableFunctionsImpl»
    '''

    def private translatableFunctionsBaseImpl(Application it) '''
        /**
         * Utility base class for translatable helper methods.
         */
        class «appName»_«fillingUtil»Base_Translatable extends Zikula_AbstractBase
        {
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
                $dom = ZLanguage::getModuleDomain('«appName»');
                $fields = array();
                switch ($objectType) {
                    «FOR entity : getTranslatableEntities»
                        «entity.translatableFieldList»
                    «ENDFOR»
                }
                return $fields;
            }

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
                $translations = array();

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
                $serviceManager = ServiceUtil::getManager();
                $entityManager = $serviceManager->getService('doctrine.entitymanager');

                // get translations
                $repository = $entityManager->getRepository('«appName»_Entity_' . ucwords($objectType) . 'Translation');
                $entityTranslations = $repository->findTranslations($entity);

                $supportedLocales = ZLanguage::getInstalledLanguages();
                $currentLanguage = ZLanguage::getLanguageCode();
                foreach ($supportedLocales as $locale) {
                    if ($locale == $currentLanguage) {
                        // Translatable extension did already fetch current translation
                        continue;
                    }
                    $translationData = array();
                    foreach ($fields as $field) {
                        $translationData[$field['name'] . $locale] = isset($entityTranslations[$locale]) ? $entityTranslations[$locale][$field['name']] : '';
                    }
                    // add data to collected translations
                    $translations[$locale] = $translationData;
                }

                return $translations;
            }

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
                $translations = array();
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
                        $translations[$locale] = array('locale' => $locale, 'fields' => array());
                        $translationData = $formData[strtolower($objectType) . $locale];
                        foreach ($fields as $field) {
                            $translations[$locale]['fields'][$field['name']] = isset($translationData[$field['name'] . $locale]) ? $translationData[$field['name'] . $locale] : '';
                            unset($formData[$field['name'] . $locale]);
                        }
                    }
                }
                if ($useOnlyCurrentLocale === true) {
                    $locale = ZLanguage::getLanguageCode();
                    $translations[$locale] = array('locale' => $locale, 'fields' => array());
                    $translationData = $formData[strtolower($objectType) . $locale];
                    foreach ($fields as $field) {
                        $translations[$locale]['fields'][$field['name']] = isset($translationData[$field['name'] . $locale]) ? $translationData[$field['name'] . $locale] : '';
                        unset($formData[$field['name'] . $locale]);
                    }
                }
                return $translations;
            }
        }
    '''

    def private translatableFieldList(Entity it) '''
            case '«name.formatForCode»':
                $fields = array(
                    «translatableFieldDefinition»
                );
                break;
    '''

    def translatableFieldDefinition(Entity it) '''
        «FOR field : getTranslatableFields SEPARATOR ','»«field.translatableFieldDefinition»«ENDFOR»
«/*no slug input element yet, see https://github.com/l3pp4rd/DoctrineExtensions/issues/140
«IF hasTranslatableSlug»,
                    array('name' => 'slug',
                          'default' => '')
«ENDIF»*/»
    '''

    def private translatableFieldDefinition(EntityField it) {
        switch it {
            BooleanField: '''
                    array('name' => '«name»',
                          'default' => «IF it.defaultValue != null && it.defaultValue != ''»«(it.defaultValue == 'true').displayBool»«ELSE»false«ENDIF»)'''
            AbstractIntegerField: translatableFieldDefinitionNumeric
            DecimalField: translatableFieldDefinitionNumeric
            FloatField: translatableFieldDefinitionNumeric
            UploadField: translatableFieldDefinitionNoDefault
            ArrayField: translatableFieldDefinitionNoDefault
            ObjectField: translatableFieldDefinitionNoDefault
            AbstractDateField: '''
                    array('name' => '«name»',
                          'default' => '«IF it.defaultValue != null && it.defaultValue != ''»«it.defaultValue»«ENDIF»')'''
            DerivedField: '''
                    array('name' => '«name»',
                          'default' => __('«IF it.defaultValue != null && it.defaultValue != ''»«it.defaultValue»«ELSE»«name.formatForDisplayCapital»«ENDIF»', $dom))'''
            CalculatedField: '''
                    array('name'    => '«name»',
                          'default' => __('«name.formatForDisplayCapital»', $dom))'''
        }
    }

    def private translatableFieldDefinitionNumeric(DerivedField it) '''
                    array('name' => '«name»',
                          'default' => 0)'''

    def private translatableFieldDefinitionNoDefault(DerivedField it) '''
                    array('name' => '«name»',
                          'default' => '')'''

    def private translatableFunctionsImpl(Application it) '''
        /**
         * Utility implementation class for translatable helper methods.
         */
        class «appName»_«fillingUtil»Translatable extends «appName»_«fillingUtil»Base_Translatable
        {
            // feel free to add your own convenience methods here
        }
    '''
}
