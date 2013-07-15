package org.zikula.modulestudio.generator.cartridges.zclassic.controller.actionHandler;

import com.google.inject.Inject;
import de.guite.modulestudio.metamodel.modulestudio.Application;
import de.guite.modulestudio.metamodel.modulestudio.Controller;
import de.guite.modulestudio.metamodel.modulestudio.Controllers;
import org.eclipse.xtend2.lib.StringConcatenation;
import org.eclipse.xtext.xbase.lib.Extension;
import org.eclipse.xtext.xbase.lib.Functions.Function0;
import org.zikula.modulestudio.generator.extensions.ModelExtensions;
import org.zikula.modulestudio.generator.extensions.Utils;

/**
 * Upload processing functions for edit form handlers.
 */
@SuppressWarnings("all")
public class UploadProcessing {
  @Inject
  @Extension
  private ModelExtensions _modelExtensions = new Function0<ModelExtensions>() {
    public ModelExtensions apply() {
      ModelExtensions _modelExtensions = new ModelExtensions();
      return _modelExtensions;
    }
  }.apply();
  
  @Inject
  @Extension
  private Utils _utils = new Function0<Utils>() {
    public Utils apply() {
      Utils _utils = new Utils();
      return _utils;
    }
  }.apply();
  
  public CharSequence generate(final Controller it) {
    CharSequence _xifexpression = null;
    Controllers _container = it.getContainer();
    Application _application = _container.getApplication();
    boolean _hasUploads = this._modelExtensions.hasUploads(_application);
    if (_hasUploads) {
      Controllers _container_1 = it.getContainer();
      Application _application_1 = _container_1.getApplication();
      CharSequence _handleUploads = this.handleUploads(it, _application_1);
      _xifexpression = _handleUploads;
    }
    return _xifexpression;
  }
  
  private CharSequence handleUploads(final Controller it, final Application app) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Helper method to process upload fields.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param array  $formData       The form input data.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param object $existingObject Data of existing entity object.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @return array form data after processing.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("protected function handleUploads($formData, $existingObject)");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if (!count($this->uploadFields)) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("return $formData;");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// initialise the upload handler");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$uploadManager = new ");
    {
      boolean _targets = this._utils.targets(app, "1.3.5");
      if (_targets) {
        String _appName = this._utils.appName(app);
        _builder.append(_appName, "    ");
        _builder.append("_");
      }
    }
    _builder.append("UploadHandler();");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("$existingObjectData = $existingObject->toArray();");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$objectId = ($this->mode != \'create\') ? $this->idValues[0] : 0;");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// process all fields");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("foreach ($this->uploadFields as $uploadField => $isMandatory) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("// check if an existing file must be deleted");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$hasOldFile = (!empty($existingObjectData[$uploadField]));");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$hasBeenDeleted = !$hasOldFile;");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("if ($this->mode != \'create\') {");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("if (isset($formData[$uploadField . \'DeleteFile\'])) {");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("if ($hasOldFile && $formData[$uploadField . \'DeleteFile\'] === true) {");
    _builder.newLine();
    _builder.append("                    ");
    _builder.append("// remove upload file (and image thumbnails)");
    _builder.newLine();
    _builder.append("                    ");
    _builder.append("$existingObjectData = $uploadManager->deleteUploadFile($this->objectType, $existingObjectData, $uploadField, $objectId);");
    _builder.newLine();
    _builder.append("                    ");
    _builder.append("if (empty($existingObjectData[$uploadField])) {");
    _builder.newLine();
    _builder.append("                        ");
    _builder.append("$existingObject[$uploadField] = \'\';");
    _builder.newLine();
    _builder.append("                        ");
    _builder.append("$existingObject[$uploadField . \'Meta\'] = array();");
    _builder.newLine();
    _builder.append("                    ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("unset($formData[$uploadField . \'DeleteFile\']);");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("$hasBeenDeleted = true;");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("        ");
    _builder.append("// look whether a file has been provided");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("if (!$formData[$uploadField] || $formData[$uploadField][\'size\'] == 0) {");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("// no file has been uploaded");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("unset($formData[$uploadField]);");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("// skip to next one");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("continue;");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("        ");
    _builder.append("if ($hasOldFile && $hasBeenDeleted !== true && $this->mode != \'create\') {");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("// remove old upload file (and image thumbnails)");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("$existingObjectData = $uploadManager->deleteUploadFile($this->objectType, $existingObjectData, $uploadField, $objectId);");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("if (empty($existingObjectData[$uploadField])) {");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("$existingObject[$uploadField] = \'\';");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("$existingObject[$uploadField . \'Meta\'] = array();");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("        ");
    _builder.append("// do the actual upload (includes validation, physical file processing and reading meta data)");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$uploadResult = $uploadManager->performFileUpload($this->objectType, $formData, $uploadField);");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("// assign the upload file name");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$formData[$uploadField] = $uploadResult[\'fileName\'];");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("// assign the meta data");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$formData[$uploadField . \'Meta\'] = $uploadResult[\'metaData\'];");
    _builder.newLine();
    _builder.newLine();
    _builder.append("        ");
    _builder.append("// if current field is mandatory check if everything has been done");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("if ($isMandatory && empty($formData[$uploadField])) {");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("// mandatory upload has not been completed successfully");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("return false;");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("        ");
    _builder.append("// upload succeeded");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("return $formData;");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
}
