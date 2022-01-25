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
        fsa.generateClassPair('Repository/' + refClass.formatForCodeCapital + 'Repository.php',
            modelRefRepositoryBaseImpl(app), modelRefRepositoryImpl(app)
        )
    }

    def private modelRefRepositoryBaseImpl(ManyToManyRelationship it, Application app) '''
        namespace «app.appNamespace»\Repository\Base;

        use Doctrine\ORM\EntityRepository;

        /**
         * Repository class used to implement own convenience methods for performing certain DQL queries.
         *
         * This is the base repository class for the many to many relationship
         * between «source.name.formatForDisplay» and «target.name.formatForDisplay» entities.
         */
        class Abstract«refClass.formatForCodeCapital»Repository extends EntityRepository
        {
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
        class «refClass.formatForCodeCapital»Repository extends Abstract«refClass.formatForCodeCapital»Repository
        {
            // feel free to add your own methods here, like for example reusable DQL queries
        }
    '''
}
