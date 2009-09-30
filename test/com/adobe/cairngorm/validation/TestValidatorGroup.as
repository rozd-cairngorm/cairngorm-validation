/**
 * Copyright (c) 2006. Adobe Systems Incorporated.
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 *   * Redistributions of source code must retain the above copyright notice,
 *     this list of conditions and the following disclaimer.
 *   * Redistributions in binary form must reproduce the above copyright notice,
 *     this list of conditions and the following disclaimer in the documentation
 *     and/or other materials provided with the distribution.
 *   * Neither the name of Adobe Systems Incorporated nor the names of its
 *     contributors may be used to endorse or promote products derived from this
 *     software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
 * LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 * INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
 * CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
 * POSSIBILITY OF SUCH DAMAGE.
 */
package com.adobe.cairngorm.validation
{   
   import flexunit.framework.TestCase;
   
   import mx.controls.TextInput;
   import mx.events.ValidationResultEvent;
   import mx.validators.StringValidator;
   
   public class TestValidatorGroup extends TestCase
   {
      private var validatorGroup : ValidatorGroup;
      private var subValidatorGroup : ValidatorGroup;
      
      private var firstnameValidator : StringValidator;
      private var lastnameValidator : StringValidator;
      private var addressValidator : StringValidator;
      
      private var mockFirstnameValidatorListener : MockValidatorListener;
      private var mockLastnameValidatorListener : MockValidatorListener;
      
      private var firstnameInput : TextInput;
      private var lastnameInput : TextInput;
      private var addressInput : TextInput;
      
      override public function setUp() : void
		{
		   firstnameInput = new TextInput();
		   lastnameInput = new TextInput();
		   addressInput = new TextInput();
		   
		   validatorGroup = new ValidatorGroup();
		   subValidatorGroup = new ValidatorGroup();
		   
		   mockFirstnameValidatorListener = new MockValidatorListener();
		   mockLastnameValidatorListener = new MockValidatorListener();
		   
		   firstnameValidator = new StringValidator();
		   firstnameValidator.required = true;
         firstnameValidator.source = firstnameInput;
         firstnameValidator.minLength = 2;
         firstnameValidator.property = "text";
         firstnameValidator.triggerEvent = "valueCommit";
         firstnameValidator.listener = mockFirstnameValidatorListener;
         
         lastnameValidator = new StringValidator();
         lastnameValidator.required = true;
         lastnameValidator.source = lastnameInput;
         lastnameValidator.minLength = 2;
         lastnameValidator.property = "text";
         lastnameValidator.triggerEvent = "valueCommit";
         lastnameValidator.listener = mockLastnameValidatorListener;
         
         addressValidator = new StringValidator();
         addressValidator.required = true;
         addressValidator.source = addressInput;
         addressValidator.minLength = 5;
         addressValidator.property = "text";
         addressValidator.triggerEvent = "valueCommit";
		}
      
      public function testEmptyValidatorGroup() : void
      {
         validatorGroup.preValidation = true;
         validatorGroup.initialized( null, "" );
         assertTrue("The validatorGroup should be valid", validatorGroup.isValid );
      }
      
      public function testEmptyNestedValidatorGroup() : void
      {
         validatorGroup.preValidation = true;
         subValidatorGroup.preValidation = true;
         validatorGroup.addValidatorGroup( subValidatorGroup );
         validatorGroup.initialized( null, "" );
         assertTrue("The validatorGroup should be valid", validatorGroup.isValid );
      }
      
      public function testPreValidationEnabled() : void
      {
         validatorGroup.preValidation = true;
         validatorGroup.addValidator( firstnameValidator );
		   validatorGroup.addValidator( lastnameValidator );
		   
         assertFalse("The validatorGroup should be invalid", validatorGroup.isValid );
         
         firstnameInput.text = "Yaniv";
         lastnameInput.text = "De Ridder";
         
         assertTrue("The validatorGroup should be valid", validatorGroup.isValid );
      }
      
      public function testPreValidationDisabled() : void
      {
         validatorGroup.preValidation = false;
         validatorGroup.addValidator( firstnameValidator );
		   validatorGroup.addValidator( lastnameValidator );
		   
         assertTrue("The validatorGroup should be valid", validatorGroup.isValid );
         
         firstnameInput.text = "Yaniv";
         lastnameInput.text = "";
         
         assertTrue("The validatorGroup should be valid", validatorGroup.isValid );
         
         validatorGroup.validate();
                  
         assertFalse("The validatorGroup should be invalid", validatorGroup.isValid );
      }
      
      public function testValidatarGroupEnableFlag() : void
      {
         validatorGroup.preValidation = true;
         validatorGroup.addValidator( firstnameValidator );
		   validatorGroup.addValidator( lastnameValidator );
         firstnameInput.text = "Y";
         lastnameInput.text = "D";
		   
         assertFalse("The validatorGroup should be valid", validatorGroup.isValid );
         
         validatorGroup.enabled = false;

         assertTrue("The validatorGroup should be valid", validatorGroup.isValid );
         
         firstnameInput.text = "";
         lastnameInput.text = "";
         
         assertTrue("The validatorGroup should be valid", validatorGroup.isValid );
         
         firstnameInput.text = "yaniv";
         lastnameInput.text = "de ridder";
         
         validatorGroup.enabled = true;
         
         assertTrue("The validatorGroup should be valid", validatorGroup.isValid );
      }
      
      public function testAddValidatorDynamically() : void
      {
         validatorGroup.preValidation = true;
         validatorGroup.addValidator( firstnameValidator );
		   firstnameInput.text = "Yaniv";
		   
         assertTrue("The validatorGroup should be valid", validatorGroup.isValid );
         
         validatorGroup.addValidator( lastnameValidator );
         
         assertFalse("The validatorGroup should be invalid", validatorGroup.isValid );
         
         lastnameInput.text = "De Ridder";
         
         assertTrue("The validatorGroup should be valid", validatorGroup.isValid );
      }
      
      public function testRemoveValidatorDynamically() : void
      {
         validatorGroup.preValidation = true;
         validatorGroup.addValidator( firstnameValidator );
         validatorGroup.addValidator( lastnameValidator );
		   firstnameInput.text = "Yaniv";
		   
		   assertFalse("The validatorGroup should be invalid", validatorGroup.isValid );
		   
         validatorGroup.removeValidator( lastnameValidator );
         
         assertTrue("The validatorGroup should be valid", validatorGroup.isValid );
      }
      
      public function testRemoveValidatorDynamicallyNotFound() : void
      {
         validatorGroup.addValidator( firstnameValidator );
		   
         try
         {
            validatorGroup.removeValidator( lastnameValidator );
            
            assertFalse("The validatorGroup should throw an error before this line", true );  
         }
         catch( e : Error )
         {
            assertNotNull("The validatorGroup should not find the validator specified", e );
         }
      }
      
      public function testRemoveValidatorGroupDynamicallyNotFound() : void
      {
         validatorGroup.addValidatorGroup( new ValidatorGroup() );
         
         try
         {
            validatorGroup.removeValidatorGroup( subValidatorGroup );
            
            assertFalse("The validatorGroup should throw an error before this line", true );  
         }
         catch( e : Error )
         {
            assertNotNull("The validatorGroup should not find the group specified", e );
         }
      }
      
      public function testNestedValidatorGroup() : void
      {
         validatorGroup.preValidation = true;
         validatorGroup.addValidator( firstnameValidator );
		   validatorGroup.addValidator( lastnameValidator );
		   
		   subValidatorGroup.preValidation = true;
		   subValidatorGroup.addValidator(addressValidator );
		   
		   validatorGroup.addValidatorGroup( subValidatorGroup );
		   
		   assertFalse("The validatorGroup should be invalid", validatorGroup.isValid );
		   
		   firstnameInput.text = "Yaniv";
         lastnameInput.text = "De Ridder";
         addressInput.text = "Brussels";
         
         assertTrue("The validatorGroup should be valid", validatorGroup.isValid );
      }
      
      public function testNestedValidatorGroupEnabledFlag() : void
      {
         validatorGroup.preValidation = true;
         validatorGroup.addValidator( firstnameValidator );
		   validatorGroup.addValidator( lastnameValidator );
		   
		   subValidatorGroup.preValidation = true;
		   subValidatorGroup.addValidator( addressValidator );
		   
		   validatorGroup.addValidatorGroup( subValidatorGroup );
		   
		   assertFalse("The validatorGroup should be invalid", validatorGroup.isValid );
		   
		   firstnameInput.text = "Yaniv";
         lastnameInput.text = "De Ridder";
         
         assertFalse("The validatorGroup should be invalid", validatorGroup.isValid );
         
         validatorGroup.enabled = false;
                     
         assertTrue("The validatorGroup should be valid", validatorGroup.isValid );
      }
      
      public function testAddValidatorIntoNestedValidatorGroupDynamically() : void
      {
         subValidatorGroup.preValidation = true;
         validatorGroup.addValidatorGroup( subValidatorGroup );
         validatorGroup.preValidation = true;
         validatorGroup.addValidator( firstnameValidator );
		   firstnameInput.text = "Yaniv";
		   
         assertTrue("The validatorGroup should be valid", validatorGroup.isValid );
         
         subValidatorGroup.addValidator( addressValidator );
         
         assertFalse("The validatorGroup should be invalid", validatorGroup.isValid );
         
         addressInput.text = "Brussels";
         
         assertTrue("The validatorGroup should be valid", validatorGroup.isValid );
      }
      
      public function testRemoveValidatorIntoNestedValidatorGroupDynamically() : void
      {
         subValidatorGroup.preValidation = true;
         subValidatorGroup.addValidator( addressValidator );
         
         validatorGroup.addValidatorGroup( subValidatorGroup );
         validatorGroup.preValidation = true;
         validatorGroup.addValidator( firstnameValidator );
		   firstnameInput.text = "Yaniv";
		   
		   assertFalse("The validatorGroup should be invalid", validatorGroup.isValid );
		   
         subValidatorGroup.removeValidator( addressValidator );
            
         assertTrue("The validatorGroup should be valid", validatorGroup.isValid );
      }
      
      public function testRemoveValidatorGroupFromNestedValidatorGroupDynamically() : void
      {
         subValidatorGroup.preValidation = true;
         subValidatorGroup.addValidator( addressValidator );
         
         validatorGroup.addValidatorGroup( subValidatorGroup );
         validatorGroup.preValidation = true;
         validatorGroup.addValidator( firstnameValidator );
		   firstnameInput.text = "Yaniv";
		   
		   assertFalse("The validatorGroup should be invalid", validatorGroup.isValid );
		   
         validatorGroup.removeValidatorGroup( subValidatorGroup );
            
         assertTrue("The validatorGroup should be valid", validatorGroup.isValid );
      }
      
      public function testResetValidatorGroup() : void
      {
         validatorGroup.addValidator( firstnameValidator );
		   validatorGroup.addValidator( lastnameValidator );
		   firstnameInput.text = "";
		   lastnameInput.text = "";
		   
		   validatorGroup.validate();
		   
		   assertTrue("The listener should receive an invalid result", 
		      mockFirstnameValidatorListener.validationResultType == ValidationResultEvent.INVALID );
		   
		   assertTrue("The listener should receive an invalid result", 
		      mockLastnameValidatorListener.validationResultType == ValidationResultEvent.INVALID );
		   
		   validatorGroup.reset();
		   
		   assertTrue("The listener should receive a valid result", 
		      mockFirstnameValidatorListener.validationResultType == ValidationResultEvent.VALID );
		   
		   assertTrue("The listener should receive a valid result", 
		      mockLastnameValidatorListener.validationResultType == ValidationResultEvent.VALID );
      }
      
      public function testSilentValidation() : void
      {
         validatorGroup.addValidator( firstnameValidator );
		   validatorGroup.addValidator( lastnameValidator );
		   firstnameInput.text = "";
		   lastnameInput.text = "";
		   
		   validatorGroup.validate( true );
		   
		   assertNull("The listener should not receive any result", 
		      mockFirstnameValidatorListener.validationResultType );
		   
		   assertNull("The listener should not receive any result", 
		      mockLastnameValidatorListener.validationResultType );
		      
         assertFalse("The validatorGroup should be invalid", 
		      validatorGroup.isValid );		      
		      
		   validatorGroup.validate( false );
		      
		   assertTrue("The listener should receive an invalid result", 
		      mockFirstnameValidatorListener.validationResultType == ValidationResultEvent.INVALID );
		   
		   assertTrue("The listener should receive an invalid result", 
		      mockLastnameValidatorListener.validationResultType == ValidationResultEvent.INVALID );
		   
         assertFalse("The validatorGroup should be invalid", 
		      validatorGroup.isValid );		  
      
      }
      
   }
}