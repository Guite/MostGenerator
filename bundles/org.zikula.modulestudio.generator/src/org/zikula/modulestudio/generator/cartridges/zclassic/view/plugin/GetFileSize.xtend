package org.zikula.modulestudio.generator.cartridges.zclassic.view.plugin

import de.guite.modulestudio.metamodel.Application
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class GetFileSize {

    extension FormattingExtensions = new FormattingExtensions
    extension Utils = new Utils

    def generate(Application it) '''
        «getFileSizeImpl»

        «getReadableFileSize»
    '''

    def private getFileSizeImpl(Application it) '''
        /**
         * The «appName.formatForDB»_fileSize filter displays the size of a given file in a readable way.
         * Example:
         *     {{ 12345|«appName.formatForDB»_fileSize }}
         «IF !targets('3.0')»
         *
         * @param int $size File size in bytes
         * @param string  $filepath The input file path including file name (if file size is not known)
         * @param boolean $nodesc If set to true the description will not be appended
         * @param boolean $onlydesc If set to true only the description will be returned
         *
         * @return string File size in a readable form
         «ENDIF»
         */
        public function getFileSize(«IF targets('3.0')»int $size = 0, string $filepath = '', bool $nodesc = false, bool $onlydesc = false): string«ELSE»($size = 0, $filepath = '', $nodesc = false, $onlydesc = false)«ENDIF»
        {
            «IF !targets('3.0')»
                if (!is_numeric($size)) {
                    $size = (int) $size;
                }
            «ENDIF»
            if (!$size) {
                if (empty($filepath) || !file_exists($filepath)) {
                    return '';
                }
                $size = filesize($filepath);
            }
            if (!$size) {
                return '';
            }

            return $this->getReadableFileSize($size, $nodesc, $onlydesc);
        }
    '''

    def private getReadableFileSize(Application it) '''
        /**
         * Display a given file size in a readable format
         «IF !targets('3.0')»
         *
         * @param int $size File size in bytes
         * @param boolean $nodesc If set to true the description will not be appended
         * @param boolean $onlydesc If set to true only the description will be returned
         *
         * @return string File size in a readable form
         «ENDIF»
         */
        private function getReadableFileSize(«IF targets('3.0')»int $size, bool $nodesc = false, bool $onlydesc = false): string«ELSE»($size, $nodesc = false, $onlydesc = false)«ENDIF»
        {
            $sizeDesc = $this->__('Bytes');
            if ($size >= 1024) {
                $size /= 1024;
                $sizeDesc = $this->__('KB');
            }
            if ($size >= 1024) {
                $size /= 1024;
                $sizeDesc = $this->__('MB');
            }
            if ($size >= 1024) {
                $size /= 1024;
                $sizeDesc = $this->__('GB');
            }
            $sizeDesc = '&nbsp;' . $sizeDesc;

            // format number
            $dec_point = ',';
            $thousands_separator = '.';
            if ($size - (int)$size >= 0.005) {
                $size = number_format($size, 2, $dec_point, $thousands_separator);
            } else {
                $size = number_format($size, 0, '', $thousands_separator);
            }

            // append size descriptor if desired
            if (!$nodesc) {
                $size .= $sizeDesc;
            }

            // return either only the description or the complete string
            return $onlydesc ? $sizeDesc : $size;
        }
    '''
}
