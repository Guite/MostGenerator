package org.zikula.modulestudio.generator.cartridges.zclassic.controller.helper;

import com.google.common.base.Objects;
import de.guite.modulestudio.metamodel.Application;
import de.guite.modulestudio.metamodel.DataObject;
import de.guite.modulestudio.metamodel.Entity;
import de.guite.modulestudio.metamodel.EntityTreeType;
import de.guite.modulestudio.metamodel.JoinRelationship;
import de.guite.modulestudio.metamodel.RelationEditType;
import java.util.ArrayList;
import org.eclipse.xtend2.lib.StringConcatenation;
import org.eclipse.xtext.generator.IFileSystemAccess;
import org.eclipse.xtext.xbase.lib.CollectionLiterals;
import org.eclipse.xtext.xbase.lib.Extension;
import org.eclipse.xtext.xbase.lib.Functions.Function1;
import org.eclipse.xtext.xbase.lib.InputOutput;
import org.eclipse.xtext.xbase.lib.IterableExtensions;
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper;
import org.zikula.modulestudio.generator.extensions.ControllerExtensions;
import org.zikula.modulestudio.generator.extensions.FormattingExtensions;
import org.zikula.modulestudio.generator.extensions.ModelExtensions;
import org.zikula.modulestudio.generator.extensions.ModelJoinExtensions;
import org.zikula.modulestudio.generator.extensions.NamingExtensions;
import org.zikula.modulestudio.generator.extensions.Utils;

@SuppressWarnings("all")
public class ModelHelper {
  @Extension
  private ControllerExtensions _controllerExtensions = new ControllerExtensions();
  
  @Extension
  private FormattingExtensions _formattingExtensions = new FormattingExtensions();
  
  @Extension
  private ModelExtensions _modelExtensions = new ModelExtensions();
  
  @Extension
  private ModelJoinExtensions _modelJoinExtensions = new ModelJoinExtensions();
  
  @Extension
  private NamingExtensions _namingExtensions = new NamingExtensions();
  
  @Extension
  private Utils _utils = new Utils();
  
  /**
   * Entry point for the helper class creation.
   */
  public void generate(final Application it, final IFileSystemAccess fsa) {
    InputOutput.<String>println("Generating helper class for model layer");
    final FileHelper fh = new FileHelper();
    String _appSourceLibPath = this._namingExtensions.getAppSourceLibPath(it);
    String _plus = (_appSourceLibPath + "Helper/ModelHelper.php");
    this._namingExtensions.generateClassPair(it, fsa, _plus, 
      fh.phpFileContent(it, this.modelFunctionsBaseImpl(it)), fh.phpFileContent(it, this.modelFunctionsImpl(it)));
  }
  
  private CharSequence modelFunctionsBaseImpl(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("namespace ");
    String _appNamespace = this._utils.appNamespace(it);
    _builder.append(_appNamespace);
    _builder.append("\\Helper\\Base;");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("use ");
    String _appNamespace_1 = this._utils.appNamespace(it);
    _builder.append(_appNamespace_1);
    _builder.append("\\Entity\\Factory\\");
    String _formatForCodeCapital = this._formattingExtensions.formatForCodeCapital(it.getName());
    _builder.append(_formatForCodeCapital);
    _builder.append("Factory;");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Helper base class for model layer methods.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("abstract class AbstractModelHelper");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("/**");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* @var ");
    String _formatForCodeCapital_1 = this._formattingExtensions.formatForCodeCapital(it.getName());
    _builder.append(_formatForCodeCapital_1, "     ");
    _builder.append("Factory");
    _builder.newLineIfNotEmpty();
    _builder.append("     ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("protected $entityFactory;");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("/**");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* ModelHelper constructor.");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("*");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* @param ");
    String _formatForCodeCapital_2 = this._formattingExtensions.formatForCodeCapital(it.getName());
    _builder.append(_formatForCodeCapital_2, "     ");
    _builder.append("Factory $entityFactory ");
    String _formatForCodeCapital_3 = this._formattingExtensions.formatForCodeCapital(it.getName());
    _builder.append(_formatForCodeCapital_3, "     ");
    _builder.append("Factory service instance");
    _builder.newLineIfNotEmpty();
    _builder.append("     ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("public function __construct(");
    String _formatForCodeCapital_4 = this._formattingExtensions.formatForCodeCapital(it.getName());
    _builder.append(_formatForCodeCapital_4, "    ");
    _builder.append("Factory $entityFactory)");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("{");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$this->entityFactory = $entityFactory;");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    CharSequence _canBeCreated = this.canBeCreated(it);
    _builder.append(_canBeCreated, "    ");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("    ");
    CharSequence _hasExistingInstances = this.hasExistingInstances(it);
    _builder.append(_hasExistingInstances, "    ");
    _builder.newLineIfNotEmpty();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence canBeCreated(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Determines whether creating an instance of a certain object type is possible.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* This is when");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*     - no tree is used");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*     - it has no incoming bidirectional non-nullable relationships.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*     - the edit type of all those relationships has PASSIVE_EDIT and auto completion is used on the target side");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*       (then a new source object can be created while creating the target object).");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*     - corresponding source objects exist already in the system.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Note that even creation of a certain object is possible, it may still be forbidden for the current user");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* if he does not have the required permission level.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param string $objectType Name of treated entity type");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @return boolean Whether a new instance can be created or not");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @throws Exception If an invalid object type is used");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("public function canBeCreated($objectType)");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$result = false;");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("switch ($objectType) {");
    _builder.newLine();
    {
      final Function1<Entity, Boolean> _function = (Entity it_1) -> {
        return Boolean.valueOf((this._controllerExtensions.hasEditAction(it_1) && Objects.equal(it_1.getTree(), EntityTreeType.NONE)));
      };
      Iterable<Entity> _filter = IterableExtensions.<Entity>filter(this._modelExtensions.getAllEntities(it), _function);
      for(final Entity entity : _filter) {
        _builder.append("        ");
        _builder.append("case \'");
        String _formatForCode = this._formattingExtensions.formatForCode(entity.getName());
        _builder.append(_formatForCode, "        ");
        _builder.append("\':");
        _builder.newLineIfNotEmpty();
        _builder.append("        ");
        _builder.append("    ");
        CharSequence _canBeCreatedImpl = this.canBeCreatedImpl(entity);
        _builder.append(_canBeCreatedImpl, "            ");
        _builder.newLineIfNotEmpty();
        _builder.append("        ");
        _builder.append("    ");
        _builder.append("break;");
        _builder.newLine();
      }
    }
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("return $result;");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence canBeCreatedImpl(final Entity it) {
    StringConcatenation _builder = new StringConcatenation();
    Iterable<JoinRelationship> incomingAndMandatoryRelations = this._modelJoinExtensions.getBidirectionalIncomingAndMandatoryJoinRelations(it);
    _builder.newLineIfNotEmpty();
    {
      boolean _isEmpty = IterableExtensions.isEmpty(incomingAndMandatoryRelations);
      if (_isEmpty) {
        _builder.append("$result = true;");
        _builder.newLine();
      } else {
        String _xblockexpression = null;
        {
          final Function1<JoinRelationship, Boolean> _function = (JoinRelationship it_1) -> {
            boolean _usesAutoCompletion = this._modelJoinExtensions.usesAutoCompletion(it_1, true);
            return Boolean.valueOf((!_usesAutoCompletion));
          };
          final Function1<JoinRelationship, Boolean> _function_1 = (JoinRelationship it_1) -> {
            return Boolean.valueOf(((!Objects.equal(this._controllerExtensions.getEditingType(it_1), RelationEditType.ACTIVE_NONE_PASSIVE_EDIT)) && (!Objects.equal(this._controllerExtensions.getEditingType(it_1), RelationEditType.ACTIVE_EDIT_PASSIVE_EDIT))));
          };
          incomingAndMandatoryRelations = IterableExtensions.<JoinRelationship>filter(IterableExtensions.<JoinRelationship>filter(incomingAndMandatoryRelations, _function), _function_1);
          _xblockexpression = "";
        }
        _builder.append(_xblockexpression);
        _builder.newLineIfNotEmpty();
        {
          boolean _isEmpty_1 = IterableExtensions.isEmpty(incomingAndMandatoryRelations);
          if (_isEmpty_1) {
            _builder.append("$result = true;");
            _builder.newLine();
          } else {
            _builder.append("$result = true;");
            _builder.newLine();
            {
              ArrayList<DataObject> _uniqueListOfSourceEntityTypes = this.getUniqueListOfSourceEntityTypes(it, incomingAndMandatoryRelations);
              for(final DataObject entity : _uniqueListOfSourceEntityTypes) {
                _builder.append("$result &= $this->hasExistingInstances(\'");
                String _formatForCode = this._formattingExtensions.formatForCode(entity.getName());
                _builder.append(_formatForCode);
                _builder.append("\');");
                _builder.newLineIfNotEmpty();
              }
            }
          }
        }
      }
    }
    return _builder;
  }
  
  private ArrayList<DataObject> getUniqueListOfSourceEntityTypes(final Entity it, final Iterable<JoinRelationship> relations) {
    ArrayList<DataObject> _xblockexpression = null;
    {
      ArrayList<DataObject> sourceTypes = CollectionLiterals.<DataObject>newArrayList();
      for (final JoinRelationship relation : relations) {
        boolean _contains = sourceTypes.contains(relation.getSource());
        boolean _not = (!_contains);
        if (_not) {
          sourceTypes.add(relation.getSource());
        }
      }
      _xblockexpression = sourceTypes;
    }
    return _xblockexpression;
  }
  
  private CharSequence hasExistingInstances(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Determines whether there exists at least one instance of a certain object type in the database.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param string $objectType Name of treated entity type");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @return boolean Whether at least one instance exists or not");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @throws Exception If an invalid object type is used");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("protected function hasExistingInstances($objectType)");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$repository = $this->entityFactory->getRepository($objectType);");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if (null === $repository) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("return false;");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("return $repository->selectCount() > 0;");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence modelFunctionsImpl(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("namespace ");
    String _appNamespace = this._utils.appNamespace(it);
    _builder.append(_appNamespace);
    _builder.append("\\Helper;");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("use ");
    String _appNamespace_1 = this._utils.appNamespace(it);
    _builder.append(_appNamespace_1);
    _builder.append("\\Helper\\Base\\AbstractModelHelper;");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Helper implementation class for model layer methods.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("class ModelHelper extends AbstractModelHelper");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// feel free to add your own convenience methods here");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
}
