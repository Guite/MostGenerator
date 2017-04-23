package org.zikula.modulestudio.generator.cartridges.zclassic.models.entity;

import com.google.common.base.Objects;
import de.guite.modulestudio.metamodel.CascadeType;
import de.guite.modulestudio.metamodel.DataObject;
import de.guite.modulestudio.metamodel.DerivedField;
import de.guite.modulestudio.metamodel.Entity;
import de.guite.modulestudio.metamodel.IntegerField;
import de.guite.modulestudio.metamodel.JoinRelationship;
import de.guite.modulestudio.metamodel.ManyToManyRelationship;
import de.guite.modulestudio.metamodel.ManyToOneRelationship;
import de.guite.modulestudio.metamodel.OneToManyRelationship;
import de.guite.modulestudio.metamodel.OneToOneRelationship;
import de.guite.modulestudio.metamodel.RelationFetchType;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import org.eclipse.xtend2.lib.StringConcatenation;
import org.eclipse.xtext.xbase.lib.CollectionLiterals;
import org.eclipse.xtext.xbase.lib.Conversions;
import org.eclipse.xtext.xbase.lib.Extension;
import org.eclipse.xtext.xbase.lib.IterableExtensions;
import org.eclipse.xtext.xbase.lib.StringExtensions;
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper;
import org.zikula.modulestudio.generator.extensions.FormattingExtensions;
import org.zikula.modulestudio.generator.extensions.ModelExtensions;
import org.zikula.modulestudio.generator.extensions.ModelJoinExtensions;
import org.zikula.modulestudio.generator.extensions.NamingExtensions;

@SuppressWarnings("all")
public class Association {
  @Extension
  private FormattingExtensions _formattingExtensions = new FormattingExtensions();
  
  @Extension
  private ModelExtensions _modelExtensions = new ModelExtensions();
  
  @Extension
  private ModelJoinExtensions _modelJoinExtensions = new ModelJoinExtensions();
  
  @Extension
  private NamingExtensions _namingExtensions = new NamingExtensions();
  
  private FileHelper fh = new FileHelper();
  
  /**
   * If we have an outgoing association useTarget is true; for an incoming one it is false.
   */
  public CharSequence generate(final JoinRelationship it, final Boolean useTarget) {
    CharSequence _xblockexpression = null;
    {
      final String sourceName = StringExtensions.toFirstLower(this._namingExtensions.getRelationAliasName(it, Boolean.valueOf(false)));
      final String targetName = StringExtensions.toFirstLower(this._namingExtensions.getRelationAliasName(it, Boolean.valueOf(true)));
      DataObject _xifexpression = null;
      if ((useTarget).booleanValue()) {
        _xifexpression = it.getTarget();
      } else {
        _xifexpression = it.getSource();
      }
      final String entityClass = this._namingExtensions.entityClassName(_xifexpression, "", Boolean.valueOf(false));
      _xblockexpression = this.directionSwitch(it, useTarget, sourceName, targetName, entityClass);
    }
    return _xblockexpression;
  }
  
  private CharSequence directionSwitch(final JoinRelationship it, final Boolean useTarget, final String sourceName, final String targetName, final String entityClass) {
    CharSequence _xifexpression = null;
    boolean _isBidirectional = this.isBidirectional(it);
    boolean _not = (!_isBidirectional);
    if (_not) {
      _xifexpression = this.unidirectional(it, useTarget, sourceName, targetName, entityClass);
    } else {
      _xifexpression = this.bidirectional(it, useTarget, sourceName, targetName, entityClass);
    }
    return _xifexpression;
  }
  
  private CharSequence unidirectional(final JoinRelationship it, final Boolean useTarget, final String sourceName, final String targetName, final String entityClass) {
    StringConcatenation _builder = new StringConcatenation();
    {
      if ((useTarget).booleanValue()) {
        CharSequence _outgoing = this.outgoing(it, sourceName, targetName, entityClass);
        _builder.append(_outgoing);
        _builder.newLineIfNotEmpty();
      }
    }
    return _builder;
  }
  
  private CharSequence bidirectional(final JoinRelationship it, final Boolean useTarget, final String sourceName, final String targetName, final String entityClass) {
    StringConcatenation _builder = new StringConcatenation();
    {
      if ((!(useTarget).booleanValue())) {
        CharSequence _incoming = this.incoming(it, sourceName, targetName, entityClass);
        _builder.append(_incoming);
        _builder.newLineIfNotEmpty();
      } else {
        CharSequence _outgoing = this.outgoing(it, sourceName, targetName, entityClass);
        _builder.append(_outgoing);
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
    _builder.append(_incomingMappingDetails);
    _builder.newLineIfNotEmpty();
    _builder.append(" ");
    _builder.append("* @ORM\\");
    String _incomingMappingType = this.incomingMappingType(it);
    _builder.append(_incomingMappingType, " ");
    _builder.append("(targetEntity=\"");
    _builder.append(entityClass, " ");
    _builder.append("\", inversedBy=\"");
    _builder.append(targetName, " ");
    _builder.append("\"");
    CharSequence _additionalOptions = this.additionalOptions(it, Boolean.valueOf(true));
    _builder.append(_additionalOptions, " ");
    _builder.append(")");
    _builder.newLineIfNotEmpty();
    CharSequence _joinDetails = this.joinDetails(it, Boolean.valueOf(false));
    _builder.append(_joinDetails);
    _builder.newLineIfNotEmpty();
    {
      boolean _isNullable = it.isNullable();
      boolean _not = (!_isNullable);
      if (_not) {
        final String aliasName = StringExtensions.toFirstLower(this._namingExtensions.getRelationAliasName(it, Boolean.valueOf(false)));
        _builder.newLineIfNotEmpty();
        {
          boolean _isManySide = this._modelJoinExtensions.isManySide(it, false);
          boolean _not_1 = (!_isManySide);
          if (_not_1) {
            _builder.append(" ");
            _builder.append("* @Assert\\NotNull(message=\"Choosing a ");
            String _formatForDisplay = this._formattingExtensions.formatForDisplay(aliasName);
            _builder.append(_formatForDisplay);
            _builder.append(" is required.\")");
            _builder.newLineIfNotEmpty();
          } else {
            _builder.append(" ");
            _builder.append("* @Assert\\NotNull(message=\"Choosing at least one of the ");
            String _formatForDisplay_1 = this._formattingExtensions.formatForDisplay(aliasName);
            _builder.append(_formatForDisplay_1);
            _builder.append(" is required.\")");
            _builder.newLineIfNotEmpty();
          }
        }
      }
    }
    {
      boolean _isManySide_1 = this._modelJoinExtensions.isManySide(it, false);
      boolean _not_2 = (!_isManySide_1);
      if (_not_2) {
        _builder.append(" ");
        _builder.append("* @Assert\\Type(type=\"");
        _builder.append(entityClass);
        _builder.append("\")");
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.append(" ");
    _builder.append("* @var \\");
    _builder.append(entityClass, " ");
    {
      boolean _isManySide_2 = this._modelJoinExtensions.isManySide(it, false);
      if (_isManySide_2) {
        _builder.append("[]");
      }
    }
    _builder.append(" $");
    _builder.append(sourceName, " ");
    _builder.newLineIfNotEmpty();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("protected $");
    _builder.append(sourceName);
    _builder.append(";");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    return _builder;
  }
  
  private String getDisplayNameDependingOnType(final DataObject it) {
    String _xifexpression = null;
    if ((it instanceof Entity)) {
      _xifexpression = this._formattingExtensions.formatForDisplay(((Entity)it).getNameMultiple());
    } else {
      _xifexpression = this._formattingExtensions.formatForDisplay(it.getName());
    }
    return _xifexpression;
  }
  
  private CharSequence _incomingMappingDescription(final JoinRelationship it, final String sourceName, final String targetName) {
    CharSequence _switchResult = null;
    boolean _matched = false;
    if (it instanceof OneToOneRelationship) {
      _matched=true;
      StringConcatenation _builder = new StringConcatenation();
      _builder.append("One ");
      _builder.append(targetName);
      _builder.append(" [");
      String _formatForDisplay = this._formattingExtensions.formatForDisplay(((OneToOneRelationship)it).getTarget().getName());
      _builder.append(_formatForDisplay);
      _builder.append("] is linked by one ");
      _builder.append(sourceName);
      _builder.append(" [");
      String _formatForDisplay_1 = this._formattingExtensions.formatForDisplay(((OneToOneRelationship)it).getSource().getName());
      _builder.append(_formatForDisplay_1);
      _builder.append("] (INVERSE SIDE)");
      _switchResult = _builder;
    }
    if (!_matched) {
      if (it instanceof OneToManyRelationship) {
        _matched=true;
        StringConcatenation _builder = new StringConcatenation();
        _builder.append("Many ");
        _builder.append(targetName);
        _builder.append(" [");
        String _displayNameDependingOnType = this.getDisplayNameDependingOnType(((OneToManyRelationship)it).getTarget());
        _builder.append(_displayNameDependingOnType);
        _builder.append("] are linked by one ");
        _builder.append(sourceName);
        _builder.append(" [");
        String _formatForDisplay = this._formattingExtensions.formatForDisplay(((OneToManyRelationship)it).getSource().getName());
        _builder.append(_formatForDisplay);
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
    if (it instanceof OneToOneRelationship) {
      boolean _isPrimaryKey = ((OneToOneRelationship)it).isPrimaryKey();
      if (_isPrimaryKey) {
        _matched=true;
        StringConcatenation _builder = new StringConcatenation();
        _builder.append(" ");
        _builder.append("* @ORM\\Id");
        _switchResult = _builder;
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
    if (it instanceof OneToOneRelationship) {
      _matched=true;
      _switchResult = "OneToOne";
    }
    if (!_matched) {
      if (it instanceof OneToManyRelationship) {
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
    _builder.append(entityClass, " ");
    _builder.append("\")");
    _builder.newLineIfNotEmpty();
    CharSequence _joinDetails = this.joinDetails(it, Boolean.valueOf(false));
    _builder.append(_joinDetails);
    _builder.newLineIfNotEmpty();
    {
      boolean _isNullable = it.isNullable();
      boolean _not = (!_isNullable);
      if (_not) {
        final String aliasName = StringExtensions.toFirstLower(this._namingExtensions.getRelationAliasName(it, Boolean.valueOf(false)));
        _builder.newLineIfNotEmpty();
        _builder.append(" ");
        _builder.append("* @Assert\\NotNull(message=\"Choosing a ");
        String _formatForDisplay = this._formattingExtensions.formatForDisplay(aliasName);
        _builder.append(_formatForDisplay);
        _builder.append(" is required.\")");
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.append(" ");
    _builder.append("* @Assert\\Type(type=\"");
    _builder.append(entityClass, " ");
    _builder.append("\")");
    _builder.newLineIfNotEmpty();
    _builder.append(" ");
    _builder.append("* @var \\");
    _builder.append(entityClass, " ");
    _builder.append(" $");
    _builder.append(sourceName, " ");
    _builder.newLineIfNotEmpty();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("protected $");
    _builder.append(sourceName);
    _builder.append(";");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence _incomingMappingDescription(final ManyToOneRelationship it, final String sourceName, final String targetName) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("One ");
    _builder.append(targetName);
    _builder.append(" [");
    String _formatForDisplay = this._formattingExtensions.formatForDisplay(it.getTarget().getName());
    _builder.append(_formatForDisplay);
    _builder.append("] is linked by many ");
    _builder.append(sourceName);
    _builder.append(" [");
    String _displayNameDependingOnType = this.getDisplayNameDependingOnType(it.getSource());
    _builder.append(_displayNameDependingOnType);
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
        _builder.append(entityClass, " ");
        _builder.append("\", mappedBy=\"");
        _builder.append(targetName, " ");
        _builder.append("\"");
        CharSequence _additionalOptions = this.additionalOptions(it, Boolean.valueOf(true));
        _builder.append(_additionalOptions, " ");
        _builder.append(")");
        _builder.newLineIfNotEmpty();
        {
          if (((null != it.getOrderByReverse()) && (!Objects.equal(it.getOrderByReverse(), "")))) {
            _builder.append(" ");
            _builder.append("* @ORM\\OrderBy({");
            String _orderByDetails = this.orderByDetails(it.getOrderByReverse());
            _builder.append(_orderByDetails, " ");
            _builder.append("})");
            _builder.newLineIfNotEmpty();
          }
        }
        {
          boolean _isNullable = it.isNullable();
          boolean _not = (!_isNullable);
          if (_not) {
            final String aliasName = StringExtensions.toFirstLower(this._namingExtensions.getRelationAliasName(it, Boolean.valueOf(false)));
            _builder.newLineIfNotEmpty();
            _builder.append(" ");
            _builder.append("* @Assert\\NotNull(message=\"Choosing at least one of the ");
            String _formatForDisplay = this._formattingExtensions.formatForDisplay(aliasName);
            _builder.append(_formatForDisplay);
            _builder.append(" is required.\")");
            _builder.newLineIfNotEmpty();
          }
        }
        {
          int _maxSource = it.getMaxSource();
          boolean _greaterThan = (_maxSource > 0);
          if (_greaterThan) {
            _builder.append(" ");
            _builder.append("* @Assert\\Count(min=\"");
            int _minSource = it.getMinSource();
            _builder.append(_minSource);
            _builder.append("\", max=\"");
            int _maxSource_1 = it.getMaxSource();
            _builder.append(_maxSource_1);
            _builder.append("\")");
            _builder.newLineIfNotEmpty();
          }
        }
        _builder.append(" ");
        _builder.append("* @var \\");
        _builder.append(entityClass, " ");
        _builder.append("[] $");
        _builder.append(sourceName, " ");
        _builder.newLineIfNotEmpty();
        _builder.append(" ");
        _builder.append("*/");
        _builder.newLine();
        _builder.append("protected $");
        _builder.append(sourceName);
        _builder.append(" = null;");
        _builder.newLineIfNotEmpty();
      }
    }
    return _builder;
  }
  
  private CharSequence _incomingMappingDescription(final ManyToManyRelationship it, final String sourceName, final String targetName) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("Many ");
    _builder.append(targetName);
    _builder.append(" [");
    String _displayNameDependingOnType = this.getDisplayNameDependingOnType(it.getTarget());
    _builder.append(_displayNameDependingOnType);
    _builder.append("] are linked by many ");
    _builder.append(sourceName);
    _builder.append(" [");
    String _displayNameDependingOnType_1 = this.getDisplayNameDependingOnType(it.getSource());
    _builder.append(_displayNameDependingOnType_1);
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
      boolean _isBidirectional = this.isBidirectional(it);
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
    _builder.append(entityClass, " ");
    _builder.append("\"");
    {
      boolean _isBidirectional_1 = this.isBidirectional(it);
      if (_isBidirectional_1) {
        _builder.append(", mappedBy=\"");
        _builder.append(sourceName, " ");
        _builder.append("\"");
      }
    }
    CharSequence _cascadeOptions = this.cascadeOptions(it, Boolean.valueOf(false));
    _builder.append(_cascadeOptions, " ");
    CharSequence _fetchTypeTag = this.fetchTypeTag(it);
    _builder.append(_fetchTypeTag, " ");
    CharSequence _outgoingMappingAdditions = this.outgoingMappingAdditions(it);
    _builder.append(_outgoingMappingAdditions, " ");
    _builder.append(")");
    _builder.newLineIfNotEmpty();
    CharSequence _joinDetails = this.joinDetails(it, Boolean.valueOf(true));
    _builder.append(_joinDetails);
    _builder.newLineIfNotEmpty();
    {
      boolean _isNullable = it.isNullable();
      boolean _not = (!_isNullable);
      if (_not) {
        final String aliasName = StringExtensions.toFirstLower(this._namingExtensions.getRelationAliasName(it, Boolean.valueOf(true)));
        _builder.newLineIfNotEmpty();
        {
          boolean _isManySide = this._modelJoinExtensions.isManySide(it, true);
          boolean _not_1 = (!_isManySide);
          if (_not_1) {
            _builder.append(" ");
            _builder.append("* @Assert\\NotNull(message=\"Choosing a ");
            String _formatForDisplay = this._formattingExtensions.formatForDisplay(aliasName);
            _builder.append(_formatForDisplay);
            _builder.append(" is required.\")");
            _builder.newLineIfNotEmpty();
          } else {
            _builder.append(" ");
            _builder.append("* @Assert\\NotNull(message=\"Choosing at least one of the ");
            String _formatForDisplay_1 = this._formattingExtensions.formatForDisplay(aliasName);
            _builder.append(_formatForDisplay_1);
            _builder.append(" is required.\")");
            _builder.newLineIfNotEmpty();
          }
        }
      }
    }
    {
      boolean _isManySide_1 = this._modelJoinExtensions.isManySide(it, true);
      boolean _not_2 = (!_isManySide_1);
      if (_not_2) {
        _builder.append(" ");
        _builder.append("* @Assert\\Type(type=\"");
        _builder.append(entityClass);
        _builder.append("\")");
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.append(" ");
    _builder.append("* @var \\");
    _builder.append(entityClass, " ");
    _builder.append(" $");
    _builder.append(targetName, " ");
    _builder.newLineIfNotEmpty();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("protected $");
    _builder.append(targetName);
    _builder.append(";");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence _outgoingMappingDescription(final JoinRelationship it, final String sourceName, final String targetName) {
    CharSequence _switchResult = null;
    boolean _matched = false;
    if (it instanceof OneToOneRelationship) {
      _matched=true;
      StringConcatenation _builder = new StringConcatenation();
      _builder.append("One ");
      _builder.append(sourceName);
      _builder.append(" [");
      String _formatForDisplay = this._formattingExtensions.formatForDisplay(((OneToOneRelationship)it).getSource().getName());
      _builder.append(_formatForDisplay);
      _builder.append("] has one ");
      _builder.append(targetName);
      _builder.append(" [");
      String _formatForDisplay_1 = this._formattingExtensions.formatForDisplay(((OneToOneRelationship)it).getTarget().getName());
      _builder.append(_formatForDisplay_1);
      _builder.append("] (INVERSE SIDE)");
      _switchResult = _builder;
    }
    if (!_matched) {
      if (it instanceof ManyToOneRelationship) {
        _matched=true;
        StringConcatenation _builder = new StringConcatenation();
        _builder.append("Many ");
        _builder.append(sourceName);
        _builder.append(" [");
        String _displayNameDependingOnType = this.getDisplayNameDependingOnType(((ManyToOneRelationship)it).getSource());
        _builder.append(_displayNameDependingOnType);
        _builder.append("] have one ");
        _builder.append(targetName);
        _builder.append(" [");
        String _formatForDisplay = this._formattingExtensions.formatForDisplay(((ManyToOneRelationship)it).getTarget().getName());
        _builder.append(_formatForDisplay);
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
    if (it instanceof OneToOneRelationship) {
      _matched=true;
      _switchResult = "OneToOne";
    }
    if (!_matched) {
      if (it instanceof ManyToOneRelationship) {
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
      if (((null != it.getIndexBy()) && (!Objects.equal(it.getIndexBy(), "")))) {
        _builder.append(", indexBy=\"");
        String _indexBy = it.getIndexBy();
        _builder.append(_indexBy);
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
      if (((null != it.getIndexBy()) && (!Objects.equal(it.getIndexBy(), "")))) {
        _builder.append(", indexBy=\"");
        String _indexBy = it.getIndexBy();
        _builder.append(_indexBy);
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
        _builder.append(entityClass, " ");
        _builder.append("\"");
        CharSequence _additionalOptions = this.additionalOptions(it, Boolean.valueOf(false));
        _builder.append(_additionalOptions, " ");
        _builder.append(")");
        _builder.newLineIfNotEmpty();
      } else {
        _builder.append(" ");
        _builder.append("* @ORM\\OneToMany(targetEntity=\"");
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
    _builder.append(_joinDetails);
    _builder.newLineIfNotEmpty();
    {
      if (((null != it.getOrderBy()) && (!Objects.equal(it.getOrderBy(), "")))) {
        _builder.append(" ");
        _builder.append("* @ORM\\OrderBy({");
        String _orderByDetails = this.orderByDetails(it.getOrderBy());
        _builder.append(_orderByDetails, " ");
        _builder.append("})");
        _builder.newLineIfNotEmpty();
      }
    }
    {
      boolean _isNullable = it.isNullable();
      boolean _not_1 = (!_isNullable);
      if (_not_1) {
        final String aliasName = StringExtensions.toFirstLower(this._namingExtensions.getRelationAliasName(it, Boolean.valueOf(true)));
        _builder.newLineIfNotEmpty();
        _builder.append(" ");
        _builder.append("* @Assert\\NotNull(message=\"Choosing at least one of the ");
        String _formatForDisplay = this._formattingExtensions.formatForDisplay(aliasName);
        _builder.append(_formatForDisplay);
        _builder.append(" is required.\")");
        _builder.newLineIfNotEmpty();
      }
    }
    {
      int _maxTarget = it.getMaxTarget();
      boolean _greaterThan = (_maxTarget > 0);
      if (_greaterThan) {
        _builder.append(" ");
        _builder.append("* @Assert\\Count(min=\"");
        int _minTarget = it.getMinTarget();
        _builder.append(_minTarget);
        _builder.append("\", max=\"");
        int _maxTarget_1 = it.getMaxTarget();
        _builder.append(_maxTarget_1);
        _builder.append("\")");
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.append(" ");
    _builder.append("* @var \\");
    _builder.append(entityClass, " ");
    _builder.append("[] $");
    _builder.append(targetName, " ");
    _builder.newLineIfNotEmpty();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("protected $");
    _builder.append(targetName);
    _builder.append(" = null;");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence _outgoingMappingDescription(final OneToManyRelationship it, final String sourceName, final String targetName) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("One ");
    _builder.append(sourceName);
    _builder.append(" [");
    String _formatForDisplay = this._formattingExtensions.formatForDisplay(it.getSource().getName());
    _builder.append(_formatForDisplay);
    _builder.append("] has many ");
    _builder.append(targetName);
    _builder.append(" [");
    String _displayNameDependingOnType = this.getDisplayNameDependingOnType(it.getTarget());
    _builder.append(_displayNameDependingOnType);
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
    _builder.append(_joinDetails);
    _builder.newLineIfNotEmpty();
    {
      if (((null != it.getOrderBy()) && (!Objects.equal(it.getOrderBy(), "")))) {
        _builder.append(" ");
        _builder.append("* @ORM\\OrderBy({");
        String _orderByDetails = this.orderByDetails(it.getOrderBy());
        _builder.append(_orderByDetails, " ");
        _builder.append("})");
        _builder.newLineIfNotEmpty();
      }
    }
    {
      boolean _isNullable = it.isNullable();
      boolean _not = (!_isNullable);
      if (_not) {
        final String aliasName = StringExtensions.toFirstLower(this._namingExtensions.getRelationAliasName(it, Boolean.valueOf(true)));
        _builder.newLineIfNotEmpty();
        _builder.append(" ");
        _builder.append("* @Assert\\NotNull(message=\"Choosing at least one of the ");
        String _formatForDisplay = this._formattingExtensions.formatForDisplay(aliasName);
        _builder.append(_formatForDisplay);
        _builder.append(" is required.\")");
        _builder.newLineIfNotEmpty();
      }
    }
    {
      int _maxTarget = it.getMaxTarget();
      boolean _greaterThan = (_maxTarget > 0);
      if (_greaterThan) {
        _builder.append(" ");
        _builder.append("* @Assert\\Count(min=\"");
        int _minTarget = it.getMinTarget();
        _builder.append(_minTarget);
        _builder.append("\", max=\"");
        int _maxTarget_1 = it.getMaxTarget();
        _builder.append(_maxTarget_1);
        _builder.append("\")");
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.append(" ");
    _builder.append("* @var \\");
    _builder.append(entityClass, " ");
    _builder.append("[] $");
    _builder.append(targetName, " ");
    _builder.newLineIfNotEmpty();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("protected $");
    _builder.append(targetName);
    _builder.append(" = null;");
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  private CharSequence _outgoingMappingDescription(final ManyToManyRelationship it, final String sourceName, final String targetName) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("Many ");
    _builder.append(sourceName);
    _builder.append(" [");
    String _displayNameDependingOnType = this.getDisplayNameDependingOnType(it.getSource());
    _builder.append(_displayNameDependingOnType);
    _builder.append("] have many ");
    _builder.append(targetName);
    _builder.append(" [");
    String _displayNameDependingOnType_1 = this.getDisplayNameDependingOnType(it.getTarget());
    _builder.append(_displayNameDependingOnType_1);
    _builder.append("] (OWNING SIDE)");
    return _builder;
  }
  
  private CharSequence joinDetails(final JoinRelationship it, final Boolean useTarget) {
    CharSequence _xblockexpression = null;
    {
      DataObject _xifexpression = null;
      if ((useTarget).booleanValue()) {
        _xifexpression = it.getSource();
      } else {
        _xifexpression = it.getTarget();
      }
      final DataObject joinedEntityLocal = _xifexpression;
      DataObject _xifexpression_1 = null;
      if ((useTarget).booleanValue()) {
        _xifexpression_1 = it.getTarget();
      } else {
        _xifexpression_1 = it.getSource();
      }
      final DataObject joinedEntityForeign = _xifexpression_1;
      String[] _xifexpression_2 = null;
      if ((useTarget).booleanValue()) {
        _xifexpression_2 = this._modelJoinExtensions.getSourceFields(it);
      } else {
        _xifexpression_2 = this._modelJoinExtensions.getTargetFields(it);
      }
      final String[] joinColumnsLocal = _xifexpression_2;
      String[] _xifexpression_3 = null;
      if ((useTarget).booleanValue()) {
        _xifexpression_3 = this._modelJoinExtensions.getTargetFields(it);
      } else {
        _xifexpression_3 = this._modelJoinExtensions.getSourceFields(it);
      }
      final String[] joinColumnsForeign = _xifexpression_3;
      final String foreignTableName = this._modelJoinExtensions.fullJoinTableName(it, useTarget, joinedEntityForeign);
      CharSequence _xifexpression_4 = null;
      if (((((this._modelExtensions.containsDefaultIdField(((Iterable<String>)Conversions.doWrapArray(joinColumnsForeign)), joinedEntityForeign) && this._modelExtensions.containsDefaultIdField(((Iterable<String>)Conversions.doWrapArray(joinColumnsLocal)), joinedEntityLocal)) && (!it.isUnique())) && it.isNullable()) && Objects.equal(it.getOnDelete(), ""))) {
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
        CharSequence _joinTableDetails = this.joinTableDetails(it, useTarget);
        _builder_1.append(_joinTableDetails);
        _builder_1.newLineIfNotEmpty();
        _builder_1.append(" ");
        _builder_1.append("* )");
        _xifexpression_4 = _builder_1;
      }
      _xblockexpression = _xifexpression_4;
    }
    return _xblockexpression;
  }
  
  private CharSequence joinTableDetails(final JoinRelationship it, final Boolean useTarget) {
    StringConcatenation _builder = new StringConcatenation();
    DataObject _xifexpression = null;
    if ((useTarget).booleanValue()) {
      _xifexpression = it.getSource();
    } else {
      _xifexpression = it.getTarget();
    }
    final DataObject joinedEntityLocal = _xifexpression;
    _builder.newLineIfNotEmpty();
    DataObject _xifexpression_1 = null;
    if ((useTarget).booleanValue()) {
      _xifexpression_1 = it.getTarget();
    } else {
      _xifexpression_1 = it.getSource();
    }
    final DataObject joinedEntityForeign = _xifexpression_1;
    _builder.newLineIfNotEmpty();
    String[] _xifexpression_2 = null;
    if ((useTarget).booleanValue()) {
      _xifexpression_2 = this._modelJoinExtensions.getSourceFields(it);
    } else {
      _xifexpression_2 = this._modelJoinExtensions.getTargetFields(it);
    }
    final String[] joinColumnsLocal = _xifexpression_2;
    _builder.newLineIfNotEmpty();
    String[] _xifexpression_3 = null;
    if ((useTarget).booleanValue()) {
      _xifexpression_3 = this._modelJoinExtensions.getTargetFields(it);
    } else {
      _xifexpression_3 = this._modelJoinExtensions.getSourceFields(it);
    }
    final String[] joinColumnsForeign = _xifexpression_3;
    _builder.newLineIfNotEmpty();
    {
      int _size = ((List<String>)Conversions.doWrapArray(joinColumnsForeign)).size();
      boolean _greaterThan = (_size > 1);
      if (_greaterThan) {
        CharSequence _joinColumnsMultiple = this.joinColumnsMultiple(it, useTarget, joinedEntityLocal, joinColumnsLocal);
        _builder.append(_joinColumnsMultiple);
        _builder.newLineIfNotEmpty();
      } else {
        CharSequence _joinColumnsSingle = this.joinColumnsSingle(it, useTarget, joinedEntityLocal, joinColumnsLocal);
        _builder.append(_joinColumnsSingle);
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
            CharSequence _joinColumn = this.joinColumn(it, joinColumnForeign, this._formattingExtensions.formatForDB(this._modelExtensions.getFirstPrimaryKey(joinedEntityForeign).getName()), useTarget);
            _builder.append(_joinColumn);
          }
        }
        _builder.append("}");
        _builder.newLineIfNotEmpty();
      } else {
        _builder.append(" *      inverseJoinColumns={");
        CharSequence _joinColumn_1 = this.joinColumn(it, IterableExtensions.<String>head(((Iterable<String>)Conversions.doWrapArray(joinColumnsForeign))), this._formattingExtensions.formatForDB(this._modelExtensions.getFirstPrimaryKey(joinedEntityForeign).getName()), useTarget);
        _builder.append(_joinColumn_1);
        _builder.append("}");
        _builder.newLineIfNotEmpty();
      }
    }
    return _builder;
  }
  
  private CharSequence joinColumnsMultiple(final JoinRelationship it, final Boolean useTarget, final DataObject joinedEntityLocal, final String[] joinColumnsLocal) {
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
        CharSequence _joinColumn = this.joinColumn(it, joinColumnLocal, this._formattingExtensions.formatForDB(this._modelExtensions.getFirstPrimaryKey(joinedEntityLocal).getName()), Boolean.valueOf((!(useTarget).booleanValue())));
        _builder.append(_joinColumn, " ");
      }
    }
    _builder.append("},");
    return _builder;
  }
  
  private CharSequence joinColumnsSingle(final JoinRelationship it, final Boolean useTarget, final DataObject joinedEntityLocal, final String[] joinColumnsLocal) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append(" ");
    _builder.append("*      joinColumns={");
    CharSequence _joinColumn = this.joinColumn(it, IterableExtensions.<String>head(((Iterable<String>)Conversions.doWrapArray(joinColumnsLocal))), this._formattingExtensions.formatForDB(this._modelExtensions.getFirstPrimaryKey(joinedEntityLocal).getName()), Boolean.valueOf((!(useTarget).booleanValue())));
    _builder.append(_joinColumn, " ");
    _builder.append("},");
    return _builder;
  }
  
  private CharSequence joinColumn(final JoinRelationship it, final String columnName, final String referencedColumnName, final Boolean useTarget) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("@ORM\\JoinColumn(name=\"");
    String _joinColumnName = this.joinColumnName(it, columnName, useTarget);
    _builder.append(_joinColumnName);
    _builder.append("\", referencedColumnName=\"");
    _builder.append(referencedColumnName);
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
        _builder.append(_onDelete_1);
        _builder.append("\"");
      }
    }
    _builder.append(")");
    return _builder;
  }
  
  private String joinColumnName(final JoinRelationship it, final String columnName, final Boolean useTarget) {
    String _switchResult = null;
    boolean _matched = false;
    if (it instanceof ManyToManyRelationship) {
      boolean _equals = Objects.equal(columnName, "id");
      if (_equals) {
        _matched=true;
        DataObject _xifexpression = null;
        if ((useTarget).booleanValue()) {
          _xifexpression = ((ManyToManyRelationship)it).getTarget();
        } else {
          _xifexpression = ((ManyToManyRelationship)it).getSource();
        }
        String _formatForDB = this._formattingExtensions.formatForDB(_xifexpression.getName());
        _switchResult = (_formatForDB + "_id");
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
    _builder.append(_cascadeOptions);
    CharSequence _fetchTypeTag = this.fetchTypeTag(it);
    _builder.append(_fetchTypeTag);
    return _builder;
  }
  
  private CharSequence cascadeOptions(final JoinRelationship it, final Boolean useReverse) {
    CharSequence _xblockexpression = null;
    {
      CascadeType _xifexpression = null;
      if ((useReverse).booleanValue()) {
        _xifexpression = it.getCascadeReverse();
      } else {
        _xifexpression = it.getCascade();
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
        _builder.append(_cascadeOptionsImpl);
        _builder.append("}");
        _xifexpression_1 = _builder;
      }
      _xblockexpression = _xifexpression_1;
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
      String _literal = it.getFetchType().getLiteral();
      _builder.append(_literal);
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
        _xifexpression = it.getCascadeReverse();
      } else {
        _xifexpression = it.getCascade();
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
      _xblockexpression = _xifexpression_1;
    }
    return _xblockexpression;
  }
  
  private String orderByDetails(final String orderBy) {
    String _xblockexpression = null;
    {
      final ArrayList<Object> criteria = CollectionLiterals.<Object>newArrayList();
      final String[] orderByFields = orderBy.replace(", ", ",").split(",");
      for (final String orderByField : orderByFields) {
        {
          String fieldName = orderByField;
          String sorting = "ASC";
          boolean _contains = orderByField.contains(":");
          if (_contains) {
            final String[] criteriaParts = orderByField.split(":");
            fieldName = IterableExtensions.<String>head(((Iterable<String>)Conversions.doWrapArray(criteriaParts)));
            sorting = IterableExtensions.<String>last(((Iterable<String>)Conversions.doWrapArray(criteriaParts)));
          }
          String _upperCase = sorting.toUpperCase();
          String _plus = ((("\"" + fieldName) + "\" = \"") + _upperCase);
          String _plus_1 = (_plus + "\"");
          criteria.add(_plus_1);
        }
      }
      _xblockexpression = IterableExtensions.join(criteria, ", ");
    }
    return _xblockexpression;
  }
  
  public CharSequence initCollections(final Entity it) {
    StringConcatenation _builder = new StringConcatenation();
    {
      Iterable<JoinRelationship> _outgoingCollections = this._modelJoinExtensions.getOutgoingCollections(it);
      for(final JoinRelationship relation : _outgoingCollections) {
        CharSequence _initCollection = this.initCollection(relation, Boolean.valueOf(true));
        _builder.append(_initCollection);
      }
    }
    _builder.newLineIfNotEmpty();
    {
      Iterable<JoinRelationship> _incomingCollections = this._modelJoinExtensions.getIncomingCollections(it);
      for(final JoinRelationship relation_1 : _incomingCollections) {
        CharSequence _initCollection_1 = this.initCollection(relation_1, Boolean.valueOf(false));
        _builder.append(_initCollection_1);
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
        _builder.append(_relationAliasName);
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
    _builder.append(_relationAccessorImpl);
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  private CharSequence relationAccessorImpl(final JoinRelationship it, final Boolean useTarget, final String aliasName) {
    StringConcatenation _builder = new StringConcatenation();
    DataObject _xifexpression = null;
    if ((useTarget).booleanValue()) {
      _xifexpression = it.getTarget();
    } else {
      _xifexpression = it.getSource();
    }
    final String entityClass = this._namingExtensions.entityClassName(_xifexpression, "", Boolean.valueOf(false));
    _builder.newLineIfNotEmpty();
    DataObject _xifexpression_1 = null;
    if ((useTarget).booleanValue()) {
      _xifexpression_1 = it.getTarget();
    } else {
      _xifexpression_1 = it.getSource();
    }
    final String nameSingle = _xifexpression_1.getName();
    _builder.newLineIfNotEmpty();
    final boolean isMany = this._modelJoinExtensions.isManySide(it, (useTarget).booleanValue());
    _builder.newLineIfNotEmpty();
    final String entityClassPrefix = "\\";
    _builder.newLineIfNotEmpty();
    {
      if (isMany) {
        CharSequence _terAndSetterMethods = this.fh.getterAndSetterMethods(it, aliasName, (entityClassPrefix + entityClass), Boolean.valueOf(true), Boolean.valueOf(true), Boolean.valueOf(false), "", this.relationSetterCustomImpl(it, useTarget, aliasName));
        _builder.append(_terAndSetterMethods);
        _builder.newLineIfNotEmpty();
        CharSequence _relationAccessorAdditions = this.relationAccessorAdditions(it, useTarget, aliasName, nameSingle);
        _builder.append(_relationAccessorAdditions);
        _builder.newLineIfNotEmpty();
      } else {
        CharSequence _terAndSetterMethods_1 = this.fh.getterAndSetterMethods(it, aliasName, (entityClassPrefix + entityClass), Boolean.valueOf(false), Boolean.valueOf(true), Boolean.valueOf(true), "null", this.relationSetterCustomImpl(it, useTarget, aliasName));
        _builder.append(_terAndSetterMethods_1);
        _builder.newLineIfNotEmpty();
      }
    }
    {
      if (isMany) {
        CharSequence _addMethod = this.addMethod(it, useTarget, Boolean.valueOf(isMany), aliasName, nameSingle, entityClass);
        _builder.append(_addMethod);
        _builder.newLineIfNotEmpty();
        CharSequence _removeMethod = this.removeMethod(it, useTarget, Boolean.valueOf(isMany), aliasName, nameSingle, entityClass);
        _builder.append(_removeMethod);
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
        DataObject _xifexpression = null;
        if ((useTarget).booleanValue()) {
          _xifexpression = it.getTarget();
        } else {
          _xifexpression = it.getSource();
        }
        String _name = _xifexpression.getName();
        final String nameSingle = (_name + "Single");
        _builder.newLineIfNotEmpty();
        _builder.append("foreach ($");
        _builder.append(aliasName);
        _builder.append(" as $");
        _builder.append(nameSingle);
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
        _builder.append(_formatForCode);
        _builder.append(" = $");
        _builder.append(aliasName);
        _builder.append(";");
        _builder.newLineIfNotEmpty();
        final boolean generateInverseCalls = (this.isBidirectional(it) && (((!this.isManyToMany(it)) && (useTarget).booleanValue()) || (this.isManyToMany(it) && (!(useTarget).booleanValue()))));
        _builder.newLineIfNotEmpty();
        {
          if (generateInverseCalls) {
            final String ownAliasName = StringExtensions.toFirstUpper(this._namingExtensions.getRelationAliasName(it, Boolean.valueOf((!(useTarget).booleanValue()))));
            _builder.newLineIfNotEmpty();
            _builder.append("$");
            _builder.append(aliasName);
            _builder.append("->set");
            _builder.append(ownAliasName);
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
      if ((((!(useTarget).booleanValue()) && (null != it.getIndexBy())) && (!Objects.equal(it.getIndexBy(), "")))) {
        _builder.append("/**");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* Returns an instance of ");
        String _entityClassName = this._namingExtensions.entityClassName(it.getSource(), "", Boolean.valueOf(false));
        _builder.append(_entityClassName, " ");
        _builder.append(" from the list of ");
        String _relationAliasName = this._namingExtensions.getRelationAliasName(it, useTarget);
        _builder.append(_relationAliasName, " ");
        _builder.append(" by its given ");
        String _formatForDisplay = this._formattingExtensions.formatForDisplay(it.getIndexBy());
        _builder.append(_formatForDisplay, " ");
        _builder.append(" index.");
        _builder.newLineIfNotEmpty();
        _builder.append(" ");
        _builder.append("*");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* @param ");
        String _entityClassName_1 = this._namingExtensions.entityClassName(it.getSource(), "", Boolean.valueOf(false));
        _builder.append(_entityClassName_1, " ");
        _builder.append(" $");
        String _formatForCode = this._formattingExtensions.formatForCode(it.getIndexBy());
        _builder.append(_formatForCode, " ");
        _builder.newLineIfNotEmpty();
        _builder.append(" ");
        _builder.append("*");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* @return The desired ");
        String _entityClassName_2 = this._namingExtensions.entityClassName(it.getSource(), "", Boolean.valueOf(false));
        _builder.append(_entityClassName_2, " ");
        _builder.append(" instance");
        _builder.newLineIfNotEmpty();
        _builder.append(" ");
        _builder.append("* ");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* @throws \\InvalidArgumentException If desired index does not exist");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("*/");
        _builder.newLine();
        _builder.append("public function get");
        String _formatForCodeCapital = this._formattingExtensions.formatForCodeCapital(singleName);
        _builder.append(_formatForCodeCapital);
        _builder.append("($");
        String _formatForCode_1 = this._formattingExtensions.formatForCode(it.getIndexBy());
        _builder.append(_formatForCode_1);
        _builder.append(")");
        _builder.newLineIfNotEmpty();
        _builder.append("{");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("if (!isset($this->");
        String _formatForCode_2 = this._formattingExtensions.formatForCode(aliasName);
        _builder.append(_formatForCode_2, "    ");
        _builder.append("[$");
        String _formatForCode_3 = this._formattingExtensions.formatForCode(it.getIndexBy());
        _builder.append(_formatForCode_3, "    ");
        _builder.append("])) {");
        _builder.newLineIfNotEmpty();
        _builder.append("        ");
        _builder.append("throw new \\InvalidArgumentException(\"");
        String _formatForDisplayCapital = this._formattingExtensions.formatForDisplayCapital(it.getIndexBy());
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
        String _formatForCode_5 = this._formattingExtensions.formatForCode(it.getIndexBy());
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
    _builder.append("* Adds an instance of \\");
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
    _builder.append(" The instance to be added to the collection");
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
    CharSequence _addMethodImpl = this.addMethodImpl(it, useTarget, selfIsMany, name, nameSingle, type);
    _builder.append(_addMethodImpl);
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    return _builder;
  }
  
  private boolean isManyToMany(final JoinRelationship it) {
    boolean _switchResult = false;
    boolean _matched = false;
    if (it instanceof ManyToManyRelationship) {
      _matched=true;
      _switchResult = true;
    }
    if (!_matched) {
      _switchResult = false;
    }
    return _switchResult;
  }
  
  private CharSequence _addParameters(final JoinRelationship it, final Boolean useTarget, final String name, final String type) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("\\");
    _builder.append(type);
    _builder.append(" $");
    _builder.append(name);
    return _builder;
  }
  
  private CharSequence _addParameters(final OneToManyRelationship it, final Boolean useTarget, final String name, final String type) {
    StringConcatenation _builder = new StringConcatenation();
    {
      if (((!(useTarget).booleanValue()) && (!IterableExtensions.isEmpty(this._modelExtensions.getAggregateFields(it.getSource()))))) {
        final DerivedField targetField = this._modelJoinExtensions.getAggregateTargetField(IterableExtensions.<IntegerField>head(this._modelExtensions.getAggregateFields(it.getSource())));
        _builder.newLineIfNotEmpty();
        _builder.append("\\");
        String _fieldTypeAsString = this._modelExtensions.fieldTypeAsString(targetField);
        _builder.append(_fieldTypeAsString);
        _builder.append(" $");
        String _formatForCode = this._formattingExtensions.formatForCode(targetField.getName());
        _builder.append(_formatForCode);
        _builder.newLineIfNotEmpty();
        _builder.append("        ");
      } else {
        _builder.append("\\");
        _builder.append(type);
        _builder.append(" $");
        _builder.append(name);
      }
    }
    return _builder;
  }
  
  private CharSequence addMethodSignature(final JoinRelationship it, final Boolean useTarget, final String name, final String nameSingle, final String type) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("public function add");
    String _firstUpper = StringExtensions.toFirstUpper(name);
    _builder.append(_firstUpper);
    _builder.append("(");
    CharSequence _addParameters = this.addParameters(it, useTarget, nameSingle, type);
    _builder.append(_addParameters);
    _builder.append(")");
    return _builder;
  }
  
  private CharSequence addMethodImplDefault(final JoinRelationship it, final Boolean selfIsMany, final Boolean useTarget, final String name, final String nameSingle, final String type) {
    StringConcatenation _builder = new StringConcatenation();
    CharSequence _addMethodSignature = this.addMethodSignature(it, useTarget, name, nameSingle, type);
    _builder.append(_addMethodSignature);
    _builder.newLineIfNotEmpty();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$this->");
    _builder.append(name, "    ");
    {
      if ((selfIsMany).booleanValue()) {
        _builder.append("->add(");
      } else {
        _builder.append(" = ");
      }
    }
    _builder.append("$");
    _builder.append(nameSingle, "    ");
    {
      if ((selfIsMany).booleanValue()) {
        _builder.append(")");
      }
    }
    _builder.append(";");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    CharSequence _addInverseCalls = this.addInverseCalls(it, useTarget, nameSingle);
    _builder.append(_addInverseCalls, "    ");
    _builder.newLineIfNotEmpty();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence _addMethodImpl(final JoinRelationship it, final Boolean selfIsMany, final Boolean useTarget, final String name, final String nameSingle, final String type) {
    StringConcatenation _builder = new StringConcatenation();
    CharSequence _addMethodImplDefault = this.addMethodImplDefault(it, useTarget, selfIsMany, name, nameSingle, type);
    _builder.append(_addMethodImplDefault);
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  private CharSequence _addMethodImpl(final OneToManyRelationship it, final Boolean selfIsMany, final Boolean useTarget, final String name, final String nameSingle, final String type) {
    StringConcatenation _builder = new StringConcatenation();
    {
      if ((((!(useTarget).booleanValue()) && (null != it.getIndexBy())) && (!Objects.equal(it.getIndexBy(), "")))) {
        CharSequence _addMethodSignature = this.addMethodSignature(it, useTarget, name, nameSingle, type);
        _builder.append(_addMethodSignature);
        _builder.newLineIfNotEmpty();
        _builder.append("{");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("$this->");
        _builder.append(name, "    ");
        _builder.append("[$");
        _builder.append(nameSingle, "    ");
        _builder.append("->get");
        String _formatForCodeCapital = this._formattingExtensions.formatForCodeCapital(it.getIndexBy());
        _builder.append(_formatForCodeCapital, "    ");
        _builder.append("()] = $");
        _builder.append(nameSingle, "    ");
        _builder.append(";");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        CharSequence _addInverseCalls = this.addInverseCalls(it, useTarget, nameSingle);
        _builder.append(_addInverseCalls, "    ");
        _builder.newLineIfNotEmpty();
        _builder.append("}");
        _builder.newLine();
      } else {
        if (((!(useTarget).booleanValue()) && (!IterableExtensions.isEmpty(this._modelExtensions.getAggregateFields(it.getSource()))))) {
          CharSequence _addMethodSignature_1 = this.addMethodSignature(it, useTarget, name, nameSingle, type);
          _builder.append(_addMethodSignature_1);
          _builder.newLineIfNotEmpty();
          _builder.append("{");
          _builder.newLine();
          _builder.append("    ");
          final IntegerField sourceField = IterableExtensions.<IntegerField>head(this._modelExtensions.getAggregateFields(it.getSource()));
          _builder.newLineIfNotEmpty();
          _builder.append("    ");
          final DerivedField targetField = this._modelJoinExtensions.getAggregateTargetField(sourceField);
          _builder.newLineIfNotEmpty();
          _builder.append("    ");
          _builder.append("$");
          String _relationAliasName = this._namingExtensions.getRelationAliasName(it, Boolean.valueOf(true));
          _builder.append(_relationAliasName, "    ");
          _builder.append(" = new ");
          String _entityClassName = this._namingExtensions.entityClassName(it.getTarget(), "", Boolean.valueOf(false));
          _builder.append(_entityClassName, "    ");
          _builder.append("($this, $");
          String _formatForCode = this._formattingExtensions.formatForCode(targetField.getName());
          _builder.append(_formatForCode, "    ");
          _builder.append(");");
          _builder.newLineIfNotEmpty();
          _builder.append("    ");
          _builder.append("$this->");
          _builder.append(name, "    ");
          {
            if ((selfIsMany).booleanValue()) {
              _builder.append("[]");
            }
          }
          _builder.append(" = $");
          _builder.append(nameSingle, "    ");
          _builder.append(";");
          _builder.newLineIfNotEmpty();
          _builder.append("    ");
          _builder.append("$this->");
          String _formatForCode_1 = this._formattingExtensions.formatForCode(sourceField.getName());
          _builder.append(_formatForCode_1, "    ");
          _builder.append(" += $");
          String _formatForCode_2 = this._formattingExtensions.formatForCode(targetField.getName());
          _builder.append(_formatForCode_2, "    ");
          _builder.append(";");
          _builder.newLineIfNotEmpty();
          _builder.newLine();
          _builder.append("    ");
          _builder.append("return $");
          String _relationAliasName_1 = this._namingExtensions.getRelationAliasName(it, Boolean.valueOf(true));
          _builder.append(_relationAliasName_1, "    ");
          _builder.append(";");
          _builder.newLineIfNotEmpty();
          _builder.append("}");
          _builder.newLine();
          _builder.newLine();
          _builder.append("/**");
          _builder.newLine();
          _builder.append(" ");
          _builder.append("* Additional add function for internal use.");
          _builder.newLine();
          _builder.append(" ");
          _builder.append("*");
          _builder.newLine();
          _builder.append(" ");
          _builder.append("* @param ");
          String _fieldTypeAsString = this._modelExtensions.fieldTypeAsString(targetField);
          _builder.append(_fieldTypeAsString, " ");
          _builder.append(" $");
          String _formatForCode_3 = this._formattingExtensions.formatForCode(targetField.getName());
          _builder.append(_formatForCode_3, " ");
          _builder.append(" Given instance to be used for aggregation");
          _builder.newLineIfNotEmpty();
          _builder.append(" ");
          _builder.append("*/");
          _builder.newLine();
          _builder.append("protected function add");
          String _formatForCodeCapital_1 = this._formattingExtensions.formatForCodeCapital(targetField.getName());
          _builder.append(_formatForCodeCapital_1);
          _builder.append("Without");
          String _formatForCodeCapital_2 = this._formattingExtensions.formatForCodeCapital(this._namingExtensions.getRelationAliasName(it, Boolean.valueOf(true)));
          _builder.append(_formatForCodeCapital_2);
          _builder.append("($");
          String _formatForCode_4 = this._formattingExtensions.formatForCode(targetField.getName());
          _builder.append(_formatForCode_4);
          _builder.append(")");
          _builder.newLineIfNotEmpty();
          _builder.append("{");
          _builder.newLine();
          _builder.append("    ");
          _builder.append("$this->");
          String _formatForCode_5 = this._formattingExtensions.formatForCode(sourceField.getName());
          _builder.append(_formatForCode_5, "    ");
          _builder.append(" += $");
          String _formatForCode_6 = this._formattingExtensions.formatForCode(targetField.getName());
          _builder.append(_formatForCode_6, "    ");
          _builder.append(";");
          _builder.newLineIfNotEmpty();
          _builder.append("}");
          _builder.newLine();
        } else {
          CharSequence _addMethodImplDefault = this.addMethodImplDefault(it, useTarget, selfIsMany, name, nameSingle, type);
          _builder.append(_addMethodImplDefault);
          _builder.newLineIfNotEmpty();
        }
      }
    }
    return _builder;
  }
  
  private CharSequence _addMethodImpl(final ManyToManyRelationship it, final Boolean selfIsMany, final Boolean useTarget, final String name, final String nameSingle, final String type) {
    StringConcatenation _builder = new StringConcatenation();
    {
      if ((((!(useTarget).booleanValue()) && (null != it.getIndexBy())) && (!Objects.equal(it.getIndexBy(), "")))) {
        CharSequence _addMethodSignature = this.addMethodSignature(it, useTarget, name, nameSingle, type);
        _builder.append(_addMethodSignature);
        _builder.newLineIfNotEmpty();
        _builder.append("{");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("$this->");
        _builder.append(name, "    ");
        _builder.append("[$");
        _builder.append(nameSingle, "    ");
        _builder.append("->get");
        String _formatForCodeCapital = this._formattingExtensions.formatForCodeCapital(it.getIndexBy());
        _builder.append(_formatForCodeCapital, "    ");
        _builder.append("()] = $");
        _builder.append(nameSingle, "    ");
        _builder.append(";");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        CharSequence _addInverseCalls = this.addInverseCalls(it, useTarget, nameSingle);
        _builder.append(_addInverseCalls, "    ");
        _builder.newLineIfNotEmpty();
        _builder.append("}");
        _builder.newLine();
      } else {
        CharSequence _addMethodImplDefault = this.addMethodImplDefault(it, useTarget, selfIsMany, name, nameSingle, type);
        _builder.append(_addMethodImplDefault);
        _builder.newLineIfNotEmpty();
      }
    }
    return _builder;
  }
  
  private CharSequence addInverseCalls(final JoinRelationship it, final Boolean useTarget, final String nameSingle) {
    StringConcatenation _builder = new StringConcatenation();
    final boolean generateInverseCalls = (this.isBidirectional(it) && (((!this.isManyToMany(it)) && (useTarget).booleanValue()) || (this.isManyToMany(it) && (!(useTarget).booleanValue()))));
    _builder.newLineIfNotEmpty();
    {
      if (generateInverseCalls) {
        final String ownAliasName = StringExtensions.toFirstUpper(this._namingExtensions.getRelationAliasName(it, Boolean.valueOf((!(useTarget).booleanValue()))));
        _builder.newLineIfNotEmpty();
        final boolean otherIsMany = this._modelJoinExtensions.isManySide(it, (!(useTarget).booleanValue()));
        _builder.newLineIfNotEmpty();
        {
          if (otherIsMany) {
            _builder.append("$");
            _builder.append(nameSingle);
            _builder.append("->add");
            _builder.append(ownAliasName);
            _builder.append("($this);");
            _builder.newLineIfNotEmpty();
          } else {
            _builder.append("$");
            _builder.append(nameSingle);
            _builder.append("->set");
            _builder.append(ownAliasName);
            _builder.append("($this);");
            _builder.newLineIfNotEmpty();
          }
        }
      }
    }
    return _builder;
  }
  
  private CharSequence removeMethod(final JoinRelationship it, final Boolean useTarget, final Boolean selfIsMany, final String name, final String nameSingle, final String type) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Removes an instance of \\");
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
    _builder.append("* @param \\");
    _builder.append(type, " ");
    _builder.append(" $");
    _builder.append(nameSingle, " ");
    _builder.append(" The instance to be removed from the collection");
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
    _builder.append(_firstUpper);
    _builder.append("(\\");
    _builder.append(type);
    _builder.append(" $");
    _builder.append(nameSingle);
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
    final boolean generateInverseCalls = (this.isBidirectional(it) && (((!this.isManyToMany(it)) && (useTarget).booleanValue()) || (this.isManyToMany(it) && (!(useTarget).booleanValue()))));
    _builder.newLineIfNotEmpty();
    {
      if (generateInverseCalls) {
        _builder.append("    ");
        final String ownAliasName = StringExtensions.toFirstUpper(this._namingExtensions.getRelationAliasName(it, Boolean.valueOf((!(useTarget).booleanValue()))));
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        final boolean otherIsMany = this._modelJoinExtensions.isManySide(it, (!(useTarget).booleanValue()));
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
  
  private boolean isBidirectional(final JoinRelationship it) {
    boolean _xblockexpression = false;
    {
      boolean _matched = false;
      if (it instanceof OneToOneRelationship) {
        _matched=true;
        return ((OneToOneRelationship)it).isBidirectional();
      }
      if (!_matched) {
        if (it instanceof OneToManyRelationship) {
          _matched=true;
          return ((OneToManyRelationship)it).isBidirectional();
        }
      }
      if (!_matched) {
        if (it instanceof ManyToOneRelationship) {
          _matched=true;
          return false;
        }
      }
      if (!_matched) {
        if (it instanceof ManyToManyRelationship) {
          _matched=true;
          return ((ManyToManyRelationship)it).isBidirectional();
        }
      }
      _xblockexpression = false;
    }
    return _xblockexpression;
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
  
  private CharSequence addMethodImpl(final JoinRelationship it, final Boolean selfIsMany, final Boolean useTarget, final String name, final String nameSingle, final String type) {
    if (it instanceof ManyToManyRelationship) {
      return _addMethodImpl((ManyToManyRelationship)it, selfIsMany, useTarget, name, nameSingle, type);
    } else if (it instanceof OneToManyRelationship) {
      return _addMethodImpl((OneToManyRelationship)it, selfIsMany, useTarget, name, nameSingle, type);
    } else if (it != null) {
      return _addMethodImpl(it, selfIsMany, useTarget, name, nameSingle, type);
    } else {
      throw new IllegalArgumentException("Unhandled parameter types: " +
        Arrays.<Object>asList(it, selfIsMany, useTarget, name, nameSingle, type).toString());
    }
  }
}
