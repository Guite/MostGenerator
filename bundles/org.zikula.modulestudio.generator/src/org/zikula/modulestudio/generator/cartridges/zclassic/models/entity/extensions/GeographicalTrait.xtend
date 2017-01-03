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

    def generate(Application it, IFileSystemAccess fsa) {
        val filePath = getAppSourceLibPath + 'Traits/GeographicalTrait.php'
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
        use Symfony\Component\Validator\Constraints as Assert;

        /**
         * Geographical trait implementation class.
         */
        trait StandardFieldsTrait
        {
            «traitImpl»
        }
    '''

    def private traitImpl(Application it) '''
        /**
         * The coordinate's latitude part.
         *
         * @ORM\Column(type="decimal", precision=12, scale=7)
         * @Assert\Type(type="float")
         * @var decimal $latitude
         */
        protected $latitude = 0.00;

        /**
         * The coordinate's longitude part.
         *
         * @ORM\Column(type="decimal", precision=12, scale=7)
         * @Assert\Type(type="float")
         * @var decimal $longitude
         */
        protected $longitude = 0.00;

        «fh.getterAndSetterMethods(it, 'latitude', 'decimal', false, true, false, '', '')»
        «fh.getterAndSetterMethods(it, 'longitude', 'decimal', false, true, false, '', '')»
    '''
}
