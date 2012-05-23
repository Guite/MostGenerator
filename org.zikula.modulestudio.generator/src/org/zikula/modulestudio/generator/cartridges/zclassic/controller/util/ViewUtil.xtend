package org.zikula.modulestudio.generator.cartridges.zclassic.controller.util

import com.google.inject.Inject
import de.guite.modulestudio.metamodel.modulestudio.Application
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class ViewUtil {
    @Inject extension ModelExtensions = new ModelExtensions()
    @Inject extension NamingExtensions = new NamingExtensions()
    @Inject extension Utils = new Utils()

    FileHelper fh = new FileHelper()

    /**
     * Entry point for the Util class creation.
     */
    def generate(Application it, IFileSystemAccess fsa) {
        println('Generating utility class for view layer')
    	val utilPath = appName.getAppSourceLibPath + 'Util/'
        fsa.generateFile(utilPath + 'Base/View.php', viewFunctionsBaseFile)
        fsa.generateFile(utilPath + 'View.php', viewFunctionsFile)
    }

    def private viewFunctionsBaseFile(Application it) '''
    	«fh.phpFileHeader(it)»
    	«viewFunctionsBaseImpl»
    '''

    def private viewFunctionsFile(Application it) '''
    	«fh.phpFileHeader(it)»
    	«viewFunctionsImpl»
    '''

    def private viewFunctionsBaseImpl(Application it) '''
        /**
         * Utility base class for view helper methods.
         */
        class «appName»_«fillingUtil»Base_View extends Zikula_AbstractBase
        {
            /**
             * Determines the view template for a certain method with given parameters.
             *
             * @param Zikula_View $view       Reference to view object.
             * @param string      $type       Current type (admin, user, ...).
             * @param string      $objectType Name of treated entity type.
             * @param string      $func       Current function (main, view, ...).
             * @param array       $args       Additional arguments.
             *
             * @return string name of template file.
             */
            public static function getViewTemplate($view, $type, $objectType, $func, $args = array())
            {
                // create the base template name
                $template = DataUtil::formatForOS($type . '/' . $objectType . '/' . $func);

                // check for template extension
                $templateExtension = self::determineExtension($view, $type, $objectType, $func, $args);

                // check whether a special template is used
                $tpl = (isset($args['tpl']) && !empty($args['tpl'])) ? $args['tpl'] : FormUtil::getPassedValue('tpl', '', 'GETPOST', FILTER_SANITIZE_STRING);
                if (!empty($tpl) && $view->template_exists($template . '_' . DataUtil::formatForOS($tpl) . '.' . $templateExtension)) {
                    $template .= '_' . DataUtil::formatForOS($tpl);
                }
                $template .= '.' . $templateExtension;

                return $template;
            }

            /**
             * Utility method for managing view templates.
             *
             * @param Zikula_View $view       Reference to view object.
             * @param string      $type       Current type (admin, user, ...).
             * @param string      $objectType Name of treated entity type.
             * @param string      $func       Current function (main, view, ...).
             * @param string      $template   Optional assignment of precalculated template file.
             * @param array       $args       Additional arguments.
             *
             * @return mixed Output.
             */
            public static function processTemplate($view, $type, $objectType, $func, $args = array(), $template = '')
            {
                $templateExtension = self::determineExtension($view, $type, $objectType, $func, $args);
                if (empty($template)) {
                    $template = self::getViewTemplate($view, $type, $objectType, $func, $args);
                }

                // look whether we need output with or without the theme
                $raw = (bool) (isset($args['raw']) && !empty($args['raw'])) ? $args['raw'] : FormUtil::getPassedValue('raw', false, 'GETPOST', FILTER_VALIDATE_BOOLEAN);
                if (!$raw && in_array($templateExtension, array('csv', 'rss', 'atom', 'xml', 'pdf', 'vcard', 'ical', 'json', 'kml'))) {
                    $raw = true;
                }

                if ($raw == true) {
                    // standalone output
                    if ($templateExtension == 'pdf') {
                        return self::processPdf($view, $template);
                    } else {
                        $view->display($template);
                    }
                    System::shutDown();
                }

                // normal output
                return $view->fetch($template);
            }

            /**
             * Get extension of the currently treated template.
             *
             * @param Zikula_View $view       Reference to view object.
             * @param string      $type       Current type (admin, user, ...).
             * @param string      $objectType Name of treated entity type.
             * @param string      $func       Current function (main, view, ...).
             * @param array       $args       Additional arguments.
             *
             * @return array List of allowed template extensions.
             */
            protected static function determineExtension($view, $type, $objectType, $func, $args = array())
            {
                $templateExtension = 'tpl';
                if (!in_array($func, array('view', 'display'))) {
                    return $templateExtension;
                }

                $extParams = self::availableExtensions($type, $objectType, $func, $args);
                foreach ($extParams as $extension) {
                    $extensionCheck = (int)FormUtil::getPassedValue('use' . $extension . 'ext', 0, 'GET', FILTER_VALIDATE_INT);
                    //$extensionCheck = (int)$this->request->query->filter('use' . $extension . 'ext', 0, FILTER_VALIDATE_INT);
                    if ($extensionCheck == 1) {
                        $templateExtension = $extension;
                        break;
                    }
                }
                return $templateExtension;
            }

            /**
             * Get list of available template extensions.
             *
             * @param Zikula_View $view       Reference to view object.
             * @param string      $type       Current type (admin, user, ...).
             * @param string      $objectType Name of treated entity type.
             * @param string      $func       Current function (main, view, ...).
             * @param array       $args       Additional arguments.
             *
             * @return array List of allowed template extensions.
             */
            public static function availableExtensions($type, $objectType, $func, $args = array())
            {
                $extParams = array();
                if ($func == 'view') {
                    if (SecurityUtil::checkPermission('«appName»:' . ucwords($objectType) . ':', '::', ACCESS_ADMIN)) {
                        $extParams = array('csv', 'rss', 'atom', 'xml', 'json', 'kml'/*, 'pdf'*/);
                    } else {
                        $extParams = array('rss', 'atom'/*, 'pdf'*/);
                    }
                } elseif ($func == 'display') {
                    if (SecurityUtil::checkPermission('«appName»:' . ucwords($objectType) . ':', '::', ACCESS_ADMIN)) {
                        $extParams = array('xml', 'json', 'kml'/*, 'pdf'*/);
                    }
                }
                return $extParams;
            }

            /**
             * Processes a template file using dompdf (LGPL).
             *
             * @param Zikula_View $view     Reference to view object.
             * @param string      $template Name of template to use.
             *
             * @return mixed Output.
             */
            protected static function processPdf(Zikula_View $view, $template)
            {
                // first the content, to set page vars
                $output = $view->fetch($template);

                // see http://codeigniter.com/forums/viewthread/69388/P15/#561214
                //$output = utf8_decode($output);

                // then the surrounding
                $output = $view->fetch('include_pdfheader.tpl') . $output . '</body></html>';

                // create name of the pdf output file
                $fileTitle = «appName»_Util_Controller::formatPermalink(System::getVar('sitename'))
                           . '-'
                           . «appName»_Util_Controller::formatPermalink(PageUtil::getVar('title'))
                           . '-' . date('Ymd') . '.pdf';

                // if ($_GET['dbg'] == 1) die($output);

                // instantiate pdf object
                $pdf = new DOMPDF();
                // define page properties
                $pdf->set_paper('A4');
                // load html input data
                $pdf->load_html($output);
                // create the actual pdf file
                $pdf->render();
                // stream output to browser
                $pdf->stream($fileTitle);

                // prevent additional output by shutting down the system
                System::shutDown();
                return true;
            }
            «IF hasUploads»

                /**
                 * Display a given file size in a readable format
                 *
                 * @param string  $size     File size in bytes.
                 * @param boolean $nodesc   If set to true the description will not be appended.
                 * @param boolean $onlydesc If set to true only the description will be returned.
                 *
                 * @return string File size in a readable form.
                 */
                public static function getReadableFileSize($size, $nodesc = false, $onlydesc = false)
                {
                    $dom = ZLanguage::getModuleDomain('«appName»');
                    $sizeDesc = __('Bytes', $dom);
                    if ($size >= 1024) {
                        $size /= 1024;
                        $sizeDesc = __('KB', $dom);
                    }
                    if ($size >= 1024) {
                        $size /= 1024;
                        $sizeDesc = __('MB', $dom);
                    }
                    if ($size >= 1024) {
                        $size /= 1024;
                        $sizeDesc = __('GB', $dom);
                    }
                    $sizeDesc = '&nbsp;' . $sizeDesc;

                    // format number
                    $dec_point = ',';
                    $thousands_separator = '.';
                    if ($size - number_format($size, 0) >= 0.005) {
                        $size = number_format($size, 2, $dec_point, $thousands_separator);
                    } else {
                        $size = number_format($size, 0, '', $thousands_separator);
                    }

                    // append size descriptor if desired
                    if (!$nodesc) {
                        $size .= $sizeDesc;
                    }

                    // return either only the description or the complete string
                    $result = ($onlydesc) ? $sizeDesc : $size;
                    return $result;
                }
            «ENDIF»
        }
    '''

    def private viewFunctionsImpl(Application it) '''
        /**
         * Utility implementation class for view helper methods.
         */
        class «appName»_«fillingUtil»View extends «appName»_«fillingUtil»Base_View
        {
            // feel free to add your own convenience methods here
        }
    '''
}
