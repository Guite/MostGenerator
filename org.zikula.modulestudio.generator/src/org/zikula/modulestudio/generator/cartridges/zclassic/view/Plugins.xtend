package org.zikula.modulestudio.generator.cartridges.zclassic.view

import com.google.inject.Inject
import de.guite.modulestudio.metamodel.modulestudio.Application
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.cartridges.zclassic.view.plugin.ActionUrl
import org.zikula.modulestudio.generator.cartridges.zclassic.view.plugin.FormColourInput
import org.zikula.modulestudio.generator.cartridges.zclassic.view.plugin.FormCountrySelector
import org.zikula.modulestudio.generator.cartridges.zclassic.view.plugin.FormFrame
import org.zikula.modulestudio.generator.cartridges.zclassic.view.plugin.FormGeoInput
import org.zikula.modulestudio.generator.cartridges.zclassic.view.plugin.FormItemSelector
import org.zikula.modulestudio.generator.cartridges.zclassic.view.plugin.FormatGeoData
import org.zikula.modulestudio.generator.cartridges.zclassic.view.plugin.GetCountryName
import org.zikula.modulestudio.generator.cartridges.zclassic.view.plugin.GetFileSize
import org.zikula.modulestudio.generator.cartridges.zclassic.view.plugin.GetListEntry
import org.zikula.modulestudio.generator.cartridges.zclassic.view.plugin.ImageThumb
import org.zikula.modulestudio.generator.cartridges.zclassic.view.plugin.SelectorObjectTypes
import org.zikula.modulestudio.generator.cartridges.zclassic.view.plugin.SelectorTemplates
import org.zikula.modulestudio.generator.cartridges.zclassic.view.plugin.TemplateHeaders
import org.zikula.modulestudio.generator.cartridges.zclassic.view.plugin.TreeJS
import org.zikula.modulestudio.generator.cartridges.zclassic.view.plugin.TreeSelector
import org.zikula.modulestudio.generator.cartridges.zclassic.view.plugin.ValidationError
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions

class Plugins {
    @Inject extension ModelExtensions = new ModelExtensions()
    @Inject extension ModelBehaviourExtensions = new ModelBehaviourExtensions()

    def generate(Application it, IFileSystemAccess fsa) {
        new ActionUrl().generate(it, fsa)
        new ImageThumb().generate(it, fsa)
        new FormFrame().generate(it, fsa)
        new SelectorObjectTypes().generate(it, fsa)
        new SelectorTemplates().generate(it, fsa)
        new TemplateHeaders().generate(it, fsa)
        new ValidationError().generate(it, fsa)
        if (hasUploads) {
            new ImageThumb().generate(it, fsa)
            new GetFileSize().generate(it, fsa)
        }
        if (hasTrees) {
            new TreeJS().generate(it, fsa)
            new TreeSelector().generate(it, fsa)
        }
        new FormItemSelector().generate(it, fsa)
        if (hasColourFields) {
            new FormColourInput().generate(it, fsa)
        }
        if (hasCountryFields) {
            new FormCountrySelector().generate(it, fsa)
            new GetCountryName().generate(it, fsa)
        }
        if (hasListFields) {
            new GetListEntry().generate(it, fsa)
        }
        if (getAllEntities.exists(e|e.geographical)) {
            new FormGeoInput().generate(it, fsa)
            new FormatGeoData().generate(it, fsa)
        }
    }
}
