(function(){
    var app = angular.module("dacp", []);
    app.controller("listController", ['$scope', '$http', function($scope, $http){
        $http.get('/list.json').success(function(data){
            $scope.list = data;
            console.log(data);
        });
    }]);
})();
