package org.zikula.modulestudio.generator.cartridges.zclassic.controller.formtype.field

import de.guite.modulestudio.metamodel.Application
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class GeoType {

    extension FormattingExtensions = new FormattingExtensions()
    extension NamingExtensions = new NamingExtensions()
    extension Utils = new Utils()

    FileHelper fh = new FileHelper()

    def generate(Application it, IFileSystemAccess fsa) {
        generateClassPair(fsa, getAppSourceLibPath + 'Form/Type/Field/GeoType.php',
            fh.phpFileContent(it, geoTypeBaseImpl), fh.phpFileContent(it, geoTypeImpl)
        )
    }

    def private geoTypeBaseImpl(Application it) '''
        namespace «appNamespace»\Form\Type\Field\Base;

        use Symfony\Component\Form\AbstractType;
        «IF targets('1.5')»
            use Symfony\Component\Form\Extension\Core\Type\NumberType;
        «ENDIF»
        use Symfony\Component\OptionsResolver\OptionsResolver;

        /**
         * Geo field type base class.
         */
        abstract class AbstractGeoType extends AbstractType
        {
            /**
             * @inheritDoc
             */
            public function configureOptions(OptionsResolver $resolver)
            {
                parent::configureOptions($resolver);

                $resolver->setDefaults([
                    'scale' => 7,
                    'attr' => [
                        'maxlength' => 12,
                        'class' => 'geo-date'
                    ]
                ]);
            }

            /**
             * @inheritDoc
             */
            public function getParent()
            {
                return «IF targets('1.5')»NumberType::class«ELSE»'Symfony\Component\Form\Extension\Core\Type\NumberType'«ENDIF»;
            }

            /**
             * @inheritDoc
             */
            public function getBlockPrefix()
            {
                return '«appName.formatForDB»_field_geo';
            }
        }
    '''

    def private geoTypeImpl(Application it) '''
        namespace «appNamespace»\Form\Type\Field;

        use «appNamespace»\Form\Type\Field\Base\AbstractGeoType;

        /**
         * Geo field type implementation class.
         */
        class GeoType extends AbstractGeoType
        {
            // feel free to add your customisation here
        }
    '''
}
