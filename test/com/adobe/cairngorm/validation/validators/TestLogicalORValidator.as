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
	
	import mx.controls.TextInput;
	import mx.events.ValidationResultEvent; 

	public class TestLogicalORValidator extends TestCase
	{
		private var validator : DerivedLogicalORValidator;
		
		/**
		 * Constructor.
		 * @param methodName the name of the individual test to run.
		 */
		public function TestLogicalORValidator( methodName : String = null )
		{
			super( methodName );
		}
	
		/**
		 * @see flexunit.framework.TestCase#setUp().
		 */
		override public function setUp() : void
		{
			validator = new DerivedLogicalORValidator();
		}
		
		/**
		 * @see flexunit.framework.TestCase#tearDown().
		 */
		override public function tearDown() : void
		{
			validator = null;
		}
		
		/**
		 * Test "setSource", without passing in an Array. We expect an Error to
		 * be thrown.
		 */
		public function testSetSourceWithoutArray() : void
		{
			var failed : Boolean = true;
			
			try
			{
				validator.source = new Object();
			}
			catch ( error : Error )
			{
				failed = false;
			}
			
			assertFalse( failed );
		}
		
		/**
		 * Test "setSource", with an Array of fields. We expect the trigger and
		 * listener to be set on each field.
		 */
		public function testSetSourceWithArray() : void
		{
			// Create the fields.
			var field1 : TextInput = new TextInput();
			var field2 : TextInput = new TextInput();
			
			var fields : Array = new Array();
			fields.push( field1 );
			fields.push( field2 );
			
			// Set the fields on the validator.
			validator.source = fields;
			
			// Check the trigger was set.
			assertTrue( field1.willTrigger( "valueCommit" ) );
			assertTrue( field2.willTrigger( "valueCommit" ) );
			
			// Check the listeners were registered (not ideal as it only check
			// if that event is registered, not if there is a handler registered
			// on each of the fields).
			assertTrue( validator.willTrigger( ValidationResultEvent.INVALID ) );
			assertTrue( validator.willTrigger( ValidationResultEvent.VALID ) );
		}
		
		/**
		 * Test "getSource" with a 'source' set.
		 */
		public function testGetSourceWithSource() : void
		{
			var fields : Array = new Array();
			
			validator.source = fields;
			
			assertEquals( fields, validator.source );			
		}
		
		/**
		 * Test "getSource" with no 'source' set.
		 */
		public function testGetSourceWithNoSource() : void
		{			
			assertEquals( 0, validator.source.length );			
		}
		
		/**
		 * Test "getProperties".
		 */
		public function testGetProperties() : void
		{
			var properties : Array = new Array();
			
			validator.properties = properties;
			
			assertEquals( properties, validator.properties );	
		}
		
		/**
		 * Test "doValidation" with no values and 'property'. It should fire an
		 * INVALID event.
		 */
		public function testDoValidation1() : void
		{
			// Create the fields.
			var field1 : TextInput = new TextInput();
			var field2 : TextInput = new TextInput();
			
			var fields : Array = new Array();
			fields.push( field1 );
			fields.push( field2 );
			
			// Set the fields on the validator.
			validator.source = fields;
			validator.property = "text";
			
			// Do the validation.
			assertFalse( validator.isValid() );
		}
		
		/**
		 * Test "doValidation" with one value and 'property'. It should fire a
		 * VALID event.
		 */
		public function testDoValidation2() : void
		{
			// Create the fields.
			var field1 : TextInput = new TextInput();
			field1.text = "hello";
			
			var field2 : TextInput = new TextInput();
			
			var fields : Array = new Array();
			fields.push( field1 );
			fields.push( field2 );
			
			// Set the fields on the validator.
			validator.source = fields;
			validator.property = "text";
			
			// Do the validation.
			assertTrue( validator.isValid() );
		}
		
		/**
		 * Test "doValidation" with values for all fields and 'property'. It
		 * should fire a VALID event.
		 */
		public function testDoValidation3() : void
		{
			// Create the fields.
			var field1 : TextInput = new TextInput();
			field1.text = "hello";
			
			var field2 : TextInput = new TextInput();
			field2.text = "hello"
			
			var fields : Array = new Array();
			fields.push( field1 );
			fields.push( field2 );
			
			// Set the fields on the validator.
			validator.source = fields;
			validator.property = "text";
			
			// Do the validation.
			assertTrue( validator.isValid() );
		}
		
		/**
		 * Test "doValidation" with no values and 'properties'. It should fire
		 * an INVALID event.
		 */
		public function testDoValidation4() : void
		{
			// Create the fields.
			var field1 : TextInput = new TextInput();
			var field2 : TextInput = new TextInput();
			
			var fields : Array = new Array();
			fields.push( field1 );
			fields.push( field2 );
			
			// Set the fields on the validator.
			validator.source = fields;
			validator.properties = [ "text", "text" ];
			
			// Do the validation.
			assertFalse( validator.isValid() );
		}
		
		/**
		 * Test "doValidation" with one value and 'properties'. It should fire a
		 * VALID event.
		 */
		public function testDoValidation5() : void
		{
			// Create the fields.
			var field1 : TextInput = new TextInput();
			field1.text = "hello";
			
			var field2 : TextInput = new TextInput();
			
			var fields : Array = new Array();
			fields.push( field1 );
			fields.push( field2 );
			
			// Set the fields on the validator.
			validator.source = fields;
			validator.properties = [ "text", "text" ];
			validator.message = "error";
			
			// Do the validation.
			assertTrue( validator.isValid() );
		}
		
		/**
		 * Test "doValidation" with values for all fields and 'properties'. It
		 * should fire a VALID event.
		 */
		public function testDoValidation6() : void
		{
			// Create the fields.
			var field1 : TextInput = new TextInput();
			field1.text = "hello";
			
			var field2 : TextInput = new TextInput();
			field2.text = "hello"
			
			var fields : Array = new Array();
			fields.push( field1 );
			fields.push( field2 );
			
			// Set the fields on the validator.
			validator.source = fields;
			validator.properties = [ "text", "text" ];
			
			// Do the validation.
			assertTrue( validator.isValid() );
		}

		/**
		 * Test "doValidation" with a different number of 'properties' to the
		 * number of fields. It should throw an error.
		 */
		public function testDoValidation7() : void
		{
			// Create the fields.
			var field1 : TextInput = new TextInput();
			
			var field2 : TextInput = new TextInput();
			field2.text = "hello"
			
			var fields : Array = new Array();
			fields.push( field1 );
			fields.push( field2 );
			
			// Set the fields on the validator.
			validator.source = fields;
			validator.properties = [ "text" ];
			
			// Do the validation.
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
		 * Test "doValidation" without setting 'property' or 'properties'. It
		 * should throw an error.
		 */
		public function testDoValidation8() : void
		{
			// Create the fields.
			var field1 : TextInput = new TextInput();
			field1.text = "hello";
			
			var field2 : TextInput = new TextInput();
			field2.text = "hello"
			
			var fields : Array = new Array();
			fields.push( field1 );
			fields.push( field2 );
			
			// Set the fields on the validator.
			validator.source = fields;
			
			// Do the validation.
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
		 * Test "doValidation" with a different listener.
		 */
		public function testDoValidation9() : void
		{
			// Set the listener to this tesat class.
			validator.listener = this;
			
			// Get the actual listeners.
			var listeners : Array = validator.getActualListeners();
			
			// Check we only have one listener.
			assertEquals( 1, listeners.length );
			
			// Check the listener is this test class.
			assertEquals( this, listeners[ 0 ] );
		}
	}
}