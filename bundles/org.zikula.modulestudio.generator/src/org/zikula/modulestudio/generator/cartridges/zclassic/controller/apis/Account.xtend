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

    // 1.3.x only
    def generate(Application it, IFileSystemAccess fsa) {
        if (!targets('1.3.x')) {
            return
        }
        println('Generating account api')
        generateClassPair(fsa, getAppSourceLibPath + 'Api/Account.php',
            fh.phpFileContent(it, accountApiBaseClass), fh.phpFileContent(it, accountApiImpl)
        )
    }

    def private accountApiBaseClass(Application it) '''
        /**
         * Account api base class.
         */
        abstract class «appName»_Api_Base_AbstractAccount extends Zikula_AbstractApi
        {
            «accountApiBaseImpl»
        }
    '''

    def private accountApiBaseImpl(Application it) '''
        /**
         * Return an array of items to show in the your account panel.
         *
         * @param array $args List of arguments
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

            $userName = (isset($args['uname'])) ? $args['uname'] : UserUtil::getVar('uname');
            // does this user exist?
            if (UserUtil::getIdFromName($userName) === false) {
                // user does not exist
                return $items;
            }

            if (!SecurityUtil::checkPermission($this->name . '::', '::', ACCESS_OVERVIEW)) {
                return $items;
            }

            // Create an array of links to return
            «IF !getAllUserControllers.empty && getMainUserController.hasActions('view')»
                «FOR entity : getAllEntities.filter[standardFields && ownerPermission]»
                    $objectType = '«entity.name.formatForCode»';
                    if (SecurityUtil::checkPermission($this->name . ':' . ucfirst($objectType) . ':', '::', ACCESS_READ)) {
                        $items[] = array(
                            'url' => ModUtil::url($this->name, 'user', 'view', array('ot' => $objectType, 'own' => 1)),
                            'title'   => $this->__('My «entity.nameMultiple.formatForDisplay»'),
                            'icon'    => 'windowlist.png',
                            'module'  => 'core',
                            'set'     => 'icons/large'
                        );
                    }
                «ENDFOR»
            «ENDIF»
            «IF !getAllAdminControllers.empty»
                if (SecurityUtil::checkPermission($this->name . '::', '::', ACCESS_ADMIN)) {
                    $items[] = array(
                        'url'   => ModUtil::url($this->name, 'admin', 'main'),
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
        /**
         * Account api implementation class.
         */
        class «appName»_Api_Account extends «appName»_Api_Base_AbstractAccount
        {
            // feel free to extend the account api here
        }
    '''
}
