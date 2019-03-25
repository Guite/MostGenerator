package org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.techdocs

import de.guite.modulestudio.metamodel.Application
import de.guite.modulestudio.metamodel.HookProviderMode
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
        <html lang="«language»">
        <head>
            <meta charset="utf-8">
            <meta http-equiv="X-UA-Compatible" content="IE=edge">

            <meta name="viewport" content="width=device-width, initial-scale=1">
            <meta name="description" content="«appDescription»">
            <meta name="author" content="«author»">
            <title>«name.formatForDisplayCapital» &ndash; «title»</title>
            <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.4.0/css/bootstrap.min.css">
            <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.4.0/css/bootstrap-theme.min.css">
            <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/font-awesome/4.7.0/css/font-awesome.min.css">
            <!--[if lt IE 9]>
                <script src="https://oss.maxcdn.com/html5shiv/3.7.3/html5shiv.min.js"></script>
                <script src="https://oss.maxcdn.com/respond/1.4.2/respond.min.js"></script>
            <![endif]-->
            <link rel="icon" href="../../public/images/admin.png">
            <style>
                body {
                    padding-bottom: 80px;
                }
                h2 {
                    margin-top: 80px;
                }
                h3 {
                    margin-top: 50px;
                }
                table {
                    width: 100%;
                }
                th, td {
                    vertical-align: top;
                }
            </style>
        </head>
        <body>
              <div class="container">
                  <h1>
                      <img src="../../public/images/admin.png" width="48" height="48" alt="Icon" class="img-thumbnail pull-right" />
                      «name.formatForDisplayCapital» &ndash; «title»
                  </h1>
                  <p>«appDescription»</p>
    '''

    def private footer(Application it) '''
                </div>
                <script src="https://code.jquery.com/jquery-3.3.1.min.js"></script>
                <script src="https://code.jquery.com/jquery-migrate-3.0.1.min.js"></script>
                <script src="https://maxcdn.bootstrapcdn.com/bootstrap/3.4.0/js/bootstrap.min.js"></script>
            </body>
        </html>
    '''

    def table(CharSequence columns, CharSequence header, CharSequence content) '''
        <div class="table-responsive">
            <table class="table-striped table-bordered table-hover table-condensed">
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

    def flag(Boolean value) '''
        «IF value»
            <i class="fa fa-check"></i>
        «ELSE»
            <i class="fa fa-times"></i>
        «ENDIF»
    '''

    def basicInfo(Application it, String language) '''
        «table(basicInfoColumns, basicInfoHeader(language), basicInfoContent(language))»
        <h2><i class="fa fa-sitemap"></i> «IF language == 'de'»Modell der Anwendung«ELSE»Application model«ENDIF»</h2>
        <p><img src="«name.formatForCodeCapital»_Entities%20Diagram.jpg" alt="«name.formatForDisplayCapital» «IF language == 'de'»Modell«ELSE»Model«ENDIF»" class="img-thumbnail img-responsive" /></p>
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
            <td headers="hBasicValue hEmail"><a href="mailto:«email»"><i class="fa fa-envelope"></i> «email»</a></td>
        </tr>
        <tr>
            <th id="hUrl" scope="row" headers="hBasicField">URL</th>
            <td headers="hBasicValue hUrl"><a href="«url»" title="«IF language == 'de'»Projektseite«ELSE»Project page«ENDIF»" target="_blank"><i class="fa fa-external-link-square"></i> «url»</a></td>
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
            <td headers="hBasicValue hPlatform"><a href="https://ziku.la/«language»/" title="«IF language == 'de'»Internetseite von Zikula«ELSE»Zikula website«ENDIF»" target="_blank">Zikula</a> «targetSemVer(true)»</td>
        </tr>
        <tr>
            <th id="hGenerated" scope="row" headers="hBasicField">«IF language == 'de'»Generiert«ELSE»Generated«ENDIF»</th>
            <td headers="hBasicValue hGenerated">«IF language == 'de'»durch«ELSE»by«ENDIF» <a href="«msUrl»«IF language != 'de'»/en/«ENDIF»" title="«IF language == 'de'»Internetseite von ModuleStudio«ELSE»ModuleStudio website«ENDIF»" target="_blank">ModuleStudio</a>«IF versionAllGeneratedFiles» «msVersion»«ENDIF»«IF timestampAllGeneratedFiles» «IF language == 'de'»am«ELSE»at«ENDIF» «timestamp»«ENDIF»</td>
        </tr>
    '''

    def hookProviderDescription(HookProviderMode it, String language) {
        switch it {
            case DISABLED:
                return if (language == 'de') 'kein Hook-Anbieter verfügbar' else 'no hook provider available'
            case ENABLED:
                return if (language == 'de') 'Hook-Anbieter verfügbar' else 'hook provider available'
            case ENABLED_SELF:
                return if (language == 'de') 'Hook-Anbieter verfügbar, der auch an eigene Abonnenten angehängt werden kann' else 'hook provider available which may hook to its own subscribers'
        }
    }
}
