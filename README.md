neomatch
========

A sample application matching jobs with candidates


Installation
------------

    git clone git://github.com/maxdemarzi/neomatch.git
    bundle install
    rake neo4j:install
    rake neo4j:start
    rake neo4j:create
    rackup

On Heroku
---------

    git clone git://github.com/maxdemarzi/neomatch.git
    heroku apps:create neomatch
    heroku addons:add neo4j
    git push heroku master
    heroku rake neo4j:create

See it running live at http://neomatch.heroku.com

![Screenshot](https://raw.github.com/maxdemarzi/neomatch/master/neomatch.png)