package org.zikula.modulestudio.generator.cartridges.zclassic.view

import com.google.inject.Inject
import de.guite.modulestudio.metamodel.modulestudio.Application
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.cartridges.zclassic.view.plugin.ActionUrl
import org.zikula.modulestudio.generator.cartridges.zclassic.view.plugin.form.ColourInput
import org.zikula.modulestudio.generator.cartridges.zclassic.view.plugin.form.CountrySelector
import org.zikula.modulestudio.generator.cartridges.zclassic.view.plugin.form.Frame
import org.zikula.modulestudio.generator.cartridges.zclassic.view.plugin.form.GeoInput
import org.zikula.modulestudio.generator.cartridges.zclassic.view.plugin.form.ItemSelector
import org.zikula.modulestudio.generator.cartridges.zclassic.view.plugin.form.TreeSelector
import org.zikula.modulestudio.generator.cartridges.zclassic.view.plugin.form.UserInput
import org.zikula.modulestudio.generator.cartridges.zclassic.view.plugin.FormatGeoData
import org.zikula.modulestudio.generator.cartridges.zclassic.view.plugin.GetCountryName
import org.zikula.modulestudio.generator.cartridges.zclassic.view.plugin.GetFileSize
import org.zikula.modulestudio.generator.cartridges.zclassic.view.plugin.GetListEntry
import org.zikula.modulestudio.generator.cartridges.zclassic.view.plugin.ImageThumb
import org.zikula.modulestudio.generator.cartridges.zclassic.view.plugin.SelectorObjectTypes
import org.zikula.modulestudio.generator.cartridges.zclassic.view.plugin.SelectorTemplates
import org.zikula.modulestudio.generator.cartridges.zclassic.view.plugin.TemplateHeaders
import org.zikula.modulestudio.generator.cartridges.zclassic.view.plugin.TreeJS
import org.zikula.modulestudio.generator.cartridges.zclassic.view.plugin.TreeSelection
import org.zikula.modulestudio.generator.cartridges.zclassic.view.plugin.ValidationError
import org.zikula.modulestudio.generator.extensions.ControllerExtensions
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions

class Plugins {
    @Inject extension ControllerExtensions = new ControllerExtensions()
    @Inject extension ModelExtensions = new ModelExtensions()
    @Inject extension ModelBehaviourExtensions = new ModelBehaviourExtensions()

    def generate(Application it, IFileSystemAccess fsa) {
        new ActionUrl().generate(it, fsa)
        new SelectorObjectTypes().generate(it, fsa)
        new SelectorTemplates().generate(it, fsa)
        new TemplateHeaders().generate(it, fsa)
        if (hasEditActions) {
            new Frame().generate(it, fsa)
            new ValidationError().generate(it, fsa)
        }
        if (hasUploads) {
            new ImageThumb().generate(it, fsa)
            new GetFileSize().generate(it, fsa)
        }
        if (hasTrees) {
            new TreeJS().generate(it, fsa)
            if (hasEditActions) {
                new TreeSelector().generate(it, fsa)
            }
            new TreeSelection().generate(it, fsa)
        }
        new ItemSelector().generate(it, fsa)
        if (hasColourFields && hasEditActions) {
            new ColourInput().generate(it, fsa)
        }
        if (hasCountryFields) {
            if (hasEditActions) {
                new CountrySelector().generate(it, fsa)
            }
            new GetCountryName().generate(it, fsa)
        }
        if (hasListFields) {
            new GetListEntry().generate(it, fsa)
        }
        if (hasUserFields) {
            if (hasEditActions) {
                new UserInput().generate(it, fsa)
            }
        }
        if (getAllEntities.exists(e|e.geographical)) {
            if (hasEditActions) {
                new GeoInput().generate(it, fsa)
            }
            new FormatGeoData().generate(it, fsa)
        }
    }
}
