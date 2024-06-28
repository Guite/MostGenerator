package org.zikula.modulestudio.generator.application

import de.guite.modulestudio.metamodel.Application
import org.eclipse.xtend.lib.annotations.Accessors
import org.eclipse.xtext.generator.JavaIoFileSystemAccess
import org.eclipse.xtext.util.RuntimeIOException

class MostFileSystemAccess extends JavaIoFileSystemAccess implements IMostFileSystemAccess {

    extension MostFileSystemHelper = new MostFileSystemHelper

    @Accessors(PUBLIC_SETTER)
    Application app

    override generateFile(String fileName, String outputConfigName, CharSequence contents) throws RuntimeIOException {
        if (app.shouldBeSkipped(fileName)) {
            return
        }
        val result = preProcess(app, fileName, contents).entrySet.head

        super.generateFile(result.key, outputConfigName, result.value)
    }

    /**
     * Generates a base class and an inheriting concrete class with
     * the corresponding content.
     *
     * @param concretePath    Path to concrete class file.
     * @param baseContent     Content for base class file.
     * @param concreteContent Content for concrete class file.
     */
    override generateClassPair(String concretePath, CharSequence baseContent, CharSequence concreteContent) {
        val basePath = app.getPathToBaseClass(concretePath)
        generateFile(basePath, baseContent)
        generateFile(concretePath, concreteContent)
    }

    /* to be added later if needed
    override generateFile(String fileName, String outputCfgName, InputStream content) {
    }*/
}
