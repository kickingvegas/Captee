var ExtensionClass = function() {};

ExtensionClass.prototype = {
    run: function(arguments) {
        arguments.completionFunction({
            "title": document.title,
            "href": document.location.href
        });
    }
};

var ExtensionPreprocessingJS = new ExtensionClass;
