package org.zikula.modulestudio.generator.cartridges.symfony.models.entity.extensions

import de.guite.modulestudio.metamodel.Entity
import de.guite.modulestudio.metamodel.Field
import de.guite.modulestudio.metamodel.ManyToOneRelationship
import de.guite.modulestudio.metamodel.OneToManyRelationship
import de.guite.modulestudio.metamodel.OneToOneRelationship
import de.guite.modulestudio.metamodel.Relationship
import org.zikula.modulestudio.generator.cartridges.symfony.smallstuff.FileHelper
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions

class Sluggable extends AbstractExtension implements EntityExtensionInterface {

    extension FormattingExtensions = new FormattingExtensions
    extension ModelBehaviourExtensions = new ModelBehaviourExtensions
    extension NamingExtensions = new NamingExtensions

    /**
     * Generates additional annotations on class level.
     */
    override classAnnotations(Entity it) '''
    '''

    /**
     * Additional field annotations.
     */
    override columnAnnotations(Field it) '''
    '''

    /**
     * Generates additional entity properties.
     */
    override properties(Entity it) '''
        #[ORM\Column(length: «IF slugLength <= 190»«slugLength»«ELSE»190«ENDIF», unique: «slugUnique.displayBool»)]
        «IF loggable»
            #[Gedmo\Versioned]
        «ENDIF»
        «IF hasTranslatableSlug»
            #[Gedmo\Translatable]
        «ENDIF»
        #[Gedmo\Slug(«slugDetails»)]
        «slugHandler»
        #[Assert\Length(min: 1, max: «IF slugLength <= 190»«slugLength»«ELSE»190«ENDIF»)]
        protected string $slug;

    '''

    def private slugDetails(Entity it) '''fields: [«FOR field : getSluggableFields SEPARATOR ', '»'«field.name.formatForCode»'«ENDFOR»], updatable: «slugUpdatable.displayBool», unique: «slugUnique.displayBool», separator: '«slugSeparator»', style: 'default'«''»'''

    def private slugHandler(Entity it) {
        if (tree) {
            return treeSlugHandler
        }
        if (needsRelativeOrInversedRelativeSlugHandler) {
            if (needsRelativeAndInversedRelativeSlugHandlers) {
                return relativeAndInverseRelativeSlugHandlers
            }
            if (needsRelativeSlugHandler) {
                return relativeSlugHandler
            }
            if (needsInversedRelativeSlugHandler) {
                return inversedRelativeSlugHandler
            }
        }
        ''
    }

    def private treeSlugHandler(Entity it) '''
        #[Gedmo\SlugHandler(class: TreeSlugHandler::class, options: [
            'parentRelationField' => 'parent',
            'separator' => '/',
        ])]
    '''

    def private relativeAndInverseRelativeSlugHandlers(Entity it) '''
«FOR relation : getRelationsForRelativeSlugHandler SEPARATOR ','»
«relativeSlugHandlerImpl(relation)»
«ENDFOR»
«FOR relation : getRelationsForInversedRelativeSlugHandler SEPARATOR ','»
«inversedRelativeSlugHandlerImpl(relation)»
«ENDFOR»
'''

    def private relativeSlugHandler(Entity it) '''
«FOR relation : getRelationsForRelativeSlugHandler SEPARATOR ','»
«relativeSlugHandlerImpl(relation)»
«ENDFOR»
'''

    def private relativeSlugHandlerImpl(Entity it, Relationship relation) '''
        #[Gedmo\SlugHandler(class: RelativeSlugHandler::class, options: [
            «IF relation instanceof OneToOneRelationship || relation instanceof OneToManyRelationship»
                'relationField' => '«relation.getRelationAliasName(false).formatForCodeCapital»',
            «ELSEIF relation instanceof ManyToOneRelationship»
                'relationField' => '«relation.getRelationAliasName(true).formatForCodeCapital»',
            «ENDIF»
            'relationSlugField' => 'slug',
            'separator' => '/',
        ])]
    '''

    def private inversedRelativeSlugHandler(Entity it) '''
«FOR relation : getRelationsForInversedRelativeSlugHandler SEPARATOR ','»
«inversedRelativeSlugHandlerImpl(relation)»
«ENDFOR»
 '''

    def private inversedRelativeSlugHandlerImpl(Entity it, Relationship relation) '''
        #[Gedmo\SlugHandler(class: InversedRelativeSlugHandler::class, options: [
            «IF relation instanceof OneToOneRelationship || relation instanceof OneToManyRelationship»
                'relationClass' => '«relation.target.name.formatForCodeCapital + 'Entity'»',
                'mappedBy' => '«relation.getRelationAliasName(true).formatForCodeCapital»',
            «ELSEIF relation instanceof ManyToOneRelationship»
                'relationClass' => '«relation.source.name.formatForCodeCapital + 'Entity'»',
                'mappedBy' => '«relation.getRelationAliasName(false).formatForCodeCapital»',
            «ENDIF»
            'inverseSlugField' => 'slug',
        ])]
    '''

    /**
     * Generates additional accessor methods.
     */
    override accessors(Entity it) '''
        «(new FileHelper(application)).getterAndSetterMethods(it, 'slug', 'string', true, '', '')»
    '''
}
