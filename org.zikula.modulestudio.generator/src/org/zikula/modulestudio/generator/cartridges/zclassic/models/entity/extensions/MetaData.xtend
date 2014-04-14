package org.zikula.modulestudio.generator.cartridges.zclassic.models.entity.extensions

import com.google.inject.Inject
import de.guite.modulestudio.metamodel.modulestudio.DerivedField
import de.guite.modulestudio.metamodel.modulestudio.Entity
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class MetaData extends AbstractExtension implements EntityExtensionInterface {

    @Inject extension FormattingExtensions = new FormattingExtensions
    @Inject extension ModelExtensions = new ModelExtensions
    @Inject extension NamingExtensions = new NamingExtensions
    @Inject extension Utils = new Utils

    /**
     * Generates additional annotations on class level.
     */
    override classAnnotations(Entity it) '''
    '''

    /**
     * Additional field annotations.
     */
    override columnAnnotations(DerivedField it) '''
    '''

    /**
     * Generates additional entity properties.
     */
    override properties(Entity it) '''

        /**
         * @ORM\OneToOne(targetEntity="«IF !container.application.targets('1.3.5')»\«ENDIF»«entityClassName('metaData', false)»", 
         *               mappedBy="entity", cascade={"all"},
         *               orphanRemoval=true)
         * @var «IF !container.application.targets('1.3.5')»\«ENDIF»«entityClassName('metaData', false)»
         */
        protected $metadata = null;
    '''

    /**
     * Generates additional accessor methods.
     */
    override accessors(Entity it) '''
        «val fh = new FileHelper»
        «fh.getterAndSetterMethods(it, 'metadata', (if (!container.application.targets('1.3.5')) '\\' else '') + entityClassName('metaData', false), false, true, 'null', '')»
    '''

    /**
     * Returns the extension class type.
     */
    override extensionClassType(Entity it) {
        'metaData'
    }

    /**
     * Returns the extension class import statements.
     */
    override extensionClassImports(Entity it) '''
        use Doctrine\ORM\Mapping as ORM;
        «IF !container.application.targets('1.3.5')»
            use Zikula\Core\Doctrine\Entity\«extensionBaseClass»;
        «ENDIF»
    '''

    /**
     * Returns the extension base class.
     */
    override extensionBaseClass(Entity it) {
        if (!container.application.targets('1.3.5')) {
            'AbstractEntityMetadata'
        } else {
            'Zikula_Doctrine2_Entity_EntityMetadata'
        }
    }

    /**
     * Returns the extension class description.
     */
    override extensionClassDescription(Entity it) {
        'Entity extension domain class storing ' + name.formatForDisplay + ' meta data.'
    }

    /**
     * Returns the extension base class ORM annotations.
     */
    override extensionClassBaseAnnotations(Entity it) '''
        /**
         * @ORM\OneToOne(targetEntity="«IF !container.application.targets('1.3.5')»\«ENDIF»«entityClassName('', false)»", inversedBy="metadata")
         * @ORM\JoinColumn(name="entityId", referencedColumnName="«getPrimaryKeyFields.head.name.formatForCode»", unique=true)
         * @var «IF !container.application.targets('1.3.5')»\«ENDIF»«entityClassName('', false)»
         */
        protected $entity;

        «extensionClassEntityAccessors»
    '''

    /**
     * Returns the extension implementation class ORM annotations.
     */
    override extensionClassImplAnnotations(Entity it) '''
         «' '»* @ORM\Entity(repositoryClass="«IF !container.application.targets('1.3.5')»\«ENDIF»«repositoryClass(container.application, extensionClassType)»")
         «' '»* @ORM\Table(name="«fullEntityTableName»_metadata")
    '''
}
