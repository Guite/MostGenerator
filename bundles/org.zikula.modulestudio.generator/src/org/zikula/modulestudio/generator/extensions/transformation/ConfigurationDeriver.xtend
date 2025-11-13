package org.zikula.modulestudio.generator.extensions.transformation

import de.guite.modulestudio.metamodel.Application
import de.guite.modulestudio.metamodel.ListFieldItem
import de.guite.modulestudio.metamodel.ModuleStudioFactory
import de.guite.modulestudio.metamodel.NumberFieldType
import de.guite.modulestudio.metamodel.StringRole
import org.eclipse.emf.ecore.util.EcoreUtil
import org.zikula.modulestudio.generator.application.IMostFileSystemAccess
import org.zikula.modulestudio.generator.extensions.ControllerExtensions
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.Utils
import org.zikula.modulestudio.generator.application.config.AppConfig

/**
 * This class derives configuration settings from a given application model.
 */
class ConfigurationDeriver {

    extension ControllerExtensions = new ControllerExtensions
    extension FormattingExtensions = new FormattingExtensions
    extension ModelBehaviourExtensions = new ModelBehaviourExtensions
    extension ModelExtensions = new ModelExtensions
    extension Utils = new Utils

    AppConfig config
    ModuleStudioFactory factory

    /**
     * Derives configuration for given application.
     *
     * @param it The given {@link Application} instance
     * @param fsa The file system accessor
     */
    def derive(Application it, IMostFileSystemAccess fsa) {
        'Deriving configuration settings'.printIfNotTesting(fsa)

        config = new AppConfig
        factory = ModuleStudioFactory.eINSTANCE

        addViewSettings
        addImageSettings
        addModerationSettings
        addGeoSettings
        addVersionControlSettings

        config
    }

    def private addViewSettings(Application it) {
        val entitiesWithIndex = entities.filter[hasIndexAction]
        if (entitiesWithIndex.empty) {
            return
        }

        for (entity : entitiesWithIndex) {
            config.view.fields += factory.createNumberField => [
                name = entity.name.formatForCode + 'EntriesPerPage'
                defaultValue = '10'
                documentation = 'The amount of ' + entity.nameMultiple.formatForDisplay + ' shown per page.'
            ]
            if (entity.standardFields) {
                config.view.fields += factory.createBooleanField => [
                    name = 'linkOwn' + entity.nameMultiple.formatForCodeCapital + 'OnAccountPage'
                    defaultValue = 'true'
                    documentation = 'Whether to add a link to ' + entity.nameMultiple.formatForDisplay + ' of the current user on his account page.'
                    mandatory = false
                ]
            }
        }
        for (entity : entities.filter[ownerPermission]) {
            config.view.fields += factory.createBooleanField => [
                name = entity.name.formatForCode + 'PrivateMode'
                defaultValue = 'false'
                documentation = 'Whether users may only see own ' + entity.nameMultiple.formatForDisplay + '.'
                mandatory = false
            ]
        }
        if (!entities.filter[standardFields].empty) {
            config.view.fields += factory.createBooleanField => [
                name = 'showOnlyOwnEntries'
                defaultValue = 'false'
                documentation = 'Whether only own entries should be shown on index pages by default or not.'
                mandatory = false
            ]
        }
        if (supportLocaleFilter) {
            config.view.fields += factory.createBooleanField => [
                name = 'filterDataByLocale'
                defaultValue = 'false'
                documentation = 'Whether automatically filter data in the frontend based on the current locale or not.'
                mandatory = false
            ]
        }
    }

    def private addImageSettings(Application it) {
        if (!hasImageFields) {
            return
        }

        val entitiesWithImageUploads = entities.filter[hasImageFieldsEntity]
        for (entity : entitiesWithImageUploads) {
            for (imageUploadField : entity.imageFieldsEntity) {
                val fieldSuffix = entity.name.formatForCodeCapital + imageUploadField.name.formatForCodeCapital
                config.image.fields += factory.createBooleanField => [
                    name = 'enableShrinkingFor' + fieldSuffix
                    defaultValue = 'false'
                    documentation = 'Whether to enable shrinking huge images to maximum dimensions. Stores downscaled version of the original image.'
                    mandatory = false
                ]
                config.image.fields += factory.createNumberField => [
                    name = 'shrinkWidth' + fieldSuffix
                    defaultValue = '800'
                    documentation = 'The maximum image width in pixels.'
                    unit = 'pixels'
                ]
                config.image.fields += factory.createNumberField => [
                    name = 'shrinkHeight' + fieldSuffix
                    defaultValue = '600'
                    documentation = 'The maximum image height in pixels.'
                    unit = 'pixels'
                ]
            }
        }
    }

    def private addModerationSettings(Application it) {
        val entitiesWithApproval = entities.filter[approval]
        val entitiesWithEditActionsAndStandardFields = entities.filter[hasEditAction && standardFields]
        if (entitiesWithApproval.empty && entitiesWithEditActionsAndStandardFields.empty) {
            return
        }

        for (entity : entitiesWithApproval) {
            config.moderation.fields += factory.createNumberField => [
                name = 'moderationGroupFor' + entity.nameMultiple.formatForCodeCapital
                defaultValue = '2' // use admin group (gid=2) as fallback
                documentation = 'Used to determine moderator user accounts for sending email notifications.'
            ]
        }
        for (entity : entitiesWithEditActionsAndStandardFields) {
            config.moderation.fields += factory.createBooleanField => [
                name = 'allowModerationSpecificCreatorFor' + entity.name.formatForCodeCapital
                defaultValue = 'false'
                documentation = 'Whether to allow moderators choosing a user which will be set as creator.'
                mandatory = false
            ]
            config.moderation.fields += factory.createBooleanField => [
                name = 'allowModerationSpecificCreationDateFor' + entity.name.formatForCodeCapital
                defaultValue = 'false'
                documentation = 'Whether to allow moderators choosing a custom creation date.'
                mandatory = false
            ]
        }
    }

    def private addGeoSettings(Application it) {
        if (!hasGeographical) {
            return
        }

        config.geo.fields += factory.createNumberField => [
            name = 'defaultLatitude'
            numberType = NumberFieldType.DECIMAL
            defaultValue = '55.88'
            documentation = 'The default latitude.'
        ]
        config.geo.fields += factory.createNumberField => [
            name = 'defaultLongitude'
            numberType = NumberFieldType.DECIMAL
            defaultValue = '12.36'
            documentation = 'The default longitude.'
        ]
        config.geo.fields += factory.createNumberField => [
            name = 'defaultZoomLevel'
            defaultValue = '5'
            documentation = 'The default zoom level.'
        ]
        config.geo.fields += factory.createStringField => [
            name = 'tileLayerUrl'
            defaultValue = 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png'
            documentation = 'URL of tile layer to use. See https://leaflet-extras.github.io/leaflet-providers/preview/ for examples.'
        ]
        config.geo.fields += factory.createStringField => [
            name = 'tileLayerAttribution'
            defaultValue = '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors'
            documentation = 'Attribution for tile layer to use.'
        ]

        for (entity : getGeographicalEntities) {
            config.geo.fields += factory.createBooleanField => [
                name = 'enable' + entity.name.formatForCodeCapital + 'GeoLocation'
                defaultValue = 'false'
                documentation = 'Whether to enable geo location functionality for ' + entity.nameMultiple.formatForDisplay + ' or not.'
                mandatory = false
            ]
        }
    }

    def private addVersionControlSettings(Application it) {
        if (!hasLoggable) {
            return
        }

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
            config.versionControl.fields += listField

            listField = factory.createListField => [
                name = 'maximumAmountOf' + entity.name.formatForCodeCapital + 'Revisions'
                length = 5
                mandatory = false
                multiple = false
            ]
            listField.items.addAll(EcoreUtil.copyAll(revisionAmountItems))
            config.versionControl.fields += listField

            config.versionControl.fields += factory.createStringField => [
                name = 'periodFor' + entity.name.formatForCodeCapital + 'Revisions'
                defaultValue = 'P1Y0M0DT0H0M0S'
                mandatory = false
                role = StringRole.DATE_INTERVAL
            ]

            config.versionControl.fields += factory.createBooleanField => [
                name = 'show' + entity.name.formatForCodeCapital + 'History'
                defaultValue = 'true'
                documentation = 'Whether to show the version history to editors or not.'
                mandatory = false
            ]
        }
    }
}
