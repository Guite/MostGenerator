package org.zikula.modulestudio.generator.cartridges.zclassic.models.entity.extensions

import de.guite.modulestudio.metamodel.Application
import org.zikula.modulestudio.generator.application.IMostFileSystemAccess
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class StandardFieldsTrait {

    extension ModelBehaviourExtensions = new ModelBehaviourExtensions
    extension Utils = new Utils

    FileHelper fh
    Boolean isLoggable

    def generate(Application it, IMostFileSystemAccess fsa, Boolean loggable) {
        if (!hasStandardFieldEntities) {
            return
        }
        fh = new FileHelper(it)
        isLoggable = loggable
        val filePath = 'Traits/' + (if (loggable) 'Loggable' else '') + 'StandardFieldsTrait.php'
        fsa.generateFile(filePath, traitFile)
    }

    def private traitFile(Application it) '''
        namespace «appNamespace»\Traits;

        use DateTimeInterface;
        use Doctrine\DBAL\Types\Types;
        use Doctrine\ORM\Mapping as ORM;
        use Gedmo\Mapping\Annotation as Gedmo;
        use Symfony\Component\Validator\Constraints as Assert;
        use Zikula\UsersModule\Entity\UserEntity;

        /**
         * «IF isLoggable»Loggable s«ELSE»S«ENDIF»tandard fields trait.
         */
        trait «IF isLoggable»Loggable«ENDIF»StandardFieldsTrait
        {
            «traitImpl»
        }
    '''

    def private traitImpl(Application it) '''
        #[ORM\ManyToOne]
        #[ORM\JoinColumn(referencedColumnName: 'uid')]
        #[Gedmo\Blameable(on: 'create')]
        «IF isLoggable»
            #[Gedmo\Versioned]
        «ENDIF»
        protected ?UserEntity $createdBy = null;

        #[ORM\Column(type: Types::DATETIME_IMMUTABLE)]
        #[Gedmo\Timestampable(on: 'create')]
        «IF isLoggable»
            #[Gedmo\Versioned]
        «ENDIF»
        protected ?DateTimeInterface $createdDate = null;

        #[ORM\ManyToOne]
        #[ORM\JoinColumn(referencedColumnName: 'uid')]
        #[Gedmo\Blameable(on: 'update')]
        protected ?UserEntity $updatedBy = null;

        #[ORM\Column(type: Types::DATETIME_IMMUTABLE)]
        #[Gedmo\Timestampable(on: 'update')]
        «IF isLoggable»
            #[Gedmo\Versioned]
        «ENDIF»
        protected ?DateTimeInterface $updatedDate = null;
        «fh.getterAndSetterMethods(it, 'createdBy', 'UserEntity', true, '', '')»
        «fh.getterAndSetterMethods(it, 'createdDate', 'DateTimeInterface', true, '', '')»
        «fh.getterAndSetterMethods(it, 'updatedBy', 'UserEntity', true, '', '')»
        «fh.getterAndSetterMethods(it, 'updatedDate', 'DateTimeInterface', true, '', '')»
    '''
}
