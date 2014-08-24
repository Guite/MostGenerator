package org.zikula.modulestudio.generator.cartridges.reporting

import de.guite.modulestudio.metamodel.Application
import java.io.File
import org.eclipse.core.runtime.CoreException
import org.eclipse.core.runtime.Path
import org.eclipse.emf.ecore.resource.ResourceSet
import org.eclipse.gmf.runtime.diagram.core.preferences.PreferencesHint
import org.eclipse.gmf.runtime.diagram.ui.image.ImageFileFormat
import org.eclipse.gmf.runtime.diagram.ui.render.util.CopyToImageUtil
import org.eclipse.gmf.runtime.emf.core.resources.GMFResource
import org.eclipse.gmf.runtime.notation.Diagram
import org.zikula.modulestudio.generator.application.WorkflowSettings

/**
 * This class serves for exporting diagram files to image file formats.
 */
class DiagramExporter {

    /**
     * The output path chosen for generation.
     */
    String outputPath

    /**
     * Prefix for output files, will be set to application name.
     */
    String outputPrefix

    /**
     * Reference to workflow settings.
     */
    WorkflowSettings settings

    /**
     * Preferences hint.
     */
    PreferencesHint preferencesHint

    /**
     * The constructor.
     * 
     * @param wfSettings
     *            Given {@link WorkflowSettings} instance.
     */
    new(WorkflowSettings wfSettings) {
        settings = wfSettings
    }

    /**
     * Process an application diagram.
     * 
     * @param appDiagram
     *            Instance of {@link Diagram}.
     * @param outPath
     *            The desired output path.
     * @param prefHint
     *            Instance of {@link PreferencesHint}.
     */
    def processDiagram(Diagram appDiagram, String outPath,
            PreferencesHint prefHint) {
        // diagramExporterLock.objet).notifyAll)
        preferencesHint = prefHint

        // create sub folder for diagrams
        outputPath = outPath + '/diagrams/' //$NON-NLS-1$
        val diagramDirectory = new File(outputPath)
        if (!diagramDirectory.exists && !diagramDirectory.mkdir) {
            println('Error: could not create directory: ' + outputPath)
        }

        val app = appDiagram.element as Application
        outputPrefix = app.name

        // get resource set with all resources loaded in the editing domain
        val ResourceSet resourceSet = getResourceSetFromApp(app)
        val resources = resourceSet.resources
        // go through all resources
        for (resource : resources) {
            // look for diagrams (notation models)
            val resourceUri = resource.getURI.toString
            if (resourceUri.endsWith('mostdiagram') && resource instanceof GMFResource) { //$NON-NLS-1$
                // look for all contained diagrams, too
                // inputDiagram = resource.contents.head as Diagram
                for (resourceElement : resource.contents) {
                    if (resourceElement instanceof Diagram) {
                        if (!saveCurrentDiagramInAllFormats(resourceElement)) {
                            println('An error occurred during exporting the diagram.')
                        }
                    }
                }
            }
        }
    }

    /**
     * Exports the given {@link Diagram} into all possible file formats.
     * 
     * @param inputDiagram
     *            The given input diagram.
     * @return Whether everything worked fine or not.
     */
    def private saveCurrentDiagramInAllFormats(Diagram inputDiagram) {
        var result = false
        try {
            result = saveCurrentDiagramAs(ImageFileFormat.BMP, inputDiagram)
            result = saveCurrentDiagramAs(ImageFileFormat.GIF, inputDiagram)
            result = saveCurrentDiagramAs(ImageFileFormat.JPG, inputDiagram)
            result = saveCurrentDiagramAs(ImageFileFormat.PDF, inputDiagram)
            result = saveCurrentDiagramAs(ImageFileFormat.PNG, inputDiagram)
            result = saveCurrentDiagramAs(ImageFileFormat.SVG, inputDiagram)
        } catch (CoreException e) {
            // TODO Auto-generated catch block
            e.printStackTrace
        }
        result
    }

    /**
     * Exports the given {@link Diagram} into a certain {@link ImageFileFormat}.
     * 
     * @param format
     *            The given image file format.
     * @param inputDiagram
     *            The given input diagram.
     * @return Whether everything worked fine or not.
     * @throws CoreException
     *             In case an error occurred.
     */
    def private saveCurrentDiagramAs(ImageFileFormat format,
            Diagram inputDiagram) throws CoreException {
        val outputSuffix = '_main' //$NON-NLS-1$

        val filePath = outputPath + outputPrefix
                + outputSuffix + '.' //$NON-NLS-1$
                + format.toString.toLowerCase
        val destination = new Path(filePath)

        try {
            new CopyToImageUtil().copyToImage(inputDiagram, destination,
                    format, settings.getProgressMonitor,
                    preferencesHint)
        } catch (IllegalStateException e) {
            // TODO remove this try-catch-clause and find out the reason for
            // "Cannot modify resource set without a write transaction"
        }
        true
    }

    /**
     * Retrieve a resource set from a given {@link Application}.
     * 
     * @param app
     *            The given {@link Application} instance.
     * @return The determined resource set.
     */
    def private getResourceSetFromApp(Application app) {
        // get eResource from EObject
        val resource = app.eResource

        // get ResourceSet from eResource
        val resourceSet = resource.resourceSet

        // get editing domain
        //val domain = TransactionalEditingDomain_Factory.INSTANCE.createEditingDomain(resourceSet)

        resourceSet
    }
}
