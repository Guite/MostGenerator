package org.zikula.modulestudio.generator.cartridges.zclassic.models.entity.extensions

import de.guite.modulestudio.metamodel.Application
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class GeographicalTrait {

    extension NamingExtensions = new NamingExtensions
    extension Utils = new Utils

    FileHelper fh = new FileHelper
    Boolean isLoggable

    def generate(Application it, IFileSystemAccess fsa, Boolean loggable) {
        isLoggable = loggable
        val filePath = 'Traits/' + (if (loggable) 'Loggable' else '') + 'GeographicalTrait.php'
        if (!shouldBeSkipped(filePath)) {
            if (shouldBeMarked(filePath)) {
                fsa.generateFile(filePath.replace('.php', '.generated.php'), fh.phpFileContent(it, traitFile))
            } else {
                fsa.generateFile(filePath, fh.phpFileContent(it, traitFile))
            }
        }
    }

    def private traitFile(Application it) '''
        namespace «appNamespace»\Traits;

        use Doctrine\ORM\Mapping as ORM;
        «IF isLoggable»
            use Gedmo\Mapping\Annotation as Gedmo;
        «ENDIF»
        use Symfony\Component\Validator\Constraints as Assert;

        /**
         * «IF isLoggable»Loggable g«ELSE»G«ENDIF»eographical trait implementation class.
         */
        trait «IF isLoggable»Loggable«ENDIF»GeographicalTrait
        {
            «traitImpl»
        }
    '''

    def private traitImpl(Application it) '''
        /**
         * The coordinate's latitude part.
         *
         * @ORM\Column(type="decimal", precision=12, scale=7)
         «IF isLoggable»
          * @Gedmo\Versioned
         «ENDIF»«/* disabled due to https://github.com/doctrine/dbal/issues/1347
                  * @Assert\Type(type="float") */»
         * @var float $latitude
         */
        protected $latitude = 0.00;

        /**
         * The coordinate's longitude part.
         *
         * @ORM\Column(type="decimal", precision=12, scale=7)
         «IF isLoggable»
          * @Gedmo\Versioned
         «ENDIF»«/* disabled due to https://github.com/doctrine/dbal/issues/1347
         * @Assert\Type(type="float") */»
         * @var float $longitude
         */
        protected $longitude = 0.00;

        «fh.getterAndSetterMethods(it, 'latitude', 'float', false, true, false, '', '')»
        «fh.getterAndSetterMethods(it, 'longitude', 'float', false, true, false, '', '')»
    '''
}
