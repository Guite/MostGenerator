package org.zikula.modulestudio.generator.cartridges.zclassic.models.entity.extensions

import de.guite.modulestudio.metamodel.Application
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class StandardFieldsTrait {

    extension NamingExtensions = new NamingExtensions
    extension Utils = new Utils

    FileHelper fh = new FileHelper

    def generate(Application it, IFileSystemAccess fsa) {
        val filePath = getAppSourceLibPath + 'Traits/StandardFieldsTrait.php'
        if (!shouldBeSkipped(filePath)) {
            if (shouldBeMarked(filePath)) {
                fsa.generateFile(filePath.replace('.php', '.generated.php'), fh.phpFileContent(it, traitImpl))
            } else {
                fsa.generateFile(filePath, fh.phpFileContent(it, traitImpl))
            }
        }
    }

    def private traitImpl(Application it) '''
        namespace «appNamespace»\Traits;

        use Doctrine\ORM\Mapping as ORM;
        use Gedmo\Mapping\Annotation as Gedmo;
        use Symfony\Component\Validator\Constraints as Assert;

        /**
         * Standard fields trait implementation class.
         */
        trait StandardFieldsTrait
        {
            /**
             * @var UserEntity
             * @Gedmo\Blameable(on="create")
             * @ORM\ManyToOne(targetEntity="Zikula\UsersModule\Entity\UserEntity")
             * @ORM\JoinColumn(referencedColumnName="uid")
             */
            protected $createdUserId;

            /**
             * @var UserEntity
             * @Gedmo\Blameable(on="update")
             * @ORM\ManyToOne(targetEntity="Zikula\UsersModule\Entity\UserEntity")
             * @ORM\JoinColumn(referencedColumnName="uid")
             */
            protected $updatedUserId;

            /**
             * @ORM\Column(type="datetime")
             * @Gedmo\Timestampable(on="create")
             * @Assert\DateTime()
             * @var \DateTime $createdDate
             */
            protected $createdDate;

            /**
             * @ORM\Column(type="datetime")
             * @Gedmo\Timestampable(on="update")
             * @Assert\DateTime()
             * @var \DateTime $updatedDate
             */
            protected $updatedDate;

            «fh.getterAndSetterMethods(it, 'createdUserId', 'string', false, true, false, '', '')»
            «fh.getterAndSetterMethods(it, 'updatedUserId', 'string', false, true, false, '', '')»
            «fh.getterAndSetterMethods(it, 'createdDate', 'datetime', false, true, false, '', '')»
            «fh.getterAndSetterMethods(it, 'updatedDate', 'datetime', false, true, false, '', '')»
        }
    '''
}
