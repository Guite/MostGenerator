package org.zikula.modulestudio.generator.cartridges.zclassic.models.entity;

import com.google.common.base.Objects;
import com.google.inject.Inject;
import de.guite.modulestudio.metamodel.modulestudio.Application;
import de.guite.modulestudio.metamodel.modulestudio.CascadeType;
import de.guite.modulestudio.metamodel.modulestudio.DerivedField;
import de.guite.modulestudio.metamodel.modulestudio.Entity;
import de.guite.modulestudio.metamodel.modulestudio.IntegerField;
import de.guite.modulestudio.metamodel.modulestudio.JoinRelationship;
import de.guite.modulestudio.metamodel.modulestudio.ManyToManyRelationship;
import de.guite.modulestudio.metamodel.modulestudio.ManyToOneRelationship;
import de.guite.modulestudio.metamodel.modulestudio.Models;
import de.guite.modulestudio.metamodel.modulestudio.OneToManyRelationship;
import de.guite.modulestudio.metamodel.modulestudio.OneToOneRelationship;
import de.guite.modulestudio.metamodel.modulestudio.RelationFetchType;
import java.util.Arrays;
import java.util.List;
import org.eclipse.xtend2.lib.StringConcatenation;
import org.eclipse.xtext.xbase.lib.Conversions;
import org.eclipse.xtext.xbase.lib.Extension;
import org.eclipse.xtext.xbase.lib.Functions.Function0;
import org.eclipse.xtext.xbase.lib.IterableExtensions;
import org.eclipse.xtext.xbase.lib.StringExtensions;
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper;
import org.zikula.modulestudio.generator.extensions.FormattingExtensions;
import org.zikula.modulestudio.generator.extensions.ModelExtensions;
import org.zikula.modulestudio.generator.extensions.ModelJoinExtensions;
import org.zikula.modulestudio.generator.extensions.NamingExtensions;
import org.zikula.modulestudio.generator.extensions.Utils;

@SuppressWarnings("all")
public class Association {
  @Inject
  @Extension
  private FormattingExtensions _formattingExtensions = new Function0<FormattingExtensions>() {
    public FormattingExtensions apply() {
      FormattingExtensions _formattingExtensions = new FormattingExtensions();
      return _formattingExtensions;
    }
  }.apply();
  
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
  private ModelJoinExtensions _modelJoinExtensions = new Function0<ModelJoinExtensions>() {
    public ModelJoinExtensions apply() {
      ModelJoinExtensions _modelJoinExtensions = new ModelJoinExtensions();
      return _modelJoinExtensions;
    }
  }.apply();
  
  @Inject
  @Extension
  private NamingExtensions _namingExtensions = new Function0<NamingExtensions>() {
    public NamingExtensions apply() {
      NamingExtensions _namingExtensions = new NamingExtensions();
      return _namingExtensions;
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
  
  private FileHelper fh = new Function0<FileHelper>() {
    public FileHelper apply() {
      FileHelper _fileHelper = new FileHelper();
      return _fileHelper;
    }
  }.apply();
  
  /**
   * If we have an outgoing association useTarget is true; for an incoming one it is false.
   */
  public CharSequence generate(final JoinRelationship it, final Boolean useTarget) {
    CharSequence _xblockexpression = null;
    {
      String _relationAliasName = this._namingExtensions.getRelationAliasName(it, Boolean.valueOf(false));
      final String sourceName = StringExtensions.toFirstLower(_relationAliasName);
      String _relationAliasName_1 = this._namingExtensions.getRelationAliasName(it, Boolean.valueOf(true));
      final String targetName = StringExtensions.toFirstLower(_relationAliasName_1);
      Entity _xifexpression = null;
      if ((useTarget).booleanValue()) {
        Entity _target = it.getTarget();
        _xifexpression = _target;
      } else {
        Entity _source = it.getSource();
        _xifexpression = _source;
      }
      final String entityClass = this._namingExtensions.entityClassName(_xifexpression, "", Boolean.valueOf(false));
      CharSequence _directionSwitch = this.directionSwitch(it, useTarget, sourceName, targetName, entityClass);
      _xblockexpression = (_directionSwitch);
    }
    return _xblockexpression;
  }
  
  private CharSequence directionSwitch(final JoinRelationship it, final Boolean useTarget, final String sourceName, final String targetName, final String entityClass) {
    CharSequence _xifexpression = null;
    boolean _isBidirectional = it.isBidirectional();
    boolean _not = (!_isBidirectional);
    if (_not) {
      CharSequence _unidirectional = this.unidirectional(it, useTarget, sourceName, targetName, entityClass);
      _xifexpression = _unidirectional;
    } else {
      CharSequence _bidirectional = this.bidirectional(it, useTarget, sourceName, targetName, entityClass);
      _xifexpression = _bidirectional;
    }
    return _xifexpression;
  }
  
  private CharSequence unidirectional(final JoinRelationship it, final Boolean useTarget, final String sourceName, final String targetName, final String entityClass) {
    StringConcatenation _builder = new StringConcatenation();
    {
      if ((useTarget).booleanValue()) {
        CharSequence _outgoing = this.outgoing(it, sourceName, targetName, entityClass);
        _builder.append(_outgoing, "");
        _builder.newLineIfNotEmpty();
      }
    }
    return _builder;
  }
  
  private CharSequence bidirectional(final JoinRelationship it, final Boolean useTarget, final String sourceName, final String targetName, final String entityClass) {
    StringConcatenation _builder = new StringConcatenation();
    {
      boolean _not = (!(useTarget).booleanValue());
      if (_not) {
        CharSequence _incoming = this.incoming(it, sourceName, targetName, entityClass);
        _builder.append(_incoming, "");
        _builder.newLineIfNotEmpty();
      } else {
        CharSequence _outgoing = this.outgoing(it, sourceName, targetName, entityClass);
        _builder.append(_outgoing, "");
        _builder.newLineIfNotEmpty();
      }
    }
    return _builder;
  }
  
  private CharSequence _incoming(final JoinRelationship it, final String sourceName, final String targetName, final String entityClass) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Bidirectional - ");
    CharSequence _incomingMappingDescription = this.incomingMappingDescription(it, sourceName, targetName);
    _builder.append(_incomingMappingDescription, " ");
    _builder.append(".");
    _builder.newLineIfNotEmpty();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    CharSequence _incomingMappingDetails = this.incomingMappingDetails(it);
    _builder.append(_incomingMappingDetails, "");
    _builder.newLineIfNotEmpty();
    _builder.append(" ");
    _builder.append("* @ORM\\");
    String _incomingMappingType = this.incomingMappingType(it);
    _builder.append(_incomingMappingType, " ");
    _builder.append("(targetEntity=\"");
    {
      Models _container = it.getContainer();
      Application _application = _container.getApplication();
      boolean _targets = this._utils.targets(_application, "1.3.5");
      boolean _not = (!_targets);
      if (_not) {
        _builder.append("\\");
      }
    }
    _builder.append(entityClass, " ");
    _builder.append("\", inversedBy=\"");
    _builder.append(targetName, " ");
    _builder.append("\"");
    CharSequence _additionalOptions = this.additionalOptions(it, Boolean.valueOf(true));
    _builder.append(_additionalOptions, " ");
    _builder.append(")");
    _builder.newLineIfNotEmpty();
    CharSequence _joinDetails = this.joinDetails(it, Boolean.valueOf(false));
    _builder.append(_joinDetails, "");
    _builder.newLineIfNotEmpty();
    _builder.append(" ");
    _builder.append("* @var ");
    {
      Models _container_1 = it.getContainer();
      Application _application_1 = _container_1.getApplication();
      boolean _targets_1 = this._utils.targets(_application_1, "1.3.5");
      boolean _not_1 = (!_targets_1);
      if (_not_1) {
        _builder.append("\\");
      }
    }
    _builder.append(entityClass, " ");
    _builder.append(" $");
    _builder.append(sourceName, " ");
    _builder.append(".");
    _builder.newLineIfNotEmpty();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("protected $");
    _builder.append(sourceName, "");
    _builder.append(";");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence _incomingMappingDescription(final JoinRelationship it, final String sourceName, final String targetName) {
    CharSequence _switchResult = null;
    boolean _matched = false;
    if (!_matched) {
      if (it instanceof OneToOneRelationship) {
        final OneToOneRelationship _oneToOneRelationship = (OneToOneRelationship)it;
        _matched=true;
        StringConcatenation _builder = new StringConcatenation();
        _builder.append("One ");
        _builder.append(targetName, "");
        _builder.append(" [");
        Entity _target = _oneToOneRelationship.getTarget();
        String _name = _target.getName();
        String _formatForDisplay = this._formattingExtensions.formatForDisplay(_name);
        _builder.append(_formatForDisplay, "");
        _builder.append("] is linked by one ");
        _builder.append(sourceName, "");
        _builder.append(" [");
        Entity _source = _oneToOneRelationship.getSource();
        String _name_1 = _source.getName();
        String _formatForDisplay_1 = this._formattingExtensions.formatForDisplay(_name_1);
        _builder.append(_formatForDisplay_1, "");
        _builder.append("] (INVERSE SIDE)");
        _switchResult = _builder;
      }
    }
    if (!_matched) {
      if (it instanceof OneToManyRelationship) {
        final OneToManyRelationship _oneToManyRelationship = (OneToManyRelationship)it;
        _matched=true;
        StringConcatenation _builder = new StringConcatenation();
        _builder.append("Many ");
        _builder.append(targetName, "");
        _builder.append(" [");
        Entity _target = _oneToManyRelationship.getTarget();
        String _nameMultiple = _target.getNameMultiple();
        String _formatForDisplay = this._formattingExtensions.formatForDisplay(_nameMultiple);
        _builder.append(_formatForDisplay, "");
        _builder.append("] are linked by one ");
        _builder.append(sourceName, "");
        _builder.append(" [");
        Entity _source = _oneToManyRelationship.getSource();
        String _name = _source.getName();
        String _formatForDisplay_1 = this._formattingExtensions.formatForDisplay(_name);
        _builder.append(_formatForDisplay_1, "");
        _builder.append("] (OWNING SIDE)");
        _switchResult = _builder;
      }
    }
    if (!_matched) {
      _switchResult = "";
    }
    return _switchResult;
  }
  
  private CharSequence incomingMappingDetails(final JoinRelationship it) {
    CharSequence _switchResult = null;
    boolean _matched = false;
    if (!_matched) {
      if (it instanceof OneToOneRelationship) {
        final OneToOneRelationship _oneToOneRelationship = (OneToOneRelationship)it;
        boolean _isPrimaryKey = _oneToOneRelationship.isPrimaryKey();
        if (_isPrimaryKey) {
          _matched=true;
          StringConcatenation _builder = new StringConcatenation();
          _builder.append(" ");
          _builder.append("* @ORM\\Id");
          _switchResult = _builder;
        }
      }
    }
    if (!_matched) {
      _switchResult = "";
    }
    return _switchResult;
  }
  
  private String incomingMappingType(final JoinRelationship it) {
    String _switchResult = null;
    boolean _matched = false;
    if (!_matched) {
      if (it instanceof OneToOneRelationship) {
        final OneToOneRelationship _oneToOneRelationship = (OneToOneRelationship)it;
        _matched=true;
        _switchResult = "OneToOne";
      }
    }
    if (!_matched) {
      if (it instanceof OneToManyRelationship) {
        final OneToManyRelationship _oneToManyRelationship = (OneToManyRelationship)it;
        _matched=true;
        _switchResult = "ManyToOne";
      }
    }
    if (!_matched) {
      _switchResult = "";
    }
    return _switchResult;
  }
  
  private CharSequence _incoming(final ManyToOneRelationship it, final String sourceName, final String targetName, final String entityClass) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Bidirectional - ");
    CharSequence _incomingMappingDescription = this.incomingMappingDescription(it, sourceName, targetName);
    _builder.append(_incomingMappingDescription, " ");
    _builder.append(".");
    _builder.newLineIfNotEmpty();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    {
      boolean _isPrimaryKey = it.isPrimaryKey();
      if (_isPrimaryKey) {
        _builder.append(" ");
        _builder.append("* @ORM\\Id");
        _builder.newLine();
      }
    }
    _builder.append(" ");
    _builder.append("* @ORM\\OneToOne(targetEntity=\"");
    {
      Models _container = it.getContainer();
      Application _application = _container.getApplication();
      boolean _targets = this._utils.targets(_application, "1.3.5");
      boolean _not = (!_targets);
      if (_not) {
        _builder.append("\\");
      }
    }
    _builder.append(entityClass, " ");
    _builder.append("\")");
    _builder.newLineIfNotEmpty();
    CharSequence _joinDetails = this.joinDetails(it, Boolean.valueOf(false));
    _builder.append(_joinDetails, "");
    _builder.newLineIfNotEmpty();
    _builder.append(" ");
    _builder.append("* @var ");
    {
      Models _container_1 = it.getContainer();
      Application _application_1 = _container_1.getApplication();
      boolean _targets_1 = this._utils.targets(_application_1, "1.3.5");
      boolean _not_1 = (!_targets_1);
      if (_not_1) {
        _builder.append("\\");
      }
    }
    _builder.append(entityClass, " ");
    _builder.append(" $");
    _builder.append(sourceName, " ");
    _builder.append(".");
    _builder.newLineIfNotEmpty();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("protected $");
    _builder.append(sourceName, "");
    _builder.append(";");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence _incomingMappingDescription(final ManyToOneRelationship it, final String sourceName, final String targetName) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("One ");
    _builder.append(targetName, "");
    _builder.append(" [");
    Entity _target = it.getTarget();
    String _name = _target.getName();
    String _formatForDisplay = this._formattingExtensions.formatForDisplay(_name);
    _builder.append(_formatForDisplay, "");
    _builder.append("] is linked by many ");
    _builder.append(sourceName, "");
    _builder.append(" [");
    Entity _source = it.getSource();
    String _nameMultiple = _source.getNameMultiple();
    String _formatForDisplay_1 = this._formattingExtensions.formatForDisplay(_nameMultiple);
    _builder.append(_formatForDisplay_1, "");
    _builder.append("] (INVERSE SIDE)");
    return _builder;
  }
  
  private CharSequence _incoming(final ManyToManyRelationship it, final String sourceName, final String targetName, final String entityClass) {
    StringConcatenation _builder = new StringConcatenation();
    {
      boolean _isBidirectional = it.isBidirectional();
      if (_isBidirectional) {
        _builder.append("/**");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* Bidirectional - ");
        CharSequence _incomingMappingDescription = this.incomingMappingDescription(it, sourceName, targetName);
        _builder.append(_incomingMappingDescription, " ");
        _builder.append(".");
        _builder.newLineIfNotEmpty();
        _builder.append(" ");
        _builder.append("*");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* @ORM\\ManyToMany(targetEntity=\"");
        {
          Models _container = it.getContainer();
          Application _application = _container.getApplication();
          boolean _targets = this._utils.targets(_application, "1.3.5");
          boolean _not = (!_targets);
          if (_not) {
            _builder.append("\\");
          }
        }
        _builder.append(entityClass, " ");
        _builder.append("\", mappedBy=\"");
        _builder.append(targetName, " ");
        _builder.append("\"");
        CharSequence _additionalOptions = this.additionalOptions(it, Boolean.valueOf(true));
        _builder.append(_additionalOptions, " ");
        _builder.append(")");
        _builder.newLineIfNotEmpty();
        _builder.append(" ");
        _builder.append("* @var ");
        {
          Models _container_1 = it.getContainer();
          Application _application_1 = _container_1.getApplication();
          boolean _targets_1 = this._utils.targets(_application_1, "1.3.5");
          boolean _not_1 = (!_targets_1);
          if (_not_1) {
            _builder.append("\\");
          }
        }
        _builder.append(entityClass, " ");
        _builder.append("[] $");
        _builder.append(sourceName, " ");
        _builder.append(".");
        _builder.newLineIfNotEmpty();
        _builder.append(" ");
        _builder.append("*/");
        _builder.newLine();
        _builder.append("protected $");
        _builder.append(sourceName, "");
        _builder.append(" = null;");
        _builder.newLineIfNotEmpty();
      }
    }
    return _builder;
  }
  
  private CharSequence _incomingMappingDescription(final ManyToManyRelationship it, final String sourceName, final String targetName) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("Many ");
    _builder.append(targetName, "");
    _builder.append(" [");
    Entity _target = it.getTarget();
    String _nameMultiple = _target.getNameMultiple();
    String _formatForDisplay = this._formattingExtensions.formatForDisplay(_nameMultiple);
    _builder.append(_formatForDisplay, "");
    _builder.append("] are linked by many ");
    _builder.append(sourceName, "");
    _builder.append(" [");
    Entity _source = it.getSource();
    String _nameMultiple_1 = _source.getNameMultiple();
    String _formatForDisplay_1 = this._formattingExtensions.formatForDisplay(_nameMultiple_1);
    _builder.append(_formatForDisplay_1, "");
    _builder.append("] (INVERSE SIDE)");
    return _builder;
  }
  
  /**
   * This default rule is used for OneToOne and ManyToOne.
   */
  private CharSequence _outgoing(final JoinRelationship it, final String sourceName, final String targetName, final String entityClass) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* ");
    {
      boolean _isBidirectional = it.isBidirectional();
      if (_isBidirectional) {
        _builder.append("Bi");
      } else {
        _builder.append("Uni");
      }
    }
    _builder.append("directional - ");
    CharSequence _outgoingMappingDescription = this.outgoingMappingDescription(it, sourceName, targetName);
    _builder.append(_outgoingMappingDescription, " ");
    _builder.append(".");
    _builder.newLineIfNotEmpty();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @ORM\\");
    String _outgoingMappingType = this.outgoingMappingType(it);
    _builder.append(_outgoingMappingType, " ");
    _builder.append("(targetEntity=\"");
    {
      Models _container = it.getContainer();
      Application _application = _container.getApplication();
      boolean _targets = this._utils.targets(_application, "1.3.5");
      boolean _not = (!_targets);
      if (_not) {
        _builder.append("\\");
      }
    }
    _builder.append(entityClass, " ");
    _builder.append("\"");
    {
      boolean _isBidirectional_1 = it.isBidirectional();
      if (_isBidirectional_1) {
        _builder.append(", mappedBy=\"");
        _builder.append(sourceName, " ");
        _builder.append("\"");
      }
    }
    CharSequence _fetchTypeTag = this.fetchTypeTag(it);
    _builder.append(_fetchTypeTag, " ");
    CharSequence _outgoingMappingAdditions = this.outgoingMappingAdditions(it);
    _builder.append(_outgoingMappingAdditions, " ");
    _builder.append(")");
    _builder.newLineIfNotEmpty();
    CharSequence _joinDetails = this.joinDetails(it, Boolean.valueOf(true));
    _builder.append(_joinDetails, "");
    _builder.newLineIfNotEmpty();
    _builder.append(" ");
    _builder.append("* @var ");
    {
      Models _container_1 = it.getContainer();
      Application _application_1 = _container_1.getApplication();
      boolean _targets_1 = this._utils.targets(_application_1, "1.3.5");
      boolean _not_1 = (!_targets_1);
      if (_not_1) {
        _builder.append("\\");
      }
    }
    _builder.append(entityClass, " ");
    _builder.append(" $");
    _builder.append(targetName, " ");
    _builder.append(".");
    _builder.newLineIfNotEmpty();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("protected $");
    _builder.append(targetName, "");
    _builder.append(";");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence _outgoingMappingDescription(final JoinRelationship it, final String sourceName, final String targetName) {
    CharSequence _switchResult = null;
    boolean _matched = false;
    if (!_matched) {
      if (it instanceof OneToOneRelationship) {
        final OneToOneRelationship _oneToOneRelationship = (OneToOneRelationship)it;
        _matched=true;
        StringConcatenation _builder = new StringConcatenation();
        _builder.append("One ");
        _builder.append(sourceName, "");
        _builder.append(" [");
        Entity _source = _oneToOneRelationship.getSource();
        String _name = _source.getName();
        String _formatForDisplay = this._formattingExtensions.formatForDisplay(_name);
        _builder.append(_formatForDisplay, "");
        _builder.append("] has one ");
        _builder.append(targetName, "");
        _builder.append(" [");
        Entity _target = _oneToOneRelationship.getTarget();
        String _name_1 = _target.getName();
        String _formatForDisplay_1 = this._formattingExtensions.formatForDisplay(_name_1);
        _builder.append(_formatForDisplay_1, "");
        _builder.append("] (INVERSE SIDE)");
        _switchResult = _builder;
      }
    }
    if (!_matched) {
      if (it instanceof ManyToOneRelationship) {
        final ManyToOneRelationship _manyToOneRelationship = (ManyToOneRelationship)it;
        _matched=true;
        StringConcatenation _builder = new StringConcatenation();
        _builder.append("Many ");
        _builder.append(sourceName, "");
        _builder.append(" [");
        Entity _source = _manyToOneRelationship.getSource();
        String _nameMultiple = _source.getNameMultiple();
        String _formatForDisplay = this._formattingExtensions.formatForDisplay(_nameMultiple);
        _builder.append(_formatForDisplay, "");
        _builder.append("] have one ");
        _builder.append(targetName, "");
        _builder.append(" [");
        Entity _target = _manyToOneRelationship.getTarget();
        String _name = _target.getName();
        String _formatForDisplay_1 = this._formattingExtensions.formatForDisplay(_name);
        _builder.append(_formatForDisplay_1, "");
        _builder.append("] (OWNING SIDE)");
        _switchResult = _builder;
      }
    }
    if (!_matched) {
      _switchResult = "";
    }
    return _switchResult;
  }
  
  private String outgoingMappingType(final JoinRelationship it) {
    String _switchResult = null;
    boolean _matched = false;
    if (!_matched) {
      if (it instanceof OneToOneRelationship) {
        final OneToOneRelationship _oneToOneRelationship = (OneToOneRelationship)it;
        _matched=true;
        _switchResult = "OneToOne";
      }
    }
    if (!_matched) {
      if (it instanceof ManyToOneRelationship) {
        final ManyToOneRelationship _manyToOneRelationship = (ManyToOneRelationship)it;
        _matched=true;
        _switchResult = "ManyToOne";
      }
    }
    if (!_matched) {
      _switchResult = "";
    }
    return _switchResult;
  }
  
  private CharSequence _outgoingMappingAdditions(final JoinRelationship it) {
    StringConcatenation _builder = new StringConcatenation();
    return _builder;
  }
  
  private CharSequence _outgoingMappingAdditions(final OneToOneRelationship it) {
    StringConcatenation _builder = new StringConcatenation();
    {
      boolean _isOrphanRemoval = it.isOrphanRemoval();
      if (_isOrphanRemoval) {
        _builder.append(", orphanRemoval=true");
      }
    }
    return _builder;
  }
  
  private CharSequence _outgoingMappingAdditions(final OneToManyRelationship it) {
    StringConcatenation _builder = new StringConcatenation();
    {
      boolean _isOrphanRemoval = it.isOrphanRemoval();
      if (_isOrphanRemoval) {
        _builder.append(", orphanRemoval=true");
      }
    }
    {
      boolean _and = false;
      String _indexBy = it.getIndexBy();
      boolean _tripleNotEquals = (_indexBy != null);
      if (!_tripleNotEquals) {
        _and = false;
      } else {
        String _indexBy_1 = it.getIndexBy();
        boolean _notEquals = (!Objects.equal(_indexBy_1, ""));
        _and = (_tripleNotEquals && _notEquals);
      }
      if (_and) {
        _builder.append(", indexBy=\"");
        String _indexBy_2 = it.getIndexBy();
        _builder.append(_indexBy_2, "");
        _builder.append("\"");
      }
    }
    _builder.append(")");
    return _builder;
  }
  
  private CharSequence _outgoingMappingAdditions(final ManyToManyRelationship it) {
    StringConcatenation _builder = new StringConcatenation();
    {
      boolean _isOrphanRemoval = it.isOrphanRemoval();
      if (_isOrphanRemoval) {
        _builder.append(", orphanRemoval=true");
      }
    }
    {
      boolean _and = false;
      String _indexBy = it.getIndexBy();
      boolean _tripleNotEquals = (_indexBy != null);
      if (!_tripleNotEquals) {
        _and = false;
      } else {
        String _indexBy_1 = it.getIndexBy();
        boolean _notEquals = (!Objects.equal(_indexBy_1, ""));
        _and = (_tripleNotEquals && _notEquals);
      }
      if (_and) {
        _builder.append(", indexBy=\"");
        String _indexBy_2 = it.getIndexBy();
        _builder.append(_indexBy_2, "");
        _builder.append("\"");
      }
    }
    return _builder;
  }
  
  private CharSequence _outgoing(final OneToManyRelationship it, final String sourceName, final String targetName, final String entityClass) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* ");
    {
      boolean _isBidirectional = it.isBidirectional();
      if (_isBidirectional) {
        _builder.append("Bi");
      } else {
        _builder.append("Uni");
      }
    }
    _builder.append("directional - ");
    CharSequence _outgoingMappingDescription = this.outgoingMappingDescription(it, sourceName, targetName);
    _builder.append(_outgoingMappingDescription, " ");
    _builder.append(".");
    _builder.newLineIfNotEmpty();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    {
      boolean _isBidirectional_1 = it.isBidirectional();
      boolean _not = (!_isBidirectional_1);
      if (_not) {
        _builder.append(" ");
        _builder.append("* @ORM\\ManyToMany(targetEntity=\"");
        {
          Models _container = it.getContainer();
          Application _application = _container.getApplication();
          boolean _targets = this._utils.targets(_application, "1.3.5");
          boolean _not_1 = (!_targets);
          if (_not_1) {
            _builder.append("\\");
          }
        }
        _builder.append(entityClass, " ");
        _builder.append("\"");
        CharSequence _additionalOptions = this.additionalOptions(it, Boolean.valueOf(false));
        _builder.append(_additionalOptions, " ");
        _builder.append(")");
        _builder.newLineIfNotEmpty();
      } else {
        _builder.append(" ");
        _builder.append("* @ORM\\OneToMany(targetEntity=\"");
        {
          Models _container_1 = it.getContainer();
          Application _application_1 = _container_1.getApplication();
          boolean _targets_1 = this._utils.targets(_application_1, "1.3.5");
          boolean _not_2 = (!_targets_1);
          if (_not_2) {
            _builder.append("\\");
          }
        }
        _builder.append(entityClass, " ");
        _builder.append("\", mappedBy=\"");
        _builder.append(sourceName, " ");
        _builder.append("\"");
        CharSequence _additionalOptions_1 = this.additionalOptions(it, Boolean.valueOf(false));
        _builder.append(_additionalOptions_1, " ");
        CharSequence _outgoingMappingAdditions = this.outgoingMappingAdditions(it);
        _builder.append(_outgoingMappingAdditions, " ");
        _builder.newLineIfNotEmpty();
      }
    }
    CharSequence _joinDetails = this.joinDetails(it, Boolean.valueOf(true));
    _builder.append(_joinDetails, "");
    _builder.newLineIfNotEmpty();
    {
      boolean _and = false;
      String _orderBy = it.getOrderBy();
      boolean _tripleNotEquals = (_orderBy != null);
      if (!_tripleNotEquals) {
        _and = false;
      } else {
        String _orderBy_1 = it.getOrderBy();
        boolean _notEquals = (!Objects.equal(_orderBy_1, ""));
        _and = (_tripleNotEquals && _notEquals);
      }
      if (_and) {
        _builder.append(" ");
        _builder.append("* @ORM\\OrderBy({\"");
        String _orderBy_2 = it.getOrderBy();
        _builder.append(_orderBy_2, " ");
        _builder.append("\" = \"ASC\"})");
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.append(" ");
    _builder.append("* @var ");
    {
      Models _container_2 = it.getContainer();
      Application _application_2 = _container_2.getApplication();
      boolean _targets_2 = this._utils.targets(_application_2, "1.3.5");
      boolean _not_3 = (!_targets_2);
      if (_not_3) {
        _builder.append("\\");
      }
    }
    _builder.append(entityClass, " ");
    _builder.append("[] $");
    _builder.append(targetName, " ");
    _builder.append(".");
    _builder.newLineIfNotEmpty();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("protected $");
    _builder.append(targetName, "");
    _builder.append(" = null;");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence _outgoingMappingDescription(final OneToManyRelationship it, final String sourceName, final String targetName) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("One ");
    _builder.append(sourceName, "");
    _builder.append(" [");
    Entity _source = it.getSource();
    String _name = _source.getName();
    String _formatForDisplay = this._formattingExtensions.formatForDisplay(_name);
    _builder.append(_formatForDisplay, "");
    _builder.append("] has many ");
    _builder.append(targetName, "");
    _builder.append(" [");
    Entity _target = it.getTarget();
    String _nameMultiple = _target.getNameMultiple();
    String _formatForDisplay_1 = this._formattingExtensions.formatForDisplay(_nameMultiple);
    _builder.append(_formatForDisplay_1, "");
    _builder.append("] (INVERSE SIDE)");
    return _builder;
  }
  
  private CharSequence _outgoing(final ManyToManyRelationship it, final String sourceName, final String targetName, final String entityClass) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* ");
    {
      boolean _isBidirectional = it.isBidirectional();
      if (_isBidirectional) {
        _builder.append("Bi");
      } else {
        _builder.append("Uni");
      }
    }
    _builder.append("directional - ");
    CharSequence _outgoingMappingDescription = this.outgoingMappingDescription(it, sourceName, targetName);
    _builder.append(_outgoingMappingDescription, " ");
    _builder.append(".");
    _builder.newLineIfNotEmpty();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @ORM\\ManyToMany(targetEntity=\"");
    {
      Models _container = it.getContainer();
      Application _application = _container.getApplication();
      boolean _targets = this._utils.targets(_application, "1.3.5");
      boolean _not = (!_targets);
      if (_not) {
        _builder.append("\\");
      }
    }
    _builder.append(entityClass, " ");
    _builder.append("\"");
    {
      boolean _isBidirectional_1 = it.isBidirectional();
      if (_isBidirectional_1) {
        _builder.append(", inversedBy=\"");
        _builder.append(sourceName, " ");
        _builder.append("\"");
      }
    }
    CharSequence _additionalOptions = this.additionalOptions(it, Boolean.valueOf(false));
    _builder.append(_additionalOptions, " ");
    CharSequence _outgoingMappingAdditions = this.outgoingMappingAdditions(it);
    _builder.append(_outgoingMappingAdditions, " ");
    _builder.append(")");
    _builder.newLineIfNotEmpty();
    CharSequence _joinDetails = this.joinDetails(it, Boolean.valueOf(true));
    _builder.append(_joinDetails, "");
    _builder.newLineIfNotEmpty();
    {
      boolean _and = false;
      String _orderBy = it.getOrderBy();
      boolean _tripleNotEquals = (_orderBy != null);
      if (!_tripleNotEquals) {
        _and = false;
      } else {
        String _orderBy_1 = it.getOrderBy();
        boolean _notEquals = (!Objects.equal(_orderBy_1, ""));
        _and = (_tripleNotEquals && _notEquals);
      }
      if (_and) {
        _builder.append(" ");
        _builder.append("* @ORM\\OrderBy({\"");
        String _orderBy_2 = it.getOrderBy();
        _builder.append(_orderBy_2, " ");
        _builder.append("\" = \"ASC\"})");
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.append(" ");
    _builder.append("* @var ");
    {
      Models _container_1 = it.getContainer();
      Application _application_1 = _container_1.getApplication();
      boolean _targets_1 = this._utils.targets(_application_1, "1.3.5");
      boolean _not_1 = (!_targets_1);
      if (_not_1) {
        _builder.append("\\");
      }
    }
    _builder.append(entityClass, " ");
    _builder.append("[] $");
    _builder.append(targetName, " ");
    _builder.append(".");
    _builder.newLineIfNotEmpty();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("protected $");
    _builder.append(targetName, "");
    _builder.append(" = null;");
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  private CharSequence _outgoingMappingDescription(final ManyToManyRelationship it, final String sourceName, final String targetName) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("Many ");
    _builder.append(sourceName, "");
    _builder.append(" [");
    Entity _source = it.getSource();
    String _nameMultiple = _source.getNameMultiple();
    String _formatForDisplay = this._formattingExtensions.formatForDisplay(_nameMultiple);
    _builder.append(_formatForDisplay, "");
    _builder.append("] have many ");
    _builder.append(targetName, "");
    _builder.append(" [");
    Entity _target = it.getTarget();
    String _nameMultiple_1 = _target.getNameMultiple();
    String _formatForDisplay_1 = this._formattingExtensions.formatForDisplay(_nameMultiple_1);
    _builder.append(_formatForDisplay_1, "");
    _builder.append("] (OWNING SIDE)");
    return _builder;
  }
  
  private CharSequence joinDetails(final JoinRelationship it, final Boolean useTarget) {
    CharSequence _xblockexpression = null;
    {
      Entity _xifexpression = null;
      if ((useTarget).booleanValue()) {
        Entity _source = it.getSource();
        _xifexpression = _source;
      } else {
        Entity _target = it.getTarget();
        _xifexpression = _target;
      }
      final Entity joinedEntityLocal = _xifexpression;
      Entity _xifexpression_1 = null;
      if ((useTarget).booleanValue()) {
        Entity _target_1 = it.getTarget();
        _xifexpression_1 = _target_1;
      } else {
        Entity _source_1 = it.getSource();
        _xifexpression_1 = _source_1;
      }
      final Entity joinedEntityForeign = _xifexpression_1;
      String[] _xifexpression_2 = null;
      if ((useTarget).booleanValue()) {
        String[] _sourceFields = this._modelJoinExtensions.getSourceFields(it);
        _xifexpression_2 = _sourceFields;
      } else {
        String[] _targetFields = this._modelJoinExtensions.getTargetFields(it);
        _xifexpression_2 = _targetFields;
      }
      final String[] joinColumnsLocal = _xifexpression_2;
      String[] _xifexpression_3 = null;
      if ((useTarget).booleanValue()) {
        String[] _targetFields_1 = this._modelJoinExtensions.getTargetFields(it);
        _xifexpression_3 = _targetFields_1;
      } else {
        String[] _sourceFields_1 = this._modelJoinExtensions.getSourceFields(it);
        _xifexpression_3 = _sourceFields_1;
      }
      final String[] joinColumnsForeign = _xifexpression_3;
      final String foreignTableName = this._modelJoinExtensions.fullJoinTableName(it, useTarget, joinedEntityForeign);
      CharSequence _xifexpression_4 = null;
      boolean _and = false;
      boolean _and_1 = false;
      boolean _and_2 = false;
      boolean _and_3 = false;
      boolean _containsDefaultIdField = this._modelExtensions.containsDefaultIdField(((Iterable<String>)Conversions.doWrapArray(joinColumnsForeign)), joinedEntityForeign);
      if (!_containsDefaultIdField) {
        _and_3 = false;
      } else {
        boolean _containsDefaultIdField_1 = this._modelExtensions.containsDefaultIdField(((Iterable<String>)Conversions.doWrapArray(joinColumnsLocal)), joinedEntityLocal);
        _and_3 = (_containsDefaultIdField && _containsDefaultIdField_1);
      }
      if (!_and_3) {
        _and_2 = false;
      } else {
        boolean _isUnique = it.isUnique();
        boolean _not = (!_isUnique);
        _and_2 = (_and_3 && _not);
      }
      if (!_and_2) {
        _and_1 = false;
      } else {
        boolean _isNullable = it.isNullable();
        _and_1 = (_and_2 && _isNullable);
      }
      if (!_and_1) {
        _and = false;
      } else {
        String _onDelete = it.getOnDelete();
        boolean _equals = Objects.equal(_onDelete, "");
        _and = (_and_1 && _equals);
      }
      if (_and) {
        StringConcatenation _builder = new StringConcatenation();
        _builder.append(" ");
        _builder.append("* @ORM\\JoinTable(name=\"");
        _builder.append(foreignTableName, " ");
        _builder.append("\")");
        _xifexpression_4 = _builder;
      } else {
        StringConcatenation _builder_1 = new StringConcatenation();
        _builder_1.append(" ");
        _builder_1.append("* @ORM\\JoinTable(name=\"");
        _builder_1.append(foreignTableName, " ");
        _builder_1.append("\",");
        _builder_1.newLineIfNotEmpty();
        _builder_1.append("        ");
        CharSequence _joinTableDetails = this.joinTableDetails(it, useTarget);
        _builder_1.append(_joinTableDetails, "        ");
        _builder_1.newLineIfNotEmpty();
        _builder_1.append("         ");
        _builder_1.append("* )");
        _xifexpression_4 = _builder_1;
      }
      _xblockexpression = (_xifexpression_4);
    }
    return _xblockexpression;
  }
  
  private CharSequence joinTableDetails(final JoinRelationship it, final Boolean useTarget) {
    StringConcatenation _builder = new StringConcatenation();
    Entity _xifexpression = null;
    if ((useTarget).booleanValue()) {
      Entity _source = it.getSource();
      _xifexpression = _source;
    } else {
      Entity _target = it.getTarget();
      _xifexpression = _target;
    }
    final Entity joinedEntityLocal = _xifexpression;
    _builder.newLineIfNotEmpty();
    Entity _xifexpression_1 = null;
    if ((useTarget).booleanValue()) {
      Entity _target_1 = it.getTarget();
      _xifexpression_1 = _target_1;
    } else {
      Entity _source_1 = it.getSource();
      _xifexpression_1 = _source_1;
    }
    final Entity joinedEntityForeign = _xifexpression_1;
    _builder.newLineIfNotEmpty();
    String[] _xifexpression_2 = null;
    if ((useTarget).booleanValue()) {
      String[] _sourceFields = this._modelJoinExtensions.getSourceFields(it);
      _xifexpression_2 = _sourceFields;
    } else {
      String[] _targetFields = this._modelJoinExtensions.getTargetFields(it);
      _xifexpression_2 = _targetFields;
    }
    final String[] joinColumnsLocal = _xifexpression_2;
    _builder.newLineIfNotEmpty();
    String[] _xifexpression_3 = null;
    if ((useTarget).booleanValue()) {
      String[] _targetFields_1 = this._modelJoinExtensions.getTargetFields(it);
      _xifexpression_3 = _targetFields_1;
    } else {
      String[] _sourceFields_1 = this._modelJoinExtensions.getSourceFields(it);
      _xifexpression_3 = _sourceFields_1;
    }
    final String[] joinColumnsForeign = _xifexpression_3;
    _builder.newLineIfNotEmpty();
    {
      int _size = ((List<String>)Conversions.doWrapArray(joinColumnsForeign)).size();
      boolean _greaterThan = (_size > 1);
      if (_greaterThan) {
        CharSequence _joinColumnsMultiple = this.joinColumnsMultiple(it, useTarget, joinedEntityLocal, joinColumnsLocal);
        _builder.append(_joinColumnsMultiple, "");
        _builder.newLineIfNotEmpty();
      } else {
        CharSequence _joinColumnsSingle = this.joinColumnsSingle(it, useTarget, joinedEntityLocal, joinColumnsLocal);
        _builder.append(_joinColumnsSingle, "");
        _builder.newLineIfNotEmpty();
      }
    }
    {
      int _size_1 = ((List<String>)Conversions.doWrapArray(joinColumnsForeign)).size();
      boolean _greaterThan_1 = (_size_1 > 1);
      if (_greaterThan_1) {
        _builder.append(" *      inverseJoinColumns={");
        {
          boolean _hasElements = false;
          for(final String joinColumnForeign : joinColumnsForeign) {
            if (!_hasElements) {
              _hasElements = true;
            } else {
              _builder.appendImmediate(", ", "");
            }
            DerivedField _firstPrimaryKey = this._modelExtensions.getFirstPrimaryKey(joinedEntityForeign);
            String _name = _firstPrimaryKey.getName();
            String _formatForDB = this._formattingExtensions.formatForDB(_name);
            CharSequence _joinColumn = this.joinColumn(it, joinColumnForeign, _formatForDB, useTarget);
            _builder.append(_joinColumn, "");
          }
        }
        _builder.append("}");
        _builder.newLineIfNotEmpty();
      } else {
        _builder.append(" *      inverseJoinColumns={");
        String _head = IterableExtensions.<String>head(((Iterable<String>)Conversions.doWrapArray(joinColumnsForeign)));
        DerivedField _firstPrimaryKey_1 = this._modelExtensions.getFirstPrimaryKey(joinedEntityForeign);
        String _name_1 = _firstPrimaryKey_1.getName();
        String _formatForDB_1 = this._formattingExtensions.formatForDB(_name_1);
        CharSequence _joinColumn_1 = this.joinColumn(it, _head, _formatForDB_1, useTarget);
        _builder.append(_joinColumn_1, "");
        _builder.append("}");
        _builder.newLineIfNotEmpty();
      }
    }
    return _builder;
  }
  
  private CharSequence joinColumnsMultiple(final JoinRelationship it, final Boolean useTarget, final Entity joinedEntityLocal, final String[] joinColumnsLocal) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append(" ");
    _builder.append("*      joinColumns={");
    {
      boolean _hasElements = false;
      for(final String joinColumnLocal : joinColumnsLocal) {
        if (!_hasElements) {
          _hasElements = true;
        } else {
          _builder.appendImmediate(", ", " ");
        }
        DerivedField _firstPrimaryKey = this._modelExtensions.getFirstPrimaryKey(joinedEntityLocal);
        String _name = _firstPrimaryKey.getName();
        String _formatForDB = this._formattingExtensions.formatForDB(_name);
        boolean _not = (!(useTarget).booleanValue());
        CharSequence _joinColumn = this.joinColumn(it, joinColumnLocal, _formatForDB, Boolean.valueOf(_not));
        _builder.append(_joinColumn, " ");
      }
    }
    _builder.append("},");
    return _builder;
  }
  
  private CharSequence joinColumnsSingle(final JoinRelationship it, final Boolean useTarget, final Entity joinedEntityLocal, final String[] joinColumnsLocal) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append(" ");
    _builder.append("*      joinColumns={");
    String _head = IterableExtensions.<String>head(((Iterable<String>)Conversions.doWrapArray(joinColumnsLocal)));
    DerivedField _firstPrimaryKey = this._modelExtensions.getFirstPrimaryKey(joinedEntityLocal);
    String _name = _firstPrimaryKey.getName();
    String _formatForDB = this._formattingExtensions.formatForDB(_name);
    boolean _not = (!(useTarget).booleanValue());
    CharSequence _joinColumn = this.joinColumn(it, _head, _formatForDB, Boolean.valueOf(_not));
    _builder.append(_joinColumn, " ");
    _builder.append("},");
    return _builder;
  }
  
  private CharSequence joinColumn(final JoinRelationship it, final String columnName, final String referencedColumnName, final Boolean useTarget) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("@ORM\\JoinColumn(name=\"");
    String _joinColumnName = this.joinColumnName(it, columnName, useTarget);
    _builder.append(_joinColumnName, "");
    _builder.append("\", referencedColumnName=\"");
    _builder.append(referencedColumnName, "");
    _builder.append("\" ");
    {
      boolean _isUnique = it.isUnique();
      if (_isUnique) {
        _builder.append(", unique=true");
      }
    }
    {
      boolean _isNullable = it.isNullable();
      boolean _not = (!_isNullable);
      if (_not) {
        _builder.append(", nullable=false");
      }
    }
    {
      String _onDelete = it.getOnDelete();
      boolean _notEquals = (!Objects.equal(_onDelete, ""));
      if (_notEquals) {
        _builder.append(", onDelete=\"");
        String _onDelete_1 = it.getOnDelete();
        _builder.append(_onDelete_1, "");
        _builder.append("\"");
      }
    }
    _builder.append(")");
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  private String joinColumnName(final JoinRelationship it, final String columnName, final Boolean useTarget) {
    String _switchResult = null;
    boolean _matched = false;
    if (!_matched) {
      if (it instanceof ManyToManyRelationship) {
        final ManyToManyRelationship _manyToManyRelationship = (ManyToManyRelationship)it;
        boolean _equals = Objects.equal(columnName, "id");
        if (_equals) {
          _matched=true;
          Entity _xifexpression = null;
          if ((useTarget).booleanValue()) {
            Entity _target = _manyToManyRelationship.getTarget();
            _xifexpression = _target;
          } else {
            Entity _source = _manyToManyRelationship.getSource();
            _xifexpression = _source;
          }
          String _name = _xifexpression.getName();
          String _formatForDB = this._formattingExtensions.formatForDB(_name);
          String _plus = (_formatForDB + "_id");
          _switchResult = _plus;
        }
      }
    }
    if (!_matched) {
      _switchResult = columnName;
    }
    return _switchResult;
  }
  
  private CharSequence additionalOptions(final JoinRelationship it, final Boolean useReverse) {
    StringConcatenation _builder = new StringConcatenation();
    CharSequence _cascadeOptions = this.cascadeOptions(it, useReverse);
    _builder.append(_cascadeOptions, "");
    CharSequence _fetchTypeTag = this.fetchTypeTag(it);
    _builder.append(_fetchTypeTag, "");
    return _builder;
  }
  
  private CharSequence cascadeOptions(final JoinRelationship it, final Boolean useReverse) {
    CharSequence _xblockexpression = null;
    {
      CascadeType _xifexpression = null;
      if ((useReverse).booleanValue()) {
        CascadeType _cascadeReverse = it.getCascadeReverse();
        _xifexpression = _cascadeReverse;
      } else {
        CascadeType _cascade = it.getCascade();
        _xifexpression = _cascade;
      }
      final CascadeType cascadeProperty = _xifexpression;
      CharSequence _xifexpression_1 = null;
      boolean _equals = Objects.equal(cascadeProperty, CascadeType.NONE);
      if (_equals) {
        _xifexpression_1 = "";
      } else {
        StringConcatenation _builder = new StringConcatenation();
        _builder.append(", cascade={");
        String _cascadeOptionsImpl = this.cascadeOptionsImpl(it, useReverse);
        _builder.append(_cascadeOptionsImpl, "");
        _builder.append("}");
        _xifexpression_1 = _builder;
      }
      _xblockexpression = (_xifexpression_1);
    }
    return _xblockexpression;
  }
  
  private CharSequence fetchTypeTag(final JoinRelationship it) {
    CharSequence _xifexpression = null;
    RelationFetchType _fetchType = it.getFetchType();
    boolean _notEquals = (!Objects.equal(_fetchType, RelationFetchType.LAZY));
    if (_notEquals) {
      StringConcatenation _builder = new StringConcatenation();
      _builder.append(", fetch=\"");
      RelationFetchType _fetchType_1 = it.getFetchType();
      String _asConstant = this._modelJoinExtensions.asConstant(_fetchType_1);
      _builder.append(_asConstant, "");
      _builder.append("\"");
      _xifexpression = _builder;
    }
    return _xifexpression;
  }
  
  private String cascadeOptionsImpl(final JoinRelationship it, final Boolean useReverse) {
    String _xblockexpression = null;
    {
      CascadeType _xifexpression = null;
      if ((useReverse).booleanValue()) {
        CascadeType _cascadeReverse = it.getCascadeReverse();
        _xifexpression = _cascadeReverse;
      } else {
        CascadeType _cascade = it.getCascade();
        _xifexpression = _cascade;
      }
      final CascadeType cascadeProperty = _xifexpression;
      String _xifexpression_1 = null;
      boolean _equals = Objects.equal(cascadeProperty, CascadeType.PERSIST);
      if (_equals) {
        _xifexpression_1 = "\"persist\"";
      } else {
        String _xifexpression_2 = null;
        boolean _equals_1 = Objects.equal(cascadeProperty, CascadeType.REMOVE);
        if (_equals_1) {
          _xifexpression_2 = "\"remove\"";
        } else {
          String _xifexpression_3 = null;
          boolean _equals_2 = Objects.equal(cascadeProperty, CascadeType.MERGE);
          if (_equals_2) {
            _xifexpression_3 = "\"merge\"";
          } else {
            String _xifexpression_4 = null;
            boolean _equals_3 = Objects.equal(cascadeProperty, CascadeType.DETACH);
            if (_equals_3) {
              _xifexpression_4 = "\"detach\"";
            } else {
              String _xifexpression_5 = null;
              boolean _equals_4 = Objects.equal(cascadeProperty, CascadeType.PERSIST_REMOVE);
              if (_equals_4) {
                _xifexpression_5 = "\"persist\", \"remove\"";
              } else {
                String _xifexpression_6 = null;
                boolean _equals_5 = Objects.equal(cascadeProperty, CascadeType.PERSIST_MERGE);
                if (_equals_5) {
                  _xifexpression_6 = "\"persist\", \"merge\"";
                } else {
                  String _xifexpression_7 = null;
                  boolean _equals_6 = Objects.equal(cascadeProperty, CascadeType.PERSIST_DETACH);
                  if (_equals_6) {
                    _xifexpression_7 = "\"persist\", \"detach\"";
                  } else {
                    String _xifexpression_8 = null;
                    boolean _equals_7 = Objects.equal(cascadeProperty, CascadeType.REMOVE_MERGE);
                    if (_equals_7) {
                      _xifexpression_8 = "\"remove\", \"merge\"";
                    } else {
                      String _xifexpression_9 = null;
                      boolean _equals_8 = Objects.equal(cascadeProperty, CascadeType.REMOVE_DETACH);
                      if (_equals_8) {
                        _xifexpression_9 = "\"remove\", \"detach\"";
                      } else {
                        String _xifexpression_10 = null;
                        boolean _equals_9 = Objects.equal(cascadeProperty, CascadeType.MERGE_DETACH);
                        if (_equals_9) {
                          _xifexpression_10 = "\"merge\", \"detach\"";
                        } else {
                          String _xifexpression_11 = null;
                          boolean _equals_10 = Objects.equal(cascadeProperty, CascadeType.PERSIST_REMOVE_MERGE);
                          if (_equals_10) {
                            _xifexpression_11 = "\"persist\", \"remove\", \"merge\"";
                          } else {
                            String _xifexpression_12 = null;
                            boolean _equals_11 = Objects.equal(cascadeProperty, CascadeType.PERSIST_REMOVE_DETACH);
                            if (_equals_11) {
                              _xifexpression_12 = "\"persist\", \"remove\", \"detach\"";
                            } else {
                              String _xifexpression_13 = null;
                              boolean _equals_12 = Objects.equal(cascadeProperty, CascadeType.PERSIST_MERGE_DETACH);
                              if (_equals_12) {
                                _xifexpression_13 = "\"persist\", \"merge\", \"detach\"";
                              } else {
                                String _xifexpression_14 = null;
                                boolean _equals_13 = Objects.equal(cascadeProperty, CascadeType.REMOVE_MERGE_DETACH);
                                if (_equals_13) {
                                  _xifexpression_14 = "\"remove\", \"merge\", \"detach\"";
                                } else {
                                  String _xifexpression_15 = null;
                                  boolean _equals_14 = Objects.equal(cascadeProperty, CascadeType.ALL);
                                  if (_equals_14) {
                                    _xifexpression_15 = "\"all\"";
                                  }
                                  _xifexpression_14 = _xifexpression_15;
                                }
                                _xifexpression_13 = _xifexpression_14;
                              }
                              _xifexpression_12 = _xifexpression_13;
                            }
                            _xifexpression_11 = _xifexpression_12;
                          }
                          _xifexpression_10 = _xifexpression_11;
                        }
                        _xifexpression_9 = _xifexpression_10;
                      }
                      _xifexpression_8 = _xifexpression_9;
                    }
                    _xifexpression_7 = _xifexpression_8;
                  }
                  _xifexpression_6 = _xifexpression_7;
                }
                _xifexpression_5 = _xifexpression_6;
              }
              _xifexpression_4 = _xifexpression_5;
            }
            _xifexpression_3 = _xifexpression_4;
          }
          _xifexpression_2 = _xifexpression_3;
        }
        _xifexpression_1 = _xifexpression_2;
      }
      _xblockexpression = (_xifexpression_1);
    }
    return _xblockexpression;
  }
  
  public CharSequence initCollections(final Entity it) {
    StringConcatenation _builder = new StringConcatenation();
    {
      Iterable<JoinRelationship> _outgoingCollections = this._modelJoinExtensions.getOutgoingCollections(it);
      for(final JoinRelationship relation : _outgoingCollections) {
        CharSequence _initCollection = this.initCollection(relation, Boolean.valueOf(true));
        _builder.append(_initCollection, "");
      }
    }
    _builder.newLineIfNotEmpty();
    {
      Iterable<JoinRelationship> _incomingCollections = this._modelJoinExtensions.getIncomingCollections(it);
      for(final JoinRelationship relation_1 : _incomingCollections) {
        CharSequence _initCollection_1 = this.initCollection(relation_1, Boolean.valueOf(false));
        _builder.append(_initCollection_1, "");
      }
    }
    _builder.newLineIfNotEmpty();
    {
      boolean _isAttributable = it.isAttributable();
      if (_isAttributable) {
        _builder.append("$this->attributes = new ArrayCollection();");
        _builder.newLine();
      }
    }
    {
      boolean _isCategorisable = it.isCategorisable();
      if (_isCategorisable) {
        _builder.append("$this->categories = new ArrayCollection();");
        _builder.newLine();
      }
    }
    return _builder;
  }
  
  private CharSequence initCollection(final JoinRelationship it, final Boolean outgoing) {
    StringConcatenation _builder = new StringConcatenation();
    {
      boolean _isManySide = this._modelJoinExtensions.isManySide(it, (outgoing).booleanValue());
      if (_isManySide) {
        _builder.append("$this->");
        String _relationAliasName = this._namingExtensions.getRelationAliasName(it, outgoing);
        _builder.append(_relationAliasName, "");
        _builder.append(" = new ArrayCollection();");
        _builder.newLineIfNotEmpty();
      }
    }
    return _builder;
  }
  
  public CharSequence relationAccessor(final JoinRelationship it, final Boolean useTarget) {
    StringConcatenation _builder = new StringConcatenation();
    final String relationAliasName = this._namingExtensions.getRelationAliasName(it, useTarget);
    _builder.newLineIfNotEmpty();
    CharSequence _relationAccessorImpl = this.relationAccessorImpl(it, useTarget, relationAliasName);
    _builder.append(_relationAccessorImpl, "");
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  private CharSequence relationAccessorImpl(final JoinRelationship it, final Boolean useTarget, final String aliasName) {
    StringConcatenation _builder = new StringConcatenation();
    Entity _xifexpression = null;
    if ((useTarget).booleanValue()) {
      Entity _target = it.getTarget();
      _xifexpression = _target;
    } else {
      Entity _source = it.getSource();
      _xifexpression = _source;
    }
    String _entityClassName = this._namingExtensions.entityClassName(_xifexpression, "", Boolean.valueOf(false));
    final String entityClass = _entityClassName;
    _builder.newLineIfNotEmpty();
    Entity _xifexpression_1 = null;
    if ((useTarget).booleanValue()) {
      Entity _target_1 = it.getTarget();
      _xifexpression_1 = _target_1;
    } else {
      Entity _source_1 = it.getSource();
      _xifexpression_1 = _source_1;
    }
    String _name = _xifexpression_1.getName();
    final String nameSingle = _name;
    _builder.newLineIfNotEmpty();
    final boolean isMany = this._modelJoinExtensions.isManySide(it, (useTarget).booleanValue());
    _builder.newLineIfNotEmpty();
    {
      if (isMany) {
        String _xifexpression_2 = null;
        Models _container = it.getContainer();
        Application _application = _container.getApplication();
        boolean _targets = this._utils.targets(_application, "1.3.5");
        boolean _not = (!_targets);
        if (_not) {
          _xifexpression_2 = "\\";
        }
        String _plus = (_xifexpression_2 + entityClass);
        CharSequence _relationSetterCustomImpl = this.relationSetterCustomImpl(it, useTarget, aliasName);
        CharSequence _terAndSetterMethods = this.fh.getterAndSetterMethods(it, aliasName, _plus, Boolean.valueOf(true), Boolean.valueOf(false), "", _relationSetterCustomImpl);
        _builder.append(_terAndSetterMethods, "");
        _builder.newLineIfNotEmpty();
        CharSequence _relationAccessorAdditions = this.relationAccessorAdditions(it, useTarget, aliasName, nameSingle);
        _builder.append(_relationAccessorAdditions, "");
        _builder.newLineIfNotEmpty();
      } else {
        String _xifexpression_3 = null;
        Models _container_1 = it.getContainer();
        Application _application_1 = _container_1.getApplication();
        boolean _targets_1 = this._utils.targets(_application_1, "1.3.5");
        boolean _not_1 = (!_targets_1);
        if (_not_1) {
          _xifexpression_3 = "\\";
        }
        String _plus_1 = (_xifexpression_3 + entityClass);
        CharSequence _relationSetterCustomImpl_1 = this.relationSetterCustomImpl(it, useTarget, aliasName);
        CharSequence _terAndSetterMethods_1 = this.fh.getterAndSetterMethods(it, aliasName, _plus_1, Boolean.valueOf(false), Boolean.valueOf(true), "null", _relationSetterCustomImpl_1);
        _builder.append(_terAndSetterMethods_1, "");
        _builder.newLineIfNotEmpty();
      }
    }
    {
      if (isMany) {
        CharSequence _addMethod = this.addMethod(it, useTarget, Boolean.valueOf(isMany), aliasName, nameSingle, entityClass);
        _builder.append(_addMethod, "");
        _builder.newLineIfNotEmpty();
        CharSequence _removeMethod = this.removeMethod(it, useTarget, Boolean.valueOf(isMany), aliasName, nameSingle, entityClass);
        _builder.append(_removeMethod, "");
        _builder.newLineIfNotEmpty();
      }
    }
    return _builder;
  }
  
  private CharSequence relationSetterCustomImpl(final JoinRelationship it, final Boolean useTarget, final String aliasName) {
    StringConcatenation _builder = new StringConcatenation();
    final boolean otherIsMany = this._modelJoinExtensions.isManySide(it, (useTarget).booleanValue());
    _builder.newLineIfNotEmpty();
    {
      if (otherIsMany) {
        Entity _xifexpression = null;
        if ((useTarget).booleanValue()) {
          Entity _target = it.getTarget();
          _xifexpression = _target;
        } else {
          Entity _source = it.getSource();
          _xifexpression = _source;
        }
        String _name = _xifexpression.getName();
        String _plus = (_name + "Single");
        final String nameSingle = _plus;
        _builder.newLineIfNotEmpty();
        _builder.append("foreach ($");
        _builder.append(aliasName, "");
        _builder.append(" as $");
        _builder.append(nameSingle, "");
        _builder.append(") {");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("$this->add");
        String _firstUpper = StringExtensions.toFirstUpper(aliasName);
        _builder.append(_firstUpper, "    ");
        _builder.append("($");
        _builder.append(nameSingle, "    ");
        _builder.append(");");
        _builder.newLineIfNotEmpty();
        _builder.append("}");
        _builder.newLine();
      } else {
        _builder.append("$this->");
        String _formatForCode = this._formattingExtensions.formatForCode(aliasName);
        _builder.append(_formatForCode, "");
        _builder.append(" = $");
        _builder.append(aliasName, "");
        _builder.append(";");
        _builder.newLineIfNotEmpty();
        boolean _and = false;
        boolean _isBidirectional = it.isBidirectional();
        if (!_isBidirectional) {
          _and = false;
        } else {
          boolean _or = false;
          boolean _and_1 = false;
          boolean _isManyToMany = this.isManyToMany(it);
          boolean _not = (!_isManyToMany);
          if (!_not) {
            _and_1 = false;
          } else {
            _and_1 = (_not && (useTarget).booleanValue());
          }
          if (_and_1) {
            _or = true;
          } else {
            boolean _and_2 = false;
            boolean _isManyToMany_1 = this.isManyToMany(it);
            if (!_isManyToMany_1) {
              _and_2 = false;
            } else {
              boolean _not_1 = (!(useTarget).booleanValue());
              _and_2 = (_isManyToMany_1 && _not_1);
            }
            _or = (_and_1 || _and_2);
          }
          _and = (_isBidirectional && _or);
        }
        final boolean generateInverseCalls = _and;
        _builder.newLineIfNotEmpty();
        {
          if (generateInverseCalls) {
            boolean _not_2 = (!(useTarget).booleanValue());
            String _relationAliasName = this._namingExtensions.getRelationAliasName(it, Boolean.valueOf(_not_2));
            final String ownAliasName = StringExtensions.toFirstUpper(_relationAliasName);
            _builder.newLineIfNotEmpty();
            _builder.append("$");
            _builder.append(aliasName, "");
            _builder.append("->set");
            _builder.append(ownAliasName, "");
            _builder.append("($this);");
            _builder.newLineIfNotEmpty();
          }
        }
      }
    }
    return _builder;
  }
  
  private CharSequence _relationAccessorAdditions(final JoinRelationship it, final Boolean useTarget, final String aliasName, final String singleName) {
    StringConcatenation _builder = new StringConcatenation();
    return _builder;
  }
  
  private CharSequence _relationAccessorAdditions(final OneToManyRelationship it, final Boolean useTarget, final String aliasName, final String singleName) {
    StringConcatenation _builder = new StringConcatenation();
    {
      boolean _and = false;
      boolean _and_1 = false;
      boolean _not = (!(useTarget).booleanValue());
      if (!_not) {
        _and_1 = false;
      } else {
        String _indexBy = it.getIndexBy();
        boolean _tripleNotEquals = (_indexBy != null);
        _and_1 = (_not && _tripleNotEquals);
      }
      if (!_and_1) {
        _and = false;
      } else {
        String _indexBy_1 = it.getIndexBy();
        boolean _notEquals = (!Objects.equal(_indexBy_1, ""));
        _and = (_and_1 && _notEquals);
      }
      if (_and) {
        _builder.append("/**");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* Returns an instance of ");
        Entity _source = it.getSource();
        String _entityClassName = this._namingExtensions.entityClassName(_source, "", Boolean.valueOf(false));
        _builder.append(_entityClassName, " ");
        _builder.append(" from the list of ");
        String _relationAliasName = this._namingExtensions.getRelationAliasName(it, useTarget);
        _builder.append(_relationAliasName, " ");
        _builder.append(" by its given ");
        String _indexBy_2 = it.getIndexBy();
        String _formatForDisplay = this._formattingExtensions.formatForDisplay(_indexBy_2);
        _builder.append(_formatForDisplay, " ");
        _builder.append(" index.");
        _builder.newLineIfNotEmpty();
        _builder.append(" ");
        _builder.append("*");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* @param ");
        Entity _source_1 = it.getSource();
        String _entityClassName_1 = this._namingExtensions.entityClassName(_source_1, "", Boolean.valueOf(false));
        _builder.append(_entityClassName_1, " ");
        _builder.append(" $");
        String _indexBy_3 = it.getIndexBy();
        String _formatForCode = this._formattingExtensions.formatForCode(_indexBy_3);
        _builder.append(_formatForCode, " ");
        _builder.append(".");
        _builder.newLineIfNotEmpty();
        _builder.append(" ");
        _builder.append("*/");
        _builder.newLine();
        _builder.append("public function get");
        String _formatForCodeCapital = this._formattingExtensions.formatForCodeCapital(singleName);
        _builder.append(_formatForCodeCapital, "");
        _builder.append("($");
        String _indexBy_4 = it.getIndexBy();
        String _formatForCode_1 = this._formattingExtensions.formatForCode(_indexBy_4);
        _builder.append(_formatForCode_1, "");
        _builder.append(")");
        _builder.newLineIfNotEmpty();
        _builder.append("{");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("if (!isset($this->");
        String _formatForCode_2 = this._formattingExtensions.formatForCode(aliasName);
        _builder.append(_formatForCode_2, "    ");
        _builder.append("[$");
        String _indexBy_5 = it.getIndexBy();
        String _formatForCode_3 = this._formattingExtensions.formatForCode(_indexBy_5);
        _builder.append(_formatForCode_3, "    ");
        _builder.append("])) {");
        _builder.newLineIfNotEmpty();
        _builder.append("        ");
        _builder.append("throw new \\InvalidArgumentException(\"");
        String _indexBy_6 = it.getIndexBy();
        String _formatForDisplayCapital = this._formattingExtensions.formatForDisplayCapital(_indexBy_6);
        _builder.append(_formatForDisplayCapital, "        ");
        _builder.append(" is not available on this list of ");
        String _formatForDisplay_1 = this._formattingExtensions.formatForDisplay(aliasName);
        _builder.append(_formatForDisplay_1, "        ");
        _builder.append(".\");");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("}");
        _builder.newLine();
        _builder.newLine();
        _builder.append("    ");
        _builder.append("return $this->");
        String _formatForCode_4 = this._formattingExtensions.formatForCode(aliasName);
        _builder.append(_formatForCode_4, "    ");
        _builder.append("[$");
        String _indexBy_7 = it.getIndexBy();
        String _formatForCode_5 = this._formattingExtensions.formatForCode(_indexBy_7);
        _builder.append(_formatForCode_5, "    ");
        _builder.append("];");
        _builder.newLineIfNotEmpty();
        _builder.append("}");
        _builder.newLine();
        _builder.newLine();
      }
    }
    return _builder;
  }
  
  private CharSequence addMethod(final JoinRelationship it, final Boolean useTarget, final Boolean selfIsMany, final String name, final String nameSingle, final String type) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Adds an instance of ");
    {
      Models _container = it.getContainer();
      Application _application = _container.getApplication();
      boolean _targets = this._utils.targets(_application, "1.3.5");
      boolean _not = (!_targets);
      if (_not) {
        _builder.append("\\");
      }
    }
    _builder.append(type, " ");
    _builder.append(" to the list of ");
    String _formatForDisplay = this._formattingExtensions.formatForDisplay(name);
    _builder.append(_formatForDisplay, " ");
    _builder.append(".");
    _builder.newLineIfNotEmpty();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param ");
    CharSequence _addParameters = this.addParameters(it, useTarget, nameSingle, type);
    _builder.append(_addParameters, " ");
    _builder.append(" The instance to be added to the collection.");
    _builder.newLineIfNotEmpty();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @return void");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("public function add");
    String _firstUpper = StringExtensions.toFirstUpper(name);
    _builder.append(_firstUpper, "");
    _builder.append("(");
    CharSequence _addParameters_1 = this.addParameters(it, useTarget, nameSingle, type);
    _builder.append(_addParameters_1, "");
    _builder.append(")");
    _builder.newLineIfNotEmpty();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    CharSequence _addAssignment = this.addAssignment(it, useTarget, selfIsMany, name, nameSingle);
    _builder.append(_addAssignment, "    ");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    boolean _and = false;
    boolean _isBidirectional = it.isBidirectional();
    if (!_isBidirectional) {
      _and = false;
    } else {
      boolean _or = false;
      boolean _and_1 = false;
      boolean _isManyToMany = this.isManyToMany(it);
      boolean _not_1 = (!_isManyToMany);
      if (!_not_1) {
        _and_1 = false;
      } else {
        _and_1 = (_not_1 && (useTarget).booleanValue());
      }
      if (_and_1) {
        _or = true;
      } else {
        boolean _and_2 = false;
        boolean _isManyToMany_1 = this.isManyToMany(it);
        if (!_isManyToMany_1) {
          _and_2 = false;
        } else {
          boolean _not_2 = (!(useTarget).booleanValue());
          _and_2 = (_isManyToMany_1 && _not_2);
        }
        _or = (_and_1 || _and_2);
      }
      _and = (_isBidirectional && _or);
    }
    final boolean generateInverseCalls = _and;
    _builder.newLineIfNotEmpty();
    {
      if (generateInverseCalls) {
        _builder.append("    ");
        boolean _not_3 = (!(useTarget).booleanValue());
        String _relationAliasName = this._namingExtensions.getRelationAliasName(it, Boolean.valueOf(_not_3));
        final String ownAliasName = StringExtensions.toFirstUpper(_relationAliasName);
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        boolean _not_4 = (!(useTarget).booleanValue());
        final boolean otherIsMany = this._modelJoinExtensions.isManySide(it, _not_4);
        _builder.newLineIfNotEmpty();
        {
          if (otherIsMany) {
            _builder.append("    ");
            _builder.append("$");
            _builder.append(nameSingle, "    ");
            _builder.append("->add");
            _builder.append(ownAliasName, "    ");
            _builder.append("($this);");
            _builder.newLineIfNotEmpty();
          } else {
            _builder.append("    ");
            _builder.append("$");
            _builder.append(nameSingle, "    ");
            _builder.append("->set");
            _builder.append(ownAliasName, "    ");
            _builder.append("($this);");
            _builder.newLineIfNotEmpty();
          }
        }
      }
    }
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    return _builder;
  }
  
  private boolean isManyToMany(final JoinRelationship it) {
    boolean _switchResult = false;
    boolean _matched = false;
    if (!_matched) {
      if (it instanceof ManyToManyRelationship) {
        final ManyToManyRelationship _manyToManyRelationship = (ManyToManyRelationship)it;
        _matched=true;
        _switchResult = true;
      }
    }
    if (!_matched) {
      _switchResult = false;
    }
    return _switchResult;
  }
  
  private CharSequence _addParameters(final JoinRelationship it, final Boolean useTarget, final String name, final String type) {
    StringConcatenation _builder = new StringConcatenation();
    {
      Models _container = it.getContainer();
      Application _application = _container.getApplication();
      boolean _targets = this._utils.targets(_application, "1.3.5");
      boolean _not = (!_targets);
      if (_not) {
        _builder.append("\\");
      }
    }
    _builder.append(type, "");
    _builder.append(" $");
    _builder.append(name, "");
    return _builder;
  }
  
  private CharSequence _addParameters(final OneToManyRelationship it, final Boolean useTarget, final String name, final String type) {
    StringConcatenation _builder = new StringConcatenation();
    {
      boolean _and = false;
      boolean _not = (!(useTarget).booleanValue());
      if (!_not) {
        _and = false;
      } else {
        Entity _source = it.getSource();
        Iterable<IntegerField> _aggregateFields = this._modelExtensions.getAggregateFields(_source);
        boolean _isEmpty = IterableExtensions.isEmpty(_aggregateFields);
        boolean _not_1 = (!_isEmpty);
        _and = (_not && _not_1);
      }
      if (_and) {
        Entity _source_1 = it.getSource();
        Iterable<IntegerField> _aggregateFields_1 = this._modelExtensions.getAggregateFields(_source_1);
        IntegerField _head = IterableExtensions.<IntegerField>head(_aggregateFields_1);
        final DerivedField targetField = this._modelJoinExtensions.getAggregateTargetField(_head);
        _builder.newLineIfNotEmpty();
        {
          Models _container = it.getContainer();
          Application _application = _container.getApplication();
          boolean _targets = this._utils.targets(_application, "1.3.5");
          boolean _not_2 = (!_targets);
          if (_not_2) {
            _builder.append("\\");
          }
        }
        String _fieldTypeAsString = this._modelExtensions.fieldTypeAsString(targetField);
        _builder.append(_fieldTypeAsString, "");
        _builder.append(" $");
        String _name = targetField.getName();
        String _formatForCode = this._formattingExtensions.formatForCode(_name);
        _builder.append(_formatForCode, "");
        _builder.newLineIfNotEmpty();
        _builder.append("        ");
      } else {
        {
          Models _container_1 = it.getContainer();
          Application _application_1 = _container_1.getApplication();
          boolean _targets_1 = this._utils.targets(_application_1, "1.3.5");
          boolean _not_3 = (!_targets_1);
          if (_not_3) {
            _builder.append("\\");
          }
        }
        _builder.append(type, "");
        _builder.append(" $");
        _builder.append(name, "");
      }
    }
    return _builder;
  }
  
  private CharSequence addAssignmentDefault(final JoinRelationship it, final Boolean selfIsMany, final Boolean useTarget, final String name, final String nameSingle) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("$this->");
    _builder.append(name, "");
    {
      if ((selfIsMany).booleanValue()) {
        _builder.append("->add(");
      } else {
        _builder.append(" = ");
      }
    }
    _builder.append("$");
    _builder.append(nameSingle, "");
    {
      if ((selfIsMany).booleanValue()) {
        _builder.append(")");
      }
    }
    _builder.append(";");
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  private CharSequence _addAssignment(final JoinRelationship it, final Boolean selfIsMany, final Boolean useTarget, final String name, final String nameSingle) {
    StringConcatenation _builder = new StringConcatenation();
    CharSequence _addAssignmentDefault = this.addAssignmentDefault(it, useTarget, selfIsMany, name, nameSingle);
    _builder.append(_addAssignmentDefault, "");
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  private CharSequence _addAssignment(final OneToManyRelationship it, final Boolean selfIsMany, final Boolean useTarget, final String name, final String nameSingle) {
    StringConcatenation _builder = new StringConcatenation();
    {
      boolean _and = false;
      boolean _and_1 = false;
      boolean _not = (!(useTarget).booleanValue());
      if (!_not) {
        _and_1 = false;
      } else {
        String _indexBy = it.getIndexBy();
        boolean _tripleNotEquals = (_indexBy != null);
        _and_1 = (_not && _tripleNotEquals);
      }
      if (!_and_1) {
        _and = false;
      } else {
        String _indexBy_1 = it.getIndexBy();
        boolean _notEquals = (!Objects.equal(_indexBy_1, ""));
        _and = (_and_1 && _notEquals);
      }
      if (_and) {
        _builder.append("$this->");
        _builder.append(name, "");
        _builder.append("[$");
        _builder.append(nameSingle, "");
        _builder.append("->get");
        String _indexBy_2 = it.getIndexBy();
        String _formatForCodeCapital = this._formattingExtensions.formatForCodeCapital(_indexBy_2);
        _builder.append(_formatForCodeCapital, "");
        _builder.append("()] = $");
        _builder.append(nameSingle, "");
        _builder.append(";");
        _builder.newLineIfNotEmpty();
      } else {
        boolean _and_2 = false;
        boolean _not_1 = (!(useTarget).booleanValue());
        if (!_not_1) {
          _and_2 = false;
        } else {
          Entity _source = it.getSource();
          Iterable<IntegerField> _aggregateFields = this._modelExtensions.getAggregateFields(_source);
          boolean _isEmpty = IterableExtensions.isEmpty(_aggregateFields);
          boolean _not_2 = (!_isEmpty);
          _and_2 = (_not_1 && _not_2);
        }
        if (_and_2) {
          Entity _source_1 = it.getSource();
          Iterable<IntegerField> _aggregateFields_1 = this._modelExtensions.getAggregateFields(_source_1);
          final IntegerField sourceField = IterableExtensions.<IntegerField>head(_aggregateFields_1);
          _builder.newLineIfNotEmpty();
          final DerivedField targetField = this._modelJoinExtensions.getAggregateTargetField(sourceField);
          _builder.newLineIfNotEmpty();
          _builder.append("$");
          String _relationAliasName = this._namingExtensions.getRelationAliasName(it, Boolean.valueOf(true));
          _builder.append(_relationAliasName, "");
          _builder.append(" = new ");
          Entity _target = it.getTarget();
          String _entityClassName = this._namingExtensions.entityClassName(_target, "", Boolean.valueOf(false));
          _builder.append(_entityClassName, "");
          _builder.append("($this, $");
          String _name = targetField.getName();
          String _formatForCode = this._formattingExtensions.formatForCode(_name);
          _builder.append(_formatForCode, "");
          _builder.append(");");
          _builder.newLineIfNotEmpty();
          _builder.append("$this->");
          _builder.append(name, "");
          {
            if ((selfIsMany).booleanValue()) {
              _builder.append("[]");
            }
          }
          _builder.append(" = $");
          _builder.append(nameSingle, "");
          _builder.append(";");
          _builder.newLineIfNotEmpty();
          _builder.append("$this->");
          String _name_1 = sourceField.getName();
          String _formatForCode_1 = this._formattingExtensions.formatForCode(_name_1);
          _builder.append(_formatForCode_1, "");
          _builder.append(" += $");
          String _name_2 = targetField.getName();
          String _formatForCode_2 = this._formattingExtensions.formatForCode(_name_2);
          _builder.append(_formatForCode_2, "");
          _builder.append(";");
          _builder.newLineIfNotEmpty();
          _builder.append("return $");
          String _relationAliasName_1 = this._namingExtensions.getRelationAliasName(it, Boolean.valueOf(true));
          _builder.append(_relationAliasName_1, "");
          _builder.append(";");
          _builder.newLineIfNotEmpty();
          _builder.append("        ");
          _builder.append("}");
          _builder.newLine();
          _builder.newLine();
          _builder.append("        ");
          _builder.append("/**");
          _builder.newLine();
          _builder.append("         ");
          _builder.append("* Additional add function for internal use.");
          _builder.newLine();
          _builder.append("         ");
          _builder.append("*");
          _builder.newLine();
          _builder.append("         ");
          _builder.append("* @param ");
          String _fieldTypeAsString = this._modelExtensions.fieldTypeAsString(targetField);
          _builder.append(_fieldTypeAsString, "         ");
          _builder.append(" $");
          String _name_3 = targetField.getName();
          String _formatForCode_3 = this._formattingExtensions.formatForCode(_name_3);
          _builder.append(_formatForCode_3, "         ");
          _builder.append(" Given instance to be used for aggregation.");
          _builder.newLineIfNotEmpty();
          _builder.append("         ");
          _builder.append("*/");
          _builder.newLine();
          _builder.append("        ");
          _builder.append("protected function add");
          String _name_4 = targetField.getName();
          String _formatForCodeCapital_1 = this._formattingExtensions.formatForCodeCapital(_name_4);
          _builder.append(_formatForCodeCapital_1, "        ");
          _builder.append("Without");
          String _relationAliasName_2 = this._namingExtensions.getRelationAliasName(it, Boolean.valueOf(true));
          String _formatForCodeCapital_2 = this._formattingExtensions.formatForCodeCapital(_relationAliasName_2);
          _builder.append(_formatForCodeCapital_2, "        ");
          _builder.append("($");
          String _name_5 = targetField.getName();
          String _formatForCode_4 = this._formattingExtensions.formatForCode(_name_5);
          _builder.append(_formatForCode_4, "        ");
          _builder.append(")");
          _builder.newLineIfNotEmpty();
          _builder.append("        ");
          _builder.append("{");
          _builder.newLine();
          _builder.append("$this->");
          String _name_6 = sourceField.getName();
          String _formatForCode_5 = this._formattingExtensions.formatForCode(_name_6);
          _builder.append(_formatForCode_5, "");
          _builder.append(" += $");
          String _name_7 = targetField.getName();
          String _formatForCode_6 = this._formattingExtensions.formatForCode(_name_7);
          _builder.append(_formatForCode_6, "");
          _builder.append(";");
          _builder.newLineIfNotEmpty();
        } else {
          CharSequence _addAssignmentDefault = this.addAssignmentDefault(it, useTarget, selfIsMany, name, nameSingle);
          _builder.append(_addAssignmentDefault, "");
          _builder.newLineIfNotEmpty();
        }
      }
    }
    return _builder;
  }
  
  private CharSequence _addAssignment(final ManyToManyRelationship it, final Boolean selfIsMany, final Boolean useTarget, final String name, final String nameSingle) {
    StringConcatenation _builder = new StringConcatenation();
    {
      boolean _and = false;
      boolean _and_1 = false;
      boolean _not = (!(useTarget).booleanValue());
      if (!_not) {
        _and_1 = false;
      } else {
        String _indexBy = it.getIndexBy();
        boolean _tripleNotEquals = (_indexBy != null);
        _and_1 = (_not && _tripleNotEquals);
      }
      if (!_and_1) {
        _and = false;
      } else {
        String _indexBy_1 = it.getIndexBy();
        boolean _notEquals = (!Objects.equal(_indexBy_1, ""));
        _and = (_and_1 && _notEquals);
      }
      if (_and) {
        _builder.append("$this->");
        _builder.append(name, "");
        _builder.append("[$");
        _builder.append(nameSingle, "");
        _builder.append("->get");
        String _indexBy_2 = it.getIndexBy();
        String _formatForCodeCapital = this._formattingExtensions.formatForCodeCapital(_indexBy_2);
        _builder.append(_formatForCodeCapital, "");
        _builder.append("()] = $");
        _builder.append(nameSingle, "");
        _builder.append(";");
        _builder.newLineIfNotEmpty();
      } else {
        CharSequence _addAssignmentDefault = this.addAssignmentDefault(it, useTarget, selfIsMany, name, nameSingle);
        _builder.append(_addAssignmentDefault, "");
        _builder.newLineIfNotEmpty();
      }
    }
    return _builder;
  }
  
  private CharSequence removeMethod(final JoinRelationship it, final Boolean useTarget, final Boolean selfIsMany, final String name, final String nameSingle, final String type) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Removes an instance of ");
    {
      Models _container = it.getContainer();
      Application _application = _container.getApplication();
      boolean _targets = this._utils.targets(_application, "1.3.5");
      boolean _not = (!_targets);
      if (_not) {
        _builder.append("\\");
      }
    }
    _builder.append(type, " ");
    _builder.append(" from the list of ");
    String _formatForDisplay = this._formattingExtensions.formatForDisplay(name);
    _builder.append(_formatForDisplay, " ");
    _builder.append(".");
    _builder.newLineIfNotEmpty();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param ");
    {
      Models _container_1 = it.getContainer();
      Application _application_1 = _container_1.getApplication();
      boolean _targets_1 = this._utils.targets(_application_1, "1.3.5");
      boolean _not_1 = (!_targets_1);
      if (_not_1) {
        _builder.append("\\");
      }
    }
    _builder.append(type, " ");
    _builder.append(" $");
    _builder.append(nameSingle, " ");
    _builder.append(" The instance to be removed from the collection.");
    _builder.newLineIfNotEmpty();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @return void");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("public function remove");
    String _firstUpper = StringExtensions.toFirstUpper(name);
    _builder.append(_firstUpper, "");
    _builder.append("(");
    {
      Models _container_2 = it.getContainer();
      Application _application_2 = _container_2.getApplication();
      boolean _targets_2 = this._utils.targets(_application_2, "1.3.5");
      boolean _not_2 = (!_targets_2);
      if (_not_2) {
        _builder.append("\\");
      }
    }
    _builder.append(type, "");
    _builder.append(" $");
    _builder.append(nameSingle, "");
    _builder.append(")");
    _builder.newLineIfNotEmpty();
    _builder.append("{");
    _builder.newLine();
    {
      if ((selfIsMany).booleanValue()) {
        _builder.append("    ");
        _builder.append("$this->");
        _builder.append(name, "    ");
        _builder.append("->removeElement($");
        _builder.append(nameSingle, "    ");
        _builder.append(");");
        _builder.newLineIfNotEmpty();
      } else {
        _builder.append("    ");
        _builder.append("$this->");
        _builder.append(name, "    ");
        _builder.append(" = null;");
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.append("    ");
    boolean _and = false;
    boolean _isBidirectional = it.isBidirectional();
    if (!_isBidirectional) {
      _and = false;
    } else {
      boolean _or = false;
      boolean _and_1 = false;
      boolean _isManyToMany = this.isManyToMany(it);
      boolean _not_3 = (!_isManyToMany);
      if (!_not_3) {
        _and_1 = false;
      } else {
        _and_1 = (_not_3 && (useTarget).booleanValue());
      }
      if (_and_1) {
        _or = true;
      } else {
        boolean _and_2 = false;
        boolean _isManyToMany_1 = this.isManyToMany(it);
        if (!_isManyToMany_1) {
          _and_2 = false;
        } else {
          boolean _not_4 = (!(useTarget).booleanValue());
          _and_2 = (_isManyToMany_1 && _not_4);
        }
        _or = (_and_1 || _and_2);
      }
      _and = (_isBidirectional && _or);
    }
    final boolean generateInverseCalls = _and;
    _builder.newLineIfNotEmpty();
    {
      if (generateInverseCalls) {
        _builder.append("    ");
        boolean _not_5 = (!(useTarget).booleanValue());
        String _relationAliasName = this._namingExtensions.getRelationAliasName(it, Boolean.valueOf(_not_5));
        final String ownAliasName = StringExtensions.toFirstUpper(_relationAliasName);
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        boolean _not_6 = (!(useTarget).booleanValue());
        final boolean otherIsMany = this._modelJoinExtensions.isManySide(it, _not_6);
        _builder.newLineIfNotEmpty();
        {
          if (otherIsMany) {
            _builder.append("    ");
            _builder.append("$");
            _builder.append(nameSingle, "    ");
            _builder.append("->remove");
            _builder.append(ownAliasName, "    ");
            _builder.append("($this);");
            _builder.newLineIfNotEmpty();
          } else {
            _builder.append("    ");
            _builder.append("$");
            _builder.append(nameSingle, "    ");
            _builder.append("->set");
            _builder.append(ownAliasName, "    ");
            _builder.append("(null);");
            _builder.newLineIfNotEmpty();
          }
        }
      }
    }
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence incoming(final JoinRelationship it, final String sourceName, final String targetName, final String entityClass) {
    if (it instanceof ManyToManyRelationship) {
      return _incoming((ManyToManyRelationship)it, sourceName, targetName, entityClass);
    } else if (it instanceof ManyToOneRelationship) {
      return _incoming((ManyToOneRelationship)it, sourceName, targetName, entityClass);
    } else if (it != null) {
      return _incoming(it, sourceName, targetName, entityClass);
    } else {
      throw new IllegalArgumentException("Unhandled parameter types: " +
        Arrays.<Object>asList(it, sourceName, targetName, entityClass).toString());
    }
  }
  
  private CharSequence incomingMappingDescription(final JoinRelationship it, final String sourceName, final String targetName) {
    if (it instanceof ManyToManyRelationship) {
      return _incomingMappingDescription((ManyToManyRelationship)it, sourceName, targetName);
    } else if (it instanceof ManyToOneRelationship) {
      return _incomingMappingDescription((ManyToOneRelationship)it, sourceName, targetName);
    } else if (it != null) {
      return _incomingMappingDescription(it, sourceName, targetName);
    } else {
      throw new IllegalArgumentException("Unhandled parameter types: " +
        Arrays.<Object>asList(it, sourceName, targetName).toString());
    }
  }
  
  private CharSequence outgoing(final JoinRelationship it, final String sourceName, final String targetName, final String entityClass) {
    if (it instanceof ManyToManyRelationship) {
      return _outgoing((ManyToManyRelationship)it, sourceName, targetName, entityClass);
    } else if (it instanceof OneToManyRelationship) {
      return _outgoing((OneToManyRelationship)it, sourceName, targetName, entityClass);
    } else if (it != null) {
      return _outgoing(it, sourceName, targetName, entityClass);
    } else {
      throw new IllegalArgumentException("Unhandled parameter types: " +
        Arrays.<Object>asList(it, sourceName, targetName, entityClass).toString());
    }
  }
  
  private CharSequence outgoingMappingDescription(final JoinRelationship it, final String sourceName, final String targetName) {
    if (it instanceof ManyToManyRelationship) {
      return _outgoingMappingDescription((ManyToManyRelationship)it, sourceName, targetName);
    } else if (it instanceof OneToManyRelationship) {
      return _outgoingMappingDescription((OneToManyRelationship)it, sourceName, targetName);
    } else if (it != null) {
      return _outgoingMappingDescription(it, sourceName, targetName);
    } else {
      throw new IllegalArgumentException("Unhandled parameter types: " +
        Arrays.<Object>asList(it, sourceName, targetName).toString());
    }
  }
  
  private CharSequence outgoingMappingAdditions(final JoinRelationship it) {
    if (it instanceof ManyToManyRelationship) {
      return _outgoingMappingAdditions((ManyToManyRelationship)it);
    } else if (it instanceof OneToManyRelationship) {
      return _outgoingMappingAdditions((OneToManyRelationship)it);
    } else if (it instanceof OneToOneRelationship) {
      return _outgoingMappingAdditions((OneToOneRelationship)it);
    } else if (it != null) {
      return _outgoingMappingAdditions(it);
    } else {
      throw new IllegalArgumentException("Unhandled parameter types: " +
        Arrays.<Object>asList(it).toString());
    }
  }
  
  private CharSequence relationAccessorAdditions(final JoinRelationship it, final Boolean useTarget, final String aliasName, final String singleName) {
    if (it instanceof OneToManyRelationship) {
      return _relationAccessorAdditions((OneToManyRelationship)it, useTarget, aliasName, singleName);
    } else if (it != null) {
      return _relationAccessorAdditions(it, useTarget, aliasName, singleName);
    } else {
      throw new IllegalArgumentException("Unhandled parameter types: " +
        Arrays.<Object>asList(it, useTarget, aliasName, singleName).toString());
    }
  }
  
  private CharSequence addParameters(final JoinRelationship it, final Boolean useTarget, final String name, final String type) {
    if (it instanceof OneToManyRelationship) {
      return _addParameters((OneToManyRelationship)it, useTarget, name, type);
    } else if (it != null) {
      return _addParameters(it, useTarget, name, type);
    } else {
      throw new IllegalArgumentException("Unhandled parameter types: " +
        Arrays.<Object>asList(it, useTarget, name, type).toString());
    }
  }
  
  private CharSequence addAssignment(final JoinRelationship it, final Boolean selfIsMany, final Boolean useTarget, final String name, final String nameSingle) {
    if (it instanceof ManyToManyRelationship) {
      return _addAssignment((ManyToManyRelationship)it, selfIsMany, useTarget, name, nameSingle);
    } else if (it instanceof OneToManyRelationship) {
      return _addAssignment((OneToManyRelationship)it, selfIsMany, useTarget, name, nameSingle);
    } else if (it != null) {
      return _addAssignment(it, selfIsMany, useTarget, name, nameSingle);
    } else {
      throw new IllegalArgumentException("Unhandled parameter types: " +
        Arrays.<Object>asList(it, selfIsMany, useTarget, name, nameSingle).toString());
    }
  }
}
