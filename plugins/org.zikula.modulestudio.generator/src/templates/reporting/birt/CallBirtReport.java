package templates.reporting.birt;

import org.eclipse.birt.core.framework.Platform;
import org.eclipse.birt.report.engine.api.EngineConfig;
import org.eclipse.birt.report.engine.api.HTMLRenderOption;
import org.eclipse.birt.report.engine.api.IReportEngine;
import org.eclipse.birt.report.engine.api.IReportEngineFactory;
import org.eclipse.birt.report.engine.api.IReportRunnable;
import org.eclipse.birt.report.engine.api.IRunAndRenderTask;

public class CallBirtReport {

    public static void test() {
        try {
            // http://wiki.eclipse.org/RCP_Example_%28BIRT%29_2.1
            // http://wiki.eclipse.org/Simple_Execute_%28BIRT%29_2.1
            final EngineConfig config = new EngineConfig();

            final IReportEngineFactory factory = (IReportEngineFactory) Platform
                    .createFactoryObject(IReportEngineFactory.EXTENSION_REPORT_ENGINE_FACTORY);
            final IReportEngine engine = factory.createReportEngine(config);

            IReportRunnable design = null;
            // Open the report design

            design = engine
                    .openReportDesign("/home/gabriel/workspace/Maturaprojekt/org.zikula.modulestudio.generator/src/templates/reporting/birt/testreport.rtpdesign");
            final IRunAndRenderTask task = engine
                    .createRunAndRenderTask(design);
            // task.setParameterValue("Top Count", (new Integer(5)));
            // task.validateParameters();

            final HTMLRenderOption options = new HTMLRenderOption();
            options.setOutputFileName("/home/gabriel/workspace/Maturaprojekt/examples/output/reporting/ValidationTest/birt.html");
            options.setOutputFormat("html");
            // options.setHtmlRtLFlag(false);
            // options.setEmbeddable(false);
            // options.setImageDirectory("C:\\test\\images");

            // PDFRenderOption options = new PDFRenderOption();
            // options.setOutputFileName("c:/temp/test.pdf");
            // options.setOutputFormat("pdf");

            task.setRenderOption(options);
            task.run();
            task.close();
            engine.destroy();

        } catch (final Exception ex) {
            ex.printStackTrace();
        }
    }
}
