package org.zikula.modulestudio.generator.cartridges.zclassic.controller.helper

import de.guite.modulestudio.metamodel.Application
import org.zikula.modulestudio.generator.application.IMostFileSystemAccess
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class FeatureActivationHelper {

    extension FormattingExtensions = new FormattingExtensions
    extension ModelBehaviourExtensions = new ModelBehaviourExtensions
    extension Utils = new Utils

    /**
     * Entry point for the helper class creation.
     */
    def generate(Application it, IMostFileSystemAccess fsa) {
        'Generating helper class for dynamic feature enablement'.printIfNotTesting(fsa)
        fsa.generateClassPair('Helper/FeatureActivationHelper.php', featureEnablementFunctionsBaseImpl, featureEnablementFunctionsImpl)
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
                if (self::CATEGORIES == $feature) {
                    $method = 'hasCategories';
                    if (method_exists($this, $method)) {
                        return $this->$method($objectType);
                    }

                    return in_array($objectType, ['«getCategorisableEntities.map[name.formatForCode].join('\', \'')»']);
                }
            «ENDIF»
            «IF hasAttributableEntities»
                if (self::ATTRIBUTES == $feature) {
                    $method = 'hasAttributes';
                    if (method_exists($this, $method)) {
                        return $this->$method($objectType);
                    }

                    return in_array($objectType, ['«getAttributableEntities.map[name.formatForCode].join('\', \'')»']);
                }
            «ENDIF»
            «IF hasTranslatable»
                if (self::TRANSLATIONS == $feature) {
                    $method = 'hasTranslations';
                    if (method_exists($this, $method)) {
                        return $this->$method($objectType);
                    }

                    return in_array($objectType, ['«getTranslatableEntities.map[name.formatForCode].join('\', \'')»']);
                }
            «ENDIF»
            «IF hasTrees»
                if (self::TREE_RELATIVES == $feature) {
                    $method = 'hasTreeRelatives';
                    if (method_exists($this, $method)) {
                        return $this->$method($objectType);
                    }

                    return in_array($objectType, ['«getTreeEntities.map[name.formatForCode].join('\', \'')»']);
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
