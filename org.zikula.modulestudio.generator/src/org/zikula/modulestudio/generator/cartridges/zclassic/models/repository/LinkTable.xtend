package org.zikula.modulestudio.generator.cartridges.zclassic.models.repository

import com.google.inject.Inject
import de.guite.modulestudio.metamodel.modulestudio.Application
import de.guite.modulestudio.metamodel.modulestudio.ManyToManyRelationship
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class LinkTable {
    @Inject extension FormattingExtensions = new FormattingExtensions
    @Inject extension NamingExtensions = new NamingExtensions
    @Inject extension Utils = new Utils

    FileHelper fh = new FileHelper

    /**
     * Creates a reference table class file for every many-to-many relationship instance.
     */
    def generate(ManyToManyRelationship it, Application app, IFileSystemAccess fsa) {
        val repositoryPath = app.getAppSourceLibPath + 'Entity/Repository/'
        val repositoryFile = refClass.formatForCodeCapital + '.php'
        fsa.generateFile(repositoryPath + 'Base/' + repositoryFile, modelRefRepositoryBaseFile(app))
        fsa.generateFile(repositoryPath + repositoryFile, modelRefRepositoryFile(app))
    }

    def private modelRefRepositoryBaseFile(ManyToManyRelationship it, Application app) '''
        «fh.phpFileHeader(app)»
        «modelRefRepositoryBaseImpl(app)»
    '''

    def private modelRefRepositoryFile(ManyToManyRelationship it, Application app) '''
        «fh.phpFileHeader(app)»
        «modelRefRepositoryImpl(app)»
    '''

    def private modelRefRepositoryBaseImpl(ManyToManyRelationship it, Application app) '''
        «IF !app.targets('1.3.5')»
            namespace «app.appNamespace»\Entity\Repository\Base;

        «ENDIF»
        /**
         * Repository class used to implement own convenience methods for performing certain DQL queries.
         *
         * This is the base repository class for the many to many relationship
         * between «source.name.formatForDisplay» and «target.name.formatForDisplay» entities.
         */
        «IF app.targets('1.3.5')»
        class «app.appName»_Entity_Repository_Base_«refClass.formatForCodeCapital» extends EntityRepository
        «ELSE»
        class «refClass.formatForCodeCapital» extends \EntityRepository
        «ENDIF»
        {
            public function truncateTable()
            {
                $qb = $this->getEntityManager()->createQueryBuilder();
                «IF app.targets('1.3.5')»
                $qb->delete('«app.appName»_Entity_«refClass.formatForCodeCapital»', 'tbl');
                «ELSE»
                $qb->delete('\\«app.vendor.formatForCodeCapital»\\«app.name.formatForCodeCapital»Module\\Entity\\«refClass.formatForCodeCapital»', 'tbl');
                «ENDIF»
                $query = $qb->getQuery();
                $query->execute();
            }
        }
    '''

    def private modelRefRepositoryImpl(ManyToManyRelationship it, Application app) '''
        «IF !app.targets('1.3.5')»
            namespace «app.appNamespace»\Entity\Repository;

            use «app.appNamespace»\Entity\Repository\Base\«refClass.formatForCodeCapital» as Base«refClass.formatForCodeCapital»;

        «ENDIF»
        /**
         * Repository class used to implement own convenience methods for performing certain DQL queries.
         *
         * This is the concrete repository class for the many to many relationship
         * between «source.name.formatForDisplay» and «target.name.formatForDisplay» entities.
         */
        «IF app.targets('1.3.5')»
        class «app.appName»_Entity_Repository_«refClass.formatForCodeCapital» extends «app.appName»_Entity_Repository_Base_«refClass.formatForCodeCapital»
        «ELSE»
        class «refClass.formatForCodeCapital» extends Base«refClass.formatForCodeCapital»
        «ENDIF»
        {
            // feel free to add your own methods here, like for example reusable DQL queries
        }
    '''
}
