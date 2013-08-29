package org.zikula.modulestudio.generator.cartridges.zclassic.controller.apis

import com.google.inject.Inject
import de.guite.modulestudio.metamodel.modulestudio.Application
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper
import org.zikula.modulestudio.generator.cartridges.zclassic.view.additions.MailzView
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class Mailz {
    @Inject extension FormattingExtensions = new FormattingExtensions()
    @Inject extension ModelExtensions = new ModelExtensions()
    @Inject extension NamingExtensions = new NamingExtensions()
    @Inject extension Utils = new Utils()

    FileHelper fh = new FileHelper()

    def generate(Application it, IFileSystemAccess fsa) {
        val apiPath = getAppSourceLibPath + 'Api/'
        val apiClassSuffix = if (!targets('1.3.5')) 'Api' else ''
        val apiFileName = 'Mailz' + apiClassSuffix + '.php'
        fsa.generateFile(apiPath + 'Base/' + apiFileName, mailzBaseFile)
        fsa.generateFile(apiPath + apiFileName, mailzFile)
        new MailzView().generate(it, fsa)
    }

    def private mailzBaseFile(Application it) '''
        «fh.phpFileHeader(it)»
        «mailzBaseClass»
    '''

    def private mailzFile(Application it) '''
        «fh.phpFileHeader(it)»
        «mailzImpl»
    '''

    def private mailzBaseClass(Application it) '''
        «IF !targets('1.3.5')»
            namespace «appNamespace»\Api\Base;

            use ModUtil;
            use ServiceUtil;
            use Zikula_AbstractApi;
            use Zikula_View;

        «ENDIF»
        /**
         * Mailz api base class.
         */
        class «IF targets('1.3.5')»«appName»_Api_Base_Mailz«ELSE»MailzApi«ENDIF» extends Zikula_AbstractApi
        {
            «mailzBaseImpl»
        }
    '''

    def private mailzBaseImpl(Application it) '''
        /**
         * Returns existing Mailz plugins with type / title.
         *
         * @param array $args List of arguments.
         *
         * @return array List of provided plugin functions.
         */
        public function getPlugins(array $args = array())
        {
            «val itemDesc = getLeadingEntity.nameMultiple.formatForDisplay»
            $plugins = array();
            $plugins[] = array(
                'pluginid'      => 1,
                'module'        => '«appName»',
                'title'         => $this->__('3 newest «itemDesc»'),
                'description'   => $this->__('A list of the three newest «itemDesc».')
            );
            $plugins[] = array(
                'pluginid'      => 2,
                'module'        => '«appName»',
                'title'         => $this->__('3 random «itemDesc»'),
                'description'   => $this->__('A list of three random «itemDesc».')
            );
            return $plugins;
        }

        /**
         * Returns the content for a given Mailz plugin.
         *
         * @param array    $args                List of arguments.
         * @param int      $args['pluginid']    id number of plugin (internal id for this module, see getPlugins method).
         * @param string   $args['params']      optional, show specific one or all otherwise.
         * @param int      $args['uid']         optional, user id for user specific content.
         * @param string   $args['contenttype'] h or t for html or text.
         * @param datetime $args['last']        timestamp of last newsletter.
         *
         * @return string output of plugin template.
         */
        public function getContent(array $args = array())
        {
            ModUtil::initOOModule('«appName»');
            // $args is something like:
            // Array ( [uid] => 5 [contenttype] => h [pluginid] => 1 [nid] => 1 [last] => 0000-00-00 00:00:00 [params] => Array ( [] => ) ) 1
            «val leadingEntity = getLeadingEntity»
            $objectType = '«leadingEntity.name.formatForCode»';

            «IF targets('1.3.5')»
                $entityClass = '«appName»_Entity_' . ucwords($objectType);
            «ELSE»
                $entityClass = '\\«appNamespace»\\Entity\\' . ucwords($objectType) . 'Entity';
            «ENDIF»
            $serviceManager = ServiceUtil::getManager();
            $entityManager = $serviceManager->getService('doctrine.entitymanager');
            $repository = $entityManager->getRepository($entityClass);

            $idFields = ModUtil::apiFunc('«appName»', 'selection', 'getIdFields', array('ot' => $objectType));

            $sortParam = '';
            if ($args['pluginid'] == 2) {
                $sortParam = 'RAND()';
            } elseif ($args['pluginid'] == 1) {
                if (count($idFields) == 1) {
                    $sortParam = $idFields[0] . ' DESC';
                } else {
                    foreach ($idFields as $idField) {
                        if (!empty($sortParam)) {
                            $sortParam .= ', ';
                        }
                        $sortParam .= $idField . ' ASC';
                    }
                }
            }

            $where = ''/*$this->filter*/;
            $resultsPerPage = 3;

            // get objects from database
            $selectionArgs = array(
                'ot' => $objectType,
                'where' => $where,
                'orderBy' => $sortParam,
                'currentPage' => 1,
                'resultsPerPage' => $resultsPerPage
            );
            list($entities, $objectCount) = ModUtil::apiFunc('«appName»', 'selection', 'getEntitiesPaginated', $selectionArgs);

            $view = Zikula_View::getInstance('«appName»', true);

            //$data = array('sorting' => $this->sorting, 'amount' => $this->amount, 'filter' => $this->filter, 'template' => $this->template);
            //$view->assign('vars', $data);

            $view->assign('objectType', $objectType)
                 ->assign('items', $entities)
                 ->assign($repository->getAdditionalTemplateParameters('api', array('name' => 'mailz')));

            if ($args['contenttype'] == 't') { /* text */
                return $view->fetch('«IF targets('1.3.5')»mailz«ELSE»Mailz«ENDIF»/itemlist_«leadingEntity.name.formatForCode»_text.tpl');
            } else {
                //return $view->fetch('«IF targets('1.3.5')»contenttype«ELSE»ContentType«ENDIF»/itemlist_display.html');
                return $view->fetch('«IF targets('1.3.5')»mailz«ELSE»Mailz«ENDIF»/itemlist_«leadingEntity.name.formatForCode»_html.tpl');
            }
        }
    '''

    def private mailzImpl(Application it) '''
        «IF !targets('1.3.5')»
            namespace «appNamespace»\Api;

        «ENDIF»
        /**
         * Mailz api implementation class.
         */
        «IF targets('1.3.5')»
        class «appName»_Api_Mailz extends «appName»_Api_Base_Mailz
        «ELSE»
        class MailzApi extends Base\MailzApi
        «ENDIF»
        {
            // feel free to extend the mailz api here
        }
    '''
}
