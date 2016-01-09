(function(){
    var app = angular.module("dacp", []);
    app.config = {};

/*
    app.factory('configService', ['$rootScope', function ($rootScope) {
        var service = {
            config: { },
            SaveState: function () {
                sessionStorage.userService = angular.toJson(service.config);
            },
            RestoreState: function () {
                service.config = angular.fromJson(sessionStorage.userService);
            }
        }

        $rootScope.$on("savestate", service.SaveState);
        $rootScope.$on("restorestate", service.RestoreState);

        return service;
    }]);
*/

    app.controller("listController", ['$scope', '$http', '$interval', function($scope, $http, $interval){
        $scope.config = app.config;
        $scope.refresh = function(){
            $http.get('/api/list').success(function(data){
                $scope.list = data;
                console.log(data);
            });
        }
        $scope.start = function(instance_id) {
            $http.get('/api/instance/start/' + instance_id).success(function(data){
                $scope.refresh();
            });
        }
        $scope.stop = function(instance_id) {
            $http.get('/api/instance/stop/' + instance_id).success(function(data){
                $scope.refresh();
            });
        }
        $interval($scope.refresh, 15000);
        $scope.refresh();
    }]);
    app.controller("configController", ['$scope', '$http', function($scope, $http){
        $http.get('/api/config').success(function(data){
            app.config = data.config;
            $scope.config = data.config;
        });
    }]);
    app.controller("navController", ['$scope', '$http', function($scope, $http){
        $scope.enroll = function(){
            $http.get('/api/enroll_cluster').success(function(data){
            });
        };
        $scope.destroy = function(){
            $http.get('/api/destroy_cluster').success(function(data){
            });
        };
    }]);
})();
