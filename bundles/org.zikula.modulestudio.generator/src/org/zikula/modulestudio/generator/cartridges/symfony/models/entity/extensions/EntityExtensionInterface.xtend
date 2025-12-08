package org.zikula.modulestudio.generator.cartridges.symfony.models.entity.extensions

import de.guite.modulestudio.metamodel.Entity
import de.guite.modulestudio.metamodel.Field
import java.util.List
import org.zikula.modulestudio.generator.application.IMostFileSystemAccess

interface EntityExtensionInterface {

    /**
     * Generates additional attributes on class level.
     */
    def CharSequence classAttributes(Entity it)

    /**
     * Additional field attributes.
     */
    def CharSequence columnAttributes(Field it)

    /**
     * Generates additional entity properties.
     */
    def CharSequence properties(Entity it)

    /**
     * Generates additional accessor methods.
     */
    def CharSequence accessors(Entity it)

    /**
     * Generates separate extension classes.
     */
    def void extensionClasses(Entity it, IMostFileSystemAccess fsa)

    /**
     * Returns the extension class type.
     */
    def String extensionClassType(Entity it)

    /**
     * Returns the extension class import statements.
     */
    def List<String> extensionClassImports(Entity it)

    /**
     * Returns the extension base class.
     */
    def String extensionBaseClass(Entity it)

    /**
     * Returns the extension class description.
     */
    def String extensionClassDescription(Entity it)

    /**
     * Returns the extension base class implementation.
     */
    def String extensionClassBaseImplementation(Entity it)

    /**
     * Returns the extension implementation class ORM attributes.
     */
    def String extensionClassImplAttributes(Entity it)

    /**
     * Returns the extension repository interface base implementation.
     */
    def String extensionRepositoryInterfaceBaseImplementation(Entity it)

    /**
     * Returns the extension repository class base implementation.
     */
    def String extensionRepositoryClassBaseImplementation(Entity it)
}
