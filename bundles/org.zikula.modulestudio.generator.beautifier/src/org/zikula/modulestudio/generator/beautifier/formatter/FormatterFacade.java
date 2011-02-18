package org.zikula.modulestudio.generator.beautifier.formatter;

import java.io.File;

import org.eclipse.ui.IEditorPart;
import org.eclipse.ui.WorkbenchException;

public class FormatterFacade {

    private IEditorPart currentEditor;
    private SimpleContentFormatter formatter;

    /**
     * Process a single file
     * 
     * @param file
     * @throws WorkbenchException
     */
    public void formatFile(File file) throws WorkbenchException {
        final SimpleContentFormatter formatter = getFormatter();
        formatter.format(file);
    }

    /**
     * @return the formatter
     */
    public SimpleContentFormatter getFormatter() {
        if (formatter == null) {
            formatter = new SimpleContentFormatter();
        }
        return formatter;
    }

    /**
     * @param formatter
     *            the formatter to set
     */
    protected void setFormatter(SimpleContentFormatter formatter) {
        this.formatter = formatter;
    }
}
