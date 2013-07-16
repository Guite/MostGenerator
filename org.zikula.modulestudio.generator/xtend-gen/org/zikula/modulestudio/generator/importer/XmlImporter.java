package org.zikula.modulestudio.generator.importer;

import com.google.common.base.Objects;
import com.google.inject.Injector;
import de.guite.modulestudio.metamodel.modulestudio.Application;
import de.guite.modulestudio.metamodel.modulestudio.BooleanField;
import de.guite.modulestudio.metamodel.modulestudio.Controllers;
import de.guite.modulestudio.metamodel.modulestudio.DateField;
import de.guite.modulestudio.metamodel.modulestudio.DatetimeField;
import de.guite.modulestudio.metamodel.modulestudio.DecimalField;
import de.guite.modulestudio.metamodel.modulestudio.DerivedField;
import de.guite.modulestudio.metamodel.modulestudio.EmailField;
import de.guite.modulestudio.metamodel.modulestudio.Entity;
import de.guite.modulestudio.metamodel.modulestudio.EntityField;
import de.guite.modulestudio.metamodel.modulestudio.EntityIndex;
import de.guite.modulestudio.metamodel.modulestudio.EntityIndexItem;
import de.guite.modulestudio.metamodel.modulestudio.FloatField;
import de.guite.modulestudio.metamodel.modulestudio.IntegerField;
import de.guite.modulestudio.metamodel.modulestudio.Models;
import de.guite.modulestudio.metamodel.modulestudio.ModulestudioFactory;
import de.guite.modulestudio.metamodel.modulestudio.ModulestudioPackage;
import de.guite.modulestudio.metamodel.modulestudio.StringField;
import de.guite.modulestudio.metamodel.modulestudio.TextField;
import de.guite.modulestudio.metamodel.modulestudio.UploadField;
import de.guite.modulestudio.metamodel.modulestudio.UrlField;
import de.guite.modulestudio.metamodel.modulestudio.UserField;
import de.guite.modulestudio.metamodel.modulestudio.Views;
import de.guite.modulestudio.ui.internal.MostDslActivator;
import java.io.IOException;
import java.util.Collections;
import java.util.List;
import org.eclipse.emf.common.util.EList;
import org.eclipse.emf.common.util.URI;
import org.eclipse.emf.ecore.EClass;
import org.eclipse.emf.ecore.EObject;
import org.eclipse.emf.ecore.EPackage.Registry;
import org.eclipse.emf.ecore.resource.Resource;
import org.eclipse.xtext.resource.XtextResource;
import org.eclipse.xtext.resource.XtextResourceSet;
import org.eclipse.xtext.xbase.lib.Conversions;
import org.eclipse.xtext.xbase.lib.Exceptions;
import org.eclipse.xtext.xbase.lib.IterableExtensions;
import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;
import org.zikula.modulestudio.generator.importer.XmlReader;

/**
 * This class allows the creation of new models by importing a given xml file
 * which has previously been created from a pntables.php file.
 */
@SuppressWarnings("all")
public class XmlImporter {
  /**
   * The application.
   */
  private Application app;
  
  /**
   * The factory for creating semantic elements.
   */
  private ModulestudioFactory factory;
  
  /**
   * Application name.
   */
  private String appName;
  
  /**
   * The xml input document.
   */
  private Document document;
  
  /**
   * The constructor reading the input file.
   * 
   * @param fileName Name of the xml input file.
   * @throws Exception In case something goes wrong.
   */
  public XmlImporter(final String fileName) throws Exception {
    boolean _isEmpty = fileName.isEmpty();
    if (_isEmpty) {
      Exception _exception = new Exception(
        "Error: invalid filename given. Please provide an xml file.");
      throw _exception;
    }
    XmlReader _xmlReader = new XmlReader(fileName);
    final XmlReader xmlReader = _xmlReader;
    final String[] fileNameParts = fileName.split("/");
    int _size = ((List<String>)Conversions.doWrapArray(fileNameParts)).size();
    int _minus = (_size - 1);
    String _get = fileNameParts[_minus];
    String _replaceAll = _get.replaceAll(" ", "");
    final String rawFileName = _replaceAll.replaceAll(".xml", "");
    String _convertToMixedCase = this.convertToMixedCase(rawFileName);
    this.appName = _convertToMixedCase;
    this.document = xmlReader.document;
  }
  
  /**
   * Wrapper for the actual import process.
   */
  public void process() {
    this.createModel();
    this.processElements();
    this.saveModel();
  }
  
  /**
   * Creates the model instance and sets basic properties.
   */
  private void createModel() {
    this.factory = ModulestudioFactory.eINSTANCE;
    Application _createApplication = this.factory.createApplication();
    this.app = _createApplication;
    this.app.setName(this.appName);
    final Models modelContainer = this.factory.createModels();
    modelContainer.setName("Model");
    EList<Models> _models = this.app.getModels();
    _models.add(modelContainer);
    final Controllers controllerContainer = this.factory.createControllers();
    controllerContainer.setName("Controller");
    EList<Controllers> _controllers = this.app.getControllers();
    _controllers.add(controllerContainer);
    final Views viewContainer = this.factory.createViews();
    viewContainer.setName("View");
    EList<Views> _views = this.app.getViews();
    _views.add(viewContainer);
    EList<Models> _modelContext = controllerContainer.getModelContext();
    _modelContext.add(modelContainer);
    controllerContainer.setProcessViews(viewContainer);
  }
  
  /**
   * Processes the elements in the xml file.
   */
  private void processElements() {
    final NodeList nodes = this.document.getElementsByTagName("table");
    EList<Models> _models = this.app.getModels();
    final Models modelContainer = IterableExtensions.<Models>head(_models);
    int i = 0;
    int _length = nodes.getLength();
    boolean _lessThan = (i < _length);
    boolean _while = _lessThan;
    while (_while) {
      {
        int _plus = (i + 1);
        i = _plus;
        int _minus = (i - 1);
        Node _item = nodes.item(_minus);
        final Element table = ((Element) _item);
        final Entity entity = this.factory.createEntity();
        final NodeList fields = table.getElementsByTagName("column");
        String entityName = table.getAttribute("name");
        boolean _and = false;
        boolean _isEmpty = entityName.isEmpty();
        boolean _not = (!_isEmpty);
        if (!_not) {
          _and = false;
        } else {
          int _length_1 = fields.getLength();
          boolean _greaterThan = (_length_1 > 0);
          _and = (_not && _greaterThan);
        }
        if (_and) {
          boolean _isEmpty_1 = entityName.isEmpty();
          if (_isEmpty_1) {
            String _string = Integer.valueOf(i).toString();
            String _plus_1 = ("Table " + _string);
            entityName = _plus_1;
          }
          entity.setName(entityName);
          entity.setNameMultiple(entityName);
          String _attribute = table.getAttribute("enableAttribution");
          boolean _equalsIgnoreCase = _attribute.equalsIgnoreCase("true");
          entity.setAttributable(_equalsIgnoreCase);
          String _attribute_1 = table.getAttribute("enableCategorization");
          boolean _equalsIgnoreCase_1 = _attribute_1.equalsIgnoreCase("true");
          entity.setCategorisable(_equalsIgnoreCase_1);
          int j = 0;
          int _length_2 = fields.getLength();
          boolean _lessThan_1 = (j < _length_2);
          boolean _while_1 = _lessThan_1;
          while (_while_1) {
            {
              Node _item_1 = fields.item(j);
              final Element fieldData = ((Element) _item_1);
              String _attribute_2 = fieldData.getAttribute("name");
              boolean _isStandardField = this.isStandardField(_attribute_2);
              boolean _not_1 = (!_isStandardField);
              if (_not_1) {
                this.processField(entity, fieldData);
              }
              int _plus_2 = (j + 1);
              j = _plus_2;
            }
            int _length_3 = fields.getLength();
            boolean _lessThan_2 = (j < _length_3);
            _while_1 = _lessThan_2;
          }
          final NodeList indexes = table.getElementsByTagName("index");
          j = 0;
          int _length_3 = indexes.getLength();
          boolean _lessThan_2 = (j < _length_3);
          boolean _while_2 = _lessThan_2;
          while (_while_2) {
            {
              Node _item_1 = indexes.item(j);
              final Element indexData = ((Element) _item_1);
              this.processIndex(entity, indexData);
              int _plus_2 = (j + 1);
              j = _plus_2;
            }
            int _length_4 = indexes.getLength();
            boolean _lessThan_3 = (j < _length_4);
            _while_2 = _lessThan_3;
          }
          EList<Entity> _entities = modelContainer.getEntities();
          _entities.add(entity);
        }
      }
      int _length_1 = nodes.getLength();
      boolean _lessThan_1 = (i < _length_1);
      _while = _lessThan_1;
    }
  }
  
  /**
   * Determines whether a given field name should be considered as a standard field or not.
   * 
   * @param fieldName Name of given field.
   * @return boolean whether it is a standard field or not.
   */
  private boolean isStandardField(final String fieldName) {
    boolean _or = false;
    boolean _or_1 = false;
    boolean _or_2 = false;
    boolean _or_3 = false;
    boolean _equalsIgnoreCase = fieldName.equalsIgnoreCase("obj_status");
    if (_equalsIgnoreCase) {
      _or_3 = true;
    } else {
      boolean _equalsIgnoreCase_1 = fieldName.equalsIgnoreCase("cr_date");
      _or_3 = (_equalsIgnoreCase || _equalsIgnoreCase_1);
    }
    if (_or_3) {
      _or_2 = true;
    } else {
      boolean _equalsIgnoreCase_2 = fieldName.equalsIgnoreCase("cr_uid");
      _or_2 = (_or_3 || _equalsIgnoreCase_2);
    }
    if (_or_2) {
      _or_1 = true;
    } else {
      boolean _equalsIgnoreCase_3 = fieldName.equalsIgnoreCase("lu_date");
      _or_1 = (_or_2 || _equalsIgnoreCase_3);
    }
    if (_or_1) {
      _or = true;
    } else {
      boolean _equalsIgnoreCase_4 = fieldName.equalsIgnoreCase("lu_uid");
      _or = (_or_1 || _equalsIgnoreCase_4);
    }
    return _or;
  }
  
  /**
   * Processes a given field.
   * 
   * @param it The {@link Entity} where this field belongs to.
   * @param fieldData Xml input data for the field.
   */
  private Boolean processField(final Entity it, final Element fieldData) {
    Boolean _xblockexpression = null;
    {
      final String fieldName = fieldData.getAttribute("name");
      String _attribute = fieldData.getAttribute("type");
      final String fieldType = _attribute.toUpperCase();
      final String fieldLength = fieldData.getAttribute("length");
      final String fieldNullable = fieldData.getAttribute("nullable");
      final String fieldDefault = fieldData.getAttribute("default");
      Boolean _xifexpression = null;
      boolean _and = false;
      boolean _and_1 = false;
      boolean _isEmpty = fieldName.isEmpty();
      boolean _not = (!_isEmpty);
      if (!_not) {
        _and_1 = false;
      } else {
        boolean _isEmpty_1 = fieldType.isEmpty();
        boolean _not_1 = (!_isEmpty_1);
        _and_1 = (_not && _not_1);
      }
      if (!_and_1) {
        _and = false;
      } else {
        boolean _isEmpty_2 = fieldNullable.isEmpty();
        boolean _not_2 = (!_isEmpty_2);
        _and = (_and_1 && _not_2);
      }
      if (_and) {
        Boolean _xifexpression_1 = null;
        boolean _equals = fieldType.equals("BOOLEAN");
        if (_equals) {
          boolean _xblockexpression_1 = false;
          {
            final BooleanField field = this.factory.createBooleanField();
            this.setBasicFieldProperties(field, fieldData);
            String _xifexpression_2 = null;
            boolean _and_2 = false;
            boolean _isEmpty_3 = fieldDefault.isEmpty();
            boolean _not_3 = (!_isEmpty_3);
            if (!_not_3) {
              _and_2 = false;
            } else {
              String _lowerCase = fieldDefault.toLowerCase();
              boolean _equals_1 = Objects.equal(_lowerCase, "true");
              _and_2 = (_not_3 && _equals_1);
            }
            if (_and_2) {
              _xifexpression_2 = "true";
            } else {
              _xifexpression_2 = "false";
            }
            field.setDefaultValue(_xifexpression_2);
            EList<EntityField> _fields = it.getFields();
            boolean _add = _fields.add(field);
            _xblockexpression_1 = (_add);
          }
          _xifexpression_1 = Boolean.valueOf(_xblockexpression_1);
        } else {
          Boolean _xifexpression_2 = null;
          boolean _or = false;
          boolean _or_1 = false;
          boolean _or_2 = false;
          boolean _or_3 = false;
          boolean _equals_1 = fieldType.equals("INT");
          if (_equals_1) {
            _or_3 = true;
          } else {
            boolean _equals_2 = fieldType.equals("TINYINT");
            _or_3 = (_equals_1 || _equals_2);
          }
          if (_or_3) {
            _or_2 = true;
          } else {
            boolean _equals_3 = fieldType.equals("SMALLINT");
            _or_2 = (_or_3 || _equals_3);
          }
          if (_or_2) {
            _or_1 = true;
          } else {
            boolean _equals_4 = fieldType.equals("MEDIUMINT");
            _or_1 = (_or_2 || _equals_4);
          }
          if (_or_1) {
            _or = true;
          } else {
            boolean _equals_5 = fieldType.equals("BIGINT");
            _or = (_or_1 || _equals_5);
          }
          if (_or) {
            boolean _xblockexpression_2 = false;
            {
              final String fieldAutoInc = fieldData.getAttribute("autoincrement");
              final String fieldPrimary = fieldData.getAttribute("primary");
              boolean _xifexpression_3 = false;
              boolean _or_4 = false;
              boolean _or_5 = false;
              boolean _or_6 = false;
              boolean _equalsIgnoreCase = fieldName.equalsIgnoreCase("uid");
              if (_equalsIgnoreCase) {
                _or_6 = true;
              } else {
                boolean _equalsIgnoreCase_1 = fieldName.equalsIgnoreCase("userid");
                _or_6 = (_equalsIgnoreCase || _equalsIgnoreCase_1);
              }
              if (_or_6) {
                _or_5 = true;
              } else {
                boolean _equalsIgnoreCase_2 = fieldName.equalsIgnoreCase("user_id");
                _or_5 = (_or_6 || _equalsIgnoreCase_2);
              }
              if (_or_5) {
                _or_4 = true;
              } else {
                boolean _equalsIgnoreCase_3 = fieldName.equalsIgnoreCase("user");
                _or_4 = (_or_5 || _equalsIgnoreCase_3);
              }
              if (_or_4) {
                boolean _xblockexpression_3 = false;
                {
                  final UserField field = this.factory.createUserField();
                  this.setBasicFieldProperties(field, fieldData);
                  boolean _isEmpty_3 = fieldLength.isEmpty();
                  boolean _not_3 = (!_isEmpty_3);
                  if (_not_3) {
                    int _parseInt = Integer.parseInt(fieldLength);
                    field.setLength(_parseInt);
                  } else {
                    int _integerLength = this.getIntegerLength(fieldType);
                    field.setLength(_integerLength);
                  }
                  boolean _and_2 = false;
                  boolean _equalsIgnoreCase_4 = fieldPrimary.equalsIgnoreCase("true");
                  if (!_equalsIgnoreCase_4) {
                    _and_2 = false;
                  } else {
                    boolean _equalsIgnoreCase_5 = fieldAutoInc.equalsIgnoreCase("true");
                    _and_2 = (_equalsIgnoreCase_4 && _equalsIgnoreCase_5);
                  }
                  field.setPrimaryKey(_and_2);
                  boolean _isEmpty_4 = fieldDefault.isEmpty();
                  boolean _not_4 = (!_isEmpty_4);
                  if (_not_4) {
                    int _parseInt_1 = Integer.parseInt(fieldDefault);
                    String _string = Integer.valueOf(_parseInt_1).toString();
                    field.setDefaultValue(_string);
                  }
                  EList<EntityField> _fields = it.getFields();
                  boolean _add = _fields.add(field);
                  _xblockexpression_3 = (_add);
                }
                _xifexpression_3 = _xblockexpression_3;
              } else {
                boolean _xblockexpression_4 = false;
                {
                  final IntegerField field = this.factory.createIntegerField();
                  this.setBasicFieldProperties(field, fieldData);
                  boolean _isEmpty_3 = fieldLength.isEmpty();
                  boolean _not_3 = (!_isEmpty_3);
                  if (_not_3) {
                    int _parseInt = Integer.parseInt(fieldLength);
                    field.setLength(_parseInt);
                  } else {
                    int _integerLength = this.getIntegerLength(fieldType);
                    field.setLength(_integerLength);
                  }
                  boolean _and_2 = false;
                  boolean _equalsIgnoreCase_4 = fieldPrimary.equalsIgnoreCase("true");
                  if (!_equalsIgnoreCase_4) {
                    _and_2 = false;
                  } else {
                    boolean _equalsIgnoreCase_5 = fieldAutoInc.equalsIgnoreCase("true");
                    _and_2 = (_equalsIgnoreCase_4 && _equalsIgnoreCase_5);
                  }
                  field.setPrimaryKey(_and_2);
                  boolean _isEmpty_4 = fieldDefault.isEmpty();
                  boolean _not_4 = (!_isEmpty_4);
                  if (_not_4) {
                    int _parseInt_1 = Integer.parseInt(fieldDefault);
                    String _string = Integer.valueOf(_parseInt_1).toString();
                    field.setDefaultValue(_string);
                  }
                  EList<EntityField> _fields = it.getFields();
                  boolean _add = _fields.add(field);
                  _xblockexpression_4 = (_add);
                }
                _xifexpression_3 = _xblockexpression_4;
              }
              _xblockexpression_2 = (_xifexpression_3);
            }
            _xifexpression_2 = Boolean.valueOf(_xblockexpression_2);
          } else {
            Boolean _xifexpression_3 = null;
            boolean _equals_6 = fieldType.equals("VARCHAR");
            if (_equals_6) {
              boolean _xifexpression_4 = false;
              boolean _or_4 = false;
              boolean _or_5 = false;
              boolean _or_6 = false;
              boolean _or_7 = false;
              boolean _or_8 = false;
              boolean _or_9 = false;
              boolean _or_10 = false;
              boolean _equals_7 = fieldName.equals("file");
              if (_equals_7) {
                _or_10 = true;
              } else {
                boolean _equals_8 = fieldName.equals("filename");
                _or_10 = (_equals_7 || _equals_8);
              }
              if (_or_10) {
                _or_9 = true;
              } else {
                boolean _equalsIgnoreCase = fieldName.equalsIgnoreCase("image");
                _or_9 = (_or_10 || _equalsIgnoreCase);
              }
              if (_or_9) {
                _or_8 = true;
              } else {
                boolean _equalsIgnoreCase_1 = fieldName.equalsIgnoreCase("imagefile");
                _or_8 = (_or_9 || _equalsIgnoreCase_1);
              }
              if (_or_8) {
                _or_7 = true;
              } else {
                boolean _equalsIgnoreCase_2 = fieldName.equalsIgnoreCase("video");
                _or_7 = (_or_8 || _equalsIgnoreCase_2);
              }
              if (_or_7) {
                _or_6 = true;
              } else {
                boolean _equalsIgnoreCase_3 = fieldName.equalsIgnoreCase("videofile");
                _or_6 = (_or_7 || _equalsIgnoreCase_3);
              }
              if (_or_6) {
                _or_5 = true;
              } else {
                boolean _equalsIgnoreCase_4 = fieldName.equalsIgnoreCase("upload");
                _or_5 = (_or_6 || _equalsIgnoreCase_4);
              }
              if (_or_5) {
                _or_4 = true;
              } else {
                boolean _equalsIgnoreCase_5 = fieldName.equalsIgnoreCase("uploadfile");
                _or_4 = (_or_5 || _equalsIgnoreCase_5);
              }
              if (_or_4) {
                boolean _xblockexpression_3 = false;
                {
                  final UploadField field = this.factory.createUploadField();
                  this.setBasicFieldProperties(field, fieldData);
                  boolean _isEmpty_3 = fieldLength.isEmpty();
                  boolean _not_3 = (!_isEmpty_3);
                  if (_not_3) {
                    int _parseInt = Integer.parseInt(fieldLength);
                    field.setLength(_parseInt);
                  }
                  EList<EntityField> _fields = it.getFields();
                  boolean _add = _fields.add(field);
                  _xblockexpression_3 = (_add);
                }
                _xifexpression_4 = _xblockexpression_3;
              } else {
                boolean _xifexpression_5 = false;
                boolean _or_11 = false;
                boolean _or_12 = false;
                boolean _equalsIgnoreCase_6 = fieldName.equalsIgnoreCase("email");
                if (_equalsIgnoreCase_6) {
                  _or_12 = true;
                } else {
                  boolean _equalsIgnoreCase_7 = fieldName.equalsIgnoreCase("emailaddress");
                  _or_12 = (_equalsIgnoreCase_6 || _equalsIgnoreCase_7);
                }
                if (_or_12) {
                  _or_11 = true;
                } else {
                  boolean _equalsIgnoreCase_8 = fieldName.equalsIgnoreCase("mailaddress");
                  _or_11 = (_or_12 || _equalsIgnoreCase_8);
                }
                if (_or_11) {
                  boolean _xblockexpression_4 = false;
                  {
                    final EmailField field = this.factory.createEmailField();
                    this.setBasicFieldProperties(field, fieldData);
                    boolean _isEmpty_3 = fieldLength.isEmpty();
                    boolean _not_3 = (!_isEmpty_3);
                    if (_not_3) {
                      int _parseInt = Integer.parseInt(fieldLength);
                      field.setLength(_parseInt);
                    }
                    boolean _isEmpty_4 = fieldDefault.isEmpty();
                    boolean _not_4 = (!_isEmpty_4);
                    if (_not_4) {
                      field.setDefaultValue(fieldDefault);
                    }
                    EList<EntityField> _fields = it.getFields();
                    boolean _add = _fields.add(field);
                    _xblockexpression_4 = (_add);
                  }
                  _xifexpression_5 = _xblockexpression_4;
                } else {
                  boolean _xifexpression_6 = false;
                  boolean _or_13 = false;
                  boolean _or_14 = false;
                  boolean _equalsIgnoreCase_9 = fieldName.equalsIgnoreCase("url");
                  if (_equalsIgnoreCase_9) {
                    _or_14 = true;
                  } else {
                    boolean _equalsIgnoreCase_10 = fieldName.equalsIgnoreCase("homepage");
                    _or_14 = (_equalsIgnoreCase_9 || _equalsIgnoreCase_10);
                  }
                  if (_or_14) {
                    _or_13 = true;
                  } else {
                    boolean _equalsIgnoreCase_11 = fieldName.equalsIgnoreCase("website");
                    _or_13 = (_or_14 || _equalsIgnoreCase_11);
                  }
                  if (_or_13) {
                    boolean _xblockexpression_5 = false;
                    {
                      final UrlField field = this.factory.createUrlField();
                      this.setBasicFieldProperties(field, fieldData);
                      boolean _isEmpty_3 = fieldLength.isEmpty();
                      boolean _not_3 = (!_isEmpty_3);
                      if (_not_3) {
                        int _parseInt = Integer.parseInt(fieldLength);
                        field.setLength(_parseInt);
                      }
                      boolean _isEmpty_4 = fieldDefault.isEmpty();
                      boolean _not_4 = (!_isEmpty_4);
                      if (_not_4) {
                        field.setDefaultValue(fieldDefault);
                      }
                      EList<EntityField> _fields = it.getFields();
                      boolean _add = _fields.add(field);
                      _xblockexpression_5 = (_add);
                    }
                    _xifexpression_6 = _xblockexpression_5;
                  } else {
                    boolean _xblockexpression_6 = false;
                    {
                      final StringField field = this.factory.createStringField();
                      this.setBasicFieldProperties(field, fieldData);
                      boolean _isEmpty_3 = fieldLength.isEmpty();
                      boolean _not_3 = (!_isEmpty_3);
                      if (_not_3) {
                        int _parseInt = Integer.parseInt(fieldLength);
                        field.setLength(_parseInt);
                      }
                      boolean _equalsIgnoreCase_12 = fieldName.equalsIgnoreCase("country");
                      if (_equalsIgnoreCase_12) {
                        field.setCountry(true);
                        field.setNospace(true);
                      } else {
                        boolean _or_15 = false;
                        boolean _equalsIgnoreCase_13 = fieldName.equalsIgnoreCase("colour");
                        if (_equalsIgnoreCase_13) {
                          _or_15 = true;
                        } else {
                          boolean _equalsIgnoreCase_14 = fieldName.equalsIgnoreCase("color");
                          _or_15 = (_equalsIgnoreCase_13 || _equalsIgnoreCase_14);
                        }
                        if (_or_15) {
                          field.setHtmlcolour(true);
                          field.setNospace(true);
                        } else {
                          boolean _or_16 = false;
                          boolean _or_17 = false;
                          boolean _equalsIgnoreCase_15 = fieldName.equalsIgnoreCase("language");
                          if (_equalsIgnoreCase_15) {
                            _or_17 = true;
                          } else {
                            boolean _equalsIgnoreCase_16 = fieldName.equalsIgnoreCase("lang");
                            _or_17 = (_equalsIgnoreCase_15 || _equalsIgnoreCase_16);
                          }
                          if (_or_17) {
                            _or_16 = true;
                          } else {
                            boolean _equalsIgnoreCase_17 = fieldName.equalsIgnoreCase("locale");
                            _or_16 = (_or_17 || _equalsIgnoreCase_17);
                          }
                          if (_or_16) {
                            field.setLanguage(true);
                            field.setNospace(true);
                          }
                        }
                      }
                      boolean _isEmpty_4 = fieldDefault.isEmpty();
                      boolean _not_4 = (!_isEmpty_4);
                      if (_not_4) {
                        field.setDefaultValue(fieldDefault);
                      }
                      EList<EntityField> _fields = it.getFields();
                      boolean _add = _fields.add(field);
                      _xblockexpression_6 = (_add);
                    }
                    _xifexpression_6 = _xblockexpression_6;
                  }
                  _xifexpression_5 = _xifexpression_6;
                }
                _xifexpression_4 = _xifexpression_5;
              }
              _xifexpression_3 = Boolean.valueOf(_xifexpression_4);
            } else {
              Boolean _xifexpression_7 = null;
              boolean _or_15 = false;
              boolean _equals_9 = fieldType.equals("TEXT");
              if (_equals_9) {
                _or_15 = true;
              } else {
                boolean _equals_10 = fieldType.equals("LONGTEXT");
                _or_15 = (_equals_9 || _equals_10);
              }
              if (_or_15) {
                boolean _xblockexpression_7 = false;
                {
                  final TextField field = this.factory.createTextField();
                  this.setBasicFieldProperties(field, fieldData);
                  boolean _isEmpty_3 = fieldLength.isEmpty();
                  boolean _not_3 = (!_isEmpty_3);
                  if (_not_3) {
                    int _parseInt = Integer.parseInt(fieldLength);
                    field.setLength(_parseInt);
                  }
                  boolean _isEmpty_4 = fieldDefault.isEmpty();
                  boolean _not_4 = (!_isEmpty_4);
                  if (_not_4) {
                    field.setDefaultValue(fieldDefault);
                  }
                  EList<EntityField> _fields = it.getFields();
                  boolean _add = _fields.add(field);
                  _xblockexpression_7 = (_add);
                }
                _xifexpression_7 = Boolean.valueOf(_xblockexpression_7);
              } else {
                Boolean _xifexpression_8 = null;
                boolean _equals_11 = fieldType.equals("NUMERIC");
                if (_equals_11) {
                  boolean _xblockexpression_8 = false;
                  {
                    final DecimalField field = this.factory.createDecimalField();
                    this.setBasicFieldProperties(field, fieldData);
                    boolean _isEmpty_3 = fieldLength.isEmpty();
                    boolean _not_3 = (!_isEmpty_3);
                    if (_not_3) {
                      int _parseInt = Integer.parseInt(fieldLength);
                      field.setLength(_parseInt);
                    }
                    boolean _isEmpty_4 = fieldDefault.isEmpty();
                    boolean _not_4 = (!_isEmpty_4);
                    if (_not_4) {
                      float _parseFloat = Float.parseFloat(fieldDefault);
                      String _string = Float.valueOf(_parseFloat).toString();
                      field.setDefaultValue(_string);
                    }
                    EList<EntityField> _fields = it.getFields();
                    boolean _add = _fields.add(field);
                    _xblockexpression_8 = (_add);
                  }
                  _xifexpression_8 = Boolean.valueOf(_xblockexpression_8);
                } else {
                  Boolean _xifexpression_9 = null;
                  boolean _equals_12 = fieldType.equals("FLOAT");
                  if (_equals_12) {
                    boolean _xblockexpression_9 = false;
                    {
                      final FloatField field = this.factory.createFloatField();
                      this.setBasicFieldProperties(field, fieldData);
                      boolean _isEmpty_3 = fieldLength.isEmpty();
                      boolean _not_3 = (!_isEmpty_3);
                      if (_not_3) {
                        int _parseInt = Integer.parseInt(fieldLength);
                        field.setLength(_parseInt);
                      }
                      boolean _isEmpty_4 = fieldDefault.isEmpty();
                      boolean _not_4 = (!_isEmpty_4);
                      if (_not_4) {
                        float _parseFloat = Float.parseFloat(fieldDefault);
                        String _string = Float.valueOf(_parseFloat).toString();
                        field.setDefaultValue(_string);
                      }
                      EList<EntityField> _fields = it.getFields();
                      boolean _add = _fields.add(field);
                      _xblockexpression_9 = (_add);
                    }
                    _xifexpression_9 = Boolean.valueOf(_xblockexpression_9);
                  } else {
                    Boolean _xifexpression_10 = null;
                    boolean _equals_13 = fieldType.equals("DATETIME");
                    if (_equals_13) {
                      boolean _xblockexpression_10 = false;
                      {
                        final DatetimeField field = this.factory.createDatetimeField();
                        this.setBasicFieldProperties(field, fieldData);
                        boolean _isEmpty_3 = fieldDefault.isEmpty();
                        boolean _not_3 = (!_isEmpty_3);
                        if (_not_3) {
                          field.setDefaultValue(fieldDefault);
                        }
                        EList<EntityField> _fields = it.getFields();
                        boolean _add = _fields.add(field);
                        _xblockexpression_10 = (_add);
                      }
                      _xifexpression_10 = Boolean.valueOf(_xblockexpression_10);
                    } else {
                      Boolean _xifexpression_11 = null;
                      boolean _equals_14 = fieldType.equals("DATE");
                      if (_equals_14) {
                        boolean _xblockexpression_11 = false;
                        {
                          final DateField field = this.factory.createDateField();
                          this.setBasicFieldProperties(field, fieldData);
                          boolean _isEmpty_3 = fieldDefault.isEmpty();
                          boolean _not_3 = (!_isEmpty_3);
                          if (_not_3) {
                            field.setDefaultValue(fieldDefault);
                          }
                          EList<EntityField> _fields = it.getFields();
                          boolean _add = _fields.add(field);
                          _xblockexpression_11 = (_add);
                        }
                        _xifexpression_11 = Boolean.valueOf(_xblockexpression_11);
                      }
                      _xifexpression_10 = _xifexpression_11;
                    }
                    _xifexpression_9 = _xifexpression_10;
                  }
                  _xifexpression_8 = _xifexpression_9;
                }
                _xifexpression_7 = _xifexpression_8;
              }
              _xifexpression_3 = _xifexpression_7;
            }
            _xifexpression_2 = _xifexpression_3;
          }
          _xifexpression_1 = _xifexpression_2;
        }
        _xifexpression = _xifexpression_1;
      }
      _xblockexpression = (_xifexpression);
    }
    return _xblockexpression;
  }
  
  /**
   * Returns the length for an integer field, depending on a given field type.
   * 
   * @param fieldType The given integer type.
   * @return integer The proposed length for this integer field.
   */
  private int getIntegerLength(final String fieldType) {
    int _xblockexpression = (int) 0;
    {
      int result = 0;
      boolean _equals = fieldType.equals("INT");
      if (_equals) {
        result = 4;
      }
      boolean _equals_1 = fieldType.equals("TINYINT");
      if (_equals_1) {
        result = 1;
      }
      boolean _equals_2 = fieldType.equals("SMALLINT");
      if (_equals_2) {
        result = 2;
      }
      boolean _equals_3 = fieldType.equals("MEDIUMINT");
      if (_equals_3) {
        result = 4;
      }
      boolean _equals_4 = fieldType.equals("BIGINT");
      if (_equals_4) {
        result = 8;
      }
      boolean _equals_5 = (result == 0);
      if (_equals_5) {
        result = 10;
      }
      _xblockexpression = (result);
    }
    return _xblockexpression;
  }
  
  /**
   * Configures basic field properties.
   * 
   * @param it The {@link DerivedField} which should be configured.
   * @param fieldData Xml input data for the field.
   * @return Object The block expression of this method.
   */
  private void setBasicFieldProperties(final DerivedField it, final Element fieldData) {
    String _attribute = fieldData.getAttribute("name");
    final String fieldName = this.convertToMixedCase(_attribute);
    final String fieldType = fieldData.getAttribute("type");
    String _attribute_1 = fieldData.getAttribute("nullable");
    final String fieldNullable = _attribute_1.toLowerCase();
    final String fieldDefault = fieldData.getAttribute("default");
    boolean _or = false;
    boolean _equals = fieldType.equals("DATETIME");
    if (_equals) {
      _or = true;
    } else {
      boolean _equals_1 = fieldType.equals("DATE");
      _or = (_equals || _equals_1);
    }
    final boolean isDateField = _or;
    it.setName(fieldName);
    boolean _equals_2 = fieldNullable.equals("true");
    it.setNullable(_equals_2);
    boolean _and = false;
    boolean _and_1 = false;
    boolean _isEmpty = fieldDefault.isEmpty();
    boolean _not = (!_isEmpty);
    if (!_not) {
      _and_1 = false;
    } else {
      boolean _equals_3 = fieldDefault.equals("\'\'");
      boolean _not_1 = (!_equals_3);
      _and_1 = (_not && _not_1);
    }
    if (!_and_1) {
      _and = false;
    } else {
      boolean _equals_4 = fieldDefault.equals("NULL");
      boolean _not_2 = (!_equals_4);
      _and = (_and_1 && _not_2);
    }
    if (_and) {
      boolean _equals_5 = fieldType.equals("BOOLEAN");
      if (_equals_5) {
        boolean _or_1 = false;
        boolean _equalsIgnoreCase = fieldDefault.equalsIgnoreCase("true");
        if (_equalsIgnoreCase) {
          _or_1 = true;
        } else {
          boolean _equals_6 = fieldDefault.equals("1");
          _or_1 = (_equalsIgnoreCase || _equals_6);
        }
        final boolean isSet = _or_1;
        String _xifexpression = null;
        if (isSet) {
          _xifexpression = "true";
        } else {
          _xifexpression = "false";
        }
        it.setDefaultValue(_xifexpression);
      } else {
        boolean _and_2 = false;
        if (!isDateField) {
          _and_2 = false;
        } else {
          boolean _equals_7 = fieldDefault.equals("DEFTIMESTAMP");
          _and_2 = (isDateField && _equals_7);
        }
        boolean _not_3 = (!_and_2);
        if (_not_3) {
          it.setDefaultValue(fieldDefault);
        }
      }
    }
  }
  
  /**
   * Converts a given field name to mixed case.
   * 
   * @param fieldName The given field name.
   * @return string The field name in mixed case.
   */
  private String convertToMixedCase(final String fieldName) {
    String _xblockexpression = null;
    {
      String result = "";
      boolean _contains = fieldName.contains("_");
      boolean _not = (!_contains);
      if (_not) {
        result = fieldName;
      } else {
        final String[] fieldNameParts = fieldName.split("_");
        StringBuilder _stringBuilder = new StringBuilder();
        final StringBuilder sb = _stringBuilder;
        for (final String fieldNamePart : fieldNameParts) {
          {
            String _substring = fieldNamePart.substring(0, 1);
            String _upperCase = _substring.toUpperCase();
            sb.append(_upperCase);
            String _substring_1 = fieldNamePart.substring(1);
            String _lowerCase = _substring_1.toLowerCase();
            sb.append(_lowerCase);
          }
        }
        String _string = sb.toString();
        result = _string;
      }
      _xblockexpression = (result);
    }
    return _xblockexpression;
  }
  
  /**
   * Processes a given index.
   * 
   * @param it The {@link EntityIndex} which should be processed.
   * @param indexData Xml input data for the index.
   * @return boolean whether everything was okay or not.
   */
  private Boolean processIndex(final Entity it, final Element indexData) {
    Boolean _xblockexpression = null;
    {
      final String indexName = indexData.getAttribute("name");
      final String indexFieldList = indexData.getAttribute("fields");
      Boolean _xifexpression = null;
      boolean _and = false;
      boolean _isEmpty = indexName.isEmpty();
      boolean _not = (!_isEmpty);
      if (!_not) {
        _and = false;
      } else {
        boolean _isEmpty_1 = indexFieldList.isEmpty();
        boolean _not_1 = (!_isEmpty_1);
        _and = (_not && _not_1);
      }
      if (_and) {
        boolean _xblockexpression_1 = false;
        {
          final String[] indexFields = indexFieldList.split(",");
          final EntityIndex index = this.factory.createEntityIndex();
          index.setName(indexName);
          for (final String indexField : indexFields) {
            {
              final EntityIndexItem indexItem = this.factory.createEntityIndexItem();
              indexItem.setName(indexField);
              EList<EntityIndexItem> _items = index.getItems();
              _items.add(indexItem);
            }
          }
          EList<EntityIndex> _indexes = it.getIndexes();
          boolean _add = _indexes.add(index);
          _xblockexpression_1 = (_add);
        }
        _xifexpression = Boolean.valueOf(_xblockexpression_1);
      }
      _xblockexpression = (_xifexpression);
    }
    return _xblockexpression;
  }
  
  /**
   * Saves the created model content into a .mostapp file.
   */
  private void saveModel() {
    MostDslActivator _instance = MostDslActivator.getInstance();
    final Injector injector = _instance.getInjector(MostDslActivator.DE_GUITE_MODULESTUDIO_MOSTDSL);
    final XtextResourceSet resourceSet = injector.<XtextResourceSet>getInstance(XtextResourceSet.class);
    resourceSet.addLoadOption(XtextResource.OPTION_RESOLVE_ALL, Boolean.TRUE);
    Registry _packageRegistry = resourceSet.getPackageRegistry();
    EClass _eClass = ModulestudioPackage.eINSTANCE.eClass();
    _packageRegistry.put(ModulestudioPackage.eNS_URI, _eClass);
    String _plus = ("MOST_output/" + this.appName);
    String _plus_1 = (_plus + ".mostapp");
    URI _createURI = URI.createURI(_plus_1);
    final Resource resource = resourceSet.createResource(_createURI);
    EList<EObject> _contents = resource.getContents();
    _contents.add(this.app);
    try {
      resource.save(Collections.EMPTY_MAP);
    } catch (final Throwable _t) {
      if (_t instanceof IOException) {
        final IOException e = (IOException)_t;
        e.printStackTrace();
      } else {
        throw Exceptions.sneakyThrow(_t);
      }
    }
    resource.unload();
  }
}
