package org.zikula.modulestudio.generator.cartridges.zclassic.controller.util

import com.google.inject.Inject
import de.guite.modulestudio.metamodel.modulestudio.Application
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class Image {
    @Inject extension FormattingExtensions = new FormattingExtensions()
    @Inject extension NamingExtensions = new NamingExtensions()
    @Inject extension Utils = new Utils()

    FileHelper fh = new FileHelper()

    /**
     * Entry point for the Util class creation.
     */
    def generate(Application it, IFileSystemAccess fsa) {
        println('Generating utility class for image handling')
    	val utilPath = appName.getAppSourceLibPath + 'Util/'
        fsa.generateFile(utilPath + 'Base/Image.php', imageFunctionsBaseFile)
        fsa.generateFile(utilPath + 'Image.php', imageFunctionsFile)
    }

    def private imageFunctionsBaseFile(Application it) '''
    	«fh.phpFileHeader(it)»
    	«imageFunctionsBaseImpl»
    '''

    def private imageFunctionsFile(Application it) '''
    	«fh.phpFileHeader(it)»
    	«imageFunctionsImpl»
    '''

    def imageFunctionsBaseImpl(Application it) '''
        use Imagine\Image\Box;
        use Imagine\Image\Color;
        use Imagine\Image\Point;

        /**
         * Utility base class for image helper methods.
         */
        class «appName»_«fillingUtil»Base_Image extends Zikula_AbstractBase
        {
            /**
             * This method is used by the «appName.formatForDB»ImageThumb modifier
             * as well as the Ajax controller of this application.
             *
             * It serves for creating and displaying a thumbnail image.
             *
             * @param  string    $filePath   The input file path (including file name).
             * @param  int       $width      Desired width.
             * @param  int       $height     Desired height.
             * @param  array     $thumbArgs  Additional arguments.
             *
             * @return string The thumbnail file path.
             */
            public static function getThumb($filePath = '', $width = 100, $height = 80, $thumbArgs = array())
            {
                if (empty($filePath) || !file_exists($filePath)) {
                    return '';
                }
                if (!is_array($thumbArgs)) {
                    $thumbArgs = array();
                }

                // compute thumbnail file path using a sub folder
                $pathInfo = pathinfo($filePath);
                $thumbFilePath = $pathInfo['dirname'] . '/tmb/' . $pathInfo['filename'] . '_' . $width . 'x' . $height . '.' . $pathInfo['extension'];

                // return thumbnail file path if it is already existing
                if (file_exists($thumbFilePath)) {
                    return $thumbFilePath;
                }

                // use Imagine library for creating the thumbnail image
                // documentation can be found at https://github.com/avalanche123/Imagine/tree/master/docs/en
                try {
                    // create instance of Imagine
                    $imagine = new Imagine\Gd\Imagine();
                    // alternative
                    // $imagine = new Imagine\Imagick\Imagine();

                    // open image to be processed
                    $image = $imagine->open($filePath);
                    // remember the image size
                    $originalSize = $image->getSize();

                    if (isset($thumbArgs['crop']) && $thumbArgs['crop'] == true && isset($thumbArgs['x']) && isset($thumbArgs['y'])) {
                        // crop the image
                        $thumb = $image->crop(new Point($thumbArgs['x'], $thumbArgs['y']), new Box($width, $height));
                    } else {
                        // scale down thumbnails per default
                        $thumbMode = Imagine\Image\ImageInterface::THUMBNAIL_INSET;
                        if (isset($thumbArgs['thumbMode']) && $thumbArgs['thumbMode'] == Imagine\Image\ImageInterface::THUMBNAIL_OUTBOUND) {
                            // cut out thumbnail
                            $thumbMode = Imagine\Image\ImageInterface::THUMBNAIL_OUTBOUND;
                        }

                        // define target dimension
                        $thumbSize = new Box($width, $height);
                        // $thumbSize->increase(25); // add 25 pixels to x and y values
                        // $thumbSize->scale(2); // double x and y values

                        $thumb = $image->thumbnail($thumbSize, $thumbMode);
                    }

                    /**
                     * You can do many other image manipulations here as well:
                     *    resize, rotate, crop, save, copy, paste, apply mask and many more
                     * It would even be possible to visualise the image histogram.
                     * See https://github.com/avalanche123/Imagine/blob/master/docs/en/image.rst
                     *
                     * Small example from manual:
                     *
                     *     $bgColour = new Color('fff', 30).darken(40);
                     *     $thumb = $image->resize(new Box(15, 25))
                     *         ->rotate(45, $bgColour)
                     *         ->crop(new Point(0, 0), new Box(45, 45));
                     */

                    /**
                     * Create a new image with fully-transparent black background:
                     *     $bgColour = new Color('000', 100);
                     *     $thumb = $imagine->create($thumbSize, $bgColour);
                     * Create a new image with a vertical gradient background:
                     *     $thumb = $imagine->create($thumbSize)
                     *         ->fill(
                     *             new Imagine\Fill\Gradient\Vertical(
                     *                 $size->getHeight(),
                     *                 new Color(array(127, 127, 127)),
                     *                 new Color('fff')
                     *             )
                     *         );
                     */

                    /**
                     * If you want to do drawings with elements like ellipse, chord or polygon
                     * see https://github.com/avalanche123/Imagine/blob/master/docs/en/drawing.rst
                     *
                     *     $centerPoint = new Point($thumbSize->getWidth()/2, $thumbSize->getHeight()/2);
                     */

                    /**
                     * For font usage use
                     * $font = $imagine->font($file, $size, $colour);
                     */

                    // save thumb file
                    $saveOptions = array();
                    if (in_array($pathInfo['extension'], array('jpg', 'jpeg', 'png'))) {
                        $saveOptions['quality'] = $this->getDefaultQuality($pathInfo['extension']);
                    }
                    $thumb->save($thumbFilePath);

                    // return path to created thumbnail image
                    return $thumbFilePath;

                } catch (Imagine\Exception\Exception $e) {
                    $dom = ZLanguage::getModuleDomain('«appName»');
                    // log this exception
                    LogUtil::registerError(__f('An error occured during thumbnail creation: %s', array($e->getMessage()), $dom));
                    // return the original image as fallback
                    return $filePath;
                }
            }
        }

        /**
         * Returns the quality to be used for a given file extension.
         *
         * @param string $extension The file extension
         *
         * @return integer the desired quality
         */
        protected function getDefaultQuality($extension)
        {
            return 85;
        }
    '''

    def imageFunctionsImpl(Application it) '''
        /**
         * Utility implementation class for image helper methods.
         */
        class «appName»_«fillingUtil»Image extends «appName»_«fillingUtil»Base_Image
        {
            // feel free to add your own convenience methods here
        }
    '''
}
