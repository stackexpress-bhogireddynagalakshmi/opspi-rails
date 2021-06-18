FROM ruby:3.0.0
ARG RAILS_ENV
ENV RAILS_ENV=$RAILS_ENV
RUN apt-get update -qq && \
    apt-get install -y nano build-essential libpq-dev
RUN mkdir /project
RUN curl -sL https://deb.nodesource.com/setup_14.x | bash -
RUN apt-get install -y nodejs \
      cron
# confirm installation
RUN node -v
RUN apt-get -y install
RUN apt-get update && apt-get install -y mariadb-client
RUN apt-get install mysql2 -v '0.5.3' -y
RUN npm install --global yarn 
#RUN apt-get update && apt-get install -y mysql-client && rm -rf /var/lib/apt
COPY Gemfile Gemfile.lock /project/
WORKDIR /project
RUN gem update --system
RUN gem install bundler -v '2.2.3'
RUN bundle --version
RUN bundle install
COPY . /project
EXPOSE 3000
RUN RAILS_ENV=production bundle exec rake assets:precompile
#CMD [ "bundle", "exec", "rails", "server" ]
CMD ["bin/run-docker-production.sh"]
