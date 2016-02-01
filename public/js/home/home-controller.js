angular.module('make-collage')
  .controller('HomeController', ['$scope', '$http', '$routeParams', function ($scope, $http, $routeParams) {
  	$scope.loading = false;
  	
  	$scope.user = $routeParams.e;

  	$scope.connect = function() {
  		$scope.loading = true;
  		console.log("o")
  	}
  }]);
