package templates.reporting.birt;

import org.eclipse.birt.core.framework.Platform;
import org.eclipse.birt.report.engine.api.EngineConfig;
import org.eclipse.birt.report.engine.api.HTMLRenderOption;
import org.eclipse.birt.report.engine.api.IReportEngine;
import org.eclipse.birt.report.engine.api.IReportEngineFactory;
import org.eclipse.birt.report.engine.api.IReportRunnable;
import org.eclipse.birt.report.engine.api.IRunAndRenderTask;

public class CallBirtReport {
    public static void main() {
        test();
    }

    public static void test() {

        IReportEngine engine = null;
        EngineConfig config = null;

        try {
            // http://wiki.eclipse.org/RCP_Example_%28BIRT%29_2.1
            // http://wiki.eclipse.org/Simple_Execute_%28BIRT%29_2.1
            config = new EngineConfig();

            // use this to set the resource path
            // final Bundle bundle =
            // org.eclipse.core.runtime.Platform.getBundle("templates.reporting.birt");
            // System.out.println(bundle);
            // final URL url = FileLocator.find(bundle, new
            // Path("/ReportEngine"), null);

            // final String myresourcepath =
            // FileLocator.toFileURL(url).getPath();
            // config.setResourcePath(myresourcepath);

            config.setBIRTHome("/home/gabriel/workspace/Maturaprojekt/org.zikula.modulestudio.generator/src/templates/reporting/birt/ReportEngine");

            Platform.startup(config);
            final IReportEngineFactory factory = (IReportEngineFactory) Platform
                    .createFactoryObject(IReportEngineFactory.EXTENSION_REPORT_ENGINE_FACTORY);
            engine = factory.createReportEngine(config);

            IReportRunnable design = null;
            // Open the report design

            design = engine
                    .openReportDesign("/home/gabriel/workspace/Maturaprojekt/org.zikula.modulestudio.generator/src/templates/reporting/birt/testreport.rptdesign");
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
