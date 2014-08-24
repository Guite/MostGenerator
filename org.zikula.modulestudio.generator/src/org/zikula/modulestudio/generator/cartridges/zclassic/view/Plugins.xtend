package org.zikula.modulestudio.generator.cartridges.zclassic.view

import de.guite.modulestudio.metamodel.Application
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.cartridges.zclassic.view.plugin.ActionUrl
import org.zikula.modulestudio.generator.cartridges.zclassic.view.plugin.FormatGeoData
import org.zikula.modulestudio.generator.cartridges.zclassic.view.plugin.FormatIcalText
import org.zikula.modulestudio.generator.cartridges.zclassic.view.plugin.GetCountryName
import org.zikula.modulestudio.generator.cartridges.zclassic.view.plugin.GetFileSize
import org.zikula.modulestudio.generator.cartridges.zclassic.view.plugin.GetListEntry
import org.zikula.modulestudio.generator.cartridges.zclassic.view.plugin.ModerationObjects
import org.zikula.modulestudio.generator.cartridges.zclassic.view.plugin.ObjectState
import org.zikula.modulestudio.generator.cartridges.zclassic.view.plugin.ObjectTypeSelector
import org.zikula.modulestudio.generator.cartridges.zclassic.view.plugin.TemplateHeaders
import org.zikula.modulestudio.generator.cartridges.zclassic.view.plugin.TemplateSelector
import org.zikula.modulestudio.generator.cartridges.zclassic.view.plugin.TreeData
import org.zikula.modulestudio.generator.cartridges.zclassic.view.plugin.TreeSelection
import org.zikula.modulestudio.generator.cartridges.zclassic.view.plugin.ValidationError
import org.zikula.modulestudio.generator.cartridges.zclassic.view.plugin.form.AbstractObjectSelector
import org.zikula.modulestudio.generator.cartridges.zclassic.view.plugin.form.ColourInput
import org.zikula.modulestudio.generator.cartridges.zclassic.view.plugin.form.CountrySelector
import org.zikula.modulestudio.generator.cartridges.zclassic.view.plugin.form.Frame
import org.zikula.modulestudio.generator.cartridges.zclassic.view.plugin.form.GeoInput
import org.zikula.modulestudio.generator.cartridges.zclassic.view.plugin.form.ItemSelector
import org.zikula.modulestudio.generator.cartridges.zclassic.view.plugin.form.RelationSelectorAutoComplete
import org.zikula.modulestudio.generator.cartridges.zclassic.view.plugin.form.RelationSelectorList
import org.zikula.modulestudio.generator.cartridges.zclassic.view.plugin.form.TreeSelector
import org.zikula.modulestudio.generator.cartridges.zclassic.view.plugin.form.UserInput
import org.zikula.modulestudio.generator.extensions.ControllerExtensions
import org.zikula.modulestudio.generator.extensions.GeneratorSettingsExtensions
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.Utils
import org.zikula.modulestudio.generator.extensions.WorkflowExtensions

class Plugins {
    extension ControllerExtensions = new ControllerExtensions
    extension GeneratorSettingsExtensions = new GeneratorSettingsExtensions
    extension ModelExtensions = new ModelExtensions
    extension ModelBehaviourExtensions = new ModelBehaviourExtensions
    extension Utils = new Utils
    extension WorkflowExtensions = new WorkflowExtensions

    def generate(Application it, IFileSystemAccess fsa) {
        viewPlugins(fsa)
        if (hasEditActions || needsConfig) {
            new Frame().generate(it, fsa)
        }
        if (hasEditActions) {
            editPlugins(fsa)
            if (targets('1.3.5')) {
                new ValidationError().generate(it, fsa)
            }
        }
        otherPlugins(fsa)
    }

    def private viewPlugins(Application it, IFileSystemAccess fsa) {
        new ActionUrl().generate(it, fsa)
        new ObjectState().generate(it, fsa)
        if (targets('1.3.5')) {
            new TemplateHeaders().generate(it, fsa)
        }
        if (hasCountryFields) {
            new GetCountryName().generate(it, fsa)
        }
        if (hasUploads) {
            new GetFileSize().generate(it, fsa)
        }
        if (hasListFields) {
            new GetListEntry().generate(it, fsa)
        }
        if (hasGeographical) {
            new FormatGeoData().generate(it, fsa)
        }
        if (hasTrees) {
            new TreeData().generate(it, fsa)
            new TreeSelection().generate(it, fsa)
        }
        if (generateModerationPanel && needsApproval) {
            new ModerationObjects().generate(it, fsa)
        }
        if (generateIcsTemplates && !entities.filter[getStartDateField !== null && getEndDateField !== null].empty) {
            new FormatIcalText().generate(it, fsa)
        }
    }

    def private editPlugins(Application it, IFileSystemAccess fsa) {
        if (hasColourFields) {
            new ColourInput().generate(it, fsa)
        }
        if (hasCountryFields) {
            new CountrySelector().generate(it, fsa)
        }
        if (hasGeographical) {
            new GeoInput().generate(it, fsa)
        }
        val hasRelations = !relations.empty
        if (hasTrees || hasRelations) {
            new AbstractObjectSelector().generate(it, fsa)
        }
        if (hasTrees) {
            new TreeSelector().generate(it, fsa)
        }
        if (hasRelations) {
            new RelationSelectorList().generate(it, fsa)
            new RelationSelectorAutoComplete().generate(it, fsa)
        }
        if (hasUserFields) {
            new UserInput().generate(it, fsa)
        }
    }

    def private otherPlugins(Application it, IFileSystemAccess fsa) {
        new ItemSelector().generate(it, fsa)
        new ObjectTypeSelector().generate(it, fsa)
        new TemplateSelector().generate(it, fsa)
    }
}
