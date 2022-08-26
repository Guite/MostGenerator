package org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff

import de.guite.modulestudio.metamodel.Application
import de.guite.modulestudio.metamodel.ApplicationDependencyType
import de.guite.modulestudio.metamodel.EmailValidationMode
import de.guite.modulestudio.metamodel.Entity
import de.guite.modulestudio.metamodel.JoinRelationship
import de.guite.modulestudio.metamodel.ReferredApplication
import org.zikula.modulestudio.generator.application.IMostFileSystemAccess
import org.zikula.modulestudio.generator.extensions.ControllerExtensions
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.ModelJoinExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class ComposerFile {

    extension ControllerExtensions = new ControllerExtensions
    extension FormattingExtensions = new FormattingExtensions
    extension ModelExtensions = new ModelExtensions
    extension ModelBehaviourExtensions = new ModelBehaviourExtensions
    extension ModelJoinExtensions = new ModelJoinExtensions
    extension Utils = new Utils

    def generate(Application it, IMostFileSystemAccess fsa) {
        fsa.generateFile('composer.json', composerFile)
    }

    def private composerFile(Application it) '''
        {
            «composerContent»
        }
    '''

    def private composerContent(Application it) '''
        "name": "«vendor.formatForDB»/«name.formatForDB»-bundle",
        "version": "«version»",
        "description": "«appDescription»",
        "type": "symfony-bundle",
        "license": "«licenseSPDX»",
        "authors": [
            {
                "name": "«author»",
                "email": "«email»",
                "homepage": "«url»",
                "role": "owner"
            }
        ],
        "autoload": {
            "psr-4": { "«vendor.formatForCodeCapital»\\«name.formatForCodeCapital»Bundle\\": "" }
        },
        "require": {
            «var dependencies = referredApplications.filter[dependencyType == ApplicationDependencyType.REQUIREMENT]»
            "php": "^8.1",
            "doctrine/doctrine-migrations-bundle": "^3.2",
            «IF generatePdfSupport»
                "dompdf/dompdf": "^2",
            «ENDIF»
            «IF hasGeographical»
                "drmonty/leaflet": "^1",
            «ENDIF»
            «IF hasEmailFieldsWithValidationMode(EmailValidationMode.STRICT)»
                "egulias/email-validator": "^2",
            «ENDIF»
            "symfony/maker-bundle": "^1",
            "zikula/core-bundle": "^«targetSemVer(false)»"«IF !dependencies.empty»,«ENDIF»
            «IF !dependencies.empty»
                «FOR referredApp : dependencies»
                    «dependency(referredApp)»«IF referredApp != dependencies.last»,«ENDIF»
                «ENDFOR»
            «ENDIF»
        },
        "require-dev": {
        },
        «{ dependencies = referredApplications.filter[dependencyType == ApplicationDependencyType.RECOMMENDATION]; '' }»
        «IF !dependencies.empty»
            "suggest": {
                «FOR referredApp : dependencies»
                    «dependency(referredApp)»«IF referredApp != dependencies.last»,«ENDIF»
                «ENDFOR»
            },
        «ENDIF»
        "extra": {
            "zikula": {
                "class": "«vendor.formatForCodeCapital»\\«name.formatForCodeCapital»Bundle\\«appName»",
                "displayname": "«name.formatForDisplayCapital»",
                "url": "«name.formatForDB»",
                "icon": "fas fa-database",
                "capabilities": {
                    «generateCapabilities»
                },
                "securityschema": {
                    "«appName»::": "::",
                    «FOR entity : getAllEntities»«entity.permissionSchema(appName)»«ENDFOR»
                    "«appName»::Ajax": "::"
                }
            }
        },
        "config": {
            "vendor-dir": "vendor",
            "preferred-install": "dist",
            "optimize-autoloader": true,
            "sort-packages": true
        }
    '''

    def private dependency(Application it, ReferredApplication dependency) '''
        "«dependency.name»:>=«dependency.minVersion»«/*,<=«dependency.maxVersion»*/»": "«IF null !== dependency.documentation && !dependency.documentation.empty»«dependency.documentation.formatForDisplay»«ELSE»«dependency.name» application«ENDIF»"
    '''

    def private generateCapabilities(Application it) '''
        "admin": {
            "route": "«appName.formatForDB»_«getLeadingEntity.name.formatForDB»_admin«getLeadingEntity.getPrimaryAction»"
        },
        "user": {
            "route": "«appName.formatForDB»_«getLeadingEntity.name.formatForDB»_«getLeadingEntity.getPrimaryAction»"
        }«IF hasCategorisableEntities»,«ENDIF»
        «IF hasCategorisableEntities»
            "categorizable": {
                "entities": [
                    «FOR entity : getCategorisableEntities»
                        "«vendor.formatForCodeCapital»\\«name.formatForCodeCapital»Bundle\\Entity\\«entity.name.formatForCodeCapital»Entity"«IF entity != getCategorisableEntities.last»,«ENDIF»
                    «ENDFOR»
                ]
            }
        «ENDIF»
    '''

    def private permissionSchema(Entity it, String appName) '''
        "«appName»:«name.formatForCodeCapital»:": "«name.formatForCodeCapital» ID::",
        «val incomingRelations = getIncomingJoinRelations/*.filter[r|r.source.container == it.container]*/»
        «IF !incomingRelations.empty»
            «FOR relation : incomingRelations»«relation.permissionSchema(appName)»«ENDFOR»
        «ENDIF»
    '''

    def private permissionSchema(JoinRelationship it, String appName) '''
        "«appName»:«source.name.formatForCodeCapital»:«target.name.formatForCodeCapital»": "«source.name.formatForCodeCapital» ID:«target.name.formatForCodeCapital» ID:",
    '''

    // Reference: http://www.spdx.org/licenses/
    def private licenseSPDX(Application it) {
        switch license {
            case 'Academic Free License v1.1': 'AFL-1.1'
            case 'AFL-1.1': 'AFL-1.1'
            case 'Academic Free License v1.2': 'AFL-1.2'
            case 'AFL-1.2': 'AFL-1.2'
            case 'Academic Free License v2.0': 'AFL-2.0'
            case 'AFL-2.0': 'AFL-2.0'
            case 'Academic Free License v2.1': 'AFL-2.1'
            case 'AFL-2.1': 'AFL-2.1'
            case 'Academic Free License v3.0': 'AFL-3.0'
            case 'AFL-3.0': 'AFL-3.0'
            case 'Adaptive Public License 1.0': 'APL-1.0'
            case 'APL-1.0': 'APL-1.0'
            case 'ANTLR Software Rights Notice': 'ANTLR-PD'
            case 'ANTLR-PD': 'ANTLR-PD'
            case 'Apache License 1.0': 'Apache-1.0'
            case 'Apache-1.0': 'Apache-1.0'
            case 'Apache License 1.1': 'Apache-1.1'
            case 'Apache-1.1': 'Apache-1.1'
            case 'Apache License 2.0': 'Apache-2.0'
            case 'Apache-2.0': 'Apache-2.0'
            case 'Apple Public Source License 1.0': 'APSL-1.0'
            case 'APSL-1.0': 'APSL-1.0'
            case 'Apple Public Source License 1.1': 'APSL-1.1'
            case 'APSL-1.1': 'APSL-1.1'
            case 'Apple Public Source License 1.2': 'APSL-1.2'
            case 'APSL-1.2': 'APSL-1.2'
            case 'Apple Public Source License 2.0': 'APSL-2.0'
            case 'APSL-2.0': 'APSL-2.0'
            case 'Artistic License 1.0': 'Artistic-1.0'
            case 'Artistic-1.0': 'Artistic-1.0'
            case 'Artistic License 2.0': 'Artistic-2.0'
            case 'Artistic-2.0': 'Artistic-2.0'
            case 'Attribution Assurance License': 'AAL'
            case 'AAL': 'AAL'
            case 'Boost Software License 1.0': 'BSL-1.0'
            case 'BSL-1.0': 'BSL-1.0'
            case 'BSD 2-clause "Simplified" License': 'BSD-2-Clause'
            case 'BSD-2-Clause': 'BSD-2-Clause'
            case 'BSD 2-clause "NetBSD" License': 'BSD-2-Clause-NetBSD'
            case 'BSD-2-Clause-NetBSD': 'BSD-2-Clause-NetBSD'
            case 'BSD 2-clause "FreeBSD" License': 'BSD-2-Clause-FreeBSD'
            case 'BSD-2-Clause-FreeBSD': 'BSD-2-Clause-FreeBSD'
            case 'BSD 3-clause "New" or "Revised" License': 'BSD-3-Clause'
            case 'BSD-3-Clause': 'BSD-3-Clause'
            case 'BSD 4-clause "Original" or "Old" License': 'BSD-4-Clause'
            case 'BSD-4-Clause': 'BSD-4-Clause'
            case 'BSD-4-Clause (University of California-Specific)': 'BSD-4-Clause-UC'
            case 'BSD-4-Clause-UC': 'BSD-4-Clause-UC'
            case 'CeCILL Free Software License Agreement v1.0': 'CECILL-1.0'
            case 'CECILL-1.0': 'CECILL-1.0'
            case 'CeCILL Free Software License Agreement v1.1': 'CECILL-1.1'
            case 'CECILL-1.1': 'CECILL-1.1'
            case 'CeCILL Free Software License Agreement v2.0': 'CECILL-2.0'
            case 'CECILL-2.0': 'CECILL-2.0'
            case 'CeCILL-B Free Software License Agreement': 'CECILL-B'
            case 'CECILL-B': 'CECILL-B'
            case 'CeCILL-C Free Software License Agreement': 'CECILL-C'
            case 'CECILL-C': 'CECILL-C'
            case 'Clarified Artistic License': 'ClArtistic'
            case 'ClArtistic': 'ClArtistic'
            case 'CNRI Python Open Source GPL Compatible License Agreement': 'CNRI-Python-GPL-Compatible'
            case 'CNRI-Python-GPL-Compatible': 'CNRI-Python-GPL-Compatible'
            case 'CNRI Python License': 'CNRI-Python'
            case 'CNRI-Python': 'CNRI-Python'
            case 'Common Development and Distribution License 1.0': 'CDDL-1.0'
            case 'CDDL-1.0': 'CDDL-1.0'
            case 'Common Development and Distribution License 1.1': 'CDDL-1.1'
            case 'CDDL-1.1': 'CDDL-1.1'
            case 'Common Public Attribution License 1.0': 'CPAL-1.0'
            case 'CPAL-1.0': 'CPAL-1.0'
            case 'Common Public License 1.0': 'CPL-1.0'
            case 'CPL-1.0': 'CPL-1.0'
            case 'Computer Associates Trusted Open Source License 1.1': 'CATOSL-1.1'
            case 'CATOSL-1.1': 'CATOSL-1.1'
            case 'Creative Commons Attribution 1.0': 'CC-BY-1.0'
            case 'CC-BY-1.0': 'CC-BY-1.0'
            case 'Creative Commons Attribution 2.0': 'CC-BY-2.0'
            case 'CC-BY-2.0': 'CC-BY-2.0'
            case 'Creative Commons Attribution 2.5': 'CC-BY-2.5'
            case 'CC-BY-2.5': 'CC-BY-2.5'
            case 'Creative Commons Attribution 3.0': 'CC-BY-3.0'
            case 'CC-BY-3.0': 'CC-BY-3.0'
            case 'Creative Commons Attribution No Derivatives 1.0': 'CC-BY-ND-1.0'
            case 'CC-BY-ND-1.0': 'CC-BY-ND-1.0'
            case 'Creative Commons Attribution No Derivatives 2.0': 'CC-BY-ND-2.0'
            case 'CC-BY-ND-2.0': 'CC-BY-ND-2.0'
            case 'Creative Commons Attribution No Derivatives 2.5': 'CC-BY-ND-2.5'
            case 'CC-BY-ND-2.5': 'CC-BY-ND-2.5'
            case 'Creative Commons Attribution No Derivatives 3.0': 'CC-BY-ND-3.0'
            case 'CC-BY-ND-3.0': 'CC-BY-ND-3.0'
            case 'Creative Commons Attribution Non Commercial 1.0': 'CC-BY-NC-1.0'
            case 'CC-BY-NC-1.0': 'CC-BY-NC-1.0'
            case 'Creative Commons Attribution Non Commercial 2.0': 'CC-BY-NC-2.0'
            case 'CC-BY-NC-2.0': 'CC-BY-NC-2.0'
            case 'Creative Commons Attribution Non Commercial 2.5': 'CC-BY-NC-2.5'
            case 'CC-BY-NC-2.5': 'CC-BY-NC-2.5'
            case 'Creative Commons Attribution Non Commercial 3.0': 'CC-BY-NC-3.0'
            case 'CC-BY-NC-3.0': 'CC-BY-NC-3.0'
            case 'Creative Commons Attribution Non Commercial No Derivatives 1.0': 'CC-BY-NC-ND-1.0'
            case 'CC-BY-NC-ND-1.0': 'CC-BY-NC-ND-1.0'
            case 'Creative Commons Attribution Non Commercial No Derivatives 2.0': 'CC-BY-NC-ND-2.0'
            case 'CC-BY-NC-ND-2.0': 'CC-BY-NC-ND-2.0'
            case 'Creative Commons Attribution Non Commercial No Derivatives 2.5': 'CC-BY-NC-ND-2.5'
            case 'CC-BY-NC-ND-2.5': 'CC-BY-NC-ND-2.5'
            case 'Creative Commons Attribution Non Commercial No Derivatives 3.0': 'CC-BY-NC-ND-3.0'
            case 'CC-BY-NC-ND-3.0': 'CC-BY-NC-ND-3.0'
            case 'Creative Commons Attribution Non Commercial Share Alike 1.0': 'CC-BY-NC-SA-1.0'
            case 'CC-BY-NC-SA-1.0': 'CC-BY-NC-SA-1.0'
            case 'Creative Commons Attribution Non Commercial Share Alike 2.0': 'CC-BY-NC-SA-2.0'
            case 'CC-BY-NC-SA-2.0': 'CC-BY-NC-SA-2.0'
            case 'Creative Commons Attribution Non Commercial Share Alike 2.5': 'CC-BY-NC-SA-2.5'
            case 'CC-BY-NC-SA-2.5': 'CC-BY-NC-SA-2.5'
            case 'Creative Commons Attribution Non Commercial Share Alike 3.0': 'CC-BY-NC-SA-3.0'
            case 'CC-BY-NC-SA-3.0': 'CC-BY-NC-SA-3.0'
            case 'Creative Commons Attribution Share Alike 1.0': 'CC-BY-SA-1.0'
            case 'CC-BY-SA-1.0': 'CC-BY-SA-1.0'
            case 'Creative Commons Attribution Share Alike 2.0': 'CC-BY-SA-2.0'
            case 'CC-BY-SA-2.0': 'CC-BY-SA-2.0'
            case 'Creative Commons Attribution Share Alike 2.5': 'CC-BY-SA-2.5'
            case 'CC-BY-SA-2.5': 'CC-BY-SA-2.5'
            case 'Creative Commons Attribution Share Alike 3.0': 'CC-BY-SA-3.0'
            case 'CC-BY-SA-3.0': 'CC-BY-SA-3.0'
            case 'Creative Commons Zero v1.0 Universal': 'CC0-1.0'
            case 'CC0-1.0': 'CC0-1.0'
            case 'CUA Office Public License v1.0': 'CUA-OPL-1.0'
            case 'CUA-OPL-1.0': 'CUA-OPL-1.0'
            case 'Eclipse Public License 1.0': 'EPL-1.0'
            case 'EPL-1.0': 'EPL-1.0'
            case 'eCos license version 2.0': 'eCos-2.0'
            case 'eCos-2.0': 'eCos-2.0'
            case 'Educational Community License v1.0': 'ECL-1.0'
            case 'ECL-1.0': 'ECL-1.0'
            case 'Educational Community License v2.0': 'ECL-2.0'
            case 'ECL-2.0': 'ECL-2.0'
            case 'Eiffel Forum License v1.0': 'EFL-1.0'
            case 'EFL-1.0': 'EFL-1.0'
            case 'Eiffel Forum License v2.0': 'EFL-2.0'
            case 'EFL-2.0': 'EFL-2.0'
            case 'Entessa Public License v1.0': 'Entessa'
            case 'Entessa': 'Entessa'
            case 'Erlang Public License v1.1': 'ErlPL-1.1'
            case 'ErlPL-1.1': 'ErlPL-1.1'
            case 'EU DataGrid Software License': 'EUDatagrid'
            case 'EUDatagrid': 'EUDatagrid'
            case 'European Union Public License 1.0': 'EUPL-1.0'
            case 'EUPL-1.0': 'EUPL-1.0'
            case 'European Union Public License 1.1': 'EUPL-1.1'
            case 'EUPL-1.1': 'EUPL-1.1'
            case 'Fair License': 'Fair'
            case 'Fair': 'Fair'
            case 'Frameworx Open License 1.0': 'Frameworx-1.0'
            case 'Frameworx-1.0': 'Frameworx-1.0'
            case 'GNU Affero General Public License v3.0': 'AGPL-3.0'
            case 'AGPL-3.0': 'AGPL-3.0'
            case 'GNU Free Documentation License v1.1': 'GFDL-1.1'
            case 'GFDL-1.1': 'GFDL-1.1'
            case 'GNU Free Documentation License v1.2': 'GFDL-1.2'
            case 'GFDL-1.2': 'GFDL-1.2'
            case 'GNU Free Documentation License v1.3': 'GFDL-1.3'
            case 'GFDL-1.3': 'GFDL-1.3'
            case 'GNU General Public License v1.0 only': 'GPL-1.0'
            case 'GPL-1.0': 'GPL-1.0'
            case 'GNU General Public License v1.0 or later': 'GPL-1.0+'
            case 'GPL-1.0+': 'GPL-1.0+'
            case 'GNU General Public License v2.0 only': 'GPL-2.0'
            case 'GPL-2.0': 'GPL-2.0'
            case 'GNU General Public License v2.0 or later': 'GPL-2.0+'
            case 'GPL-2.0+': 'GPL-2.0+'
            case 'GNU General Public License v2.0 w/Autoconf exception': 'GPL-2.0-with-autoconf-exception'
            case 'GPL-2.0-with-autoconf-exception': 'GPL-2.0-with-autoconf-exception'
            case 'GNU General Public License v2.0 w/Bison exception': 'GPL-2.0-with-bison-exception'
            case 'GPL-2.0-with-bison-exception': 'GPL-2.0-with-bison-exception'
            case 'GNU General Public License v2.0 w/Classpath exception': 'GPL-2.0-with-classpath-exception'
            case 'GPL-2.0-with-classpath-exception': 'GPL-2.0-with-classpath-exception'
            case 'GNU General Public License v2.0 w/Font exception': 'GPL-2.0-with-font-exception'
            case 'GPL-2.0-with-font-exception': 'GPL-2.0-with-font-exception'
            case 'GNU General Public License v2.0 w/GCC Runtime Library exception': 'GPL-2.0-with-GCC-exception'
            case 'GPL-2.0-with-GCC-exception': 'GPL-2.0-with-GCC-exception'
            case 'GNU General Public License v3.0 only': 'GPL-3.0'
            case 'GPL-3.0': 'GPL-3.0'
            case 'GNU General Public License v3.0 or later': 'GPL-3.0+'
            case 'GPL-3.0+': 'GPL-3.0+'
            case 'GNU General Public License v3.0 w/Autoconf exception': 'GPL-3.0-with-autoconf-exception'
            case 'GPL-3.0-with-autoconf-exception': 'GPL-3.0-with-autoconf-exception'
            case 'GNU General Public License v3.0 w/GCC Runtime Library exception': 'GPL-3.0-with-GCC-exception'
            case 'GPL-3.0-with-GCC-exception': 'GPL-3.0-with-GCC-exception'
            case 'GNU Lesser General Public License v2.1 only': 'LGPL-2.1'
            case 'LGPL-2.1': 'LGPL-2.1'
            case 'GNU Lesser General Public License v2.1 or later': 'LGPL-2.1-or-later'
            case 'LGPL-2.1+': 'LGPL-2.1-or-later'
            case 'GNU Lesser General Public License v3.0 only': 'LGPL-3.0'
            case 'LGPL-3.0': 'LGPL-3.0'
            case 'GNU Lesser General Public License v3.0 or later': 'LGPL-3.0-or-later'
            case 'LGPL-3.0+': 'LGPL-3.0-or-later'
            case 'GNU Library General Public License v2 only': 'LGPL-2.0'
            case 'LGPL-2.0': 'LGPL-2.0'
            case 'GNU Library General Public License v2 or later': 'LGPL-2.0-or-later'
            case 'LGPL-2.0+': 'LGPL-2.0-or-later'
            case 'gSOAP Public License v1.3b': 'gSOAP-1.3b'
            case 'gSOAP-1.3b': 'gSOAP-1.3b'
            case 'Historic Permission Notice and Disclaimer': 'HPND'
            case 'HPND': 'HPND'
            case 'IBM Public License v1.0': 'IPL-1.0'
            case 'IPL-1.0': 'IPL-1.0'
            case 'IPA Font License': 'IPA'
            case 'IPA': 'IPA'
            case 'ISC License': 'ISC'
            case 'ISC': 'ISC'
            case 'LaTeX Project Public License v1.0': 'LPPL-1.0'
            case 'LPPL-1.0': 'LPPL-1.0'
            case 'LaTeX Project Public License v1.1': 'LPPL-1.1'
            case 'LPPL-1.1': 'LPPL-1.1'
            case 'LaTeX Project Public License v1.2': 'LPPL-1.2'
            case 'LPPL-1.2': 'LPPL-1.2'
            case 'LaTeX Project Public License v1.3c': 'LPPL-1.3c'
            case 'LPPL-1.3c': 'LPPL-1.3c'
            case 'libpng License': 'Libpng'
            case 'Libpng': 'Libpng'
            case 'Lucent Public License Version 1.0 (Plan9)': 'LPL-1.0'
            case 'LPL-1.0': 'LPL-1.0'
            case 'Lucent Public License v1.02': 'LPL-1.02'
            case 'LPL-1.02': 'LPL-1.02'
            case 'Microsoft Public License': 'MS-PL'
            case 'MS-PL': 'MS-PL'
            case 'Microsoft Reciprocal License': 'MS-RL'
            case 'MS-RL': 'MS-RL'
            case 'MirOS Licence': 'MirOS'
            case 'MirOS': 'MirOS'
            case 'MIT License': 'MIT'
            case 'MIT': 'MIT'
            case 'Motosoto License': 'Motosoto'
            case 'Motosoto': 'Motosoto'
            case 'Mozilla Public License 1.0': 'MPL-1.0'
            case 'MPL-1.0': 'MPL-1.0'
            case 'Mozilla Public License 1.1': 'MPL-1.1'
            case 'MPL-1.1': 'MPL-1.1'
            case 'Mozilla Public License 2.0': 'MPL-2.0'
            case 'MPL-2.0': 'MPL-2.0'
            case 'Mozilla Public License 2.0 (no copyleft exception)': 'MPL-2.0-no-copyleft-exception'
            case 'MPL-2.0-no-copyleft-exception': 'MPL-2.0-no-copyleft-exception'
            case 'Multics License': 'Multics'
            case 'Multics': 'Multics'
            case 'NASA Open Source Agreement 1.3': 'NASA-1.3'
            case 'NASA-1.3': 'NASA-1.3'
            case 'Naumen Public License': 'Naumen'
            case 'Naumen': 'Naumen'
            case 'Nethack General Public License': 'NGPL'
            case 'NGPL': 'NGPL'
            case 'Nokia Open Source License': 'Nokia'
            case 'Nokia': 'Nokia'
            case 'Non-Profit Open Software License 3.0': 'NPOSL-3.0'
            case 'NPOSL-3.0': 'NPOSL-3.0'
            case 'NTP License': 'NTP'
            case 'NTP': 'NTP'
            case 'OCLC Research Public License 2.0': 'OCLC-2.0'
            case 'OCLC-2.0': 'OCLC-2.0'
            case 'ODC Open Database License v1.0': 'ODbL-1.0'
            case 'ODbL-1.0': 'ODbL-1.0'
            case 'ODC Public Domain Dedication & License 1.0': 'PDDL-1.0'
            case 'PDDL-1.0': 'PDDL-1.0'
            case 'Open Group Test Suite License': 'OGTSL'
            case 'OGTSL': 'OGTSL'
            case 'Open Software License 1.0': 'OSL-1.0'
            case 'OSL-1.0': 'OSL-1.0'
            case 'Open Software License 2.0': 'OSL-2.0'
            case 'OSL-2.0': 'OSL-2.0'
            case 'Open Software License 2.1': 'OSL-2.1'
            case 'OSL-2.1': 'OSL-2.1'
            case 'Open Software License 3.0': 'OSL-3.0'
            case 'OSL-3.0': 'OSL-3.0'
            case 'OpenLDAP Public License v2.8': 'OLDAP-2.8'
            case 'OLDAP-2.8': 'OLDAP-2.8'
            case 'OpenSSL License': 'OpenSSL'
            case 'OpenSSL': 'OpenSSL'
            case 'PHP License v3.0': 'PHP-3.0'
            case 'PHP-3.0': 'PHP-3.0'
            case 'PHP LIcense v3.01': 'PHP-3.01'
            case 'PHP-3.01': 'PHP-3.01'
            case 'PostgreSQL License': 'PostgreSQL'
            case 'PostgreSQL': 'PostgreSQL'
            case 'Python License 2.0': 'Python-2.0'
            case 'Python-2.0': 'Python-2.0'
            case 'Q Public License 1.0': 'QPL-1.0'
            case 'QPL-1.0': 'QPL-1.0'
            case 'RealNetworks Public Source License v1.0': 'RPSL-1.0'
            case 'RPSL-1.0': 'RPSL-1.0'
            case 'Reciprocal Public License 1.5': 'RPL-1.5'
            case 'RPL-1.5': 'RPL-1.5'
            case 'Red Hat eCos Public License v1.1': 'RHeCos-1.1'
            case 'RHeCos-1.1': 'RHeCos-1.1'
            case 'Ricoh Source Code Public License': 'RSCPL'
            case 'RSCPL': 'RSCPL'
            case 'Ruby License': 'Ruby'
            case 'Ruby': 'Ruby'
            case 'Sax Public Domain Notice': 'SAX-PD'
            case 'SAX-PD': 'SAX-PD'
            case 'SIL Open Font License 1.0': 'OFL-1.0'
            case 'OFL-1.0': 'OFL-1.0'
            case 'SIL Open Font License 1.1': 'OFL-1.1'
            case 'OFL-1.1': 'OFL-1.1'
            case 'Simple Public License 2.0': 'SimPL-2.0'
            case 'SimPL-2.0': 'SimPL-2.0'
            case 'Sleepycat License': 'Sleepycat'
            case 'Sleepycat': 'Sleepycat'
            case 'SugarCRM Public License v1.1.3': 'SugarCRM-1.1.3'
            case 'SugarCRM-1.1.3': 'SugarCRM-1.1.3'
            case 'Sun Public License v1.0': 'SPL-1.0'
            case 'SPL-1.0': 'SPL-1.0'
            case 'Sybase Open Watcom Public License 1.0': 'Watcom-1.0'
            case 'Watcom-1.0': 'Watcom-1.0'
            case 'University of Illinois/NCSA Open Source License': 'NCSA'
            case 'NCSA': 'NCSA'
            case 'Vovida Software License v1.0': 'VSL-1.0'
            case 'VSL-1.0': 'VSL-1.0'
            case 'W3C Software and Notice License': 'W3C'
            case 'W3C': 'W3C'
            case 'wxWindows Library License': 'WXwindows'
            case 'WXwindows': 'WXwindows'
            case 'X.Net License': 'Xnet'
            case 'Xnet': 'Xnet'
            case 'XFree86 License 1.1': 'XFree86-1.1'
            case 'XFree86-1.1': 'XFree86-1.1'
            case 'Yahoo! Public License v1.0': 'YPL-1.0'
            case 'YPL-1.0': 'YPL-1.0'
            case 'Yahoo! Public License v1.1': 'YPL-1.1'
            case 'YPL-1.1': 'YPL-1.1'
            case 'Zimbra Public License v1.3': 'Zimbra-1.3'
            case 'Zimbra-1.3': 'Zimbra-1.3'
            case 'zlib License': 'Zlib'
            case 'Zlib': 'Zlib'
            case 'Zope Public License 1.1': 'ZPL-1.1'
            case 'ZPL-1.1': 'ZPL-1.1'
            case 'Zope Public License 2.0': 'ZPL-2.0'
            case 'ZPL-2.0': 'ZPL-2.0'
            case 'Zope Public License 2.1': 'ZPL-2.1'
            case 'ZPL-2.1': 'ZPL-2.1'
            default: 'LGPL-3.0-or-later'
        }
    }
}
