package org.zikula.modulestudio.generator.cartridges.zclassic.controller.apis

import com.google.inject.Inject
import de.guite.modulestudio.metamodel.modulestudio.Application
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper
import org.zikula.modulestudio.generator.extensions.ControllerExtensions
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class Account {
    @Inject extension ControllerExtensions = new ControllerExtensions()
    @Inject extension FormattingExtensions = new FormattingExtensions()
    @Inject extension ModelExtensions = new ModelExtensions()
    @Inject extension NamingExtensions = new NamingExtensions()
    @Inject extension Utils = new Utils()

    FileHelper fh = new FileHelper()

    def generate(Application it, IFileSystemAccess fsa) {
        val apiPath = getAppSourceLibPath + 'Api/'
        val apiClassSuffix = if (!targets('1.3.5')) 'Api' else ''
        val apiFileName = 'Account' + apiClassSuffix + '.php'
        fsa.generateFile(apiPath + 'Base/' + apiFileName, accountApiBaseFile)
        fsa.generateFile(apiPath + apiFileName, accountApiFile)
    }

    def private accountApiBaseFile(Application it) '''
        «fh.phpFileHeader(it)»
        «accountApiBaseClass»
    '''

    def private accountApiFile(Application it) '''
        «fh.phpFileHeader(it)»
        «accountApiImpl»
    '''

    def private accountApiBaseClass(Application it) '''
        «IF !targets('1.3.5')»
            namespace «appName»\Api\Base;

        «ENDIF»
        /**
         * Account api base class.
         */
        «IF targets('1.3.5')»
        class «appName»_Api_Base_Account extends Zikula_AbstractApi
        «ELSE»
        class AccountApi extends \Zikula_AbstractApi
        «ENDIF»
        {
            «accountApiBaseImpl»
        }
    '''

    def private accountApiBaseImpl(Application it) '''
        /**
         * Return an array of items to show in the your account panel.
         *
         * @param array $args List of arguments.
         *
         * @return array List of collected account items
         */
        public function getall(array $args = array())
        {
            // collect items in an array
            $items = array();

            $useAccountPage = $this->getVar('useAccountPage', true);
            if ($useAccountPage === false) {
                return $items;
            }

            $userName = (isset($args['uname'])) ? $args['uname'] : \UserUtil::getVar('uname');
            // does this user exist?
            if (\UserUtil::getIdFromName($userName) === false) {
                // user does not exist
                return $items;
            }

            if (!\SecurityUtil::checkPermission($this->name . '::', '::', ACCESS_OVERVIEW)) {
                return \LogUtil::registerPermissionError();
            }

            // Create an array of links to return
            «IF !getAllUserControllers.isEmpty && getMainUserController.hasActions('view')»
                «FOR entity : getAllEntities.filter(e|e.standardFields && e.ownerPermission)»
                    $objectType = '«entity.name.formatForCode»';
                    if (\SecurityUtil::checkPermission($this->name . ':' . ucwords($objectType) . ':', '::', ACCESS_READ)) {
                        $items[] = array(
                            'url' => \ModUtil::url($this->name, 'user', 'view', array('ot' => $objectType, 'own' => 1)),
                            'title'   => $this->__('My «entity.nameMultiple.formatForDisplay»'),
                            'icon'    => 'windowlist.png',
                            'module'  => 'core',
                            'set'     => 'icons/large'
                        );
                    }
                «ENDFOR»
            «ENDIF»
            «IF !getAllAdminControllers.isEmpty»
                if (\SecurityUtil::checkPermission($this->name . '::', '::', ACCESS_ADMIN)) {
                    $items[] = array(
                        'url'   => \ModUtil::url($this->name, 'admin', '«IF targets('1.3.5')»main«ELSE»index«ENDIF»'),
                        'title' => $this->__('«name.formatForDisplayCapital» Backend'),
                        'icon'   => 'configure.png',
                        'module' => 'core',
                        'set'    => 'icons/large'
                    );
                }
            «ENDIF»

            // return the items
            return $items;
        }
    '''

    def private accountApiImpl(Application it) '''
        «IF !targets('1.3.5')»
            namespace «appName»\Api;

        «ENDIF»
        /**
         * Account api implementation class.
         */
        «IF targets('1.3.5')»
        class «appName»_Api_Account extends «appName»_Api_Base_Account
        «ELSE»
        class AccountApi extends Base\AccountApi
        «ENDIF»
        {
            // feel free to extend the account api here
        }
    '''
}
