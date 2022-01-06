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
         *     {{ 12345|«appName.formatForDB»_fileSize }}.
         */
        public function getFileSize(int $size = 0, string $filePath = '', bool $nodesc = false, bool $onlydesc = false): string
        {
            if (!$size) {
                if (empty($filePath) || !file_exists($filePath)) {
                    return '';
                }
                $size = filesize($filePath);
            }
            if (!$size) {
                return '';
            }

            return $this->getReadableFileSize($size, $nodesc, $onlydesc);
        }
    '''

    def private getReadableFileSize(Application it) '''
        /**
         * Display a given file size in a readable format.
         */
        private function getReadableFileSize(int $size, bool $nodesc = false, bool $onlydesc = false): string
        {
            $sizeDesc = $this->trans('Bytes');
            if ($size >= 1024) {
                $size /= 1024;
                $sizeDesc = $this->trans('KB');
            }
            if ($size >= 1024) {
                $size /= 1024;
                $sizeDesc = $this->trans('MB');
            }
            if ($size >= 1024) {
                $size /= 1024;
                $sizeDesc = $this->trans('GB');
            }
            $sizeDesc = '&nbsp;' . $sizeDesc;

            // format number
            $dec_point = ',';
            $thousands_separator = '.';
            if ($size - (int) $size >= 0.005) {
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
