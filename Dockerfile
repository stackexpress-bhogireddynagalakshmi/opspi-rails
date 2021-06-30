FROM ruby:3.0.0
ARG RAILS_ENV
ARG DB_HOST
ARG DB_NAME
ARG DB_USERNAME
ARG DB_PASSWORD
ARG DB_PORT
ARG SECRET_KEY_BASE
ENV RAILS_ENV=$RAILS_ENV
ENV DB_HOST=$DB_HOST
ENV DB_NAME=$DB_NAME
ENV DB_USERNAME=$DB_USERNAME
ENV DB_PASSWORD=$DB_PASSWORD
ENV DB_PORT=$DB_PORT
ENV SECRET_KEY_BASE=$SECRET_KEY_BASE
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
