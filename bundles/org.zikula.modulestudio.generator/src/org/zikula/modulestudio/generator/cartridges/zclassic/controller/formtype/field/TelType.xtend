package org.zikula.modulestudio.generator.cartridges.zclassic.controller.formtype.field

import de.guite.modulestudio.metamodel.Application
import org.zikula.modulestudio.generator.application.IMostFileSystemAccess
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class TelType {

    extension FormattingExtensions = new FormattingExtensions
    extension Utils = new Utils

    def generate(Application it, IMostFileSystemAccess fsa) {
        if (targets('2.0')) {
            return
        }
        fsa.generateClassPair('Form/Type/Field/TelType.php', telTypeBaseImpl, telTypeImpl)
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
            public function getParent()
            {
                return TextType::class;
            }

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
