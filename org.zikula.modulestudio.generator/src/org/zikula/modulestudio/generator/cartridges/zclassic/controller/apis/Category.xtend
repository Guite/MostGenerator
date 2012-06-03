package org.zikula.modulestudio.generator.cartridges.zclassic.controller.apis

import com.google.inject.Inject
import de.guite.modulestudio.metamodel.modulestudio.Application
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class Category {
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
         * @param string $args['ot'] The object type to be treated (optional)
         *
         * @return mixed Category array on success, false on failure
         */
        public function getMainCat($args)
        {
            $objectType = $this->determineObjectType($args, 'getMainCat');

            return CategoryRegistryUtil::getRegisteredModuleCategory('«appName»', ucwords($objectType), 'Main', 32); // 32 == /__System/Modules/Global
        }

        /**
         * Determine object type using controller util methods.
         *
         * @param string $args['ot'] The object type to retrieve (optional)
         * @param string $methodName Name of calling method
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
