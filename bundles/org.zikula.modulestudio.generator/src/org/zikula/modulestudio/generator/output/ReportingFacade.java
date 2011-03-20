package org.zikula.modulestudio.generator.output;

import java.util.HashMap;

import org.eclipse.birt.core.framework.Platform;
import org.eclipse.birt.report.engine.api.EngineConfig;
import org.eclipse.birt.report.engine.api.EngineConstants;
import org.eclipse.birt.report.engine.api.IReportEngine;
import org.eclipse.birt.report.engine.api.IReportEngineFactory;
import org.eclipse.birt.report.engine.api.IRunAndRenderTask;
import org.eclipse.birt.report.engine.api.PDFRenderOption;
import org.eclipse.birt.report.engine.api.ReportEngine;

public class ReportingFacade {

    String outputPath;
    String modelPath;
    IReportEngine engine = null;
    EngineConfig config = null;
    IRunAndRenderTask task = null;
    PDFRenderOption options = null;

    public void setOutputPath(String path) {
        this.outputPath = path;
    }

    public void setModelPath(String path) {
        this.modelPath = path;
    }

    public void setUp() {
        try {
            // http://wiki.eclipse.org/RCP_Example_%28BIRT%29_2.1
            // http://wiki.eclipse.org/Simple_Execute_%28BIRT%29_2.1
            config = new EngineConfig();
            final HashMap hm = config.getAppContext();
            hm.put(EngineConstants.APPCONTEXT_CLASSLOADER_KEY,
                    ReportEngine.class.getClassLoader());
            config.setAppContext(hm);

            Platform.startup(config);
            final IReportEngineFactory factory = (IReportEngineFactory) Platform
                    .createFactoryObject(IReportEngineFactory.EXTENSION_REPORT_ENGINE_FACTORY);
            engine = factory.createReportEngine(config);
        } catch (final Exception ex) {
            ex.printStackTrace();
        }

    }

    public void startExport(String reportPath, String outputName) {
        try {

            task = engine.createRunAndRenderTask(engine
                    .openReportDesign(reportPath));
            System.out.println("Generating Report: " + outputName);
            task.setParameterValue("modelPath",
                    "file:" + (this.modelPath.toString()));
            options = new PDFRenderOption();
            options.setOutputFileName(this.outputPath + "/" + outputName);
            options.setOutputFormat("pdf");

            task.setRenderOption(options);
            task.run();

        } catch (final Exception ex) {
            ex.printStackTrace();
        }
    }

    public void shutDown() {
        try {
            task.close();
            engine.destroy();
            Platform.shutdown();
        } catch (final Exception ex) {
            ex.printStackTrace();
        }
    }
}
