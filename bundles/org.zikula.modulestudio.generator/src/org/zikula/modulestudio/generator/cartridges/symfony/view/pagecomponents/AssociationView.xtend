package org.zikula.modulestudio.generator.cartridges.symfony.view.pagecomponents

import de.guite.modulestudio.metamodel.Entity
import org.zikula.modulestudio.generator.application.IMostFileSystemAccess
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.ModelJoinExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils
import de.guite.modulestudio.metamodel.UploadField

class AssociationView {

    extension FormattingExtensions = new FormattingExtensions
    extension ModelExtensions = new ModelExtensions
    extension ModelJoinExtensions = new ModelJoinExtensions
    extension NamingExtensions = new NamingExtensions
    extension Utils = new Utils

    def generate(Entity it, IMostFileSystemAccess fsa) {
        val incomingRelations = getCommonRelations(true)
        val outgoingRelations = getCommonRelations(false)

        if (incomingRelations.empty && outgoingRelations.empty) {
            return
        }

        val templatePath = application.getViewPath
        val templateExtension = '.html.twig'

        // TODO consider one separate template for each relation property, like EAB demo does it
        // @see https://github.com/EasyCorp/easyadmin-demo/tree/main/templates/admin/post
        var fileName = name.formatForCodeCapital + '/association_display' + templateExtension
        fsa.generateFile(templatePath + fileName, associationFieldTemplateImpl)

        if (!incomingRelations.filter[autocompleteTarget].empty || !outgoingRelations.filter[autocompleteSource].empty) {
            fileName = name.formatForCodeCapital + '/association_autocomplete' + templateExtension
            fsa.generateFile(templatePath + fileName, associationAutocompleteFieldTemplateImpl)
        }
    }

    def private associationFieldTemplateImpl(Entity it) '''
        {# based on association.html.twig and EAB demo #}
        {# @var ea \EasyCorp\Bundle\EasyAdminBundle\Context\AdminContext #}
        {# @var field \EasyCorp\Bundle\EasyAdminBundle\Dto\FieldDto #}
        {# @var entity \EasyCorp\Bundle\EasyAdminBundle\Dto\EntityDto #}
        {% set «nameMultiple.formatForCode» = field.customOptions.get('associationType') ? field.value : [field.value] %}
        {% for «name.formatForCode» in «nameMultiple.formatForCode» %}
            {% if «name.formatForCode» %}
                {% set title = «name.formatForCode»|«application.appName.formatForDB»_formattedTitle %}
                «IF hasImageFieldsEntity»
                    «includeImage(getImageFieldsEntity.head, name.formatForCode)»
                «ENDIF»
                {% if 'toMany' == field.customOptions.get('associationType') %}
                    <span class="badge badge-secondary">{{ title }}</span>
                {% else %}
                    {% if field.customOptions.get('relatedUrl') is not null %}
                        <a href="{{ field.customOptions.get('relatedUrl') }}">{{ title }}</a>
                    {% else %}
                        {{ title }}
                    {% endif %}
                {% endif %}
            {% else %}
                {#<span class="text-muted">{{ 'common.not_assigned'|trans }}</span>#}
            {% endif %}
        {% endfor %}
    '''

    def private associationAutocompleteFieldTemplateImpl(Entity it) '''
        {# based on EAB demo #}
        <div style="display: flex; align-items: center; gap: 10px; padding: 4px 0;">
            {% set title = entity|«application.appName.formatForDB»_formattedTitle %}
            «IF hasImageFieldsEntity»
                «includeImage(getImageFieldsEntity.head, 'entity')»
            «ENDIF»
            <div style="min-width: 0; line-height: 1.3">
                <div style="font-weight: 500; overflow: hidden; text-overflow: ellipsis; white-space: nowrap;">
                    {{ title }}
                </div>
                {# you may enable some additional information, like a short description
                <div style="font-size: 0.85em; color: #6c757d; overflow: hidden; text-overflow: ellipsis; white-space: nowrap;">
                    {{ entity.details }}
                </div>
                #}
            </div>
        </div>
    '''

    def private includeImage(UploadField it, String entityObj) '''
        «IF !mandatory»
            {% if «entityObj».«name.formatForCode» is not empty %}
        «ENDIF»
            <img src="{{ vich_uploader_asset(«entityObj», '«name.formatForCode»File')|imagine_filter('thumb_related') }}" alt="{{ title|e('html_attr') }}" class="img-thumbnail" />
        «IF !mandatory»
            {% endif %}
        «ENDIF»
    '''
}
