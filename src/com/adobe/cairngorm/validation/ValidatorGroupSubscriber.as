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
    import flash.events.EventDispatcher;

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
         * @param enableTrigger This flag will set the trigger property of the of the specified Validator if set to True
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

        private function subscribedInitialized(listener:Object):void
        {
            if (listener != null)
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
            registerForValidationEvents(
                subscriber.validator,
                subscriber.listener, false, enableControlTrigger);
        }

        private function handleDocumentCreated(event:FlexEvent):void
        {
            if (autoInit)
            {
                //initializeSubscribers();
                registerSubscribers();
            }
        }

    }
}