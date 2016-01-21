angular.module('make-collage')
  .controller('BuilderController', ['$scope', '$http', function ($scope, $http) {
  	$scope.error = null;
    $scope.backgroundColor = '#e0e3e4';

  	$http({
  		url: '/images'
  	}).then(function(res) {
  		
  		if(res.data.error) {
  			$scope.error = 'Not authorized';
  			return;
  		}
      $scope.images = [];
      $scope.images[0] = $.map(res.data.images, function(img, index) {
  			return { 'src': img.images.standard_resolution.url, 'col': 4, 'order': index, 'id': index };
  		});
      $scope.images[1] = [];
  		
   	});

    function createOptions (listName) {
      var _listName = listName;
      var options = {
        connectWith: ".ank",
        placeholder: "placeholder",
        forcePlaceholderSize: true,
        'ui-floating': true,
        helper: function(e, ui) {
          ui.children().each(function() {
            angular.element(this).width('203.33');
          });
          return ui;
        },
        zIndex: 300,
        start: function(e, f) {
          $(f.item).height(203.33);
        }
      };
      return options;
    }

    $scope.sortableOptionsList = [createOptions('A'), createOptions('B')];

		$scope.generate = function() {
  		$butt = angular.element('#butt');
      $butt.text('Working...');
      
      angular.forEach($scope.images[1], function(item, index) {
  			item.y = $('#'+item.id).position().top;
  			item.x = $('#'+item.id).position().left;
  			item.width = $('#'+item.id).width();
  			item.height = $('#'+item.id).height();
  		});
  		
  		$http({
  			method: 'POST',
  			url: '/generate',
  			data: {
  				images: $scope.images[1],
  				imageheight: $('#container-inner').height(),
          backgroundcolor: $scope.backgroundColor || null
  			},
  			params: {
  				action: 'generate'
  			}
  		}).success(function(res) {
        $scope.url = res.url;
        $butt.text('Generate');
      })
  	}

  }]);