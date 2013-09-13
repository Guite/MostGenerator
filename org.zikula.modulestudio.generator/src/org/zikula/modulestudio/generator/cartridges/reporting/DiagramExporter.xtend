package org.zikula.modulestudio.generator.cartridges.reporting

import de.guite.modulestudio.metamodel.modulestudio.Application
import de.guite.modulestudio.metamodel.modulestudio.Controllers
import de.guite.modulestudio.metamodel.modulestudio.Models
import de.guite.modulestudio.metamodel.modulestudio.Views
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
     * The diagram type (0 = main, 1 = model, 2 = controller, 3 = view).
     */
    Integer inputDiagramType

    /**
     * The output path chosen for generation.
     */
    String outputPath

    /**
     * Prefix for output files, will be set to application name.
     */
    String outputPrefix

    /**
     * Counter for iterating model sub diagrams.
     */
    Integer diagCounterM

    /**
     * Counter for iterating controller sub diagrams.
     */
    Integer diagCounterC

    /**
     * Counter for iterating view sub diagrams.
     */
    Integer diagCounterV

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
        inputDiagramType = 0
        preferencesHint = prefHint
        diagCounterM = 0
        diagCounterC = 0
        diagCounterV = 0

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
                        if (!saveCurrentDiagramInAllFormats((resourceElement as Diagram))) {
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
        val diagramElement = inputDiagram.element
        inputDiagramType = 0
        switch (diagramElement) {
            Models: {
                inputDiagramType = 1
                diagCounterM = diagCounterM + 1
            }
            Controllers: {
                inputDiagramType = 2
                diagCounterC = diagCounterC + 1
            }
            Views: {
                inputDiagramType = 3
                diagCounterV = diagCounterV + 1
            }
        }

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
        val diagramType = inputDiagramType
        var outputSuffix = '' //$NON-NLS-1$
        if (diagramType == 0) {
            outputSuffix = '_main' //$NON-NLS-1$
        } else if (diagramType == 1) {
            outputSuffix = '_model_' + diagCounterM //$NON-NLS-1$
        } else if (diagramType == 2) {
            outputSuffix = '_controller_' + diagCounterC //$NON-NLS-1$
        } else if (diagramType == 3) {
            outputSuffix = '_view_' + diagCounterV //$NON-NLS-1$
        }

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
     * Retrieve a resource set from a given application.
     * 
     * @param app
     *            The given application instance.
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
