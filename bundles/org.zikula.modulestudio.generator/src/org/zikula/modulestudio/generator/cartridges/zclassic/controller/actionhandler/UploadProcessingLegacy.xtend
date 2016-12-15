package org.zikula.modulestudio.generator.cartridges.zclassic.controller.actionhandler

import de.guite.modulestudio.metamodel.Application
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.Utils

/**
 * Upload processing functions for edit form handlers.
 */
class UploadProcessingLegacy {

    extension ModelExtensions = new ModelExtensions
    extension Utils = new Utils

    // 1.3.x only
    def generate(Application it) {
        if (hasUploads && targets('1.3.x')) {
            handleUploads
        }
    }

    def private handleUploads(Application it) '''
        /**
         * Helper method to process upload fields.
         *
         * @param array               $formData The form input data
         * @param Zikula_EntityAccess $entity   Existing entity object
         *
         * @return array|bool Form data after processing or false on errors
         */
        protected function handleUploads($formData, $entity)
        {
            if (!count($this->uploadFields)) {
                return $formData;
            }

            // initialise the upload handler
            $uploadHandler = new «appName»_UploadHandler();

            // process all fields
            foreach ($this->uploadFields as $uploadField => $isMandatory) {
                // check if an existing file must be deleted
                $hasOldFile = !empty($entity[$uploadField]);
                $hasBeenDeleted = !$hasOldFile;
                if (isset($formData[$uploadField . 'DeleteFile'])) {
                    if ($hasOldFile && $formData[$uploadField . 'DeleteFile'] === true) {
                        // remove upload file (and image thumbnails)
                        $entity = $uploadHandler->deleteUploadFile($entity, $uploadField);
                    }
                    unset($formData[$uploadField . 'DeleteFile']);
                    $hasBeenDeleted = true;
                }

                // look whether a file has been provided
                if (!$formData[$uploadField] || $formData[$uploadField]['size'] == 0) {
                    // no file has been uploaded
                    unset($formData[$uploadField]);
                    // skip to next one
                    continue;
                }

                if ($hasOldFile && true !== $hasBeenDeleted) {
                    // remove old upload file (and image thumbnails)
                    $entity = $uploadHandler->deleteUploadFile($entity, $uploadField);
                }

                // do the actual upload (includes validation, physical file processing and reading meta data)
                $uploadResult = $uploadHandler->performFileUpload($this->objectType, $formData, $uploadField);
                // assign the upload file name
                $formData[$uploadField] = $uploadResult['fileName'];
                // assign the meta data
                $formData[$uploadField . 'Meta'] = $uploadResult['metaData'];

                // if current field is mandatory check if everything has been done
                if ($isMandatory && empty($formData[$uploadField])) {
                    // mandatory upload has not been completed successfully
                    return false;
                }

                $this->entityRef = $entity;

                // upload succeeded
            }

            return $formData;
        }
    '''
}
