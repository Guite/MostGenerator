package org.zikula.modulestudio.generator.extensions.transformation

import de.guite.modulestudio.metamodel.Application
import de.guite.modulestudio.metamodel.ArrayType
import de.guite.modulestudio.metamodel.Entity
import de.guite.modulestudio.metamodel.ManyToOneRelationship
import de.guite.modulestudio.metamodel.ModuleStudioFactory
import de.guite.modulestudio.metamodel.NumberFieldType
import de.guite.modulestudio.metamodel.OneToOneRelationship
import de.guite.modulestudio.metamodel.StringField
import de.guite.modulestudio.metamodel.StringRole
import de.guite.modulestudio.metamodel.UploadField
import org.zikula.modulestudio.generator.application.IMostFileSystemAccess
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions
import org.zikula.modulestudio.generator.extensions.Utils
import org.zikula.modulestudio.generator.extensions.WorkflowExtensions

/**
 * This class adds derived entity fields and variables to a given application model.
 */
class PersistenceTransformer {

    extension FormattingExtensions = new FormattingExtensions
    extension ModelBehaviourExtensions = new ModelBehaviourExtensions
    extension WorkflowExtensions = new WorkflowExtensions
    extension Utils = new Utils

    /**
     * Transformation entry point consuming the application instance.
     *
     * @param it The given {@link Application} instance
     * @param fsa The file system accessor
     */
    def modify(Application it, IMostFileSystemAccess fsa) {
        'Starting model transformation'.printIfNotTesting(fsa)

        name = name.replaceUmlauts
        vendor = vendor.replaceUmlauts
        author = author.replaceUmlauts

        // handle all entities
        for (entity : entities) {
            entity.handleEntity
        }

        // make optional upload fields nullable
        for (field : entities.map[fields].flatten.filter(UploadField).filter[!mandatory]) {
            field.nullable = true
        }
        // correct default values for country fields
        for (field : entities.map[fields].flatten.filter(StringField).filter[StringRole.COUNTRY == role]) {
            if (null !== field.defaultValue) {
                field.defaultValue = field.defaultValue.toUpperCase
            }
        }
        // ensure date interval fields are nullable
        for (field : entities.map[fields].flatten.filter(StringField).filter[StringRole.DATE_INTERVAL== role]) {
            field.nullable = true
        }
    }

    /**
     * Replace umlauts by equivalent characters.
     *
     * @param it Given string
     * @return string Replaced string
     */
    def private replaceUmlauts(String it) {
        var output = it

        output = output.replaceAll('Ä', 'Ae')
        output = output.replaceAll('Ö', 'Oe')
        output = output.replaceAll('Ü', 'Ue')
        output = output.replaceAll('ä', 'ae')
        output = output.replaceAll('ö', 'oe')
        output = output.replaceAll('ü', 'ue')
        output = output.replaceAll('ß', 'ss')

        output
    }

    /**
     * Transformation processing for a single entity.
     *
     * @param it The currently treated {@link Entity} instance.
     */
    def private void handleEntity(Entity it) {
        //('Transforming entity ' + name).printIfNotTesting(fsa)
        //('Field size before: ' + fields.size + ' fields').printIfNotTesting(fsa)
        if (fields.filter[primaryKey].empty
             && outgoing.filter(OneToOneRelationship).filter[primaryKey].empty
             && outgoing.filter(ManyToOneRelationship).filter[primaryKey].empty
        ) {
            addPrimaryKey
        }
        //('Added primary key, field size now: ' + fields.size + ' fields').printIfNotTesting(fsa)

        addWorkflowState

        if (hasSluggableFields) {
            val isTranslatable = hasTranslatableSlug
            fields += ModuleStudioFactory.eINSTANCE.createStringField => [
                name = 'slug'
                documentation = 'Permalink for this ' + name.formatForDisplay
                length = 190
                mandatory = true
                minLength = 1
                unique = true
                translatable = isTranslatable
                visibleOnIndex = false
                visibleOnDetail = false
                visibleOnSort = false
            ]
        }

        if (geographical) {
            fields += ModuleStudioFactory.eINSTANCE.createNumberField => [
                numberType = NumberFieldType.DECIMAL
                name = 'latitude'
                documentation = 'The coordinate\'s latitude part.'
                defaultValue = '0.00'
                mandatory = false
                visibleOnIndex = false
                visibleOnDetail = false
                visibleOnNew = false
                visibleOnEdit = false
                visibleOnSort = true
            ]
            fields += ModuleStudioFactory.eINSTANCE.createNumberField => [
                numberType = NumberFieldType.DECIMAL
                name = 'longitude'
                documentation = 'The coordinate\'s longitude part.'
                defaultValue = '0.00'
                mandatory = false
                visibleOnIndex = false
                visibleOnDetail = false
                visibleOnNew = false
                visibleOnEdit = false
                visibleOnSort = true
            ]
        }
/** TODO

    def getReservedTranslatableFields() {
        #['locale']
    }

    def getReservedTreeFields() {
        #['lft', 'lvl', 'rgt', 'root', 'parent', 'children']
    }

 */


        if (standardFields) {
            // add standard fields
            fields += ModuleStudioFactory.eINSTANCE.createUserField => [
                name = 'createdBy'
                mandatory = false
                visibleOnIndex = true
                visibleOnDetail = true
                visibleOnNew = false
                visibleOnEdit = false
                visibleOnSort = true
            ]
            fields += ModuleStudioFactory.eINSTANCE.createDatetimeField => [
                name = 'createdDate'
                mandatory = false
                visibleOnIndex = true
                visibleOnDetail = true
                visibleOnNew = false
                visibleOnEdit = false
                visibleOnSort = true
                immutable = true
            ]
            fields += ModuleStudioFactory.eINSTANCE.createUserField => [
                name = 'updatedBy'
                mandatory = false
                visibleOnIndex = true
                visibleOnDetail = true
                visibleOnNew = false
                visibleOnEdit = false
                visibleOnSort = true
            ]
            fields += ModuleStudioFactory.eINSTANCE.createDatetimeField => [
                name = 'updatedDate'
                mandatory = false
                visibleOnIndex = true
                visibleOnDetail = true
                visibleOnNew = false
                visibleOnEdit = false
                visibleOnSort = true
                immutable = true
            ]
        }

        if (loggable && hasTranslatableFields) {
            // add array field to store revisions of translations
            fields += ModuleStudioFactory.eINSTANCE.createArrayField => [
                name = 'translationData'
                mandatory = false
                visibleOnIndex = false
                visibleOnDetail = false
                visibleOnNew = false
                visibleOnEdit = false
                visibleOnSort = false
                arrayType = ArrayType.JSON
            ]
        }
    }

    /**
     * Adds a primary key to a given entity.
     * 
     * @param entity The given {@link Entity} instance.
     */
    def private addPrimaryKey(Entity entity) {
        val idField = ModuleStudioFactory.eINSTANCE.createStringField => [
            name = 'id'
            primaryKey = true
            unique = true
            length = 36
            role = StringRole.UUID
            visibleOnIndex = true
            visibleOnDetail = true
            visibleOnNew = false
            visibleOnEdit = false
            visibleOnSort = false
        ]
        entity.fields.add(0, idField)
    }

    /**
     * Adds a list field for the workflow state to a given entity.
     * 
     * @param entity The given {@link Entity} instance.
     */
    def private addWorkflowState(Entity entity) {
        val factory = ModuleStudioFactory.eINSTANCE
        val listField = factory.createListField => [
            name = 'workflowState'
            documentation = 'The current workflow state.'
            length = 20
            multiple = false
            visibleOnIndex = entity.hasVisibleWorkflow
            visibleOnDetail = entity.hasVisibleWorkflow
            visibleOnNew = false
            visibleOnEdit = false
            visibleOnSort = entity.hasVisibleWorkflow
        ]
        listField.items += factory.createListFieldItem => [
            name = 'Initial'
            value = 'initial'
            documentation = 'Pseudo-state for content which is just created and not persisted yet.'
            ^default = true
        ]

        if (entity.ownerPermission) {
            listField.items += factory.createListFieldItem => [
                name = 'Deferred'
                value = 'deferred'
                documentation = 'Content has not been submitted yet or has been waiting, but was rejected.'
            ]
        }

        if (entity.approval) {
            listField.items += factory.createListFieldItem => [
                name = 'Waiting'
                value = 'waiting'
                documentation = 'Content has been submitted and waits for approval.'
            ]
        }

        listField.items += factory.createListFieldItem => [
            name = 'Approved'
            value = 'approved'
            documentation = 'Content has been approved and is available online.'
        ]

        if (entity.hasArchive) {
            listField.items += factory.createListFieldItem => [
                name = 'Archived'
                value = 'archived'
                documentation = 'Content has reached the end and became archived.'
            ]
        }

        listField.items += factory.createListFieldItem => [
            name = 'Deleted'
            value = 'deleted'
            documentation = 'Pseudo-state for content which has been deleted from the database.'
        ]

        entity.fields.add(1, listField)
    }
}
