package org.zikula.modulestudio.generator.cartridges.zclassic.controller.actionhandler

import de.guite.modulestudio.metamodel.Application
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.Utils

/**
 * Upload processing functions for edit form handlers.
 */
class UploadProcessing {

    extension ModelExtensions = new ModelExtensions
    extension Utils = new Utils

    def generate(Application it) {
        if (hasUploads) {
            handleUploads
        }
    }

    def private handleUploads(Application it) '''
        /**
         * Helper method to process upload fields.
         *
         * @param «IF targets('1.3.x')»       «ENDIF»array        $formData The form input data
         * @param «IF targets('1.3.x')»Zikula_«ENDIF»EntityAccess $entity   Existing entity object
         *
         * @return array Form data after processing
         */
        protected function handleUploads($formData, $entity)
        {
            if (!count($this->uploadFields)) {
                return $formData;
            }

            «IF targets('1.3.x')»
                // initialise the upload handler
                $uploadHandler = new «appName»_UploadHandler();
            «ENDIF»
            $existingObjectData = $entity->toArray();

            $objectId = $this->«IF targets('1.3.x')»mode«ELSE»templateParameters['mode']«ENDIF» != 'create' ? $this->idValues[0] : 0;

            // process all fields
            foreach ($this->uploadFields as $uploadField => $isMandatory) {
                // check if an existing file must be deleted
                $hasOldFile = !empty($existingObjectData[$uploadField]);
                $hasBeenDeleted = !$hasOldFile;
                if («IF targets('1.3.x')»$this->mode«ELSE»$this->templateParameters['mode']«ENDIF» != 'create') {
                    if (isset($formData[$uploadField . 'DeleteFile'])) {
                        if ($hasOldFile && $formData[$uploadField . 'DeleteFile'] === true) {
                            // remove upload file (and image thumbnails)
                            $existingObjectData = $«IF !targets('1.3.x')»this->«ENDIF»uploadHandler->deleteUploadFile($this->objectType, $existingObjectData, $uploadField, $objectId);
                            if (empty($existingObjectData[$uploadField])) {
                                $entity[$uploadField] = '';
                                $entity[$uploadField . 'Meta'] = «IF targets('1.3.x')»array()«ELSE»[]«ENDIF»;
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

                if ($hasOldFile && true !== $hasBeenDeleted && $this->«IF targets('1.3.x')»mode«ELSE»templateParameters['mode']«ENDIF» != 'create') {
                    // remove old upload file (and image thumbnails)
                    $existingObjectData = $«IF !targets('1.3.x')»this->«ENDIF»uploadHandler->deleteUploadFile($this->objectType, $existingObjectData, $uploadField, $objectId);
                    if (empty($existingObjectData[$uploadField])) {
                        $entity[$uploadField] = '';
                        $entity[$uploadField . 'Meta'] = «IF targets('1.3.x')»array()«ELSE»[]«ENDIF»;
                    }
                }

                // do the actual upload (includes validation, physical file processing and reading meta data)
                $uploadResult = $«IF !targets('1.3.x')»this->«ENDIF»uploadHandler->performFileUpload($this->objectType, $formData, $uploadField);
                // assign the upload file name
                «IF targets('1.3.x')»$formData«ELSE»$entity«ENDIF»[$uploadField] = $uploadResult['fileName'];
                // assign the meta data
                «IF targets('1.3.x')»$formData«ELSE»$entity«ENDIF»[$uploadField . 'Meta'] = $uploadResult['metaData'];

                // if current field is mandatory check if everything has been done
                if ($isMandatory && empty(«IF targets('1.3.x')»$formData«ELSE»$entity«ENDIF»[$uploadField])) {
                    // mandatory upload has not been completed successfully
                    return false;
                }

                «IF !targets('1.3.x')»
                    $this->entityRef = $entity;

                «ENDIF»
                // upload succeeded
            }

            return $formData;
        }
    '''
}
