package org.zikula.modulestudio.generator.cartridges.symfony.controller.config

import de.guite.modulestudio.metamodel.ArrayField
import de.guite.modulestudio.metamodel.BooleanField
import de.guite.modulestudio.metamodel.DatetimeField
import de.guite.modulestudio.metamodel.Entity
import de.guite.modulestudio.metamodel.Field
import de.guite.modulestudio.metamodel.StringField
import de.guite.modulestudio.metamodel.StringRole
import de.guite.modulestudio.metamodel.UserField
import org.zikula.modulestudio.generator.cartridges.symfony.controller.ControllerMethodInterface
import org.zikula.modulestudio.generator.extensions.ControllerExtensions
import org.zikula.modulestudio.generator.extensions.DateTimeExtensions
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions

class ConfigureCrud implements ControllerMethodInterface {

    extension ControllerExtensions = new ControllerExtensions
    extension DateTimeExtensions = new DateTimeExtensions
    extension FormattingExtensions = new FormattingExtensions
    extension ModelExtensions = new ModelExtensions
    extension NamingExtensions = new NamingExtensions

    Iterable<DatetimeField> dateTimeFields

    override void init(Entity it) {
        dateTimeFields = getAnyDateTimeFieldsEntity
    }

    override imports(Entity it) {
        val imports = newArrayList
        imports.addAll(#[
            'EasyCorp\\Bundle\\EasyAdminBundle\\Config\\Crud',
            'function Symfony\\Component\\Translation\\t',
            entityClassName('', false)
        ])
        if (!dateTimeFields.empty) {
            imports.add('EasyCorp\\Bundle\\EasyAdminBundle\\Field\\DateTimeField')
        }
        imports
    }

    override generateMethod(Entity it) '''
        public function configureCrud(Crud $crud): Crud
        {
            return $crud
                «methodBody»
            ;
        }
    '''

    def private methodBody(Entity it) '''
        ->setEntityLabelInSingular(
            fn (?«name.formatForCodeCapital» $«name.formatForCode», ?string $pageName) => $«name.formatForCode» ?? '«name.formatForDisplayCapital»'
        )
        ->setEntityLabelInPlural('«nameMultiple.formatForDisplayCapital»')
        «IF hasIndexAction»
            ->setPageTitle(Crud::PAGE_INDEX, t('%entity_label_plural% list'))
        «ENDIF»
        «IF hasEditAction»
            ->setPageTitle(Crud::PAGE_NEW, t('New %entity_label_singular%'))
        «ENDIF»
        «IF hasDetailAction»
            ->setPageTitle(Crud::PAGE_DETAIL, fn («name.formatForCodeCapital» $«name.formatForCode») => «/*(string) $«name.formatForCode»*/»$this->entityDisplayHelper->getFormattedTitle($«name.formatForCode»))
        «ENDIF»
        «IF hasEditAction»
            ->setPageTitle(Crud::PAGE_EDIT, fn («name.formatForCodeCapital» $«name.formatForCode») => t('Edit %entity%', ['%entity%' => «/*(string) $«name.formatForCode»*/»$this->entityDisplayHelper->getFormattedTitle($«name.formatForCode»)]))
        «ENDIF»
        «IF hasIndexAction»
            «IF null !== documentation && !documentation.replaceAll('\\s+', '').empty»
                ->setHelp(Crud::PAGE_INDEX, t('«documentation.replaceAll('\'', '"')»'))
            «ENDIF»
        «ENDIF»
        «IF hasAnyDateTimeFieldsEntity»
            «IF hasDirectDateFields»
                ->setDateFormat(DateTimeField::FORMAT_MEDIUM)
            «ENDIF»
            «IF hasDirectTimeFields»
                ->setTimeFormat(DateTimeField::FORMAT_SHORT)
            «ENDIF»
            «IF hasDirectDateTimeFields»
                ->setDateTimeFormat(DateTimeField::FORMAT_MEDIUM, DateTimeField::FORMAT_SHORT)
            «ENDIF»
        «ENDIF»
        «IF !allEntityFields.filter(StringField).filter[f|f.role === StringRole.DATE_INTERVAL].empty»
            ->setDateIntervalFormat('%%y Year(s) %%m Month(s) %%d Day(s)')
        «ENDIF»
        «IF !dateTimeFields.empty»
            ->setTimezone('Europe/Berlin')
        «ENDIF»
        // ->setSearchFields(['«FOR field : allEntityFields.filter[f|f.isContainedInSearch] SEPARATOR '\', \''»«field.name.formatForCode»«ENDFOR»'])
        ->addFormTheme('@ZikulaTheme/Form/bootstrap_4_zikula_admin_layout.html.twig')
        ->addFormTheme('@ZikulaTheme/Form/form_div_layout.html.twig')
    '''

    def private isContainedInSearch(Field it) {
        switch it {
            BooleanField: false
            UserField: false
            ArrayField: false
            default: true
        }
    }
}
