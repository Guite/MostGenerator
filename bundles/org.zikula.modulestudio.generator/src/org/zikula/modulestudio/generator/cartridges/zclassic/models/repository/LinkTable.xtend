package org.zikula.modulestudio.generator.cartridges.zclassic.models.repository

import de.guite.modulestudio.metamodel.Application
import de.guite.modulestudio.metamodel.ManyToManyRelationship
import org.zikula.modulestudio.generator.application.IMostFileSystemAccess
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class LinkTable {

    extension FormattingExtensions = new FormattingExtensions
    extension Utils = new Utils

    /**
     * Creates a reference table class file for every many-to-many relationship instance.
     */
    def generate(ManyToManyRelationship it, Application app, IMostFileSystemAccess fsa) {
        fsa.generateClassPair('Repository/' + refClass.formatForCodeCapital + 'RepositoryInterface.php',
            modelRefRepositoryInterfaceBaseImpl(app), modelRefRepositoryInterfaceImpl(app)
        )
        fsa.generateClassPair('Repository/' + refClass.formatForCodeCapital + 'Repository.php',
            modelRefRepositoryBaseImpl(app), modelRefRepositoryImpl(app)
        )
    }

    def private modelRefRepositoryInterfaceBaseImpl(ManyToManyRelationship it, Application app) '''
        namespace «app.appNamespace»\Repository\Base;

        use Doctrine\Persistence\ObjectRepository;

        /**
         * Repository interface for the many to many relationship between «source.name.formatForDisplay» and «target.name.formatForDisplay» entities.
         */
        interface Abstract«refClass.formatForCodeCapital»RepositoryInterface extends ObjectRepository
        {
            // nothing
        }
    '''

    def private modelRefRepositoryBaseImpl(ManyToManyRelationship it, Application app) '''
        namespace «app.appNamespace»\Repository\Base;

        use Doctrine\ORM\EntityRepository;

        /**
         * Repository class used to implement own convenience methods for performing certain DQL queries.
         *
         * This is the base repository class for the many to many relationship
         * between «source.name.formatForDisplay» and «target.name.formatForDisplay» entities.
         */
        class Abstract«refClass.formatForCodeCapital»Repository extends EntityRepository implements Abstract«refClass.formatForCodeCapital»RepositoryInterface
        {
            // nothing
        }
    '''

    def private modelRefRepositoryInterfaceImpl(ManyToManyRelationship it, Application app) '''
        namespace «app.appNamespace»\Repository;

        use «app.appNamespace»\Repository\Base\Abstract«refClass.formatForCodeCapital»RepositoryInterface;

        /**
         * Repository interface for the many to many relationship between «source.name.formatForDisplay» and «target.name.formatForDisplay» entities.
         */
        interface «refClass.formatForCodeCapital»RepositoryInterface extends Abstract«refClass.formatForCodeCapital»RepositoryInterface
        {
            // feel free to add your own interface methods
        }
    '''

    def private modelRefRepositoryImpl(ManyToManyRelationship it, Application app) '''
        namespace «app.appNamespace»\Repository;

        use «app.appNamespace»\Repository\Base\Abstract«refClass.formatForCodeCapital»Repository;

        /**
         * Repository class used to implement own convenience methods for performing certain DQL queries.
         *
         * This is the concrete repository class for the many to many relationship
         * between «source.name.formatForDisplay» and «target.name.formatForDisplay» entities.
         */
        class «refClass.formatForCodeCapital»Repository extends Abstract«refClass.formatForCodeCapital»Repository implements «refClass.formatForCodeCapital»RepositoryInterface
        {
            // feel free to add your own methods here, like for example reusable DQL queries
        }
    '''
}
