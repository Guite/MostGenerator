package org.zikula.modulestudio.generator.cartridges.symfony.smallstuff.techdocs

import de.guite.modulestudio.metamodel.Application
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class TechHelper {

    extension FormattingExtensions = new FormattingExtensions
    extension Utils = new Utils

    def docPage(Application it, String language, String title, CharSequence content) '''
        «header(language, title)»
        «content»
        «footer»
    '''

    def private header(Application it, String language, String title) '''
        <!DOCTYPE html>
        <html lang="«language»" dir="auto">
        <head>
            <meta charset="utf-8">
            <meta http-equiv="X-UA-Compatible" content="IE=edge">

            <meta name="viewport" content="width=device-width, initial-scale=1">
            <meta name="description" content="«appDescription»">
            <meta name="author" content="«author»">
            <title>«name.formatForDisplayCapital» &ndash; «title»</title>
            <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@4.6.2/dist/css/bootstrap.min.css" integrity="sha384-xOolHFLEh07PJGoPkLv1IbcEPTNtaed2xpHsD9ESMhqIYd0nLMwNLD69Npy4HI+N" crossorigin="anonymous">
            <link rel="stylesheet" href="https://use.fontawesome.com/releases/v6.5.1/css/all.css">
            <link rel="icon" href="../../public/images/admin.png">
            <link rel="stylesheet" href="../../public/css/techdocs.css">
        </head>
        <body>
              <div class="container">
                  <h1>
                      <img src="../../public/images/admin.png" width="48" height="48" alt="Icon" class="img-thumbnail float-right" />
                      «name.formatForDisplayCapital» &ndash; «title»
                  </h1>
                  <p>«appDescription»</p>
    '''

    def private footer(Application it) '''
                </div>
                <script src="https://code.jquery.com/jquery-3.6.0.slim.min.js" integrity="sha256-u7e5khyithlIdTpu22PHhENmPcRdFiHRjhAuHcs05RI=" crossorigin="anonymous"></script>
                <script src="https://cdn.jsdelivr.net/npm/bootstrap@4.6.2/dist/js/bootstrap.bundle.min.js" integrity="sha384-Fy6S3B9q64WdZWQUiU+q4/2Lc9npb8tCaSX9FK7E8HnRr0Jz8D6OP9dO5Vg3Q9ct" crossorigin="anonymous"></script>
            </body>
        </html>
    '''

    def table(Application it, CharSequence columns, CharSequence header, CharSequence content) '''
        <div class="table-responsive">
            <table class="table-striped table-bordered table-hover table-sm">
                «columns»
                «IF header != ''»
                    <thead>
                        «header»
                    </thead>
                «ENDIF»
                <tbody>
                    «content»
                </tbody>
            </table>
        </div>
    '''

    def flag(Application it, Boolean value) '''
        «IF value»
            <i class="fas fa-check"></i>
        «ELSE»
            <i class="fas fa-times"></i>
        «ENDIF»
    '''

    def basicInfo(Application it, String language) '''
        «table(basicInfoColumns, basicInfoHeader(language), basicInfoContent(language))»
        <h2><i class="fas fa-sitemap"></i> «IF language == 'de'»Modell der Anwendung«ELSE»Application model«ENDIF»</h2>
        <p><img src="«name.formatForCodeCapital»_Entities%20Diagram.jpg" alt="«name.formatForDisplayCapital» «IF language == 'de'»Modell«ELSE»Model«ENDIF»" class="img-thumbnail img-fluid" /></p>
    '''

    def private basicInfoColumns(Application it) '''
        <colgroup>
            <col id="cBasicField" />
            <col id="cBasicValue" />
        </colgroup>
    '''

    def private basicInfoHeader(Application it, String language) '''
        <tr class="sr-only">
            <th id="hBasicField" scope="col">«IF language == 'de'»Feld«ELSE»Field«ENDIF»</th>
            <th id="hBasicValue" scope="col">«IF language == 'de'»Wert«ELSE»Value«ENDIF»</th>
        </tr>
    '''

    def private basicInfoContent(Application it, String language) '''
        <tr>
            <th id="hVendor" scope="row" headers="hBasicField">«IF language == 'de'»Anbieter«ELSE»Vendor«ENDIF»</th>
            <td headers="hBasicValue hVendor">«vendor»</td>
        </tr>
        <tr>
            <th id="hAuthor" scope="row" headers="hBasicField">«IF language == 'de'»Autor«ELSE»Author«ENDIF»</th>
            <td headers="hBasicValue hAuthor">«author»</td>
        </tr>
        <tr>
            <th id="hEmail" scope="row" headers="hBasicField">«IF language == 'de'»E-Mail«ELSE»Email«ENDIF»</th>
            <td headers="hBasicValue hEmail"><a href="mailto:«email»"><i class="fas fa-envelope"></i> «email»</a></td>
        </tr>
        <tr>
            <th id="hUrl" scope="row" headers="hBasicField">URL</th>
            <td headers="hBasicValue hUrl"><a href="«url»" title="«IF language == 'de'»Projektseite«ELSE»Project page«ENDIF»" target="_blank"><i class="fas fa-external-link-square-alt"></i> «url»</a></td>
        </tr>
        <tr>
            <th id="hVersion" scope="row" headers="hBasicField">Version</th>
            <td headers="hBasicValue hVersion">«version»</td>
        </tr>
        <tr>
            <th id="hLicense" scope="row" headers="hBasicField">«IF language == 'de'»Lizenz«ELSE»License«ENDIF»</th>
            <td headers="hBasicValue hLicense">«license»</td>
        </tr>
        <tr>
            <th id="hPlatform" scope="row" headers="hBasicField">«IF language == 'de'»Plattform«ELSE»Platform«ENDIF»</th>
            <td headers="hBasicValue hPlatform">
                <a href="https://symfony.com/" title="«IF language == 'de'»Internetseite von Symfony«ELSE»Symfony website«ENDIF»" target="_blank">Symfony</a> «targetSymfonyVersion»
                 &amp; <a href="https://ziku.la/«language»/" title="«IF language == 'de'»Internetseite von Zikula«ELSE»Zikula website«ENDIF»" target="_blank">Zikula</a> «targetZikulaVersion»
            </td>
        </tr>
        <tr>
            <th id="hGenerated" scope="row" headers="hBasicField">«IF language == 'de'»Generiert«ELSE»Generated«ENDIF»</th>
            <td headers="hBasicValue hGenerated">«IF language == 'de'»durch«ELSE»by«ENDIF» <a href="«msUrl»«IF language != 'de'»/en/«ENDIF»" title="«IF language == 'de'»Internetseite von ModuleStudio«ELSE»ModuleStudio website«ENDIF»" target="_blank">ModuleStudio</a>«IF versionAllGeneratedFiles» «msVersion»«ENDIF»«IF timestampAllGeneratedFiles» «IF language == 'de'»am«ELSE»at«ENDIF» «timestamp»«ENDIF»</td>
        </tr>
    '''
}
