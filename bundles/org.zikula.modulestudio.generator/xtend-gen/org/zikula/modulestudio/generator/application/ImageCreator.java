package org.zikula.modulestudio.generator.application;

import com.google.common.base.Objects;
import java.awt.Color;
import java.awt.Font;
import java.awt.FontMetrics;
import java.awt.Graphics2D;
import java.awt.Image;
import java.awt.geom.AffineTransform;
import java.awt.image.AffineTransformOp;
import java.awt.image.BufferedImage;
import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.net.URL;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import javax.imageio.ImageIO;
import org.eclipse.core.runtime.FileLocator;
import org.eclipse.core.runtime.IStatus;
import org.eclipse.xtext.xbase.lib.CollectionLiterals;
import org.eclipse.xtext.xbase.lib.Conversions;
import org.eclipse.xtext.xbase.lib.Exceptions;
import org.eclipse.xtext.xbase.lib.IterableExtensions;
import org.zikula.modulestudio.generator.application.ModuleStudioGeneratorActivator;
import org.zikula.modulestudio.generator.application.WorkflowSettings;

/**
 * The image creator serves for generating custom images for an application.
 * 
 * It creates admin images as well as Scribite editor plugin images.
 */
@SuppressWarnings("all")
public class ImageCreator {
  /**
   * Admin image context.
   */
  private final static String CONTEXT_ADMIN = "admin";
  
  /**
   * Transparent background mode.
   */
  private final static String BG_TRANSPARENT = "transparent";
  
  /**
   * White background mode.
   */
  private final static String BG_WHITE = "white";
  
  /**
   * Black background mode.
   */
  private final static String BG_BLACK = "black";
  
  /**
   * The workflow settings.
   */
  private WorkflowSettings settings;
  
  /**
   * The source image (MOST icon).
   */
  private BufferedImage sourceImage = null;
  
  /**
   * List of target directories.
   */
  private List<File> targetDirectories = null;
  
  /**
   * The current context.
   */
  private String context = null;
  
  /**
   * The text to output on the images.
   */
  private String initialsText = null;
  
  /**
   * Generates all custom images for a given application.
   * 
   * @param settings The workflow settings
   * @throws IOException
   */
  public void generate(final WorkflowSettings settings) throws IOException {
    this.settings = settings;
    this.determineAppText();
    Boolean _isStandalone = settings.getIsStandalone();
    boolean _not = (!(_isStandalone).booleanValue());
    if (_not) {
      final URL sourceUrl = settings.getAdminImageUrl();
      if ((null == sourceUrl)) {
        throw new IOException("Could not read input image");
      }
      final URL sourceImageUrl = FileLocator.toFileURL(settings.getAdminImageUrl());
      String _path = sourceImageUrl.getPath();
      final File sourceImageFile = new File(_path);
      String _absolutePath = sourceImageFile.getAbsolutePath();
      File _file = new File(_absolutePath);
      this.sourceImage = ImageIO.read(_file);
    } else {
      final InputStream inputStream = this.getClass().getResourceAsStream(settings.getAdminImageInputPath());
      this.sourceImage = ImageIO.read(inputStream);
    }
    for (final String contextName : Collections.<String>unmodifiableList(CollectionLiterals.<String>newArrayList(ImageCreator.CONTEXT_ADMIN))) {
      {
        this.context = contextName;
        this.determineTargetDirectories();
        int _length = ((Object[])Conversions.unwrapArray(this.targetDirectories, Object.class)).length;
        boolean _greaterThan = (_length > 0);
        if (_greaterThan) {
          this.generateCustomImage(ImageCreator.BG_TRANSPARENT);
          this.generateCustomImage(ImageCreator.BG_WHITE);
          this.generateCustomImage(ImageCreator.BG_BLACK);
        }
      }
    }
  }
  
  /**
   * Determines the text to output on the images.
   */
  private String determineAppText() {
    String _xblockexpression = null;
    {
      final ArrayList<Character> capitals = CollectionLiterals.<Character>newArrayList();
      for (int i = 0; (i < this.settings.getAppName().length()); i++) {
        boolean _isUpperCase = Character.isUpperCase(this.settings.getAppName().charAt(i));
        if (_isUpperCase) {
          char _charAt = this.settings.getAppName().charAt(i);
          capitals.add(Character.valueOf(_charAt));
        }
      }
      String _xifexpression = null;
      int _size = capitals.size();
      boolean _greaterThan = (_size > 1);
      if (_greaterThan) {
        Character _head = IterableExtensions.<Character>head(capitals);
        String _plus = (_head + "");
        Character _last = IterableExtensions.<Character>last(capitals);
        String _plus_1 = (_plus + _last);
        _xifexpression = this.initialsText = _plus_1;
      } else {
        String _upperCase = Character.valueOf(this.settings.getAppVendor().charAt(0)).toString().toUpperCase();
        Character _head_1 = IterableExtensions.<Character>head(capitals);
        String _plus_2 = (_upperCase + _head_1);
        _xifexpression = this.initialsText = _plus_2;
      }
      _xblockexpression = _xifexpression;
    }
    return _xblockexpression;
  }
  
  /**
   * Determines the target directories for the current context.
   */
  private List<File> determineTargetDirectories() {
    List<File> _xifexpression = null;
    boolean _equals = Objects.equal(this.context, ImageCreator.CONTEXT_ADMIN);
    if (_equals) {
      File _pathToModuleImageAssets = this.settings.getPathToModuleImageAssets();
      _xifexpression = this.targetDirectories = Collections.<File>unmodifiableList(CollectionLiterals.<File>newArrayList(_pathToModuleImageAssets));
    }
    return _xifexpression;
  }
  
  /**
   * Generates a single custom image.
   * 
   * @param bgMode The background colour mode (transparent, white, black); defaults to transparent
   */
  private void generateCustomImage(final String bgMode) {
    int _xifexpression = (int) 0;
    boolean _equals = Objects.equal(this.context, ImageCreator.CONTEXT_ADMIN);
    if (_equals) {
      _xifexpression = 48;
    } else {
      _xifexpression = 48;
    }
    final int size = _xifexpression;
    String _xifexpression_1 = null;
    boolean _contains = Collections.<String>unmodifiableList(CollectionLiterals.<String>newArrayList(ImageCreator.BG_TRANSPARENT, ImageCreator.BG_WHITE, ImageCreator.BG_BLACK)).contains(bgMode);
    boolean _not = (!_contains);
    if (_not) {
      _xifexpression_1 = ImageCreator.BG_TRANSPARENT;
    } else {
      _xifexpression_1 = bgMode;
    }
    final String bgColour = _xifexpression_1;
    Color _xifexpression_2 = null;
    boolean _equals_1 = Objects.equal(bgColour, ImageCreator.BG_BLACK);
    if (_equals_1) {
      _xifexpression_2 = Color.WHITE;
    } else {
      _xifexpression_2 = Color.BLACK;
    }
    final Color textColour = _xifexpression_2;
    final int fontSize = (size / 2);
    String _xifexpression_3 = null;
    boolean _equals_2 = Objects.equal(this.context, ImageCreator.CONTEXT_ADMIN);
    if (_equals_2) {
      _xifexpression_3 = ImageCreator.CONTEXT_ADMIN;
    } else {
      _xifexpression_3 = this.settings.getAppName();
    }
    String targetFileName = _xifexpression_3;
    boolean _equals_3 = Objects.equal(bgColour, ImageCreator.BG_WHITE);
    if (_equals_3) {
      targetFileName = (targetFileName + "_w");
    } else {
      boolean _equals_4 = Objects.equal(bgColour, ImageCreator.BG_BLACK);
      if (_equals_4) {
        targetFileName = (targetFileName + "_b");
      }
    }
    targetFileName = (targetFileName + ".png");
    final BufferedImage image = new BufferedImage(size, size, BufferedImage.TYPE_INT_ARGB);
    final Graphics2D graphics = image.createGraphics();
    Color backgroundColour = new Color(0, 0, 0, 1);
    boolean _equals_5 = Objects.equal(bgColour, ImageCreator.BG_WHITE);
    if (_equals_5) {
      backgroundColour = Color.WHITE;
    } else {
      boolean _equals_6 = Objects.equal(bgColour, ImageCreator.BG_BLACK);
      if (_equals_6) {
        backgroundColour = Color.BLACK;
      }
    }
    graphics.setColor(backgroundColour);
    graphics.fillRect(0, 0, size, size);
    final BufferedImage resizedSourceImage = this.resizeImage(this.sourceImage, (size / 2), (size / 2));
    graphics.drawImage(resizedSourceImage, (size / 4), (size / 2), null);
    Font _font = new Font("Arial", Font.BOLD, fontSize);
    graphics.setFont(_font);
    graphics.setPaint(textColour);
    final FontMetrics fontMetrics = graphics.getFontMetrics();
    int _width = image.getWidth();
    int _stringWidth = fontMetrics.stringWidth(this.initialsText);
    int _minus = (_width - _stringWidth);
    final int textX = (_minus / 2);
    int _xifexpression_4 = (int) 0;
    if ((size == 48)) {
      int _height = fontMetrics.getHeight();
      _xifexpression_4 = (_height - 5);
    } else {
      int _xifexpression_5 = (int) 0;
      if ((size == 16)) {
        int _height_1 = fontMetrics.getHeight();
        _xifexpression_5 = (_height_1 - 3);
      }
      _xifexpression_4 = _xifexpression_5;
    }
    final int textY = _xifexpression_4;
    graphics.drawString(this.initialsText, textX, textY);
    try {
      for (final File targetDirectory : this.targetDirectories) {
        {
          String _plus = (targetDirectory + File.separator);
          String _plus_1 = (_plus + targetFileName);
          final File outputFile = new File(_plus_1);
          ImageIO.write(image, "png", outputFile);
        }
      }
    } catch (final Throwable _t) {
      if (_t instanceof IOException) {
        final IOException e = (IOException)_t;
        ModuleStudioGeneratorActivator.log(IStatus.ERROR, e.getMessage(), e);
      } else {
        throw Exceptions.sneakyThrow(_t);
      }
    } finally {
      graphics.dispose();
    }
  }
  
  /**
   * Resizes an Image by stretching it to a new size.
   * 
   * @param picture the initial image
   * @param width the destination width
   * @param height the destination height
   * @return the stretched buffered image
   */
  private BufferedImage resizeImage(final Image picture, final double width, final double height) {
    BufferedImage _xblockexpression = null;
    {
      final int size = 48;
      BufferedImage buffer = new BufferedImage(size, size, BufferedImage.TYPE_INT_ARGB);
      final Graphics2D graphics = buffer.createGraphics();
      graphics.drawImage(picture, 0, 0, null);
      final AffineTransform transformer = new AffineTransform();
      final double xFactor = (width / size);
      final double yFactor = (height / size);
      transformer.scale(xFactor, yFactor);
      final AffineTransformOp operation = new AffineTransformOp(transformer, AffineTransformOp.TYPE_BILINEAR);
      buffer = operation.filter(buffer, null);
      _xblockexpression = buffer;
    }
    return _xblockexpression;
  }
}
