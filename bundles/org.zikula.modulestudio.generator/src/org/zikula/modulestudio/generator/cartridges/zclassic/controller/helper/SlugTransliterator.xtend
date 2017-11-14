package org.zikula.modulestudio.generator.cartridges.zclassic.controller.helper

import de.guite.modulestudio.metamodel.Application
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class SlugTransliterator {

    extension ModelBehaviourExtensions = new ModelBehaviourExtensions
    extension NamingExtensions = new NamingExtensions
    extension Utils = new Utils

    /**
     * Entry point for the helper class creation.
     */
    def generate(Application it, IFileSystemAccess fsa) {
        if (!hasSluggable) {
            return
        }
        println('Generating custom sluggable transliterator')
        val fh = new FileHelper
        generateClassPair(fsa, 'Helper/SlugTransliterator.php',
            fh.phpFileContent(it, transliteratorBaseImpl), fh.phpFileContent(it, transliteratorImpl)
        )
    }

    def private transliteratorBaseImpl(Application it) '''
        namespace «appNamespace»\Helper\Base;

        use Gedmo\Sluggable\Util\Urlizer;

        /**
         * Custom slug transliterator for proper handling of umlauts and accents during permalink generation.
         *
         * @see https://github.com/Atlantic18/DoctrineExtensions/pull/1504
         */
        abstract class AbstractSlugTransliterator
        {
            public static function transliterate($text, $separator = '-')
            {
                $text = Urlizer::unaccent($text);

                return Urlizer::urlize($text, $separator);
            }
        }
    '''

    def private transliteratorImpl(Application it) '''
        namespace «appNamespace»\Helper;

        use «appNamespace»\Helper\Base\AbstractSlugTransliterator;

        /**
         * Custom slug transliterator for proper handling of umlauts and accents during permalink generation.
         */
        class SlugTransliterator extends AbstractSlugTransliterator
        {
            // feel free to add your own convenience methods here
        }
    '''
}
