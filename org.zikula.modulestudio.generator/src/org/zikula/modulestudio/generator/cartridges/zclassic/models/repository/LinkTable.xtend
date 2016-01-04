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
        app.generateClassPair(fsa, app.getAppSourceLibPath + 'Entity/Repository/' + refClass.formatForCodeCapital + '.php',
            fh.phpFileContent(app, modelRefRepositoryBaseImpl(app)), fh.phpFileContent(app, modelRefRepositoryImpl(app))
        )
    }

    def private modelRefRepositoryBaseImpl(ManyToManyRelationship it, Application app) '''
        «IF !app.targets('1.3.x')»
            namespace «app.appNamespace»\Entity\Repository\Base;

            use UserUtil;

        «ENDIF»
        /**
         * Repository class used to implement own convenience methods for performing certain DQL queries.
         *
         * This is the base repository class for the many to many relationship
         * between «source.name.formatForDisplay» and «target.name.formatForDisplay» entities.
         */
        «IF app.targets('1.3.x')»
        class «app.appName»_Entity_Repository_Base_«refClass.formatForCodeCapital» extends EntityRepository
        «ELSE»
        class «refClass.formatForCodeCapital» extends \EntityRepository
        «ENDIF»
        {
            public function truncateTable()
            {
                $qb = $this->getEntityManager()->createQueryBuilder();
                «IF app.targets('1.3.x')»
                    $qb->delete('«app.appName»_Entity_«refClass.formatForCodeCapital»', 'tbl');
                «ELSE»
                    $qb->delete('\\«app.vendor.formatForCodeCapital»\\«app.name.formatForCodeCapital»Module\\Entity\\«refClass.formatForCodeCapital»', 'tbl');
                «ENDIF»
                $query = $qb->getQuery();
                $query->execute();
                «IF !app.targets('1.3.x')»

                    $serviceManager = ServiceUtil::getManager();
                    $logger = $serviceManager->get('logger');
                    $logger->debug('{app}: User {user} truncated the {entity} entity table.', ['app' => '«app.appName»', 'user' => UserUtil::getVar('uname'), 'entity' => '«refClass.formatForDisplay»']);
                «ENDIF»
            }
        }
    '''

    def private modelRefRepositoryImpl(ManyToManyRelationship it, Application app) '''
        «IF !app.targets('1.3.x')»
            namespace «app.appNamespace»\Entity\Repository;

            use «app.appNamespace»\Entity\Repository\Base\«refClass.formatForCodeCapital» as Base«refClass.formatForCodeCapital»;

        «ENDIF»
        /**
         * Repository class used to implement own convenience methods for performing certain DQL queries.
         *
         * This is the concrete repository class for the many to many relationship
         * between «source.name.formatForDisplay» and «target.name.formatForDisplay» entities.
         */
        «IF app.targets('1.3.x')»
        class «app.appName»_Entity_Repository_«refClass.formatForCodeCapital» extends «app.appName»_Entity_Repository_Base_«refClass.formatForCodeCapital»
        «ELSE»
        class «refClass.formatForCodeCapital» extends Base«refClass.formatForCodeCapital»
        «ENDIF»
        {
            // feel free to add your own methods here, like for example reusable DQL queries
        }
    '''
}
