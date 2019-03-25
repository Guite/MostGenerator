package org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.techdocs

import de.guite.modulestudio.metamodel.Application
import de.guite.modulestudio.metamodel.DataObject
import de.guite.modulestudio.metamodel.Entity
import de.guite.modulestudio.metamodel.EntityTreeType
import java.util.ArrayList
import java.util.HashMap
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions
import org.zikula.modulestudio.generator.extensions.ModelInheritanceExtensions

class TechComplexity {

    extension FormattingExtensions = new FormattingExtensions
    extension ModelBehaviourExtensions = new ModelBehaviourExtensions
    extension ModelInheritanceExtensions = new ModelInheritanceExtensions

    TechHelper helper = new TechHelper
    String language
    ArrayList<String> complexityLabels
    HashMap<String, ArrayList<Integer>> metricsInternalData
    HashMap<String, ArrayList<Integer>> metricsExternalData
    HashMap<String, ArrayList<Integer>> metricsInputs
    HashMap<String, ArrayList<Integer>> metricsOutputs
    HashMap<String, ArrayList<Integer>> metricsQueries

    def generate(Application it, String language) {
        this.language = language
        if (language == 'de') {
            complexityLabels = newArrayList('Niedrig', 'Mittel', 'Hoch')
        } else {
            complexityLabels = newArrayList('Low', 'Medium', 'High')
        }
        initMetrics
        helper.docPage(it, language, title, content)
    }

    def private initMetrics(Application it) {
        metricsInternalData = newHashMap(
            'weight' -> newArrayList(7, 10, 15),
            'complexity' -> newArrayList(0, 0, 0),
            'points' -> newArrayList(0, 0, 0)
        )
        metricsExternalData = newHashMap(
            'weight' -> newArrayList(5, 7, 10),
            'complexity' -> newArrayList(0, 0, 0),
            'points' -> newArrayList(0, 0, 0)
        )
        metricsInputs = newHashMap(
            'weight' -> newArrayList(3, 4, 6),
            'complexity' -> newArrayList(0, 0, 0),
            'points' -> newArrayList(0, 0, 0)
        )
        metricsOutputs = newHashMap(
            'weight' -> newArrayList(4, 5, 7),
            'complexity' -> newArrayList(0, 0, 0),
            'points' -> newArrayList(0, 0, 0)
        )
        metricsQueries = newHashMap(
            'weight' -> newArrayList(3, 4, 6),
            'complexity' -> newArrayList(0, 0, 0),
            'points' -> newArrayList(0, 0, 0)
        )
    }

    def private title(Application it) {
        if (language == 'de') {
            return 'Komplexität der Anwendung'
        }
        'Application complexity'
    }

    def content(Application it) '''
        «helper.basicInfo(it, language)»
        <h2><i class="fa fa-calculator"></i> «IF language == 'de'»Funktionspunktanalyse«ELSE»Function points analysis«ENDIF»</h2>
        <p>
            «IF language == 'de'»
                Der Funktionspunkt ist eine Metrik, um den Umfang eines Softwaresystems anzugeben. Weitere Infos können <a href="https://de.wikipedia.org/wiki/Function-Point-Verfahren" target="_blank">auf Wikipedia</a> eingesehen werden.
            «ELSE»
                A function point is a unit to specify the complexity of a software system. More information is available <a href="https://en.wikipedia.org/wiki/Function_point" target="_blank">at Wikipedia</a>.
            «ENDIF»
        </p>
        «helper.table(fpColumns, fpHeader, fpContent)»
        <h3>«IF language == 'de'»Weitere Aktionen«ELSE»Further actions«ENDIF»</h3>
        <p>
            «IF language == 'de'»
                <a href="http://csse.usc.edu/tools/COCOMOII.php" target="_blank" class="btn btn-primary"><i class="fa fa-money"></i> Aufwand, Dauer und Kosten mit COCOMO II berechnen</a>
            «ELSE»
                <a href="http://csse.usc.edu/tools/COCOMOII.php" target="_blank" class="btn btn-primary"><i class="fa fa-money"></i> Calculate effort, schedule and costs with COCOMO II</a>
            «ENDIF»
        </p>
    '''

    def private fpColumns(Application it) '''
        <colgroup>
            <col id="cDesignation" />
            <col id="cComplexity" />
            <col id="cAmount" />
            <col id="cWeight" />
            <col id="cPoints" />
        </colgroup>
    '''

    def private fpHeader(Application it) '''
        <tr>
            <th id="hDesignation" scope="col">«IF language == 'de'»Bezeichnung«ELSE»Designation«ENDIF»</th>
            <th id="hComplexity" scope="col">«IF language == 'de'»Komplexität«ELSE»Complexity«ENDIF»</th>
            <th id="hAmount" scope="col" class="text-right">«IF language == 'de'»Anzahl«ELSE»Amount«ENDIF»</th>
            <th id="hWeight" scope="col" class="text-right">«IF language == 'de'»Gewicht«ELSE»Weight«ENDIF»</th>
            <th id="hPoints" scope="col" class="text-right">«IF language == 'de'»Punkte«ELSE»Points«ENDIF»</th>
        </tr>
    '''

    def private fpContent(Application it) '''
        «internalData»
        «externalData»
        «inputs»
        «outputs»
        «queries»
        «sum»
    '''

    def private internalData(Application it) '''
        <tr>
            <th id="hInternalData" scope="row" headers="hDesignation">
                «IF language == 'de'»Interne Daten«ELSE»Internal data«ENDIF»
                «helper.table(internalDataColumns, internalDataHeader, internalDataContent)»
            </th>
            <td headers="hInternalData hComplexity">
                <br />
                «FOR complexityLabel : complexityLabels»
                    «complexityLabel»<br />
                «ENDFOR»
            </td>
            <td headers="hInternalData hAmount" class="text-right">
                <br />
                «FOR metric : metricsInternalData.get('complexity')»
                    «metric»<br />
                «ENDFOR»
            </td>
            <td headers="hInternalData hWeight" class="text-right">
                <br />
                «FOR metric : metricsInternalData.get('weight')»
                    «metric»<br />
                «ENDFOR»
            </td>
            <td headers="hInternalData hPoints" class="text-right">
                <br />
                «
                    for (i : 0 .. 2) {
                        val points = metricsInternalData.get('complexity').get(i) * metricsInternalData.get('weight').get(i)
                        metricsInternalData.get('points').set(i, points)
                    }
                »
                «FOR metric : metricsInternalData.get('points')»
                    «metric»<br />
                «ENDFOR»
            </td>
        </tr>
    '''

    def private internalDataColumns(Application it) '''
        <colgroup>
            <col id="cInternalTable" />
            <col id="cInternalColumnAmount" />
            <col id="cInternalRelationAmount" />
            <col id="cInternalComplexity" />
        </colgroup>
    '''

    def private internalDataHeader(Application it) '''
        <tr>
            <th id="hInternalTable" scope="col">«IF language == 'de'»Tabellenname«ELSE»Table name«ENDIF»</th>
            <th id="hInternalColumnAmount" scope="col">«IF language == 'de'»Spalten«ELSE»Columns«ENDIF»</th>
            <th id="hInternalRelationAmount" scope="col">«IF language == 'de'»Relationen«ELSE»Relations«ENDIF»</th>
            <th id="hInternalComplexity" scope="col">«IF language == 'de'»Komplexität«ELSE»Complexity«ENDIF»</th>
        </tr>
    '''

    def private internalDataContent(Application it) {
        var output = ''
        for (entity : entities.sortBy[name]) {
            val complexityIndex = calculateComplexityInternalData(entity.countColumns, entity.countRelations)
            metricsInternalData.get('complexity').set(complexityIndex, metricsInternalData.get('complexity').get(complexityIndex) + 1)
            output += '''
                <tr>
                    <th id="hInternal«entity.name.formatForCodeCapital»" scope="row" headers="hInternalTable">«entity.name.formatForDisplayCapital»</th>
                    <td headers="hInternal«entity.name.formatForCodeCapital» hInternalColumnAmount" class="text-right">«entity.countColumns»</td>
                    <td headers="hInternal«entity.name.formatForCodeCapital» hInternalRelationAmount" class="text-right">«entity.countRelations»</td>
                    <td headers="hInternal«entity.name.formatForCodeCapital» hInternalComplexity">«complexityLabels.get(complexityIndex)»</td>
                </tr>
            '''
        }
        output
    }

    def private externalData(Application it) '''
        <tr>
            <th id="hExternalData" scope="row" headers="hDesignation">
                «IF language == 'de'»Schnittstellendaten (z. B. externe Tabellen)«ELSE»Interface data (e. g. external tables)«ENDIF»
            </th>
            <td headers="hExternalData hComplexity">
                <br />
                «FOR complexityLabel : complexityLabels»
                    «complexityLabel»<br />
                «ENDFOR»
            </td>
            <td headers="hExternalData hAmount" class="text-right">
                <br />
                «/*FOR metric : metricsExternalData.get('complexity')»
                    «metric»<br />
                «ENDFOR*/»
            </td>
            <td headers="hExternalData hWeight" class="text-right">
                <br />
                «FOR metric : metricsExternalData.get('weight')»
                    «metric»<br />
                «ENDFOR»
            </td>
            <td headers="hExternalData hPoints" class="text-right">
                <br />
                «
                    for (i : 0 .. 2) {
                        val points = metricsExternalData.get('complexity').get(i) * metricsExternalData.get('weight').get(i)
                        metricsExternalData.get('points').set(i, points)
                    }
                »
                «/*FOR metric : metricsExternalData.get('points')»
                    «metric»<br />
                «ENDFOR*/»
            </td>
        </tr>
    '''

    def private inputs(Application it) '''
        <tr>
            <th id="hInputs" scope="row" headers="hDesignation">
                «IF language == 'de'»Eingaben«ELSE»Inputs«ENDIF»
                «helper.table(inputsColumns, inputsHeader, inputsContent)»
            </th>
            <td headers="hInputs hComplexity">
                <br />
                «FOR complexityLabel : complexityLabels»
                    «complexityLabel»<br />
                «ENDFOR»
            </td>
            <td headers="hInputs hAmount" class="text-right">
                <br />
                «FOR metric : metricsInputs.get('complexity')»
                    «metric»<br />
                «ENDFOR»
            </td>
            <td headers="hInputs hWeight" class="text-right">
                <br />
                «FOR metric : metricsInputs.get('weight')»
                    «metric»<br />
                «ENDFOR»
            </td>
            <td headers="hInputs hPoints" class="text-right">
                <br />
                «
                    for (i : 0 .. 2) {
                        val points = metricsInputs.get('complexity').get(i) * metricsInputs.get('weight').get(i)
                        metricsInputs.get('points').set(i, points)
                    }
                »
                «FOR metric : metricsInputs.get('points')»
                    «metric»<br />
                «ENDFOR»
            </td>
        </tr>
    '''

    def private inputsColumns(Application it) '''
        <colgroup>
            <col id="cInputTable" />
            <col id="cInputFieldAmount" />
            <col id="cInputRelationAmount" />
            <col id="cInputComplexity" />
        </colgroup>
    '''

    def private inputsHeader(Application it) '''
        <tr>
            <th id="hInputTable" scope="col">«IF language == 'de'»Tabellenname«ELSE»Table name«ENDIF»</th>
            <th id="hInputFieldAmount" scope="col">«IF language == 'de'»Felder«ELSE»Fields«ENDIF»</th>
            <th id="hInputRelationAmount" scope="col">«IF language == 'de'»Relationen«ELSE»Relations«ENDIF»</th>
            <th id="hInputComplexity" scope="col">«IF language == 'de'»Komplexität«ELSE»Complexity«ENDIF»</th>
        </tr>
    '''

    def private inputsContent(Application it) {
        var output = ''
        for (entity : entities.sortBy[name]) {
            val complexityIndex = calculateComplexityInput(entity.countColumns, entity.incoming.length)
            metricsInputs.get('complexity').set(complexityIndex, metricsInputs.get('complexity').get(complexityIndex) + 1)
            output += '''
                <tr>
                    <th id="hInput«entity.name.formatForCodeCapital»" scope="row" headers="hInputTable">«entity.name.formatForDisplayCapital»</th>
                    <td headers="hInput«entity.name.formatForCodeCapital» hInputFieldAmount" class="text-right">«entity.countColumns»</td>
                    <td headers="hInput«entity.name.formatForCodeCapital» hInputRelationAmount" class="text-right">«entity.incoming.length»</td>
                    <td headers="hInput«entity.name.formatForCodeCapital» hInputComplexity">«complexityLabels.get(complexityIndex)»</td>
                </tr>
            '''
        }
        output
    }

    def private outputs(Application it) '''
        <tr>
            <th id="hOutputs" scope="row" headers="hDesignation">
                «IF language == 'de'»Ausgaben«ELSE»Outputs«ENDIF»
                «helper.table(outputsColumns, outputsHeader, outputsContent)»
            </th>
            <td headers="hOutputs hComplexity">
                <br />
                «FOR complexityLabel : complexityLabels»
                    «complexityLabel»<br />
                «ENDFOR»
            </td>
            <td headers="hOutputs hAmount" class="text-right">
                <br />
                «FOR metric : metricsOutputs.get('complexity')»
                    «metric»<br />
                «ENDFOR»
            </td>
            <td headers="hOutputs hWeight" class="text-right">
                <br />
                «FOR metric : metricsOutputs.get('weight')»
                    «metric»<br />
                «ENDFOR»
            </td>
            <td headers="hOutputs hPoints" class="text-right">
                <br />
                «
                    for (i : 0 .. 2) {
                        val points = metricsOutputs.get('complexity').get(i) * metricsOutputs.get('weight').get(i)
                        metricsOutputs.get('points').set(i, points)
                    }
                »
                «FOR metric : metricsOutputs.get('points')»
                    «metric»<br />
                «ENDFOR»
            </td>
        </tr>
    '''

    def private outputsColumns(Application it) '''
        <colgroup>
            <col id="cOutputTable" />
            <col id="cOutputViewAmount" />
            <col id="cOutputRelationAmount" />
            <col id="cOutputComplexity" />
        </colgroup>
    '''

    def private outputsHeader(Application it) '''
        <tr>
            <th id="hOutputTable" scope="col">«IF language == 'de'»Tabellenname«ELSE»Table name«ENDIF»</th>
            <th id="hOutputViewAmount" scope="col">«IF language == 'de'»Ansichten«ELSE»Views«ENDIF»</th>
            <th id="hOutputRelationAmount" scope="col">«IF language == 'de'»Relationen«ELSE»Relations«ENDIF»</th>
            <th id="hOutputComplexity" scope="col">«IF language == 'de'»Komplexität«ELSE»Complexity«ENDIF»</th>
        </tr>
    '''

    def private outputsContent(Application it) {
        var output = ''
        for (entity : entities.sortBy[name]) {
            val complexityIndex = calculateComplexityOutput(entity.countColumns, entity.countRelations)
            metricsOutputs.get('complexity').set(complexityIndex, metricsOutputs.get('complexity').get(complexityIndex) + 1)
            output += '''
                <tr>
                    <th id="hOutput«entity.name.formatForCodeCapital»" scope="row" headers="hOutputTable">«entity.name.formatForDisplayCapital»</th>
                    <td headers="hOutput«entity.name.formatForCodeCapital» hOutputViewAmount" class="text-right">«entity.countColumns»</td>
                    <td headers="hOutput«entity.name.formatForCodeCapital» hOutputRelationAmount" class="text-right">«entity.countRelations»</td>
                    <td headers="hOutput«entity.name.formatForCodeCapital» hOutputComplexity">«complexityLabels.get(complexityIndex)»</td>
                </tr>
            '''
        }
        output
    }

    def private queries(Application it) '''
        <tr>
            <th id="hQueries" scope="row" headers="hDesignation">
                «IF language == 'de'»Abfragen«ELSE»Queries«ENDIF»
            </th>
            <td headers="hQueries hComplexity">
                <br />
                «FOR complexityLabel : complexityLabels»
                    «complexityLabel»<br />
                «ENDFOR»
            </td>
            <td headers="hQueries hAmount" class="text-right">
                <br />
                «/*FOR metric : metricsQueries.get('complexity')»
                    «metric»<br />
                «ENDFOR*/»
            </td>
            <td headers="hQueries hWeight" class="text-right">
                <br />
                «FOR metric : metricsQueries.get('weight')»
                    «metric»<br />
                «ENDFOR»
            </td>
            <td headers="hQueries hPoints" class="text-right">
                <br />
                «
                    for (i : 0 .. 2) {
                        val points = metricsQueries.get('complexity').get(i) * metricsQueries.get('weight').get(i)
                        metricsQueries.get('points').set(i, points)
                    }
                »
                «/*FOR metric : metricsQueries.get('points')»
                    «metric»<br />
                «ENDFOR*/»
            </td>
        </tr>
    '''

    def private sum(Application it) '''
        <tr>
            <th id="hSum" scope="row" headers="hDesignation">«IF language == 'de'»Summe unjustierter Funktionspunkte«ELSE»Sum of unadjusted function points«ENDIF»</th>
            <td headers="hSum hComplexity"></td>
            <td headers="hSum hAmount" class="text-right"></td>
            <td headers="hSum hWeight" class="text-right"></td>
            <td headers="hSum hPoints" class="text-right"><strong>«sumOfFunctionPoints»</strong></td>
        </tr>
    '''

    def private countColumns(DataObject it) {
        var amount = getSelfAndParentDataObjects.map[fields].flatten.length
        if (it instanceof Entity) {
            if (attributable) {
                amount += 1
            }
            if (categorisable) {
                amount += 1
            }
            if (geographical) {
                amount += 2
            }
            if (standardFields) {
                amount += 4
            }
            if (tree != EntityTreeType.NONE) {
                amount += 6
            }
            if (hasSluggableFields) {
                amount += 1
            }
            if (hasTranslatableFields) {
                amount += 1
            }
        }
        amount
    }

    def private countRelations(DataObject it) {
        (incoming + outgoing).length
    }

    def private calculateComplexityInternalData(Integer columns, Integer relations) {
        if (relations < 2 && columns > 15 || relations < 3 && columns > 4 && columns < 16 || relations >= 3 && columns < 5) {
            return 1
        }
        if (relations < 3 && columns > 15 || relations >= 3 && columns > 4) {
            return 2
        }
        0
    }

    def private calculateComplexityInput(Integer fields, Integer relations) {
        if (relations < 2 && fields > 15 || relations < 3 && fields > 4 && fields < 16 || relations >= 3 && fields < 5) {
            return 1
        }
        if (relations < 3 && fields > 15 || relations >= 3 && fields > 4) {
            return 2
        }
        0
    }

    def private calculateComplexityOutput(Integer fields, Integer relations) {    
        if (relations < 2 && fields > 50 || relations < 6 && fields > 19 && fields < 51 || relations > 5 && fields < 20) {
            return 1
        }
        if (relations < 6 && fields > 50 || relations > 5 && fields > 19) {
            return 2
        }
        0
    }

    def private sumOfFunctionPoints(Application it) {
        var sum = 0
        sum += sumUp(metricsInternalData.get('points'))
        sum += sumUp(metricsExternalData.get('points'))
        sum += sumUp(metricsInputs.get('points'))
        sum += sumUp(metricsOutputs.get('points'))
        sum += sumUp(metricsQueries.get('points'))
        sum
    }

    def private sumUp(ArrayList<Integer> source) {
        var sum = 0
        for (i : 0 .. 2) {
            sum += source.get(i)
        }
        sum
    }
}
