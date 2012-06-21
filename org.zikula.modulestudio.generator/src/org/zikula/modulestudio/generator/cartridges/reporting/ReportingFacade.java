package org.zikula.modulestudio.generator.cartridges.reporting;

import java.util.HashMap;
import java.util.logging.Level;

import org.eclipse.birt.core.framework.Platform;
import org.eclipse.birt.report.engine.api.EngineConfig;
import org.eclipse.birt.report.engine.api.EngineConstants;
import org.eclipse.birt.report.engine.api.IReportEngine;
import org.eclipse.birt.report.engine.api.IReportEngineFactory;
import org.eclipse.birt.report.engine.api.IRunAndRenderTask;
import org.eclipse.birt.report.engine.api.PDFRenderOption;
import org.eclipse.birt.report.engine.api.ReportEngine;

/**
 * Facade class for the reporting cartridge.
 */
public class ReportingFacade {

    /**
     * The output path.
     */
    String outputPath;

    /**
     * The model path.
     */
    String modelPath;

    /**
     * The {@link IReportEngine} reference.
     */
    private IReportEngine engine = null;

    /**
     * Report engine configuration object.
     */
    private EngineConfig config = null;

    /**
     * The {@link IRunAndRenderTask} reference.
     */
    private IRunAndRenderTask task = null;

    /**
     * PDF render options.
     */
    private PDFRenderOption options = null;

    /**
     * Sets up prerequisites.
     */
    public void setUp() {
        try {
            // http://wiki.eclipse.org/RCP_Example_%28BIRT%29_2.1
            // http://wiki.eclipse.org/Simple_Execute_%28BIRT%29_2.1
            setConfig(new EngineConfig());
            final HashMap hm = getConfig().getAppContext();
            hm.put(EngineConstants.APPCONTEXT_CLASSLOADER_KEY,
                    ReportEngine.class.getClassLoader());
            getConfig().setAppContext(hm);
            getConfig().setLogConfig(this.outputPath + "/reporting/", //$NON-NLS-1$
                    Level.WARNING);

            Platform.startup(getConfig());
            final IReportEngineFactory factory = (IReportEngineFactory) Platform
                    .createFactoryObject(IReportEngineFactory.EXTENSION_REPORT_ENGINE_FACTORY);
            setEngine(factory.createReportEngine(getConfig()));
        } catch (final Exception ex) {
            ex.printStackTrace();
        }

    }

    /**
     * Starts the export of a certain report to a given output name.
     * 
     * @param reportPath
     *            The path to the report.
     * @param outputName
     *            Desired name of output file.
     */
    public void startExport(String reportPath, String outputName) {
        try {
            // diagramExporterLock.getObjet().wait();
            setTask(getEngine().createRunAndRenderTask(
                    getEngine().openReportDesign(reportPath)));
            getTask().setParameterValue("modelPath", //$NON-NLS-1$
                    "file:" + (this.modelPath.toString())); //$NON-NLS-1$
            getTask().setParameterValue("diagramPath", //$NON-NLS-1$
                    "file:" + (this.outputPath + "/diagrams/")); //$NON-NLS-1$ //$NON-NLS-2$
            setPdfOptions(new PDFRenderOption());
            getPdfOptions().setOutputFileName(this.outputPath + "/reporting/" //$NON-NLS-1$
                    + outputName);
            getPdfOptions().setOutputFormat("pdf"); //$NON-NLS-1$

            getTask().setRenderOption(getPdfOptions());
            getTask().run();

        } catch (final Exception ex) {
            ex.printStackTrace();
        }
    }

    /**
     * Cleanup method.
     */
    public void shutDown() {
        try {
            getTask().close();
            getEngine().destroy();
            Platform.shutdown();
        } catch (final Exception ex) {
            ex.printStackTrace();
        }
    }

    /**
     * Sets the output path.
     * 
     * @param path
     *            Given path string.
     */
    public void setOutputPath(String path) {
        this.outputPath = path;
    }

    /**
     * Sets the model path.
     * 
     * @param path
     *            Given path string.
     */
    public void setModelPath(String path) {
        this.modelPath = path;
    }

    /**
     * Returns the report engine object.
     * 
     * @return the {@link IReportEngine} instance.
     */
    public IReportEngine getEngine() {
        return this.engine;
    }

    /**
     * Sets the report engine object.
     * 
     * @param newEngine
     *            the {@link IReportEngine} instance to set.
     */
    public void setEngine(IReportEngine newEngine) {
        this.engine = newEngine;
    }

    /**
     * Returns the report engine configuration object.
     * 
     * @return the {@link EngineConfig} instance.
     */
    public EngineConfig getConfig() {
        return this.config;
    }

    /**
     * Sets the report engine configuration object.
     * 
     * @param newConfig
     *            the {@link EngineConfig} instance to set.
     */
    public void setConfig(EngineConfig newConfig) {
        this.config = newConfig;
    }

    /**
     * Returns the task object.
     * 
     * @return the {@link IRunAndRenderTask} instance.
     */
    public IRunAndRenderTask getTask() {
        return this.task;
    }

    /**
     * Sets the task object.
     * 
     * @param newTask
     *            the {@link IRunAndRenderTask} instance to set.
     */
    public void setTask(IRunAndRenderTask newTask) {
        this.task = newTask;
    }

    /**
     * Returns the pdf options object.
     * 
     * @return the {@link PDFRenderOption} instance.
     */
    public PDFRenderOption getPdfOptions() {
        return this.options;
    }

    /**
     * Sets the pdf options object.
     * 
     * @param pdfOptions
     *            the {@link PDFRenderOption} instance to set.
     */
    public void setPdfOptions(PDFRenderOption pdfOptions) {
        this.options = pdfOptions;
    }
}
