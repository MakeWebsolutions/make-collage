// Declare app level module which depends on filters, and services
angular.module('make-collage', ['ngResource', 'ngRoute', 'ui.bootstrap', 'ui.date', 'ui.sortable', 'colorpicker.module'])
  .config(['$routeProvider', function ($routeProvider) {
    $routeProvider
      .when('/', {
        templateUrl: 'views/home/home.html', 
        controller: 'HomeController'})

      .when('/builder', {
        templateUrl: 'views/home/builder.html', 
        controller: 'BuilderController'})

      .otherwise({redirectTo: '/'});
  }]);
