package org.zikula.modulestudio.generator.cartridges.zclassic.models.repository

import de.guite.modulestudio.metamodel.Application
import de.guite.modulestudio.metamodel.ManyToManyRelationship
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class LinkTable {

    extension FormattingExtensions = new FormattingExtensions
    extension NamingExtensions = new NamingExtensions
    extension Utils = new Utils

    FileHelper fh = new FileHelper

    /**
     * Creates a reference table class file for every many-to-many relationship instance.
     */
    def generate(ManyToManyRelationship it, Application app, IFileSystemAccess fsa) {
        app.generateClassPair(fsa, 'Entity/Repository/' + refClass.formatForCodeCapital + 'Repository.php',
            fh.phpFileContent(app, modelRefRepositoryBaseImpl(app)), fh.phpFileContent(app, modelRefRepositoryImpl(app))
        )
    }

    def private modelRefRepositoryBaseImpl(ManyToManyRelationship it, Application app) '''
        namespace «app.appNamespace»\Entity\Repository\Base;

        use Doctrine\ORM\EntityRepository;
        use Psr\Log\LoggerInterface;

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
        namespace «app.appNamespace»\Entity\Repository;

        use «app.appNamespace»\Entity\Repository\Base\Abstract«refClass.formatForCodeCapital»Repository;

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
