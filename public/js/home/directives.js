(function() {

	angular.module('make-collage')
		.directive('copyToClipboard', [function() {
			return {
				restrict: 'A',
				scope: false,
				link: function(scope, element, attrs) {
					$element = $(element);

					$element.on('click', function() {
						if(!!attrs.copyToClipboard) { 
							$('#'+ attrs.copyToClipboard).select();
						}else{
							$(element).select();
						}

						try {
							document.execCommand('copy');
						} catch(err) {}
					});
				}
			}
		}]);

})();