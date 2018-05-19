package org.zikula.modulestudio.generator.extensions.transformation

import de.guite.modulestudio.metamodel.Application
import de.guite.modulestudio.metamodel.DataObject
import de.guite.modulestudio.metamodel.Entity
import de.guite.modulestudio.metamodel.EntityWorkflowType
import de.guite.modulestudio.metamodel.ManyToOneRelationship
import de.guite.modulestudio.metamodel.MappedSuperClass
import de.guite.modulestudio.metamodel.ModuleStudioFactory
import de.guite.modulestudio.metamodel.NumberFieldType
import de.guite.modulestudio.metamodel.OneToOneRelationship
import de.guite.modulestudio.metamodel.UploadField
import org.zikula.modulestudio.generator.application.IMostFileSystemAccess
import org.zikula.modulestudio.generator.extensions.ControllerExtensions
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.ModelInheritanceExtensions
import org.zikula.modulestudio.generator.extensions.Utils

/**
 * This class adds primary key fields to all entities of an application.
 */
class PersistenceTransformer {

    /**
     * Extension methods for controllers.
     */
    extension ControllerExtensions = new ControllerExtensions

    /**
     * Extension methods for formatting names.
     */
    extension FormattingExtensions = new FormattingExtensions

    /**
     * Extension methods related to behavioural model extensions.
     */
    extension ModelBehaviourExtensions = new ModelBehaviourExtensions

    /**
     * Extension methods related to the model layer.
     */
    extension ModelExtensions = new ModelExtensions

    /**
     * Extension methods related to inheritance.
     */
    extension ModelInheritanceExtensions = new ModelInheritanceExtensions

    /**
     * Extension methods for common utilities.
     */
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

        addWorkflowSettings
        addViewSettings
        addImageSettings
        addIntegrationSettings
        addGeoSettings
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
     * @param it The currently treated {@link DataObject} instance.
     */
    def private void handleEntity(DataObject it) {
        //('Transforming entity ' + name).printIfNotTesting(fsa)
        //('Field size before: ' + fields.size + ' fields').printIfNotTesting(fsa)
        if (getDerivedFields.filter[primaryKey].empty
             && outgoing.filter(OneToOneRelationship).filter[primaryKey].empty
             && outgoing.filter(ManyToOneRelationship).filter[primaryKey].empty
        ) {
            addPrimaryKey
        }
        //('Added primary key, field size now: ' + fields.size + ' fields').printIfNotTesting(fsa)

        if (it instanceof Entity) {
            if (!inheriting || parentType instanceof MappedSuperClass) {
                addWorkflowState
            }
        }

        // make optional upload fields nullable, too
        for (field : fields.filter(UploadField).filter[f|!f.mandatory]) {
            field.nullable = true
        }
    }

    /**
     * Adds a primary key to a given entity.
     * 
     * @param entity The given {@link DataObject} instance.
     */
    def private addPrimaryKey(DataObject entity) {
        val idField = ModuleStudioFactory.eINSTANCE.createIntegerField => [
            name = 'id'
            length = 9
            primaryKey = true
            unique = true
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
            documentation = 'the current workflow state'
            length = 20
            multiple = false
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

        if (entity.workflow != EntityWorkflowType.NONE) {
            listField.items += factory.createListFieldItem => [
                name = 'Waiting'
                value = 'waiting'
                documentation = 'Content has been submitted and waits for approval.'
            ]

            if (entity.workflow == EntityWorkflowType.ENTERPRISE) {
                listField.items += factory.createListFieldItem => [
                    name = 'Accepted'
                    value = 'accepted'
                    documentation = 'Content has been submitted and accepted, but still waits for approval.'
                ]
            }
        }

        listField.items += factory.createListFieldItem => [
            name = 'Approved'
            value = 'approved'
            documentation = 'Content has been approved and is available online.'
        ]

        if (entity.hasTray) {
            listField.items += factory.createListFieldItem => [
                name = 'Suspended'
                value = 'suspended'
                documentation = 'Content has been approved, but is temporarily offline.'
            ]
        }

        if (entity.hasArchive) {
            listField.items += factory.createListFieldItem => [
                name = 'Archived'
                value = 'archived'
                documentation = 'Content has reached the end and became archived.'
            ]
        }

        //if (entity.softDeleteable) {
            listField.items += factory.createListFieldItem => [
                name = 'Trashed'
                value = 'trashed'
                documentation = 'Content has been marked as deleted, but is still persisted in the database.'
            ]
        //}

        listField.items += factory.createListFieldItem => [
            name = 'Deleted'
            value = 'deleted'
            documentation = 'Pseudo-state for content which has been deleted from the database.'
        ]

        entity.fields.add(1, listField)

        val wfIndex = factory.createEntityIndex => [
            name = 'workflowStateIndex'
        ]
        wfIndex.items += factory.createEntityIndexItem => [
            name = 'workflowState'
        ]

        entity.indexes += wfIndex
    }

    def private addWorkflowSettings(Application it) {
        val entitiesWithApproval = getAllEntities.filter[workflow != EntityWorkflowType.NONE]
        if (entitiesWithApproval.empty) {
            return
        }

        val varContainer = createVarContainerForWorkflowSettings
        val factory = ModuleStudioFactory.eINSTANCE

        for (entity : entitiesWithApproval) {
            varContainer.fields += factory.createIntegerField => [
                name = 'moderationGroupFor' + entity.nameMultiple.formatForCodeCapital
                defaultValue = '2' // use admin group (gid=2) as fallback
                documentation = 'Used to determine moderator user accounts for sending email notifications.'
            ]
            if (entity.workflow == EntityWorkflowType.ENTERPRISE) {
                varContainer.fields += factory.createIntegerField => [
                    name = 'superModerationGroupFor' + entity.nameMultiple.formatForCodeCapital
                    defaultValue = '2' // use admin group (gid=2) as fallback
                    documentation = 'Used to determine moderator user accounts for sending email notifications.'
                ]
            }
        }

        variables += varContainer
    }

    def private addViewSettings(Application it) {
        val entitiesWithView = getAllEntities.filter[hasViewAction]
        if (entitiesWithView.empty) {
            return
        }

        val varContainer = createVarContainerForViewSettings
        val factory = ModuleStudioFactory.eINSTANCE

        for (entity : entitiesWithView) {
            varContainer.fields += factory.createIntegerField => [
                name = entity.name.formatForCode + 'EntriesPerPage'
                defaultValue = '10'
                documentation = 'The amount of ' + entity.nameMultiple.formatForDisplay + ' shown per page'
            ]
            if (generateAccountApi && entity.standardFields) {
                varContainer.fields += factory.createBooleanField => [
                    name = 'linkOwn' + entity.nameMultiple.formatForCodeCapital + 'OnAccountPage'
                    defaultValue = 'true'
                    documentation = 'Whether to add a link to ' + entity.nameMultiple.formatForDisplay + ' of the current user on his account page'
                    mandatory = false
                ]
            }
        }
        if (supportLocaleFilter) {
            varContainer.fields += factory.createBooleanField => [
                name = 'filterDataByLocale'
                defaultValue = 'false'
                documentation = 'Whether automatically filter data in the frontend based on the current locale or not'
                mandatory = false
            ]
        }

        variables += varContainer
    }

    def private addImageSettings(Application it) {
        if (!hasImageFields) {
            return
        }

        val varContainer = createVarContainerForImageSettings
        val factory = ModuleStudioFactory.eINSTANCE

        val entitiesWithImageUploads = getAllEntities.filter[hasImageFieldsEntity]
        for (entity : entitiesWithImageUploads) {
            for (imageUploadField : entity.imageFieldsEntity) {
                val fieldSuffix = entity.name.formatForCodeCapital + imageUploadField.name.formatForCodeCapital
                varContainer.fields += factory.createBooleanField => [
                    name = 'enableShrinkingFor' + fieldSuffix
                    defaultValue = 'false'
                    documentation = 'Whether to enable shrinking huge images to maximum dimensions. Stores downscaled version of the original image.'
                    mandatory = false
                    cssClass = 'shrink-enabler'
                ]
                varContainer.fields += factory.createIntegerField => [
                    name = 'shrinkWidth' + fieldSuffix
                    defaultValue = '800'
                    documentation = 'The maximum image width in pixels.'
                ]
                varContainer.fields += factory.createIntegerField => [
                    name = 'shrinkHeight' + fieldSuffix
                    defaultValue = '600'
                    documentation = 'The maximum image height in pixels.'
                ]
                val thumbModeField = factory.createListField => [
                    name = 'thumbnailMode' + fieldSuffix
                    documentation = 'Thumbnail mode (inset or outbound).'
                ]
                thumbModeField.items += factory.createListFieldItem => [
                    name = 'Inset'
                    value = 'inset'
                    ^default = true
                ]
                thumbModeField.items += factory.createListFieldItem => [
                    name = 'Outbound'
                    value = 'outbound'
                ]
                varContainer.fields += thumbModeField
                for (action : #['view', 'display', 'edit']) {
                    if ((action == 'view' && entity.hasViewAction) || (action == 'display' && entity.hasDisplayAction) || (action == 'edit' && entity.hasEditAction)) {
                        varContainer.fields += factory.createIntegerField => [
                            name = 'thumbnailWidth' + fieldSuffix + action.toFirstUpper
                            defaultValue = if (action == 'view') '32' else '240'
                            documentation = 'Thumbnail width on ' + action + ' pages in pixels.'
                        ]
                        varContainer.fields += factory.createIntegerField => [
                            name = 'thumbnailHeight' + fieldSuffix + action.toFirstUpper
                            defaultValue = if (action == 'view') '24' else '180'
                            documentation = 'Thumbnail height on ' + action + ' pages in pixels.'
                        ]
                    }
                }
            }
        }

        variables += varContainer
    }

    def private addIntegrationSettings(Application it) {
        if (!generateExternalControllerAndFinder) {
            return
        }

        val varContainer = createVarContainerForIntegrationSettings
        val factory = ModuleStudioFactory.eINSTANCE

        val listField = factory.createListField => [
            name = 'enabledFinderTypes'
            documentation = 'Which sections are supported in the Finder component (used by Scribite plug-ins).'
            mandatory = false
            multiple = true
        ]
        for (entity : getFinderEntities) {
            listField.items += factory.createListFieldItem => [
                name = entity.name.formatForDisplayCapital
                value = entity.name.formatForCode
                ^default = true
            ]
        }

        varContainer.fields += listField
        variables += varContainer
    }

    def private addGeoSettings(Application it) {
        if (!hasGeographical) {
            return
        }

        val varContainer = createVarContainerForGeoSettings
        val factory = ModuleStudioFactory.eINSTANCE

        varContainer.fields += factory.createNumberField => [
            name = 'defaultLatitude'
            defaultValue = '0.00'
            documentation = 'The default latitude.'
            numberType = NumberFieldType.FLOAT
        ]
        varContainer.fields += factory.createNumberField => [
            name = 'defaultLongitude'
            defaultValue = '0.00'
            documentation = 'The default longitude.'
            numberType = NumberFieldType.FLOAT
        ]
        varContainer.fields += factory.createIntegerField => [
            name = 'defaultZoomLevel'
            defaultValue = '5'
            documentation = 'The default zoom level.'
        ]
        varContainer.fields += factory.createStringField => [
            name = 'tileLayerUrl'
            defaultValue = 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png'
            documentation = 'URL of tile layer to use. See http://leaflet-extras.github.io/leaflet-providers/preview/ for examples.'
        ]
        varContainer.fields += factory.createStringField => [
            name = 'tileLayerAttribution'
            defaultValue = '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors'
            documentation = 'Attribution for tile layer to use.'
        ]

        for (entity : getGeographicalEntities) {
            varContainer.fields += factory.createBooleanField => [
                name = 'enable' + entity.name.formatForCodeCapital + 'GeoLocation'
                defaultValue = 'false'
                documentation = 'Whether to enable geo location functionality for ' + entity.nameMultiple.formatForDisplay + ' or not.'
                mandatory = false
            ]
        }

        variables += varContainer
    }

    def private createVarContainerForWorkflowSettings(Application it) {
        val newSortNumber = getNextVarContainerSortNumber
        ModuleStudioFactory.eINSTANCE.createVariables => [
            name = 'Moderation'
            documentation = 'Here you can assign moderation groups for enhanced workflow actions.'
            sortOrder = newSortNumber
        ]
    }

    def private createVarContainerForViewSettings(Application it) {
        val newSortNumber = getNextVarContainerSortNumber
        ModuleStudioFactory.eINSTANCE.createVariables => [
            name = 'ListViews'
            documentation = 'Here you can configure parameters for list views.'
            sortOrder = newSortNumber
        ]
    }

    def private createVarContainerForImageSettings(Application it) {
        val newSortNumber = getNextVarContainerSortNumber
        ModuleStudioFactory.eINSTANCE.createVariables => [
            name = 'Images'
            documentation = 'Here you can define several options for image handling.'
            sortOrder = newSortNumber
        ]
    }

    def private createVarContainerForIntegrationSettings(Application it) {
        val newSortNumber = getNextVarContainerSortNumber
        ModuleStudioFactory.eINSTANCE.createVariables => [
            name = 'Integration'
            documentation = 'These options allow you to configure integration aspects.'
            sortOrder = newSortNumber
        ]
    }

    def private createVarContainerForGeoSettings(Application it) {
        val newSortNumber = getNextVarContainerSortNumber
        ModuleStudioFactory.eINSTANCE.createVariables => [
            name = 'Geo'
            documentation = 'Here you can define settings related to geographical features.'
            sortOrder = newSortNumber
        ]
    }

    def private getNextVarContainerSortNumber(Application it) {
        var lastVarContainerSortNumber = 0
        if (!variables.empty) {
            lastVarContainerSortNumber = variables.sortBy[sortOrder].reverseView.head.sortOrder
        }

        val newSortNumber = lastVarContainerSortNumber + 1

        newSortNumber
    }
}
