package org.zikula.modulestudio.generator.cartridges.zclassic.controller.util

import de.guite.modulestudio.metamodel.Application
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils
import org.zikula.modulestudio.generator.extensions.ViewExtensions

class ViewUtil {

    extension FormattingExtensions = new FormattingExtensions
    extension ModelExtensions = new ModelExtensions
    extension NamingExtensions = new NamingExtensions
    extension Utils = new Utils
    extension ViewExtensions = new ViewExtensions

    FileHelper fh = new FileHelper

    /**
     * Entry point for the utility class creation.
     */
    def generate(Application it, IFileSystemAccess fsa) {
        println('Generating utility class for view layer')
        generateClassPair(fsa, getAppSourceLibPath + 'Util/View' + (if (targets('1.3.x')) '' else 'Util') + '.php',
            fh.phpFileContent(it, viewFunctionsBaseImpl), fh.phpFileContent(it, viewFunctionsImpl)
        )
    }

    def private viewFunctionsBaseImpl(Application it) '''
        «IF !targets('1.3.x')»
            namespace «appNamespace»\Util\Base;

            use DataUtil;
            use FormUtil;
            use ModUtil;
            use PageUtil;
            use SecurityUtil;
            use System;
            use Symfony\Component\HttpFoundation\Request;
            use Symfony\Component\HttpFoundation\Response;
            use Zikula_AbstractBase;
            use Zikula_View;
            use Zikula\Core\Response\PlainResponse;

        «ENDIF»
        /**
         * Utility base class for view helper methods.
         */
        class «IF targets('1.3.x')»«appName»_Util_Base_View«ELSE»ViewUtil«ENDIF» extends Zikula_AbstractBase
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
         * @param Zikula_View $view    Reference to view object.
         * @param string      $type    Current controller (name of currently treated entity).
         * @param string      $func    Current function («IF targets('1.3.x')»main«ELSE»index«ENDIF», view, ...).
         «IF targets('1.3.x')»
         * @param array       $args    Additional arguments.
         «ELSE»
         * @param Request     $request Current request.
         «ENDIF»
         *
         * @return string name of template file.
         */
        public function getViewTemplate(Zikula_View $view, $type, $func, «IF targets('1.3.x')»$args = array()«ELSE»Request $request«ENDIF»)
        {
            // create the base template name
            $template = DataUtil::formatForOS(«IF targets('1.3.x')»$type«ELSE»ucfirst($type)«ENDIF» . '/' . $func);

            // check for template extension
            $templateExtension = $this->determineExtension($view, $type, $func, «IF targets('1.3.x')»$args«ELSE»$request«ENDIF»);

            // check whether a special template is used
            «IF targets('1.3.x')»
                $tpl = (isset($args['tpl']) && !empty($args['tpl'])) ? $args['tpl'] : FormUtil::getPassedValue('tpl', '', 'GETPOST', FILTER_SANITIZE_STRING);
            «ELSE»
                $tpl = '';
                if ($request->isMethod('POST')) {
                    $tpl = $request->request->filter('tpl', '', false, FILTER_SANITIZE_STRING);
                } elseif ($request->isMethod('GET')) {
                    $tpl = $request->query->filter('tpl', '', false, FILTER_SANITIZE_STRING);
                }
            «ENDIF»

            $templateExtension = '.' . $templateExtension;
            if ($templateExtension != '.tpl') {
                $templateExtension .= '.tpl';
            }

            if (!empty($tpl) && $view->template_exists($template . '_' . DataUtil::formatForOS($tpl) . $templateExtension)) {
                $template .= '_' . DataUtil::formatForOS($tpl);
            }
            $template .= $templateExtension;

            return $template;
        }
    '''

    def private processTemplate(Application it) '''
        /**
         * Utility method for managing view templates.
         *
         * @param Zikula_View $view     Reference to view object.
         * @param string      $type     Current controller (name of currently treated entity).
         * @param string      $func     Current function («IF targets('1.3.x')»main«ELSE»index«ENDIF», view, ...).
         * @param string      $template Optional assignment of precalculated template file.
         «IF targets('1.3.x')»
         * @param array       $args     Additional arguments.
         «ELSE»
         * @param Request     $request  Current request.
         «ENDIF»
         *
         * @return mixed Output.
         */
        public function processTemplate(Zikula_View $view, $type, $func, «IF targets('1.3.x')»$args = array()«ELSE»Request $request«ENDIF», $template = '')
        {
            $templateExtension = $this->determineExtension($view, $type, $func, «IF targets('1.3.x')»$args«ELSE»$request«ENDIF»);
            if (empty($template)) {
                $template = $this->getViewTemplate($view, $type, $func, «IF targets('1.3.x')»$args«ELSE»$request«ENDIF»);
            }

            // look whether we need output with or without the theme
            «IF targets('1.3.x')»
                $raw = (bool) (isset($args['raw']) && !empty($args['raw'])) ? $args['raw'] : FormUtil::getPassedValue('raw', false, 'GETPOST', FILTER_VALIDATE_BOOLEAN);
            «ELSE»
                $raw = false;
                if ($request->isMethod('POST')) {
                    $raw = (bool) $request->request->filter('raw', false, false, FILTER_VALIDATE_BOOLEAN);
                } elseif ($request->isMethod('GET')) {
                    $raw = (bool) $request->query->filter('raw', false, false, FILTER_VALIDATE_BOOLEAN);
                }
            «ENDIF»
            if (!$raw && $templateExtension != 'tpl') {
                $raw = true;
            }

            «IF targets('1.3.x')»
                // ensure the Admin module's plugins are loaded if we have lct=admin but another type value
                $lct = (isset($args['lct']) && !empty($args['lct'])) ? $args['lct'] : FormUtil::getPassedValue('lct', 'user', 'GETPOST', FILTER_SANITIZE_STRING);
                if ($lct == 'admin') {
                    // load Smarty plugins of Admin module
                    $view->addPluginDir('system/Admin/templates/plugins');
                }

            «ENDIF»
            if ($raw == true) {
                // standalone output
                if ($templateExtension == 'pdf') {
                    $template = str_replace('.pdf', '', $template);
                    return $this->processPdf($view«IF !targets('1.3.x')», $request«ENDIF», $template);
                } else {
                    «IF targets('1.3.x')»
                        $view->display($template);
                    «ELSE»
                        return new PlainResponse($view->display($template));
                    «ENDIF»
                }
                «IF targets('1.3.x')»
                    System::shutDown();
                «ENDIF»
            }

            // normal output
            «IF targets('1.3.x')»
                return $view->fetch($template);
            «ELSE»
                return new Response($view->fetch($template));
            «ENDIF»
        }
    '''

    def private determineExtension(Application it) '''
        /**
         * Get extension of the currently treated template.
         *
         * @param Zikula_View $view    Reference to view object.
         * @param string      $type    Current controller (name of currently treated entity).
         * @param string      $func    Current function («IF targets('1.3.x')»main«ELSE»index«ENDIF», view, ...).
         «IF targets('1.3.x')»
         * @param array       $args    Additional arguments.
         «ELSE»
         * @param Request     $request Current request.
         «ENDIF»
         *
         * @return array List of allowed template extensions.
         */
        protected function determineExtension(Zikula_View $view, $type, $func, «IF targets('1.3.x')»$args = array()«ELSE»Request $request«ENDIF»)
        {
            $templateExtension = 'tpl';
            if (!in_array($func, array('view', 'display'))) {
                return $templateExtension;
            }

            $extensions = $this->availableExtensions($type, $func);
            «IF targets('1.3.x')»
                foreach ($extensions as $extension) {
                    $extensionVar = 'use' . $extension . 'ext';
                    $extensionCheck = (isset($args[$extensionVar]) && !empty($extensionVar)) ? $extensionVar : 0;
                    if ($extensionCheck != 1) {
                        $extensionCheck = (int)FormUtil::getPassedValue($extensionVar, 0, 'GET', FILTER_VALIDATE_INT);
                    }
                    if ($extensionCheck == 1) {
                        $templateExtension = $extension;
                        break;
                    }
                }
            «ELSE»
                $format = $request->getRequestFormat();
                if ($format != 'html' && in_array($format, $extensions)) {
                    $templateExtension = $format;
                }
            «ENDIF»

            return $templateExtension;
        }
    '''

    def private availableExtensions(Application it) '''
        /**
         * Get list of available template extensions.
         *
         * @param string $type Current controller (name of currently treated entity).
         * @param string $func Current function («IF targets('1.3.x')»main«ELSE»index«ENDIF», view, ...).
         *
         * @return array List of allowed template extensions.
         */
        public function availableExtensions($type, $func)
        {
            $extensions = array();
            $hasAdminAccess = SecurityUtil::checkPermission('«appName»:' . ucfirst($type) . ':', '::', ACCESS_ADMIN);
            if ($func == 'view') {
                if ($hasAdminAccess) {
                    $extensions = array(«FOR format : getListOfViewFormats SEPARATOR ', '»'«format»'«ENDFOR»);
                } else {
                    $extensions = array(«FOR format : getListOfViewFormats.filter[it == 'rss' || it == 'atom' || it == 'pdf'] SEPARATOR ', '»'«format»'«ENDFOR»);
                }
            } elseif ($func == 'display') {
                if ($hasAdminAccess) {
                    $extensions = array(«FOR format : getListOfDisplayFormats SEPARATOR ', '»'«format»'«ENDFOR»);
                } else {
                    $extensions = array(«FOR format : getListOfDisplayFormats.filter[it == 'ics' || it == 'pdf'] SEPARATOR ', '»'«format»'«ENDFOR»);
                }
            }

            return $extensions;
        }
    '''

    def private processPdf(Application it) '''
        /**
         * Processes a template file using dompdf (LGPL).
         *
         * @param Zikula_View $view     Reference to view object.
         «IF !targets('1.3.x')»
         * @param Request     $request  Current request.
         «ENDIF»
         * @param string      $template Name of template to use.
         *
         * @return mixed Output.
         */
        protected function processPdf(Zikula_View $view«IF !targets('1.3.x')», Request $request«ENDIF», $template)
        {
            // first the content, to set page vars
            $output = $view->fetch($template);

            // make local images absolute
            «IF targets('1.3.x')»
                $output = str_replace('img src="/', 'img src="' . System::serverGetVar('DOCUMENT_ROOT') . '/', $output);
            «ELSE»
                $output = str_replace('img src="/', 'img src="' . $request->server->get('DOCUMENT_ROOT') . '/', $output);
            «ENDIF»

            // see http://codeigniter.com/forums/viewthread/69388/P15/#561214
            //$output = utf8_decode($output);

            // then the surrounding
            $output = $view->fetch('include_pdfheader.tpl') . $output . '</body></html>';

            «IF targets('1.3.x')»
                $controllerHelper = new «appName»_Util_Controller($this->serviceManager);
            «ELSE»
                $controllerHelper = $this->serviceManager->get('«appName.formatForDB».controller_helper');
            «ENDIF»
            // create name of the pdf output file
            $fileTitle = $controllerHelper->formatPermalink(System::getVar('sitename'))
                       . '-'
                       . $controllerHelper->formatPermalink(PageUtil::getVar('title'))
                       . '-' . date('Ymd') . '.pdf';

            // if ($_GET['dbg'] == 1) die($output);

            // instantiate pdf object
            $pdf = new \DOMPDF();
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
        «IF !targets('1.3.x')»
            namespace «appNamespace»\Util;

            use «appNamespace»\Util\Base\ViewUtil as BaseViewUtil;

        «ENDIF»
        /**
         * Utility implementation class for view helper methods.
         */
        «IF targets('1.3.x')»
        class «appName»_Util_View extends «appName»_Util_Base_View
        «ELSE»
        class ViewUtil extends BaseViewUtil
        «ENDIF»
        {
            // feel free to add your own convenience methods here
        }
    '''
}
