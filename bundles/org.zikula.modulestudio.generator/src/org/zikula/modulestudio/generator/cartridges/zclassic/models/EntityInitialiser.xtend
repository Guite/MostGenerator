package org.zikula.modulestudio.generator.cartridges.zclassic.models

import de.guite.modulestudio.metamodel.AbstractDateField
import de.guite.modulestudio.metamodel.Application
import de.guite.modulestudio.metamodel.DateField
import de.guite.modulestudio.metamodel.DatetimeField
import de.guite.modulestudio.metamodel.TimeField
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class EntityInitialiser {

    extension FormattingExtensions = new FormattingExtensions
    extension ModelBehaviourExtensions = new ModelBehaviourExtensions
    extension ModelExtensions = new ModelExtensions
    extension NamingExtensions = new NamingExtensions
    extension Utils = new Utils

    FileHelper fh = new FileHelper

    /**
     * Creates an entity initialiser class file for easy entity initialisation.
     */
    def generate(Application it, IFileSystemAccess fsa) {
        println('Generating entity initialiser class')
        generateClassPair(fsa, getAppSourceLibPath + 'Entity/Factory/EntityInitialiser.php',
            fh.phpFileContent(it, initialiserBaseImpl), fh.phpFileContent(it, initialiserImpl)
        )
    }

    def private initialiserBaseImpl(Application it) '''
        namespace «appNamespace»\Entity\Factory\Base;

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
                 «IF hasListFieldsExceptWorkflowState»
                 * @param ListEntriesHelper $listEntriesHelper Helper service for managing list entries
                 «ENDIF»
                 «IF hasGeographical»
                 * @param float $defaultLatitude Default latitude for geographical entities
                 * @param float $defaultLongitude Default longitude for geographical entities
                 «ENDIF»
                 */
                public function __construct(«IF hasListFieldsExceptWorkflowState»ListEntriesHelper $listEntriesHelper«IF hasGeographical», «ENDIF»«ENDIF»«IF hasGeographical»$defaultLatitude, $defaultLongitude«ENDIF»)
                {
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
                    «FOR field : entity.getDerivedFields.filter(AbstractDateField)»
                        «field.setDefaultValue»
                    «ENDFOR»
                    «IF !entity.getListFieldsEntity.filter[name != 'workflowState'].empty»
                        «FOR listField : entity.getListFieldsEntity.filter[name != 'workflowState']»
                            $listEntries = $this->listEntriesHelper->getEntries('«entity.name.formatForCode»', '«listField.name.formatForCode»');
                            «IF listField.multiple»
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

    def private setDefaultValue(AbstractDateField it) {
        if (it.defaultValue !== null && it.defaultValue != '' && it.defaultValue.length > 0) {
            if (it.defaultValue != 'now') {
                '''$entity->set«name.formatForCodeCapital»(new \DateTime('«it.defaultValue»'));'''
            } else {
                '''$entity->set«name.formatForCodeCapital»(\DateTime::createFromFormat('«defaultFormat»', date('«defaultFormat»')));'''
            }
        }
    }

    def private dispatch defaultFormat(DatetimeField it) '''Y-m-d H:i:s'''
    def private dispatch defaultFormat(DateField it) '''Y-m-d'''
    def private dispatch defaultFormat(TimeField it) '''H:i:s'''

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
