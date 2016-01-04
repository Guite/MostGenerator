package org.zikula.modulestudio.generator.cartridges.zclassic.models

import de.guite.modulestudio.metamodel.Application
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class LegacyPaginatorSwitch {
    extension NamingExtensions = new NamingExtensions
    extension Utils = new Utils

    FileHelper fh = new FileHelper

    def generate(Application it, IFileSystemAccess fsa) {
        println("Generating paginator switch classes")
        var fileName = 'Paginator.php'
        generateClassPair(fsa, getAppSourceLibPath + 'Paginator/' + fileName,
            fh.phpFileContent(it, paginatorBaseImpl), fh.phpFileContent(it, paginatorImpl)
        )
        fileName = 'LegacyPaginator.php'
        generateClassPair(fsa, getAppSourceLibPath + 'Paginator/' + fileName,
            fh.phpFileContent(it, legacyPaginatorBaseImpl), fh.phpFileContent(it, legacyPaginatorImpl)
        )
    }

    def private paginatorBaseImpl(Application it) '''
        use Doctrine\ORM\Query;
        use Doctrine\ORM\Tools\Pagination\Paginator;

        /**
         * Paginator switch base class for making 1.3.x modules work with 1.4.
         * Uses the newer Paginator.
         */
        abstract class «appName»_Paginator_Base_Paginator
        {
            /**
             * @var Query The query instance.
             */
            private $query;

            /**
             * @var boolean Whether the currently queries entity has relationships or not.
             */
            private $hasRelationships;

            /**
             * The constructor.
             *
             * @param Query   $query            The query instance.
             * @param boolean $hasRelationships Whether the currently queries entity has relationships or not.
             */
            public function __construct(Query $query, $hasRelationships)
            {
                $this->query = $query;
                $this->hasRelationships = $hasRelationships;
            }

            /**
             * Retrieves the paginated results.
             *
             * @return array Paginator object and total amount of rows affected by the query.
             */
            public function getResults()
            {
                $paginator = new Paginator($this->query, $this->hasRelationships);
                $count = count($paginator);

                return «IF targets('1.3.x')»array($paginator, $count)«ELSE»[$paginator, $count]«ENDIF»;
            }
        }
    '''

    def private paginatorImpl(Application it) '''
        /**
         * Paginator switch implementation class for making 1.3.x modules work with 1.4.
         */
        class «appName»_Paginator_Paginator extends «appName»_Paginator_Base_Paginator
        {
            // extend the paginator class here if desired
        }
    '''

    def private legacyPaginatorBaseImpl(Application it) '''
        use Doctrine\ORM\Query;
        use DoctrineExtensions\Paginate\Paginate;

        /**
         * Paginator switch base class for 1.3.x modules.
         * Uses the old Paginator.
         */
        abstract class «appName»_Paginator_Base_LegacyPaginator
        {
            /**
             * @var Query The query instance.
             */
            private $query;

            /**
             * @var boolean Whether the currently queries entity has relationships or not.
             */
            private $hasRelationships;

            /**
             * The constructor.
             *
             * @param Query   $query            The query instance.
             * @param boolean $hasRelationships Whether the currently queries entity has relationships or not.
             */
            public function __construct(Query $query, $hasRelationships)
            {
                $this->query = $query;
                $this->hasRelationships = $hasRelationships;
            }

            /**
             * Retrieves the paginated results.
             *
             * @param integer $offset         The query offset.
             * @param integer $resultsPerPage The amount of records per page.
             *
             * @return array Query object and total amount of rows affected by the query.
             */
            public function getResults($offset, $resultsPerPage)
            {
                // count the total number of affected items
                $count = Paginate::getTotalQueryResults($this->query);
                if ($this->hasRelationships) {
                    // prefetch unique relationship ids for given pagination frame
                    $this->query = Paginate::getPaginateQuery($this->query, $offset, $resultsPerPage);
                }

                return «IF targets('1.3.x')»array($this->query, $count)«ELSE»[$this->query, $count]«ENDIF»;
            }
        }
    '''

    def private legacyPaginatorImpl(Application it) '''
        /**
         * Paginator switch implementation class for 1.3.x modules.
         */
        class «appName»_Paginator_LegacyPaginator extends «appName»_Paginator_Base_LegacyPaginator
        {
            // extend the paginator class here if desired
        }
    '''
}