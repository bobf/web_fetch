FROM library/ruby:2.5.3
ADD .build/web_fetch.tar.gz .
WORKDIR web_fetch
RUN bundle && bundle exec rake install
CMD ["bundle", "exec", "web_fetch_control", "run", "--", "--port", "8077", "--host", "0.0.0.0"]
