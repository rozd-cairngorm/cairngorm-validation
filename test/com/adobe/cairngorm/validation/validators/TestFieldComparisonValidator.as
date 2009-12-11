/**
 *  Copyright (c) 2007 - 2009 Adobe
 *  All rights reserved.
 *
 *  Permission is hereby granted, free of charge, to any person obtaining
 *  a copy of this software and associated documentation files (the "Software"),
 *  to deal in the Software without restriction, including without limitation
 *  the rights to use, copy, modify, merge, publish, distribute, sublicense,
 *  and/or sell copies of the Software, and to permit persons to whom the
 *  Software is furnished to do so, subject to the following conditions:
 *
 *  The above copyright notice and this permission notice shall be included
 *  in all copies or substantial portions of the Software.
 *
 *  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 *  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 *  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
 *  THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 *  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 *  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
 *  IN THE SOFTWARE.
 */
package com.adobe.cairngorm.validation.validators
{
	import flash.events.Event;
	
	import flexunit.framework.TestCase;
	
	import mx.controls.Button;
	import mx.controls.TextInput;

	public class TestFieldComparisonValidator extends TestCase
	{
		public var validator : DerivedFieldComparisonValidator;
		
		/**
		 * Constructor.
		 * @param methodName the name of the individual test to run.
		 */
		public function TestFieldComparisonValidator( methodName : String = null )
		{
			super( methodName );
		}
	
		/**
		 * @see flexunit.framework.TestCase#setUp().
		 */
		override public function setUp() : void
		{
			validator = new DerivedFieldComparisonValidator();
		}
		
		/**
		 * @see flexunit.framework.TestCase#tearDown().
		 */
		override public function tearDown() : void
		{
			validator = null;
		}
		
		/**
		 * Test "setDest" adds the trigger handler.
		 */
		public function testSetDest() : void
		{
			var field : TextInput = new TextInput();
			
			validator.destination = field;
			
			assertTrue( field.willTrigger( "valueCommit" ) );
			
		}
		
		/**
		 * Test "setDest" using a String.
		 */
		public function testSetDestAsString() : void
		{
			var failed : Boolean = true;
			
			try
			{
				validator.destination = "myField";
			}
			catch ( error : Error )
			{
				failed = false;
			}
			
			assertFalse( failed );
		}
		
		/**
		 * Test "getdestination".
		 */
		public function testGetdestination() : void
		{
			var field : TextInput = new TextInput();
			
			validator.destination = field;
			
			assertEquals( field, validator.destination );
		}
		
		/**
		 * Test "getdestinationProperty".
		 */
		public function testGetdestinationProperty() : void
		{
			var property : String = "text";
			
			validator.destinationProperty = property;
			
			assertEquals( property, validator.destinationProperty );
		}
		
		/**
		 * Test "setdestinationTrigger".
		 */
		public function testSetdestinationTrigger() : void
		{
			// First, add a field and make sure the trigger handler is set.
			var field : TextInput = new TextInput();
			
			validator.destination = field;
			
			assertTrue( field.willTrigger( "valueCommit" ) );
			
			// Now add a button as the trigger.
			var button : Button = new Button();
			
			validator.destinationTrigger = button;
			
			// Check the field is no longer the trigger.
			assertFalse( field.willTrigger( "valueCommit" ) );
			
			// Check the button is now the trigger.
			assertTrue( button.willTrigger( "valueCommit" ) );
		}
		
		/**
		 * Test "getdestinationTrigger".
		 */
		public function testGetdestinationTrigger() : void
		{			
			var button : Button = new Button();
			
			validator.destinationTrigger = button;
			
			assertEquals( button, validator.destinationTrigger );
		}
		
		/**
		 * Test "setdestinationTriggerEvent".
		 */
		public function testSetdestinationTriggerEvent() : void
		{
			// First, add a field and make sure the trigger handler is set.
			var field : TextInput = new TextInput();
			
			validator.destination = field;
			
			assertTrue( field.willTrigger( "valueCommit" ) );
			
			// Now change the trigger event.
			validator.destinationTriggerEvent = "myevent";
			
			assertTrue( field.willTrigger( "myevent" ) );	
		}
		
		/**
		 * Test "getdestinationTriggerEvent".
		 */
		 public function testGetdestinationTriggerEvent() : void
		 {
		 	validator.destinationTriggerEvent = "myevent";
		 	
		 	assertEquals( "myevent", validator.destinationTriggerEvent );
		 }
		
		/**
		 * Test "doValidation" when the 'destination' is triggered first. We don't want
		 * a validation event to fire if the 'destination' triggers the validator
		 * before the user has had the opportunity to enter text in the 'source'
		 * field.
		 * Remember we are validating the 'source' against the 'destination', the error
		 * message is only displayed on the 'source'.
		 */
		public function testDoValidation1() : void
		{
			// Create the source and destinationination fields.
			var source : TextInput = new TextInput();

			var destination : TextInput = new TextInput();
			destination.text = "hello";
			
			// Configure the validator.
			validator.source = source;
			validator.property = "text";
			validator.destination = destination;
			validator.destinationProperty = "text";
			
			// Dispatch the trigger event.
			destination.dispatchEvent( new Event( "valueCommit" ) );
			
			// Check the 'destination' trigger handler was executed and "doValidation'
			// was not called.
			assertTrue( validator.isDestFired() );
			assertFalse( validator.isValidationDone() );
		}
		
		/**
		 * Test "doValidation" when the 'source' is triggered first (i.e. 'destination'
		 * has no value). In this instance we expect the INVALID event to fire
		 * even if the user hasn't entered any text in the 'destination'.
		 * Remember we are validating the 'source' against the 'destination', the error
		 * message is only displayed on the 'source'.
		 */
		public function testDoValidation2() : void
		{
			// Create the source and destinationination fields.
			var source : TextInput = new TextInput();
			source.text = "hello";

			var destination : TextInput = new TextInput();
			
			// Configure the validator.
			validator.source = source;
			validator.property = "text";
			validator.destination = destination;
			validator.destinationProperty = "text";
			
			// Do the validation.
			assertFalse( validator.isValid() );
		}
		
		/**
		 * Test "doValidation" when the fields match. In this instance we expect
		 * the VALID event to fire.
		 * Remember we are validating the 'source' against the 'destination', the error
		 * message is only displayed on the 'source'.
		 */
		public function testDoValidation3() : void
		{
			// Create the source and destinationination fields.
			var source : TextInput = new TextInput();
			source.text = "hello";

			var destination : TextInput = new TextInput();
			destination.text = "hello";
			
			// Configure the validator.
			validator.source = source;
			validator.property = "text";
			validator.destination = destination;
			validator.destinationProperty = "text";
			
			// Do the validation.
			assertTrue( validator.isValid() );
		}
		
		/**
		 * Test "doValidation" when we the fields don't match. In this instance
		 * we expect the INVALID event to fire.
		 * Remember we are validating the 'source' against the 'destination', the error
		 * message is only displayed on the 'source'.
		 */
		public function testDoValidation4() : void
		{
			// Create the source and destinationination fields.
			var source : TextInput = new TextInput();
			source.text = "hello";

			var destination : TextInput = new TextInput();
			destination.text = "bye";
			
			// Configure the validator.
			validator.source = source;
			validator.property = "text";
			validator.destination = destination;
			validator.destinationProperty = "text";
			
			// Do the validation.
			assertFalse( validator.isValid() );
		}
		
		/**
		 * Test "doValidation" when no 'destination' is entered. We expect an Error to
		 * be thrown. We need a source for this to work.
		 */
		public function testDoValidationWithNodestination() : void
		{
			// Create a source field.
			var source : TextInput = new TextInput();
			source.text = "hello";
			
			// Configure the validator.
			validator.source = source;
			validator.property = "text";
			validator.destinationProperty = "text";
			
			// Dispatch the trigger event.
			var failed : Boolean = true;
			
			try
			{
				validator.isValid();
			}
			catch ( error : Error )
			{
				failed = false;
			}
			
			assertFalse( failed );
		}
		
		/**
		 * Test "doValidation" when no 'destinationProperty' is entered. We expect an
		 * Error to be thrown. We need a source for this to work.
		 */
		public function testDoValidationWithNodestinationProperty() : void
		{
			// Create the source and destinationination fields.
			var source : TextInput = new TextInput();
			source.text = "hello";

			var destination : TextInput = new TextInput();
			
			// Configure the validator.
			validator.source = source;
			validator.property = "text";
			validator.destination = destination;
			
			// Dispatch the trigger event.
			var failed : Boolean = false;
			
			try
			{
				validator.isValid();
			}
			catch ( error : Error )
			{
				failed = false;
			}
			
			assertFalse( failed );
		}
	}
}