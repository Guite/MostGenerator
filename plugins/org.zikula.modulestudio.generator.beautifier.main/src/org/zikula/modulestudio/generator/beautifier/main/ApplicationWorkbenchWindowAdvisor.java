package org.zikula.modulestudio.generator.beautifier.main;

import java.io.File;
import java.util.Vector;

import org.eclipse.core.runtime.CoreException;
import org.eclipse.swt.graphics.Point;
import org.eclipse.ui.PlatformUI;
import org.eclipse.ui.application.ActionBarAdvisor;
import org.eclipse.ui.application.IActionBarConfigurer;
import org.eclipse.ui.application.IWorkbenchWindowConfigurer;
import org.eclipse.ui.application.WorkbenchWindowAdvisor;
import org.zikula.modulestudio.generator.beautifier.GeneratorFileUtil;
import org.zikula.modulestudio.generator.beautifier.formatter.FormatterFacade;

public class ApplicationWorkbenchWindowAdvisor extends WorkbenchWindowAdvisor {

    public ApplicationWorkbenchWindowAdvisor(
            IWorkbenchWindowConfigurer configurer) {
        super(configurer);
    }

    @Override
    public ActionBarAdvisor createActionBarAdvisor(
            IActionBarConfigurer configurer) {
        return new ApplicationActionBarAdvisor(configurer);
    }

    @Override
    public void preWindowOpen() {
        final IWorkbenchWindowConfigurer configurer = getWindowConfigurer();
        configurer.setInitialSize(new Point(400, 300));
        configurer.setShowCoolBar(false);
        configurer.setShowStatusLine(false);
        configurer.setTitle("Standalone Beautifier Application"); //$NON-NLS-1$
    }

    @Override
    public void postWindowOpen() {
        Integer numFiles = 0;
        try {
            numFiles = startBeautifier();
        } catch (final CoreException e) {
            // TODO Auto-generated catch block
            e.printStackTrace();
        }
        PlatformUI.getWorkbench().close();
        System.out.println("Done: beautified " + numFiles + " php files.");
    }

    public Integer startBeautifier() throws CoreException {
        final String rootPath = "/home/axel/Beautifier_TestFiles/";
        final File dir = new File(rootPath);

        // retrieve files
        final Vector<File> fileList = new Vector<File>();
        GeneratorFileUtil.getRecursivePhpFiles(dir, fileList);

        // initialize formatter class
        final FormatterFacade beautifier = new FormatterFacade();
        // process files
        for (final File file : fileList) {
            beautifier.formatFile(file);
        }
        // Success, return amount of processed files
        return fileList.size();
    }
}
