package org.zikula.modulestudio.generator.cartridges.zclassic.models

import de.guite.modulestudio.metamodel.Application
import de.guite.modulestudio.metamodel.DatetimeField
import org.zikula.modulestudio.generator.application.IMostFileSystemAccess
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper
import org.zikula.modulestudio.generator.extensions.DateTimeExtensions
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class EntityInitialiser {

    extension DateTimeExtensions = new DateTimeExtensions
    extension FormattingExtensions = new FormattingExtensions
    extension ModelBehaviourExtensions = new ModelBehaviourExtensions
    extension ModelExtensions = new ModelExtensions
    extension Utils = new Utils

    FileHelper fh = new FileHelper

    /**
     * Creates an entity initialiser class file for easy entity initialisation.
     */
    def generate(Application it, IMostFileSystemAccess fsa) {
        'Generating entity initialiser class'.printIfNotTesting(fsa)
        fsa.generateClassPair('Entity/Factory/EntityInitialiser.php', initialiserBaseImpl, initialiserImpl)
    }

    def private initialiserBaseImpl(Application it) '''
        namespace «appNamespace»\Entity\Factory\Base;

        «IF supportLocaleFilter»
            use Symfony\Component\HttpFoundation\Request;
            use Symfony\Component\HttpFoundation\RequestStack;
        «ENDIF»
        «FOR entity : getAllEntities»
            use «appNamespace»\Entity\«entity.name.formatForCodeCapital»Entity;
        «ENDFOR»
        «IF hasListFieldsExceptWorkflowState»
            use «appNamespace»\Helper\ListEntriesHelper;
        «ENDIF»

        /**
         * Entity initialiser class used to dynamically apply default values to newly created entities.
         */
        abstract class AbstractEntityInitialiser
        {
            «IF supportLocaleFilter»
                /**
                 * @var Request
                 */
                protected $request;

            «ENDIF»
            «IF hasListFieldsExceptWorkflowState»
                /**
                 * @var ListEntriesHelper Helper service for managing list entries
                 */
                protected $listEntriesHelper;

            «ENDIF»
            «IF hasGeographical»
                /**
                 * @var float Default latitude for geographical entities
                 */
                protected $defaultLatitude;

                /**
                 * @var float Default longitude for geographical entities
                 */
                protected $defaultLongitude;

            «ENDIF»
            «IF hasListFieldsExceptWorkflowState || hasGeographical»
                /**
                 * EntityInitialiser constructor.
                 *
                 «IF supportLocaleFilter»
                 * @param RequestStack $requestStack RequestStack service instance
                 «ENDIF»
                 «IF hasListFieldsExceptWorkflowState»
                 * @param ListEntriesHelper $listEntriesHelper Helper service for managing list entries
                 «ENDIF»
                 «IF hasGeographical»
                 * @param float $defaultLatitude Default latitude for geographical entities
                 * @param float $defaultLongitude Default longitude for geographical entities
                 «ENDIF»
                 */
                public function __construct(
                    «IF supportLocaleFilter»RequestStack $requestStack«ENDIF»«IF supportLocaleFilter && hasListFieldsExceptWorkflowState»,«ENDIF»
                    «IF hasListFieldsExceptWorkflowState»ListEntriesHelper $listEntriesHelper«ENDIF»«IF (supportLocaleFilter || hasListFieldsExceptWorkflowState) && hasGeographical»,«ENDIF»
                    «IF hasGeographical»$defaultLatitude,
                    $defaultLongitude«ENDIF»
                ) {
                    «IF supportLocaleFilter»
                        $this->request = $requestStack->getCurrentRequest();
                    «ENDIF»
                    «IF hasListFieldsExceptWorkflowState»
                        $this->listEntriesHelper = $listEntriesHelper;
                    «ENDIF»
                    «IF hasGeographical»
                        $this->defaultLatitude = $defaultLatitude;
                        $this->defaultLongitude = $defaultLongitude;
                    «ENDIF»
                }

            «ENDIF»
            «FOR entity : getAllEntities»
                /**
                 * Initialises a given «entity.name.formatForCode» instance.
                 *
                 * @param «entity.name.formatForCodeCapital»Entity $entity The newly created entity instance
                 *
                 * @return «entity.name.formatForCodeCapital»Entity The updated entity instance
                 */
                public function init«entity.name.formatForCodeCapital»(«entity.name.formatForCodeCapital»Entity $entity)
                {
                    «FOR field : entity.getLanguageFieldsEntity + entity.getLocaleFieldsEntity»
                        $entity->set«field.name.formatForCodeCapital»($this->request->getLocale());
                    «ENDFOR»
                    «FOR field : entity.getDerivedFields.filter(DatetimeField)»
                        «field.setDefaultValue»
                    «ENDFOR»
                    «IF !entity.getListFieldsEntity.filter[name != 'workflowState'].empty»
                        «FOR listField : entity.getListFieldsEntity.filter[name != 'workflowState']»
                            $listEntries = $this->listEntriesHelper->getEntries('«entity.name.formatForCode»', '«listField.name.formatForCode»');
                            «IF !listField.multiple»
                                foreach ($listEntries as $listEntry) {
                                    if (true === $listEntry['default']) {
                                        $entity->set«listField.name.formatForCodeCapital»($listEntry['value']);
                                        break;
                                    }
                                }
                            «ELSE»
                                $items = [];
                                foreach ($listEntries as $listEntry) {
                                    if (true === $listEntry['default']) {
                                        $items[] = $listEntry['value'];
                                    }
                                }
                                $entity->set«listField.name.formatForCodeCapital»(implode('###', $items));
                            «ENDIF»

                        «ENDFOR»
                    «ENDIF»
                    «IF entity.geographical»
                        $entity->setLatitude($this->defaultLatitude);
                        $entity->setLongitude($this->defaultLongitude);

                    «ENDIF»
                    return $entity;
                }

            «ENDFOR»
            «IF hasListFieldsExceptWorkflowState»
                «fh.getterAndSetterMethods(it, 'listEntriesHelper', 'ListEntriesHelper', false, true, false, '', '')»
            «ENDIF»
        }
    '''

    def private setDefaultValue(DatetimeField it) {
        if (it.defaultValue !== null && !it.defaultValue.empty && it.defaultValue.length > 0) {
            if (it.defaultValue != 'now') {
                '''$entity->set«name.formatForCodeCapital»(new \DateTime«IF immutable»Immutable«ENDIF»('«it.defaultValue»'));'''
            } else {
                '''$entity->set«name.formatForCodeCapital»(\DateTime«IF immutable»Immutable«ENDIF»::createFromFormat('«defaultFormat»', «defaultValueForNow»));'''
            }
        }
    }

    def private hasListFieldsExceptWorkflowState(Application it) {
        !getAllListFields.filter[name != 'workflowState'].empty
    }

    def private initialiserImpl(Application it) '''
        namespace «appNamespace»\Entity\Factory;

        use «appNamespace»\Entity\Factory\Base\AbstractEntityInitialiser;

        /**
         * Entity initialiser class used to dynamically apply default values to newly created entities.
         */
        class EntityInitialiser extends AbstractEntityInitialiser
        {
            // feel free to customise the initialiser
        }
    '''
}
