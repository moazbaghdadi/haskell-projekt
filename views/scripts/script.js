var app = angular.module('myApp', []);

app.controller('TableController', ['$window', '$scope', '$http', function($window,$scope, $http) {
		$scope.showtable = true;
		$scope.showaddform = false;
		$scope.showchances =  false;
		$scope.showerr = false;
		$scope.matchseason = 2015;
		
		$http.get("/getTable")
		.then(function (response) {
		$scope.season = response.data.season;
		$scope.rows = response.data.teams;
		});
		
		$http.get("/getAllMatches", {params: {season : $scope.matchseason}})
		.then(function (response) {
				$scope.matches = response.data;
		});		
		
		$http.get("/getTeams")
		.then(function (response) {
		$scope.teams = response.data;
		});
		
		$http.get("/getChances", {params: {season: 2015}})
		.then(function (response) {
		$scope.chances	 = response.data;
		});
		
		
		$scope.tableClick = function() {
				$scope.showtable = true;
				$scope.showmatches = false;
				$scope.showaddform = false;
				$scope.showchances =  false;
		}
		
		$scope.matchesClick = function() {
				$scope.showtable = false;
				$scope.showmatches = true;
				$scope.showaddform = false;
				$scope.showchances =  false;
		}
		
		$scope.addMatchesClick = function() {
				$scope.showtable = false;
				$scope.showmatches = false;
				$scope.showaddform = true;
				$scope.showchances =  false;
		}
		
		$scope.chancesClick = function() {
				$scope.showtable = false;
				$scope.showmatches = false;
				$scope.showaddform = false;
				$scope.showchances =  true;
		}
		
		$scope.selectMatchesTeam = function() {
				var req = {
						season : $scope.matchseason,
						team : $scope.team
				}
				if ($scope.team == "All"){
					$http({
						url: "/getAllMatches",
						method: "GET",
						params: {season : $scope.matchseason}
					}).then(function (response) {
						$scope.matches = response.data;
					});
				} else {
					$http({
					url: "/getMatch",
					method: "GET",
					params: req
					})
					.then(function (response) {
						$scope.showMatcherr = false;
						$scope.matches = response.data;
					}, function(data) {
						$scope.showMatcherr = true;
					});
				}
		}
		
		$scope.submitMatch = function() {
				
				var req = {
						matchweek : $scope.matchweek,
						season: $scope.season,
						hometeam: $scope.hometeam,
						awayteam: $scope.awayteam,
						homescore: $scope.homescore,
						awayscore: $scope.awayscore
				}
				$http({
				url: "/postMatch",
				method: "GET",
				params: req
				})
				.then(function (response) {
					$scope.showerr = false;
					$http.get("/getTable")
					.then(function (response) {
						$scope.season = response.data.season;
						$scope.rows = response.data.teams;
					});
					$http.get("/getChances", {params: {season: $scope.season}})
						.then(function (response) {
						$scope.chances	 = response.data;
					});
				}, function(data) {
					$scope.showerr = true;
				});
		}

}]);