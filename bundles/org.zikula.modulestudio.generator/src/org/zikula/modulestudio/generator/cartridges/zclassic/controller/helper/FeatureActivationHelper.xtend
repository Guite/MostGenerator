package org.zikula.modulestudio.generator.cartridges.zclassic.controller.helper

import de.guite.modulestudio.metamodel.Application
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class FeatureActivationHelper {

    extension FormattingExtensions = new FormattingExtensions
    extension ModelBehaviourExtensions = new ModelBehaviourExtensions
    extension NamingExtensions = new NamingExtensions
    extension Utils = new Utils

    FileHelper fh = new FileHelper

    /**
     * Entry point for the helper class creation.
     */
    def generate(Application it, IFileSystemAccess fsa) {
        println('Generating helper class for dynamic feature enablement')
        generateClassPair(fsa, getAppSourceLibPath + 'Helper/FeatureActivationHelper.php',
            fh.phpFileContent(it, featureEnablementFunctionsBaseImpl), fh.phpFileContent(it, featureEnablementFunctionsImpl)
        )
    }

    def private featureEnablementFunctionsBaseImpl(Application it) '''
        namespace «appNamespace»\Helper\Base;

        /**
         * Helper base class for dynamic feature enablement methods.
         */
        abstract class AbstractFeatureActivationHelper
        {
            «featureConstants»
            «isEnabled»
        }
    '''

    def private featureConstants(Application it) '''
        «IF hasCategorisableEntities»
            /**
             * Categorisation feature
             */
            const CATEGORIES = 'categories';

        «ENDIF»
        «IF hasAttributableEntities»
            /**
             * Attribution feature
             */
            const ATTRIBUTES = 'attributes';

        «ENDIF»
        «IF hasTranslatable»
            /**
             * Translation feature
             */
            const TRANSLATIONS = 'translations';

        «ENDIF»
        «IF hasTrees»
            /**
             * Tree relatives feature
             */
            const TREE_RELATIVES = 'treeRelatives';

        «ENDIF»
    '''

    def private isEnabled(Application it) '''
        /**
         * This method checks whether a certain feature is enabled for a given entity type or not.
         *
         * @param string $feature     Name of requested feature
         * @param string $objectType  Currently treated entity type
         *
         * @return boolean True if the feature is enabled, false otherwise
         */
        public function isEnabled($feature, $objectType)
        {
            «IF hasCategorisableEntities»
                if ($feature == self::CATEGORIES) {
                    $method = 'hasCategories';
                    if (method_exists($this, $method)) {
                        return $this->$method($objectType);
                    }

                    return in_array($objectType, ['«getCategorisableEntities.map[e|e.name.formatForCode].join('\', \'')»']);
                }
            «ENDIF»
            «IF hasAttributableEntities»
                if ($feature == self::ATTRIBUTES) {
                    $method = 'hasAttributes';
                    if (method_exists($this, $method)) {
                        return $this->$method($objectType);
                    }

                    return in_array($objectType, ['«getAttributableEntities.map[e|e.name.formatForCode].join('\', \'')»']);
                }
            «ENDIF»
            «IF hasTranslatable»
                if ($feature == self::TRANSLATIONS) {
                    $method = 'hasTranslations';
                    if (method_exists($this, $method)) {
                        return $this->$method($objectType);
                    }

                    return in_array($objectType, ['«getTranslatableEntities.map[e|e.name.formatForCode].join('\', \'')»']);
                }
            «ENDIF»
            «IF hasTrees»
                if ($feature == self::TREE_RELATIVES) {
                    $method = 'hasTreeRelatives';
                    if (method_exists($this, $method)) {
                        return $this->$method($objectType);
                    }

                    return in_array($objectType, ['«getTreeEntities.map[e|e.name.formatForCode].join('\', \'')»']);
                }
            «ENDIF»

            return false;
        }
    '''

    def private featureEnablementFunctionsImpl(Application it) '''
        namespace «appNamespace»\Helper;

        use «appNamespace»\Helper\Base\AbstractFeatureActivationHelper;

        /**
         * Helper implementation class for dynamic feature enablement methods.
         */
        class FeatureActivationHelper extends AbstractFeatureActivationHelper
        {
            // feel free to add your own convenience methods here
        }
    '''
}
