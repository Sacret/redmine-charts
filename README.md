redmine-charts
==============

Redmine Charts.

Description
-----------

**Redmine Charts** is a web application which extends ProgForce Redmine with following charts: overall issues, issues per month, today issues and user's progress. Using these charts you can easily track your team's progress with the project and estimate the work done.

The application is built using [AngularJS](https://angularjs.org/) as frontend and [Express](http://expressjs.com/) as backend framework. Also many useful modules and libraries were integrated, such as [Moment.js](http://momentjs.com/), [Highcharts](http://www.highcharts.com/), [Lodash](https://lodash.com/) and others.

To start work you just need to fill 'API key' field in the form above with your Redmine API access key from [account](http://redmine.pfrus.com/my/account) page.

After that you will be able to see, estimate and control issues progress.

The 'Overall Issues' chart provides you with the following information:
-   *Total count of issues* — the number of all issues in the current project.
-   *Percentage of issues by statuses* — the number and percentage of issues according their statuses.

The 'Issues Per Month' chart provides you with the following information:
-   *Count of open and closed issues* — the number of such issues per month.
-   *Ability to choose date range* — you can manage what period of time will be shown.

The 'Today Issues' chart provides you with the following information:
-   *Count of open and closed issues* — the number of such issues for today.

The 'My Progress' chart provides you with the following information:
-   *Count of open and closed issues* — the number of such issues per week for current user.
-   *Ability to choose date range* — you can manage what period of time will be shown.

If you have any suggestions and/or bug reports — you are welcome to our [GitHub Issues](https://github.com/Sacret/redmine-charts/issues) page. We will be happy to improve all needed functionality and fix bugs.
