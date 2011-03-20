package org.zikula.modulestudio.generator.output;

import java.io.File;

import org.eclipse.core.runtime.CoreException;
import org.eclipse.core.runtime.IPath;
import org.eclipse.core.runtime.NullProgressMonitor;
import org.eclipse.core.runtime.Path;
import org.eclipse.emf.common.util.EList;
import org.eclipse.emf.ecore.EObject;
import org.eclipse.emf.ecore.resource.Resource;
import org.eclipse.emf.ecore.resource.ResourceSet;
import org.eclipse.emf.transaction.TransactionalEditingDomain;
import org.eclipse.gmf.runtime.diagram.core.preferences.PreferencesHint;
import org.eclipse.gmf.runtime.diagram.ui.image.ImageFileFormat;
import org.eclipse.gmf.runtime.diagram.ui.render.util.CopyToImageUtil;
import org.eclipse.gmf.runtime.emf.core.resources.GMFResource;
import org.eclipse.gmf.runtime.notation.Diagram;
import org.zikula.modulestudio.generator.application.ManualProgressMonitor;

import de.guite.modulestudio.metamodel.modulestudio.Application;
import de.guite.modulestudio.metamodel.modulestudio.Controllers;
import de.guite.modulestudio.metamodel.modulestudio.Models;
import de.guite.modulestudio.metamodel.modulestudio.Views;

/**
 * Class for exporting diagram files to image file formats.
 */
/** TODO: javadocs needed for class, members and methods */
public class DiagramExporter {

    /** reference to currently treated diagram */
    private Diagram inputDiagram;

    /** diagram type (0 = main, 1 = model, 2 = controller, 3 = view) */
    private Integer inputDiagramType;

    /** the output path chosen for generation */
    private String outputPath;

    /** prefix for output files, will be set to app name */
    private String outputPrefix;

    /** counter for iterating model sub diagrams */
    private Integer diagCounterM;
    /** counter for iterating controller sub diagrams */
    private Integer diagCounterC;
    /** counter for iterating view sub diagrams */
    private Integer diagCounterV;

    /** reference to helper class */
    private final CopyToImageUtil copyUtil;

    private PreferencesHint preferencesHint;

    public DiagramExporter() {
        // instantiate utility class to render a diagram to an image file
        copyUtil = new CopyToImageUtil();
    }

    public void processDiagram(Diagram appDiagram, String outPath,
            PreferencesHint prefHint) {
        inputDiagram = appDiagram;
        inputDiagramType = 0;
        preferencesHint = prefHint;
        diagCounterM = diagCounterC = diagCounterV = 0;

        // create sub folder for diagrams
        outputPath = outPath + "/diagrams/";
        final File diagramDirectory = new File(outputPath);
        if (!diagramDirectory.exists()) {
            final boolean success = (diagramDirectory).mkdir();
            if (!success) {
                System.out.println("Error: could not create directory: "
                        + outputPath);
            }
        }

        final Application app = ((Application) inputDiagram.getElement());
        outputPrefix = app.getName();

        // get resource set with all resources loaded in the editing domain
        final ResourceSet resourceSet = getResourceSetFromApp(app);
        final EList<Resource> resources = resourceSet.getResources();
        // go through all resources
        for (final Resource resource : resources) {
            // look for diagrams (notation models)
            final String resourceUri = resource.getURI().toString();
            if (!resourceUri.endsWith("mostdiagram")) {
                continue;
            }
            if (!(resource instanceof GMFResource)) {
                continue;
            }

            // look for all contained diagrams, too
            // inputDiagram = (Diagram) resource.getContents().get(0);
            for (final Object resourceElement : resource.getContents()) {
                if (!(resourceElement instanceof Diagram)) {
                    continue;
                }
                inputDiagram = (Diagram) resourceElement;
                if (!saveCurrentDiagramInAllFormats()) {
                    System.out
                            .println("An error occured during exporting the diagram.");
                }
            }
        }
    }

    private boolean saveCurrentDiagramInAllFormats() {
        final EObject diagramElement = inputDiagram.getElement();
        inputDiagramType = 0;
        if (diagramElement instanceof Models) {
            inputDiagramType = 1;
            diagCounterM++;
        }
        else if (diagramElement instanceof Controllers) {
            inputDiagramType = 2;
            diagCounterC++;
        }
        else if (diagramElement instanceof Views) {
            inputDiagramType = 3;
            diagCounterV++;
        }

        boolean result = false;
        result = saveCurrentDiagramAs(ImageFileFormat.BMP);
        result = saveCurrentDiagramAs(ImageFileFormat.GIF);
        result = saveCurrentDiagramAs(ImageFileFormat.JPG);
        result = saveCurrentDiagramAs(ImageFileFormat.PDF);
        result = saveCurrentDiagramAs(ImageFileFormat.PNG);
        result = saveCurrentDiagramAs(ImageFileFormat.SVG);
        return result;
    }

    private boolean saveCurrentDiagramAs(final ImageFileFormat format) {
        final ManualProgressMonitor monitor = new ManualProgressMonitor();

        String outputSuffix = "";
        if (inputDiagramType == 0) {
            outputSuffix = "_main";
        }
        else if (inputDiagramType == 1) {
            outputSuffix = "_model_" + diagCounterM;
        }
        else if (inputDiagramType == 2) {
            outputSuffix = "_controller_" + diagCounterC;
        }
        else if (inputDiagramType == 3) {
            outputSuffix = "_view_" + diagCounterV;
        }

        final String filePath = outputPath + outputPrefix + outputSuffix + "."
                + format.toString().toLowerCase();
        final IPath destination = new Path(filePath);

        try {
            new CopyToImageUtil().copyToImage(inputDiagram, destination,
                    format, new NullProgressMonitor(), preferencesHint);
            return true;
        } catch (final CoreException e) {
            // TODO Auto-generated catch block
            e.printStackTrace();
        }
        return false;
    }

    /**
     * Retrieve a resource set from a given application.
     * 
     * @param app
     * @return
     */
    private ResourceSet getResourceSetFromApp(Application app) {
        // get eResource from EObject
        final Resource resource = app.eResource();

        // get ResourceSet from eResource
        final ResourceSet resourceSet = resource.getResourceSet();

        // get editing domain
        final TransactionalEditingDomain domain = TransactionalEditingDomain.Factory.INSTANCE
                .createEditingDomain(resourceSet);

        return resourceSet;
    }
}
