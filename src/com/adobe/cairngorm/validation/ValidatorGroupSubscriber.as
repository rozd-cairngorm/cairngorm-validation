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
package com.adobe.cairngorm.validation
{
    import flash.events.EventDispatcher;
    import flash.events.FocusEvent;
    
    import mx.binding.utils.BindingUtils;
    import mx.core.IMXMLObject;
    import mx.core.UIComponent;
    import mx.events.FlexEvent;
    import mx.events.ValidationResultEvent;
    import mx.validators.IValidatorListener;
    import mx.validators.Validator;

    [DefaultProperty("subscribers")]
    public class ValidatorGroupSubscriber extends EventDispatcher implements IMXMLObject
    {

        /**
         * This property holds the list of ValidatorGroupSubscriber.
         *
         * <br>It accept only elements of type ValidatorGroupSubscriber.
         * This property is a template and should be used in MXML.
         *
         * @see #registerForValidationEvents()
         *
         * @example
         *   <br>
         *   &lt;validators:ValidatorGroupSubscriber &gt; <br>
         *   &nbsp;&nbsp;&lt;validators:subscribers&gt;<br>
         *   &nbsp;&nbsp;&nbsp;&nbsp;&lt;validators:ValidatorGroupSubscriber <br>
         *   &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;validator="{ model.validatorGroup.firstnameValidator }" <br>
         *   &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;control="{ firstnameInput } /&gt;<br>
         *   &nbsp;&nbsp;&lt;/validators:subscribers&gt; <br>
         *   &lt;/validators:ValidatorGroupSubscriber&gt;<br>
         *
         */
        [ArrayElementType("com.adobe.cairngorm.validation.ValidatorSubscriber")]
        public var subscribers:Array;

        [Bindable]
        public var enableControlTrigger:Boolean = false;
		
		/**
		 * By setting this property to true, the Validator Listener is going to be reset to VALID 
		 * on FOCUS_IN event.  
		 */
		[Bindable]
		public var resetValidationFeedbackOnFocusIn : Boolean = false;

        public var autoInit:Boolean = true;

        /**
         * The ValidatorGroupSubscriber constructor.
         */
        public function ValidatorGroupSubscriber()
        {
            super();
        }

        /**
         * This is a Static method used to register the specified Validator with the specified listener.
         *
         * <br>If the listener is a UIComponent it will show the error tooltip and the red border
         * as soon as the validator dispatch the INVALID event.<br>
         * The listener can be anything that implements IValidatorListener.
         *
         * <br><br>This method can be used in ActionScript direclty. If the ValidatorGroupSubscriber
         * is used in MXML using the subscribers template, this method is called automatically for each ValidatorSubscriber.
         *
         * @param validator The validator to register with the listener
         * @param listener The listener. It can be anything that implements IValidatorListener
         * @param forceValidation This flag will force the validation if set to True for the specified validator after it is being registered with the listener
         * @param enableTrigger This flag will set the trigger property of the specified Validator if set to True
         */
        public static function registerForValidationEvents(
            validator:Validator,
            listener:EventDispatcher,
            forceValidation:Boolean = false,
            enableTrigger:Boolean = false):void
        {
            //If the listener is different from null mean the validator is already linked to a
            //listener, therefore we first reset the listener before setting the new one. 
            if (validator.listener != null)
            {
                var validationResultEvent:ValidationResultEvent = new ValidationResultEvent(ValidationResultEvent.VALID);

                IValidatorListener(validator.listener).validationResultHandler(
                    validationResultEvent);

                validator.listener = null;
                validator.trigger = null;
            }

            if (forceValidation)
            {
                validator.validate();
            }

            if (enableTrigger)
            {
                validator.trigger = listener;
            }

            validator.listener = listener;
        }
		
		private function handleFocusIn( event : FocusEvent ) : void
		{
			var validationResultEvent:ValidationResultEvent = new ValidationResultEvent(ValidationResultEvent.VALID);
			IValidatorListener( event.currentTarget ).validationResultHandler( validationResultEvent );
		}

        public function set triggerInit(value:Object):void
        {
            //Ignore this call if the auto init is active.
            if (autoInit == true)
            {
                return;
            }

            if ((value is Boolean && value == true) || value != null)
            {
                initializeSubscribers();
            }
        }

        /**
         * @private
         */
        public function initialized(document:Object, id:String):void
        {
            if (document is UIComponent)
            {
                UIComponent(document).addEventListener(
                    FlexEvent.CREATION_COMPLETE,
                    handleDocumentCreated);
            }
        }

        private function initializeSubscribers():void
        {
            if (subscribers != null)
            {
                for (var i:uint = 0; i < subscribers.length; i++)
                {
                    var subscriber:ValidatorSubscriber = subscribers[i];

                    if (subscriber.validator)
                    {
                        subscribeControl(subscriber);
                    }
                }
            }
        }

        private function registerSubscribers():void
        {
            if (subscribers != null)
            {
                for (var i:uint = 0; i < subscribers.length; i++)
                {
                    var subscriber:ValidatorSubscriber = subscribers[i];
                    BindingUtils.bindSetter(subscribedInitialized, subscriber, [ "listener" ]);
                }
            }
        }

        private var count:int = 0;

		private function containNullValues( value : Array ) : Boolean
		{
			for each( var item : Object in value )
			{
				if( item == null )
				{
					return true;
				}
			}
			
			return false;
		}
		
        private function subscribedInitialized(listener:Object):void
        {
            if( listener != null && listener is Array && containNullValues( listener as Array ) == false )
            {
				count++;
            }
			
			if( listener != null && listener is IValidatorListener )
			{
				count++;
			}

            if (count == subscribers.length)
            {
                initializeSubscribers();
            }
        }

        private function subscribeControl(subscriber:ValidatorSubscriber):void
        {
			var subscriberListener : EventDispatcher;
			
			if( subscriber.listener && subscriber.listener is Array )
			{
				subscriberListener = new ValidatorMultipleListeners( subscriber.listener as Array );		
			}
            else if( !(subscriber.listener is Array) )
			{
				subscriberListener = EventDispatcher( subscriber.listener );
			}
			
            registerForValidationEvents(
                subscriber.validator,
				subscriberListener, false, enableControlTrigger);
			
			if( resetValidationFeedbackOnFocusIn )
			{
				UIComponent( subscriber.listener ).addEventListener(FocusEvent.FOCUS_IN, handleFocusIn ); 
			}
        }

        private function handleDocumentCreated(event:FlexEvent):void
        {
            if (autoInit)
            {
                registerSubscribers();
            }
        }

    }
}