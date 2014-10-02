<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Redmine Charts</title>
    <link href="resources/bootstrap.min.css" rel="stylesheet">    
  </head>
  <body>
    <div class="container">
      <div class="jumbotron">
        <h1>Redmine Charts for Logoworks Team</h1>
        <p>Some textual and graphical information about tasks, bugs and issues</p>
      </div>
      <h1>Logoworks Info</h1>
      <div class="progress" id="progress-info">
        <div class="progress-bar progress-bar-striped active" role="progressbar" aria-valuenow="0" aria-valuemin="0" aria-valuemax="100" style="width: 0%"></div>
      </div>
      <dl>
        <dt>Name</dt>
        <dd id="project-name"></dd>
        <dt>Identifier</dt>
        <dd id="project-identifier"></dd>
        <dt>Created</dt>
        <dd id="project-created"></dd>
        <dt>Trackers</dt>
        <dd id="project-trackers"></dd>
      </dl>
      <h1>Logoworks Issues Overall</h1>
      <div class="progress" id="progress-issues-overall">
        <div class="progress-bar progress-bar-striped active" role="progressbar" aria-valuenow="0" aria-valuemin="0" aria-valuemax="100" style="width: 0%"></div>
      </div>
      <div id="issues-overall"></div>
      <h1>Logoworks Per Month</h1>
      <div class="progress" id="progress-issues-per-month">
        <div class="progress-bar progress-bar-striped active" role="progressbar" aria-valuenow="0" aria-valuemin="0" aria-valuemax="100" style="width: 0%"></div>
      </div>
      <div id="issues-per-month"></div>
    </div>
    <script type="text/javascript" src="http://ajax.googleapis.com/ajax/libs/jquery/1.8.2/jquery.min.js"></script>
    <script type="text/javascript" src="resources/bootstrap.min.js"></script>
    <script type="text/javascript" src="resources/highcharts.js"></script>
    <script type="text/javascript" src="script.js"></script>
  </body>
</html>