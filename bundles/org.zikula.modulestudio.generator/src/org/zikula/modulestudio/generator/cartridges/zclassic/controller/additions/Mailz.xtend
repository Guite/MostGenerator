package org.zikula.modulestudio.generator.cartridges.zclassic.controller.additions

import de.guite.modulestudio.metamodel.Application
import org.zikula.modulestudio.generator.application.IMostFileSystemAccess
import org.zikula.modulestudio.generator.cartridges.zclassic.view.additions.MailzView
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class Mailz {

    extension FormattingExtensions = new FormattingExtensions
    extension ModelExtensions = new ModelExtensions
    extension Utils = new Utils

    def generate(Application it, IMostFileSystemAccess fsa) {
        fsa.generateClassPair('Api/MailzApi.php', mailzBaseClass, mailzImpl)
        new MailzView().generate(it, fsa)
    }

    def private mailzBaseClass(Application it) '''
        namespace «appNamespace»\Api\Base;

        use Exception;
        use Symfony\Component\DependencyInjection\ContainerAwareInterface;
        use Symfony\Component\DependencyInjection\ContainerAwareTrait;
        use Zikula_AbstractBase;

        /**
         * Mailz api base class.
         */
        abstract class AbstractMailzApi extends Zikula_AbstractBase implements ContainerAwareInterface
        {
            use ContainerAwareTrait;

            /**
             * MailzApi constructor.
             */
            public function __construct()
            {
                $this->setContainer(\ServiceUtil::getManager());
            }

            «mailzBaseImpl»
        }
    '''

    def private mailzBaseImpl(Application it) '''
        /**
         * Returns existing Mailz plugins with type / title.
         «IF !targets('3.0')»
         *
         * @param array $args List of arguments
         *
         * @return array List of provided plugin functions
         «ENDIF»
         */
        public function getPlugins(array $args = [])«IF targets('3.0')»: array«ENDIF»
        {
            $translator = $this->container->get('translator«IF !targets('3.0')».default«ENDIF»');

            «val itemDesc = getLeadingEntity.nameMultiple.formatForDisplay»
            $plugins = [];
            $plugins[] = [
                'pluginid'    => 1,
                'module'      => '«appName»',
                'title'       => $translator->«IF targets('3.0')»trans«ELSE»__«ENDIF»('3 newest «itemDesc»'),
                'description' => $translator->«IF targets('3.0')»trans«ELSE»__«ENDIF»('A list of the three newest «itemDesc».')
            ];
            $plugins[] = [
                'pluginid'    => 2,
                'module'      => '«appName»',
                'title'       => $translator->«IF targets('3.0')»trans«ELSE»__«ENDIF»('3 recently updated «itemDesc»'),
                'description' => $translator->«IF targets('3.0')»trans«ELSE»__«ENDIF»('A list of the three recently updated «itemDesc».')
            ];
            $plugins[] = [
                'pluginid'    => 3,
                'module'      => '«appName»',
                'title'       => $translator->«IF targets('3.0')»trans«ELSE»__«ENDIF»('3 random «itemDesc»'),
                'description' => $translator->«IF targets('3.0')»trans«ELSE»__«ENDIF»('A list of three random «itemDesc».')
            ];

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
        public function getContent(array $args = [])«IF targets('3.0')»: string«ENDIF»
        {
            // $args is something like:
            // Array ( [uid] => 5 [contenttype] => h [pluginid] => 1 [nid] => 1 [last] => 0000-00-00 00:00:00 [params] => Array ( [] => ) ) 1
            «val leadingEntity = getLeadingEntity»
            $objectType = '«leadingEntity.name.formatForCode»';

            $repository = $this->container->get('«appService».entity_factory')->getRepository($objectType);

            $sorting = 'default';
            if ($args['pluginid'] == 1) {
                $sorting = 'newest';
            } elseif ($args['pluginid'] == 2) {
                $sorting = 'updated';
            } elseif ($args['pluginid'] == 3) {
                $sorting = 'random';
            }
            $sortParam = $this->container->get('«appService».model_helper')->resolveSortParameter($objectType, $sorting);

            $where = ''/*$this->filter*/;
            $resultsPerPage = 3;

            // get objects from database
            try {
                list($entities, $objectCount) = $repository->selectWherePaginated($where, $orderBy, 1, $resultsPerPage);
            } catch (Exception $exception) {
                $entities = [];
                $objectCount = 0;
            }

            $templateType = 't' === $args['contenttype'] ? 'text' : 'html';

            //$templateParameters = ['sorting' => $this->sorting, 'amount' => $this->amount, 'filter' => $this->filter, 'template' => $this->template];
            $templateParameters = [
                'objectType' => $objectType,
                'items' => $entities
            ];

            $templateParameters = $this->container->get('«appService».controller_helper')
                ->addTemplateParameters($objectType, $templateParameters, 'mailz', [])
            ;

            return $this->container->get('twig')->render(
                '@«appName»/Mailz/itemlist_' . $objectType . $templateType . '.twig',
                $templateParameters
            );
        }
    '''

    def private mailzImpl(Application it) '''
        namespace «appNamespace»\Api;

        use «appNamespace»\Api\Base\AbstractMailzApi;

        /**
         * Mailz api implementation class.
         */
        class MailzApi extends AbstractMailzApi
        {
            // feel free to extend the mailz api here
        }
    '''
}
