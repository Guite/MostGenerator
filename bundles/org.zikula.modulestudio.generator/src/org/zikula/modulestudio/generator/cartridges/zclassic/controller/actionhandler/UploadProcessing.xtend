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
         «IF targets('1.3.x')»
         * @param array               $formData The form input data
         * @param Zikula_EntityAccess $entity   Existing entity object
         *
         * @return array|bool Form data after processing or false on errors
         «ELSE»
         * @return bool True if upload handling succeeded, false otherwise
         «ENDIF»
         */
        protected function handleUploads(«IF targets('1.3.x')»$formData, $entity«ENDIF»)
        {
            if (!count($this->uploadFields)) {
                return«IF targets('1.3.x')» $formData«ELSE»true«ENDIF»;
            }

            «IF targets('1.3.x')»
                // initialise the upload handler
                $uploadHandler = new «appName»_UploadHandler();
            «ELSE»
                // get treated entity reference from persisted member var
                $entity = $this->entityRef;
            «ENDIF»
            $existingObjectData = $entity->toArray();

            $isCreation = $this->«IF targets('1.3.x')»mode«ELSE»templateParameters['mode']«ENDIF» == 'create';
            $objectId = !$isCreation ? $this->idValues[0] : 0;

            // process all fields
            foreach ($this->uploadFields as $uploadField => $isMandatory) {
                // check if an existing file must be deleted
                $hasOldFile = !empty($existingObjectData[$uploadField]);
                $hasBeenDeleted = !$hasOldFile;
                if (!$isCreation) {
                    «IF targets('1.3.x')»
                        if (isset($formData[$uploadField . 'DeleteFile'])) {
                            if ($hasOldFile && $formData[$uploadField . 'DeleteFile'] === true) {
                                // remove upload file (and image thumbnails)
                                $existingObjectData = $uploadHandler->deleteUploadFile($this->objectType, $existingObjectData, $uploadField, $objectId);
                                if (empty($existingObjectData[$uploadField])) {
                                    $entity[$uploadField] = '';
                                    $entity[$uploadField . 'Meta'] = array();
                                }
                            }
                            unset($formData[$uploadField . 'DeleteFile']);
                            $hasBeenDeleted = true;
                        }
                    «ELSE»
                        $deleteFileKey = $uploadField . 'DeleteFile';
                        if (isset($this->form[$deleteFileKey])) {
                            if ($hasOldFile && $this->form[$deleteFileKey]->getData() == 1) {
                                // remove upload file (and image thumbnails)
                                $existingObjectData = $this->uploadHandler->deleteUploadFile($this->objectType, $existingObjectData, $uploadField, $objectId);
                                if (empty($existingObjectData[$uploadField])) {
                                    $entity[$uploadField] = '';
                                    $entity[$uploadField . 'Meta'] = [];
                                }
                            }
                            $hasBeenDeleted = true;
                        }
                    «ENDIF»
                }
                «IF targets('1.3.x')»

                    // look whether a file has been provided
                    if (!$formData[$uploadField] || $formData[$uploadField]['size'] == 0) {
                        // no file has been uploaded
                        unset($formData[$uploadField]);
                        // skip to next one
                        continue;
                    }

                    if ($hasOldFile && true !== $hasBeenDeleted && !$isCreation) {
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
                «ENDIF»

                // if current field is mandatory check if everything has been done
                if ($isMandatory && empty(«IF targets('1.3.x')»$formData«ELSE»$entity«ENDIF»[$uploadField])) {
                    // mandatory upload has not been completed successfully
                    return false;
                }

                $this->entityRef = $entity;

                // upload succeeded
            }
            «IF targets('1.3.x')»

                return $formData;
            «ENDIF»
        }
    '''
}
