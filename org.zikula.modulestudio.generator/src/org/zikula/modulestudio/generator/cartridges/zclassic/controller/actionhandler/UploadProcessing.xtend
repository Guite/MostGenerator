package org.zikula.modulestudio.generator.cartridges.zclassic.controller.actionhandler

import de.guite.modulestudio.metamodel.Application
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.Utils

/**
 * Upload processing functions for edit form handlers.
 */
class UploadProcessing {

    extension FormattingExtensions = new FormattingExtensions
    extension ModelExtensions = new ModelExtensions
    extension Utils = new Utils

    def generate(Application it) {
        if (hasUploads)
            handleUploads
    }

    def private handleUploads(Application it) '''
        /**
         * Helper method to process upload fields.
         *
         * @param array  $formData       The form input data.
         * @param object $existingObject Data of existing entity object.
         *
         * @return array form data after processing.
         */
        protected function handleUploads($formData, $existingObject)
        {
            if (!count($this->uploadFields)) {
                return $formData;
            }

            // initialise the upload handler
            «IF targets('1.3.x')»
                $uploadManager = new «appName»_UploadHandler();
            «ELSE»
                $uploadManager = $this->view->getServiceManager()->get('«appName.formatForDB».upload_handler');
            «ENDIF»
            $existingObjectData = $existingObject->toArray();

            $objectId = ($this->mode != 'create') ? $this->idValues[0] : 0;

            // process all fields
            foreach ($this->uploadFields as $uploadField => $isMandatory) {
                // check if an existing file must be deleted
                $hasOldFile = (!empty($existingObjectData[$uploadField]));
                $hasBeenDeleted = !$hasOldFile;
                if ($this->mode != 'create') {
                    if (isset($formData[$uploadField . 'DeleteFile'])) {
                        if ($hasOldFile && $formData[$uploadField . 'DeleteFile'] === true) {
                            // remove upload file (and image thumbnails)
                            $existingObjectData = $uploadManager->deleteUploadFile($this->objectType, $existingObjectData, $uploadField, $objectId);
                            if (empty($existingObjectData[$uploadField])) {
                                $existingObject[$uploadField] = '';
                                $existingObject[$uploadField . 'Meta'] = array();
                            }
                        }
                        unset($formData[$uploadField . 'DeleteFile']);
                        $hasBeenDeleted = true;
                    }
                }

                // look whether a file has been provided
                if (!$formData[$uploadField] || $formData[$uploadField]['size'] == 0) {
                    // no file has been uploaded
                    unset($formData[$uploadField]);
                    // skip to next one
                    continue;
                }

                if ($hasOldFile && $hasBeenDeleted !== true && $this->mode != 'create') {
                    // remove old upload file (and image thumbnails)
                    $existingObjectData = $uploadManager->deleteUploadFile($this->objectType, $existingObjectData, $uploadField, $objectId);
                    if (empty($existingObjectData[$uploadField])) {
                        $existingObject[$uploadField] = '';
                        $existingObject[$uploadField . 'Meta'] = array();
                    }
                }

                // do the actual upload (includes validation, physical file processing and reading meta data)
                $uploadResult = $uploadManager->performFileUpload($this->objectType, $formData, $uploadField);
                // assign the upload file name
                $formData[$uploadField] = $uploadResult['fileName'];
                // assign the meta data
                $formData[$uploadField . 'Meta'] = $uploadResult['metaData'];

                // if current field is mandatory check if everything has been done
                if ($isMandatory && empty($formData[$uploadField])) {
                    // mandatory upload has not been completed successfully
                    return false;
                }

                // upload succeeded
            }

            return $formData;
        }
    '''
}
