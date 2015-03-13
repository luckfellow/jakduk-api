<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>    
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>    

<!DOCTYPE html>
<html ng-app="jakdukApp">
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
	<title><spring:message code="stats"/> &middot; <spring:message code="common.jakduk"/></title>
	
	<link rel="stylesheet" href="<%=request.getContextPath()%>/resources/unify/assets/plugins/cube-portfolio/cubeportfolio/css/cubeportfolio.min.css">
	<link rel="stylesheet" href="<%=request.getContextPath()%>/resources/unify/assets/plugins/cube-portfolio/cubeportfolio/custom/custom-cubeportfolio.css">
	
	<jsp:include page="../include/html-header.jsp"></jsp:include>
</head>

<body>
<div class="wrapper" ng-controller="statsCtrl">
	<jsp:include page="../include/navigation-header.jsp"/>
	
	<!--=== Breadcrumbs ===-->
	<div class="breadcrumbs">
		<div class="container">
			<h1 class="pull-left"><a href="<c:url value="/stats/supporters/refresh"/>"><spring:message code="stats.supporters"/></a></h1>
		</div><!--/container-->
	</div><!--/breadcrumbs-->
	<!--=== End Breadcrumbs ===-->		

	<!--=== Content Part ===-->
	<div class="container content">

<div class="cube-portfolio">	
		<div id="filters-container" class="cbp-l-filters-text content-xs">
			<div class="cbp-filter-item"
			ng-class="{'cbp-filter-item-active':chartConfig.options.chart.type == 'bar'}" ng-click="changeChartType('bar')"> 
				<spring:message code="stats.chart.bar"/> 
			</div> |
			<div class="cbp-filter-item"
			ng-class="{'cbp-filter-item-active':chartConfig.options.chart.type == 'pie'}" ng-click="changeChartType('pie')"> 
				<spring:message code="stats.chart.pie"/> 
			</div>
		</div><!--/end Filters Container-->
</div>   			

	 <highchart id="chart1" config="chartConfig" class="margin-bottom-10"></highchart>

<div class="tag-box tag-box-v4 margin-bottom-20">
	<p><spring:message code="stats.msg.total.number.of.members"/><strong>{{usersTotal}}</strong></p>
	<p><spring:message code="stats.msg.total.number.of.supporters"/><strong>{{supportersTotal}}</strong></p>	
</div>

<div class="text-right">
<button class="btn-u btn-brd rounded" type="button" ng-click="btnUrlCopy()">
	<spring:message code="common.button.copy.url.to.clipboard"/>
</button>
    <a id="kakao-link-btn" href="javascript:;">
      <img src="<%=request.getContextPath()%>/resources/kakao/icon/kakaolink_btn_small.png" />
    </a>
</div>
	 
	</div>
	
	<jsp:include page="../include/footer.jsp"/>	
</div>

<!-- Bootstrap core JavaScript
  ================================================== -->
<!-- Placed at the end of the document so the pages load faster -->
<script src="<%=request.getContextPath()%>/resources/jquery/dist/jquery.min.js"></script>

<script src="<%=request.getContextPath()%>/resources/kakao/js/kakao.min.js"></script>

<script src="<%=request.getContextPath()%>/resources/highcharts/highcharts.js"></script>
<script src="<%=request.getContextPath()%>/resources/highcharts/modules/exporting.js"></script>
<script src="<%=request.getContextPath()%>/resources/highcharts-ng/dist/highcharts-ng.min.js"></script>

<script type="text/javascript">
var jakdukApp = angular.module("jakdukApp", ["highcharts-ng"]);

jakdukApp.controller('statsCtrl', function($scope, $http) {
	$scope.supportersConn = "none";
	$scope.chartSeriesData = [];
	$scope.supportersTotal = 0;
	$scope.usersTotal = 0;
	
	angular.element(document).ready(function() {			
		$scope.getSupporters();
		
		var chartType = "${chartType}";
		
		if (chartType != "pie") {			
			chartType = "bar";
		}
		
		$scope.chartConfig = {
			options: {
				chart: {
					type: chartType,
					height: 100
				},
				tooltip: {
					//pointFormat: '<spring:message code="stats.number.of.supporter"/> : <b>{point.y:1f}</b> <spring:message code="stats.attendance.people"/>'
	            }
			},	        
			title: {
				text: '<spring:message code="stats.supporters.title"/>'
	        },	        
			subtitle: {
				text: 'Source: https://jakduk.com'
            },
			xAxis: {
				type: 'category',
				labels: {
					style: {
						fontSize: '13px'
                    }
                }
            },
			yAxis: {
				min: 0,
				title: {
					text: '<spring:message code="stats.number.of.supporter"/>'
                }							
            },                                 
			series: [{
				name: '<spring:message code="stats.number.of.supporter"/>',
				data: $scope.chartSeriesData,
				dataLabels: {
					enabled: true,
					align: 'right',
					format: '{point.name} <b>{point.y:1f}</b>',
					style: {
						fontSize: '13px'
                    }
                }
            }],
			loading: true,
			credits:{enabled:true}
		};		
		
	    // 사용할 앱의 Javascript 키를 설정해 주세요.
   Kakao.init('${kakaoKey}');

	    // 카카오톡 링크 버튼을 생성합니다. 처음 한번만 호출하면 됩니다.
   Kakao.Link.createTalkLinkButton({
			container: '#kakao-link-btn',
			label: '<spring:message code="stats.supporters.title"/>\r<spring:message code="stats"/> · <spring:message code="common.jakduk"/>',
			webLink: {
				text: "https://jakduk.com/stats/supporters",
				url: "https://jakduk.com/stats/supporters"	    	  
			}
		});	    
	});
	
	$scope.getSupporters = function() {
		var bUrl = '<c:url value="/stats/data/supporters.json"/>';
		
		if ($scope.supportersConn == "none") {
			
			var reqPromise = $http.get(bUrl);
			
			$scope.supportersConn = "loading";
			
			reqPromise.success(function(data, status, headers, config) {
				
				$scope.supportersTotal = data.supportersTotal;
				$scope.usersTotal = data.usersTotal;
				var supporters = data.supporters;
				$scope.chartConfig.options.chart.height = 200 + (supporters.length * 30);
				
				supporters.forEach(function(supporter) {
					var item = [supporter.supportFC.names[0].shortName, supporter.count];
					$scope.chartSeriesData.push(item);
				});
				
				$scope.supportersConn = "none";
				$scope.chartConfig.loading = false;
				
			});
			reqPromise.error(function(data, status, headers, config) {
				$scope.supportersConn = "none";
				$scope.error = '<spring:message code="common.msg.error.network.unstable"/>';
			});
		}
	};
	
	$scope.changeChartType = function(chartName) {
		$scope.chartConfig.options.chart.type = chartName;
	};
	
	$scope.btnUrlCopy = function() {
		var url = "https://jakduk.com/stats/supporters?chartType=" + $scope.chartConfig.options.chart.type;
		
		if(window.clipboardData){
		    // IE처리
		    // 클립보드에 문자열 복사
		    window.clipboardData.setData('text', url);
		    
		    // 클립보드의 내용 가져오기
		    // window.clipboardData.getData('Text');
		 
		    // 클립보드의 내용 지우기
		    // window.clipboardData.clearData("Text");
		  }  else {                     
		    // 비IE 처리    
		    window.prompt ('<spring:message code="common.msg.copy.to.clipboard"/>', url);  
		  }
	}
	
});
</script>

<jsp:include page="../include/body-footer.jsp"/>
</body>
</html>