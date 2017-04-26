package org.zikula.modulestudio.generator.cartridges.zclassic.controller.helper

import de.guite.modulestudio.metamodel.Application
import de.guite.modulestudio.metamodel.Entity
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.ModelJoinExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class CollectionFilterHelper {

    extension FormattingExtensions = new FormattingExtensions
    extension ModelBehaviourExtensions = new ModelBehaviourExtensions
    extension ModelExtensions = new ModelExtensions
    extension ModelJoinExtensions = new ModelJoinExtensions
    extension NamingExtensions = new NamingExtensions
    extension Utils = new Utils

    def generate(Application it, IFileSystemAccess fsa) {
        println('Generating helper class for filtering entity collections')
        val fh = new FileHelper
        generateClassPair(fsa, getAppSourceLibPath + 'Helper/CollectionFilterHelper.php',
            fh.phpFileContent(it, collectionFilterHelperBaseClass), fh.phpFileContent(it, collectionFilterHelperImpl)
        )
    }

    def private collectionFilterHelperBaseClass(Application it) '''
        namespace «appNamespace»\Helper\Base;

        use Symfony\Component\HttpFoundation\Request;
        use Symfony\Component\HttpFoundation\RequestStack;
        «FOR entity : getAllEntities»
            use «appNamespace»\Entity\«entity.name.formatForCodeCapital»Entity;
        «ENDFOR»
        «IF hasCategorisableEntities»
            use «appNamespace»\Helper\CategoryHelper;
        «ENDIF»

        /**
         * Entity collection filter helper base class.
         */
        abstract class AbstractCollectionFilterHelper
        {
            /**
             * @var Request
             */
            protected $request;
            «IF hasCategorisableEntities»

                /**
                 * @var CategoryHelper
                 */
                private $categoryHelper;
            «ENDIF»

            /**
             * CollectionFilterHelper constructor.
             *
             * @param RequestStack «IF hasCategorisableEntities»  «ENDIF»$requestStack «IF hasCategorisableEntities»       «ENDIF»RequestStack service instance
             «IF hasCategorisableEntities»
             * @param CategoryHelper $categoryHelper      CategoryHelper service instance
             «ENDIF»
             */
            public function __construct(RequestStack $requestStack«IF hasCategorisableEntities», CategoryHelper $categoryHelper«ENDIF»)
            {
                $this->request = $requestStack->getCurrentRequest();
                «IF hasCategorisableEntities»
                    $this->categoryHelper = $categoryHelper;
                «ENDIF»
            }

            «collectionFilterHelperBaseImpl»
        }
    '''

    def private collectionFilterHelperBaseImpl(Application it) '''
        /**
         * Returns an array of additional template variables for view quick navigation forms.
         *
         * @param string $objectType Name of treated entity type
         * @param string $context    Usage context (allowed values: controllerAction, api, actionHandler, block, contentType)
         * @param array  $args       Additional arguments
         *
         * @return array List of template variables to be assigned
         */
        public function getViewQuickNavParameters($objectType = '', $context = '', $args = [])
        {
            if (!in_array($context, ['controllerAction', 'api', 'actionHandler', 'block', 'contentType'])) {
                $context = 'controllerAction';
            }

            «FOR entity : getAllEntities»
                if ($entity instanceof «entity.name.formatForCodeCapital»Entity) {
                    return $this->getViewQuickNavParametersFor«entity.name.formatForCodeCapital»($context, $args);
                }
            «ENDFOR»

            return [];
        }
        «FOR entity : getAllEntities»

            «entity.getViewQuickNavParameters»
        «ENDFOR»
    '''

    def private getViewQuickNavParameters(Entity it) '''
        /**
         * Returns an array of additional template variables for view quick navigation forms.
         *
         * @param string $context Usage context (allowed values: controllerAction, api, actionHandler, block, contentType)
         * @param array  $args    Additional arguments
         *
         * @return array List of template variables to be assigned
         */
        protected function getViewQuickNavParametersFor«name.formatForCodeCapital»($context = '', $args = [])
        {
            $parameters = [];

            «IF categorisable»
                $parameters['catId'] = $this->request->query->get('catId', '');
                $parameters['catIdList'] = $this->categoryHelper->retrieveCategoriesFromRequest('«name.formatForCode»', 'GET');
            «ENDIF»
            «IF !getBidirectionalIncomingJoinRelationsWithOneSource.empty»
                «FOR relation: getBidirectionalIncomingJoinRelationsWithOneSource»
                    «val sourceAliasName = relation.getRelationAliasName(false)»
                    $parameters['«sourceAliasName»'] = $this->request->query->get('«sourceAliasName»', 0);
                «ENDFOR»
            «ENDIF»
            «IF hasListFieldsEntity»
                «FOR field : getListFieldsEntity»
                    «val fieldName = field.name.formatForCode»
                    $parameters['«fieldName»'] = $this->request->query->get('«fieldName»', '');
                «ENDFOR»
            «ENDIF»
            «IF hasUserFieldsEntity»
                «FOR field : getUserFieldsEntity»
                    «val fieldName = field.name.formatForCode»
                    $parameters['«fieldName»'] = (int) $this->request->query->get('«fieldName»', 0);
                «ENDFOR»
            «ENDIF»
            «IF hasCountryFieldsEntity»
                «FOR field : getCountryFieldsEntity»
                    «val fieldName = field.name.formatForCode»
                    $parameters['«fieldName»'] = $this->request->query->get('«fieldName»', '');
                «ENDFOR»
            «ENDIF»
            «IF hasLanguageFieldsEntity»
                «FOR field : getLanguageFieldsEntity»
                    «val fieldName = field.name.formatForCode»
                    $parameters['«fieldName»'] = $this->request->query->get('«fieldName»', '');
                «ENDFOR»
            «ENDIF»
            «IF hasLocaleFieldsEntity»
                «FOR field : getLocaleFieldsEntity»
                    «val fieldName = field.name.formatForCode»
                    $parameters['«fieldName»'] = $this->request->query->get('«fieldName»', '');
                «ENDFOR»
            «ENDIF»
            «IF hasAbstractStringFieldsEntity»
                $parameters['q'] = $this->request->query->get('q', '');
            «ENDIF»
            «IF hasBooleanFieldsEntity»
                «FOR field : getBooleanFieldsEntity»
                    «val fieldName = field.name.formatForCode»
                    $parameters['«fieldName»'] = $this->request->query->get('«fieldName»', '');
                «ENDFOR»
            «ENDIF»

            return $parameters;
        }
    '''

    def private collectionFilterHelperImpl(Application it) '''
        namespace «appNamespace»\Helper;

        use «appNamespace»\Helper\Base\AbstractCollectionFilterHelper;

        /**
         * Entity collection filter helper implementation class.
         */
        class CollectionFilterHelper extends AbstractCollectionFilterHelper
        {
            // feel free to extend the collection filter helper here
        }
    '''
}
