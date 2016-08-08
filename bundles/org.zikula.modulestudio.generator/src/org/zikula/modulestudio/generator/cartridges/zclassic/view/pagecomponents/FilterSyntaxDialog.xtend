package org.zikula.modulestudio.generator.cartridges.zclassic.view.pagecomponents

import de.guite.modulestudio.metamodel.Application
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions

class FilterSyntaxDialog {
    extension ModelBehaviourExtensions = new ModelBehaviourExtensions
    extension NamingExtensions = new NamingExtensions

    def generate(Application it, IFileSystemAccess fsa) {
        var fileName = 'includeFilterSyntaxDialog.html.twig'
        if (!shouldBeSkipped(getViewPath + fileName)) {
            println('Generating filter syntax dialog')
            if (shouldBeMarked(getViewPath + fileName)) {
                fileName = 'includeFilterSyntaxDialog.generated.html.twig'
            }
            fsa.generateFile(getViewPath + fileName, dialogTemplate)
        }
    }

    def private dialogTemplate(Application it) '''
        {# purpose of this template: show a modal dialog for explaining FilterUtil syntax #}
        <div class="modal fade" id="filterSyntaxModal" tabindex="-1" role="dialog" aria-labelledby="filterSyntaxModalLabel" aria-hidden="true">
            <div class="modal-dialog">
                <div class="modal-content">
                    «dialogHeader»
                    «dialogBody»
                    «dialogFooter»
                </div>
            </div>
        </div>
    '''

    def private dialogHeader(Application it) '''
        <div class="modal-header">
            <button type="button" class="close" data-dismiss="modal"><span aria-hidden="true">&times;</span><span class="sr-only">{{ __('Close') }}</span></button>
            <h4 class="modal-title" id="filterSyntaxModalLabel">{{ __('Filter syntax explained') }}</h4>
        </div>
    '''

    def private dialogBody(Application it) '''
        <div class="modal-body">
            <p>{{ __('It is possible to filter the list of retrieved items by specifying arbitrary filter expressions. This page shows how to create these expressions.') }}</p>
            <h4>{{ __('Example') }}</h4>
            <p>{{ __('The following filters assume that you have a list of persons whereby each person can have many addresses.') }}</p>
            <hr />
            <h4>{{ __('Table aliases') }}</h4>
            <p>{{ __('The main table, that is the entity being the primary subject of the query, is always known directly. That means, you can prepend "tbl.", but you do not need to.') }}
               {{ __('All additional joined tables can be referenced by "tblFoo".') }}
               {{ __('Thereby "Foo" does not mean the name of the joined entity, but the source or target alias of the corresponding relationship.') }}
               {{ __('This has the advantage that it is possible to join a certain table multiple times. For example instead of having many addresses for a person one could also create two relationships for business and home addresses this way.') }}
            </p>
            <p>{{ __('So in our example we can reference Persons with "tbl" and addresses with "tblAddresses".') }}</p>
            <hr />
            <h4>{{ __('General syntax') }}</h4>
            <h5>{{ __('Filter statements') }}</h5>
            <p>{{ __('A filter consists of several statements.') }} {{ __('Each statement is a set of field name, operator and value connected by a colon.') }} {{ __('The operator defines the condition type (equal, lower than, etc.).') }}</p>
            <ul>
                <li><code>firstName:eq:Peter</code> {{ __('The first name is Peter') }}</li>
                <li><code>tblAddresses.houseNumber:lt:100</code> {{ __('The house number of any address is lower than 100') }}</li>
            </ul>
            <h5>{{ __('Combining statements') }}</h5>
            <p>{{ __('Several statements can be connected by a comma , (AND) or an asterisk * (OR).') }}</p>
            <ul>
                <li><code>firstName:eq:Peter,tblAddresses.houseNumber:lt:100</code> {{ __('The first name is Peter and the house number of any address is below 100.') }}</li>
                <li><code>firstName:eq:Peter*firstName:eq:Chris</code> {{ __('The first name equals either Peter or Chris') }}</li>
            </ul>
            <p>{{ __('Furthermore you can use brackets to group statements.') }}</p>
            <ul>
                <li><code>(firstName:eq:Peter,tblAddresses.houseNumber:lt:100)*(firstName:eq:Chris,tblAddresses.houseNumber:lt:150)</code> {{ __('Either the first name is Peter and the house number of any address is below 100 or the first name is Chris and the house number of any address is below 150.') }}</li>
            </ul>
            <h4>{{ __('Operators') }}</h4>
            <ul>
                <li><code>eq</code> {{ __('is equal.') }}</li>
                <li><code>ne</code> {{ __('is not equal.') }}</li>
                <li><code>lt</code> {{ __('is lower than.') }}</li>
                <li><code>le</code> {{ __('is lower or equal than.') }}</li>
                <li><code>gt</code> {{ __('is greater than.') }}</li>
                <li><code>ge</code> {{ __('is greater or equal than.') }}</li>
                <li><code>search</code> {{ __('is any middle coincidence.') }} {{ __('The term "bar" will match "foobarthis", but not "foobar" nor "barfoo".') }}</li>
                <li><code>like</code> {{ __('is like.') }} {{ __('The value is scanned case insensitive.') }} {{ __('Also you can use "\%" as placeholder.') }} {{ __('"\%bar" will match "FOObar", "Blubbar" and so on, but not "BarFoo".') }}</li>
                <li><code>likefirst</code> {'is for coincidences at the beginning.') }} {{ __('The term "foo" will match "fOo", "FOObar", "FooBlub" and so on, but not "AnotherFoo".') }}</li>
                <li><code>likelast</code> {'is for coincidences at the end.') }} {{ __('The term "foo" will match "fOo", "AnotherFoo" and so on, but not "FoObar" or "FooBlub".') }}</li>
                <li><code>null</code> {{ __('is Empty or NULL.') }}</li>
                <li><code>notnull</code> {{ __('is not empty and not NULL.') }}</li>
            </ul>
            <hr />
            <h4>{{ __('Special field types') }}</h4>
            «IF hasCategorisableEntities»
                <h5>{{ __('Categories') }}</h5>
                <p>{{ __('If a "Person" has Categories support then you can also filter by category id or name.') }}</p>
                <ul>
                    <li><code>categories:eq:4</code> {{ __('Person is assigned to category with id "4".') }}</li>
                    <li><code>categories:eq:Sports</code> {{ __('Person is assigned to category with name "Sports".') }}</li>
                    <li><code>categories:ne:4</code> {{ __('Person is not assigned to category with id "4".') }}</li>
                    <li><code>categories:sub:Sports</code> {{ __('Person is assigned to category with name "Sports" or one of it\'s sub categories.') }}</li>
                </ul>
                <p>{{ __('The field name "categories" is the default name for category fields. However, in practice we need to define different field names for possibly several registries.') }}</p>
                <p>{{ __('Therefore we create a virtual fields for each registry property.') }} {{ __('So instead of "categories" use "categoriesFoo" whereby "Foo" is the property name for the desired registry, for example "Main".') }}</p>
            «ENDIF»
            <h5>{{ __('Dates') }}</h5>
            <p>{{ __('When filtering for dates you can use convenient extensions and even time periods.') }}</p>
            <ul>
                <li>{{ __('Prepend one of the keywords "year", "month", "week", "day", "hour", "min" followed by a colon to search for a time period.') }}
                    <ul>
                        <li><code>date:eq:year:15.07.2016</code> {{ __('All items with a date in year 2016.') }}</li>
                        <li><code>date:eq:month:15.07.2016</code> {{ __('All items with a date in July 2016.') }}</li>
                    </ul>
                </li>
                <li>{{ __('You can use relative time information according to the GNU Date Input Formats syntax.') }}
                    <ul>
                        <li><code>date:eq:today</code> {{ __('All items with date of today.') }}</li>
                        <li><code>date:ge:24 hours</code> {{ __('All items with date up from 24 hours ago.') }}</li>
                        <li><code>date:eq:last year</code> {{ __('All items with date in the last year.') }}</li>
                    </ul>
                </li>
            </ul>
            <h6>{{ __('Date operators') }}</h6>
            <ul>
                <li><code>eq</code> {{ __('is equal.') }}</li>
                <li><code>ne</code> {{ __('is not equal.') }}</li>
                <li><code>gt</code> {{ __('is greater than.') }} {{ __('For time periods: End of the given period. "Date:gt:today" matches all items with date of tomorrow or later.') }}</li>
                <li><code>ge</code> {{ __('is greater or equal than.') }} {{ __('For time periods: Begin of the given period. "Date:ge:today" matches all items with date of today or later.') }}</li>
                <li><code>lt</code> {{ __('is lower than.') }} {{ __('For time periods: Begin of the given period. "Date:lt:today" matches all items with date of yesterday or before.') }}</li>
                <li><code>le</code> {{ __('is lower or equal than.') }} {{ __('For time periods: End of the given period. "Date:le:today" matches all items with date of today or before.') }}</li>
            </ul>
        </div>
    '''

    def private dialogFooter(Application it) '''
        <div class="modal-footer">
            <button type="button" class="btn btn-primary" data-dismiss="modal">{{ __('Close') }}</button>
        </div>
    '''
}
