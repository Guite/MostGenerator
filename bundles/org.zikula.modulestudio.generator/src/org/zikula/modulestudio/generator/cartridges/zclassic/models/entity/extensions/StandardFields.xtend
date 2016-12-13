package org.zikula.modulestudio.generator.cartridges.zclassic.models.entity.extensions

import de.guite.modulestudio.metamodel.DerivedField
import de.guite.modulestudio.metamodel.Entity
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper
import org.zikula.modulestudio.generator.extensions.Utils

class StandardFields extends AbstractExtension implements EntityExtensionInterface {

    extension Utils = new Utils

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
         «IF !application.targets('1.4-dev')»
         * @ORM\Column(type="integer")
         * @ZK\StandardFields(type="userid", on="create")
         * @var integer $createdUserId
         «ELSE»
         * @ORM\Column(type="string")
         * @Gedmo\Blameable(on="create")«/*
         * @Assert\Type(type="integer")*/»
         * @var string $createdUserId
         «ENDIF»
         */
        protected $createdUserId;

        /**
         «IF loggable»
             * @Gedmo\Versioned
         «ENDIF»
         «IF !application.targets('1.4-dev')»
         * @ORM\Column(type="integer")
         * @ZK\StandardFields(type="userid", on="update")
         * @var integer $updatedUserId
         «ELSE»
         * @ORM\Column(type="string")
         * @Gedmo\Blameable(on="update")«/*
         * @Assert\Type(type="integer")*/»
         * @var string $updatedUserId
         «ENDIF»
         */
        protected $updatedUserId;

        /**
         * @ORM\Column(type="datetime")
         * @Gedmo\Timestampable(on="create")
         «IF !application.targets('1.3.x')»
         * @Assert\DateTime()
         «ENDIF»
         * @var \DateTime $createdDate
         */
        protected $createdDate;

        /**
         «IF loggable»
             * @Gedmo\Versioned
         «ENDIF»
         * @ORM\Column(type="datetime")
         * @Gedmo\Timestampable(on="update")
         «IF !application.targets('1.3.x')»
         * @Assert\DateTime()
         «ENDIF»
         * @var \DateTime $updatedDate
         */
        protected $updatedDate;
    '''

    /**
     * Generates additional accessor methods.
     */
    override accessors(Entity it) '''
        «val fh = new FileHelper»
        «fh.getterAndSetterMethods(it, 'createdUserId', (if (application.targets('1.3.x')) 'integer' else 'string'), false, true, false, '', '')»
        «fh.getterAndSetterMethods(it, 'updatedUserId', (if (application.targets('1.3.x')) 'integer' else 'string'), false, true, false, '', '')»
        «fh.getterAndSetterMethods(it, 'createdDate', 'datetime', false, true, false, '', '')»
        «fh.getterAndSetterMethods(it, 'updatedDate', 'datetime', false, true, false, '', '')»
    '''
}
