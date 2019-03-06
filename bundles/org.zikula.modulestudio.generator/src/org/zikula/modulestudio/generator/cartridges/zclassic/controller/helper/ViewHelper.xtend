package org.zikula.modulestudio.generator.cartridges.zclassic.controller.helper

import de.guite.modulestudio.metamodel.Application
import org.zikula.modulestudio.generator.application.IMostFileSystemAccess
import org.zikula.modulestudio.generator.extensions.Utils
import org.zikula.modulestudio.generator.extensions.ViewExtensions

class ViewHelper {

    extension Utils = new Utils
    extension ViewExtensions = new ViewExtensions

    /**
     * Entry point for the helper class creation.
     */
    def generate(Application it, IMostFileSystemAccess fsa) {
        'Generating helper class for view layer'.printIfNotTesting(fsa)
        fsa.generateClassPair('Helper/ViewHelper.php', viewFunctionsBaseImpl, viewFunctionsImpl)
    }

    def private viewFunctionsBaseImpl(Application it) '''
        namespace «appNamespace»\Helper\Base;

        «IF !targets('3.0')»
            use Symfony\Bundle\TwigBundle\Loader\FilesystemLoader;
        «ENDIF»
        use Symfony\Component\HttpFoundation\RequestStack;
        use Symfony\Component\HttpFoundation\Response;
        use Twig«IF targets('3.0')»\«ELSE»_«ENDIF»Environment;
        «IF targets('3.0')»
            use Twig\Loader\LoaderInterface;
        «ENDIF»
        use Zikula\Core\Response\PlainResponse;
        use Zikula\ExtensionsModule\Api\ApiInterface\VariableApiInterface;
        use Zikula\ThemeModule\Engine\AssetFilter;
        «IF generatePdfSupport»
            use Zikula\ThemeModule\Engine\ParameterBag;
        «ENDIF»
        use «appNamespace»\Helper\ControllerHelper;
        use «appNamespace»\Helper\PermissionHelper;

        /**
         * Helper base class for view layer methods.
         */
        abstract class AbstractViewHelper
        {
            «helperBaseImpl»
        }
    '''

    def private helperBaseImpl(Application it) '''
        /**
         * @var «IF !targets('3.0')»Twig_«ENDIF»Environment
         */
        protected $twig;

        /**
         * @var «IF targets('3.0')»LoaderInterface«ELSE»FilesystemLoader«ENDIF»
         */
        protected $twigLoader;

        /**
         * @var RequestStack
         */
        protected $requestStack;

        /**
         * @var VariableApiInterface
         */
        protected $variableApi;

        /**
         * @var AssetFilter
         */
        protected $assetFilter;

        «IF generatePdfSupport»
            /**
             * @var ParameterBag
             */
            protected $pageVars;

        «ENDIF»
        /**
         * @var ControllerHelper
         */
        protected $controllerHelper;

        /**
         * @var PermissionHelper
         */
        protected $permissionHelper;

        /**
         * ViewHelper constructor.
         *
         «IF targets('3.0')»
         * @param Environment          $twig             Twig service instance
         * @param LoaderInterface      $twigLoader       Twig loader service instance
         «ELSE»
         * @param Twig_Environment     $twig             Twig service instance
         * @param FilesystemLoader     $twigLoader       Twig loader service instance
         «ENDIF»
         * @param RequestStack         $requestStack     RequestStack service instance
         * @param VariableApiInterface $variableApi      VariableApi service instance
         * @param AssetFilter          $assetFilter      Theme asset filter
         «IF generatePdfSupport»
         * @param ParameterBag         $pageVars         ParameterBag for theme page variables
         «ENDIF»
         * @param ControllerHelper     $controllerHelper ControllerHelper service instance
         * @param PermissionHelper     $permissionHelper PermissionHelper service instance
         *
         * @return void
         */
        public function __construct(
            «IF !targets('3.0')»Twig_«ENDIF»Environment $twig,
            «IF targets('3.0')»LoaderInterface«ELSE»FilesystemLoader«ENDIF» $twigLoader,
            RequestStack $requestStack,
            VariableApiInterface $variableApi,
            AssetFilter $assetFilter,
            «IF generatePdfSupport»
                ParameterBag $pageVars,
            «ENDIF»
            ControllerHelper $controllerHelper,
            PermissionHelper $permissionHelper
        ) {
            $this->twig = $twig;
            $this->twigLoader = $twigLoader;
            $this->requestStack = $requestStack;
            $this->variableApi = $variableApi;
            $this->assetFilter = $assetFilter;
            «IF generatePdfSupport»
                $this->pageVars = $pageVars;
            «ENDIF»
            $this->controllerHelper = $controllerHelper;
            $this->permissionHelper = $permissionHelper;
        }

        «getViewTemplate»

        «processTemplate»

        «injectAssetsIntoRawOutput»

        «determineExtension»

        «availableExtensions»
        «IF generatePdfSupport»

            «processPdf»
        «ENDIF»
    '''

    def private getViewTemplate(Application it) '''
        /**
         * Determines the view template for a certain method with given parameters.
         *
         «IF separateAdminTemplates»
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
        public function getViewTemplate($type, $func«IF separateAdminTemplates», $isAdmin = false«ENDIF»)
        {
            // create the base template name
            $template = '@«appName»/' . ucfirst($type) . '/' . «IF separateAdminTemplates»($isAdmin ? 'Admin/' : '') . «ENDIF»$func;

            // check for template extension
            $templateExtension = '.' . $this->determineExtension($type, $func);

            // check whether a special template is used
            $tpl = $this->requestStack->getCurrentRequest()->query->getAlnum('tpl', '');
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
         * @param string $type               Current controller (name of currently treated entity)
         * @param string $func               Current function (index, view, ...)
         * @param array  $templateParameters Template data
         * @param string $template           Optional assignment of precalculated template file
         *
         * @return mixed Output
         */
        public function processTemplate($type, $func, array $templateParameters = [], $template = '')
        {
            $templateExtension = $this->determineExtension($type, $func);
            if (empty($template)) {
                «IF separateAdminTemplates»
                    $isAdmin = isset($templateParameters['routeArea']) && $templateParameters['routeArea'] == 'admin';
                «ENDIF»
                $template = $this->getViewTemplate($type, $func«IF separateAdminTemplates», $isAdmin«ENDIF»);
            }
            «IF generatePdfSupport»

                if ($templateExtension == 'pdf.twig') {
                    $template = str_replace('.pdf', '.html', $template);

                    return $this->processPdf($templateParameters, $template);
                }
            «ENDIF»

            // look whether we need output with or without the theme
            $raw = $this->requestStack->getCurrentRequest()->query->getBoolean('raw', false);
            if (!$raw && $templateExtension != 'html.twig') {
                $raw = true;
            }

            $output = $this->twig->render($template, $templateParameters);
            «val supportedFormats = getListOfViewFormats + getListOfDisplayFormats»
            $response = null;
            if (true === $raw) {
                // standalone output
                «IF supportedFormats.exists[it == 'csv']»
                    if ($templateExtension == 'csv.twig') {
                        // convert to UTF-16 for improved excel compatibility
                        // see http://stackoverflow.com/questions/4348802/how-can-i-output-a-utf-8-csv-in-php-that-excel-will-read-properly
                        $output = chr(255) . chr(254) . mb_convert_encoding($output, 'UTF-16LE', 'UTF-8');
                    }
                «ENDIF»
                $output = $this->injectAssetsIntoRawOutput($output);

                $response = new PlainResponse($output);
            } else {
                // normal output
                $response = new Response($output);
            }
            «IF !supportedFormats.empty»

                // check if we need to set any custom headers
                switch ($templateExtension) {
                    «IF supportedFormats.exists[it == 'csv']»
                        case 'csv.twig':
                            $response->headers->set('Content-Encoding', 'UTF-8');
                            $response->headers->set('Content-Type', 'text/csv; charset=UTF-8');
                            $response->headers->set('Content-Disposition', 'attachment; filename=' . $type . '-list.csv');
                            break;
                    «ENDIF»
                    «IF supportedFormats.exists[it == 'ics']»
                        case 'ics.twig':
                            $response->headers->set('Content-Type', 'text/calendar; charset=utf-8');
                            break;
                    «ENDIF»
                    «IF supportedFormats.exists[it == 'json']»
                        case 'json.twig':
                            $response->headers->set('Content-Type', 'application/json');
                            break;
                    «ENDIF»
                    «IF supportedFormats.exists[it == 'kml']»
                        case 'kml.twig':
                            $response->headers->set('Content-Type', 'application/vnd.google-earth.kml+xml');
                            break;
                    «ENDIF»
                    «IF supportedFormats.exists[it == 'xml']»
                        case 'xml.twig':
                            $response->headers->set('Content-Type', 'text/xml');
                            break;
                    «ENDIF»
                    «IF supportedFormats.exists[it == 'atom']»
                        case 'atom.twig':
                            $response->headers->set('Content-Type', 'application/atom+xml');
                            break;
                    «ENDIF»
                    «IF supportedFormats.exists[it == 'rss']»
                        case 'rss.twig':
                            $response->headers->set('Content-Type', 'application/rss+xml');
                            break;
                    «ENDIF»
                }
            «ENDIF»

            return $response;
        }
    '''

    def private injectAssetsIntoRawOutput(Application it) '''
        /**
         * Adds assets to a raw page which is not processed by the Theme engine.
         *
         * @param string $output The output to be enhanced
         *
         * @return string Output including additional assets
         */
        protected function injectAssetsIntoRawOutput($output = '')
        {
            return $this->assetFilter->filter($output);
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
            $format = $this->requestStack->getCurrentRequest()->getRequestFormat();
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
         * @return string[] List of allowed template extensions
         */
        protected function availableExtensions($type, $func)
        {
            $extensions = [];
            $hasAdminAccess = $this->permissionHelper->hasComponentPermission($type, ACCESS_ADMIN);
            if ($func == 'view') {
                if ($hasAdminAccess) {
                    $extensions = [«FOR format : getListOfViewFormats SEPARATOR ', '»'«format»'«ENDFOR»];
                } else {
                    $extensions = [«FOR format : getListOfViewFormats.filter[#['rss', 'atom', 'pdf'].contains(it)] SEPARATOR ', '»'«format»'«ENDFOR»];
                }
            } elseif ($func == 'display') {
                if ($hasAdminAccess) {
                    $extensions = [«FOR format : getListOfDisplayFormats SEPARATOR ', '»'«format»'«ENDFOR»];
                } else {
                    $extensions = [«FOR format : getListOfDisplayFormats.filter[#['ics', 'pdf'].contains(it)] SEPARATOR ', '»'«format»'«ENDFOR»];
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
        protected function processPdf(array $templateParameters = [], $template = '')
        {
            // first the content, to set page vars
            $output = $this->twig->render($template, $templateParameters);

            // make local images absolute
            $request = $this->requestStack->getCurrentRequest();
            $output = str_replace('img src="' . $request->getSchemeAndHttpHost() . $request->getBasePath() . '/', 'img src="/', $output);
            $output = str_replace('img src="/', 'img src="' . $request->server->get('DOCUMENT_ROOT') . '/', $output);

            // then the surrounding
            $output = $this->twig->render('@«appName»/includePdfHeader.html.twig') . $output . '</body></html>';

            // create name of the pdf output file
            $siteName = $this->variableApi->getSystemVar('sitename');
            $pageTitle = iconv('UTF-8', 'ASCII//TRANSLIT', $this->pageVars->get('title', ''));
            $fileTitle = iconv('UTF-8', 'ASCII//TRANSLIT', $siteName)
                       . '-'
                       . ($pageTitle != '' ? $pageTitle . '-' : '')
                       . date('Ymd') . '.pdf';
           $fileTitle = str_replace(' ', '_', $fileTitle);

            /*
            if (true === $request->query->getBoolean('dbg', false)) {
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
