package org.zikula.modulestudio.generator.extensions

import de.guite.modulestudio.metamodel.Application
import de.guite.modulestudio.metamodel.AuthMethodType
import de.guite.modulestudio.metamodel.CoreVersion

/**
 * This class contains several helper functions for accessing and using generator settings.
 */
class GeneratorSettingsExtensions {

    /**
     * Retrieves the target core version.
     */
    def getCoreVersion(Application it) {
        if (hasSettings) getSettings.targetCoreVersion else CoreVersion.ZK15
    }

    /**
     * Determines whether the model describes a system module or not.
     */
    def isSystemModule(Application it) {
        if (hasSettings) getSettings.isSystemModule else false
    }

    /**
     * Returns the desired amount of example rows created during installation.
     */
    def int amountOfExampleRows(Application it) {
        if (hasSettings) getSettings.amountOfExampleRows else 0
    }

    /**
     * Determines whether account panel integration should be generated or not.
     */
    def generateAccountApi(Application it) {
        if (hasSettings) getSettings.generateAccountApi else true
    }

    /**
     * Determines whether search integration should be generated or not.
     */
    def generateSearchApi(Application it) {
        if (hasSettings) getSettings.generateSearchApi else true
    }

    /**
     * Determines whether Mailz support should be generated or not.
     */
    def generateMailzApi(Application it) {
        if (hasSettings) getSettings.generateMailzApi else false
    }

    /**
     * Determines whether a generic list block should be generated or not.
     */
    def generateListBlock(Application it) {
        if (hasSettings) getSettings.generateListBlock else true
    }

    /**
     * Determines whether a moderation block should be generated or not.
     */
    def generateModerationBlock(Application it) {
        if (hasSettings) getSettings.generateModerationBlock else true
    }

    /**
     * Determines whether a content type for collection lists should be generated or not.
     */
    def generateListContentType(Application it) {
        if (hasSettings) getSettings.generateListContentType else true
    }

    /**
     * Determines whether a content type for single objects should be generated or not.
     */
    def generateDetailContentType(Application it) {
        if (hasSettings) getSettings.generateDetailContentType else true
    }

    /**
     * Determines whether a Newsletter plugin should be generated or not.
     */
    def generateNewsletterPlugin(Application it) {
        if (hasSettings) getSettings.generateNewsletterPlugin else false
    }

    /**
     * Determines whether a moderation panel should be generated or not.
     */
    def generateModerationPanel(Application it) {
        if (hasSettings) getSettings.generateModerationPanel else true
    }

    /**
     * Determines whether support for pending content should be generated or not.
     */
    def generatePendingContentSupport(Application it) {
        if (hasSettings) getSettings.generatePendingContentSupport else true
    }

    /**
     * Determines whether a controller for external calls providing a generic finder component should be generated or not.
     */
    def generateExternalControllerAndFinder(Application it) {
        if (hasSettings) getSettings.generateExternalControllerAndFinder else true
    }

    /**
     * Determines whether support for several Scribite editors should be generated or not.
     */
    def generateScribitePlugins(Application it) {
        if (hasSettings) getSettings.generateScribitePlugins else true
    }

    /**
     * Determines whether tag support should be generated or not.
     */
    def generateTagSupport(Application it) {
        if (hasSettings) getSettings.generateTagSupport else false
    }

    /**
     * Determines whether MultiHook needles should be generated or not.
     */
    def generateMultiHookNeedles(Application it) {
        if (hasSettings) getSettings.generateMultiHookNeedles else false
    }

    /**
     * Determines whether rss view templates should be generated or not.
     */
    def generateRssTemplates(Application it) {
        if (hasSettings) getSettings.generateRssTemplates else true
    }

    /**
     * Determines whether atom view templates should be generated or not.
     */
    def generateAtomTemplates(Application it) {
        if (hasSettings) getSettings.generateAtomTemplates else true
    }

    /**
     * Determines whether csv view templates should be generated or not.
     */
    def generateCsvTemplates(Application it) {
        if (hasSettings) getSettings.generateCsvTemplates else true
    }

    /**
     * Determines whether xml display and view templates should be generated or not.
     */
    def generateXmlTemplates(Application it) {
        if (hasSettings) getSettings.generateXmlTemplates else true
    }

    /**
     * Determines whether json templates should be generated or not.
     */
    def generateJsonTemplates(Application it) {
        if (hasSettings) getSettings.generateJsonTemplates else true
    }

    /**
     * Determines whether kml templates should be generated or not.
     */
    def generateKmlTemplates(Application it) {
        if (hasSettings) getSettings.generateKmlTemplates else true
    }

    /**
     * Determines whether ics templates should be generated or not.
     */
    def generateIcsTemplates(Application it) {
        if (hasSettings) getSettings.generateIcsTemplates else true
    }

    /**
     * Determines whether and which type of authentication method should be provided.
     */
    def authenticationMethod(Application it) {
        if (hasSettings) getSettings.authenticationMethod else AuthMethodType.NONE
    }

    /**
     * Determines whether only base classes should be generated.
     */
    def generateOnlyBaseClasses(Application it) {
        if (hasSettings) getSettings.generateOnlyBaseClasses else false
    }

    /**
     * Determines a blacklist with each entry representing a file which should not be generated.
     */
    def getListOfFilesToBeSkipped(Application it) {
        if (hasSettings && null !== getSettings.skipFiles) {
            getListOfAffectedFiles(getSettings.skipFiles)
        } else {
            newArrayList('')
        }
    }

    /**
     * Determines a list with file pathes which should be marked by special file names.
     */
    def getListOfFilesToBeMarked(Application it) {
        if (hasSettings && null !== getSettings.markFiles) {
            getListOfAffectedFiles(getSettings.markFiles)
        } else {
            newArrayList('')
        }
    }

    /**
     * Prepares a list of file pathes for further processing.
     */
    def private getListOfAffectedFiles(String setting) {
        var list = setting.replace("\t", '').replace("\n", '').split(',').toList
        for (i : 0 ..< list.size) {
            list.set(i, list.get(i).trim)
        }
        list
    }

    /**
     * Determines whether the generated by message should contain a timestamp
     * in all files or only in the Version class.
     */
    def timestampAllGeneratedFiles(Application it) {
        if (hasSettings) getSettings.timestampAllGeneratedFiles else false
    }

    /**
     * Determines whether the generated by message should contain the
     * ModuleStudio version in all files or only in the Version class.
     */
    def versionAllGeneratedFiles(Application it) {
        if (hasSettings) getSettings.versionAllGeneratedFiles else true
    }

    /**
     * Determines whether independent admin templates should be generated.
     */
    def generateSeparateAdminTemplates(Application it) {
        if (hasSettings) getSettings.separateAdminTemplates else false
    }

    /**
     * Determines whether generated footer templates should contain backlinks
     * to the ModuleStudio homepage.
     */
    def generatePoweredByBacklinksIntoFooterTemplates(Application it) {
        if (hasSettings) getSettings.generatePoweredByBacklinksIntoFooterTemplates else true
    }

    /**
     * Determines whether test cases should be generated or not.
     */
    def generateTests(Application it) {
        if (hasSettings) getSettings.generateTests else true
    }

    /**
     * Determines whether the model should be written into the docs folder or not.
     */
    def writeModelToDocs(Application it) {
        if (hasSettings) getSettings.writeModelToDocs else false
    }

    /**
     * Retrieves the SettingsContainer if present.
     */
    def private getSettings(Application it) {
        if (hasSettings) generatorSettings.head else null
    }

    /**
     * Determines whether the given Application instance has a settings container
     * or not.
     */
    def private hasSettings(Application it) {
        !generatorSettings.empty
    }
}
