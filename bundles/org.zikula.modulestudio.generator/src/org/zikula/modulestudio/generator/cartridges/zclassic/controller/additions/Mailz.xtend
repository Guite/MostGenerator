package org.zikula.modulestudio.generator.cartridges.zclassic.controller.additions

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
        generateClassPair(fsa, getAppSourceLibPath + 'Api/MailzApi.php',
            fh.phpFileContent(it, mailzBaseClass), fh.phpFileContent(it, mailzImpl)
        )
        new MailzView().generate(it, fsa)
    }

    def private mailzBaseClass(Application it) '''
        namespace «appNamespace»\Api\Base;

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
         *
         * @param array $args List of arguments
         *
         * @return array List of provided plugin functions
         */
        public function getPlugins(array $args = [])
        {
            $translator = $this->container->get('translator.default');

            «val itemDesc = getLeadingEntity.nameMultiple.formatForDisplay»
            $plugins = [];
            $plugins[] = [
                'pluginid'      => 1,
                'module'        => '«appName»',
                'title'         => $translator->__('3 newest «itemDesc»'),
                'description'   => $translator->__('A list of the three newest «itemDesc».')
            ];
            $plugins[] = [
                'pluginid'      => 2,
                'module'        => '«appName»',
                'title'         => $translator->__('3 random «itemDesc»'),
                'description'   => $translator->__('A list of three random «itemDesc».')
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
        public function getContent(array $args = [])
        {
            // $args is something like:
            // Array ( [uid] => 5 [contenttype] => h [pluginid] => 1 [nid] => 1 [last] => 0000-00-00 00:00:00 [params] => Array ( [] => ) ) 1
            «val leadingEntity = getLeadingEntity»
            $objectType = '«leadingEntity.name.formatForCode»';

            $entityFactory = $this->container->get('«appService».entity_factory');
            $idFields = $entityFactory->getIdFields($objectType);
            $repository = $entityFactory->getRepository($objectType);

            $sorting = 'default';
            if ($args['pluginid'] == 2) {
                $sorting = 'random';
            } elseif ($args['pluginid'] == 1) {
                $sorting = 'newest';
            }
            $sortParam = $this->container->get('«appService».model_helper')->resolveSortParameter($objectType, $sorting);

            $where = ''/*$this->filter*/;
            $resultsPerPage = 3;

            // get objects from database
            list($entities, $objectCount) = $repository->selectWherePaginated($where, $orderBy, 1, $resultsPerPage);

            $templateType = $args['contenttype'] == 't' ? 'text' : 'html';

            //$templateParameters = ['sorting' => $this->sorting, 'amount' => $this->amount, 'filter' => $this->filter, 'template' => $this->template];
            $templateParameters = [
                'objectType' => $objectType,
                'items' => $entities
            ];

            $templateParameters = $this->container->get('«appService».controller_helper')->addTemplateParameters($objectType, $templateParameters, 'mailz', []);

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
