package org.zikula.modulestudio.generator.application

import java.awt.Color
import java.awt.Font
import java.awt.Image
import java.awt.geom.AffineTransform
import java.awt.image.AffineTransformOp
import java.awt.image.BufferedImage
import java.io.File
import java.io.IOException
import java.util.List
import javax.imageio.ImageIO
import org.eclipse.core.runtime.FileLocator

/**
 * The image creator serves for generating custom admin images for an application.
 */
class ImageCreator {

    /**
     * Admin image context.
     */
    static final String CONTEXT_ADMIN = 'admin' // $NON-NLS-1$

    /**
     * Transparent background mode.
     */
    static final String BG_TRANSPARENT = 'transparent' // $NON-NLS-1$

    /**
     * White background mode.
     */
    static final String BG_WHITE = 'white' // $NON-NLS-1$

    /**
     * Black background mode.
     */
    static final String BG_BLACK = 'black' // $NON-NLS-1$

    /**
     * The workflow settings.
     */
    WorkflowSettings settings

    /**
     * The source image (MOST icon).
     */
    BufferedImage sourceImage = null

    /**
     * List of target directories.
     */
    List<File> targetDirectories = null

    /**
     * The current context.
     */
    String context = null

    /**
     * The text to output on the images.
     */
    String initialsText = null

    /**
     * Generates all custom images for a given application.
     *
     * @param settings The workflow settings
     * @throws IOException
     */
    def generate(WorkflowSettings settings) throws IOException {
        this.settings = settings

        determineAppText

        if (!settings.isStandalone) {
            val sourceUrl = settings.adminImageUrl
            if (null === sourceUrl) {
                throw new IOException('Could not read input image')
            }
            val sourceImageUrl = FileLocator.toFileURL(settings.adminImageUrl)
            val sourceImageFile = new File(sourceImageUrl.getPath)
            sourceImage = ImageIO.read(new File(sourceImageFile.absolutePath))
        } else {
            val inputStream = this.class.getResourceAsStream(settings.getAdminImageInputPath)
            sourceImage = ImageIO.read(inputStream)
        }

        for (contextName : #[CONTEXT_ADMIN]) {
            context = contextName
            determineTargetDirectories
            if (targetDirectories.length > 0) {
                generateCustomImage(BG_TRANSPARENT)
                generateCustomImage(BG_WHITE)
                generateCustomImage(BG_BLACK)
            }
        }
    }

    /**
     * Determines the text to output on the images.
     */
    def private determineAppText() {
        // collect capital letters in application name
        val capitals = newArrayList
        for (var i = 0; i < settings.appName.length; i++) {
            if (Character.isUpperCase(settings.appName.charAt(i))) {
                capitals += settings.appName.charAt(i)
            }
        }

        if (capitals.size > 1) {
            // If the application name contains more than one capital use the first and the last one of it
            // Example: VD for VerySimpleDownloads
            initialsText = capitals.head + '' + capitals.lastOrNull //$NON-NLS-1$
        } else {
            // Otherwise use the first capital of the vendor and the capital of the application name
            // Example: GN for Guite / News
            initialsText = settings.appVendor.charAt(0).toString.toUpperCase + capitals.head
        }
    }

    /**
     * Determines the target directories for the current context.
     */
    def private determineTargetDirectories() {
        if (context == CONTEXT_ADMIN) {
            targetDirectories = #[settings.getPathToBundleImageAssets]
        }
    }

    /**
     * Generates a single custom image.
     *
     * @param bgMode The background colour mode (transparent, white, black); defaults to transparent
     */
    def private generateCustomImage(String bgMode) {
        val size = if (context == CONTEXT_ADMIN) 48 else 48
        val bgColour = if (!#[BG_TRANSPARENT, BG_WHITE, BG_BLACK].contains(bgMode)) BG_TRANSPARENT else bgMode
        val textColour = if (bgColour == BG_BLACK) Color.WHITE else Color.BLACK
        val fontSize = size / 2

        // determine output file name
        var targetFileName = if (context == CONTEXT_ADMIN) CONTEXT_ADMIN else settings.appName
        if (bgColour == BG_WHITE) {
            targetFileName = targetFileName + '_w' //$NON-NLS-1$
        } else if (bgColour == BG_BLACK) {
            targetFileName = targetFileName + '_b' //$NON-NLS-1$
        }
        targetFileName = targetFileName + '.png' //$NON-NLS-1$

        // create new image
        val image = new BufferedImage(size, size, BufferedImage.TYPE_INT_ARGB)
        val graphics = image.createGraphics

        // fill background
        var backgroundColour = new Color(0, 0, 0, 1)
        if (bgColour == BG_WHITE) {
            backgroundColour = Color.WHITE
        } else if (bgColour == BG_BLACK) {
            backgroundColour = Color.BLACK
        }
        graphics.color = backgroundColour
        graphics.fillRect(0, 0, size, size)

        // copy MOST default icon into bottom area of the current image
        val resizedSourceImage = resizeImage(sourceImage, size/2, size/2)
        graphics.drawImage(resizedSourceImage, size/4, size/2, null)

        // add the text to the upper area
        graphics.font = new Font('Arial', Font.BOLD, fontSize)
        graphics.paint = textColour
        val fontMetrics = graphics.fontMetrics
        val textX = (image.width - fontMetrics.stringWidth(initialsText)) / 2
        val textY = if (size == 48) fontMetrics.height - 5 else if (size == 16) fontMetrics.height - 3
        graphics.drawString(initialsText, textX, textY)

        // save output images
        try {
            for (targetDirectory : targetDirectories) {
                val outputFile = new File(targetDirectory + File.separator + targetFileName)
                ImageIO.write(image, 'png', outputFile)
            }
        } catch (IOException e) {
            //ModuleStudioGeneratorActivator.log(IStatus.ERROR, e.message, e)
            println(e.message)
        } finally {
            graphics.dispose
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
    def private resizeImage(Image picture, double width, double height)
    {
        val size = 48
        var buffer = new BufferedImage(size, size, BufferedImage.TYPE_INT_ARGB)

        val graphics = buffer.createGraphics
        graphics.drawImage(picture, 0, 0, null)

        val transformer = new AffineTransform
        val xFactor = width / size
        val yFactor = height / size
        transformer.scale(xFactor, yFactor)

        val operation = new AffineTransformOp(transformer, AffineTransformOp.TYPE_BILINEAR)
        buffer = operation.filter(buffer, null)

        buffer
    }
}
