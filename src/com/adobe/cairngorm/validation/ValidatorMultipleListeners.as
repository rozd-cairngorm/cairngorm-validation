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

    import mx.events.ValidationResultEvent;
    import mx.validators.IValidatorListener;

    public class ValidatorMultipleListeners extends EventDispatcher implements IValidatorListener
    {

        [ArrayElementType("mx.validators.IValidatorListener")]
        private var listeners:Array;

        private var _errorString:String;

        private var _validationSubField:String;

        public function ValidatorMultipleListeners(listeners:Array)
        {
            this.listeners = listeners;
        }

        public function get errorString():String
        {
            return _errorString;
        }

        public function set errorString(value:String):void
        {
            _errorString = value;

            for each (var listener:IValidatorListener in listeners)
            {
                listener.errorString = errorString;
            }
        }

        public function get validationSubField():String
        {
            return _validationSubField;
        }

        public function set validationSubField(value:String):void
        {
            _validationSubField = value;

            for each (var listener:IValidatorListener in listeners)
            {
                listener.validationSubField = validationSubField;
            }
        }

        public function validationResultHandler(event:ValidationResultEvent):void
        {
            for each (var listener:IValidatorListener in listeners)
            {
                if (listener)
                {
                    listener.validationResultHandler(event);
                }
            }
        }
    }
}