package org.zikula.modulestudio.generator.extensions.transformation

import de.guite.modulestudio.metamodel.Application
import de.guite.modulestudio.metamodel.ArrayType
import de.guite.modulestudio.metamodel.DataObject
import de.guite.modulestudio.metamodel.Entity
import de.guite.modulestudio.metamodel.EntityWorkflowType
import de.guite.modulestudio.metamodel.FieldDisplayType
import de.guite.modulestudio.metamodel.ListFieldItem
import de.guite.modulestudio.metamodel.ManyToOneRelationship
import de.guite.modulestudio.metamodel.MappedSuperClass
import de.guite.modulestudio.metamodel.ModuleStudioFactory
import de.guite.modulestudio.metamodel.NumberFieldType
import de.guite.modulestudio.metamodel.OneToOneRelationship
import de.guite.modulestudio.metamodel.StringField
import de.guite.modulestudio.metamodel.StringRole
import de.guite.modulestudio.metamodel.UploadField
import org.eclipse.emf.ecore.util.EcoreUtil
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

    extension ControllerExtensions = new ControllerExtensions
    extension FormattingExtensions = new FormattingExtensions
    extension ModelBehaviourExtensions = new ModelBehaviourExtensions
    extension ModelExtensions = new ModelExtensions
    extension ModelInheritanceExtensions = new ModelInheritanceExtensions
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
        for (field : (entities.map[fields] + variables.map[fields]).flatten.filter(UploadField).filter[!mandatory]) {
            field.nullable = true
        }
        // correct default values for country fields
        for (field : (entities.map[fields] + variables.map[fields]).flatten.filter(StringField).filter[StringRole.COUNTRY == role]) {
            if (null !== field.defaultValue) {
                field.defaultValue = field.defaultValue.toUpperCase
            }
        }

        addViewSettings
        addImageSettings
        addModerationSettings
        addIntegrationSettings
        addGeoSettings
        addVersionControlSettings
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

            if (loggable && hasTranslatableFields) {
                // add array field to store revisions of translations
                fields += ModuleStudioFactory.eINSTANCE.createArrayField => [
                    name = 'translationData'
                    mandatory = false
                    displayType = FieldDisplayType.NONE
                    visible = false
                    arrayType = ArrayType.JSON_ARRAY
                ]
            }
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
            documentation = 'The current workflow state.'
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
                documentation = 'The amount of ' + entity.nameMultiple.formatForDisplay + ' shown per page.'
            ]
            if (generateAccountApi && entity.standardFields) {
                varContainer.fields += factory.createBooleanField => [
                    name = 'linkOwn' + entity.nameMultiple.formatForCodeCapital + 'OnAccountPage'
                    defaultValue = 'true'
                    documentation = 'Whether to add a link to ' + entity.nameMultiple.formatForDisplay + ' of the current user on his account page.'
                    mandatory = false
                ]
            }
        }
        for (entity : getAllEntities.filter[ownerPermission]) {
            varContainer.fields += factory.createBooleanField => [
                name = entity.name.formatForCode + 'PrivateMode'
                defaultValue = 'false'
                documentation = 'Whether users may only see own ' + entity.nameMultiple.formatForDisplay + '.'
                mandatory = false
            ]
        }
        varContainer.fields += factory.createBooleanField => [
            name = 'showOnlyOwnEntries'
            defaultValue = 'false'
            documentation = 'Whether only own entries should be shown on view pages by default or not.'
            mandatory = false
        ]
        if (supportLocaleFilter) {
            varContainer.fields += factory.createBooleanField => [
                name = 'filterDataByLocale'
                defaultValue = 'false'
                documentation = 'Whether automatically filter data in the frontend based on the current locale or not.'
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
                    unit = 'pixels'
                ]
                varContainer.fields += factory.createIntegerField => [
                    name = 'shrinkHeight' + fieldSuffix
                    defaultValue = '600'
                    documentation = 'The maximum image height in pixels.'
                    unit = 'pixels'
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
                            unit = 'pixels'
                        ]
                        varContainer.fields += factory.createIntegerField => [
                            name = 'thumbnailHeight' + fieldSuffix + action.toFirstUpper
                            defaultValue = if (action == 'view') '24' else '180'
                            documentation = 'Thumbnail height on ' + action + ' pages in pixels.'
                            unit = 'pixels'
                        ]
                    }
                }
            }
        }

        variables += varContainer
    }

    def private addModerationSettings(Application it) {
        val entitiesWithApproval = getAllEntities.filter[workflow != EntityWorkflowType.NONE]
        val entitiesWithEditActionsAndStandardFields = getAllEntities.filter[hasEditAction && standardFields]
        if (entitiesWithApproval.empty && entitiesWithEditActionsAndStandardFields.empty) {
            return
        }

        val varContainer = createVarContainerForModerationSettings
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
        for (entity : entitiesWithEditActionsAndStandardFields) {
            varContainer.fields += factory.createBooleanField => [
                name = 'allowModerationSpecificCreatorFor' + entity.name.formatForCodeCapital
                defaultValue = 'false'
                documentation = 'Whether to allow moderators choosing a user which will be set as creator.'
                mandatory = false
            ]
            varContainer.fields += factory.createBooleanField => [
                name = 'allowModerationSpecificCreationDateFor' + entity.name.formatForCodeCapital
                defaultValue = 'false'
                documentation = 'Whether to allow moderators choosing a custom creation date.'
                mandatory = false
            ]
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
            defaultValue = '55.88'
            documentation = 'The default latitude.'
            numberType = NumberFieldType.FLOAT
        ]
        varContainer.fields += factory.createNumberField => [
            name = 'defaultLongitude'
            defaultValue = '12.36'
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
            documentation = 'URL of tile layer to use. See https://leaflet-extras.github.io/leaflet-providers/preview/ for examples.'
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

    def private addVersionControlSettings(Application it) {
        if (!hasLoggable) {
            return
        }

        val varContainer = createVarContainerForVersionControl
        val factory = ModuleStudioFactory.eINSTANCE

        val revisionHandlingItems = <ListFieldItem>newArrayList
        revisionHandlingItems += factory.createListFieldItem => [
            name = 'Unlimited revisions'
            value = 'unlimited'
            ^default = true
        ]
        revisionHandlingItems += factory.createListFieldItem => [
            name = 'Limited revisions by amount of revisions'
            value = 'limitedByAmount'
        ]
        revisionHandlingItems += factory.createListFieldItem => [
            name = 'Limited revisions by date interval'
            value = 'limitedByDate'
        ]

        val revisionAmountItems = <ListFieldItem>newArrayList
        for (amount : #[1, 5, 10, 25, 50, 100, 250, 500]) {
            revisionAmountItems += factory.createListFieldItem => [
                name = amount.toString
                value = amount.toString
                ^default = if (amount == 25) true else false
            ]
        }

        for (entity : getLoggableEntities) {
            var listField = factory.createListField => [
                name = 'revisionHandlingFor' + entity.name.formatForCodeCapital
                documentation = 'Adding a limitation to the revisioning will still keep the possibility to revert ' + entity.nameMultiple.formatForDisplay + ' to an older version. You will loose the possibility to inspect changes done earlier than the oldest stored revision though.'
                length = 20
                multiple = false
            ]
            listField.items.addAll(EcoreUtil.copyAll(revisionHandlingItems))
            varContainer.fields += listField

            listField = factory.createListField => [
                name = 'maximumAmountOf' + entity.name.formatForCodeCapital + 'Revisions'
                length = 5
                mandatory = false
                multiple = false
            ]
            listField.items.addAll(EcoreUtil.copyAll(revisionAmountItems))
            varContainer.fields += listField

            varContainer.fields += factory.createStringField => [
                name = 'periodFor' + entity.name.formatForCodeCapital + 'Revisions'
                defaultValue = 'P1Y0M0DT0H0M0S'
                mandatory = false
                role = StringRole.DATE_INTERVAL
            ]

            varContainer.fields += factory.createBooleanField => [
                name = 'show' + entity.name.formatForCodeCapital + 'History'
                defaultValue = 'true'
                documentation = 'Whether to show the version history to editors or not.'
                mandatory = false
            ]
        }

        variables += varContainer
    }

    def private createVarContainerForModerationSettings(Application it) {
        val newSortNumber = getNextVarContainerSortNumber
        ModuleStudioFactory.eINSTANCE.createVariables => [
            name = 'Moderation'
            documentation = 'Here you can define moderation-related settings.'
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

    def private createVarContainerForVersionControl(Application it) {
        val newSortNumber = getNextVarContainerSortNumber
        ModuleStudioFactory.eINSTANCE.createVariables => [
            name = 'Versioning'
            documentation = 'Here you can define settings related to version control.'
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
