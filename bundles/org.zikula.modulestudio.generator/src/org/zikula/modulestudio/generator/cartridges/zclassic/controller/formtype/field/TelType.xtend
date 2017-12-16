package org.zikula.modulestudio.generator.cartridges.zclassic.controller.formtype.field

import de.guite.modulestudio.metamodel.Application
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class TelType {

    extension FormattingExtensions = new FormattingExtensions
    extension NamingExtensions = new NamingExtensions
    extension Utils = new Utils

    FileHelper fh = new FileHelper

    def generate(Application it, IFileSystemAccess fsa) {
        if (targets('2.0')) {
            return
        }
        generateClassPair(fsa, 'Form/Type/Field/TelType.php',
            fh.phpFileContent(it, telTypeBaseImpl), fh.phpFileContent(it, telTypeImpl)
        )
    }

    def private telTypeBaseImpl(Application it) '''
        namespace «appNamespace»\Form\Type\Field\Base;

        use Symfony\Component\Form\AbstractType;
        use Symfony\Component\Form\Extension\Core\Type\TextType;

        /**
         * Telephone field type base class.
         */
        abstract class AbstractTelType extends AbstractType
        {
            /**
             * @inheritDoc
             */
            public function getParent()
            {
                return TextType::class;
            }

            /**
             * @inheritDoc
             */
            public function getBlockPrefix()
            {
                return '«appName.formatForDB»_field_tel';
            }
        }
    '''

    def private telTypeImpl(Application it) '''
        namespace «appNamespace»\Form\Type\Field;

        use «appNamespace»\Form\Type\Field\Base\AbstractTelType;

        /**
         * Telephone field type implementation class.
         */
        class TelType extends AbstractTelType
        {
            // feel free to add your customisation here
        }
    '''
}
