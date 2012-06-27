/*
 * Copyright 2012 Ixonos Plc, Finland. All rights reserved.
 * 
 * This file is part of Kohti kumppanuutta.
 *
 * This file is licensed under GNU LGPL version 3.
 * Please see the 'license.txt' file in the root directory of the package you received.
 * If you did not receive a license, please contact the copyright holder
 * (kohtikumppanuutta@ixonos.com).
 *
 */
package fi.koku.action.controller;

import java.util.List;

import javax.portlet.ActionResponse;
import javax.portlet.PortletSession;
import javax.portlet.RenderRequest;
import javax.portlet.RenderResponse;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.validation.BindingResult;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.support.SessionStatus;
import org.springframework.web.portlet.bind.annotation.ActionMapping;
import org.springframework.web.portlet.bind.annotation.RenderMapping;

import fi.koku.action.model.Test;

/**
 * Main controller (handler request that have no action)
 * 
 * @author Ixonos / tuomape
 *
 */
@Controller("mainController")
@RequestMapping(value = "VIEW")
public class MainController {


  @RenderMapping
  public String render(PortletSession session, RenderRequest req, Model model) {
      return "test";
  }

 
  @RenderMapping(params = "action=showText")
  public String show(PortletSession session, RenderResponse response,
      @RequestParam(value = "text", required = false) String text,
      Model model) {;
       
    Test t = new Test();
    t.setText(text );
    model.addAttribute("test",t );

    return "test";
  }
  
  @RenderMapping(params = "action=showText2")
  public String show2(PortletSession session, RenderResponse response,
      @RequestParam(value = "text", required = false) String text,
      Model model) {;
       
    Test t = new Test();
    t.setText(text );
    model.addAttribute("non_working",t );

    return "non_working";
  }
  

  @ActionMapping(params = "action=setText")
  public void setText(PortletSession session, @ModelAttribute(value = "test") Test test,
      BindingResult bindingResult, ActionResponse response, SessionStatus sessionStatus) {
 
      response.setRenderParameter("action", "showText");
      response.setRenderParameter("text", test.getText());
    sessionStatus.setComplete();
  }

  @ActionMapping(params = "action=setText2")
  public void setTex2t(PortletSession session, @ModelAttribute(value = "test") Test test,
      BindingResult bindingResult, ActionResponse response, SessionStatus sessionStatus) {
 
      response.setRenderParameter("action", "showText2");
      response.setRenderParameter("text", test.getText());
      sessionStatus.setComplete();
  }
  
  @ActionMapping(params = "action=showNonWorking")
  public void toNonWorking(PortletSession session, ActionResponse response, SessionStatus sessionStatus) {
 
      response.setRenderParameter("action", "showText2");
      response.setRenderParameter("text", "");
    sessionStatus.setComplete();
  }

  @ActionMapping(params = "action=showWorking")
  public void toWorking(PortletSession session, ActionResponse response, SessionStatus sessionStatus) {
 
      response.setRenderParameter("action", "showText");
      response.setRenderParameter("text", "");
      sessionStatus.setComplete();
  }


  @ModelAttribute("test")
  public Test getCommandObject() {
    return new Test();
  }

}
