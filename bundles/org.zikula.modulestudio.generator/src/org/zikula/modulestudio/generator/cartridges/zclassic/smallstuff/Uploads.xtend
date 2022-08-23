package org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff

import de.guite.modulestudio.metamodel.Application
import de.guite.modulestudio.metamodel.Entity
import de.guite.modulestudio.metamodel.UploadField
import org.zikula.modulestudio.generator.application.IMostFileSystemAccess
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class Uploads {

    extension FormattingExtensions = new FormattingExtensions
    extension ModelExtensions = new ModelExtensions
    extension NamingExtensions = new NamingExtensions
    extension Utils = new Utils

    IMostFileSystemAccess fsa

    def generate(Application it, IMostFileSystemAccess fsa) {
        this.fsa = fsa
        createUploadFolders
    }

    def private createUploadFolders(Application it) {
        /* These files will be removed later. At the moment we need them to create according directories. */
        val uploadPath = getAppUploadPath
        fsa.createPlaceholder(uploadPath)
        for (entity : getUploadEntities.filter(Entity)) {
            val subFolderName = entity.nameMultiple.formatForDB + '/'
            fsa.createPlaceholder(uploadPath + subFolderName)
            val uploadFields = entity.getUploadFieldsEntity
            for (uploadField : uploadFields) {
                uploadField.uploadFolder(uploadPath, subFolderName + uploadField.subFolderPathSegment)
            }
        }
        fsa.generateFile(getAppDocPath + 'htaccessTemplate', htAccessTemplate)
    }

    def private uploadFolder(UploadField it, String basePath, String folder) {
        fsa.createPlaceholder(basePath + folder + '/')
        fsa.generateFile(getAppUploadPath(application) + folder + '/.htaccess', htAccess)
    }

    def private htAccess(UploadField it) '''
        # «generatedBy(application, application.timestampAllGeneratedFiles, application.versionAllGeneratedFiles)»
        # ------------------------------------------------------------
        # Purpose of file: block any web access to unallowed files
        # stored in this directory
        # ------------------------------------------------------------

        # Apache 2.2
        <IfModule !mod_authz_core.c>
            Deny from all
        </IfModule>

        # Apache 2.4
        <IfModule mod_authz_core.c>
            Require all denied
        </IfModule>

        <FilesMatch "\.(«allowedExtensions.replace(", ", "|")»)$">
            # Apache 2.2
            <IfModule !mod_authz_core.c>
                Order allow,deny
                Allow from all
            </IfModule>

            # Apache 2.4
            <IfModule mod_authz_core.c>
                Require all granted
            </IfModule>
        </FilesMatch>
    '''

    def private htAccessTemplate(Application it) '''
        # «generatedBy(it, timestampAllGeneratedFiles, versionAllGeneratedFiles)»
        # ------------------------------------------------------------
        # Purpose of file: block any web access to unallowed files
        # stored in this directory
        # ------------------------------------------------------------

        # Apache 2.2
        <IfModule !mod_authz_core.c>
            Deny from all
        </IfModule>

        # Apache 2.4
        <IfModule mod_authz_core.c>
            Require all denied
        </IfModule>

        <FilesMatch "\.(__EXTENSIONS__)$">
            # Apache 2.2
            <IfModule !mod_authz_core.c>
                Order allow,deny
                Allow from all
            </IfModule>

            # Apache 2.4
            <IfModule mod_authz_core.c>
                Require all granted
            </IfModule>
        </FilesMatch>
    '''
}
