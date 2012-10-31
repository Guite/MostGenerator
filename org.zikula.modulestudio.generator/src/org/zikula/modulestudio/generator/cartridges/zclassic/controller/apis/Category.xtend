package org.zikula.modulestudio.generator.cartridges.zclassic.controller.apis

import com.google.inject.Inject
import de.guite.modulestudio.metamodel.modulestudio.Application
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class Category {
    @Inject extension FormattingExtensions = new FormattingExtensions()
    @Inject extension ModelBehaviourExtensions = new ModelBehaviourExtensions()
    @Inject extension NamingExtensions = new NamingExtensions()
    @Inject extension Utils = new Utils()

    FileHelper fh = new FileHelper()

    def generate(Application it, IFileSystemAccess fsa) {
        println('Generating category api')
        val apiPath = appName.getAppSourceLibPath + 'Api/'
        fsa.generateFile(apiPath + 'Base/Category.php', categoryBaseFile)
        fsa.generateFile(apiPath + 'Category.php', categoryFile)
    }

    def private categoryBaseFile(Application it) '''
    	«fh.phpFileHeader(it)»
    	«categoryBaseClass»
	'''

    def private categoryFile(Application it) '''
    	«fh.phpFileHeader(it)»
    	«categoryImpl»
    '''

    def private categoryBaseClass(Application it) '''
		/**
		 * Category api base class.
		 */
		class «appName»_«fillingApi»Base_Category extends Zikula_AbstractApi
		{
		    «categoryBaseImpl»
		}
    '''

    def private categoryBaseImpl(Application it) '''
        /**
         * Retrieves the main/default category of «appName».
         *
         * @param string $args['ot']       The object type to be treated (optional)
         * @param string $args['registry'] Name of category registry to be used (optional)
         *
         * @return mixed Category array on success, false on failure
         */
        public function getMainCat($args)
        {
            if (isset($args['registry'])) {
                $args['registry'] = 'Main';
            }

            $objectType = $this->determineObjectType($args, 'getMainCat');

            return CategoryRegistryUtil::getRegisteredModuleCategory('«appName»', ucwords($objectType), $args['registry'], 32); // 32 == /__System/Modules/Global
        }

        /**
         * Defines whether multiple selection is enabled for a given object type
         * or not. Subclass can override this method to apply a custom behaviour
         * to certain category registries for example.
         *
         * @param string $args['ot'] The object type to be treated (optional)
         * @param string $args['registry'] Name of category registry to be used (optional)
         *
         * @return boolean true if multiple selection is allowed, else false
         */
        public function hasMultipleSelection($args)
        {
            if (isset($args['registry'])) {
                // default to the primary registry
                $args['registry'] = 'Main';
            }

            $objectType = $this->determineObjectType($args, 'hasMultipleSelection');

            // we make no difference between different category registries here
            // if you need a custom behaviour you should override this method

            $result = false;
            switch ($objectType) {
                «FOR entity : getCategorisableEntities»
                    case '«entity.name.formatForCode»':
                        $result = «entity.categorisableMultiSelection.displayBool»;
                        break;
                «ENDFOR»
            }

            return $result;
        }

        /**
         * Determine object type using controller util methods.
         *
         * @param string $args['ot'] The object type to retrieve (optional)
         * @param string $methodName Name of calling method
         *
         * @return string name of the determined object type
         */
        protected function determineObjectType($args, $methodName = '')
        {
            $objectType = isset($args['ot']) ? $args['ot'] : '';
            $controllerHelper = new «appName»_Util_Controller($this->serviceManager);
            $utilArgs = array('api' => 'category', 'action' => $methodName);
            if (!in_array($objectType, $controllerHelper->getObjectTypes('api', $utilArgs))) {
                $objectType = $controllerHelper->getDefaultObjectType('api', $utilArgs);
            }
            return $objectType;
        }
    '''

    def private categoryImpl(Application it) '''
        /**
         * Category api implementation class.
         */
        class «appName»_«fillingApi»Category extends «appName»_«fillingApi»Base_Category
        {
            // feel free to extend the category api at this place
        }
    '''
}
