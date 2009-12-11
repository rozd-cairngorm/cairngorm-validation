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
	import flash.events.IEventDispatcher;
	
	import mx.events.ValidationResultEvent;
	import mx.validators.ValidationResult;
	import mx.validators.Validator;

	/**
	 * <p>
	 * This class provides a Validator for comparing the value of two fields. It
	 * compares a source field against a destination field. For example, the
	 * destination could be a password field and the source a retypePassword
	 * field.
	 * </p>
	 * <p>
	 * The <code>&lt;validators:FieldComparisonValidator&gt;</code> tag inherits all of the tag
	 * attributes of its superclass, and adds the following tag attributes:
	 * </p>
	 * <code>&lt;validators:FieldComparisonValidator
	 *   destination="<em>No default</em>"
	 *   destinationProperty="<em>Value of the destination property</em>"
	 *   destinationTrigger="<em>Value of the destination property</em>"
	 *   destinationTriggerEvent="<em>valueCommit</em>"
	 * /&gt;</code>
	 * </p>
	 * <p>
	 * This Validator doesn't support validate required (it doesn't call
	 * "super.doValidation()"). It assumes the destination has a validate
	 * required.
	 * </p>
	 */
	public class FieldComparisonValidator extends AbstractMessageValidator
	{	
		// Static constants.
		protected static const LISTENER_FUNCTION : String = "handleValidationResult";
		protected static const TRIGGER_EVENT : String = "valueCommit";
		protected static const ERROR_CODE : String = "mismatch";
		protected static const ERROR_MESSAGE : String =
			"The source string doesn't match the destination."
		
		protected var _destFired : Boolean;
		protected var _validationDone : Boolean;
		
		private var _dest : Object;
		private var _destProperty : String;
		private var _destTrigger : IEventDispatcher;
		private var _destTriggerEvent : String = TRIGGER_EVENT;
		
		/**
		 * Constructor.
		 */
		public function FieldComparisonValidator()
		{
			// Set the default error message.
			message = ERROR_MESSAGE;	
		}
		
		/**
	 	 * Specifies the destination object containing the property to validate
	 	 * against. Set this to an instance of a component or a data model.
	 	 * You use data binding syntax in MXML to specify the value.
	 	 *
	 	 * If you specify a value to the <code>dest</code> property,
	 	 * then you should specify a value to the <code>destProperty</code>
	 	 * property as well. 
	 	 * 
	 	 * The <code>destination</code> property is optional.
	 	 * The default value is null.
	 	 */
	 	[Inspectable]
		public function set destination( value : Object ) : void
	  	{
			if ( _dest != value )
			{	
				// Check the value is not a String.
				if ( value is String )
				{
					throw new Error(
						"The dest attribute, " + value + ", can not be of type String."	);
				}
		
				// Remove the trigger and listener from the old source.
				removeDestTriggerHandler();
		
				_dest = value;
				
				// Add the trigger and listener to the new source.
				addDestTriggerHandler();	
			}
		}
	
		/**
	 	 * Return the destination object.
	 	 * @return the destination.
	 	 */
		public function get destination() : Object
		{
			return _dest;
		}
		
		/**
		 * A String specifying the name of the property of the <code>dest</code>
		 * object that contains the value to validate.
	 	 * This property supports dot-delimited Strings for specifying nested
	 	 * properties.
	 	 * The property is optional, but if you specify <code>dest</code>,
	 	 * you should set a value for this property as well.
	 	 * The default value is null.
	 	 */
	 	[Inspectable]
		public function set destinationProperty( value : String ) : void
		{
			_destProperty = value;
		}
	
		/**
	 	 * Return the destination property.
	 	 * @return the destination property.
	 	 */
		public function get destinationProperty() : String
		{
			return _destProperty;
		}
		
		/**
	 	 * Specifies the component generating the event that triggers the validator. 
	     * If omitted, by default Flex uses the value of the <code>dest</code> property.
	     * When the <code>destTrigger</code> dispatches a <code>destTriggerEvent</code>,
	     * validation executes. 
	     * @param value the component triggering the validator.
	     */
	 	[Inspectable]
		public function set destinationTrigger( value : IEventDispatcher ) : void
		{
			removeDestTriggerHandler();
			_destTrigger = value;
			addDestTriggerHandler();	
		}
		
		/**
		 * Return the component generating the event that triggers the
		 * validator.
		 * @param return the component triggering the validator.
		 */
		public function get destinationTrigger() : IEventDispatcher
		{
			return _destTrigger;
		}
		
		/**
		 *  Specifies the event that triggers the validation. 
	     *  If omitted, Flex uses the <code>valueCommit</code> event. 
	     *  Flex dispatches the <code>valueCommit</code> event
	     *  when a user completes data entry into a control.
	     *  Usually this is when the user removes focus from the component, 
	     *  or when a property value is changed programmatically.
	     *  If you want a validator to ignore all events,
	     *  set <code>destTriggerEvent</code> to the empty string ("").
	     */
		public function set destinationTriggerEvent( value : String ) : void
		{
			if ( _destTriggerEvent != value )
			{
				removeDestTriggerHandler();
				_destTriggerEvent = value;
				addDestTriggerHandler();
			}
		}
	
		/**
		 * Return the events that triggers the validator.
		 * @param return the event triggering the validator.
		 */
		public function get destinationTriggerEvent() : String
		{
			return _destTriggerEvent;
		}
		
	  	/**
	  	 * Override "doValidation" to compare the source and the destination.
	  	 */
		override protected function doValidation( value : Object ) : Array
	    {
	    	var results : Array = new Array();
	    	
	    	// Get the source and destination values.
	    	var sourceValue : Object = getValueFromSource();
	    	var destValue : Object = getValueFromDestination();
	    	
			// Check the source and destination match.
			if( sourceValue != destValue )
			{
				var mismatch : ValidationResult =
					new ValidationResult( true,	String( value ), ERROR_CODE, message );
					
				results.push( mismatch );
	    	}
			
			// This is a solution to a "corner case" - we need to know if the
			// user completes the source field before the destination. This
			// scenario is an extension of the "corner case" documented under
			// "handleDestTrigger()".
			if ( ! _validationDone )
			{
				_validationDone = true;
			}
			
			return results;
	    }
	    	  	
	  	/**
	  	 * Return the value from the destination.
	  	 * @return the destination value.
	  	 */
	  	protected function getValueFromDestination() : Object
		{
			var value : Object = null;
			
			if ( _dest && _destProperty )
			{
				value = _dest[ _destProperty ];
			}
			else if ( ! _dest && _destProperty )
			{
				throw new Error(
					"The dest attribute must be specified when the destProperty attribute is specified." );
			}
			else if ( _dest && !_destProperty )
			{
				throw new Error(
					"The destProperty attribute must be specified when the dest attribute is specified." );
			}
		
			return value;
		}
		
		/**
		 * Return the actual component generating the event that triggers the
		 * validator.
		 * @return the actual component that triggers the validator.
		 */
		protected function get actualDestTrigger() : IEventDispatcher
		{
			var trigger : IEventDispatcher = _dest as IEventDispatcher;

			if ( _destTrigger )
			{
				trigger = _destTrigger
			}
			
			return trigger;
		}
		
		/**
		 * Add a listener to trigger the Validator.
		 */
		protected function addDestTriggerHandler() : void
		{
			var trigger : IEventDispatcher = actualDestTrigger;
			
			if ( trigger )
			{
				trigger.addEventListener(
					destinationTriggerEvent,
					handleDestTrigger );
			}
		}
	
		/**
		 * Remove the listener that triggers the Validator.
		 */
		protected function removeDestTriggerHandler() : void
		{
			var trigger : IEventDispatcher = actualDestTrigger;
			
			if ( trigger )
			{
				trigger.removeEventListener(
					destinationTriggerEvent,
					handleDestTrigger );
			}
		}
		
		/**
		 * Event listener to handle the trigger event fired by destination
		 * component.
		 */
		protected function handleDestTrigger( event : Event ) : void
		{
			// This is a solution to a "corner case" - we don't want the
			// validation to occurr the first time the destination fires, as we
			// don't want to display the error message on the source.
			if ( _destFired || _validationDone )
			{
				validate();
			}
			
			// We want to know if this is the first time the destination has
			// fired the Validator trigger event.
			if ( ! _destFired )
			{
				_destFired = true;
			}
		}
	}
}