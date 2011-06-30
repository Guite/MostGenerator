package org.zikula.modulestudio.generator;

import java.io.File;
import java.io.IOException;

import org.eclipse.core.runtime.FileLocator;
import org.eclipse.core.runtime.Path;
import org.eclipse.core.runtime.Platform;
import org.eclipse.emf.mwe.utils.FileCopy;
import org.osgi.framework.Bundle;
import org.zikula.modulestudio.generator.application.Activator;

/** TODO: javadocs needed for class, members and methods */
public class WorkflowZClassic {
    WorkflowSettings settings;

    public WorkflowZClassic(WorkflowSettings settings) {
        this.settings = settings;
    }

    public void run() {
        // copy admin image
        final FileCopy fileCopy = new FileCopy();
        final Bundle bundle = Platform.getBundle(Activator.PLUGIN_ID);
        final java.net.URL[] resources = FileLocator.findEntries(bundle,
                new Path(
                /* "src" + */"/resources/images/MOST_48.png"));
        if (resources.length > 0) {
            try {
                final java.net.URL url = resources[0];
                final java.net.URL fileUrl = FileLocator.toFileURL(url);
                final File file = new File(fileUrl.getPath());
                fileCopy.setSourceFile(file.getAbsolutePath());
                fileCopy.setTargetFile(this.settings.outputPath + "/zclassic/"
                        + this.settings.app.getName() + "/src/modules/"
                        + this.settings.app.getName() + "/images/admin.png");
                fileCopy.invoke(null);
            } catch (final IOException e) {
                // TODO Auto-generated catch block
                e.printStackTrace();
            }
        }
    }
}
