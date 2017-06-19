package org.zikula.modulestudio.generator.cartridges.zclassic.controller.helper

import de.guite.modulestudio.metamodel.Application
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper
import org.zikula.modulestudio.generator.extensions.GeneratorSettingsExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils
import org.zikula.modulestudio.generator.extensions.ViewExtensions

class ViewHelper {

    extension GeneratorSettingsExtensions = new GeneratorSettingsExtensions
    extension NamingExtensions = new NamingExtensions
    extension Utils = new Utils
    extension ViewExtensions = new ViewExtensions

    /**
     * Entry point for the helper class creation.
     */
    def generate(Application it, IFileSystemAccess fsa) {
        println('Generating helper class for view layer')
        val fh = new FileHelper
        generateClassPair(fsa, getAppSourceLibPath + 'Helper/ViewHelper.php',
            fh.phpFileContent(it, viewFunctionsBaseImpl), fh.phpFileContent(it, viewFunctionsImpl)
        )
    }

    def private viewFunctionsBaseImpl(Application it) '''
        namespace «appNamespace»\Helper\Base;

        use Symfony\Bundle\TwigBundle\Loader\FilesystemLoader;
        use Symfony\Component\HttpFoundation\Request;
        use Symfony\Component\HttpFoundation\RequestStack;
        use Symfony\Component\HttpFoundation\Response;
        use Twig_Environment;
        use Zikula\Core\Response\PlainResponse;
        use Zikula\ExtensionsModule\Api\«IF targets('1.5')»ApiInterface\VariableApiInterface«ELSE»VariableApi«ENDIF»;
        use Zikula\PermissionsModule\Api\«IF targets('1.5')»ApiInterface\PermissionApiInterface«ELSE»PermissionApi«ENDIF»;
        use Zikula\ThemeModule\Engine\ParameterBag;
        use «appNamespace»\Helper\ControllerHelper;

        /**
         * Helper base class for view layer methods.
         */
        abstract class AbstractViewHelper
        {
            /**
             * @var Twig_Environment
             */
            protected $twig;

            /**
             * @var FilesystemLoader
             */
            protected $twigLoader;

            /**
             * @var Request
             */
            protected $request;

            /**
             * @var PermissionApi«IF targets('1.5')»Interface«ENDIF»
             */
            protected $permissionApi;

            /**
             * @var VariableApi«IF targets('1.5')»Interface«ENDIF»
             */
            protected $variableApi;

            /**
             * @var ParameterBag
             */
            protected $pageVars;

            /**
             * @var ControllerHelper
             */
            protected $controllerHelper;

            /**
             * ViewHelper constructor.
             *
             * @param Twig_Environment $twig             Twig service instance
             * @param FilesystemLoader $twigLoader       Twig loader service instance
             * @param RequestStack     $requestStack     RequestStack service instance
             * @param PermissionApi«IF targets('1.5')»Interface«ENDIF»    $permissionApi    PermissionApi service instance
             * @param VariableApi«IF targets('1.5')»Interface«ELSE»     «ENDIF» $variableApi      VariableApi service instance
             * @param ParameterBag     $pageVars         ParameterBag for theme page variables
             * @param ControllerHelper $controllerHelper ControllerHelper service instance
             *
             * @return void
             */
            public function __construct(
                Twig_Environment $twig,
                FilesystemLoader $twigLoader,
                RequestStack $requestStack,
                PermissionApi«IF targets('1.5')»Interface«ENDIF» $permissionApi,
                VariableApi«IF targets('1.5')»Interface«ENDIF» $variableApi,
                ParameterBag $pageVars,
                ControllerHelper $controllerHelper
            ) {
                $this->twig = $twig;
                $this->twigLoader = $twigLoader;
                $this->request = $requestStack->getCurrentRequest();
                $this->permissionApi = $permissionApi;
                $this->variableApi = $variableApi;
                $this->pageVars = $pageVars;
                $this->controllerHelper = $controllerHelper;
            }

            «getViewTemplate»

            «processTemplate»

            «determineExtension»

            «availableExtensions»

            «processPdf»
        }
    '''

    def private getViewTemplate(Application it) '''
        /**
         * Determines the view template for a certain method with given parameters.
         *
         «IF generateSeparateAdminTemplates»
         * @param string  $type    Current controller (name of currently treated entity)
         * @param string  $func    Current function (index, view, ...)
         * @param boolean $isAdmin Whether an admin template is desired or not
         «ELSE»
         * @param string $type Current controller (name of currently treated entity)
         * @param string $func Current function (index, view, ...)
         «ENDIF»
         *
         * @return string name of template file
         */
        public function getViewTemplate($type, $func«IF generateSeparateAdminTemplates», $isAdmin = false«ENDIF»)
        {
            // create the base template name
            $template = '@«appName»/' . ucfirst($type) . '/' . «IF generateSeparateAdminTemplates»($isAdmin ? 'Admin/' : '') . «ENDIF»$func;

            // check for template extension
            $templateExtension = '.' . $this->determineExtension($type, $func);

            // check whether a special template is used
            $tpl = $this->request->query->getAlnum('tpl', '');
            if (!empty($tpl)) {
                // check if custom template exists
                $customTemplate = $template . ucfirst($tpl);
                if ($this->twigLoader->exists($customTemplate . $templateExtension)) {
                    $template = $customTemplate;
                }
            }

            $template .= $templateExtension;

            return $template;
        }
    '''

    def private processTemplate(Application it) '''
        /**
         * Helper method for managing view templates.
         *
         * @param string  $type               Current controller (name of currently treated entity)
         * @param string  $func               Current function (index, view, ...)
         * @param array   $templateParameters Template data
         * @param string  $template           Optional assignment of precalculated template file
         *
         * @return mixed Output
         */
        public function processTemplate($type, $func, array $templateParameters = [], $template = '')
        {
            $templateExtension = $this->determineExtension($type, $func);
            if (empty($template)) {
                «IF generateSeparateAdminTemplates»
                    $isAdmin = isset($templateParameters['routeArea']) && $templateParameters['routeArea'] == 'admin';
                «ENDIF»
                $template = $this->getViewTemplate($type, $func«IF generateSeparateAdminTemplates», $isAdmin«ENDIF»);
            }

            if ($templateExtension == 'pdf.twig') {
                $template = str_replace('.pdf', '.html', $template);

                return $this->processPdf($templateParameters, $template);
            }

            // look whether we need output with or without the theme
            $raw = $this->request->query->getBoolean('raw', false);
            if (!$raw && $templateExtension != 'html.twig') {
                $raw = true;
            }

            $output = $this->twig->render($template, $templateParameters);
            «val supportedFormats = getListOfViewFormats + getListOfDisplayFormats»
            $response = null;
            if (true === $raw) {
                // standalone output
                «IF supportedFormats.exists[e|e == 'csv']»
                    if ($templateExtension == 'csv.twig') {
                        // convert to UTF-16 for improved excel compatibility
                        // see http://stackoverflow.com/questions/4348802/how-can-i-output-a-utf-8-csv-in-php-that-excel-will-read-properly
                        $output = chr(255) . chr(254) . mb_convert_encoding($output, 'UTF-16LE', 'UTF-8');
                    }

                «ENDIF»
                $response = new PlainResponse($output);
            } else {
                // normal output
                $response = new Response($output);
            }
            «IF !supportedFormats.empty»

                // check if we need to set any custom headers
                switch ($templateExtension) {
                    «IF supportedFormats.exists[e|e == 'csv']»
                        case 'csv.twig':
                            $response->headers->set('Content-Encoding', 'UTF-8');
                            $response->headers->set('Content-Type', 'text/csv; charset=UTF-8');
                            $response->headers->set('Content-Disposition', 'attachment; filename=' . $type . '-list.csv');
                            break;
                    «ENDIF»
                    «IF supportedFormats.exists[e|e == 'ics']»
                        case 'ics.twig':
                            $response->headers->set('Content-Type', 'text/calendar; charset=utf-8');
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
            «ENDIF»

            return $response;
        }
    '''

    def private determineExtension(Application it) '''
        /**
         * Get extension of the currently treated template.
         *
         * @param string $type Current controller (name of currently treated entity)
         * @param string $func Current function (index, view, ...)
         *
         * @return string Template extension
         */
        protected function determineExtension($type, $func)
        {
            $templateExtension = 'html.twig';
            if (!in_array($func, ['view', 'display'])) {
                return $templateExtension;
            }

            $extensions = $this->availableExtensions($type, $func);
            $format = $this->request->getRequestFormat();
            if ($format != 'html' && in_array($format, $extensions)) {
                $templateExtension = $format . '.twig';
            }

            return $templateExtension;
        }
    '''

    def private availableExtensions(Application it) '''
        /**
         * Get list of available template extensions.
         *
         * @param string $type Current controller (name of currently treated entity)
         * @param string $func Current function (index, view, ...)
         *
         * @return array List of allowed template extensions
         */
        public function availableExtensions($type, $func)
        {
            $extensions = [];
            $hasAdminAccess = $this->permissionApi->hasPermission('«appName»:' . ucfirst($type) . ':', '::', ACCESS_ADMIN);
            if ($func == 'view') {
                if ($hasAdminAccess) {
                    $extensions = [«FOR format : getListOfViewFormats SEPARATOR ', '»'«format»'«ENDFOR»];
                } else {
                    $extensions = [«FOR format : getListOfViewFormats.filter[it == 'rss' || it == 'atom' || it == 'pdf'] SEPARATOR ', '»'«format»'«ENDFOR»];
                }
            } elseif ($func == 'display') {
                if ($hasAdminAccess) {
                    $extensions = [«FOR format : getListOfDisplayFormats SEPARATOR ', '»'«format»'«ENDFOR»];
                } else {
                    $extensions = [«FOR format : getListOfDisplayFormats.filter[it == 'ics' || it == 'pdf'] SEPARATOR ', '»'«format»'«ENDFOR»];
                }
            }

            return $extensions;
        }
    '''

    def private processPdf(Application it) '''
        /**
         * Processes a template file using dompdf (LGPL).
         *
         * @param array  $templateParameters Template data
         * @param string $template           Name of template to use
         *
         * @return mixed Output
         */
        protected function processPdf(array $templateParameters = [], $template)
        {
            // first the content, to set page vars
            $output = $this->twig->render($template, $templateParameters);

            // make local images absolute
            $output = str_replace('img src="/', 'img src="' . $this->request->server->get('DOCUMENT_ROOT') . '/', $output);

            // then the surrounding
            $output = $this->twig->render('@«appName»/includePdfHeader.html.twig') . $output . '</body></html>';

            // create name of the pdf output file
            $siteName = $this->variableApi->getSystemVar('sitename');
            $pageTitle = iconv('ISO-8859-1', 'ASCII//TRANSLIT', $this->themePageVars->get('title', ''));
            $fileTitle = iconv('ISO-8859-1', 'ASCII//TRANSLIT', $siteName)
                       . '-'
                       . ($pageTitle != '' ? $pageTitle . '-' : '')
                       . date('Ymd') . '.pdf';

            /*
            if (true === $this->request->query->getBoolean('dbg', false)) {
                die($output);
            }
            */

            // instantiate pdf object
            $pdf = new \Dompdf\Dompdf();
            // define page properties
            $pdf->setPaper('A4', 'portrait');
            // load html input data
            $pdf->loadHtml($output);
            // create the actual pdf file
            $pdf->render();
            // stream output to browser
            $pdf->stream($fileTitle);

            return new Response();
        }
    '''

    def private viewFunctionsImpl(Application it) '''
        namespace «appNamespace»\Helper;

        use «appNamespace»\Helper\Base\AbstractViewHelper;

        /**
         * Helper implementation class for view layer methods.
         */
        class ViewHelper extends AbstractViewHelper
        {
            // feel free to add your own convenience methods here
        }
    '''
}
