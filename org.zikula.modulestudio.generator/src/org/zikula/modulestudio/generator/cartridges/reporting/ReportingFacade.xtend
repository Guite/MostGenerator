package org.zikula.modulestudio.generator.cartridges.reporting

import java.util.logging.Level
import org.eclipse.birt.core.framework.Platform
import org.eclipse.birt.report.engine.api.EngineConfig
import org.eclipse.birt.report.engine.api.EngineConstants
import org.eclipse.birt.report.engine.api.IReportEngine
import org.eclipse.birt.report.engine.api.IReportEngineFactory
import org.eclipse.birt.report.engine.api.IRunAndRenderTask
import org.eclipse.birt.report.engine.api.PDFRenderOption
import org.eclipse.birt.report.engine.api.ReportEngine

/**
 * Facade class for the reporting cartridge.
 */
public class ReportingFacade {

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
     * Report engine configuration object.
     */
    EngineConfig config = null

    /**
     * The {@link IRunAndRenderTask} reference.
     */
    IRunAndRenderTask task = null

    /**
     * PDF render options.
     */
    PDFRenderOption pdfRenderOptions = null

    /**
     * Sets up prerequisites.
     */
    def setUp() {
        try {
            // http://wiki.eclipse.org/RCP_Example_%28BIRT%29_2.1
            // http://wiki.eclipse.org/Simple_Execute_%28BIRT%29_2.1
            config = new EngineConfig()
            val hm = config.appContext
            hm.put(EngineConstants::APPCONTEXT_CLASSLOADER_KEY,
                    typeof(ReportEngine).classLoader)
            config.appContext = hm
            config.setLogConfig(outputPath + '/reporting/', //$NON-NLS-1$
                    Level::WARNING)

            Platform::startup(config)
            val factory = Platform::createFactoryObject(IReportEngineFactory::EXTENSION_REPORT_ENGINE_FACTORY) as IReportEngineFactory
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
            // diagramExporterLock.objet.wait
            task = engine.createRunAndRenderTask(engine.openReportDesign(reportPath))
            task.setParameterValue('modelPath', //$NON-NLS-1$
                    'file:' + (modelPath.toString)) //$NON-NLS-1$
            task.setParameterValue('diagramPath', //$NON-NLS-1$
                    'file:' + (outputPath + '/diagrams/')) //$NON-NLS-1$ //$NON-NLS-2$

            pdfRenderOptions = new PDFRenderOption()
            pdfRenderOptions.outputFileName = outputPath + '/reporting/' + outputName //$NON-NLS-1$
            pdfRenderOptions.outputFormat = 'pdf' //$NON-NLS-1$

            task.renderOption = pdfRenderOptions
            task.run

        } catch (Exception ex) {
            ex.printStackTrace
        }
    }

    /**
     * Cleanup method.
     */
    def shutDown() {
        try {
            task.close
            engine.destroy
            Platform::shutdown
        } catch (Exception ex) {
            ex.printStackTrace
        }
    }

    /**
     * Sets the output path.
     *
     * @param path The given path.
     */
    def setOutputPath(String path) {
        outputPath = path
    }

    /**
     * Sets the model path.
     *
     * @param path The given path.
     */
    def setModelPath(String path) {
        outputPath = path
    }
}
