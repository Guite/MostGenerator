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

    FileHelper fh

    /**
     * Creates an entity initialiser class file for easy entity initialisation.
     */
    def generate(Application it, IMostFileSystemAccess fsa) {
        fh = new FileHelper(it)
        'Generating entity initialiser class'.printIfNotTesting(fsa)
        fsa.generateClassPair('Entity/Factory/EntityInitialiser.php', initialiserBaseImpl, initialiserImpl)
    }

    def private initialiserBaseImpl(Application it) '''
        namespace «appNamespace»\Entity\Factory\Base;

        «IF !getAllEntities.filter[!fields.filter(DatetimeField).filter[!immutable].empty].empty»
            use DateTime;
        «ENDIF»
        «IF !getAllEntities.filter[!fields.filter(DatetimeField).filter[immutable].empty].empty»
            use DateTimeImmutable;
        «ENDIF»
        «IF supportLocaleFilter»
            use Symfony\Component\HttpFoundation\RequestStack;
        «ENDIF»
        «IF hasGeographical»
            use Zikula\ExtensionsBundle\Api\ApiInterface\VariableApiInterface;
        «ENDIF»
        «FOR entity : getAllEntities»
            use «appNamespace»\Entity\«entity.name.formatForCodeCapital»Entity;
        «ENDFOR»
        «IF hasListFieldsExceptWorkflowState»
            use «appNamespace»\Helper\ListEntriesHelper;
        «ENDIF»
        use «appNamespace»\Helper\PermissionHelper;

        /**
         * Entity initialiser class used to dynamically apply default values to newly created entities.
         */
        abstract class AbstractEntityInitialiser
        {
            «IF hasGeographical»
                protected string $defaultLatitude;

                protected string $defaultLongitude;

            «ENDIF»
            public function __construct(
                «IF supportLocaleFilter»protected RequestStack $requestStack,«ENDIF»
                protected PermissionHelper $permissionHelper«IF hasListFieldsExceptWorkflowState»,
                protected ListEntriesHelper $listEntriesHelper«ENDIF»«IF hasGeographical»,
                VariableApiInterface $variableApi«ENDIF»
            ) {
                «IF hasGeographical»
                    $this->defaultLatitude = $variableApi->get('«appName»', 'defaultLatitude', '0.00');
                    $this->defaultLongitude = $variableApi->get('«appName»', 'defaultLongitude', '0.00');
                «ENDIF»
            }
            «FOR entity : getAllEntities»

                /**
                 * Initialises a given «entity.name.formatForCode» instance.
                 */
                public function init«entity.name.formatForCodeCapital»(«entity.name.formatForCodeCapital»Entity $entity): «entity.name.formatForCodeCapital»Entity
                {
                    «FOR field : entity.getLanguageFieldsEntity + entity.getLocaleFieldsEntity»
                        $entity->set«field.name.formatForCodeCapital»($this->requestStack->getCurrentRequest()->getLocale());

                    «ENDFOR»
                    «IF !entity.getDerivedFields.filter(DatetimeField).empty»
                        «FOR field : entity.getDerivedFields.filter(DatetimeField)»
                            «field.setDefaultValue»
                        «ENDFOR»
                    «ENDIF»
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
                «fh.getterAndSetterMethods(it, 'listEntriesHelper', 'ListEntriesHelper', true, '', '')»
            «ENDIF»
        }
    '''

    def private setDefaultValue(DatetimeField it) {
        val hasDefaultValue = null !== it.defaultValue && !it.defaultValue.empty && 0 < it.defaultValue.length
        if (it.mandatory || hasDefaultValue) {
            if (hasDefaultValue && 'now' != it.defaultValue) {
                '''$entity->set«name.formatForCodeCapital»(new DateTime«IF immutable»Immutable«ENDIF»('«it.defaultValue»'));'''
            } else {
                '''$entity->set«name.formatForCodeCapital»(DateTime«IF immutable»Immutable«ENDIF»::createFromFormat('«defaultFormat»', «defaultValueForNow»));'''
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
