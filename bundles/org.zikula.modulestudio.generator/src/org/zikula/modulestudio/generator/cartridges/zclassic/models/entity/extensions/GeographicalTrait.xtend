package org.zikula.modulestudio.generator.cartridges.zclassic.models.entity.extensions

import de.guite.modulestudio.metamodel.Application
import org.zikula.modulestudio.generator.application.IMostFileSystemAccess
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper
import org.zikula.modulestudio.generator.extensions.Utils

class GeographicalTrait {

    extension Utils = new Utils

    FileHelper fh
    Boolean isLoggable

    def generate(Application it, IMostFileSystemAccess fsa, Boolean loggable) {
        fh = new FileHelper(it)
        isLoggable = loggable
        val filePath = 'Traits/' + (if (loggable) 'Loggable' else '') + 'GeographicalTrait.php'
        fsa.generateFile(filePath, traitFile)
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
         «ENDIF»
         * @Assert\Type(type="numeric")«/* type="float" not possible due to https://github.com/doctrine/dbal/issues/1347 */»
         * @var float $latitude
         */
        protected $latitude = 0.00;

        /**
         * The coordinate's longitude part.
         *
         * @ORM\Column(type="decimal", precision=12, scale=7)
         «IF isLoggable»
          * @Gedmo\Versioned
         «ENDIF»
         * @Assert\Type(type="numeric")«/* type="float" not possible due to https://github.com/doctrine/dbal/issues/1347 */»
         * @var float $longitude
         */
        protected $longitude = 0.00;
        «IF targets('3.0')»
            «fh.getterAndSetterMethods(it, 'latitude', 'float', false, true, true, '', '')»
            «fh.getterAndSetterMethods(it, 'longitude', 'float', false, true, true, '', '')»
        «ELSE»
            «fh.getterAndSetterMethods(it, 'latitude', 'float', false, true, false, '', '')»
            «fh.getterAndSetterMethods(it, 'longitude', 'float', false, true, false, '', '')»
        «ENDIF»
    '''
}
