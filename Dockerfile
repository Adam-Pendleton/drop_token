FROM ruby:2.6.3

RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app

RUN apt-get update && apt-get install -y default-mysql-client postgresql-client sqlite3 --no-install-recommends && rm -rf /var/lib/apt/lists/*

COPY Gemfile /usr/src/app/
COPY Gemfile.lock /usr/srce/app/

RUN bundle install

COPY . /usr/src/app

COPY entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]
EXPOSE 3000

## Start the main process.
CMD ["rails", "server", "-b", "0.0.0.0"]