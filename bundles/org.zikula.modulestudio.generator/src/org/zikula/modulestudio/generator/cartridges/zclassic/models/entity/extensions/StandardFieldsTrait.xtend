package org.zikula.modulestudio.generator.cartridges.zclassic.models.entity.extensions

import de.guite.modulestudio.metamodel.Application
import org.zikula.modulestudio.generator.application.IMostFileSystemAccess
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class StandardFieldsTrait {

    extension ModelBehaviourExtensions = new ModelBehaviourExtensions
    extension Utils = new Utils

    FileHelper fh = new FileHelper
    Boolean isLoggable

    def generate(Application it, IMostFileSystemAccess fsa, Boolean loggable) {
        if (!hasStandardFieldEntities) {
            return
        }
        isLoggable = loggable
        val filePath = 'Traits/' + (if (loggable) 'Loggable' else '') + 'StandardFieldsTrait.php'
        fsa.generateFile(filePath, traitFile)
    }

    def private traitFile(Application it) '''
        namespace «appNamespace»\Traits;

        use Doctrine\ORM\Mapping as ORM;
        use Gedmo\Mapping\Annotation as Gedmo;
        use Symfony\Component\Validator\Constraints as Assert;
        use Zikula\UsersModule\Entity\UserEntity;

        /**
         * «IF isLoggable»Loggable s«ELSE»S«ENDIF»tandard fields trait implementation class.
         */
        trait «IF isLoggable»Loggable«ENDIF»StandardFieldsTrait
        {
            «traitImpl»
        }
    '''

    def private traitImpl(Application it) '''
        /**
         * @Gedmo\Blameable(on="create")
         * @ORM\ManyToOne(targetEntity="Zikula\UsersModule\Entity\UserEntity")
         * @ORM\JoinColumn(referencedColumnName="uid")
         «IF isLoggable»
          * @Gedmo\Versioned
         «ENDIF»
         * @var UserEntity
         */
        protected $createdBy;

        /**
         * @ORM\Column(type="datetime")
         * @Gedmo\Timestampable(on="create")
         «IF isLoggable»
          * @Gedmo\Versioned
         «ENDIF»
         * @Assert\DateTime()
         * @var \DateTimeInterface $createdDate
         */
        protected $createdDate;

        /**
         * @Gedmo\Blameable(on="update")
         * @ORM\ManyToOne(targetEntity="Zikula\UsersModule\Entity\UserEntity")
         * @ORM\JoinColumn(referencedColumnName="uid")
         «IF isLoggable»
          * @Gedmo\Versioned
         «ENDIF»
         * @var UserEntity
         */
        protected $updatedBy;

        /**
         * @ORM\Column(type="datetime")
         * @Gedmo\Timestampable(on="update")
         «IF isLoggable»
          * @Gedmo\Versioned
         «ENDIF»
         * @Assert\DateTime()
         * @var \DateTimeInterface $updatedDate
         */
        protected $updatedDate;

        «fh.getterAndSetterMethods(it, 'createdBy', 'UserEntity', false, true, false, '', '')»
        «fh.getterAndSetterMethods(it, 'createdDate', 'datetime', false, true, false, '', '')»
        «fh.getterAndSetterMethods(it, 'updatedBy', 'UserEntity', false, true, false, '', '')»
        «fh.getterAndSetterMethods(it, 'updatedDate', 'datetime', false, true, false, '', '')»
    '''
}
