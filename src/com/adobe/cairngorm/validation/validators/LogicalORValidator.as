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
     * This class provides a logical OR Validator. It takes an Array of
     * <code>source</code> fields and returns ValidationResultEvent.VALID if one
     * them has a value.
     *
     * You can provide an Array of <code>properties</code>, which must have the
     * same number of elements as the <code>source</code> Array.  Alternatively
     * you can specify a single property using <code>property</code>, which will
     * be used for all <code>source</code> fields.
     *
     * The following example shows how to use the Validator, it is not very
     * elegant. Ideally we would specify the <code>source</code> using the MXML
     * binding syntax to pass an Array of Object references, which doesn't work.
     *
     * The following method must be defined in an Script block and called on
     * "creationComplete":
     *
     * private function initValidator() : void
     * {
     *    var sources : Array = new Array();
     *	  sources.push(lastName);
     *	  sources.push(ssn);
     *	  sources.push(dateOfBirth);
     *	  sources.push(homePhone);
     *
     *    searchValidator.source = sources;
     * }
     *
     * The Validator is declated in the MXML as follows:
     *
     * &lt;validators:LogicalORValidator&gt;
     *     &lt;id="searchValidator"&gt;
     *     &lt;propery="text"&gt;
     * &lt;/validators:LogicalORValidator&gt;
     *
     * This Validator doesn't support validate required (it doesn't call
     * "super.doValidation()").
     *
     */
    public class LogicalORValidator extends AbstractMessageValidator
    {
        protected static const ERROR_CODE:String = "noValues";

        [ArrayElementType("Object")]
        private var _source:Array;

        [ArrayElementType("Object")]
        private var _properties:Array;

        /**
         * Override "source" to provide an Array of source fields.
         */
        [Inspectable]
        override public function set source(value:Object):void
        {
            if (_source != value)
            {
                // Check the value is an Array.
                if (!value is Array)
                {
                    throw new Error("The source attribute, " + value + " must be an Array.");
                }

                // Check the value (Array) doesn't contain Strings.
                var fields:Array = value as Array;

                for (var i:uint = 0; i < fields.length; i++)
                {
                    var field:Object = fields[i];

                    if (field is String)
                    {
                        throw new Error("The source attribute can not contain values of type String.");
                    }
                }

                // Remove the trigger and listener from the old source.
                removeTriggerHandler();
                removeListenerHandler();

                _source = fields;

                // Add the trigger and listener to the new source.
                addTriggerHandler();
                addListenerHandler();
            }
        }

        /**
         * Override "source" to return the source fields.
         * @return the source fields or an empty Array if there are none.
         */
        override public function get source():Object
        {
            var source:Array;

            if (_source)
            {
                source = _source;
            }
            else
            {
                source = new Array();
            }

            return source;
        }

        /**
         * An Array specifying the source properties that contain the values to
         * validate.
         *
         * The property is optional, and the default value is null.
         */
        [Inspectable]
        public function set properties(value:Array):void
        {
            _properties = value;
        }

        /**
         * Return the source properties.
         * @return the Array of source properties.
         */
        public function get properties():Array
        {
            return _properties;
        }

        /**
         * Override "doValidation" to check if one of the source fields has a
         * value.
         */
        override protected function doValidation(value:Object):Array
        {
            var results:Array = new Array();
            var valid:Boolean = false;

            // Loop through the source fields.
            for (var i:uint = 0; i < _source.length; i++)
            {
                // Get the value from the field.
                var value:Object = getValueForSource(i);

                // If we have a value, stop checking and set valid to true.
                if (value != null && value.length > 0)
                {
                    valid = true;
                    break;
                }
            }

            // If we didn't find a value return a error, which will result in a
            // ValidationResultEvent.INVALID event.
            if (!valid)
            {
                results.push(new ValidationResult(true, String(value), ERROR_CODE,
                                                  message));
            }

            return results;
        }

        /**
         * Override "actualListners" to so we can return our source Array.
         */
        override protected function get actualListeners():Array
        {
            var result:Array = null;

            // Check if we have a "listener" set, if not use the "source",
            // failing that we return an empty Array.
            if (listener)
            {
                result = [ listener ];
            }
            else if (_source)
            {
                result = _source;
            }
            else
            {
                result = new Array();
            }

            return result;
        }

        /**
         * Override "getValueFromSource" to return an empty value, otherwise
         * "doValidation" will not be called.
         */
        override protected function getValueFromSource():Object
        {
            return "";
        }

        /**
         * Return the value for the source field at the given position. It first
         * checks to see if <code>properties</code> was set, otherwise it will
         * use <code>property</code> as the name of the property on the
         * source field containing the value.
         * @param position the position in the source Array.
         * @return the value of the object.
         */
        protected function getValueForSource(position:uint):Object
        {
            var value:Object;
            var field:Object = _source[position];

            // Check and see if "properties" was set, if not check for
            // "property".
            if (_properties)
            {
                // Only use "properties" if has the same number of elements as
                // the "source" Array.
                if (position < properties.length)
                {
                    var prop:String = properties[position];
                    value = field[prop];
                }
                else
                {
                    // Throw an Error if we don't have an equal number of
                    // elements.
                    throw new Error("The source Array and the properties Array must contain the same number of elements.");
                }
            }
            else if (property)
            {
                value = field[property];
            }
            else
            {
                // Throw an Error if "properties" or "property" was not set.
                throw new Error("The property attribute or the properties attribute must be specified. ");
            }

            return value;
        }

        /**
         * Add a listener to trigger the Validator.
         */
        protected function addTriggerHandler():void
        {
            for (var i:uint = 0; i < source.length; i++)
            {
                var field:IEventDispatcher = source[i];

                if (field)
                {
                    field.addEventListener(triggerEvent, handleTrigger);
                }
            }
        }

        /**
         * Remove the listener that triggers the Validator.
         */
        protected function removeTriggerHandler():void
        {
            for (var i:uint = 0; i < source.length; i++)
            {
                var field:IEventDispatcher = source[i];

                if (field)
                {
                    field.removeEventListener(triggerEvent, handleTrigger);
                }
            }
        }

        /**
         * Event listener to handle the trigger event fired by destination
         * component.
         */
        protected function handleTrigger(event:Event):void
        {
            validate();
        }
    }
}