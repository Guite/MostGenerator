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

        use Doctrine\DBAL\Types\Types;
        use Doctrine\ORM\Mapping as ORM;
        «IF isLoggable»
            use Gedmo\Mapping\Annotation as Gedmo;
        «ENDIF»
        use Symfony\Component\Validator\Constraints as Assert;

        /**
         * «IF isLoggable»Loggable g«ELSE»G«ENDIF»eographical trait.
         */
        trait «IF isLoggable»Loggable«ENDIF»GeographicalTrait
        {
            «traitImpl»
        }
    '''

    def private traitImpl(Application it) '''
        /**
         * The coordinate's latitude part.
         */
        #[ORM\Column(type: Types::DECIMAL, precision: 12, scale: 7)]
        «IF isLoggable»
            #[Gedmo\Versioned]
        «ENDIF»
        #[Assert\Type(type: 'numeric')]«/* type="float" not possible since decimals are mapped to strings */»
        protected string $latitude = '0.00';

        /**
         * The coordinate's longitude part.
         */
        #[ORM\Column(type: Types::DECIMAL, precision: 12, scale: 7)]
        «IF isLoggable»
            #[Gedmo\Versioned]
        «ENDIF»
        #[Assert\Type(type: 'numeric')]«/* type="float" not possible since decimals are mapped to strings */»
        protected string $longitude = '0.00';
        «fh.getterAndSetterMethods(it, 'latitude', 'string', true, '', '')»
        «fh.getterAndSetterMethods(it, 'longitude', 'string', true, '', '')»
    '''
}
