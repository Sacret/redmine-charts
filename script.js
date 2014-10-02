$(document).ready(function() {
  var site = 'http://redmine.pfrus.com/';
  var key = '261e9890fc1b2aa799f942ff2d6daa9fa691bd91';
  var creationDate = '2014-02-18';
  var projectId = 142;
  // project info
  if (readCookie('logoworks-info')) {
    NextStep('#progress-info .progress-bar', 100);
    var logoworksInfo = $.parseJSON(readCookie('logoworks-info'));
    $('#project-name').text(logoworksInfo.name);
    $('#project-identifier').text(logoworksInfo.identifier);
    $('#project-created').text(logoworksInfo.creationDate);
    $('#project-trackers').text(logoworksInfo.trackers);
    $('#progress-info').animate({opacity: 0}, 1000);
  }
  else {
    $.ajax({
      type: 'GET',
      crossDomain: true,
      url: site + 'projects/' + projectId + '.json?key=' + key + '&include=trackers,issue_categories',
      dataType: 'jsonp',
      success: function(data) {
        if (data) {
          NextStep('#progress-info .progress-bar', 100);
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
          var logoworksObject = {
            name: data.project.name,
            identifier: data.project.identifier,
            creationDate: creationDate,
            trackers: trackers,
          };
          createCookie('logoworks-info', JSON.stringify(logoworksObject), 30);
        }
      },
      complete: function(xhr,status) {
        $('#progress-info').animate({opacity: 0}, 1000);
      }
    });
  }
  // overall issues info
  var countNew, countAssigned, countInProgress, countDeferred, countResolved,
    countReadyToDeploy, countClosed, countRejected;
  var issueStatuses = [];
  var functionIssueStatuses = [];
  $.ajax({
    type: 'GET',
    crossDomain: true,
    url: site + 'issue_statuses.json?key=' + key,
    dataType: 'jsonp',
    success: function(data) {
      if (data) {
        var issueStep = parseInt(100 / data.issue_statuses.length);
        for (var i = 0; i < data.issue_statuses.length; i++) {
          (function(i) {
            functionIssueStatuses.push(
              function(done) {
                $.ajax({
                  type: 'GET',
                  crossDomain: true,
                  url: site + 'issues.json?project_id=' + projectId + '&limit=1&key=' + key + '&status_id=' + data.issue_statuses[i].id,
                  dataType: 'jsonp',
                  success: function(dataNew) {
                    if (dataNew) {
                      NextStep('#progress-issues-per-month .progress-bar', issueStep);
                      issueStatuses.push([
                        data.issue_statuses[i].name + ' (' + dataNew.total_count + ')',
                        dataNew.total_count
                      ]);
                      done();
                    }
                  }
                });
              }
            );
          })(i)
        }
        async.parallel(
          functionIssueStatuses,
          function(err, results) {
            $('#progress-issues-overall').animate({opacity: 0}, 1000);
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
                name: 'Issues share',
                data: issueStatuses
              }]
            });
          }
        );
      }
    }
  });
  // issues per month
  var currentMonth = new Date().getMonth() + 1;
  var creationMonth = new Date(creationDate).getMonth() + 1;
  var countMonths = currentMonth - creationMonth;
  var monthNames = [ '', 'Jan.', 'Feb.', 'Mar.', 'Apr.', 'May', 'Jun.', 'Jul.',
    'Aug.', 'Sep.', 'Oct.', 'Nov.', 'Dec.' ];
  var monthLenths = [0, 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
  var functionArray = [];
  var createdIssues = [];
  var closedIssues = [];
  var stateStep = parseInt(100 / 2 / countMonths);
  for (var i = 0; i <= countMonths; i++) {
    var loopMonth = parseInt(creationMonth) + i;
    var loopDate1 = new Date().getFullYear() + '-' + (loopMonth > 9 ? loopMonth : '0' + loopMonth) + '-01';
    var loopDate2 = new Date().getFullYear() + '-' + (loopMonth > 9 ? loopMonth : '0' + loopMonth) + '-' + monthLenths[loopMonth];
    (function(i, loopDate1, loopDate2) {
      if (i !== countMonths && readCookie('logoworks-created-' + i)) {
        NextStep('#progress-issues-per-month .progress-bar', stateStep);
        createdIssues.push({
          number: i,
          data: parseInt(readCookie('logoworks-created-' + i)),
        });
      }
      else {
        functionArray.push(
          function(done) {
            $.ajax({
              type: 'GET',
              crossDomain: true,
              url: site + 'issues.json?project_id=' + projectId + '&limit=1&key=' + key + '&status_id=*&created_on=><' + loopDate1 + '|' + loopDate2,
              dataType: 'jsonp',
              success: function(data) {
                if (data) {
                  NextStep('#progress-issues-per-month .progress-bar', stateStep);
                  createCookie('logoworks-created-' + i, data.total_count, 30);
                  createdIssues.push({
                    number: i,
                    data: data.total_count,
                  });
                  done();
                }
              }
            });
          }
        );
      }
      if (i !== countMonths && readCookie('logoworks-closed-' + i)) {
        NextStep('#progress-issues-per-month .progress-bar', stateStep);
        closedIssues.push({
          number: i,
          data: parseInt(readCookie('logoworks-closed-' + i)),
        });
      }
      else {
        functionArray.push(
          function(done) {
            $.ajax({
              type: 'GET',
              crossDomain: true,
              url: site + 'issues.json?project_id=' + projectId + '&limit=1&key=' + key + '&status_id=closed&updated_on=><' + loopDate1 + '|' + loopDate2,
              dataType: 'jsonp',
              success: function(data) {
                if (data) {
                  NextStep('#progress-issues-per-month .progress-bar', stateStep);
                  createCookie('logoworks-closed-' + i, data.total_count, 30);
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
      }
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
  // today issues
  var currentDate = new Date();
  var currentFormattedDate = currentDate.getFullYear() + '-' + (currentDate.getMonth() + 1 > 9 ? currentDate.getMonth() + 1 : '0' + (currentDate.getMonth() + 1)) + '-' + (currentDate.getDate() > 9 ? currentDate.getDate() : '0' + currentDate.getDate());
  var countCreatedToday, countClosedToday;
  async.parallel([
    function(done) {
      $.ajax({
        type: 'GET',
        crossDomain: true,
        url: site + 'issues.json?project_id=' + projectId + '&limit=1&key=' + key + '&status_id=*&created_on=' + currentFormattedDate,
        dataType: 'jsonp',
        success: function(data) {
          if (data) {
            NextStep('#progress-issues-today .progress-bar', 50);
            countCreatedToday = data.total_count;
            done();
          }
        }
      });
    },
    function(done) {
      $.ajax({
        type: 'GET',
        crossDomain: true,
        url: site + 'issues.json?project_id=' + projectId + '&limit=1&key=' + key + '&status_id=closed&updated_on==' + currentFormattedDate,
        dataType: 'jsonp',
        success: function(data) {
          if (data) {
            NextStep('#progress-issues-today .progress-bar', 50);
            countClosedToday = data.total_count;
            done();
          }
        }
      });
    }],
    function(err, results) {
      $('#progress-issues-today').animate({opacity: 0}, 1000);
      var countTotalToday = countCreatedToday + countClosedToday;
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
          color: 'rgba(227,227,227,.9)',
          data: [countClosedToday],
          pointPadding: 0.4,
          pointPlacement: -0.2
        }]
      });
    }
  );
  // sorting function
  function SortByNumber(a, b){
    var aNumber = a.number;
    var bNumber = b.number;
    return ((aNumber < bNumber) ? -1 : ((aNumber > bNumber) ? 1 : 0));
  }
  // next step for progressbar
  function NextStep(object, stateStep) {
    var currentState = parseInt($(object).attr('aria-valuenow')) + stateStep;
    $(object).width(currentState + '%');
    $(object).attr('aria-valuenow', currentState);
  }
  // set cookie
  function createCookie(name, value, days) {
    if (days) {
      var date = new Date();
      date.setTime(date.getTime() + (days * 24 * 60 * 60 * 1000));
      var expires = '; expires=' + date.toGMTString();
    }
    else {
      var expires = '';
    }
    document.cookie = name + '=' + value + expires + '; path=/';
  }
  // get cookie
  function readCookie(name) {
    var nameEQ = name + '=';
    var ca = document.cookie.split(';');
    for (var i = 0;i < ca.length; i++) {
      var c = ca[i];
      while (c.charAt(0) == ' ') {
        c = c.substring(1, c.length);
      }
      if (c.indexOf(nameEQ) == 0) {
        return c.substring(nameEQ.length, c.length);
      }
    }
    return null;
  }
});
