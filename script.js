$(document).ready(function() {
  var site = 'http://redmine.pfrus.com/';
  var key = '261e9890fc1b2aa799f942ff2d6daa9fa691bd91';
  var creationDate = '2014-02-18';
  // project info
/*  $.ajax({
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
                                                              ['New',             countNew],
                                                              ['Assigned',        countAssigned],
                                                              ['In progress',     countInProgress],
                                                              ['Deferred',        countDeferred],
                                                              ['Resolved',        countResolved],
                                                              ['Ready to deploy', countReadyToDeploy],
                                                              ['Closed',          countClosed],
                                                              ['Rejected',        countRejected],
                                                              ['Feedback',        countFeedback],
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
  });*/
  // issues per month
  var currentMonth = new Date().getMonth() + 1;
  var creationMonth = new Date(creationDate).getMonth() + 1;
  var countMonths = currentMonth - creationMonth;
  var issuesPerMonth = [];
  var monthNames = [ '', 'Jan.', 'Feb.', 'Mar.', 'Apr.', 'May', 'Jun.', 'Jul.', 'Aug.', 'Sep.', 'Oct.', 'Nov.', 'Dec.' ];
  var j = 0, i = 0;
  while (i < 20) {
    console.log(i);
    i++;
  }
  var k = 0;
  while (k < 100) {
    console.log(k);
    k++;
    var loopMonth = parseInt(creationMonth) + i + 1;
    var loopDate = new Date().getFullYear() + '-' + (loopMonth > 9 ? loopMonth : '0' + loopMonth) + '-01';
    issuesPerMonth[i] = [];
    $.ajax({
      type: 'GET',
      crossDomain: true,
      url: site + 'issues.json?project_id=142&limit=1&key=' + key + '&created_on=%3E%3C' + creationDate + '|' + loopDate,
      dataType: 'jsonp',
      success: function(data) {
        if (data) {
          console.log(i + '-1-' + data.total_count);
          var currentState = parseInt(100 / 2 / countMonths) * (i + 1);
          $('#progress-info .progress-bar').width(currentState + '%');
          $('#progress-info .progress-bar').attr('aria-valuenow', currentState);
          //issuesPerMonth[i].created = data.total_count;                    
        }        
      },
      complete: function(xhr,status) {
        $.ajax({
          type: 'GET',
          crossDomain: true,
          url: site + 'issues.json?project_id=142&limit=1&key=' + key + '&status_id=5&updated_on=%3E%3C' + creationDate + '|' + loopDate,
          dataType: 'jsonp',
          success: function(data) {
            if (data) {
              console.log(i + '-2-' + data.total_count);
              var currentState = parseInt(100 / 2 / countMonths) * (i + 1);
              $('#progress-info .progress-bar').width(currentState + '%');
              $('#progress-info .progress-bar').attr('aria-valuenow', currentState);
              //issuesPerMonth[i].closed = data.total_count;  
              if (i == countMonths - 1) {
                console.log(issuesPerMonth);
              }          
            }        
          },
          complete: function(xhr,status) {
            i++;
          }
        });
      }
    });
  }
});