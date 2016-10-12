package org.zikula.modulestudio.generator.cartridges.zclassic.controller.apis

import de.guite.modulestudio.metamodel.Application
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper
import org.zikula.modulestudio.generator.cartridges.zclassic.view.additions.MailzView
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class Mailz {
    extension FormattingExtensions = new FormattingExtensions
    extension ModelExtensions = new ModelExtensions
    extension NamingExtensions = new NamingExtensions
    extension Utils = new Utils

    FileHelper fh = new FileHelper

    def generate(Application it, IFileSystemAccess fsa) {
        generateClassPair(fsa, getAppSourceLibPath + 'Api/Mailz' + (if (targets('1.3.x')) '' else 'Api') + '.php',
            fh.phpFileContent(it, mailzBaseClass), fh.phpFileContent(it, mailzImpl)
        )
        new MailzView().generate(it, fsa)
    }

    def private mailzBaseClass(Application it) '''
        «IF !targets('1.3.x')»
            namespace «appNamespace»\Api\Base;

            use ModUtil;
            use ServiceUtil;
            use Zikula_AbstractBase;

        «ENDIF»
        /**
         * Mailz api base class.
         */
        abstract class «IF targets('1.3.x')»«appName»_Api_Base_AbstractMailz extends Zikula_AbstractApi«ELSE»AbstractMailzApi extends Zikula_AbstractBase«ENDIF»
        {
            «mailzBaseImpl»
        }
    '''

    def private mailzBaseImpl(Application it) '''
        /**
         * Returns existing Mailz plugins with type / title.
         *
         * @param array $args List of arguments
         *
         * @return array List of provided plugin functions
         */
        public function getPlugins(array $args = «IF targets('1.3.x')»array()«ELSE»[]«ENDIF»)
        {
            «IF !targets('1.3.x')»
                $translator = $this->get('translator.default');

            «ENDIF»
            «val itemDesc = getLeadingEntity.nameMultiple.formatForDisplay»
            $plugins = «IF targets('1.3.x')»array()«ELSE»[]«ENDIF»;
            $plugins[] = «IF targets('1.3.x')»array(«ELSE»[«ENDIF»
                'pluginid'      => 1,
                'module'        => '«appName»',
                'title'         => $«IF targets('1.3.x')»this«ELSE»translator«ENDIF»->__('3 newest «itemDesc»'),
                'description'   => $«IF targets('1.3.x')»this«ELSE»translator«ENDIF»->__('A list of the three newest «itemDesc».')
            «IF targets('1.3.x')»)«ELSE»]«ENDIF»;
            $plugins[] = «IF targets('1.3.x')»array(«ELSE»[«ENDIF»
                'pluginid'      => 2,
                'module'        => '«appName»',
                'title'         => $«IF targets('1.3.x')»this«ELSE»translator«ENDIF»->__('3 random «itemDesc»'),
                'description'   => $«IF targets('1.3.x')»this«ELSE»translator«ENDIF»->__('A list of three random «itemDesc».')
            «IF targets('1.3.x')»)«ELSE»]«ENDIF»;

            return $plugins;
        }

        /**
         * Returns the content for a given Mailz plugin.
         *
         * @param array    $args                List of arguments
         * @param int      $args['pluginid']    id number of plugin (internal id for this module, see getPlugins method)
         * @param string   $args['params']      optional, show specific one or all otherwise
         * @param int      $args['uid']         optional, user id for user specific content
         * @param string   $args['contenttype'] h or t for html or text
         * @param datetime $args['last']        timestamp of last newsletter
         *
         * @return string output of plugin template
         */
        public function getContent(array $args = «IF targets('1.3.x')»array()«ELSE»[]«ENDIF»)
        {
            «IF targets('1.3.x')»
                ModUtil::initOOModule('«appName»');
            «ENDIF»
            // $args is something like:
            // Array ( [uid] => 5 [contenttype] => h [pluginid] => 1 [nid] => 1 [last] => 0000-00-00 00:00:00 [params] => Array ( [] => ) ) 1
            «val leadingEntity = getLeadingEntity»
            $objectType = '«leadingEntity.name.formatForCode»';

            «IF targets('1.3.x')»
                $entityClass = '«appName»_Entity_' . ucfirst($objectType);
                $serviceManager = ServiceUtil::getManager();
                $entityManager = $serviceManager->get«IF targets('1.3.x')»Service«ENDIF»('doctrine.entitymanager');
                $repository = $entityManager->getRepository($entityClass);

                $idFields = ModUtil::apiFunc('«appName»', 'selection', 'getIdFields', array('ot' => $objectType));
            «ELSE»
                $repository = $this->get('«appService».' . $objectType . '_factory')->getRepository();

                $selectionHelper = $this->get('«appService».selection_helper');
                $idFields = $selectionHelper->getIdFields($objectType);
            «ENDIF»

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
            «IF targets('1.3.x')»
                $selectionArgs = array(
                    'ot' => $objectType,
                    'where' => $where,
                    'orderBy' => $sortParam,
                    'currentPage' => 1,
                    'resultsPerPage' => $resultsPerPage
                );
                list($entities, $objectCount) = ModUtil::apiFunc('«appName»', 'selection', 'getEntitiesPaginated', $selectionArgs);
            «ELSE»
                list($entities, $objectCount) = $selectionHelper->getEntitiesPaginated($objectType, $where, $orderBy, 1, $resultsPerPage);
            «ENDIF»

            $templateType = $args['contenttype'] == 't' ? 'text' : 'html';

            «IF targets('1.3.x')»
                $view = Zikula_View::getInstance('«appName»', true);

                //$data = array('sorting' => $this->sorting, 'amount' => $this->amount, 'filter' => $this->filter, 'template' => $this->template);
                //$view->assign('vars', $data);

                $view->assign('objectType', $objectType)
                     ->assign('items', $entities)
                     ->assign($repository->getAdditionalTemplateParameters('api', array('name' => 'mailz')));

                return $view->fetch('mailz/itemlist_«leadingEntity.name.formatForCode»_' . $templateType . '.tpl');
            «ELSE»
                $templating = $this->get('twig');

                //$templateParameters = ['sorting' => $this->sorting, 'amount' => $this->amount, 'filter' => $this->filter, 'template' => $this->template];
                $templateParameters = [
                    'objectType' => $objectType,
                    'items' => $entities
                ];
                «IF hasUploads»
                    $imageHelper = $this->get('«appService».image_helper');
                «ENDIF»
                $templateParameters = array_merge($templateParameters, $repository->getAdditionalTemplateParameters(«IF hasUploads»$imageHelper, «ENDIF»'api', ['name' => 'mailz']));

                return $templating->render(
                    '@«appName»/Mailz/itemlist_«leadingEntity.name.formatForCode».' . $templateType . '.twig',
                    $templateParameters
                );
            «ENDIF»
        }
    '''

    def private mailzImpl(Application it) '''
        «IF !targets('1.3.x')»
            namespace «appNamespace»\Api;

            use «appNamespace»\Api\Base\AbstractMailzApi;

        «ENDIF»
        /**
         * Mailz api implementation class.
         */
        «IF targets('1.3.x')»
        class «appName»_Api_Mailz extends «appName»_Api_Base_AbstractMailz
        «ELSE»
        class MailzApi extends AbstractMailzApi
        «ENDIF»
        {
            // feel free to extend the mailz api here
        }
    '''
}
