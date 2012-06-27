<%--
 Copyright 2012 Ixonos Plc, Finland. All rights reserved.
  
 This file is part of Kohti kumppanuutta.
 
 This file is licensed under GNU LGPL version 3.
 Please see the 'license.txt' file in the root directory of the package you received.
 If you did not receive a license, please contact the copyright holder
 (kohtikumppanuutta@ixonos.com).
--%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib uri="http://java.sun.com/portlet" prefix="portlet" %>

<%@ page import="javax.portlet.PortletPreferences" %>
<%@ page import="javax.portlet.WindowState" %>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags" %> 
<%@ taglib prefix="form" uri="http://www.springframework.org/tags/form"%>

<%@ page contentType="text/html" isELIgnored="false"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>

<portlet:defineObjects />


<portlet:actionURL var="saveTestUrl">
	<portlet:param name="action" value="setText" />
</portlet:actionURL>


<div class="portlet-section-body">

		<h1 class="portlet-section-header">
			actionURL test
		</h1>
        <div class="search">
		<form:form name="testForm" commandName="test" method="post"
			action="${saveTestUrl}">

            <div class="portlet-form-field-label">  
                This page uses taglib: http://java.sun.com/portlet and you can submit the form
            </div>
            
			<div class="portlet-form-field"> 
			 <form:input class="defaultText"  path="text" /> 
			 <input type="submit" class="portlet-form-button" value="save"> 
			</div>

			
		</form:form>
		</div>
		<br></br>
		<div>
			<c:if test="${not empty test}">			
				<h1 class="portlet-section-header">
					Form submit result:
				</h1>
				<span>
						<c:out value="${test.text }"/>
				</span>
			</c:if>
			
		</div>
		<br/>
		<div>
		<strong>
			<a href="
                 <portlet:actionURL>
                     <portlet:param name="action" value="showNonWorking" />
                 </portlet:actionURL>">
				Click here to non-working version	
			</a>
			</strong>
		</div>
	</div>

