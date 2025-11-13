package org.zikula.modulestudio.generator.application.config

import org.eclipse.xtend.lib.annotations.Data

/**
 * Configuration settings representation.
 */
@Data
class AppConfig {

    ConfigSection view
    ConfigSection image
    ConfigSection moderation
    ConfigSection geo
    ConfigSection versionControl

    new() {
        view = new ConfigSection('ListViews', 'List views settings.')
        image = new ConfigSection('Images', 'Image handling settings.')
        moderation = new ConfigSection('Moderation', 'Moderation related settings.')
        geo = new ConfigSection('Geo', 'Settings related to geographical features.')
        versionControl = new ConfigSection('Versioning', 'Settings related to version control.')
    }

    def getSections() {
        #[view, image, moderation, geo, versionControl]
    }

    /**
     * Checks whether any configuration fields are required or not.
     *
     * @return Boolean The result
     */
    def isRelevant() {
        !configFields.empty
    }

    /**
     * Checks whether there exist multiple configuration sections.
     *
     * @return Boolean The result
     */
    def hasMultipleConfigSections() {
        configFields.size > 1
    }

    /**
     * Returns all variables for a given application.
     *
     * @return List<Variable> The selected list
     */
    def getConfigFields() {
        sections.map[fields].flatten.toList
    }
}
