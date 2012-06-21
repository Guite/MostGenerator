package org.zikula.modulestudio.generator.cartridges.reporting;

import java.io.File;

import org.eclipse.core.runtime.CoreException;
import org.eclipse.core.runtime.IPath;
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
import org.zikula.modulestudio.generator.application.WorkflowSettings;

import de.guite.modulestudio.metamodel.modulestudio.Application;
import de.guite.modulestudio.metamodel.modulestudio.Controllers;
import de.guite.modulestudio.metamodel.modulestudio.Models;
import de.guite.modulestudio.metamodel.modulestudio.Views;

/**
 * This class serves for exporting diagram files to image file formats.
 */
public class DiagramExporter {

    /**
     * The diagram type (0 = main, 1 = model, 2 = controller, 3 = view).
     */
    private Integer inputDiagramType;

    /**
     * The output path chosen for generation.
     */
    private String outputPath;

    /**
     * Prefix for output files, will be set to application name.
     */
    private String outputPrefix;

    /**
     * Counter for iterating model sub diagrams.
     */
    private Integer diagCounterM;

    /**
     * Counter for iterating controller sub diagrams.
     */
    private Integer diagCounterC;

    /**
     * Counter for iterating view sub diagrams.
     */
    private Integer diagCounterV;

    /**
     * Reference to workflow settings.
     */
    private WorkflowSettings settings;

    /**
     * Preferences hint.
     */
    private PreferencesHint preferencesHint;

    /**
     * The constructor.
     * 
     * @param wfSettings
     *            Given {@link WorkflowSettings} instance.
     */
    public DiagramExporter(WorkflowSettings wfSettings) {
        this.settings = wfSettings;
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
    public void processDiagram(Diagram appDiagram, String outPath,
            PreferencesHint prefHint) {
        // diagramExporterLock.getObjet().notifyAll();
        setInputDiagramType(0);
        setPreferencesHint(prefHint);
        setDiagCounterM(0);
        setDiagCounterC(0);
        setDiagCounterV(0);

        // create sub folder for diagrams
        setOutputPath(outPath + "/diagrams/"); //$NON-NLS-1$
        final File diagramDirectory = new File(getOutputPath());
        if (!diagramDirectory.exists()) {
            final boolean success = (diagramDirectory).mkdir();
            if (!success) {
                System.out.println("Error: could not create directory: "
                        + getOutputPath());
            }
        }

        final Application app = ((Application) appDiagram.getElement());
        setOutputPrefix(app.getName());

        // get resource set with all resources loaded in the editing domain
        final ResourceSet resourceSet = getResourceSetFromApp(app);
        final EList<Resource> resources = resourceSet.getResources();
        // go through all resources
        for (final Resource resource : resources) {
            // look for diagrams (notation models)
            final String resourceUri = resource.getURI().toString();
            if (!resourceUri.endsWith("mostdiagram")) { //$NON-NLS-1$
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
                if (!saveCurrentDiagramInAllFormats((Diagram) resourceElement)) {
                    System.out
                            .println("An error occured during exporting the diagram.");
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
    private boolean saveCurrentDiagramInAllFormats(Diagram inputDiagram) {
        final EObject diagramElement = inputDiagram.getElement();
        setInputDiagramType(0);
        if (diagramElement instanceof Models) {
            setInputDiagramType(1);
            setDiagCounterM(getDiagCounterM() + 1);
        }
        else if (diagramElement instanceof Controllers) {
            setInputDiagramType(2);
            setDiagCounterC(getDiagCounterC() + 1);
        }
        else if (diagramElement instanceof Views) {
            setInputDiagramType(3);
            setDiagCounterV(getDiagCounterV() + 1);
        }

        boolean result = false;
        try {
            result = saveCurrentDiagramAs(ImageFileFormat.BMP, inputDiagram);
            result = saveCurrentDiagramAs(ImageFileFormat.GIF, inputDiagram);
            result = saveCurrentDiagramAs(ImageFileFormat.JPG, inputDiagram);
            result = saveCurrentDiagramAs(ImageFileFormat.PDF, inputDiagram);
            result = saveCurrentDiagramAs(ImageFileFormat.PNG, inputDiagram);
            result = saveCurrentDiagramAs(ImageFileFormat.SVG, inputDiagram);
        } catch (final CoreException e) {
            // TODO Auto-generated catch block
            e.printStackTrace();
        }
        return result;
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
     *             In case an error occured.
     */
    private boolean saveCurrentDiagramAs(final ImageFileFormat format,
            final Diagram inputDiagram) throws CoreException {
        final int diagramType = getInputDiagramType();
        String outputSuffix = ""; //$NON-NLS-1$
        if (diagramType == 0) {
            outputSuffix = "_main"; //$NON-NLS-1$
        }
        else if (diagramType == 1) {
            outputSuffix = "_model_" + getDiagCounterM(); //$NON-NLS-1$
        }
        else if (diagramType == 2) {
            outputSuffix = "_controller_" + getDiagCounterC(); //$NON-NLS-1$
        }
        else if (diagramType == 3) {
            outputSuffix = "_view_" + getDiagCounterV(); //$NON-NLS-1$
        }

        final String filePath = getOutputPath() + getOutputPrefix()
                + outputSuffix + "." //$NON-NLS-1$
                + format.toString().toLowerCase();
        final IPath destination = new Path(filePath);

        try {
            new CopyToImageUtil().copyToImage(inputDiagram, destination,
                    format, getWorkflowSettings().getProgressMonitor(),
                    getPreferencesHint());
        } catch (final IllegalStateException e) {
            // TODO remove this try-catch-clause and find out the reason for
            // "Cannot modify resource set without a write transaction"
        }
        return true;
    }

    /**
     * Retrieve a resource set from a given application.
     * 
     * @param app
     *            The given application instance.
     * @return The determined resource set.
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

    /**
     * Returns the input diagram type.
     * 
     * @return the input diagram type.
     */
    public Integer getInputDiagramType() {
        return this.inputDiagramType;
    }

    /**
     * Sets the input diagram type.
     * 
     * @param idType
     *            the input diagram type to set.
     */
    public void setInputDiagramType(Integer idType) {
        this.inputDiagramType = idType;
    }

    /**
     * Returns the output path.
     * 
     * @return the output path.
     */
    public String getOutputPath() {
        return this.outputPath;
    }

    /**
     * Sets the output path.
     * 
     * @param path
     *            the output path to set.
     */
    public void setOutputPath(String path) {
        this.outputPath = path;
    }

    /**
     * Returns the output prefix.
     * 
     * @return the output prefix.
     */
    public String getOutputPrefix() {
        return this.outputPrefix;
    }

    /**
     * Sets the output prefix.
     * 
     * @param prefix
     *            the output prefix to set.
     */
    public void setOutputPrefix(String prefix) {
        this.outputPrefix = prefix;
    }

    /**
     * Returns the model diagram counter.
     * 
     * @return the model diagram counter.
     */
    public Integer getDiagCounterM() {
        return this.diagCounterM;
    }

    /**
     * Sets the model diagram counter.
     * 
     * @param counter
     *            the counter value to set.
     */
    public void setDiagCounterM(Integer counter) {
        this.diagCounterM = counter;
    }

    /**
     * Returns the controller diagram counter.
     * 
     * @return the controller diagram counter.
     */
    public Integer getDiagCounterC() {
        return this.diagCounterC;
    }

    /**
     * Sets the controller diagram counter.
     * 
     * @param counter
     *            the counter value to set.
     */
    public void setDiagCounterC(Integer counter) {
        this.diagCounterC = counter;
    }

    /**
     * Returns the view diagram counter.
     * 
     * @return the view diagram counter.
     */
    public Integer getDiagCounterV() {
        return this.diagCounterV;
    }

    /**
     * Sets the view diagram counter.
     * 
     * @param counter
     *            the counter value to set.
     */
    public void setDiagCounterV(Integer counter) {
        this.diagCounterV = counter;
    }

    /**
     * Returns the workflow settings.
     * 
     * @return the {@link WorkflowSettings} instance.
     */
    public WorkflowSettings getWorkflowSettings() {
        return this.settings;
    }

    /**
     * Sets the workflow settings.
     * 
     * @param wfSettings
     *            the {@link WorkflowSettings} instance to set.
     */
    public void setWorkflowSettings(WorkflowSettings wfSettings) {
        this.settings = wfSettings;
    }

    /**
     * Returns the preferences hint object.
     * 
     * @return the {@link PreferencesHint} instance.
     */
    public PreferencesHint getPreferencesHint() {
        return this.preferencesHint;
    }

    /**
     * Sets the preferences hint object.
     * 
     * @param prefHint
     *            the {@link PreferencesHint} instance to set.
     */
    public void setPreferencesHint(PreferencesHint prefHint) {
        this.preferencesHint = prefHint;
    }
}
