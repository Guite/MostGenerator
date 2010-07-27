package org.zikula.modulestudio.generator.beautifier;

import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.util.Vector;

import org.eclipse.core.filesystem.EFS;
import org.eclipse.core.filesystem.IFileStore;
import org.eclipse.core.filesystem.IFileSystem;
import org.eclipse.core.resources.IFile;
import org.eclipse.core.runtime.CoreException;
import org.eclipse.jface.text.IDocument;
import org.eclipse.jface.text.Region;
import org.eclipse.ui.IEditorInput;
import org.eclipse.ui.IEditorPart;
import org.eclipse.ui.IEditorReference;
import org.eclipse.ui.IFileEditorInput;
import org.eclipse.ui.IWorkbench;
import org.eclipse.ui.IWorkbenchPage;
import org.eclipse.ui.IWorkbenchWindow;
import org.eclipse.ui.PartInitException;
import org.eclipse.ui.texteditor.IDocumentProvider;
import org.eclipse.ui.texteditor.ITextEditor;
import org.zikula.modulestudio.generator.beautifier.formatter.SimpleContentFormatter;
import org.zikula.modulestudio.generator.beautifier.sdk.IDE;

public class GeneratorFileUtil {

    public static Boolean isIndebugMode = false;

    /**
     * reads list of file names to consider
     * 
     * @param basedir
     * @param files
     * @throws CoreException
     */
    public static void getRecursivePhpFiles(File basedir, Vector<File> files)
            throws CoreException {
        final File[] f = basedir.listFiles();

        for (final File file : f) {
            if (file.isDirectory()) {
                getRecursivePhpFiles(file, files);
            }
            else if (file.isFile()) {
                if (!file.getName().endsWith(".php")) {
                    continue;
                }

                // add it to the collection
                files.add(file);
            }
        }
    }

    public static void applyFormatterOnSingleFileInEditor(File file,
            SimpleContentFormatter formatter) {
        final IFileSystem fileSystem = EFS.getLocalFileSystem();
        final IFileStore fileStore = fileSystem.getStore(file.toURI());
        final IWorkbenchPage page = GeneratorFileUtil.openEditor(fileStore);

        if (GeneratorFileUtil.isIndebugMode) {
            System.out.println("\n-------");
            System.out.println("Current file: " + file.toString());
        }

        final IDocument document = GeneratorFileUtil.getDocumentFromPage(page);
        final IFile iFile = GeneratorFileUtil.getIFileFromPage(page);
        final IEditorPart currentEditor = page.getActiveEditor();

        final Region region = new Region(0, document.getLength());
        // if (GeneratorFileUtil.isIndebugMode) {
        // System.out.println("Region: " + region.getLength());
        // }
        formatter.setCurrentFile(iFile);
        formatter.format(document, region);

        if (GeneratorFileUtil.isIndebugMode) {
            System.out.println("Save and exit...");
        }
        // save without confirmation
        page.saveEditor(currentEditor, false);
        // close without saving
        // page.closeEditor(currentEditor, false);
    }

    public static IWorkbenchPage openEditor(IFileStore fileStore) {
        final IWorkbench workbench = GeneratorBeautifierPlugin.getDefault()
                .getWorkbench();
        final IWorkbenchWindow window = workbench.getActiveWorkbenchWindow();
        final IWorkbenchPage page = window.getActivePage();
        try {
            IDE.openEditorOnFileStore(page, fileStore);
        } catch (final PartInitException e) {
            /* some code */
            e.printStackTrace();
        }
        return page;
    }

    /**
     * read file and return as IDocument instance
     * 
     * @param file
     * @return
     */
    public static IFile getIFileFromPage(IWorkbenchPage page) {
        final IEditorReference[] editors = page.getEditorReferences();

        IFile file = null;
        for (final IEditorReference reference : editors) {
            try {
                final IEditorInput editorInput = reference.getEditorInput();

                if (!(editorInput instanceof IFileEditorInput)) {
                    continue;
                }
                file = (((IFileEditorInput) editorInput).getFile());
            } catch (final PartInitException e) {
                // TODO Auto-generated catch block
                e.printStackTrace();
            }
        }
        return file;
    }

    /**
     * read file and return as IDocument instance
     * 
     * @param file
     * @return
     */
    public static IDocument getDocumentFromPage(IWorkbenchPage page) {
        final IEditorReference[] editors = page.getEditorReferences();

        IDocument document = null;
        for (final IEditorReference reference : editors) {
            try {
                final IEditorInput editorInput = reference.getEditorInput();
                final IFile file;

                if (!(editorInput instanceof IFileEditorInput)) {
                    continue;
                }
                file = (((IFileEditorInput) editorInput).getFile());

                final IEditorPart editor = reference.getEditor(false);
                if (editor != null && editor instanceof ITextEditor) {
                    final ITextEditor textEditor = (ITextEditor) editor;
                    final IDocumentProvider prov = textEditor
                            .getDocumentProvider();
                    document = prov.getDocument(textEditor.getEditorInput());
                }
            } catch (final PartInitException e) {
                // TODO Auto-generated catch block
                e.printStackTrace();
            }
        }
        return document;
    }

    /**
     * returns the contents of the file
     * 
     * @param file
     * @return
     */
    public static String getFileText(IFile file) {
        try {
            final InputStream in = file.getContents();
            final ByteArrayOutputStream out = new ByteArrayOutputStream();
            final byte[] buf = new byte[1024];
            int read = in.read(buf);
            while (read > 0) {
                out.write(buf, 0, read);
                read = in.read(buf);
            }
            return out.toString();
        } catch (final CoreException e) {
            GeneratorBeautifierPlugin.log(e);
        } catch (final IOException e) {
            GeneratorBeautifierPlugin.log(e);
        }
        return "";
    }
}
