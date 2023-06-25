package org.zikula.modulestudio.generator.cartridges.symfony.models

import de.guite.modulestudio.metamodel.Application
import de.guite.modulestudio.metamodel.DatetimeField
import org.zikula.modulestudio.generator.application.IMostFileSystemAccess
import org.zikula.modulestudio.generator.application.ImportList
import org.zikula.modulestudio.generator.cartridges.symfony.smallstuff.FileHelper
import org.zikula.modulestudio.generator.extensions.DateTimeExtensions
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class EntityInitializer {

    extension DateTimeExtensions = new DateTimeExtensions
    extension FormattingExtensions = new FormattingExtensions
    extension ModelBehaviourExtensions = new ModelBehaviourExtensions
    extension ModelExtensions = new ModelExtensions
    extension Utils = new Utils

    FileHelper fh

    /**
     * Creates an entity initializer class file for easy entity initialization.
     */
    def generate(Application it, IMostFileSystemAccess fsa) {
        fh = new FileHelper(it)
        'Generating entity initializer class'.printIfNotTesting(fsa)
        fsa.generateClassPair('Entity/Factory/EntityInitializer.php', initializerBaseImpl, initializerImpl)
    }

    def private collectBaseImports(Application it) {
        val imports = new ImportList
        imports.add(appNamespace + '\\Helper\\PermissionHelper')
        if (!getAllEntities.filter[!fields.filter(DatetimeField).filter[!immutable].empty].empty) {
            imports.add('DateTime')
        }
        if (!getAllEntities.filter[!fields.filter(DatetimeField).filter[immutable].empty].empty) {
            imports.add('DateTimeImmutable')
        }
        if (supportLocaleFilter) {
            imports.add('Symfony\\Component\\HttpFoundation\\RequestStack')
        }
        for (entity : getAllEntities) {
            imports.add(appNamespace + '\\Entity\\' + entity.name.formatForCodeCapital)
        }
        if (hasListFieldsExceptWorkflowState) {
            imports.add(appNamespace + '\\Helper\\ListEntriesHelper')
        }
        imports
    }

    def private initializerBaseImpl(Application it) '''
        namespace «appNamespace»\Entity\Factory\Base;

        «collectBaseImports.print»

        /**
         * Entity initializer class used to dynamically apply default values to newly created entities.
         */
        abstract class AbstractEntityInitializer
        {
            public function __construct(
                «IF supportLocaleFilter»protected readonly RequestStack $requestStack,«ENDIF»
                protected readonly PermissionHelper $permissionHelper«IF hasListFieldsExceptWorkflowState»,
                protected readonly ListEntriesHelper $listEntriesHelper«ENDIF»«IF hasGeographical»,
                protected readonly string $defaultLatitude,
                protected readonly string $defaultLongitude«ENDIF»
            ) {
            }
            «FOR entity : getAllEntities»

                /**
                 * Initialises a given «entity.name.formatForCode» instance.
                 */
                public function init«entity.name.formatForCodeCapital»(«entity.name.formatForCodeCapital» $entity): «entity.name.formatForCodeCapital»Entity
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

    def private initializerImpl(Application it) '''
        namespace «appNamespace»\Entity\Factory;

        use «appNamespace»\Entity\Factory\Base\AbstractEntityInitializer;

        /**
         * Entity initializer class used to dynamically apply default values to newly created entities.
         */
        class EntityInitializer extends AbstractEntityInitializer
        {
            // feel free to customise the initializer
        }
    '''
}
