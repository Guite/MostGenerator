package org.zikula.modulestudio.generator.cartridges.zclassic.controller.apis

import de.guite.modulestudio.metamodel.Application
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper
import org.zikula.modulestudio.generator.extensions.ControllerExtensions
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class Account {
    extension ControllerExtensions = new ControllerExtensions
    extension FormattingExtensions = new FormattingExtensions
    extension ModelExtensions = new ModelExtensions
    extension NamingExtensions = new NamingExtensions
    extension Utils = new Utils

    FileHelper fh = new FileHelper

    def generate(Application it, IFileSystemAccess fsa) {
        generateClassPair(fsa, getAppSourceLibPath + 'Api/Account' + (if (targets('1.3.x')) '' else 'Api') + '.php',
            fh.phpFileContent(it, accountApiBaseClass), fh.phpFileContent(it, accountApiImpl)
        )
    }

    def private accountApiBaseClass(Application it) '''
        «IF !targets('1.3.x')»
            namespace «appNamespace»\Api\Base;

            use ModUtil;
            use ServiceUtil;
            use UserUtil;
            use Zikula_AbstractBase;

        «ENDIF»
        /**
         * Account api base class.
         */
        class «IF targets('1.3.x')»«appName»_Api_Base_Account extends Zikula_AbstractApi«ELSE»AccountApi extends Zikula_AbstractBase«ENDIF»
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

            «IF targets('1.3.x')»
                $useAccountPage = $this->getVar('useAccountPage', true);
            «ELSE»
                $useAccountPage = $this->get('zikula_extensions_module.api.variable')->get('«appName»', 'useAccountPage', true);
            «ENDIF»
            if ($useAccountPage === false) {
                return $items;
            }

            $userName = (isset($args['uname'])) ? $args['uname'] : UserUtil::getVar('uname');
            // does this user exist?
            if (UserUtil::getIdFromName($userName) === false) {
                // user does not exist
                return $items;
            }

            «IF !targets('1.3.x')»
                $permissionHelper = $this->get('zikula_permissions_module.api.permission');
            «ENDIF»
            if (!«IF targets('1.3.x')»SecurityUtil::check«ELSE»$permissionHelper->has«ENDIF»Permission($this->name . '::', '::', ACCESS_OVERVIEW)) {
                return $items;
            }

            // Create an array of links to return
            «IF !getAllUserControllers.empty && getMainUserController.hasActions('view')»
                «FOR entity : getAllEntities.filter[standardFields && ownerPermission]»
                    $objectType = '«entity.name.formatForCode»';
                    if («IF targets('1.3.x')»SecurityUtil::check«ELSE»$permissionHelper->has«ENDIF»Permission($this->name . ':' . ucfirst($objectType) . ':', '::', ACCESS_READ)) {
                        $items[] = array(
                            «IF targets('1.3.x')»
                                'url' => ModUtil::url($this->name, 'user', 'view', array('ot' => $objectType, 'own' => 1)),
                            «ELSE»
                                'url' => $this->get('router')->generate('«appName.formatForDB»_' . strtolower($objectType) . '_view', array('own' => 1)),
                            «ENDIF»
                            'title'   => $this->__('My «entity.nameMultiple.formatForDisplay»'),
                            'icon'    => 'windowlist.png',
                            'module'  => 'core',
                            'set'     => 'icons/large'
                        );
                    }
                «ENDFOR»
            «ENDIF»
            «IF !getAllAdminControllers.empty»
                if («IF targets('1.3.x')»SecurityUtil::check«ELSE»$permissionHelper->has«ENDIF»Permission($this->name . '::', '::', ACCESS_ADMIN)) {
                    $items[] = array(
                        «IF targets('1.3.x')»
                            'url'   => ModUtil::url($this->name, 'admin', '«IF targets('1.3.x')»main«ELSE»index«ENDIF»'),
                        «ELSE»
                            'url'   => $this->get('router')->generate('«appName.formatForDB»_admin_index'),
                        «ENDIF»
                        'title'  => $this->__('«name.formatForDisplayCapital» Backend'),
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
        «IF !targets('1.3.x')»
            namespace «appNamespace»\Api;

            use «appNamespace»\Api\Base\AccountApi as BaseAccountApi;

        «ENDIF»
        /**
         * Account api implementation class.
         */
        «IF targets('1.3.x')»
        class «appName»_Api_Account extends «appName»_Api_Base_Account
        «ELSE»
        class AccountApi extends BaseAccountApi
        «ENDIF»
        {
            // feel free to extend the account api here
        }
    '''
}
