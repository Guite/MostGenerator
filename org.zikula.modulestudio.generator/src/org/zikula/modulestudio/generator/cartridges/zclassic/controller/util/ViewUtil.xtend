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
     * Entry point for the utility class creation.
     */
    def generate(Application it, IFileSystemAccess fsa) {
        println('Generating utility class for view layer')
        val utilPath = getAppSourceLibPath + 'Util/'
        val utilSuffix = (if (targets('1.3.5')) '' else 'Util')
        fsa.generateFile(utilPath + 'Base/View' + utilSuffix + '.php', viewFunctionsBaseFile)
        fsa.generateFile(utilPath + 'View' + utilSuffix + '.php', viewFunctionsFile)
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
        «IF !targets('1.3.5')»
            namespace «appName»\Util\Base;

            use DataUtil;
            use FormUtil;
            use PageUtil;
            use SecurityUtil;
            use System;
            use Symfony\Component\HttpFoundation\Response;
            use Zikula_AbstractBase;
            use Zikula_View;
            use Zikula\Core\Response\PlainResponse;

        «ENDIF»
        /**
         * Utility base class for view helper methods.
         */
        class «IF targets('1.3.5')»«appName»_Util_Base_View«ELSE»ViewUtil«ENDIF» extends Zikula_AbstractBase
        {
            «getViewTemplate»

            «processTemplate»

            «determineExtension»

            «availableExtensions»

            «processPdf»
            «IF hasUploads»

                «getReadableFileSize»
            «ENDIF»
        }
    '''

    def private getViewTemplate(Application it) '''
        /**
         * Determines the view template for a certain method with given parameters.
         *
         * @param Zikula_View $view       Reference to view object.
         * @param string      $type       Current type (admin, user, ...).
         * @param string      $objectType Name of treated entity type.
         * @param string      $func       Current function («IF targets('1.3.5')»main«ELSE»index«ENDIF», view, ...).
         * @param array       $args       Additional arguments.
         *
         * @return string name of template file.
         */
        public function getViewTemplate(Zikula_View $view, $type, $objectType, $func, $args = array())
        {
            // create the base template name
            $template = DataUtil::formatForOS(«IF targets('1.3.5')»$type . '/' . $objectType«ELSE»ucwords($type) . '/' . ucwords($objectType)«ENDIF» . '/' . $func);

            // check for template extension
            $templateExtension = $this->determineExtension($view, $type, $objectType, $func, $args);

            // check whether a special template is used
            $tpl = (isset($args['tpl']) && !empty($args['tpl'])) ? $args['tpl'] : FormUtil::getPassedValue('tpl', '', 'GETPOST', FILTER_SANITIZE_STRING);
            if (!empty($tpl) && $view->template_exists($template . '_' . DataUtil::formatForOS($tpl) . '.' . $templateExtension)) {
                $template .= '_' . DataUtil::formatForOS($tpl);
            }
            $template .= '.' . $templateExtension;

            return $template;
        }
    '''

    def private processTemplate(Application it) '''
        /**
         * Utility method for managing view templates.
         *
         * @param Zikula_View $view       Reference to view object.
         * @param string      $type       Current type (admin, user, ...).
         * @param string      $objectType Name of treated entity type.
         * @param string      $func       Current function («IF targets('1.3.5')»main«ELSE»index«ENDIF», view, ...).
         * @param string      $template   Optional assignment of precalculated template file.
         * @param array       $args       Additional arguments.
         *
         * @return mixed Output.
         */
        public function processTemplate(Zikula_View $view, $type, $objectType, $func, $args = array(), $template = '')
        {
            $templateExtension = $this->determineExtension($view, $type, $objectType, $func, $args);
            if (empty($template)) {
                $template = $this->getViewTemplate($view, $type, $objectType, $func, $args);
            }

            // look whether we need output with or without the theme
            $raw = (bool) (isset($args['raw']) && !empty($args['raw'])) ? $args['raw'] : FormUtil::getPassedValue('raw', false, 'GETPOST', FILTER_VALIDATE_BOOLEAN);
            if (!$raw && in_array($templateExtension, array('csv', 'rss', 'atom', 'xml', 'pdf', 'vcard', 'ical', 'json', 'kml'))) {
                $raw = true;
            }

            if ($raw == true) {
                // standalone output
                if ($templateExtension == 'pdf') {
                    $template = str_replace('.pdf', '.tpl', $template);
                    return $this->processPdf($view, $template);
                } else {
                    «IF targets('1.3.5')»
                    $view->display($template);
                    «ELSE»
                    //return new PlainResponse($view->display($template));
                    $view->display($template);
                    return true;
                    «ENDIF»
                }
                «IF targets('1.3.5')»
                System::shutDown();
                «ENDIF»
            }

            // normal output
            «IF targets('1.3.5')»
            return $view->fetch($template);
            «ELSE»
            //return new Response($view->fetch($template));
            return $view->fetch($template);
            «ENDIF»
        }
    '''

    def private determineExtension(Application it) '''
        /**
         * Get extension of the currently treated template.
         *
         * @param Zikula_View $view       Reference to view object.
         * @param string      $type       Current type (admin, user, ...).
         * @param string      $objectType Name of treated entity type.
         * @param string      $func       Current function («IF targets('1.3.5')»main«ELSE»index«ENDIF», view, ...).
         * @param array       $args       Additional arguments.
         *
         * @return array List of allowed template extensions.
         */
        protected function determineExtension(Zikula_View $view, $type, $objectType, $func, $args = array())
        {
            $templateExtension = 'tpl';
            if (!in_array($func, array('view', 'display'))) {
                return $templateExtension;
            }

            $extParams = $this->availableExtensions($type, $objectType, $func, $args);
            foreach ($extParams as $extension) {
                $extensionVar = 'use' . $extension . 'ext';
                $extensionCheck = (isset($args[$extensionVar]) && !empty($extensionVar)) ? $extensionVar : 0;
                if ($extensionCheck != 1) {
                    $extensionCheck = (int)FormUtil::getPassedValue($extensionVar, 0, 'GET', FILTER_VALIDATE_INT);
                    //$extensionCheck = (int)$this->request->query->filter($extensionVar, 0, FILTER_VALIDATE_INT);
                }
                if ($extensionCheck == 1) {
                    $templateExtension = $extension;
                    break;
                }
            }

            return $templateExtension;
        }
    '''

    def private availableExtensions(Application it) '''
        /**
         * Get list of available template extensions.
         *
         * @param string $type       Current type (admin, user, ...).
         * @param string $objectType Name of treated entity type.
         * @param string $func       Current function («IF targets('1.3.5')»main«ELSE»index«ENDIF», view, ...).
         * @param array  $args       Additional arguments.
         *
         * @return array List of allowed template extensions.
         */
        public function availableExtensions($type, $objectType, $func, $args = array())
        {
            $extParams = array();
            $hasAdminAccess = SecurityUtil::checkPermission('«appName»:' . ucwords($objectType) . ':', '::', ACCESS_ADMIN);
            if ($func == 'view') {
                if ($hasAdminAccess) {
                    $extParams = array('csv', 'rss', 'atom', 'xml', 'json', 'kml'/*, 'pdf'*/);
                } else {
                    $extParams = array('rss', 'atom'/*, 'pdf'*/);
                }
            } elseif ($func == 'display') {
                if ($hasAdminAccess) {
                    $extParams = array('xml', 'json', 'kml'/*, 'pdf'*/);
                }
            }

            return $extParams;
        }
    '''

    def private processPdf(Application it) '''
        /**
         * Processes a template file using dompdf (LGPL).
         *
         * @param Zikula_View $view     Reference to view object.
         * @param string      $template Name of template to use.
         *
         * @return mixed Output.
         */
        protected function processPdf(Zikula_View $view, $template)
        {
            // first the content, to set page vars
            $output = $view->fetch($template);

            // make local images absolute
            $output = str_replace('img src="/', 'img src="' . dirname(ZLOADER_PATH) . '/', $output);

            // see http://codeigniter.com/forums/viewthread/69388/P15/#561214
            //$output = utf8_decode($output);

            // then the surrounding
            $output = $view->fetch('include_pdfheader.tpl') . $output . '</body></html>';

            $controllerHelper = new «IF targets('1.3.5')»«appName»_Util_Controller«ELSE»ControllerUtil«ENDIF»($this->serviceManager);
            // create name of the pdf output file
            $fileTitle = $controllerHelper->formatPermalink(System::getVar('sitename'))
                       . '-'
                       . $controllerHelper->formatPermalink(PageUtil::getVar('title'))
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
    '''

    def private getReadableFileSize(Application it) '''
        /**
         * Display a given file size in a readable format
         *
         * @param string  $size     File size in bytes.
         * @param boolean $nodesc   If set to true the description will not be appended.
         * @param boolean $onlydesc If set to true only the description will be returned.
         *
         * @return string File size in a readable form.
         */
        public function getReadableFileSize($size, $nodesc = false, $onlydesc = false)
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
    '''

    def private viewFunctionsImpl(Application it) '''
        «IF !targets('1.3.5')»
            namespace «appName»\Util;

        «ENDIF»
        /**
         * Utility implementation class for view helper methods.
         */
        «IF targets('1.3.5')»
        class «appName»_Util_View extends «appName»_Util_Base_View
        «ELSE»
        class ViewUtil extends Base\ViewUtil
        «ENDIF»
        {
            // feel free to add your own convenience methods here
        }
    '''
}
