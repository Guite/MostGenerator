package org.zikula.modulestudio.generator.cartridges.zclassic.controller.javascript

import de.guite.modulestudio.metamodel.Application
import de.guite.modulestudio.metamodel.ItemActionsStyle
import org.zikula.modulestudio.generator.application.IMostFileSystemAccess
import org.zikula.modulestudio.generator.extensions.ControllerExtensions
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.ModelJoinExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class DisplayFunctions {

    extension ControllerExtensions = new ControllerExtensions
    extension FormattingExtensions = new FormattingExtensions
    extension ModelBehaviourExtensions = new ModelBehaviourExtensions
    extension ModelExtensions = new ModelExtensions
    extension ModelJoinExtensions = new ModelJoinExtensions
    extension NamingExtensions = new NamingExtensions
    extension Utils = new Utils

    /**
     * Entry point for the JavaScript file with display functionality.
     */
    def generate(Application it, IMostFileSystemAccess fsa) {
        'Generating JavaScript for display functions'.printIfNotTesting(fsa)
        val fileName = appName + '.js'
        fsa.generateFile(getAppJsPath + fileName, generate)
    }

    def private generate(Application it) '''
        'use strict';

        function «vendorAndName»CapitaliseFirstLetter(string) {
            return string.charAt(0).toUpperCase() + string.substring(1);
        }
        «IF hasIndexActions»

            «initQuickNavigation»
        «ENDIF»
        «IF hasBooleansWithAjaxToggle»

            «toggleFlag»

            «initAjaxToggles»
        «ENDIF»

        «simpleAlert»
        «IF hasIndexActions»

            «initMassToggle»
        «ENDIF»
        «IF hasIndexActions || hasDetailActions»

            «initItemActions»
        «ENDIF»
        «IF (!getJoinRelations.empty || hasLoggable) && hasDetailActions»

            «initInlineWindow»

            «initQuickViewModals»
        «ENDIF»
        «IF hasImageFields»

            «initImageViewer»
        «ENDIF»
        «IF hasSortable && hasIndexActions»

            «initSortable»
        «ENDIF»

        «onLoad»
    '''

    def private initQuickNavigation(Application it) '''
        /**
         * Initialise the quick navigation form in list views.
         */
        function «vendorAndName»InitQuickNavigation() {
            var quickNavForm;
            var objectType;

            if (jQuery('.«appName.toLowerCase»-quicknav').length < 1) {
                return;
            }

            quickNavForm = jQuery('.«appName.toLowerCase»-quicknav').first();
            objectType = quickNavForm.attr('id').replace('«appName.toFirstLower»', '').replace('QuickNavForm', '');

            var quickNavFilterTimer;
            quickNavForm.find('select').change(function (event) {
                clearTimeout(quickNavFilterTimer);
                quickNavFilterTimer = setTimeout(function() {
                    quickNavForm.submit();
                }, 5000);
            });

            var fieldPrefix = '«appName.formatForDB»_' + objectType.toLowerCase() + 'quicknav_';
            // we can hide the submit button if we have no visible quick search field
            if (jQuery('#' + fieldPrefix + 'q').length < 1 || jQuery('#' + fieldPrefix + 'q').parent().parent().hasClass('d-none')) {
                jQuery('#' + fieldPrefix + 'updateview').addClass('d-none');
            }
        }
    '''

    def private toggleFlag(Application it) '''
        /**
         * Toggles a certain flag for a given item.
         */
        function «vendorAndName»ToggleFlag(objectType, fieldName, itemId) {
            jQuery.ajax({
                method: 'POST',
                url: Routing.generate('«appName.formatForDB»_ajax_toggleflag'),
                data: {
                    ot: objectType,
                    field: fieldName,
                    id: itemId
                }
            }).done(function (data) {
                var idSuffix;
                var toggleLink;

                idSuffix = «vendorAndName»CapitaliseFirstLetter(fieldName) + itemId;
                toggleLink = jQuery('#toggle' + idSuffix);

                /*if (data.message) {
                    «vendorAndName»SimpleAlert(toggleLink, Translator.trans('Success'), data.message, 'toggle' + idSuffix + 'DoneAlert', 'success');
                }*/

                toggleLink.find('.fa-check').toggleClass('d-none', true !== data.state);
                toggleLink.find('.fa-times').toggleClass('d-none', true === data.state);
            })«/*,
            fail: function (jqXHR, textStatus, errorThrown) {
                // nothing to do yet
                var idSuffix = fieldName + '_' + itemId;
                «vendorAndName»SimpleAlert(jQuery('#toggle' + idSuffix), Translator.trans('Error'), Translator.trans('Could not persist your change.'), 'toggle' + idSuffix + 'FailedAlert', 'danger');
            })*/»;
        }
    '''

    def private initAjaxToggles(Application it) '''
        /**
         * Initialise ajax-based toggle for all affected boolean fields on the current page.
         */
        function «vendorAndName»InitAjaxToggles() {
            jQuery('.«vendorAndName.toLowerCase»-ajax-toggle').click(function (event) {
                var objectType;
                var fieldName;
                var itemId;

                event.preventDefault();
                objectType = jQuery(this).data('object-type');
                fieldName = jQuery(this).data('field-name');
                itemId = jQuery(this).data('item-id');

                «vendorAndName»ToggleFlag(objectType, fieldName, itemId);
            }).removeClass('d-none');
        }
    '''

    def private simpleAlert(Application it) '''
        /**
         * Simulates a simple alert using bootstrap.
         */
        function «vendorAndName»SimpleAlert(anchorElement, title, content, alertId, cssClass) {
            var alertBox;

            alertBox = ' \
                <div id="' + alertId + '" class="alert alert-' + cssClass + ' fade show"> \
                  <button type="button" class="close" data-dismiss="alert">&times;</button> \
                  <h4>' + title + '</h4> \
                  <p>' + content + '</p> \
                </div>';

            // insert alert before the given anchor element
            anchorElement.before(alertBox);

            jQuery('#' + alertId).delay(200).addClass('in').fadeOut(4000, function () {
                jQuery(this).remove();
            });
        }
    '''

    def private initMassToggle(Application it) '''
        /**
         * Initialises the mass toggle functionality for admin view pages.
         */
        function «vendorAndName»InitMassToggle() {
            if (jQuery('.«vendorAndName.toLowerCase»-mass-toggle').length > 0) {
                jQuery('.«vendorAndName.toLowerCase»-mass-toggle').unbind('click').click(function (event) {
                    jQuery('.«vendorAndName.toLowerCase»-toggle-checkbox').prop('checked', jQuery(this).prop('checked'));
                });
            }
        }
    '''

    def private initItemActions(Application it) '''
        /**
         * Creates a dropdown menu for the item actions.
         */
        function «vendorAndName»InitItemActions(context) {
            «FOR styleWithJs : #[ItemActionsStyle.ICON, ItemActionsStyle.BUTTON_GROUP, ItemActionsStyle.DROPDOWN]»
            «IF #[indexActionsStyle, detailActionsStyle].contains(styleWithJs)»
                «IF indexActionsStyle == styleWithJs && detailActionsStyle == styleWithJs»
                    «initItemActionStyle(styleWithJs, '')»
                «ELSEIF indexActionsStyle == styleWithJs && detailActionsStyle != styleWithJs»
                    if ('index' === context) {
                        «initItemActionStyle(styleWithJs, '')»
                    }
                «ELSEIF indexActionsStyle != styleWithJs && detailActionsStyle == styleWithJs»
                    if ('detail' === context) {
                        «initItemActionStyle(styleWithJs, '')»
                    }
                «ENDIF»
            «ENDIF»
            «ENDFOR»
        }
    '''

    def private initItemActionStyle(Application it, ItemActionsStyle style, String context) '''
        «IF style == ItemActionsStyle.ICON»
            jQuery('ul.nav > li > a > i.tooltips').tooltip();
        «ELSEIF style == ItemActionsStyle.BUTTON_GROUP»
            jQuery('.btn-group-sm.item-actions').each(function (index) {
                var innerList;
                innerList = jQuery(this).children('ul.nav').first().detach();
                jQuery(this).append(innerList.find('a.btn'));
            });
        «ELSEIF style == ItemActionsStyle.DROPDOWN»
            var containerSelector;
            var containers;

            containerSelector = '';
            if ('index' === context) {
                containerSelector = '.«appName.toLowerCase»-index';
            } else if ('detail' === context) {
                containerSelector = 'h2, h3';
            }

            if ('' === containerSelector) {
                return;
            }

            containers = jQuery(containerSelector);
            if (containers.length < 1) {
                return;
            }

            containers.find('.dropdown > ul').removeClass('nav').addClass('list-unstyled dropdown-menu');
            containers.find('.dropdown > ul > li').addClass('dropdown-item').css('padding', 0);
            containers.find('.dropdown > ul a').addClass('d-block').css('padding', '3px 5px');
            containers.find('.dropdown > ul a i').addClass('fa-fw mr-1');
            if (0 < containers.find('.dropdown-toggle').length) {
                containers.find('.dropdown-toggle').removeClass('d-none').dropdown();
            }
        «ENDIF»
    '''

    def private initInlineWindow(Application it) '''
        /**
         * Helper function to create new dialog window instances.
         * Note we use jQuery UI dialogs instead of Bootstrap modals here
         * because we want to be able to open multiple windows simultaneously.
         */
        function «vendorAndName»InitInlineWindow(containerElem) {
            var newWindowId;
            var modalTitle;

            // show the container (hidden for users without JavaScript)
            containerElem.removeClass('d-none');

            // define name of window
            newWindowId = containerElem.attr('id') + 'Dialog';

            containerElem.unbind('click').click(function (event) {
                event.preventDefault();

                // check if window exists already
                if (jQuery('#' + newWindowId).length < 1) {
                    // create new window instance
                    jQuery('<div>', { id: newWindowId })
                        .append(
                            jQuery('<iframe width="100%" height="100%" marginWidth="0" marginHeight="0" frameBorder="0" scrolling="auto">')
                                .attr('src', containerElem.attr('href'))
                        )
                        .dialog({
                            autoOpen: false,
                            show: {
                                effect: 'blind',
                                duration: 1000
                            },
                            hide: {
                                effect: 'explode',
                                duration: 1000
                            },
                            title: containerElem.data('modal-title'),
                            width: 600,
                            height: 400,
                            modal: false
                        });
                }

                // open the window
                jQuery('#' + newWindowId).dialog('open');
            });

            // return the dialog selector id;
            return newWindowId;
        }
    '''

    def private initQuickViewModals(Application it) '''
        /**
         * Initialises modals for inline display of related items.
         */
        function «vendorAndName»InitQuickViewModals() {
            jQuery('.«vendorAndName.toLowerCase»-inline-window').each(function (index) {
                «vendorAndName»InitInlineWindow(jQuery(this));
            });
        }
    '''

    def private initImageViewer(Application it) '''
        /**
         * Initialises image viewing behaviour.
         */
        function «vendorAndName»InitImageViewer() {
            var scripts;
            var magnificPopupAvailable;

            // check if magnific popup is available
            scripts = jQuery('script');
            magnificPopupAvailable = false;
            jQuery.each(scripts, function (index, elem) {
                if (elem.hasAttribute('src')) {
                    elem = jQuery(elem);
                    if (-1 !== elem.attr('src').indexOf('jquery.magnific-popup')) {
                        magnificPopupAvailable = true;
                    }
                }
            });
            if (!magnificPopupAvailable) {
                return;
            }
            jQuery('a.image-link').magnificPopup({
                type: 'image',
                closeOnContentClick: true,
                image: {
                    titleSrc: 'title',
                    verticalFit: true
                },
                gallery: {
                    enabled: true,
                    navigateByImgClick: true,
                    arrowMarkup: '<button title="%title%" type="button" class="mfp-arrow mfp-arrow-%dir%"></button>',
                    tPrev: Translator.trans('Previous (Left arrow key)'),
                    tNext: Translator.trans('Next (Right arrow key)'),
                    tCounter: '<span class="mfp-counter">%curr% ' + Translator.trans('of') + ' %total%</span>'
                },
                zoom: {
                    enabled: true,
                    duration: 300,
                    easing: 'ease-in-out'
                }
            });
        }
    '''

    def private initSortable(Application it) '''
        /**
         * Initialises reordering view entries using drag n drop.
         */
        function «vendorAndName»InitSortable() {
            if (1 > jQuery('#sortableTable').length) {
                return;
            }

            jQuery('#sortableTable > tbody').sortable({
                cursor: 'move',
                handle: '.sort-handle',
                items: '.sort-item',
                placeholder: 'ui-state-highlight',
                tolerance: 'pointer',
                sort: function (event, ui) {
                    ui.item.addClass('active-item-shadow');
                },
                stop: function (event, ui) {
                    ui.item.removeClass('active-item-shadow');
                },
                update: function (event, ui) {
                    jQuery.ajax({
                        method: 'POST',
                        url: Routing.generate('«appName.formatForDB»_ajax_updatesortpositions'),
                        data: {
                            ot: jQuery('#sortableTable').data('object-type'),
                            identifiers: jQuery(this).sortable('toArray', { attribute: 'data-item-id' }),
                            min: jQuery('#sortableTable').data('min'),
                            max: jQuery('#sortableTable').data('max')
                        }
                    }).done(function (data) {
                        /*if (data.message) {
                            «vendorAndName»SimpleAlert(jQuery('#sortableTable'), Translator.trans('Success'), data.message, 'sortingDoneAlert', 'success');
                        }*/
                        window.location.reload();
                    });
                }
            });
            jQuery('#sortableTable').disableSelection();
        }
    '''

    def private onLoad(Application it) '''
        jQuery(document).ready(function () {
            var isIndexPage;
            var isDetailPage;

            isIndexPage = 0 < jQuery('.«appName.toLowerCase»-index').length;
            isDetailPage = 0 < jQuery('.«appName.toLowerCase»-detail').length;

            «IF hasImageFields»
                «vendorAndName»InitImageViewer();

            «ENDIF»
            if (isIndexPage) {
                «vendorAndName»InitQuickNavigation();
                «vendorAndName»InitMassToggle();
                «vendorAndName»InitItemActions('index');
                «IF hasBooleansWithAjaxToggleInView»
                    «vendorAndName»InitAjaxToggles();
                «ENDIF»
                «IF hasSortable»
                    «vendorAndName»InitSortable();
                «ENDIF»
            } else if (isDetailPage) {
                «vendorAndName»InitItemActions('detail');
                «IF hasBooleansWithAjaxToggleInDisplay»
                    «vendorAndName»InitAjaxToggles();
                «ENDIF»
            }
            «IF (!getJoinRelations.empty || hasLoggable) && hasDetailActions»

                «vendorAndName»InitQuickViewModals();
            «ENDIF»
        });
    '''
}
