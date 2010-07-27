package org.zikula.modulestudio.generator.application;

import java.io.File;
import java.util.Vector;

import org.eclipse.core.runtime.CoreException;
import org.zikula.modulestudio.generator.beautifier.GeneratorFileUtil;
import org.zikula.modulestudio.generator.beautifier.formatter.FormatterFacade;

public class ModuleStudioBeautifier {
    private String rootPath = "";

    public ModuleStudioBeautifier(String targetDir) {
        rootPath = targetDir;
    }

    public Integer start() throws CoreException {
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
        return fileList.size();
    }
}
