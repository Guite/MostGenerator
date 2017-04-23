package org.zikula.modulestudio.generator.cartridges.zclassic.controller.listener;

import de.guite.modulestudio.metamodel.Application;
import org.eclipse.xtend2.lib.StringConcatenation;
import org.eclipse.xtext.xbase.lib.Extension;
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.listener.CommonExample;
import org.zikula.modulestudio.generator.extensions.FormattingExtensions;
import org.zikula.modulestudio.generator.extensions.Utils;

@SuppressWarnings("all")
public class Kernel {
  @Extension
  private FormattingExtensions _formattingExtensions = new FormattingExtensions();
  
  @Extension
  private Utils _utils = new Utils();
  
  private CommonExample commonExample = new CommonExample();
  
  public CharSequence generate(final Application it, final Boolean isBase) {
    StringConcatenation _builder = new StringConcatenation();
    {
      if ((isBase).booleanValue()) {
        _builder.append("/**");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* Makes our handlers known to the event system.");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("*/");
        _builder.newLine();
      } else {
        _builder.append("/**");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* @inheritDoc");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("*/");
        _builder.newLine();
      }
    }
    _builder.append("public static function getSubscribedEvents()");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    {
      if ((isBase).booleanValue()) {
        _builder.append("    ");
        _builder.append("return [");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("KernelEvents::REQUEST        => [\'onRequest\', 5],");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("KernelEvents::CONTROLLER     => [\'onController\', 5],");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("KernelEvents::VIEW           => [\'onView\', 5],");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("KernelEvents::RESPONSE       => [\'onResponse\', 5],");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("KernelEvents::FINISH_REQUEST => [\'onFinishRequest\', 5],");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("KernelEvents::TERMINATE      => [\'onTerminate\', 5],");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("KernelEvents::EXCEPTION      => [\'onException\', 5]");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("];");
        _builder.newLine();
      } else {
        _builder.append("    ");
        _builder.append("return parent::getSubscribedEvents();");
        _builder.newLine();
      }
    }
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    {
      if ((isBase).booleanValue()) {
        _builder.append("/**");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* Listener for the `kernel.request` event.");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("*");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* Occurs after the request handling has started.");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("*");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* If possible you can return a Response object directly (for example showing a \"maintenance mode\" page).");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* The first listener returning a response stops event propagation.");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* Also you can initialise variables and inject information into the request attributes.");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("*");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* Example from Symfony: the RouterListener determines controller and information about arguments.");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("*");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* @param GetResponseEvent $event The event instance");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("*/");
        _builder.newLine();
      } else {
        _builder.append("/**");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* @inheritDoc");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("*/");
        _builder.newLine();
      }
    }
    _builder.append("public function onRequest(GetResponseEvent $event)");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    {
      if ((!(isBase).booleanValue())) {
        _builder.append("    ");
        _builder.append("parent::onRequest($event);");
        _builder.newLine();
        _builder.newLine();
        _builder.append("    ");
        _builder.append("// if we return a response the system jumps to the kernel.response event");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("// immediately without executing any other listeners or controllers");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("// $event->setResponse(new Response(\'This site is currently not active!\'));");
        _builder.newLine();
        _builder.newLine();
        _builder.append("    ");
        _builder.append("// init stuff and add it to the request (for example a locale)");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("// $testMessage = \'Hello from ");
        String _formatForDisplay = this._formattingExtensions.formatForDisplay(it.getName());
        _builder.append(_formatForDisplay, "    ");
        _builder.append(" app\';");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("// $event->getRequest()->attributes->set(\'");
        String _appName = this._utils.appName(it);
        _builder.append(_appName, "    ");
        _builder.append("_test\', $testMessage);");
        _builder.newLineIfNotEmpty();
        _builder.newLine();
        _builder.append("    ");
        CharSequence _generalEventProperties = this.commonExample.generalEventProperties(it);
        _builder.append(_generalEventProperties, "    ");
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    {
      if ((isBase).booleanValue()) {
        _builder.append("/**");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* Listener for the `kernel.controller` event.");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("*");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* Occurs after routing has been done and the controller has been selected.");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("*");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* You can initialise things requiring the controller and/or routing information.");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* Also you can change the controller before it is executed.");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("*");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* Example from Symfony: the ParamConverterListener performs reflection and type conversion.");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("*");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* @param FilterControllerEvent $event The event instance");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("*/");
        _builder.newLine();
      } else {
        _builder.append("/**");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* @inheritDoc");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("*/");
        _builder.newLine();
      }
    }
    _builder.append("public function onController(FilterControllerEvent $event)");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    {
      if ((!(isBase).booleanValue())) {
        _builder.append("    ");
        _builder.append("parent::onController($event);");
        _builder.newLine();
        _builder.newLine();
        _builder.append("    ");
        _builder.append("// $controller = $event->getController();");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("// ...");
        _builder.newLine();
        _builder.newLine();
        _builder.append("    ");
        _builder.append("// the controller can be changed to any PHP callable");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("// $event->setController($controller);");
        _builder.newLine();
        _builder.newLine();
        _builder.newLine();
        _builder.append("    ");
        _builder.append("// check for certain controller types (or implemented interface types!)");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("// for example imagine an interface named SpecialFlaggedController");
        _builder.newLine();
        _builder.newLine();
        _builder.append("    ");
        _builder.append("// The passed $controller passed can be either a class or a Closure.");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("// If it is a class, it comes in array format.");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("// if (!is_array($controller)) {");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("//     return;");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("// }");
        _builder.newLine();
        _builder.newLine();
        _builder.append("    ");
        _builder.append("// if ($controller[0] instanceof SpecialFlaggedController) {");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("//     ...");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("// }");
        _builder.newLine();
        _builder.newLine();
        _builder.append("    ");
        CharSequence _generalEventProperties_1 = this.commonExample.generalEventProperties(it);
        _builder.append(_generalEventProperties_1, "    ");
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    {
      if ((isBase).booleanValue()) {
        _builder.append("/**");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* Listener for the `kernel.view` event.");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("*");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* Occurs only if the controller did not return a Response object.");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("*");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* You can convert the controller\'s return value into a Response object.");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* This is useful for own view layers.");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* The first listener returning a response stops event propagation.");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("*");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* Example from Symfony: TemplateListener renders Twig templates with returned arrays.");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("*");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* @param GetResponseForControllerResultEvent $event The event instance");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("*/");
        _builder.newLine();
      } else {
        _builder.append("/**");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* @inheritDoc");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("*/");
        _builder.newLine();
      }
    }
    _builder.append("public function onView(GetResponseForControllerResultEvent $event)");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    {
      if ((!(isBase).booleanValue())) {
        _builder.append("    ");
        _builder.append("parent::onView($event);");
        _builder.newLine();
        _builder.newLine();
        _builder.append("    ");
        _builder.append("// $val = $event->getControllerResult();");
        _builder.newLine();
        _builder.newLine();
        _builder.append("    ");
        _builder.append("// $response = new Response();");
        _builder.newLine();
        _builder.newLine();
        _builder.append("    ");
        _builder.append("// ... customise the response using the return value");
        _builder.newLine();
        _builder.newLine();
        _builder.append("    ");
        _builder.append("// $event->setResponse($response);");
        _builder.newLine();
        _builder.newLine();
        _builder.append("    ");
        CharSequence _generalEventProperties_2 = this.commonExample.generalEventProperties(it);
        _builder.append(_generalEventProperties_2, "    ");
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    {
      if ((isBase).booleanValue()) {
        _builder.append("/**");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* Listener for the `kernel.response` event.");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("*");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* Occurs after a response has been created and returned to the kernel.");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("*");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* You can modify or replace the response object, including http headers,");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* cookies, and so on. Of course you can also amend the actual content by");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* for example injecting some custom JavaScript code.");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* Of course you can use request attributes you set in onKernelRequest");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* or onKernelController or other events happened before.");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("*");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* Examples from Symfony:");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("*    - ContextListener: serialises user data into session for next request");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("*    - WebDebugToolbarListener: injects the web debug toolbar");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("*    - ResponseListener: updates the content type according to the request format");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("*");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* @param FilterResponseEvent $event The event instance");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("*/");
        _builder.newLine();
      } else {
        _builder.append("/**");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* @inheritDoc");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("*/");
        _builder.newLine();
      }
    }
    _builder.append("public function onResponse(FilterResponseEvent $event)");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    {
      if ((!(isBase).booleanValue())) {
        _builder.append("    ");
        _builder.append("parent::onResponse($event);");
        _builder.newLine();
        _builder.newLine();
        _builder.append("    ");
        _builder.append("// $response = $event->getResponse();");
        _builder.newLine();
        _builder.newLine();
        _builder.append("    ");
        _builder.append("// ... modify the response object");
        _builder.newLine();
        _builder.newLine();
        _builder.append("    ");
        _builder.append("// $testMessage = $event->getRequest()->attributes->get(\'");
        String _appName_1 = this._utils.appName(it);
        _builder.append(_appName_1, "    ");
        _builder.append("_test\');");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("// now $testMessage should be: \'Hello from ");
        String _formatForDisplay_1 = this._formattingExtensions.formatForDisplay(it.getName());
        _builder.append(_formatForDisplay_1, "    ");
        _builder.append(" app\'");
        _builder.newLineIfNotEmpty();
        _builder.newLine();
        _builder.append("    ");
        CharSequence _generalEventProperties_3 = this.commonExample.generalEventProperties(it);
        _builder.append(_generalEventProperties_3, "    ");
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    {
      if ((isBase).booleanValue()) {
        _builder.append("/**");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* Listener for the `kernel.finish_request` event.");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("*");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* Occurs after processing a request has been completed.");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* Called after a normal response as well as after an exception was thrown.");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("*");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* You can cleanup things here which are not directly related to the response.");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("*");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* @param FinishRequestEvent $event The event instance");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("*/");
        _builder.newLine();
      } else {
        _builder.append("/**");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* @inheritDoc");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("*/");
        _builder.newLine();
      }
    }
    _builder.append("public function onFinishRequest(FinishRequestEvent $event)");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    {
      if ((!(isBase).booleanValue())) {
        _builder.append("    ");
        _builder.append("parent::onFinishRequest($event);");
        _builder.newLine();
        _builder.newLine();
        _builder.append("    ");
        CharSequence _generalEventProperties_4 = this.commonExample.generalEventProperties(it);
        _builder.append(_generalEventProperties_4, "    ");
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    {
      if ((isBase).booleanValue()) {
        _builder.append("/**");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* Listener for the `kernel.terminate` event.");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("*");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* Occurs before the system is shutted down.");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("*");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* You can perform any bigger tasks which can be delayed until the Response");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* has been served to the client. One example is sending some spooled emails.");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("*");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* Example from Symfony: SwiftmailerBundle with memory spooling activates an");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* EmailSenderListener which delivers emails created during the request.");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("*");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* @param PostResponseEvent $event The event instance");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("*/");
        _builder.newLine();
      } else {
        _builder.append("/**");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* @inheritDoc");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("*/");
        _builder.newLine();
      }
    }
    _builder.append("public function onTerminate(PostResponseEvent $event)");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    {
      if ((!(isBase).booleanValue())) {
        _builder.append("    ");
        _builder.append("parent::onTerminate($event);");
        _builder.newLine();
        _builder.newLine();
        _builder.append("    ");
        CharSequence _generalEventProperties_5 = this.commonExample.generalEventProperties(it);
        _builder.append(_generalEventProperties_5, "    ");
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    {
      if ((isBase).booleanValue()) {
        _builder.append("/**");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* Listener for the `kernel.exception` event.");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("*");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* Occurs whenever an exception is thrown. Handles (different types");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* of) exceptions and creates a fitting Response object for them.");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("*");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* You can inject custom error handling for specific error types.");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("*");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* @param GetResponseForExceptionEvent $event The event instance");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("*/");
        _builder.newLine();
      } else {
        _builder.append("/**");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* @inheritDoc");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("*/");
        _builder.newLine();
      }
    }
    _builder.append("public function onException(GetResponseForExceptionEvent $event)");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    {
      if ((!(isBase).booleanValue())) {
        _builder.append("    ");
        _builder.append("parent::onException($event);");
        _builder.newLine();
        _builder.newLine();
        _builder.append("    ");
        _builder.append("// retrieve exception object from the received event");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("// $exception = $event->getException();");
        _builder.newLine();
        _builder.newLine();
        _builder.append("    ");
        _builder.append("// if ($exception instanceof MySpecialException");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("//     || $exception instanceof MySpecialExceptionInterface) {");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("// Create a response object and customise it to display the exception details");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("// $response = new Response();");
        _builder.newLine();
        _builder.newLine();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("// $message = sprintf(");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("//     \'");
        String _formatForDisplay_2 = this._formattingExtensions.formatForDisplay(it.getName());
        _builder.append(_formatForDisplay_2, "        ");
        _builder.append(" App Error says: %s with code: %s\',");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("//     $exception->getMessage(),");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("//     $exception->getCode()");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("// );");
        _builder.newLine();
        _builder.newLine();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("// $response->setContent($message);");
        _builder.newLine();
        _builder.newLine();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("// HttpExceptionInterface is a special type of exception that");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("// holds the status code and header details");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("// if ($exception instanceof HttpExceptionInterface) {");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("//     $response->setStatusCode($exception->getStatusCode());");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("//     $response->headers->replace($exception->getHeaders());");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("// } else {");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("//     $response->setStatusCode(Response::HTTP_INTERNAL_SERVER_ERROR);");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("// }");
        _builder.newLine();
        _builder.newLine();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("// send modified response back to the event");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("// $event->setResponse($response);");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("// }");
        _builder.newLine();
        _builder.newLine();
        _builder.append("    ");
        _builder.append("// you can alternatively set a new Exception");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("// $exception = new \\Exception(\'Some special exception\');");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("// $event->setException($exception);");
        _builder.newLine();
        _builder.newLine();
        _builder.append("    ");
        CharSequence _generalEventProperties_6 = this.commonExample.generalEventProperties(it);
        _builder.append(_generalEventProperties_6, "    ");
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
}
