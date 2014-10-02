$(document).ready(function() {
  var site = 'http://redmine.pfrus.com/';
  var key = '261e9890fc1b2aa799f942ff2d6daa9fa691bd91';
  var creationDate = '2014-02-18';
  // project info
  $.ajax({
    type: 'GET',
    crossDomain: true,
    url: site + 'projects/142.json?key=' + key + '&include=trackers,issue_categories',
    dataType: 'jsonp',
    success: function(data) {
      if (data) {
        $('#progress-info .progress-bar').width('100%');
        $('#progress-info .progress-bar').attr('aria-valuenow', 100);
        $('#project-name').text(data.project.name);
        $('#project-identifier').text(data.project.identifier);
        creationDate = data.project.created_on.substr(0, 10);
        $('#project-created').text(creationDate);
        var trackers = '';
        for (var i = 0; i < data.project.trackers.length; i++) {
          trackers += data.project.trackers[i].name;
          trackers += (i !== data.project.trackers.length - 1) ? ', ' : '';
        }
        $('#project-trackers').text(trackers);
      }        
    },
    complete: function(xhr,status) {
      $('#progress-info').animate({opacity: 0}, 1000);
    }
  });
  // overall issues info
  $.ajax({
    type: 'GET',
    crossDomain: true,
    url: site + 'issues.json?project_id=142&status_id=1&limit=1&key=' + key,
    dataType: 'jsonp',
    success: function(data) {
      if (data) {
        var countNew = data.total_count;
        $('#progress-issues-overall .progress-bar').width('11%');
        $('#progress-issues-overall .progress-bar').attr('aria-valuenow', 11);
        $.ajax({
          type: 'GET',
          crossDomain: true,
          url: site + 'issues.json?project_id=142&status_id=2&limit=1&key=' + key,
          dataType: 'jsonp',
          success: function(data) {
            if (data) {
              var countAssigned = data.total_count;  
              $('#progress-issues-overall .progress-bar').width('22%');
              $('#progress-issues-overall .progress-bar').attr('aria-valuenow', 22); 
              $.ajax({
                type: 'GET',
                crossDomain: true,
                url: site + 'issues.json?project_id=142&status_id=7&limit=1&key=' + key,
                dataType: 'jsonp',
                success: function(data) {
                  if (data) {
                    var countInProgress = data.total_count;  
                    $('#progress-issues-overall .progress-bar').width('33%');
                    $('#progress-issues-overall .progress-bar').attr('aria-valuenow', 33);    
                    $.ajax({
                      type: 'GET',
                      crossDomain: true,
                      url: site + 'issues.json?project_id=142&status_id=9&limit=1&key=' + key,
                      dataType: 'jsonp',
                      success: function(data) {
                        if (data) {
                          var countDeferred = data.total_count;
                          $('#progress-issues-overall .progress-bar').width('44%');
                          $('#progress-issues-overall .progress-bar').attr('aria-valuenow', 44);      
                          $.ajax({
                            type: 'GET',
                            crossDomain: true,
                            url: site + 'issues.json?project_id=142&status_id=3&limit=1&key=' + key,
                            dataType: 'jsonp',
                            success: function(data) {
                              if (data) {
                                var countResolved = data.total_count;  
                                $('#progress-issues-overall .progress-bar').width('56%');
                                $('#progress-issues-overall .progress-bar').attr('aria-valuenow', 56);   
                                $.ajax({
                                  type: 'GET',
                                  crossDomain: true,
                                  url: site + 'issues.json?project_id=142&status_id=12&limit=1&key=' + key,
                                  dataType: 'jsonp',
                                  success: function(data) {
                                    if (data) {
                                      var countReadyToDeploy = data.total_count;   
                                      $('#progress-issues-overall .progress-bar').width('67%');
                                      $('#progress-issues-overall .progress-bar').attr('aria-valuenow', 67);      
                                      $.ajax({
                                        type: 'GET',
                                        crossDomain: true,
                                        url: site + 'issues.json?project_id=142&status_id=5&limit=1&key=' + key,
                                        dataType: 'jsonp',
                                        success: function(data) {
                                          if (data) {
                                            var countClosed = data.total_count;    
                                            $('#progress-issues-overall .progress-bar').width('78%');
                                            $('#progress-issues-overall .progress-bar').attr('aria-valuenow', 78);   
                                            $.ajax({
                                              type: 'GET',
                                              crossDomain: true,
                                              url: site + 'issues.json?project_id=142&status_id=6&limit=1&key=' + key,
                                              dataType: 'jsonp',
                                              success: function(data) {
                                                if (data) {
                                                  var countRejected = data.total_count;   
                                                  $('#progress-issues-overall .progress-bar').width('89%');
                                                  $('#progress-issues-overall .progress-bar').attr('aria-valuenow', 89);    
                                                  $.ajax({
                                                    type: 'GET',
                                                    crossDomain: true,
                                                    url: site + 'issues.json?project_id=142&status_id=4&limit=1&key=' + key,
                                                    dataType: 'jsonp',
                                                    success: function(data) {
                                                      if (data) {
                                                        $('#progress-issues-overall .progress-bar').width('100%');
                                                        $('#progress-issues-overall .progress-bar').attr('aria-valuenow', 100);
                                                        var countFeedback = data.total_count;   
                                                        $('#issues-overall').highcharts({
                                                          chart: {
                                                            plotBackgroundColor: null,
                                                            plotBorderWidth: 1,
                                                            plotShadow: false
                                                          },
                                                          title: {
                                                            text: ''
                                                          },
                                                          tooltip: {
                                                            pointFormat: 'Status share: <b>{point.percentage:.1f}%</b>'
                                                          },
                                                          series: [{
                                                            type: 'pie',
                                                            name: 'Browser share',
                                                            data: [
                                                              ['New (' + countNew + ')', countNew],
                                                              ['Assigned (' + countAssigned + ')',countAssigned],
                                                              ['In progress (' + countInProgress + ')',countInProgress],
                                                              ['Deferred (' + countDeferred + ')',countDeferred],
                                                              ['Resolved (' + countResolved + ')',countResolved],
                                                              ['Ready to deploy (' + countReadyToDeploy + ')', countReadyToDeploy],
                                                              ['Closed (' + countClosed + ')',countClosed],
                                                              ['Rejected (' + countRejected + ')',countRejected],
                                                              ['Feedback (' + countFeedback + ')',countFeedback],
                                                            ]
                                                          }]
                                                        });           
                                                      }        
                                                    },
                                                    complete: function(xhr,status) {
                                                      $('#progress-issues-overall').animate({opacity: 0}, 1000);
                                                    }
                                                  });         
                                                }        
                                              }
                                            });        
                                          }        
                                        }
                                      });      
                                    }        
                                  }
                                });           
                              }        
                            }
                          });         
                        }        
                      }
                    });         
                  }        
                }
              });           
            }        
          }
        });
      }        
    }
  });
  // issues per month
  var currentMonth = new Date().getMonth() + 1;
  var creationMonth = new Date(creationDate).getMonth() + 1;
  var countMonths = currentMonth - creationMonth;
  var monthNames = [ '', 'Jan.', 'Feb.', 'Mar.', 'Apr.', 'May', 'Jun.', 'Jul.', 'Aug.', 'Sep.', 'Oct.', 'Nov.', 'Dec.' ];
  var functionArray = [];
  var createdIssues = [];
  var closedIssues = [];
  var stateStep = 100 / 2 / countMonths;
  for (var i = 0; i <= countMonths; i++) {
    var loopMonth = parseInt(creationMonth) + i;
    var loopDate1 = new Date().getFullYear() + '-' + (loopMonth > 9 ? loopMonth : '0' + loopMonth) + '-01';
    var loopDate2 = new Date().getFullYear() + '-' + (loopMonth + 1 > 9 ? loopMonth + 1 : '0' + (loopMonth + 1)) + '-01';
    (function(i, loopDate1, loopDate2) {      
      functionArray.push(
        function(done) {
          $.ajax({
            type: 'GET',
            crossDomain: true,
            url: site + 'issues.json?project_id=142&limit=1&key=' + key + '&status_id=*&created_on=><' + loopDate1 + '|' + loopDate2,
            dataType: 'jsonp',
            success: function(data) {
              if (data) {
                var currentState = parseInt($('#progress-issues-per-month .progress-bar').attr('aria-valuenow')) + stateStep;
                $('#progress-issues-per-month .progress-bar').width(currentState + '%');
                $('#progress-issues-per-month .progress-bar').attr('aria-valuenow', currentState);
                createdIssues.push({
                  number: i,
                  data: data.total_count
                });
                done();                
              }        
            }
          });
        }
      ); 
      functionArray.push(
        function(done) {
          $.ajax({
            type: 'GET',
            crossDomain: true,
            url: site + 'issues.json?project_id=142&limit=1&key=' + key + '&status_id=5&updated_on=><' + loopDate1 + '|' + loopDate2,
            dataType: 'jsonp',
            success: function(data) {
              if (data) {
                var currentState = parseInt($('#progress-issues-per-month .progress-bar').attr('aria-valuenow')) + stateStep;
                $('#progress-issues-per-month .progress-bar').width(currentState + '%');
                $('#progress-issues-per-month .progress-bar').attr('aria-valuenow', currentState); 
                closedIssues.push({
                  number: i,
                  data: data.total_count
                });
                done();       
              }        
            }
          }); 
        }
      );       
    })(i, loopDate1, loopDate2)
  }
  async.parallel(
    functionArray,
    function(err, results){
      $('#progress-issues-per-month').animate({opacity: 0}, 1000);
      var workMonths = monthNames.slice(creationMonth, currentMonth + 1);
      var series = [];
      //
      var dataCreated = [];
      var sortedCreatedIssues = createdIssues.sort(SortByNumber);
      for (var j = 0; j < sortedCreatedIssues.length; j++) {
        dataCreated.push(sortedCreatedIssues[j].data);
      }
      series.push({
        name: 'Created Issues',
        data: dataCreated,
      });
      //
      var dataClosed = [];
      var sortedClosedIssues = closedIssues.sort(SortByNumber);
      for (var j = 0; j < sortedClosedIssues.length; j++) {
        dataClosed.push(sortedClosedIssues[j].data);
      }
      series.push({
        name: 'Closed Issues',
        data: dataClosed,
      });
      // highchart
      $('#issues-per-month').highcharts({
        chart: {
          type: 'column'
        },
        title: {
          text: ''
        },
        xAxis: {
          categories: workMonths
        },
        yAxis: {
          min: 0,
          title: {
              text: 'Issues count'
          }
        },
        plotOptions: {
          column: {
            pointPadding: 0.2,
            borderWidth: 0
          }
        },
        series: series
      });      
    }
  );
  // sorting function
  function SortByNumber(a, b){
    var aNumber = a.number;
    var bNumber = b.number; 
    return ((aNumber < bNumber) ? -1 : ((aNumber > bNumber) ? 1 : 0));
  }
  // today issues
  var currentDate = new Date();
  var currentFormattedDate = currentDate.getFullYear() + '-' + (currentDate.getMonth() + 1 > 9 ? currentDate.getMonth() + 1 : '0' + (currentDate.getMonth() + 1)) + '-' + (currentDate.getDate() > 9 ? currentDate.getDate() : '0' + currentDate.getDate());
  $.ajax({
    type: 'GET',
    crossDomain: true,
    url: site + 'issues.json?project_id=142&limit=1&key=' + key + '&status_id=*&created_on=' + currentFormattedDate,
    dataType: 'jsonp',
    success: function(data) {
      if (data) {
        var countCreatedToday = data.total_count;
        $('#progress-issues-today .progress-bar').width('50%');
        $('#progress-issues-today .progress-bar').attr('aria-valuenow', 50);  
        $.ajax({
          type: 'GET',
          crossDomain: true,
          url: site + 'issues.json?project_id=142&limit=1&key=' + key + '&status_id=5&updated_on==' + currentFormattedDate,
          dataType: 'jsonp',
          success: function(data) {
            if (data) {
              var countClosedToday = data.total_count;
              var countTotalToday = countCreatedToday + countClosedToday;
              $('#progress-issues-today .progress-bar').width('100%');
              $('#progress-issues-today .progress-bar').attr('aria-valuenow', 100);
              $('#issues-today').highcharts({
                chart: {
                  type: 'column'
                },
                title: {
                  text: ''
                },
                xAxis: {
                  categories: [
                    'Today Issues (' + countTotalToday + ')',
                  ]
                },
                yAxis: [{
                  min: 0,
                  title: {
                    text: 'Issues'
                  }
                }],
                legend: {
                  shadow: false
                },
                tooltip: {
                  shared: true
                },
                plotOptions: {
                  column: {
                    grouping: false,
                    shadow: false,
                    borderWidth: 0
                  }
                },
                series: [{
                  name: 'Created',
                  color: 'rgba(165,170,217,1)',
                  data: [countCreatedToday],
                  pointPadding: 0.3,
                  pointPlacement: -0.2
                }, {
                  name: 'Closed',
                  color: 'rgba(126,86,134,.9)',
                  data: [countClosedToday],
                  pointPadding: 0.4,
                  pointPlacement: -0.2
                }]
              });              
            }        
          },
          complete: function(xhr,status) {
            $('#progress-issues-today').animate({opacity: 0}, 1000);
          }
        });
      }        
    }
  });
});
