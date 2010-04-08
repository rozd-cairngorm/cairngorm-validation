package com.adobe.cairngorm.validation.validators
{
    import mx.validators.ValidationResult;
    import mx.validators.Validator;
    
    public class BooleanValidator extends Validator
    {
        
        public function BooleanValidator()
        {
            super();
        }
        
        public static function validateBoolean(
            validator:BooleanValidator, value:Boolean, baseField:String = null):Array
        {
            var results:Array = [];
            
            if (!value)
            {
                results.push(new ValidationResult(true));
                return results;
            }
            
            return results;
        }
        
        override protected function doValidation(value:Object):Array
        {
            var results:Array = super.doValidation(value);
            
            if (results.length > 0)
                return results;
            else
                return BooleanValidator.validateBoolean(this, (value as Boolean), null);
        }
    }
    
}