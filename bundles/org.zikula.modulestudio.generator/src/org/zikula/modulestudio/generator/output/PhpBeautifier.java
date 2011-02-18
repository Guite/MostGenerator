package org.zikula.modulestudio.generator.output;

import java.io.File;

import org.eclipse.core.runtime.CoreException;
import org.eclipse.xpand2.output.FileHandle;
import org.eclipse.xpand2.output.PostProcessor;
import org.zikula.modulestudio.generator.beautifier.formatter.FormatterFacade;

public class PhpBeautifier implements PostProcessor {

    /** Formatter instance. */
    private FormatterFacade codeFormatter;

    /**
     * Formats the file. It must have the extension .php, .php4 or php5
     * 
     * @param info
     *            - A handle to the file that will be written
     */
    @Override
    public void beforeWriteAndClose(final FileHandle info) {
        if (info.getAbsolutePath() == null
                || !info.getAbsolutePath().endsWith(".php")) {
            return;
        }

        final String filePath = info.getAbsolutePath();
        // System.out.println("File path: " + filePath);
        try {
            getCodeFormatter().formatFile(new File(filePath));
        } catch (final CoreException e) {
            // TODO Auto-generated catch block
            e.printStackTrace();
        }
    }

    /**
     * Returns an instance of the Eclipse code formatter. If the user supplied
     * the path to a config file, this file will be used to configure the code
     * formatter. Otherwise we use the default options supplied with Xpand.
     * 
     * @return a preconfigured instance of the Eclipse code formatter.
     */
    private FormatterFacade getCodeFormatter() {
        if (codeFormatter == null) {
            codeFormatter = new FormatterFacade();
        }
        return codeFormatter;
    }

    /**
     * Called after the file has been written.
     * 
     * @param impl
     *            - A handle to the file that has been written
     */
    @Override
    public void afterClose(final FileHandle impl) {
        // do nothing here
    }
}
