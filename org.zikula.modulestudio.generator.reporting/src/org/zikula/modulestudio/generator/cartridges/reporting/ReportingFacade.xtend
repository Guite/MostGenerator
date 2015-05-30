package org.zikula.modulestudio.generator.cartridges.reporting

import java.io.File
import java.util.logging.Level
import org.eclipse.birt.core.framework.Platform
import org.eclipse.birt.report.engine.api.EngineConfig
import org.eclipse.birt.report.engine.api.EngineConstants
import org.eclipse.birt.report.engine.api.EngineException
import org.eclipse.birt.report.engine.api.IReportEngine
import org.eclipse.birt.report.engine.api.IReportEngineFactory
import org.eclipse.birt.report.engine.api.RenderOption
import org.eclipse.birt.report.engine.api.ReportEngine

/**
 * Facade class for the reporting cartridge.
 */
class ReportingFacade {

    /**
     * The output path.
     */
    String outputPath

    /**
     * The model path.
     */
    String modelPath

    /**
     * The {@link IReportEngine} reference.
     */
    IReportEngine engine = null

    /**
     * Sets up prerequisites.
     */
    def setUp() {
        try {
            // http://wiki.eclipse.org/RCP_Example_%28BIRT%29_2.1
            // http://wiki.eclipse.org/Simple_Execute_%28BIRT%29_2.1
            val config = new EngineConfig
            val hm = config.appContext
            hm.put(EngineConstants.APPCONTEXT_CLASSLOADER_KEY,
                    ReportEngine.classLoader)
            config.appContext = hm
            val reportPath = outputPath + '/reporting/' //$NON-NLS-1$
            val reportPathDir = new File(reportPath)
            if (!reportPathDir.exists && !reportPathDir.mkdir) {
                return
            }
            config.setLogConfig(reportPath, //$NON-NLS-1$
                    Level.WARNING)

            Platform.startup(config)
            val factory = Platform.createFactoryObject(IReportEngineFactory.EXTENSION_REPORT_ENGINE_FACTORY) as IReportEngineFactory
            engine = factory.createReportEngine(config)
        } catch (Exception ex) {
            ex.printStackTrace
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
    def startExport(String reportPath, String outputName) {
        try {
            singleExport(reportPath, outputName, 'html') //$NON-NLS-1$
            singleExport(reportPath, outputName, 'pdf') //$NON-NLS-1$
        } catch (Exception ex) {
            ex.printStackTrace
        }
    }

    /**
     * Does a single export for a certain file format.
     * 
     * @param reportPath
     *            The path to the report.
     * @param outputName
     *            Desired name of output file.
     * @param fileExtension
     *            Desired file format.
     */
    def private singleExport(String reportPath, String outputName, String fileExtension) throws EngineException {
        val task = engine.createRunAndRenderTask(engine.openReportDesign(reportPath))
        task.setParameterValue('modelPath', //$NON-NLS-1$
                'file:' + (modelPath)) //$NON-NLS-1$
        task.setParameterValue('diagramPath', //$NON-NLS-1$
                'file:' + (outputPath + '/diagrams/')) //$NON-NLS-1$ //$NON-NLS-2$

        var RenderOption renderOptions = new RenderOption
        renderOptions.outputFileName = outputPath + '/reporting/' + outputName + '.' + fileExtension //$NON-NLS-1$ //$NON-NLS-2$
        renderOptions.outputFormat = fileExtension
        task.renderOption = renderOptions
        task.run
        task.close
    }

    /**
     * Cleanup method.
     */
    def shutDown() {
        try {
            engine.destroy
            Platform.shutdown
        } catch (Exception ex) {
            ex.printStackTrace
        }
    }

    /**
     * Sets the output path.
     *
     * @param path The given path.
     */
    def void setOutputPath(String path) {
        outputPath = path
    }

    /**
     * Sets the model path.
     *
     * @param path The given path.
     */
    def void setModelPath(String path) {
        modelPath = path
    }
}
