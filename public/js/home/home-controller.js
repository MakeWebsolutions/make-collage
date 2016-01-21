angular.module('make-collage')
  .controller('HomeController', ['$scope', '$http', function ($scope, $http) {
  	$scope.loading = false;

  	$scope.connect = function() {
  		$scope.loading = true;
  	}
  }]);
