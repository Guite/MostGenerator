package org.zikula.modulestudio.generator.cartridges.zclassic.models.repository

import com.google.inject.Inject
import de.guite.modulestudio.metamodel.modulestudio.Application
import de.guite.modulestudio.metamodel.modulestudio.ManyToManyRelationship
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions

class LinkTable {
    @Inject extension FormattingExtensions = new FormattingExtensions()
    @Inject extension NamingExtensions = new NamingExtensions()

    FileHelper fh = new FileHelper()

    /**
     * Creates a reference table class file for every many-to-many relationship instance.
     */
    def generate(ManyToManyRelationship it, Application app, IFileSystemAccess fsa) {
        fsa.generateFile(app.getAppSourcePath + baseClassModelRefRepository.asFile, modelRefRepositoryBaseFile(app))
        fsa.generateFile(app.getAppSourcePath + implClassModelRefRepository.asFile, modelRefRepositoryFile(app))
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
        /**
         * Repository class used to implement own convenience methods for performing certain DQL queries.
         *
         * This is the base repository class for the many to many relationship
         * between «source.name.formatForDisplay» and «target.name.formatForDisplay» entities.
         */
        class «baseClassModelRefRepository» extends EntityRepository
        {
            public function truncateTable()
            {
                $qb = $this->getEntityManager()->createQueryBuilder();
                $qb->delete('«implClassModelRefEntity»', 'tbl');
                $query = $qb->getQuery();
                $query->execute();
            }
        }
    '''

    def private modelRefRepositoryImpl(ManyToManyRelationship it, Application app) '''
        /**
         * Repository class used to implement own convenience methods for performing certain DQL queries.
         *
         * This is the concrete repository class for the many to many relationship
         * between «source.name.formatForDisplay» and «target.name.formatForDisplay» entities.
         */
        class «implClassModelRefRepository» extends «baseClassModelRefRepository»
        {
            // feel free to add your own methods here, like for example reusable DQL queries
        }
    '''
}
