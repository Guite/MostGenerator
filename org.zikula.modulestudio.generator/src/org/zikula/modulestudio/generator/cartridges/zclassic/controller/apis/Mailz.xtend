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
        println('Generating mailz api')
        val apiPath = appName.getAppSourceLibPath + 'Api/'
        fsa.generateFile(apiPath + 'Base/Mailz.php', mailzBaseFile)
        fsa.generateFile(apiPath + 'Mailz.php', mailzFile)
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
		/**
		 * Mailz api base class.
		 */
		class «appName»_Api_Base_Mailz extends Zikula_AbstractApi
		{
		    «mailzBaseImpl»
		}
    '''

    def private mailzBaseImpl(Application it) '''
        /**
         * Get mailz plugins with type / title
         *
         * @return array List of provided plugin functions.
         */
        public function getPlugins($args)
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
         * Get content for plugins
         *
         * @param int      $args['pluginid']    id number of plugin (internal id for this module, see getPlugins method)
         * @param string   $args['params']      optional, show specific one or all otherwise
         * @param int      $args['uid']         optional, user id for user specific content
         * @param string   $args['contenttype'] h or t for html or text
         * @param datetime $args['last']        timestamp of last newsletter
         * @return string output of plugin template.
         */
        public function getContent($args)
        {
            ModUtil::initOOModule('«appName»');
            // $args is something like:
            // Array ( [uid] => 5 [contenttype] => h [pluginid] => 1 [nid] => 1 [last] => 0000-00-00 00:00:00 [params] => Array ( [] => ) ) 1
            «val leadingEntity = getLeadingEntity»
            $objectType = '«leadingEntity.name.formatForCode»';

            $serviceManager = ServiceUtil::getManager();
            $entityManager = $serviceManager->getService('doctrine.entitymanager');
            $repository = $entityManager->getRepository('«appName»_Entity_' . ucfirst($objectType));

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

            $view->assign('objectType', '«leadingEntity.name.formatForCode»')
                 ->assign('items', $entities)
                 ->assign($repository->getAdditionalTemplateParameters('api', array('name' => 'mailz')));

            if ($args['contenttype'] == 't') { /* text */
                return $view->fetch('mailz/itemlist_«leadingEntity.name.formatForCode»_text.tpl');
            } else {
                //return $view->fetch('contenttype/itemlist_display.html');
                return $view->fetch('mailz/itemlist_«leadingEntity.name.formatForCode»_html.tpl');
            }
        }
    '''

    def private mailzImpl(Application it) '''
        /**
         * Mailz api implementation class.
         */
        class «appName»_Api_Mailz extends «appName»_Api_Base_Mailz
        {
            // feel free to extend the mailz api here
        }
    '''
}
