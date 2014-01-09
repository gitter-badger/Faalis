/* -----------------------------------------------------------------------------
    Red Base - Basic website skel engine
    Copyright (C) 2012-2013 Yellowen

    This program is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License along
    with this program; if not, write to the Free Software Foundation, Inc.,
    51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
----------------------------------------------------------------------------- */

var Group = angular.module("Group", ["ListView", "Errors"]);

Group.config(["$routeProvider", function($routeProvider){
    $routeProvider.
        when("/auth/groups",{
            templateUrl: template("auth/groups/index"),
            controller: "GroupsController"
        }).
        when("/auth/groups/new",{
            templateUrl: template("auth/groups/new"),
            controller: "AddGroupController"
        }).
        when("/auth/groups/:id/edit",{
            templateUrl: template("auth/groups/new"),
            controller: "AddGroupController"
        });

}]);

Group.controller("GroupsController", ["$scope", "gettext", "Restangular", "catch_error", function($scope, gettext, API, catch_error){
    $scope.details_template = template("auth/groups/details");

    $scope.buttons = [
        {
            title: gettext("new"),
            icon: "fa fa-plus",
            classes: "btn tiny green",
            route: "#/auth/groups/new"

        }
    ];

    $scope.on_delete = function(groups){

        var query = [];
        groups.forEach(function(group){
            query.push(group.id);
        });

        API.all("groups").customDELETE(query.join(","))
            .then(function(data) {

                $scope.groups = _.filter($scope.groups, function(x){
                    return !(query.indexOf(x.id) != -1);
                });
                success_message(data.msg);
            })
            .catch(catch_error);

    };


    API.all("groups").getList()
        .then(function(data){
            $scope.groups = data;
        })
        .catch(catch_error);

}]);

Group.controller("AddGroupController", ["Restangular", "$scope", "$location", "$routeParams", "gettext", "catch_error", function(API, $scope, $location, $routeParams, gettext, catch_error){

    $scope.selected_perms = [];
    $scope.permissions = [];
    $scope.editing = false;

    $scope.$on("update_perms", function(event) {
        var sel_perms = [];
        event.targetScope.selected_perms.forEach(function(perm){

            var tmpobj = _.find(event.targetScope.permissions, function(x) {
                return perm.name == x.name;
            });

            if ( tmpobj ) {
                event.targetScope.select_permission(tmpobj);
            }
        });

    });

    $scope.obj_id = null;

    if("id" in $routeParams){
        $scope.obj_id = $routeParams.id;
        $scope.editing = true;
        var obj = API.one("groups", $scope.obj_id).get()
                .then(function(data) {
                    $scope.new_name = data.name;
                    $scope.selected_perms = data.permissions;
                    $scope.$emit("update_perms");
                })
                .catch(catch_error);
    }


    var permissions = API.all('permissions').getList()
            .then(function(data){
                $scope.permissions = data;
                $scope.$emit("update_perms");
            })
            .catch(catch_error);


    $scope.select_permission = function(perm){
        if( "is_selected" in perm ){
            perm.is_selected = ! perm.is_selected;
            return;
        }
        perm.is_selected = true;
    };

    $scope.is_selected = function(perm){
        if( "is_selected" in perm ){
            return perm.is_selected;
        }
        return false;
    };

    $scope.cancel = function(){
        $(".form input").val("");
        for(var i = 0; i < $scope.permissions.length;i++) {
            $scope.permissions[i].is_selected = false;
        }
    };

    $scope.save = function(){
        var permissions = [];

        for(var i = 0; i < $scope.permissions.length;i++) {
            if ($scope.permissions[i].is_selected){
                permissions.push($scope.permissions[i].name);
            }
        }

        var group = {name: $scope.new_name,
                     permissions: permissions};
        if ($scope.obj_id) {
            API.one("groups", $scope.obj_id).patch(group)
                .then(function(){
                    success_message(gettext("Group updated successfully."));
                    $location.path("/auth/groups");
                })
                .catch(catch_error);
        }
        else {
            API.all("groups").post(group).then(function(){
                success_message(gettext("Group created successfully."));
                $location.path("/auth/groups");

            }).catch(catch_error);
        }

    };
}]);