package org.zikula.modulestudio.generator.cartridges.zclassic.controller.util

import de.guite.modulestudio.metamodel.Application
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils
import org.zikula.modulestudio.generator.extensions.ViewExtensions

class ViewHelper {

    extension ModelExtensions = new ModelExtensions
    extension NamingExtensions = new NamingExtensions
    extension Utils = new Utils
    extension ViewExtensions = new ViewExtensions

    FileHelper fh = new FileHelper

    /**
     * Entry point for the helper class creation.
     */
    def generate(Application it, IFileSystemAccess fsa) {
        println('Generating helper class for view layer')
        val helperFolder = if (isLegacy) 'Util' else 'Helper'
        generateClassPair(fsa, getAppSourceLibPath + helperFolder + '/View' + (if (isLegacy) '' else 'Helper') + '.php',
            fh.phpFileContent(it, viewFunctionsBaseImpl), fh.phpFileContent(it, viewFunctionsImpl)
        )
    }

    def private viewFunctionsBaseImpl(Application it) '''
        «IF !isLegacy»
            namespace «appNamespace»\Helper\Base;

            use DataUtil;
            use PageUtil;
            use System;
            use Symfony\Component\DependencyInjection\ContainerBuilder;
            use Symfony\Component\HttpFoundation\Request;
            use Symfony\Component\HttpFoundation\Response;
            use Twig_Environment;
            use Zikula\Common\Translator\TranslatorInterface;
            use Zikula\Core\Response\PlainResponse;

        «ENDIF»
        /**
         * Helper base class for view layer methods.
         */
        abstract class «IF isLegacy»«appName»_Util_Base_AbstractView extends Zikula_AbstractBase«ELSE»AbstractViewHelper«ENDIF»
        {
            «IF !isLegacy»
                /**
                 * @var ContainerBuilder
                 */
                protected $container;

                /**
                 * @var TranslatorInterface
                 */
                protected $translator;

                /**
                 * Constructor.
                 * Initialises member vars.
                 *
                 * @param ContainerBuilder    $container  ContainerBuilder service instance
                 * @param TranslatorInterface $translator Translator service instance
                 *
                 * @return void
                 */
                public function __construct(ContainerBuilder $container, TranslatorInterface $translator)
                {
                    $this->container = $container;
                    $this->translator = $translator;
                }

            «ENDIF»
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
        «IF isLegacy»
            «' '»* @param Zikula_View $view     Reference to view object
        «ELSE»
            «' '»* @param Twig_Environment $twig     Reference to view object
        «ENDIF»
         * @param string      «IF !isLegacy»     «ENDIF»$type    Current controller (name of currently treated entity)
         * @param string      «IF !isLegacy»     «ENDIF»$func    Current function («IF isLegacy»main«ELSE»index«ENDIF», view, ...)
         «IF isLegacy»
         * @param array       $args    Additional arguments
         «ELSE»
         * @param Request          $request Current request
         «ENDIF»
         *
         * @return string name of template file
         */
        public function getViewTemplate(«IF isLegacy»Zikula_View $view«ELSE»Twig_Environment $twig«ENDIF», $type, $func, «IF isLegacy»$args = array()«ELSE»Request $request«ENDIF»)
        {
            // create the base template name
            $template = «IF isLegacy»$type«ELSE»'@«appName»/' . ucfirst($type)«ENDIF» . '/' . $func;

            // check for template extension
            $templateExtension = $this->determineExtension(«IF isLegacy»$view«ELSE»$twig«ENDIF», $type, $func, «IF isLegacy»$args«ELSE»$request«ENDIF»);

            // check whether a special template is used
            «IF isLegacy»
                $tpl = (isset($args['tpl']) && !empty($args['tpl'])) ? $args['tpl'] : FormUtil::getPassedValue('tpl', '', 'GETPOST', FILTER_SANITIZE_STRING);
            «ELSE»
                $tpl = '';
                if ($request->isMethod('POST')) {
                    $tpl = $request->request->getAlnum('tpl', '');
                } elseif ($request->isMethod('GET')) {
                    $tpl = $request->query->getAlnum('tpl', '');
                }
            «ENDIF»

            $templateExtension = '.' . $templateExtension;
            «IF isLegacy»
                if ($templateExtension != '.tpl') {
                    $templateExtension .= '.tpl';
                }

                // check if custom template exists
                if (!empty($tpl) && $view->template_exists($template . '_' . DataUtil::formatForOS($tpl) . $templateExtension)) {
                    $template .= '_' . DataUtil::formatForOS($tpl);
                }
            «ELSE»
                «/* TODO refactor this, e.g. using http://twig.sensiolabs.org/api/master/Twig_Environment.html#method_resolveTemplate */»
                // check if custom template exists
                if (!empty($tpl)) {
                    $template .= DataUtil::formatForOS(ucfirst($tpl));
                }
            «ENDIF»
            $template .= $templateExtension;

            return $template;
        }
    '''

    def private processTemplate(Application it) '''
        /**
         * Helper method for managing view templates.
         *
        «IF isLegacy»
            «' '»* @param Zikula_View $view     Reference to view object
        «ELSE»
            «' '»* @param Twig_Environment $twig     Reference to view object
        «ENDIF»
         * @param string      «IF !isLegacy»     «ENDIF»$type     Current controller (name of currently treated entity)
         * @param string      «IF !isLegacy»     «ENDIF»$func     Current function («IF isLegacy»main«ELSE»index«ENDIF», view, ...)
         «IF isLegacy»
         * @param array       $args     Additional arguments
         «ELSE»
         * @param Request          $request            Current request
         * @param array            $templateParameters Template data
         «ENDIF»
         * @param string      «IF !isLegacy»     «ENDIF»$template Optional assignment of precalculated template file
         *
         * @return mixed Output
         */
        public function processTemplate(«IF isLegacy»Zikula_View $view«ELSE»Twig_Environment $twig«ENDIF», $type, $func, «IF isLegacy»$args = array()«ELSE»Request $request, $templateParameters = []«ENDIF», $template = '')
        {
            $templateExtension = $this->determineExtension(«IF isLegacy»$view«ELSE»$twig«ENDIF», $type, $func, «IF isLegacy»$args«ELSE»$request«ENDIF»);
            if (empty($template)) {
                $template = $this->getViewTemplate(«IF isLegacy»$view«ELSE»$twig«ENDIF», $type, $func, «IF isLegacy»$args«ELSE»$request«ENDIF»);
            }

            // look whether we need output with or without the theme
            «IF isLegacy»
                $raw = (bool) (isset($args['raw']) && !empty($args['raw'])) ? $args['raw'] : FormUtil::getPassedValue('raw', false, 'GETPOST', FILTER_VALIDATE_BOOLEAN);
            «ELSE»
                $raw = false;
                if ($request->isMethod('POST')) {
                    $raw = (bool) $request->request->get('raw', false);
                } elseif ($request->isMethod('GET')) {
                    $raw = (bool) $request->query->get('raw', false);
                }
            «ENDIF»
            if (!$raw && $templateExtension != '«IF isLegacy»tpl«ELSE»html.twig«ENDIF»') {
                $raw = true;
            }

            «IF isLegacy»
                // ensure the Admin module's plugins are loaded if we have lct=admin but another type value
                $lct = (isset($args['lct']) && !empty($args['lct'])) ? $args['lct'] : FormUtil::getPassedValue('lct', 'user', 'GETPOST', FILTER_SANITIZE_STRING);
                if ($lct == 'admin') {
                    // load Smarty plugins of Admin module
                    $view->addPluginDir('system/Admin/templates/plugins');
                }

            «ENDIF»
            «IF !isLegacy»
                $response = null;
            «ENDIF»
            if (true === $raw) {
                // standalone output
                if ($templateExtension == 'pdf«IF !isLegacy».twig«ENDIF»') {
                    $template = str_replace('.pdf', '«IF !isLegacy».html«ENDIF»', $template);

                    return $this->processPdf(«IF isLegacy»$view«ELSE»$twig, $request, $templateParameters«ENDIF», $template);
                }

                «IF isLegacy»
                    $view->display($template);
                    System::shutDown();
                «ELSE»
                    $response = new PlainResponse($twig->render($template, $templateParameters));
                «ENDIF»
            }

            // normal output
            «IF isLegacy»
                return $view->fetch($template);
            «ELSE»
                $response = new Response($twig->render($template, $templateParameters));
                «val supportedFormats = getListOfViewFormats + getListOfDisplayFormats»

                // check if we need to set any custom headers
                switch ($templateExtension) {
                    «IF supportedFormats.exists[e|e == 'csv']»
                        case 'csv.twig':
                            $response->headers->set('Content-Type', 'text/comma-separated-values; charset=iso-8859-15');
                            $fileName = $type . '-list.csv';
                            $response->headers->set('Content-Disposition', 'attachment; filename=' . $fileName);
                            break;
                    «ENDIF»
                    «IF supportedFormats.exists[e|e == 'ics']»
                        case 'ics.twig':
                            $response->headers->set('Content-Type', 'text/calendar; charset=iso-8859-15«/*charset=utf-8*/»');
                            break;
                    «ENDIF»
                    «IF supportedFormats.exists[e|e == 'json']»
                        case 'json.twig':
                            $response->headers->set('Content-Type', 'application/json');
                            break;
                    «ENDIF»
                    «IF supportedFormats.exists[e|e == 'kml']»
                        case 'kml.twig':
                            $response->headers->set('Content-Type', 'application/vnd.google-earth.kml+xml');
                            break;
                    «ENDIF»
                    «IF supportedFormats.exists[e|e == 'xml']»
                        case 'xml.twig':
                            $response->headers->set('Content-Type', 'text/xml');
                            break;
                    «ENDIF»
                    «IF supportedFormats.exists[e|e == 'atom']»
                        case 'atom.twig':
                            $response->headers->set('Content-Type', 'application/atom+xml');
                            break;
                    «ENDIF»
                    «IF supportedFormats.exists[e|e == 'rss']»
                        case 'rss.twig':
                            $response->headers->set('Content-Type', 'application/rss+xml');
                            break;
                    «ENDIF»
                }

                return $response;
            «ENDIF»
        }
    '''

    def private determineExtension(Application it) '''
        /**
         * Get extension of the currently treated template.
         *
        «IF isLegacy»
            «' '»* @param Zikula_View $view     Reference to view object
        «ELSE»
            «' '»* @param Twig_Environment $twig     Reference to view object
        «ENDIF»
         * @param string      «IF !isLegacy»     «ENDIF»$type    Current controller (name of currently treated entity)
         * @param string      «IF !isLegacy»     «ENDIF»$func    Current function («IF isLegacy»main«ELSE»index«ENDIF», view, ...)
         «IF isLegacy»
         * @param array       $args    Additional arguments
         «ELSE»
         * @param Request          $request Current request
         «ENDIF»
         *
         * @return array List of allowed template extensions
         */
        protected function determineExtension(«IF isLegacy»Zikula_View $view«ELSE»Twig_Environment $twig«ENDIF», $type, $func, «IF isLegacy»$args = array()«ELSE»Request $request«ENDIF»)
        {
            $templateExtension = '«IF isLegacy»tpl«ELSE»html.twig«ENDIF»';
            if (!in_array($func, «IF isLegacy»array(«ELSE»[«ENDIF»'view', 'display'«IF isLegacy»)«ELSE»]«ENDIF»)) {
                return $templateExtension;
            }

            $extensions = $this->availableExtensions($type, $func);
            «IF isLegacy»
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
                    $templateExtension = $format . '.twig';
                }
            «ENDIF»

            return $templateExtension;
        }
    '''

    def private availableExtensions(Application it) '''
        /**
         * Get list of available template extensions.
         *
         * @param string $type Current controller (name of currently treated entity)
         * @param string $func Current function («IF isLegacy»main«ELSE»index«ENDIF», view, ...)
         *
         * @return array List of allowed template extensions
         */
        public function availableExtensions($type, $func)
        {
            $extensions = «IF isLegacy»array()«ELSE»[]«ENDIF»;
            «IF !isLegacy»
                $permissionApi = $this->container->get('zikula_permissions_module.api.permission');
            «ENDIF»
            $hasAdminAccess = «IF isLegacy»SecurityUtil::check«ELSE»$permissionApi->has«ENDIF»Permission('«appName»:' . ucfirst($type) . ':', '::', ACCESS_ADMIN);
            if ($func == 'view') {
                if ($hasAdminAccess) {
                    $extensions = «IF isLegacy»array(«ELSE»[«ENDIF»«FOR format : getListOfViewFormats SEPARATOR ', '»'«format»'«ENDFOR»«IF isLegacy»)«ELSE»]«ENDIF»;
                } else {
                    $extensions = «IF isLegacy»array(«ELSE»[«ENDIF»«FOR format : getListOfViewFormats.filter[it == 'rss' || it == 'atom' || it == 'pdf'] SEPARATOR ', '»'«format»'«ENDFOR»«IF isLegacy»)«ELSE»]«ENDIF»;
                }
            } elseif ($func == 'display') {
                if ($hasAdminAccess) {
                    $extensions = «IF isLegacy»array(«ELSE»[«ENDIF»«FOR format : getListOfDisplayFormats SEPARATOR ', '»'«format»'«ENDFOR»«IF isLegacy»)«ELSE»]«ENDIF»;
                } else {
                    $extensions = «IF isLegacy»array(«ELSE»[«ENDIF»«FOR format : getListOfDisplayFormats.filter[it == 'ics' || it == 'pdf'] SEPARATOR ', '»'«format»'«ENDFOR»«IF isLegacy»)«ELSE»]«ENDIF»;
                }
            }

            return $extensions;
        }
    '''

    def private processPdf(Application it) '''
        /**
         * Processes a template file using dompdf (LGPL).
         *
        «IF isLegacy»
            «' '»* @param Zikula_View $view     Reference to view object
        «ELSE»
            «' '»* @param Twig_Environment $twig     Reference to view object
        «ENDIF»
         «IF !isLegacy»
         * @param Request          $request            Current request
         * @param array            $templateParameters Template data
         «ENDIF»
         * @param string      «IF !isLegacy»     «ENDIF»$template Name of template to use
         *
         * @return mixed Output
         */
        protected function processPdf(«IF isLegacy»Zikula_View $view«ELSE»Twig_Environment $twig, Request $request, $templateParameters = []«ENDIF», $template)
        {
            // first the content, to set page vars
            «IF isLegacy»
                $output = $view->fetch($template);
            «ELSE»
                $output = $twig->render($template, $templateParameters);
            «ENDIF»

            // make local images absolute
            «IF isLegacy»
                $output = str_replace('img src="/', 'img src="' . System::serverGetVar('DOCUMENT_ROOT') . '/', $output);
            «ELSE»
                $output = str_replace('img src="/', 'img src="' . $request->server->get('DOCUMENT_ROOT') . '/', $output);
            «ENDIF»

            // see http://codeigniter.com/forums/viewthread/69388/P15/#561214
            //$output = utf8_decode($output);

            // then the surrounding
            «IF isLegacy»
                $output = $view->fetch('includePdfHeader.tpl') . $output . '</body></html>';
            «ELSE»
                $output = $twig->render('includePdfHeader.html.twig') . $output . '</body></html>';
            «ENDIF»

            «IF isLegacy»
                $controllerHelper = new «appName»_Util_Controller($this->serviceManager);
            «ELSE»
                $controllerHelper = $this->container->get('«appService».controller_helper');
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
         * @param string  $size     File size in bytes
         * @param boolean $nodesc   If set to true the description will not be appended
         * @param boolean $onlydesc If set to true only the description will be returned
         *
         * @return string File size in a readable form
         */
        public function getReadableFileSize($size, $nodesc = false, $onlydesc = false)
        {
            $sizeDesc = $this->«IF !isLegacy»translator->«ENDIF»__('Bytes');
            if ($size >= 1024) {
                $size /= 1024;
                $sizeDesc = $this->«IF !isLegacy»translator->«ENDIF»__('KB');
            }
            if ($size >= 1024) {
                $size /= 1024;
                $sizeDesc = $this->«IF !isLegacy»translator->«ENDIF»__('MB');
            }
            if ($size >= 1024) {
                $size /= 1024;
                $sizeDesc = $this->«IF !isLegacy»translator->«ENDIF»__('GB');
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
        «IF !isLegacy»
            namespace «appNamespace»\Helper;

            use «appNamespace»\Helper\Base\AbstractViewHelper;

        «ENDIF»
        /**
         * Helper implementation class for view layer methods.
         */
        «IF isLegacy»
        class «appName»_Util_View extends «appName»_Util_Base_AbstractView
        «ELSE»
        class ViewHelper extends AbstractViewHelper
        «ENDIF»
        {
            // feel free to add your own convenience methods here
        }
    '''

    def private isLegacy(Application it) {
        targets('1.3.x')
    }
}
