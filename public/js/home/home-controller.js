angular.module('make-collage')
  .controller('HomeController', ['$scope', '$http', '$routeParams', function ($scope, $http, $routeParams) {
  	$scope.loading = false;

  	$scope.userid = $routeParams.userid;

  	$scope.connect = function() {
  		$scope.loading = true;
  	}
  }]);
