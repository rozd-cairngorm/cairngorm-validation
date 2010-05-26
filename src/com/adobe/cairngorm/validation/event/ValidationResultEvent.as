package com.adobe.cairngorm.validation.event
{
    import mx.events.ValidationResultEvent;
    
    public class ValidationResultEvent extends mx.events.ValidationResultEvent
    {
        public static const INVALID:String = "invalid";
        public static const VALID:String = "valid";
        
        private var _target:Object;
        
        public function ValidationResultEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false, field:String=null, results:Array=null)
        {
            super(type, bubbles, cancelable, field, results);
        }
        
        override public function get target():Object{
            return _target;
        }
        
        public function set target(value:Object):void{
            this._target = value;
        }
        
        
        
    }
}