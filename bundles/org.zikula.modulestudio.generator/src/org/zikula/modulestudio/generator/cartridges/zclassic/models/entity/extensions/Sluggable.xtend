package org.zikula.modulestudio.generator.cartridges.zclassic.models.entity.extensions

import de.guite.modulestudio.metamodel.DerivedField
import de.guite.modulestudio.metamodel.Entity
import de.guite.modulestudio.metamodel.EntityTreeType
import de.guite.modulestudio.metamodel.JoinRelationship
import de.guite.modulestudio.metamodel.ManyToOneRelationship
import de.guite.modulestudio.metamodel.OneToManyRelationship
import de.guite.modulestudio.metamodel.OneToOneRelationship
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper
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
    override columnAnnotations(DerivedField it) '''
    '''

    /**
     * Generates additional entity properties.
     */
    override properties(Entity it) '''
        /**
         «IF loggable»
             * @Gedmo\Versioned
         «ENDIF»
         «IF hasTranslatableSlug»
             * @Gedmo\Translatable
         «ENDIF»
         * @Gedmo\Slug(«slugDetails»«slugHandler»)
         * @ORM\Column(type="string", length=«IF slugLength <= 190»«slugLength»«ELSE»190«ENDIF», unique=«slugUnique.displayBool»)
         * @Assert\Length(min="1", max="«IF slugLength <= 190»«slugLength»«ELSE»190«ENDIF»")
         */
        protected string $slug;

    '''

    def private slugDetails(Entity it) '''fields={«FOR field : getSluggableFields SEPARATOR ', '»"«field.name.formatForCode»"«ENDFOR»}, updatable=«slugUpdatable.displayBool», unique=«slugUnique.displayBool», separator="«slugSeparator»", style="«slugStyle.slugStyleAsConstant»"'''

    def private slugHandler(Entity it) {
        if (tree != EntityTreeType.NONE) {
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

    def private treeSlugHandler(Entity it) ''', handlers={
«treeSlugHandlerImpl»
* }'''

    def private treeSlugHandlerImpl(Entity it) '''
        *     @Gedmo\SlugHandler(class="Gedmo\Sluggable\Handler\TreeSlugHandler", options={
        «slugHandlerOption('parentRelationField', 'parent')»,
        «slugHandlerOption('separator', '/')»
        *     })
    '''

    def private relativeAndInverseRelativeSlugHandlers(Entity it) ''', handlers={
«FOR relation : getRelationsForRelativeSlugHandler SEPARATOR ','»
«relativeSlugHandlerImpl(relation)»
«ENDFOR»,
«FOR relation : getRelationsForInversedRelativeSlugHandler SEPARATOR ','»
«inversedRelativeSlugHandlerImpl(relation)»
«ENDFOR»
* }'''

    def private relativeSlugHandler(Entity it) ''', handlers={
«FOR relation : getRelationsForRelativeSlugHandler SEPARATOR ','»
«relativeSlugHandlerImpl(relation)»
«ENDFOR»
* }'''

    def private relativeSlugHandlerImpl(Entity it, JoinRelationship relation) '''
        *     @Gedmo\SlugHandler(class="Gedmo\Sluggable\Handler\RelativeSlugHandler", options={
        «IF relation instanceof OneToOneRelationship || relation instanceof OneToManyRelationship»
            «slugHandlerOption('relationField', relation.getRelationAliasName(false).formatForCodeCapital)»
        «ELSEIF relation instanceof ManyToOneRelationship»
            «slugHandlerOption('relationField', relation.getRelationAliasName(true).formatForCodeCapital)»
        «ENDIF»
        «slugHandlerOption('relationSlugField', 'slug')»
        «slugHandlerOption('separator', '/')»
        *     })
    '''

    def private inversedRelativeSlugHandler(Entity it) ''', handlers={
«FOR relation : getRelationsForInversedRelativeSlugHandler SEPARATOR ','»
«inversedRelativeSlugHandlerImpl(relation)»
«ENDFOR»
 * }'''

    def private inversedRelativeSlugHandlerImpl(Entity it, JoinRelationship relation) '''
        *     @Gedmo\SlugHandler(class="Gedmo\Sluggable\Handler\InversedRelativeSlugHandler", options={
        «IF relation instanceof OneToOneRelationship || relation instanceof OneToManyRelationship»
            «slugHandlerOption('relationClass', relation.target.name.formatForCodeCapital + 'Entity')»
            «slugHandlerOption('mappedBy', relation.getRelationAliasName(true).formatForCodeCapital)»
        «ELSEIF relation instanceof ManyToOneRelationship»
            «slugHandlerOption('relationClass', relation.source.name.formatForCodeCapital + 'Entity')»
            «slugHandlerOption('mappedBy', relation.getRelationAliasName(false).formatForCodeCapital)»
        «ENDIF»
        «slugHandlerOption('inverseSlugField', 'slug')»
        *     })
    '''

    def private slugHandlerOption(String name, String value) '''
        *         @Gedmo\SlugHandlerOption(name="«name»", value="«value»")'''

    /**
     * Generates additional accessor methods.
     */
    override accessors(Entity it) '''
        «(new FileHelper(application)).getterAndSetterMethods(it, 'slug', 'string', true, '', '')»
    '''
}
