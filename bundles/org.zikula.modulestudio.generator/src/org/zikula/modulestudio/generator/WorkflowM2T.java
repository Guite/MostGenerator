package org.zikula.modulestudio.generator;

import java.io.IOException;

import org.zikula.modulestudio.generator.application.ModuleStudioGenerator;
import org.zikula.modulestudio.generator.exceptions.ExceptionBase;
import org.zikula.modulestudio.generator.exceptions.M2TFailedCartridgeIncomplete;
import org.zikula.modulestudio.generator.exceptions.M2TFailedGeneratorResourceNotFound;
import org.zikula.modulestudio.generator.exceptions.M2TUnknownException;

/** TODO: javadocs needed for class, members and methods */
public class WorkflowM2T {
    WorkflowSettings settings;

    public WorkflowM2T(WorkflowSettings settings) {
        this.settings = settings;
    }

    public void run() throws ExceptionBase {
        try {
            // instantiate generator with Application instance
            // and progress monitor
            final ModuleStudioGenerator msGen = new ModuleStudioGenerator(
                    this.settings.app, this.settings.progressMonitor);

            for (final Object singleCartridge : this.settings.selectedCartridges) {
                if (singleCartridge.toString() != "reporting") {
                    // run workflow
                    final boolean generateResult = msGen.runWorkflow(
                            this.settings.outputPath,
                            singleCartridge.toString());

                    if (!generateResult) {
                        throw new M2TFailedCartridgeIncomplete(
                                singleCartridge.toString());

                    }
                }
            }
        } catch (final IOException e) {
            throw new M2TFailedGeneratorResourceNotFound();
        } catch (final Exception e) {
            throw new M2TUnknownException();
        }
    }
}
