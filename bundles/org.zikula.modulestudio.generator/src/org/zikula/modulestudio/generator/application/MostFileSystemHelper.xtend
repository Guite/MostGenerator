package org.zikula.modulestudio.generator.application

import de.guite.modulestudio.metamodel.Application
import java.util.Arrays
import java.util.Map
import org.zikula.modulestudio.generator.extensions.Utils

class MostFileSystemHelper {

    extension Utils = new Utils

    /**
     * Returns destination file path and enriched content for a given file path.
     */
    def preProcess(Application it, String filePath, CharSequence contents) {
        val Map<String, CharSequence> result = newLinkedHashMap

        var finalPath = filePath
        var filePathParts = filePath.split('\\.') //$NON-NLS-1$
        val fileExtension = filePathParts.lastOrNull

        if (shouldBeMarked(filePath)) {
            filePathParts = Arrays.copyOf(filePathParts, filePathParts.length - 1)
            finalPath = filePathParts.join('.') + '.generated.' + fileExtension //$NON-NLS-1$ //$NON-NLS-2$
        }

        var CharSequence finalContent
        if (fileExtension == 'php') { //$NON-NLS-1$
            finalContent = phpFile(contents)
        } else {
            finalContent = contents
        }
        result.put(finalPath, finalContent)

        result
    }

    /**
     * Returns the path to the parent (base) class for a given file path. 
     */
    def getPathToBaseClass(Application it, String concretePath) {
        var basePathSegments = concretePath.split('/') //$NON-NLS-1$
        var baseFileName = basePathSegments.lastOrNull
        basePathSegments = Arrays.copyOf(basePathSegments, basePathSegments.length - 1)

        var basePathPartsChangeable = newArrayList(basePathSegments)
        basePathPartsChangeable += 'Base' //$NON-NLS-1$
        basePathPartsChangeable += 'Abstract' + baseFileName //$NON-NLS-1$

        basePathPartsChangeable.join('/') //$NON-NLS-1$
    }

    /**
     * Checks whether a certain file path is contained in the blacklist for files to be skipped during generation.
     */
    def shouldBeSkipped(Application it, String filePath) {
        getListOfFilesToBeSkipped.contains(filePath)
    }

    /**
     * Checks whether a certain file path is contained in the list for files to be marked during generation.
     */
    def shouldBeMarked(Application it, String filePath) {
        getListOfFilesToBeMarked.contains(filePath)
    }

    /**
     * Determines a blacklist with each entry representing a file which should not be generated.
     */
    def private getListOfFilesToBeSkipped(Application it) {
        if (null !== skipFiles) {
            getListOfAffectedFiles(skipFiles)
        } else {
            #[''] //$NON-NLS-1$
        }
    }

    /**
     * Determines a list with file pathes which should be marked by special file names.
     */
    def private getListOfFilesToBeMarked(Application it) {
        if (null !== markFiles) {
            getListOfAffectedFiles(markFiles)
        } else {
            #[''] //$NON-NLS-1$
        }
    }

    /**
     * Prepares a list of file pathes for further processing.
     */
    def private getListOfAffectedFiles(String setting) {
        var list = setting.replace("\t", '').replace("\n", '').split(',').toList //$NON-NLS-1$ //$NON-NLS-2$ //$NON-NLS-3$ //$NON-NLS-4$
        for (i : 0 ..< list.size) {
            list.set(i, list.get(i).trim)
        }
        list
    }

    def private phpFile(Application it, CharSequence content) '''
        «phpFileHeader»
        «content»
    '''

    def private phpFileHeader(Application it) '''
        <?php

        /**
         «phpFileHeaderImpl»
         *
         * @version «generatedBy(false, false)»
         *
         * For the full copyright and license information, please view the LICENSE
         * file that was distributed with this source code.
         */

        declare(strict_types=1);

    '''

    def private phpFileHeaderImpl(Application it) '''
        * «name».
        *
        * @copyright «author» («vendor»)
        * @license «license»
        * @author «author»«IF null !== email && !email.empty» <«email»>«ENDIF».
        *
        * @see «IF !url.empty»«url»«ELSE»«msUrl»«ENDIF»«IF url != 'https://ziku.la'»
        * @see https://ziku.la«ENDIF»
    '''
}
